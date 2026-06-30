# Phase 0 Findings — Channel Messages Exporter

Fill this in after running the spike tools on a Vendetta device.

Reference: [Vendetta Plugin Docs](https://plugindocs.nexpid.xyz)

## Local testing setup

1. `pnpm install && pnpm build`
2. `http-server dist --port 4040` ([local dev guide](https://plugindocs.nexpid.xyz/guides/local-plugin-development.md))
3. Install `http://192.168.x.x:4040/channel-messages-exporter` on phone (same Wi‑Fi)
4. Open a channel, then plugin settings → run both spike buttons

## Test environment

- Discord app version:
- Vendetta version / loader:
- Platform (Android/iOS):
- Test channel type (DM / server / thread):

## Metro module resolution

| Module | Found? | Notes |
|--------|--------|-------|
| MessageStore | | |
| ChannelStore | | |
| UserStore | | |
| GuildStore | | |
| SelectedChannelStore | | |
| Message fetch API | | |
| ReactNative.Share | | via `@vendetta/metro/common` |
| clipboard | | via `@vendetta/metro/common` |

## Message collection shape

Paste output from plugin settings → "Run metro discovery":

```
Channel id:
Collection keys:
Sample message keys:
messageCount:
hasMore:
Fetch candidates:
```

## Share spike

- [ ] Native share sheet opened
- [ ] Clipboard fallback used
- [ ] Failed (reason):

## Decisions for Phase 1

- Pagination API to use:
- Message array field (`_array` / other):
- Channel menu patch target:
- Share strategy (Share / Clipboard / both):
