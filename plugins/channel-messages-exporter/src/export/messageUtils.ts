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
        const pivot = filtered.find((message) => getMessageId(message) === options.fromMessageId);
        if (pivot) {
            const pivotTime = getMessageTimestamp(pivot);
            filtered = filtered.filter((message) => getMessageTimestamp(message) <= pivotTime);
        }
    }

    filtered.sort((a, b) => getMessageTimestamp(a) - getMessageTimestamp(b));

    if (options.maxMessages > 0 && filtered.length > options.maxMessages) {
        filtered = filtered.slice(filtered.length - options.maxMessages);
    }

    return filtered;
}

export const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));
