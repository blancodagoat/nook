# Nook — Vendetta Plugins

Monorepo for [Vendetta](https://github.com/vendetta-mod/Vendetta) plugins, based on the [official plugin template](https://github.com/vendetta-mod/plugin-template).

Docs: [plugindocs.nexpid.xyz](https://plugindocs.nexpid.xyz)

## Plugins

| Plugin | Install URL |
|--------|-------------|
| Channel Messages Exporter | `https://blancodagoat.github.io/nook/channel-messages-exporter` |
| Template | `https://blancodagoat.github.io/nook/template` |

Paste a plugin URL into **Vendetta → Settings → Plugins → +**.

## Development

```bash
pnpm install
pnpm build
```

### Local testing (phone on same Wi‑Fi)

Per [plugindocs local dev guide](https://plugindocs.nexpid.xyz/guides/local-plugin-development.md):

```bash
# Terminal 1 — serve built plugins
http-server dist --port 4040

# Terminal 2 — rebuild after changes
pnpm build
```

Install from your LAN IP, e.g. `http://192.168.x.x:4040/channel-messages-exporter`.

### GitHub Pages deploy

Pushes to `main` build and deploy `dist/` via GitHub Actions. Enable Pages with the `gh-pages` branch (see [setting up guide](https://plugindocs.nexpid.xyz/guides/setting-up.md)).

## Plugin entrypoint

Follow the [plugin entrypoint docs](https://plugindocs.nexpid.xyz/guides/plugin-entrypoint.md):

```ts
export const onLoad = () => { /* ... */ };
export const onUnload = () => { /* ... */ };
export const Settings = () => <Text>Hello</Text>;
```

## Channel Messages Exporter

Phase 0 spike plugin — probes Discord metro modules and tests share export. See `docs/channel-messages-exporter-plan.md` and `docs/phase0-findings.md`.
