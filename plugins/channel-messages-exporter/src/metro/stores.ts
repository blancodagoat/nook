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
        return findByProps("openLazy", "hideActionSheet") as {
            openLazy?: (...args: unknown[]) => void;
            hideActionSheet?: () => void;
        };
    } catch {
        return null;
    }
}

export function getRestApi(): {
    get?: (options: {
        url: string;
        query?: Record<string, string | number>;
        retries?: number;
    }) => Promise<{ body?: unknown } | null>;
} | null {
    try {
        return findByProps("get", "post", "patch", "put", "delete") as {
            get?: (options: {
                url: string;
                query?: Record<string, string | number>;
                retries?: number;
            }) => Promise<{ body?: unknown } | null>;
        };
    } catch {
        return null;
    }
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
