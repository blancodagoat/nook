import { sanitizeFilename } from "./filename";
import { fetchChannelMessages } from "./fetchMessages";
import { serializeHtml } from "./formats/html";
import { serializeJson } from "./formats/json";
import { serializeTxt } from "./formats/txt";
import { normalizeChannel, normalizeMessages } from "./normalize";
import type { ExportFormat, ExportOptions, ExportPayload, RawChannel } from "./types";

export function buildFilename(
    template: string,
    channelName: string,
    guildName: string | undefined,
    format: ExportFormat,
): string {
    const date = new Date().toISOString().slice(0, 10);
    const base = template
        .replace("{channel}", sanitizeFilename(channelName))
        .replace("{guild}", sanitizeFilename(guildName ?? "dm"))
        .replace("{date}", date);

    return `${base}.${format}`;
}

export function serializePayload(payload: ExportPayload, format: ExportFormat): string {
    switch (format) {
        case "txt":
            return serializeTxt(payload);
        case "html":
            return serializeHtml(payload);
        default:
            return serializeJson(payload);
    }
}

export async function buildChannelExport(
    channel: RawChannel,
    options: ExportOptions,
    onProgress?: (count: number, partial: boolean) => void,
): Promise<{ content: string; payload: ExportPayload; filename: string }> {
    const { messages: rawMessages, partial } = await fetchChannelMessages(
        channel.id,
        options,
        (progress) => onProgress?.(progress.fetched, progress.partial),
    );

    const normalizedMessages = normalizeMessages(rawMessages, options);
    const exportChannel = normalizeChannel(channel);

    const payload: ExportPayload = {
        exportedAt: new Date().toISOString(),
        partial,
        channel: exportChannel,
        messageCount: normalizedMessages.length,
        messages: normalizedMessages,
        filters: {
            authorId: options.authorId,
            afterDate: options.afterDate?.toISOString(),
            beforeDate: options.beforeDate?.toISOString(),
            fromMessageId: options.fromMessageId,
        },
    };

    const content = serializePayload(payload, options.format);
    const filename = buildFilename(
        options.filenameTemplate,
        exportChannel.name,
        exportChannel.guildName,
        options.format,
    );

    return { content, payload, filename };
}
