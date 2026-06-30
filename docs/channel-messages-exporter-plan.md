# Channel Messages Exporter — Plugin Plan

A Vendetta plugin to export message history from the current Discord channel to a shareable file.

## Goal

Let users export messages from any channel they can read (server text channels, threads, DMs, group DMs) into a portable file they can save or share from their phone.

## Constraints

- **Platform:** Vendetta (React Native Discord mobile mod). APIs via `@vendetta/metro` and `@vendetta/metro/common`. See [plugindocs.nexpid.xyz](https://plugindocs.nexpid.xyz).
- **Vendetta is discontinued** (Feb 2024). This plugin targets Vendetta; Revenge/Kettu forks may need small API adjustments later.
- **Discord ToS:** Exporting messages from channels you can access is generally fine for personal backup, but bulk automated scraping is discouraged. The plugin should be user-initiated, rate-limited, and scoped to one channel at a time.
- **Mobile limits:** Large channels can have tens of thousands of messages. Memory and share-sheet size limits mean we need pagination, progress UI, and optional caps.

---

## User Experience

### Entry points

1. **Channel header / context menu** — "Export messages" on the active channel (primary flow).
2. **Message long-press sheet** (optional v2) — "Export from here" to export messages around the selected message (useful for partial exports).

### Export flow

```
User taps "Export messages"
  → Bottom sheet / modal opens
  → Shows channel name, estimated count (if known), format picker
  → User sets options (date range, limit, include attachments metadata, etc.)
  → Tap "Export"
  → Progress indicator while fetching + serializing
  → Native share sheet opens with the file (or clipboard fallback for small exports)
```

### Settings (plugin settings page)

| Setting | Default | Description |
|---------|---------|-------------|
| Default format | JSON | `json` or `txt` |
| Max messages | 5000 | Safety cap per export (0 = unlimited with warning) |
| Include embeds | true | Serialize embed title, description, URL, color |
| Include attachments | true | URLs + filenames (not binary download) |
| Include reactions | false | Reaction emoji + count |
| Include user avatars | false | Adds size; URLs only |
| Date format | ISO 8601 | For timestamps in output |
| Filename template | `{channel}-{date}` | e.g. `general-2026-06-30.json` |

---

## Technical Architecture

### Plugin layout

```
plugins/channel-messages-exporter/
├── manifest.json
└── src/
    ├── index.ts              # onLoad / onUnload, register patches
    ├── Settings.tsx          # Plugin settings UI
    ├── patches/
    │   ├── channelMenu.ts    # Inject export action into channel menu
    │   └── messageSheet.ts   # (v2) Long-press sheet button
    ├── metro/
    │   └── stores.ts         # Lazy findByProps for Discord internals
    ├── export/
    │   ├── fetchMessages.ts  # Paginated history fetch
    │   ├── normalize.ts      # Raw message → ExportMessage
    │   ├── formats/
    │   │   ├── json.ts
    │   │   └── txt.ts
    │   └── types.ts
    └── ui/
        ├── ExportSheet.tsx   # Export options + progress modal
        └── share.ts          # RN Share / clipboard helper
```

### Discord internals to resolve (via `@vendetta/metro`)

| Module | Lookup hint | Purpose |
|--------|-------------|---------|
| `MessageStore` | `getMessages`, `getMessage` | Read cached messages for a channel |
| `ChannelStore` | `getChannel`, `getDMFromUserId` | Channel metadata (name, guild, type) |
| `UserStore` | `getUser`, `getCurrentUser` | Author display names |
| `GuildStore` | `getGuild` | Server name for filename/metadata |
| Message fetch API | `fetchMessages`, `loadMessages`, or `getMessages` + `hasMore` | Paginate beyond local cache |
| `LazyActionSheet` | `hideActionSheet` | Close menus after action |
| Channel context menu | TBD via `findByDisplayName` / patch | Inject menu item |

> **Spike task (Phase 0):** On a device with Vendetta, log `MessageStore.getMessages(channelId)` shape and locate the fetch/pagination API before building the full exporter.

### Data model

```ts
interface ExportMessage {
  id: string;
  channelId: string;
  author: { id: string; username: string; displayName?: string };
  content: string;
  timestamp: string;       // ISO
  editedTimestamp?: string;
  attachments?: { url: string; filename: string; size?: number }[];
  embeds?: { title?: string; description?: string; url?: string; color?: number }[];
  reactions?: { emoji: string; count: number }[];
  replyTo?: { id: string; content?: string };
  type: number;            // Discord message type (default, system, etc.)
}

interface ExportPayload {
  exportedAt: string;
  channel: { id: string; name: string; type: number; guildName?: string };
  messageCount: number;
  messages: ExportMessage[];
}
```

### Message fetching strategy

1. **Read cache first** — `MessageStore.getMessages(channelId)` returns a collection (often `_array` or similar; confirm in spike).
2. **Paginate backward** — Call Discord's internal fetch with `before: oldestMessageId` until:
   - No more messages (`hasMore === false`),
   - User's max limit reached,
   - Or optional date cutoff passed.
3. **Rate limiting** — 300–500 ms delay between fetch batches; show cancellable progress.
4. **Deduplicate** — Merge by message ID when cache and fetch overlap.

### Output formats

**v1 — JSON** (primary)
- Full structured `ExportPayload`.
- Easy to parse, convert to HTML later, or import elsewhere.

**v1 — Plain text**
- Human-readable lines: `[2026-06-30 12:34] Author: content`
- Attachments appended as URLs on following lines.

**v2 — HTML** (optional)
- Self-contained dark-theme HTML inspired by DiscordChatExporter.
- Higher effort; defer until JSON/TXT work.

### Sharing on mobile

- Build export string in memory → write to temp path if RN FS available, else use `Share.share({ message: content })` for smaller exports.
- Investigate `@vendetta` / React Native APIs for `Share` and `Clipboard` during Phase 0.
- For large exports (>5 MB), warn user and suggest lowering max messages.

---

## Implementation Phases

### Phase 0 — Spike (0.5 day)
- [ ] Create `plugins/channel-messages-exporter/` scaffold from template
- [ ] Resolve and document Metro module handles on device
- [ ] Confirm message object shape and pagination API
- [ ] Confirm share mechanism works with a hardcoded JSON blob

### Phase 1 — MVP
- [ ] Channel menu entry: "Export messages"
- [ ] Export modal with format (JSON/TXT) and max message limit
- [ ] Fetch all cached messages + paginate until limit or end
- [ ] Normalize to `ExportMessage[]`
- [ ] JSON + TXT serializers
- [ ] Share sheet output
- [ ] Basic error handling + user-visible toasts/logs

### Phase 2 — Polish
- [ ] Plugin settings page wired to defaults
- [ ] Progress bar with cancel
- [ ] Date range filter (export messages after/before)
- [ ] Include/exclude embeds, attachments, reactions toggles
- [ ] Smart filename from channel + guild name

### Phase 3 — Extras (optional)
- [ ] "Export from here" on message long-press
- [ ] HTML export
- [ ] Export single user's messages in channel (filter by author)
- [ ] Thread support verification

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Metro module names change | Centralize lookups in `stores.ts`; fail with clear error |
| OOM on huge channels | Default cap (5000), streaming TXT writer if possible |
| Fetch API not found | Fall back to cached messages only; show "partial export" badge |
| Vendetta API drift | Document tested Discord app version; consider Revenge port |
| Sensitive data in exports | No upload anywhere; export stays on-device via share sheet |

---

## Testing Checklist

- [ ] Small DM ( < 50 messages )
- [ ] Active server channel (1000+ messages, pagination)
- [ ] Thread export
- [ ] Channel with embeds, stickers, attachments (metadata only)
- [ ] System messages (join/leave, pins)
- [ ] Export cancel mid-fetch
- [ ] Settings persist across reload
- [ ] Build + GitHub Pages deploy produces installable plugin URL

---

## Install URL (after deploy)

```
https://blancodagoat.github.io/nook/channel-messages-exporter
```

(Assumes repo name `nook`, branch `main`, GitHub Pages enabled.)

---

## Open Questions

1. Does Vendetta expose a file-system write API, or is share-sheet text the only path?
2. Which channel context menu component to patch on current Discord RN builds?
3. Should we support exporting only the currently loaded scroll window as a "quick export" mode?

Resolve these in Phase 0 before writing fetch/UI code.
