import { find, findByProps } from "@vendetta/metro";
import { after } from "@vendetta/patcher";

import type { RawChannel } from "../export/types";
import { getChannel, getLazyActionSheet } from "../metro/stores";
import { openExportSheet } from "../ui/openExport";

type Unpatch = () => void;

type SheetOption = { label?: string; onPress?: () => void };

function getSimpleActionSheet(): { showSimpleActionSheet?: (payload: unknown) => void } | null {
    try {
        const direct = find(
            (module) =>
                module?.showSimpleActionSheet &&
                !Object.getOwnPropertyDescriptor(module, "showSimpleActionSheet")?.get,
        ) as { showSimpleActionSheet?: (payload: unknown) => void } | null;

        if (direct?.showSimpleActionSheet) return direct;

        return findByProps("showSimpleActionSheet") as {
            showSimpleActionSheet?: (payload: unknown) => void;
        } | null;
    } catch {
        return null;
    }
}

function extractMessage(payload: Record<string, unknown>): { id?: string; channel_id?: string } | null {
    const direct = payload.message as { id?: string; channel_id?: string } | undefined;
    if (direct?.id && direct.channel_id) return direct;

    const context = payload.context as { message?: { id?: string; channel_id?: string } } | undefined;
    if (context?.message?.id && context.message.channel_id) return context.message;

    return null;
}

function extractChannel(payload: Record<string, unknown>): RawChannel | null {
    const direct = payload.channel as RawChannel | undefined;
    if (direct?.id) return direct;

    const context = payload.context as Record<string, unknown> | undefined;
    if (context) {
        const fromContext = extractChannel(context);
        if (fromContext) return fromContext;
    }

    const channelId = typeof payload.channelId === "string" ? payload.channelId : undefined;
    if (channelId) return getChannel(channelId);

    return null;
}

function pushOption(options: SheetOption[], label: string, onPress: () => void): void {
    if (options.some((option) => option.label === label)) return;
    options.push({ label, onPress });
}

export function patchSimpleActionSheets(): Unpatch {
    const simple = getSimpleActionSheet();
    if (!simple?.showSimpleActionSheet) return () => {};

    const hideSheet = () => getLazyActionSheet()?.hideActionSheet?.();

    return after("showSimpleActionSheet", simple, (args) => {
        const payload = args[0];
        if (!payload || typeof payload !== "object") return;

        const record = payload as Record<string, unknown>;
        const options = record.options as SheetOption[] | undefined;
        if (!Array.isArray(options)) return;

        const message = extractMessage(record);
        if (message?.id && message.channel_id) {
            const channel = getChannel(message.channel_id);
            if (!channel) return;

            pushOption(options, "Export from here", () => {
                hideSheet();
                openExportSheet(channel, { fromMessageId: message.id });
            });
            return;
        }

        const channel = extractChannel(record);
        if (!channel) return;

        pushOption(options, "Export messages", () => {
            hideSheet();
            openExportSheet(channel);
        });
    });
}
