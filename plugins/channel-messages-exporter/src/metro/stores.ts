import { channels } from "@vendetta/metro/common";
import { find, findByProps } from "@vendetta/metro";

import type { RawChannel } from "../export/types";

export function getMessageStore(): Record<string, unknown> | null {
    try {
        return findByProps("getMessages", "getMessage") as Record<string, unknown>;
    } catch {
        return null;
    }
}

export function getChannelStore(): Record<string, unknown> | null {
    try {
        return findByProps("getChannel", "hasChannel") as Record<string, unknown>;
    } catch {
        return null;
    }
}

export function getUserStore(): Record<string, unknown> | null {
    try {
        return findByProps("getUser", "getCurrentUser") as Record<string, unknown>;
    } catch {
        return null;
    }
}

export function getGuildStore(): Record<string, unknown> | null {
    try {
        return findByProps("getGuild", "getGuilds") as Record<string, unknown>;
    } catch {
        return null;
    }
}

export function getLazyActionSheet(): {
    openLazy?: (...args: unknown[]) => void;
    hideActionSheet?: () => void;
} | null {
    try {
        const direct = find(
            (module) =>
                module?.openLazy &&
                module?.hideActionSheet &&
                !Object.getOwnPropertyDescriptor(module, "openLazy")?.get,
        ) as {
            openLazy?: (...args: unknown[]) => void;
            hideActionSheet?: () => void;
        } | null;

        if (direct) return direct;

        return findByProps("openLazy", "hideActionSheet") as {
            openLazy?: (...args: unknown[]) => void;
            hideActionSheet?: () => void;
        };
    } catch {
        return null;
    }
}

export type RestApiClient = {
    get?: (options: {
        url: string;
        query?: Record<string, string | number>;
        retries?: number;
    }) => Promise<{ body?: unknown } | null>;
};

function isDirectMethod(module: object, method: string): boolean {
    const descriptor = Object.getOwnPropertyDescriptor(module, method);
    return typeof descriptor?.value === "function" && !descriptor.get;
}

function isRestApiCandidate(module: unknown): module is RestApiClient {
    if (!module || typeof module !== "object") return false;

    for (const method of ["get", "post", "patch", "put", "delete"]) {
        if (!isDirectMethod(module, method)) return false;
    }

    return true;
}

let cachedRestApi: RestApiClient | null | undefined;

export function getRestApi(): RestApiClient | null {
    if (cachedRestApi !== undefined) return cachedRestApi;

    try {
        const candidates: RestApiClient[] = [];

        const withRequest = find(
            (module) => isRestApiCandidate(module) && "request" in module,
        ) as RestApiClient | undefined;
        if (withRequest) candidates.push(withRequest);

        const generic = find(isRestApiCandidate) as RestApiClient | undefined;
        if (generic && generic !== withRequest) candidates.push(generic);

        const legacy = findByProps("get", "post", "patch", "put", "delete") as RestApiClient | null;
        if (legacy && !candidates.includes(legacy)) candidates.push(legacy);

        cachedRestApi = candidates.find((candidate) => typeof candidate.get === "function") ?? null;
    } catch {
        cachedRestApi = null;
    }

    return cachedRestApi;
}

export function looksLikeMessageBatch(body: unknown): boolean {
    if (!Array.isArray(body) || body.length === 0) return true;

    const first = body[0];
    if (!first || typeof first !== "object") return false;

    const record = first as Record<string, unknown>;
    return typeof record.id === "string" && ("channel_id" in record || "channelId" in record);
}

export function getMessageFetcher(): Record<string, unknown> | null {
    try {
        return find((module) => {
            if (!module || typeof module !== "object") return false;
            const candidate = module as Record<string, unknown>;
            return (
                typeof candidate.fetchMessages === "function" ||
                typeof candidate.loadMessages === "function"
            );
        }) as Record<string, unknown> | null;
    } catch {
        return null;
    }
}

export function getSelectedChannelId(): string | null {
    try {
        const selected = findByProps("getChannelId", "getLastSelectedChannelId") as {
            getChannelId?: () => string;
            getLastSelectedChannelId?: () => string;
        };
        const fromStore = selected.getChannelId?.() ?? selected.getLastSelectedChannelId?.();
        if (fromStore) return fromStore;
    } catch {
        // fall through
    }

    try {
        const channelApi = channels as { getChannelId?: () => string };
        return channelApi.getChannelId?.() ?? null;
    } catch {
        return null;
    }
}

export function getChannel(channelId: string): RawChannel | null {
    const store = getChannelStore();
    if (!store?.getChannel || typeof store.getChannel !== "function") return null;

    try {
        return (store.getChannel as (id: string) => RawChannel | null)(channelId);
    } catch {
        return null;
    }
}

export function getGuildName(guildId?: string): string | undefined {
    if (!guildId) return undefined;
    const store = getGuildStore();
    if (!store?.getGuild || typeof store.getGuild !== "function") return undefined;

    try {
        const guild = (store.getGuild as (id: string) => { name?: string } | null)(guildId);
        return guild?.name;
    } catch {
        return undefined;
    }
}

export function resolveChannelLabel(channel: RawChannel | null): string {
    if (!channel) return "unknown-channel";
    if (channel.name) return channel.name;

    if (channel.recipients?.length) {
        return channel.recipients.map((user) => user.username ?? user.id).join("-");
    }

    return `channel-${channel.id}`;
}
