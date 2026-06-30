import { getMessageStore } from "../metro/stores";
import type { ExportOptions } from "./types";

function getField<T>(message: Record<string, unknown>, ...keys: string[]): T | undefined {
    for (const key of keys) {
        const value = message[key];
        if (value !== undefined && value !== null) return value as T;
    }
    return undefined;
}

export function getMessageId(message: unknown): string | null {
    if (!message || typeof message !== "object") return null;
    const id = getField<string>(message as Record<string, unknown>, "id");
    return id ?? null;
}

export function getMessageTimestamp(message: unknown): number {
    if (!message || typeof message !== "object") return 0;
    const record = message as Record<string, unknown>;
    const value = getField<string>(record, "timestamp", "editedTimestamp", "edited_timestamp");
    return value ? Date.parse(value) : 0;
}

export function compareMessageIds(a: string, b: string): number {
    try {
        const diff = BigInt(a) - BigInt(b);
        if (diff < 0n) return -1;
        if (diff > 0n) return 1;
        return 0;
    } catch {
        return a.localeCompare(b);
    }
}

export function isMessageAtOrBeforePivot(messageId: string, pivotMessageId: string): boolean {
    return compareMessageIds(messageId, pivotMessageId) <= 0;
}

export function getPaginationBeforeCursor(
    options: ExportOptions,
    messages: Map<string, unknown>,
): string | undefined {
    let oldestId: string | undefined;
    let oldestTime = Number.POSITIVE_INFINITY;

    for (const message of messages.values()) {
        const id = getMessageId(message);
        if (!id) continue;
        const time = getMessageTimestamp(message);
        if (time < oldestTime) {
            oldestTime = time;
            oldestId = id;
        }
    }

    if (oldestId) return oldestId;

    if (!options.fromMessageId) return undefined;

    try {
        return (BigInt(options.fromMessageId) + 1n).toString();
    } catch {
        return options.fromMessageId;
    }
}

export function shouldStopPagination(batch: unknown[], fromMessageId?: string): boolean {
    if (!fromMessageId || batch.length === 0) return false;

    try {
        const pivot = BigInt(fromMessageId);
        for (const message of batch) {
            const id = getMessageId(message);
            if (id && BigInt(id) <= pivot) return true;
        }

        const oldestId = getMessageId(batch[batch.length - 1]);
        return oldestId ? BigInt(oldestId) <= pivot : false;
    } catch {
        return false;
    }
}

export function seedCachedMessages(channelId: string, options: ExportOptions): Map<string, unknown> {
    const byId = new Map<string, unknown>();

    for (const message of extractCachedMessages(channelId)) {
        const id = getMessageId(message);
        if (!id) continue;

        if (options.fromMessageId && !isMessageAtOrBeforePivot(id, options.fromMessageId)) {
            continue;
        }

        byId.set(id, message);
    }

    return byId;
}

export function extractCachedMessages(channelId: string): unknown[] {
    const store = getMessageStore();
    if (!store?.getMessages || typeof store.getMessages !== "function") return [];

    try {
        const collection = (store.getMessages as (id: string) => unknown)(channelId);
        if (!collection) return [];

        if (Array.isArray(collection)) return collection;

        if (typeof collection === "object") {
            const record = collection as Record<string, unknown>;
            if (Array.isArray(record._array)) return record._array;
            if (Array.isArray(record.messages)) return record.messages;
            if (typeof record.toArray === "function") {
                return (record.toArray as () => unknown[])() ?? [];
            }
        }
    } catch {
        return [];
    }

    return [];
}

export function applyMessageFilters(messages: unknown[], options: ExportOptions): unknown[] {
    let filtered = [...messages];

    if (options.authorId) {
        filtered = filtered.filter((message) => {
            if (!message || typeof message !== "object") return false;
            const author = (message as Record<string, unknown>).author as { id?: string } | undefined;
            return author?.id === options.authorId;
        });
    }

    if (options.afterDate) {
        const after = options.afterDate.getTime();
        filtered = filtered.filter((message) => getMessageTimestamp(message) >= after);
    }

    if (options.beforeDate) {
        const before = options.beforeDate.getTime();
        filtered = filtered.filter((message) => getMessageTimestamp(message) <= before);
    }

    if (options.fromMessageId) {
        filtered = filtered.filter((message) => {
            const id = getMessageId(message);
            return id ? isMessageAtOrBeforePivot(id, options.fromMessageId!) : false;
        });
    }

    filtered.sort((a, b) => getMessageTimestamp(a) - getMessageTimestamp(b));

    if (options.maxMessages > 0 && filtered.length > options.maxMessages) {
        filtered = filtered.slice(filtered.length - options.maxMessages);
    }

    return filtered;
}

export const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));
