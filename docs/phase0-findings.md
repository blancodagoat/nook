# Phase 0 Findings — Channel Messages Exporter

Fill this in after running the spike tools on a Vendetta device.

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
| ReactNative.Share | | |
| ReactNative.Clipboard | | |

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
