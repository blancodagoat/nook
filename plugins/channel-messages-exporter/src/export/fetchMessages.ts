import {
    getMessageFetcher,
    getMessageStore,
    getRestApi,
} from "../metro/stores";
import {
    applyMessageFilters,
    extractCachedMessages,
    getMessageId,
    getMessageTimestamp,
    sleep,
} from "./messageUtils";
import type { ExportOptions, FetchProgressCallback } from "./types";

let activeCancelToken: { cancelled: boolean } | null = null;

export function cancelActiveFetch(): void {
    if (activeCancelToken) activeCancelToken.cancelled = true;
}

async function fetchViaRest(
    channelId: string,
    options: ExportOptions,
    byId: Map<string, unknown>,
    onProgress?: FetchProgressCallback,
): Promise<boolean> {
    const rest = getRestApi();
    if (!rest?.get) return false;

    const max = options.maxMessages > 0 ? options.maxMessages : Number.POSITIVE_INFINITY;
    let before = getOldestMessageId(byId);
    let hadSuccess = false;

    while (byId.size < max && !activeCancelToken?.cancelled) {
        const query: Record<string, string | number> = { limit: 100 };
        if (before) query.before = before;

        const response = await rest
            .get({
                url: `/channels/${channelId}/messages`,
                query,
                retries: 1,
            })
            .catch(() => null);

        const batch = Array.isArray(response?.body) ? response.body : [];
        if (batch.length === 0) break;

        hadSuccess = true;
        for (const message of batch) {
            const id = getMessageId(message);
            if (id) byId.set(id, message);
        }

        before = getMessageId(batch[batch.length - 1]) ?? before;
        onProgress?.({ fetched: byId.size, partial: false, done: false });

        if (batch.length < 100) break;
        await sleep(options.fetchDelayMs);
    }

    return hadSuccess;
}

async function fetchViaInternalApi(
    channelId: string,
    options: ExportOptions,
    byId: Map<string, unknown>,
    onProgress?: FetchProgressCallback,
): Promise<boolean> {
    const fetcher = getMessageFetcher();
    if (!fetcher) return false;

    const max = options.maxMessages > 0 ? options.maxMessages : Number.POSITIVE_INFINITY;
    const fetchMessages = fetcher.fetchMessages ?? fetcher.loadMessages;
    if (typeof fetchMessages !== "function") return false;

    let before = getOldestMessageId(byId);
    let hadSuccess = false;

    while (byId.size < max && !activeCancelToken?.cancelled) {
        try {
            const result = await (fetchMessages as (args: Record<string, unknown>) => Promise<unknown>)({
                channelId,
                before,
                limit: 100,
            });

            const batch = extractBatch(result);
            if (batch.length === 0) break;

            hadSuccess = true;
            for (const message of batch) {
                const id = getMessageId(message);
                if (id) byId.set(id, message);
            }

            before = getMessageId(batch[batch.length - 1]) ?? before;
            onProgress?.({ fetched: byId.size, partial: false, done: false });

            if (batch.length < 100) break;
            await sleep(options.fetchDelayMs);
        } catch {
            break;
        }
    }

    return hadSuccess;
}

function extractBatch(result: unknown): unknown[] {
    if (Array.isArray(result)) return result;
    if (!result || typeof result !== "object") return [];

    const record = result as Record<string, unknown>;
    if (Array.isArray(record.messages)) return record.messages;
    if (Array.isArray(record.body)) return record.body;
    return [];
}

function getOldestMessageId(messages: Map<string, unknown>): string | undefined {
    let oldest: { id: string; time: number } | null = null;

    for (const message of messages.values()) {
        const id = getMessageId(message);
        if (!id) continue;
        const time = getMessageTimestamp(message);
        if (!oldest || time < oldest.time) oldest = { id, time };
    }

    return oldest?.id;
}

function ingestStoreMessages(channelId: string, byId: Map<string, unknown>): void {
    const store = getMessageStore();
    if (!store?.getMessages || typeof store.getMessages !== "function") return;

    try {
        const collection = (store.getMessages as (id: string) => unknown)(channelId);
        if (!collection || typeof collection !== "object") return;

        const record = collection as Record<string, unknown>;
        const receive = record.receive;
        if (typeof receive === "function") {
            for (const message of byId.values()) {
                (receive as (msg: unknown) => void).call(record, message);
            }
        }
    } catch {
        // optional enrichment only
    }
}

export async function fetchChannelMessages(
    channelId: string,
    options: ExportOptions,
    onProgress?: FetchProgressCallback,
): Promise<{ messages: unknown[]; partial: boolean }> {
    activeCancelToken = { cancelled: false };
    const byId = new Map<string, unknown>();

    for (const message of extractCachedMessages(channelId)) {
        const id = getMessageId(message);
        if (id) byId.set(id, message);
    }

    onProgress?.({ fetched: byId.size, partial: false, done: false });

    const restWorked = await fetchViaRest(channelId, options, byId, onProgress);
    const internalWorked =
        !restWorked && !activeCancelToken?.cancelled
            ? await fetchViaInternalApi(channelId, options, byId, onProgress)
            : false;

    ingestStoreMessages(channelId, byId);

    const partial = !restWorked && !internalWorked && byId.size > 0;
    const filtered = applyMessageFilters(Array.from(byId.values()), options);

    onProgress?.({
        fetched: filtered.length,
        partial,
        done: true,
    });

    activeCancelToken = null;
    return { messages: filtered, partial };
}
