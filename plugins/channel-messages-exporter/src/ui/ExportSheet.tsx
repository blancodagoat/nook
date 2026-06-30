import { React } from "@vendetta/metro/common";
import { showToast } from "@vendetta/ui/toasts";

import { buildChannelExport } from "../export/buildExport";
import { buildExportOptions } from "../export/options";
import type { ExportFormat, ExportOptions, RawChannel } from "../export/types";
import { cancelActiveFetch } from "../export/fetchMessages";
import { getLazyActionSheet } from "../metro/stores";
import { getSettings } from "../settings/defaults";
import { shareExportWithToast } from "./share";
import { getDiscordForms } from "./discordForms";

const FORMATS: ExportFormat[] = ["json", "txt", "html"];

interface ExportSheetProps {
    channel: RawChannel;
    overrides?: Partial<ExportOptions>;
}

function closeSheet(): void {
    getLazyActionSheet()?.hideActionSheet?.();
}

export default function ExportSheet({ channel, overrides }: ExportSheetProps) {
    const forms = getDiscordForms();
    const settings = getSettings();
    const [format, setFormat] = React.useState<ExportFormat>(
        overrides?.format ?? settings.defaultFormat,
    );
    const [busy, setBusy] = React.useState(false);
    const [progress, setProgress] = React.useState("Ready to export.");
    const [partial, setPartial] = React.useState(false);

    const options = React.useMemo<ExportOptions>(
        () => buildExportOptions({ ...overrides, format }),
        [format, overrides],
    );

    React.useEffect(() => {
        if (!forms) {
            showToast("Export sheet UI unavailable");
            closeSheet();
        }
    }, [forms]);

    const cycleFormat = () => {
        const index = FORMATS.indexOf(format);
        setFormat(FORMATS[(index + 1) % FORMATS.length]);
    };

    const runExport = async () => {
        if (busy) return;
        setBusy(true);
        setProgress("Fetching messages...");

        try {
            const { content, filename, payload } = await buildChannelExport(
                channel,
                options,
                (count, isPartial) => {
                    setPartial(isPartial);
                    setProgress(`Fetched ${count} messages...`);
                },
            );

            setProgress(`Exporting ${payload.messageCount} messages...`);
            await shareExportWithToast(content, filename);
            setProgress(
                payload.partial
                    ? `Shared partial export (${payload.messageCount} messages).`
                    : `Shared ${payload.messageCount} messages.`,
            );
            closeSheet();
        } catch (error) {
            const message = error instanceof Error ? error.message : String(error);
            setProgress(`Export failed: ${message}`);
            showToast("Export failed");
        } finally {
            setBusy(false);
        }
    };

    if (!forms) return null;

    const { FormSection, FormRow, FormText } = forms;
    const FormDivider = forms.FormDivider ?? (() => null);

    return (
        <FormSection title="Export messages">
            <FormText>
                {channel.name ?? channel.id}
                {partial ? " · partial export likely" : ""}
            </FormText>
            <FormDivider />
            <FormRow
                label="Format"
                sublabel={format.toUpperCase()}
                onPress={cycleFormat}
            />
            <FormRow
                label="Max messages"
                sublabel={String(options.maxMessages > 0 ? options.maxMessages : "unlimited")}
            />
            {options.fromMessageId && (
                <FormText>Exporting history up to selected message.</FormText>
            )}
            {options.authorId && <FormText>Filtering by author: {options.authorId}</FormText>}
            <FormDivider />
            <FormText>{progress}</FormText>
            <FormRow
                label={busy ? "Exporting..." : "Export"}
                sublabel="Fetch messages and open share sheet"
                onPress={runExport}
            />
            {busy && (
                <FormRow
                    label="Cancel"
                    sublabel="Stop fetching messages"
                    onPress={() => {
                        cancelActiveFetch();
                        setProgress("Cancelling...");
                    }}
                />
            )}
            <FormRow label="Close" onPress={closeSheet} />
        </FormSection>
    );
}
