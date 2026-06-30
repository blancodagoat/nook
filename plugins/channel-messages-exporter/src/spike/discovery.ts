import { logger } from "@vendetta";
import { clipboard, ReactNative } from "@vendetta/metro/common";

import {
    getChannelStore,
    getMessageStore,
    getSelectedChannelId,
    metroModules,
    type MetroModuleStatus,
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
    modules: Record<string, MetroModuleStatus>;
    messageProbe: MessageCollectionProbe;
    fetchCandidates: string[];
}

function describeValue(value: unknown): string {
    if (value === null) return "null";
    if (Array.isArray(value)) return `array(${value.length})`;
    return typeof value;
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

    const messageStore = getMessageStore();
    if (!messageStore?.getMessages || typeof messageStore.getMessages !== "function") {
        return {
            channelId,
            collectionType: "unavailable",
            keys: messageStore ? Object.keys(messageStore) : [],
            sampleMessageKeys: [],
            messageCount: null,
            hasMore: null,
            error: "MessageStore.getMessages unavailable",
        };
    }

    try {
        const collection = (messageStore.getMessages as (id: string) => unknown)(channelId);
        if (!collection || typeof collection !== "object") {
            return {
                channelId,
                collectionType: describeValue(collection),
                keys: [],
                sampleMessageKeys: [],
                messageCount: null,
                hasMore: null,
                error: `getMessages returned ${describeValue(collection)}`,
            };
        }

        const record = collection as Record<string, unknown>;
        const keys = Object.keys(record).sort();

        const arrayCandidate =
            (Array.isArray(record._array) && record._array) ||
            (Array.isArray(record.messages) && record.messages) ||
            (Array.isArray(record) && record) ||
            null;

        const firstMessage =
            arrayCandidate && arrayCandidate.length > 0
                ? (arrayCandidate[0] as Record<string, unknown>)
                : null;

        const hasMore =
            typeof record.hasMoreBefore === "boolean"
                ? record.hasMoreBefore
                : typeof record.hasMore === "boolean"
                  ? record.hasMore
                  : null;

        return {
            channelId,
            collectionType: arrayCandidate ? "array-backed" : "object",
            keys,
            sampleMessageKeys: firstMessage ? Object.keys(firstMessage).sort() : [],
            messageCount: arrayCandidate ? arrayCandidate.length : null,
            hasMore,
        };
    } catch (error) {
        return {
            channelId,
            collectionType: "error",
            keys: [],
            sampleMessageKeys: [],
            messageCount: null,
            hasMore: null,
            error: error instanceof Error ? error.message : String(error),
        };
    }
}

function probeFetchCandidates(): string[] {
    const fetcher = metroModules.messageFetcher();
    if (!fetcher.found) return [];

    return fetcher.keys.filter((key) => /fetch|load|get/i.test(key));
}

function probeShareApis(): Record<string, MetroModuleStatus> {
    return {
        reactNativeShare: {
            found: Boolean(ReactNative?.Share?.share),
            keys: ReactNative?.Share ? Object.keys(ReactNative.Share).sort() : [],
        },
        clipboard: {
            found: Boolean(clipboard?.setString),
            keys: clipboard ? Object.keys(clipboard as object).sort() : [],
        },
    };
}

export function runDiscovery(): SpikeReport {
    const modules = {
        messageStore: metroModules.messageStore(),
        channelStore: metroModules.channelStore(),
        userStore: metroModules.userStore(),
        guildStore: metroModules.guildStore(),
        selectedChannel: metroModules.selectedChannel(),
        messageFetcher: metroModules.messageFetcher(),
        lazyActionSheet: metroModules.lazyActionSheet(),
        channelsCommon: metroModules.channelsCommon(),
        ...probeShareApis(),
    };

    const channelId = getSelectedChannelId();
    const channelStore = getChannelStore();
    const channel =
        channelId && channelStore?.getChannel
            ? (channelStore.getChannel as (id: string) => { name?: string } | null)(channelId)
            : null;

    const report: SpikeReport = {
        ranAt: new Date().toISOString(),
        modules,
        messageProbe: probeMessageCollection(channelId),
        fetchCandidates: probeFetchCandidates(),
    };

    logger.log("[ChannelExporter] Phase 0 discovery complete");
    logger.log(`[ChannelExporter] Channel: ${channel?.name ?? "unknown"} (${channelId ?? "none"})`);
    logger.log(`[ChannelExporter] Cached messages: ${report.messageProbe.messageCount ?? "?"}`);
    logger.log(`[ChannelExporter] Fetch candidates: ${report.fetchCandidates.join(", ") || "none"}`);

    for (const [name, status] of Object.entries(modules)) {
        if (!status.found) {
            logger.warn(`[ChannelExporter] Missing module ${name}: ${status.error ?? "not found"}`);
        }
    }

    return report;
}
