import { React, ReactNative } from "@vendetta/metro/common";
import { showInputAlert } from "@vendetta/ui/alerts";
import { showToast } from "@vendetta/ui/toasts";

import type { ExportFormat } from "./export/types";
import { buildChannelExport } from "./export/buildExport";
import { buildExportOptions } from "./export/options";
import {
    getChannel,
    getSelectedChannelId,
    resolveChannelLabel,
} from "./metro/stores";
import { PLUGIN_BUILD } from "./buildInfo";
import { disableMenuPatches, enableMenuPatches } from "./patches/registry";
import { runDiscovery } from "./spike/discovery";
import {
    DEFAULT_SETTINGS,
    getSettings,
    updateSettings,
    type PluginSettings,
} from "./settings/defaults";
import { shareExportWithToast } from "./ui/share";

const { View, Text, Pressable } = ReactNative;

const FORMATS: ExportFormat[] = ["json", "txt", "html"];

const styles = ReactNative.StyleSheet.create({
    root: { padding: 16, gap: 8 },
    section: { marginTop: 12, gap: 6 },
    sectionTitle: { fontSize: 13, fontWeight: "600", opacity: 0.7, marginBottom: 4 },
    row: { paddingVertical: 12, paddingHorizontal: 4 },
    rowLabel: { fontSize: 16 },
    rowSub: { fontSize: 13, opacity: 0.65, marginTop: 2 },
    status: { fontSize: 13, opacity: 0.8, marginTop: 8 },
});

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

function SettingsRow(props: {
    label: string;
    sublabel?: string;
    onPress: () => void;
}): React.ReactElement {
    return React.createElement(
        Pressable,
        { onPress: props.onPress, style: styles.row },
        React.createElement(Text, { style: styles.rowLabel }, props.label),
        props.sublabel
            ? React.createElement(Text, { style: styles.rowSub }, props.sublabel)
            : null,
    );
}

function SettingsSection(props: {
    title: string;
    children: React.ReactNode;
}): React.ReactElement {
    return React.createElement(
        View,
        { style: styles.section },
        React.createElement(Text, { style: styles.sectionTitle }, props.title),
        props.children,
    );
}

export const Settings = () => {
    const [settings, setSettings] = React.useState(getSettings());
    const [status, setStatus] = React.useState("");

    const refresh = () => setSettings(getSettings());

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
            setStatus("Exporting...");
            const { content, filename } = await buildChannelExport(
                { ...channel, name: resolveChannelLabel(channel) },
                buildExportOptions(),
            );
            await shareExportWithToast(content, filename);
            setStatus(`Exported ${filename}`);
        } catch (error) {
            const message = error instanceof Error ? error.message : String(error);
            setStatus(message);
            showToast("Export failed");
        }
    };

    return React.createElement(
        View,
        { style: styles.root },
        React.createElement(Text, { style: styles.status }, `Build ${PLUGIN_BUILD}`),
        SettingsSection({
            title: "Export",
            children: [
                SettingsRow({
                    label: "Quick export",
                    sublabel: "Export current channel with saved defaults",
                    onPress: quickExportCurrent,
                }),
                status ? React.createElement(Text, { style: styles.status }, status) : null,
            ],
        }),
        SettingsSection({
            title: "Defaults",
            children: [
                SettingsRow({
                    label: "Default format",
                    sublabel: settings.defaultFormat.toUpperCase(),
                    onPress: () => {
                        updateSettings({ defaultFormat: cycleFormat(settings.defaultFormat) });
                        refresh();
                    },
                }),
                SettingsRow({
                    label: "Max messages",
                    sublabel: String(settings.maxMessages),
                    onPress: () => {
                        showInputAlert({
                            title: "Max messages (0 = unlimited)",
                            initialValue: String(settings.maxMessages),
                            confirmText: "Save",
                            onConfirm: (value) => {
                                const parsed = Number.parseInt(value, 10);
                                updateSettings({
                                    maxMessages: Number.isFinite(parsed)
                                        ? parsed
                                        : DEFAULT_SETTINGS.maxMessages,
                                });
                                refresh();
                            },
                        });
                    },
                }),
                SettingsRow({
                    label: "Include embeds",
                    sublabel: settings.includeEmbeds ? "On" : "Off",
                    onPress: () => {
                        toggle("includeEmbeds");
                        refresh();
                    },
                }),
                SettingsRow({
                    label: "Include attachments",
                    sublabel: settings.includeAttachments ? "On" : "Off",
                    onPress: () => {
                        toggle("includeAttachments");
                        refresh();
                    },
                }),
            ],
        }),
        SettingsSection({
            title: "Advanced",
            children: [
                SettingsRow({
                    label: "Menu shortcuts (experimental)",
                    sublabel: settings.menuPatches
                        ? "On — long-press / channel menus"
                        : "Off — safest mode",
                    onPress: () => {
                        const next = !settings.menuPatches;
                        updateSettings({ menuPatches: next });
                        if (next) {
                            enableMenuPatches();
                            showToast("Menu patches enabled");
                        } else {
                            disableMenuPatches();
                            showToast("Menu patches disabled");
                        }
                        refresh();
                    },
                }),
                SettingsRow({
                    label: "Debug mode",
                    sublabel: settings.debugMode ? "On" : "Off",
                    onPress: () => {
                        toggle("debugMode");
                        refresh();
                    },
                }),
                settings.debugMode
                    ? SettingsRow({
                          label: "Run metro discovery",
                          sublabel: "Logs Discord internals",
                          onPress: () => {
                              runDiscovery();
                              showToast("Discovery logged to console");
                          },
                      })
                    : null,
            ],
        }),
    );
};
