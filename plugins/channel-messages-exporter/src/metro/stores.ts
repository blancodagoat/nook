import { find, findByProps } from "@vendetta/metro";

export interface MetroModuleStatus {
    found: boolean;
    keys: string[];
    error?: string;
}

function probe(label: string, resolver: () => unknown): MetroModuleStatus {
    try {
        const mod = resolver();
        if (!mod || typeof mod !== "object") {
            return { found: false, keys: [], error: `${label}: resolver returned ${mod}` };
        }

        return {
            found: true,
            keys: Object.keys(mod as object).sort(),
        };
    } catch (error) {
        return {
            found: false,
            keys: [],
            error: `${label}: ${error instanceof Error ? error.message : String(error)}`,
        };
    }
}

export const metroModules = {
    messageStore: () =>
        probe("MessageStore", () => findByProps("getMessages", "getMessage")),

    channelStore: () =>
        probe("ChannelStore", () => findByProps("getChannel", "hasChannel")),

    userStore: () =>
        probe("UserStore", () => findByProps("getUser", "getCurrentUser")),

    guildStore: () =>
        probe("GuildStore", () => findByProps("getGuild", "getGuilds")),

    selectedChannel: () =>
        probe("SelectedChannelStore", () => findByProps("getChannelId", "getLastSelectedChannelId")),

    messageFetcher: () =>
        probe("MessageFetcher", () =>
            find((module) => {
                if (!module || typeof module !== "object") return false;
                const candidate = module as Record<string, unknown>;
                return (
                    typeof candidate.fetchMessages === "function" ||
                    typeof candidate.loadMessages === "function" ||
                    typeof candidate.getMessages === "function"
                );
            }),
        ),

    lazyActionSheet: () =>
        probe("LazyActionSheet", () => findByProps("openLazy", "hideActionSheet")),

    reactNative: () =>
        probe("ReactNative", () => {
            // eslint-disable-next-line @typescript-eslint/no-require-imports
            const common = require("@vendetta/metro/common") as {
                ReactNative?: { Share?: unknown; Clipboard?: unknown };
            };
            return common.ReactNative;
        }),
};

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

export function getSelectedChannelId(): string | null {
    try {
        const selected = findByProps("getChannelId", "getLastSelectedChannelId") as {
            getChannelId?: () => string;
            getLastSelectedChannelId?: () => string;
        };
        return selected.getChannelId?.() ?? selected.getLastSelectedChannelId?.() ?? null;
    } catch {
        try {
            // eslint-disable-next-line @typescript-eslint/no-require-imports
            const { channels } = require("@vendetta/metro/common") as {
                channels?: { getChannelId?: () => string };
            };
            return channels?.getChannelId?.() ?? null;
        } catch {
            return null;
        }
    }
}
