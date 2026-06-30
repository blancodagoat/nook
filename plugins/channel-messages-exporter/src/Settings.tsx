import { useState } from "react";

import { logger } from "@vendetta";
import { Forms } from "@vendetta/ui/components";
import { showToast } from "@vendetta/ui/toasts";

import { runDiscovery, type SpikeReport } from "./spike/discovery";
import { runShareSpike } from "./ui/share";

const { FormSection, FormRow, FormText, FormDivider } = Forms;

function formatModuleLine(name: string, status: SpikeReport["modules"][string]): string {
    if (!status.found) return `${name}: missing`;
    return `${name}: ok (${status.keys.length} keys)`;
}

export const Settings = () => {
    const [report, setReport] = useState<SpikeReport | null>(null);
    const [statusText, setStatusText] = useState("Phase 0 spike tools ready.");

    const handleDiscovery = () => {
        try {
            const nextReport = runDiscovery();
            setReport(nextReport);
            setStatusText(`Discovery ran at ${nextReport.ranAt}`);
            showToast("Metro discovery complete — check console for details");
        } catch (error) {
            const message = error instanceof Error ? error.message : String(error);
            logger.error(`[ChannelExporter] Discovery failed: ${message}`);
            setStatusText(`Discovery failed: ${message}`);
            showToast("Discovery failed");
        }
    };

    const handleShareSpike = async () => {
        try {
            const result = await runShareSpike();
            setStatusText(result);
            showToast(result);
        } catch (error) {
            const message = error instanceof Error ? error.message : String(error);
            logger.error(`[ChannelExporter] Share spike failed: ${message}`);
            setStatusText(`Share spike failed: ${message}`);
            showToast("Share spike failed");
        }
    };

    return (
        <>
            <FormSection title="Phase 0 Spike">
                <FormText>
                    Run these while viewing a channel in Discord. Results are logged to the
                    Vendetta console and summarized below.
                </FormText>
                <FormDivider />
                <FormRow
                    label="Run metro discovery"
                    sublabel="Probe MessageStore, ChannelStore, fetch APIs"
                    onPress={handleDiscovery}
                />
                <FormRow
                    label="Test share export"
                    sublabel="Share a hardcoded JSON payload"
                    onPress={handleShareSpike}
                />
                <FormDivider />
                <FormText>{statusText}</FormText>
            </FormSection>

            {report && (
                <FormSection title="Last discovery report">
                    <FormText>
                        Channel: {report.messageProbe.channelId ?? "none"}
                    </FormText>
                    <FormText>
                        Cached messages: {report.messageProbe.messageCount ?? "unknown"}
                    </FormText>
                    <FormText>
                        hasMore: {String(report.messageProbe.hasMore)}
                    </FormText>
                    <FormText>
                        Collection keys: {report.messageProbe.keys.join(", ") || "none"}
                    </FormText>
                    <FormText>
                        Sample message keys:{" "}
                        {report.messageProbe.sampleMessageKeys.join(", ") || "none"}
                    </FormText>
                    <FormText>
                        Fetch candidates: {report.fetchCandidates.join(", ") || "none"}
                    </FormText>
                    <FormDivider />
                    {Object.entries(report.modules).map(([name, status]) => (
                        <FormText key={name}>{formatModuleLine(name, status)}</FormText>
                    ))}
                </FormSection>
            )}
        </>
    );
};
