import { getSettings } from "../settings/defaults";
import type { ExportOptions } from "./types";

export function buildExportOptions(overrides?: Partial<ExportOptions>): ExportOptions {
    const settings = getSettings();

    return {
        format: overrides?.format ?? settings.defaultFormat,
        maxMessages: overrides?.maxMessages ?? settings.maxMessages,
        includeEmbeds: overrides?.includeEmbeds ?? settings.includeEmbeds,
        includeAttachments: overrides?.includeAttachments ?? settings.includeAttachments,
        includeReactions: overrides?.includeReactions ?? settings.includeReactions,
        includeAvatars: overrides?.includeAvatars ?? settings.includeAvatars,
        filenameTemplate: overrides?.filenameTemplate ?? settings.filenameTemplate,
        fetchDelayMs: overrides?.fetchDelayMs ?? settings.fetchDelayMs,
        authorId: overrides?.authorId ?? (settings.filterAuthorId || undefined),
        afterDate: overrides?.afterDate ?? parseDate(settings.filterAfterDate),
        beforeDate: overrides?.beforeDate ?? parseDate(settings.filterBeforeDate),
        fromMessageId: overrides?.fromMessageId,
    };
}

function parseDate(value: string): Date | undefined {
    if (!value) return undefined;
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? undefined : date;
}
