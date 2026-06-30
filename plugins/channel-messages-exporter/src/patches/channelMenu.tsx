import { logger } from "@vendetta";
import { findByName } from "@vendetta/metro";
import { after, before } from "@vendetta/patcher";

import type { RawChannel } from "../export/types";
import { getSettings } from "../settings/defaults";
import { getChannel, getLazyActionSheet } from "../metro/stores";
import { openExportSheet } from "../ui/openExport";
import { createActionSheetRow } from "./actionSheetRow";
import { findMutableActionRows, hasActionLabel } from "./actionSheetUtils";

type Unpatch = () => void;

const CHANNEL_SHEET_NAMES = [
    "ChannelDetailsActionSheet",
    "ChannelInfoActionSheet",
    "ChannelContextActionSheet",
    "ChannelLongPressActionSheet",
    "ChannelSettingsActionSheet",
];

const CHANNEL_SHEET_KEY_FRAGMENTS = [
    "ChannelDetails",
    "ChannelInfo",
    "ChannelContext",
    "ChannelLongPress",
    "ChannelSettings",
];

function extractChannel(context: unknown): RawChannel | null {
    if (!context || typeof context !== "object") return null;
    const record = context as Record<string, unknown>;

    const direct = record.channel as RawChannel | undefined;
    if (direct?.id) return direct;

    const channelId = typeof record.channelId === "string" ? record.channelId : undefined;
    if (channelId) return getChannel(channelId);

    const guildChannel = (record.guild as { channel?: RawChannel } | undefined)?.channel;
    if (guildChannel?.id) return guildChannel;

    return null;
}

function injectExportMessages(tree: unknown, channel: RawChannel, hideSheet: () => void): unknown {
    const buttons = findMutableActionRows(tree);
    if (!buttons || hasActionLabel(buttons, "Export messages")) return tree;

    try {
        const row = createActionSheetRow(buttons, "Export messages", () => {
            hideSheet();
            openExportSheet(channel);
        });
        if (row) buttons.push(row);
    } catch (error) {
        logger.warn("[ChannelExporter] Failed to inject channel menu row", error);
    }

    return tree;
}

function patchNamedChannelSheet(name: string, hideSheet: () => void): Unpatch | null {
    const sheet = findByName(name, false) as Record<string, unknown> | null;
    if (!sheet?.default) return null;

    return after("default", sheet, ([props], tree) => {
        const channel =
            extractChannel(props) ??
            extractChannel((props as { context?: unknown })?.context) ??
            extractChannel((props as { route?: { params?: unknown } })?.route?.params);

        if (!channel) return tree;
        return injectExportMessages(tree, channel, hideSheet);
    });
}

function patchLazyChannelSheets(): Unpatch {
    const lazyActionSheet = getLazyActionSheet();
    if (!lazyActionSheet?.openLazy) return () => {};

    return before("openLazy", lazyActionSheet, ([component, key, context]) => {
        if (typeof key !== "string") return;
        if (getSettings().debugMode) {
            logger.log(`[ChannelExporter] openLazy: ${key}`);
        }
        if (!CHANNEL_SHEET_KEY_FRAGMENTS.some((fragment) => key.includes(fragment))) return;

        const channel = extractChannel(context);
        if (!channel) return;

        component.then((instance: { default?: unknown }) => {
            if (!instance?.default || typeof instance.default !== "object") return;

            after("default", instance as Record<string, unknown>, (_props, tree) =>
                injectExportMessages(tree, channel, () => lazyActionSheet.hideActionSheet?.()),
            );
        });
    });
}

export function patchChannelMenus(): Unpatch {
    const lazyActionSheet = getLazyActionSheet();
    if (!lazyActionSheet?.openLazy) {
        logger.warn("[ChannelExporter] LazyActionSheet module not found");
    }

    const hideSheet = () => lazyActionSheet?.hideActionSheet?.();
    const unpatches: Unpatch[] = [];

    for (const name of CHANNEL_SHEET_NAMES) {
        const patch = patchNamedChannelSheet(name, hideSheet);
        if (patch) unpatches.push(patch);
    }

    unpatches.push(patchLazyChannelSheets());

    logger.log(
        `[ChannelExporter] Channel sheet patches: ${unpatches.length - 1} direct, lazy fallback on`,
    );

    return () => unpatches.forEach((unpatch) => unpatch());
}
