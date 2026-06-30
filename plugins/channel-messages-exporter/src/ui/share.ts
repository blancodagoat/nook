import { logger } from "@vendetta";
import { clipboard, ReactNative } from "@vendetta/metro/common";

import type { ExportPayload } from "../export/types";

export function buildSpikePayload(channelName = "spike-test"): ExportPayload {
    return {
        exportedAt: new Date().toISOString(),
        channel: {
            id: "phase0",
            name: channelName,
            type: 0,
        },
        messageCount: 2,
        messages: [
            {
                id: "1",
                channelId: "phase0",
                author: { id: "0", username: "phase0-bot", displayName: "Phase 0" },
                content: "Share spike message one",
                timestamp: new Date().toISOString(),
                type: 0,
            },
            {
                id: "2",
                channelId: "phase0",
                author: { id: "0", username: "phase0-bot", displayName: "Phase 0" },
                content: "Share spike message two",
                timestamp: new Date().toISOString(),
                type: 0,
            },
        ],
    };
}

export async function runShareSpike(channelName?: string): Promise<string> {
    const payload = buildSpikePayload(channelName);
    const json = JSON.stringify(payload, null, 2);

    if (ReactNative?.Share?.share) {
        await ReactNative.Share.share({
            title: "Channel export spike",
            message: json,
        });
        logger.log("[ChannelExporter] Share spike opened native share sheet");
        return "Shared via ReactNative.Share";
    }

    if (clipboard?.setString) {
        clipboard.setString(json);
        logger.log("[ChannelExporter] Share spike copied JSON to clipboard");
        return "Copied JSON to clipboard (Share API unavailable)";
    }

    logger.warn("[ChannelExporter] Share spike failed: no Share or clipboard API");
    throw new Error("Neither Share nor clipboard is available on this build");
}
