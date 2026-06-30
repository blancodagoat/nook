import { getGuildName, getUserStore } from "../metro/stores";
import type {
    ExportAuthor,
    ExportChannel,
    ExportMessage,
    ExportOptions,
    RawChannel,
} from "./types";

function asRecord(value: unknown): Record<string, unknown> | null {
    return value && typeof value === "object" ? (value as Record<string, unknown>) : null;
}

function readString(record: Record<string, unknown>, ...keys: string[]): string | undefined {
    for (const key of keys) {
        const value = record[key];
        if (typeof value === "string" && value.length > 0) return value;
    }
    return undefined;
}

function resolveAuthor(rawAuthor: unknown, options: ExportOptions): ExportAuthor {
    const author = asRecord(rawAuthor) ?? {};
    const id = readString(author, "id") ?? "unknown";
    let username = readString(author, "username") ?? "unknown";
    let displayName =
        readString(author, "globalName", "global_name", "displayName", "display_name") ?? username;

    const userStore = getUserStore();
    if (userStore?.getUser && typeof userStore.getUser === "function") {
        try {
            const user = (userStore.getUser as (userId: string) => Record<string, unknown> | null)(id);
            if (user) {
                username = readString(user, "username") ?? username;
                displayName =
                    readString(user, "globalName", "global_name", "displayName") ?? displayName;
            }
        } catch {
            // ignore lookup failures
        }
    }

    const exportAuthor: ExportAuthor = { id, username, displayName };

    if (options.includeAvatars) {
        const avatar = readString(author, "avatarURL", "avatarUrl");
        if (avatar) exportAuthor.avatarUrl = avatar;
    }

    return exportAuthor;
}

export function normalizeChannel(channel: RawChannel): ExportChannel {
    const guildName = getGuildName(channel.guild_id);
    return {
        id: channel.id,
        name: channel.name ?? `channel-${channel.id}`,
        type: channel.type ?? 0,
        guildId: channel.guild_id,
        guildName,
        parentId: channel.parent_id,
    };
}

export function normalizeMessage(raw: unknown, options: ExportOptions): ExportMessage | null {
    const message = asRecord(raw);
    if (!message) return null;

    const id = readString(message, "id");
    const channelId = readString(message, "channel_id", "channelId");
    if (!id || !channelId) return null;

    const exportMessage: ExportMessage = {
        id,
        channelId,
        author: resolveAuthor(message.author, options),
        content: readString(message, "content") ?? "",
        timestamp: readString(message, "timestamp") ?? new Date().toISOString(),
        editedTimestamp: readString(message, "edited_timestamp", "editedTimestamp"),
        type: typeof message.type === "number" ? message.type : 0,
    };

    if (options.includeAttachments && Array.isArray(message.attachments)) {
        exportMessage.attachments = message.attachments
            .map((attachment) => asRecord(attachment))
            .filter((attachment): attachment is Record<string, unknown> => Boolean(attachment))
            .map((attachment) => ({
                url: readString(attachment, "url", "proxy_url", "proxyURL") ?? "",
                filename: readString(attachment, "filename", "title") ?? "attachment",
                size: typeof attachment.size === "number" ? attachment.size : undefined,
            }))
            .filter((attachment) => attachment.url.length > 0);
    }

    if (options.includeEmbeds && Array.isArray(message.embeds)) {
        exportMessage.embeds = message.embeds
            .map((embed) => asRecord(embed))
            .filter((embed): embed is Record<string, unknown> => Boolean(embed))
            .map((embed) => ({
                title: readString(embed, "title"),
                description: readString(embed, "description", "rawDescription"),
                url: readString(embed, "url"),
                color: typeof embed.color === "number" ? embed.color : undefined,
            }))
            .filter((embed) => embed.title || embed.description || embed.url);
    }

    if (options.includeReactions && Array.isArray(message.reactions)) {
        exportMessage.reactions = message.reactions
            .map((reaction) => asRecord(reaction))
            .filter((reaction): reaction is Record<string, unknown> => Boolean(reaction))
            .map((reaction) => {
                const emoji = asRecord(reaction.emoji);
                const emojiName =
                    readString(emoji ?? {}, "name") ??
                    (typeof reaction.emoji === "string" ? reaction.emoji : "?");
                return {
                    emoji: emojiName,
                    count: typeof reaction.count === "number" ? reaction.count : 0,
                };
            });
    }

    const reference = asRecord(message.message_reference ?? message.messageReference);
    if (reference) {
        exportMessage.replyTo = {
            id: readString(reference, "message_id", "messageId") ?? "",
            content: readString(reference, "content"),
        };
    }

    return exportMessage;
}

export function normalizeMessages(rawMessages: unknown[], options: ExportOptions): ExportMessage[] {
    return rawMessages
        .map((message) => normalizeMessage(message, options))
        .filter((message): message is ExportMessage => Boolean(message));
}
