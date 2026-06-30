export interface ExportAttachment {
    url: string;
    filename: string;
    size?: number;
}

export interface ExportEmbed {
    title?: string;
    description?: string;
    url?: string;
    color?: number;
}

export interface ExportReaction {
    emoji: string;
    count: number;
}

export interface ExportAuthor {
    id: string;
    username: string;
    displayName?: string;
    avatarUrl?: string;
}

export interface ExportMessage {
    id: string;
    channelId: string;
    author: ExportAuthor;
    content: string;
    timestamp: string;
    editedTimestamp?: string;
    attachments?: ExportAttachment[];
    embeds?: ExportEmbed[];
    reactions?: ExportReaction[];
    replyTo?: { id: string; content?: string };
    type: number;
}

export interface ExportChannel {
    id: string;
    name: string;
    type: number;
    guildId?: string;
    guildName?: string;
    parentId?: string;
}

export interface ExportPayload {
    exportedAt: string;
    partial: boolean;
    channel: ExportChannel;
    messageCount: number;
    messages: ExportMessage[];
    filters?: {
        authorId?: string;
        afterDate?: string;
        beforeDate?: string;
        fromMessageId?: string;
    };
}

export type ExportFormat = "json" | "txt" | "html";

export interface ExportOptions {
    format: ExportFormat;
    maxMessages: number;
    includeEmbeds: boolean;
    includeAttachments: boolean;
    includeReactions: boolean;
    includeAvatars: boolean;
    filenameTemplate: string;
    fetchDelayMs: number;
    afterDate?: Date;
    beforeDate?: Date;
    authorId?: string;
    fromMessageId?: string;
}

export interface FetchProgress {
    fetched: number;
    partial: boolean;
    done: boolean;
    error?: string;
}

export type FetchProgressCallback = (progress: FetchProgress) => void;

export interface RawChannel {
    id: string;
    name?: string;
    type?: number;
    guild_id?: string;
    parent_id?: string;
    recipients?: { id: string; username?: string }[];
}
