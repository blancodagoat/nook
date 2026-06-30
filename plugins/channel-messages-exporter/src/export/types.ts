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
    guildName?: string;
}

export interface ExportPayload {
    exportedAt: string;
    channel: ExportChannel;
    messageCount: number;
    messages: ExportMessage[];
}

export type ExportFormat = "json" | "txt";
