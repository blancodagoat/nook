import { logger } from "@vendetta";

import type { ExportPayload } from "../export/types";

function getReactNativeShare(): {
    share: (content: { message?: string; title?: string; url?: string }) => Promise<unknown>;
} | null {
    try {
        // eslint-disable-next-line @typescript-eslint/no-require-imports
        const { ReactNative } = require("@vendetta/metro/common") as {
            ReactNative?: {
                Share?: {
                    share: (content: {
                        message?: string;
                        title?: string;
                        url?: string;
                    }) => Promise<unknown>;
                };
            };
        };

        return ReactNative?.Share ?? null;
    } catch (error) {
        logger.warn(`[ChannelExporter] Share module unavailable: ${error}`);
        return null;
    }
}

function getClipboard(): { setString: (value: string) => void } | null {
    try {
        // eslint-disable-next-line @typescript-eslint/no-require-imports
        const { ReactNative } = require("@vendetta/metro/common") as {
            ReactNative?: {
                Clipboard?: { setString: (value: string) => void };
            };
        };

        return ReactNative?.Clipboard ?? null;
    } catch {
        return null;
    }
}

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
    const share = getReactNativeShare();

    if (share?.share) {
        await share.share({
            title: "Channel export spike",
            message: json,
        });
        logger.log("[ChannelExporter] Share spike opened native share sheet");
        return "Shared via native Share API";
    }

    const clipboard = getClipboard();
    if (clipboard?.setString) {
        clipboard.setString(json);
        logger.log("[ChannelExporter] Share spike copied JSON to clipboard");
        return "Copied JSON to clipboard (Share API unavailable)";
    }

    logger.warn("[ChannelExporter] Share spike failed: no Share or Clipboard API");
    throw new Error("Neither Share nor Clipboard is available on this build");
}
