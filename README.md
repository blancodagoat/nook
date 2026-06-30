# Nook — Kettu / Revenge / Vendetta Plugins

Monorepo for Discord **mobile mod** plugins.

**Primary target:** [Kettu](https://codeberg.org/cocobo1/Kettu) (Bunny → Vendetta fork). Also works on [Revenge](https://github.com/revenge-mod/revenge-bundle) and legacy Vendetta loaders.

> **Note:** [kettu.cc/docs](https://kettu.cc/docs) is a unrelated Discord **bot** project. Kettu mod docs live on [Codeberg](https://codeberg.org/cocobo1/Kettu) and [raincord.dev/Kettu](https://raincord.dev/Kettu).

Legacy plugin API docs: [plugindocs.nexpid.xyz](https://plugindocs.nexpid.xyz) (concepts only — see **[Kettu API cross-reference](./docs/kettu-plugin-api-reference.md)** for current ground truth).

## Plugins

| Plugin | Install URL | Description |
|--------|-------------|-------------|
| Channel Messages Exporter | `https://blancodagoat.github.io/nook/channel-messages-exporter/` | Export channel history to JSON, TXT, or HTML |
| Template | `https://blancodagoat.github.io/nook/template/` | Starter plugin |

**Kettu install:** Settings → Plugins → + → paste the URL above (**trailing slash required**).

These use Kettu's **Vendetta-compatible** plugin loader (`onLoad`, `Settings`, `@vendetta/*` APIs).

## Channel Messages Exporter

### Where to find it in Kettu

1. **Plugin settings (always works if the plugin loaded)**
   - Kettu → **Settings → Plugins**
   - Tap **Channel Messages Exporter**
   - Use **Export current channel** or **Quick export** (open a channel first)

2. **Message menu**
   - Long-press a message → **Export from here**

3. **Channel menu**
   - Channel header / channel options sheet → **Export messages**

If menus are missing after a Discord update, use plugin settings or enable **Debug mode** (Advanced) and check logs for `[ChannelExporter] openLazy: ...`.

### Features

- JSON, TXT, HTML export
- Paginated REST fetch with cache fallback
- "Export from here" stops at the selected message
- Share sheet / clipboard output
- Filters, max messages, cancellable progress

## Development

```bash
pnpm install
pnpm build
```

**Plugin API reference:** [docs/kettu-plugin-api-reference.md](./docs/kettu-plugin-api-reference.md) — Kettu/Bunny/Vendetta cross-reference mapped from source + plugindocs.

### Local testing on Kettu

```bash
npx http-server dist --port 4040
# Install: http://192.168.x.x:4040/channel-messages-exporter/
```

Same Wi‑Fi as your phone. In Kettu developer settings you can also point at a custom plugin URL.

Fill in `docs/phase0-findings.md` when testing against a new Kettu/Discord version.

Pushes to `main` deploy `dist/` to GitHub Pages automatically.
