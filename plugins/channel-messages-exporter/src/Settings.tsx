import { useState } from "react";

import { Forms } from "@vendetta/ui/components";
import { showInputAlert } from "@vendetta/ui/alerts";
import { showToast } from "@vendetta/ui/toasts";

import type { ExportFormat } from "./export/types";
import {
    getChannel,
    getSelectedChannelId,
    resolveChannelLabel,
} from "./metro/stores";
import { runDiscovery } from "./spike/discovery";
import {
    DEFAULT_SETTINGS,
    getSettings,
    updateSettings,
    type PluginSettings,
} from "./settings/defaults";
import { openExportSheet } from "./ui/openExport";
import { shareExportWithToast } from "./ui/share";
import { buildChannelExport } from "./export/buildExport";
import { buildExportOptions } from "./export/options";

const { FormSection, FormRow, FormText, FormDivider } = Forms;

const FORMATS: ExportFormat[] = ["json", "txt", "html"];

function cycleFormat(current: ExportFormat): ExportFormat {
    const index = FORMATS.indexOf(current);
    return FORMATS[(index + 1) % FORMATS.length];
}

function toggle(key: keyof PluginSettings): void {
    const settings = getSettings();
    const value = settings[key];
    if (typeof value === "boolean") {
        updateSettings({ [key]: !value } as Partial<PluginSettings>);
    }
}

export const Settings = () => {
    const [settings, setSettings] = useState(getSettings());
    const [status, setStatus] = useState("");

    const refresh = () => setSettings(getSettings());

    const exportCurrentChannel = () => {
        const channelId = getSelectedChannelId();
        if (!channelId) {
            showToast("Open a channel first");
            return;
        }

        const channel = getChannel(channelId);
        if (!channel) {
            showToast("Could not resolve current channel");
            return;
        }

        openExportSheet({ ...channel, name: resolveChannelLabel(channel) });
    };

    const quickExportCurrent = async () => {
        const channelId = getSelectedChannelId();
        if (!channelId) {
            showToast("Open a channel first");
            return;
        }

        const channel = getChannel(channelId);
        if (!channel) {
            showToast("Could not resolve current channel");
            return;
        }

        try {
            setStatus("Exporting current channel...");
            const current = getSettings();
            const { content, filename } = await buildChannelExport(channel, buildExportOptions());
            await shareExportWithToast(content, filename);
            setStatus(`Exported ${filename}`);
        } catch (error) {
            const message = error instanceof Error ? error.message : String(error);
            setStatus(message);
            showToast("Export failed");
        }
    };

    return (
        <>
            <FormSection title="Export">
                <FormRow
                    label="Export current channel"
                    sublabel="Open export sheet for the active channel"
                    onPress={exportCurrentChannel}
                />
                <FormRow
                    label="Quick export"
                    sublabel="Export with saved defaults immediately"
                    onPress={quickExportCurrent}
                />
                {status ? <FormText>{status}</FormText> : null}
            </FormSection>

            <FormSection title="Defaults">
                <FormRow
                    label="Default format"
                    sublabel={settings.defaultFormat.toUpperCase()}
                    onPress={() => {
                        updateSettings({ defaultFormat: cycleFormat(settings.defaultFormat) });
                        refresh();
                    }}
                />
                <FormRow
                    label="Max messages"
                    sublabel={String(settings.maxMessages)}
                    onPress={() => {
                        showInputAlert({
                            title: "Max messages (0 = unlimited)",
                            initialValue: String(settings.maxMessages),
                            confirmText: "Save",
                            onConfirm: (value) => {
                                const parsed = Number.parseInt(value, 10);
                                updateSettings({
                                    maxMessages: Number.isFinite(parsed) ? parsed : DEFAULT_SETTINGS.maxMessages,
                                });
                                refresh();
                            },
                        });
                    }}
                />
                <FormRow
                    label="Include embeds"
                    sublabel={settings.includeEmbeds ? "On" : "Off"}
                    onPress={() => {
                        toggle("includeEmbeds");
                        refresh();
                    }}
                />
                <FormRow
                    label="Include attachments"
                    sublabel={settings.includeAttachments ? "On" : "Off"}
                    onPress={() => {
                        toggle("includeAttachments");
                        refresh();
                    }}
                />
                <FormRow
                    label="Include reactions"
                    sublabel={settings.includeReactions ? "On" : "Off"}
                    onPress={() => {
                        toggle("includeReactions");
                        refresh();
                    }}
                />
                <FormRow
                    label="Include avatars"
                    sublabel={settings.includeAvatars ? "On" : "Off"}
                    onPress={() => {
                        toggle("includeAvatars");
                        refresh();
                    }}
                />
                <FormRow
                    label="Filename template"
                    sublabel={settings.filenameTemplate}
                    onPress={() => {
                        showInputAlert({
                            title: "Filename template ({channel} {guild} {date})",
                            initialValue: settings.filenameTemplate,
                            confirmText: "Save",
                            onConfirm: (value) => {
                                updateSettings({ filenameTemplate: value || DEFAULT_SETTINGS.filenameTemplate });
                                refresh();
                            },
                        });
                    }}
                />
                <FormRow
                    label="Fetch delay (ms)"
                    sublabel={String(settings.fetchDelayMs)}
                    onPress={() => {
                        showInputAlert({
                            title: "Fetch delay in ms",
                            initialValue: String(settings.fetchDelayMs),
                            confirmText: "Save",
                            onConfirm: (value) => {
                                const parsed = Number.parseInt(value, 10);
                                updateSettings({
                                    fetchDelayMs: Number.isFinite(parsed)
                                        ? parsed
                                        : DEFAULT_SETTINGS.fetchDelayMs,
                                });
                                refresh();
                            },
                        });
                    }}
                />
            </FormSection>

            <FormSection title="Filters">
                <FormRow
                    label="Author ID filter"
                    sublabel={settings.filterAuthorId || "None"}
                    onPress={() => {
                        showInputAlert({
                            title: "Author user ID (blank = all)",
                            initialValue: settings.filterAuthorId,
                            confirmText: "Save",
                            onConfirm: (value) => {
                                updateSettings({ filterAuthorId: value.trim() });
                                refresh();
                            },
                        });
                    }}
                />
                <FormRow
                    label="After date (ISO)"
                    sublabel={settings.filterAfterDate || "None"}
                    onPress={() => {
                        showInputAlert({
                            title: "After date e.g. 2026-01-01",
                            initialValue: settings.filterAfterDate,
                            confirmText: "Save",
                            onConfirm: (value) => {
                                updateSettings({ filterAfterDate: value.trim() });
                                refresh();
                            },
                        });
                    }}
                />
                <FormRow
                    label="Before date (ISO)"
                    sublabel={settings.filterBeforeDate || "None"}
                    onPress={() => {
                        showInputAlert({
                            title: "Before date e.g. 2026-12-31",
                            initialValue: settings.filterBeforeDate,
                            confirmText: "Save",
                            onConfirm: (value) => {
                                updateSettings({ filterBeforeDate: value.trim() });
                                refresh();
                            },
                        });
                    }}
                />
            </FormSection>

            <FormSection title="Debug">
                <FormRow
                    label="Run metro discovery"
                    sublabel="Log Discord internals to console"
                    onPress={() => {
                        runDiscovery();
                        showToast("Discovery logged to console");
                    }}
                />
            </FormSection>
        </>
    );
};
