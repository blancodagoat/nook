import type { ExportMessage, ExportPayload } from "../types";

function escapeHtml(value: string): string {
    return value
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;");
}

function renderMessage(message: ExportMessage): string {
    const author = escapeHtml(message.author.displayName ?? message.author.username);
    const content = escapeHtml(message.content || "(no content)").replace(/\n/g, "<br>");
    const timestamp = escapeHtml(new Date(message.timestamp).toLocaleString());

    const attachments = (message.attachments ?? [])
        .map(
            (attachment) =>
                `<div class="attachment"><a href="${escapeHtml(attachment.url)}">${escapeHtml(attachment.filename)}</a></div>`,
        )
        .join("");

    const embeds = (message.embeds ?? [])
        .map((embed) => {
            const title = embed.title ? `<strong>${escapeHtml(embed.title)}</strong>` : "";
            const description = embed.description
                ? `<div>${escapeHtml(embed.description)}</div>`
                : "";
            const link = embed.url
                ? `<a href="${escapeHtml(embed.url)}">${escapeHtml(embed.url)}</a>`
                : "";
            return `<div class="embed">${title}${description}${link}</div>`;
        })
        .join("");

    const reactions = (message.reactions ?? [])
        .map((reaction) => `<span class="reaction">${escapeHtml(reaction.emoji)} ${reaction.count}</span>`)
        .join(" ");

    return `
<article class="message">
  <header>
    <span class="author">${author}</span>
    <time>${timestamp}</time>
  </header>
  <div class="content">${content}</div>
  ${attachments}
  ${embeds}
  ${reactions ? `<div class="reactions">${reactions}</div>` : ""}
</article>`;
}

export function serializeHtml(payload: ExportPayload): string {
    const title = escapeHtml(payload.channel.guildName
        ? `${payload.channel.guildName} / ${payload.channel.name}`
        : payload.channel.name);

    return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${title} export</title>
  <style>
    body { background: #1e1f22; color: #dbdee1; font-family: system-ui, sans-serif; margin: 0; padding: 16px; }
    .banner { background: #2b2d31; border-radius: 8px; padding: 16px; margin-bottom: 16px; }
    .message { background: #2b2d31; border-radius: 8px; padding: 12px; margin-bottom: 12px; }
    .author { color: #fff; font-weight: 600; margin-right: 8px; }
    time { color: #949ba4; font-size: 12px; }
    .content { margin-top: 8px; white-space: pre-wrap; word-break: break-word; }
    .attachment, .embed, .reactions { margin-top: 8px; font-size: 14px; }
    .embed { border-left: 3px solid #5865f2; padding-left: 8px; color: #c9ccd1; }
    a { color: #00a8fc; }
    .partial { color: #faa61a; }
  </style>
</head>
<body>
  <section class="banner">
    <h1>${title}</h1>
    <p>Exported ${escapeHtml(payload.exportedAt)} · ${payload.messageCount} messages</p>
    ${payload.partial ? '<p class="partial">Partial export — some history may be missing.</p>' : ""}
  </section>
  <main>
    ${payload.messages.map(renderMessage).join("\n")}
  </main>
</body>
</html>`;
}
