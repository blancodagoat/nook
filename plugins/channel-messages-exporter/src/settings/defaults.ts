import { storage } from "@vendetta/plugin";

import type { ExportFormat } from "../export/types";

export interface PluginSettings {
    defaultFormat: ExportFormat;
    maxMessages: number;
    includeEmbeds: boolean;
    includeAttachments: boolean;
    includeReactions: boolean;
    includeAvatars: boolean;
    filenameTemplate: string;
    fetchDelayMs: number;
    filterAuthorId: string;
    filterAfterDate: string;
    filterBeforeDate: string;
    debugMode: boolean;
    menuPatches: boolean;
}

export const DEFAULT_SETTINGS: PluginSettings = {
    defaultFormat: "json",
    maxMessages: 5000,
    includeEmbeds: true,
    includeAttachments: true,
    includeReactions: false,
    includeAvatars: false,
    filenameTemplate: "{channel}-{date}",
    fetchDelayMs: 400,
    filterAuthorId: "",
    filterAfterDate: "",
    filterBeforeDate: "",
    debugMode: false,
    menuPatches: false,
};

export function getSettings(): PluginSettings {
    return { ...DEFAULT_SETTINGS, ...(storage as Partial<PluginSettings>) };
}

export function updateSettings(patch: Partial<PluginSettings>): void {
    Object.assign(storage, patch);
}
