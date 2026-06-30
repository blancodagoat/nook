import type { ExportMessage, ExportPayload } from "../types";

function formatTimestamp(value: string): string {
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return value;
    return date.toISOString().replace("T", " ").slice(0, 16);
}

function formatMessage(message: ExportMessage): string {
    const author = message.author.displayName ?? message.author.username;
    const lines = [`[${formatTimestamp(message.timestamp)}] ${author}: ${message.content || "(no content)"}`];

    if (message.attachments?.length) {
        for (const attachment of message.attachments) {
            lines.push(`  attachment: ${attachment.filename} — ${attachment.url}`);
        }
    }

    if (message.embeds?.length) {
        for (const embed of message.embeds) {
            const title = embed.title ?? "embed";
            lines.push(`  embed: ${title}${embed.url ? ` — ${embed.url}` : ""}`);
        }
    }

    if (message.reactions?.length) {
        lines.push(
            `  reactions: ${message.reactions.map((reaction) => `${reaction.emoji}(${reaction.count})`).join(" ")}`,
        );
    }

    return lines.join("\n");
}

export function serializeTxt(payload: ExportPayload): string {
    const header = [
        `Channel: ${payload.channel.name}`,
        payload.channel.guildName ? `Guild: ${payload.channel.guildName}` : null,
        `Exported: ${payload.exportedAt}`,
        payload.partial ? "Note: partial export (only cached messages)" : null,
        "",
    ]
        .filter(Boolean)
        .join("\n");

    return `${header}\n${payload.messages.map(formatMessage).join("\n\n")}`;
}
