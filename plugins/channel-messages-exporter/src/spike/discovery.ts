import { logger } from "@vendetta";
import { clipboard, ReactNative } from "@vendetta/metro/common";

import { extractCachedMessages } from "../export/messageUtils";
import {
    getChannel,
    getChannelStore,
    getGuildStore,
    getLazyActionSheet,
    getMessageFetcher,
    getMessageStore,
    getRestApi,
    getSelectedChannelId,
    getUserStore,
} from "../metro/stores";

export interface MessageCollectionProbe {
    channelId: string | null;
    collectionType: string;
    keys: string[];
    sampleMessageKeys: string[];
    messageCount: number | null;
    hasMore: boolean | null;
    error?: string;
}

export interface SpikeReport {
    ranAt: string;
    modules: Record<string, boolean>;
    messageProbe: MessageCollectionProbe;
    fetchCandidates: string[];
}

function probeMessageCollection(channelId: string | null): MessageCollectionProbe {
    if (!channelId) {
        return {
            channelId: null,
            collectionType: "unavailable",
            keys: [],
            sampleMessageKeys: [],
            messageCount: null,
            hasMore: null,
            error: "No selected channel id",
        };
    }

    const cached = extractCachedMessages(channelId);
    const firstMessage =
        cached.length > 0 && cached[0] && typeof cached[0] === "object"
            ? Object.keys(cached[0] as object).sort()
            : [];

    return {
        channelId,
        collectionType: cached.length > 0 ? "array-backed" : "empty",
        keys: cached.length > 0 ? ["cache"] : [],
        sampleMessageKeys: firstMessage,
        messageCount: cached.length,
        hasMore: null,
    };
}

export function runDiscovery(): SpikeReport {
    const fetcher = getMessageFetcher();
    const modules = {
        messageStore: Boolean(getMessageStore()),
        channelStore: Boolean(getChannelStore()),
        userStore: Boolean(getUserStore()),
        guildStore: Boolean(getGuildStore()),
        restApi: Boolean(getRestApi()),
        messageFetcher: Boolean(fetcher),
        lazyActionSheet: Boolean(getLazyActionSheet()),
        reactNativeShare: Boolean(ReactNative?.Share?.share),
        clipboard: Boolean(clipboard?.setString),
    };

    const channelId = getSelectedChannelId();
    const channel = channelId ? getChannel(channelId) : null;
    const fetchCandidates = fetcher ? Object.keys(fetcher).filter((key) => /fetch|load|get/i.test(key)) : [];

    const report: SpikeReport = {
        ranAt: new Date().toISOString(),
        modules,
        messageProbe: probeMessageCollection(channelId),
        fetchCandidates,
    };

    logger.log("[ChannelExporter] Discovery complete");
    logger.log(`[ChannelExporter] Channel: ${channel?.name ?? "unknown"} (${channelId ?? "none"})`);
    logger.log(`[ChannelExporter] Cached messages: ${report.messageProbe.messageCount ?? "?"}`);
    logger.log(`[ChannelExporter] Fetch candidates: ${fetchCandidates.join(", ") || "none"}`);

    for (const [name, found] of Object.entries(modules)) {
        if (!found) logger.warn(`[ChannelExporter] Missing module: ${name}`);
    }

    return report;
}
