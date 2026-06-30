import { logger } from "@vendetta";
import { find, findByName, findByProps } from "@vendetta/metro";
import { after, before } from "@vendetta/patcher";

import { getChannel, getLazyActionSheet } from "../metro/stores";
import { getSettings } from "../settings/defaults";
import { openExportSheet } from "../ui/openExport";
import { createActionSheetRow } from "./actionSheetRow";
import { findMutableActionRows, hasActionLabel } from "./actionSheetUtils";

type Unpatch = () => void;

function getMessageLongPressSheet(): Record<string, unknown> | null {
    try {
        const byName = findByName("MessageLongPressActionSheet", false) as Record<string, unknown> | null;
        if (byName?.default) return byName;

        const byProps = findByProps("EmojiRow") as Record<string, unknown> | null;
        if (byProps?.default) return byProps;

        return find((module) => {
            if (!module || typeof module !== "object") return false;
            const candidate = module as Record<string, unknown>;
            return Boolean(candidate.default && (candidate.EmojiRow || candidate.ButtonRow));
        }) as Record<string, unknown> | null;
    } catch {
        return null;
    }
}

function injectExportFromHere(
    tree: unknown,
    message: { id?: string; channel_id?: string },
    hideSheet: () => void,
): unknown {
    if (!message.id || !message.channel_id) return tree;

    const buttons = findMutableActionRows(tree);
    if (!buttons || hasActionLabel(buttons, "Export from here")) return tree;

    const channel = getChannel(message.channel_id);
    if (!channel) return tree;

    try {
        const row = createActionSheetRow(buttons, "Export from here", () => {
            hideSheet();
            openExportSheet(channel, { fromMessageId: message.id });
        });
        if (row) buttons.push(row);
    } catch (error) {
        logger.warn("[ChannelExporter] Failed to inject message menu row", error);
    }

    return tree;
}

function patchDirectMessageSheet(): Unpatch {
    const sheet = getMessageLongPressSheet();
    const lazyActionSheet = getLazyActionSheet();
    if (!sheet?.default) {
        logger.warn("[ChannelExporter] MessageLongPressActionSheet module not found");
        return () => {};
    }

    const hideSheet = () => lazyActionSheet?.hideActionSheet?.();

    return after("default", sheet, ([props], tree) => {
        const message = (props as { message?: { id?: string; channel_id?: string } })?.message;
        if (!message) return tree;
        return injectExportFromHere(tree, message, hideSheet);
    });
}

function patchLazyMessageSheet(): Unpatch {
    const lazyActionSheet = getLazyActionSheet();
    if (!lazyActionSheet?.openLazy) return () => {};

    return before("openLazy", lazyActionSheet, ([component, key, context]) => {
        const message = (context as { message?: { id?: string; channel_id?: string } } | undefined)
            ?.message;
        if (typeof key === "string" && getSettings().debugMode) {
            logger.log(`[ChannelExporter] openLazy: ${key}`);
        }
        if (
            typeof key !== "string" ||
            !key.includes("MessageLongPress") ||
            !message?.id ||
            !message.channel_id
        ) {
            return;
        }

        component.then((instance: { default?: unknown }) => {
            if (!instance?.default || typeof instance.default !== "object") return;

            after("default", instance as Record<string, unknown>, ([props], tree) => {
                const msg = (props as { message?: { id?: string; channel_id?: string } })?.message ?? message;
                return injectExportFromHere(
                    tree,
                    msg,
                    () => lazyActionSheet.hideActionSheet?.(),
                );
            });
        });
    });
}

export function patchMessageSheet(): Unpatch {
    const unpatches = [patchDirectMessageSheet(), patchLazyMessageSheet()];
    return () => unpatches.forEach((unpatch) => unpatch());
}
