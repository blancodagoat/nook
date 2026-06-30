# Kettu / Bunny / Vendetta plugin API — cross-reference

Ground-truth mapping for **nook** plugins. There is no single official plugin-dev docs site for Kettu or Bunny. This doc ties together:

- [Kettu source](https://codeberg.org/cocobo1/Kettu) (canonical, current)
- [Bunny archive](https://github.com/bunny-mod/Bunny) (read-only, May 2025)
- [Vendetta Plugin Docs](https://plugindocs.nexpid.xyz) (community, ~2023 — concepts only)
- [Revenge docs](https://github.com/revenge-mod/revenge-bundle/tree/main/docs) (parallel fork — cross-check ideas, not copy-paste)

> **Not the mod:** [kettu.cc/docs](https://kettu.cc/docs) is a Discord **bot**, not the Kettu mobile client.

---

## Lineage

```
Vendetta (archived)
    └── Bunny / Pyoncord (archived May 2025)
            └── Kettu (active, Codeberg cocobo1/Kettu)
Revenge (parallel Bunny continuation, different tooling)
```

Kettu keeps Bunny’s `src/` layout (`scripts/`, `shims/`, `src/core/vendetta/`, `src/lib/addons/`). Bunny’s roadmap wanted **new** plugins on `@bunny/*`; Vendetta’s `@vendetta/*` was kept as a **compatibility shim**. Kettu still exposes both.

---

## Two plugin systems on Kettu

| | **Vendetta-compat (what nook uses)** | **Bunny spec 3 (native)** |
|---|---|---|
| **Loader** | `VdPluginManager` | `src/lib/addons/plugins/index.ts` |
| **Install URL** | `https://host/path/to/plugin/` (trailing `/` required) | Repo root + `repo.json` + `builds/{id}/manifest.json` |
| **Manifest** | Polymanifest-style `manifest.json` at plugin URL | `spec: 3`, `type: "plugin"`, semver in repo |
| **Entry exports** | `onLoad`, `onUnload`, `Settings` | `start`, `stop`, `SettingsComponent` |
| **Runtime global** | `window.vendetta` (+ per-plugin `plugin`, `logger`) | `window.bunny` (+ `bunny.plugin`) |
| **Imports in source** | `@vendetta/*` | `@bunny/*` / `@lib/*` / `@metro/*` |
| **Eval** | `vendetta=>{return ${plugin.js}}` | Bunny plugin API object |
| **Storage** | MMKV backend keyed by plugin install URL | Bunny `createStorage()` per plugin id |
| **Kettu source** | `src/core/vendetta/plugins.ts`, `api.tsx` | `src/lib/addons/plugins/` |

**nook** ships Vendetta-compat IIFE bundles to GitHub Pages. It does **not** target Bunny spec 3.

---

## Manifest (plugindocs ↔ Kettu ↔ nook)

| Field | [plugindocs manifest](https://plugindocs.nexpid.xyz/guides/manifest.md) | Kettu `VdPluginManager` | nook |
|---|---|---|---|
| `name`, `description`, `authors` | Required | Required | Same |
| `authors[].id` | “Currently unused” in plugindocs | Stored; snowflake | Set to Discord user id |
| `main` | Entry path for **bundler** | Fetched as JS filename after build | Dev: `src/index.ts`; deployed: `index.js` |
| `hash` | Added at build time | Used to skip re-download if unchanged | SHA-256 in `build.mjs` |
| `vendetta.icon` | Discord asset name | Shown in plugin list | e.g. `ic_download_24px` |

Deployed layout (GitHub Pages):

```
https://blancodagoat.github.io/nook/channel-messages-exporter/
├── manifest.json   ← hash + main: "index.js"
└── index.js        ← IIFE bundle
```

Install in Kettu: **Settings → Plugins → +** → paste URL **with trailing slash**.

---

## Entrypoint (plugindocs ↔ Kettu ↔ nook)

| Export | [plugindocs entrypoint](https://plugindocs.nexpid.xyz/guides/plugin-entrypoint.md) | Kettu `EvaledPlugin` type | nook `src/index.ts` |
|---|---|---|---|
| `onLoad()` | Called when enabled | `pluginRet.onLoad?.()` after eval | Patches + log |
| `onUnload()` | Called when disabled | `pluginRet.onUnload()` | Unpatch all |
| `Settings` | React settings component | `getSettings(id)` → component | `Settings.tsx` |

Kettu eval (`plugins.ts`):

```ts
const pluginString = `vendetta=>{return ${plugin.js}}\n//# sourceURL=${plugin.id}`;
const raw = (0, eval)(pluginString)(vendettaForPlugins);
return ret?.default ?? ret ?? {};
```

Named exports are required. Default-export-only plugins may fail depending on bundler output.

---

## Build pipeline (plugindocs ↔ nook)

| Topic | plugindocs | nook `build.mjs` |
|---|---|---|
| Bundler | Rollup + SWC/esbuild (typical) | Rollup + SWC + esbuild minify |
| Output format | IIFE | IIFE, `exports: "named"` |
| `@vendetta/*` | External → `vendetta.*` globals | `id.substring(1).replace(/\//g, ".")` |
| `react` | Must use Discord’s React | External → `vendetta.metro.common.React` |
| Local dev | [local plugin guide](https://plugindocs.nexpid.xyz/guides/local-plugin-development.md) | `pnpm build` + `http-server dist --port 4040` |

**Do not bundle React.** A second React copy breaks hooks and caused iOS crashes in early nook builds.

---

## `@vendetta/*` → Kettu source → status

Kettu builds `window.vendetta` in `src/core/vendetta/api.tsx`. Import paths in plugin source map to globals at runtime.

| Plugin import | Kettu implementation | plugindocs | Notes |
|---|---|---|---|
| `@vendetta` | `api.tsx` → `logger`, re-exports | Yes | Plugin gets scoped `logger` in eval context |
| `@vendetta/patcher` | `@lib/api/patcher` | Yes | `before`, `after`, `instead` |
| `@vendetta/metro` | `@metro` + stack-based find wrappers | Yes | `findByProps` has ActionSheet shims for redesign |
| `@vendetta/metro/common` | `@metro/common` subset on `vendetta.metro.common` | Partial | **No** `components` subpath on global — use `@vendetta/ui/components` for Forms |
| `@vendetta/metro/common` → `React` | `findByPropsLazy("createElement")` | Implied | Always import React from here, never npm `react` |
| `@vendetta/metro/common` → `ReactNative`, `clipboard` | Lazy metro finds | Yes | Share / clipboard in exporter |
| `@vendetta/ui/components` → `Forms` | `@metro/common/components` → `Forms` lazy object | Yes | **See UI pitfalls below** |
| `@vendetta/ui/toasts` | `@ui/toasts` | Yes | |
| `@vendetta/ui/alerts` | `@core/vendetta/alerts` | Yes | `showInputAlert`, etc. |
| `@vendetta/ui/assets` | `@lib/api/assets` | Yes | `getAssetIDByName` |
| `@vendetta/utils` | `@lib/utils` | Yes | `findInReactTree` for patch trees |
| `@vendetta/plugin` | Per-plugin `storage` in eval object | Yes | MMKV-backed key/value |
| `@vendetta/plugins` | `VdPluginManager` | Yes | Manage other plugins |

### Not on `window.vendetta.metro.common`

These exist in Kettu **mod source** (`@metro/common/components`) but are **not** re-exported on the vendetta shim. Plugins should use `findByProps` instead of inventing import paths:

- `ActionSheetRow` — inject into context menus
- `TableRow`, `TableRowGroup` — redesign settings rows
- `Text` — standalone text component

Example (safe in plugins):

```ts
import { findByProps } from "@vendetta/metro";

const { ActionSheetRow } = findByProps("ActionSheetRow") ?? {};
```

---

## UI pitfalls (plugindocs gaps — learned on iOS)

plugindocs shows patterns like:

```tsx
const { FormRow, FormIcon } = Forms;
<FormRow leading={<FormIcon source={...} />} />
```

**Kettu reality** (`src/metro/common/components.ts` + `src/lib/utils/lazy.ts`):

1. **`Forms` is lazy** — `findByPropsLazy("Form", "FormSection")`. Destructuring at module load or truthiness checks (`if (FormIcon)`) can pass while the resolved component is `undefined`.
2. **Legacy vs redesign** — Action sheets often use `ActionSheetRow` / `ButtonRow`, not `FormRow`. Settings may use `TableRow*` on newer Discord.
3. **Use Discord’s React** — `import { React } from "@vendetta/metro/common"`; externalize `react` in the bundle.

**nook mitigations** (channel-messages-exporter):

| Area | Approach | Source file |
|---|---|---|
| Context menu rows | Clone existing row `type` from sheet tree; fallback `ActionSheetRow` via `findByProps` | `src/patches/actionSheetRow.ts` |
| Settings / export sheet | Resolve `FormSection` / `FormRow` via `findByProps`, not lazy `Forms` alone | `src/ui/discordForms.ts` |
| Simple menus | Patch `showSimpleActionSheet` with plain `{ label, onPress }` objects | `src/patches/simpleActionSheet.ts` |

---

## Kettu-native settings API (parallel, not used by nook)

Kettu mod settings also support `registerSection()` in `src/lib/ui/settings/index.tsx` (RowConfig, native tabs). That path is for **built-in / Bunny spec 3** style integrations.

Vendetta-compat plugins still use the exported **`Settings`** React component rendered by `VdPluginManager.getSettings(id)`.

---

## External resources

| Resource | URL | Use for |
|---|---|---|
| Kettu (canonical) | https://codeberg.org/cocobo1/Kettu | Source of truth |
| Kettu (GitHub mirror) | https://github.com/C0C0B01/Kettu | Browse / star |
| Bunny (archived) | https://github.com/bunny-mod/Bunny | Historical `@bunny/*` API |
| Vendetta Plugin Docs | https://plugindocs.nexpid.xyz | Manifest, patcher concepts, local dev |
| plugindocs sitemap | https://plugindocs.nexpid.xyz/sitemap.md | Full page index |
| Revenge docs | https://github.com/revenge-mod/revenge-bundle/tree/main/docs | Cross-fork ideas |
| GitHub topic: kettu-plugins | https://github.com/topics/kettu-plugins | Working examples |
| GitHub topic: bunny-plugins | https://github.com/topics/bunny-plugins | Older examples (usually portable) |
| Polymanifest spec | https://github.com/vendetta-mod/polymanifest | Manifest hash convention |

---

## Kettu source file index (plugin-relevant)

| Path | Purpose |
|---|---|
| `src/core/vendetta/plugins.ts` | Fetch, eval, start/stop Vendetta plugins |
| `src/core/vendetta/api.tsx` | `window.vendetta` object definition |
| `src/core/vendetta/alerts.ts` | Input/confirmation alerts |
| `src/core/vendetta/storage.ts` | MMKV storage helpers |
| `src/lib/api/patcher.ts` | Patcher implementation |
| `src/metro/common/components.ts` | Forms, ActionSheetRow, TableRow, … |
| `src/metro/common/index.ts` | React, ReactNative, Flux, channels, … |
| `src/lib/addons/plugins/index.ts` | Bunny spec 3 plugin manager |
| `src/lib/addons/plugins/types.ts` | `start`/`stop`/`SettingsComponent` types |
| `src/lib/ui/settings/index.tsx` | Native `registerSection` settings API |

---

## nook plugin checklist (Kettu iOS)

- [ ] Install URL ends with `/`
- [ ] `manifest.hash` matches deployed `index.js` (reinstall after deploy)
- [ ] No bundled `react`; hooks use `vendetta.metro.common.React`
- [ ] No top-level `const { X } = Forms` for components used in render
- [ ] Action sheet injection clones existing row types or uses `findByProps("ActionSheetRow")`
- [ ] Patches store unpatch functions; `onUnload` calls them all
- [ ] Settings work without context menus (fallback path for users)
- [ ] Fill [phase0-findings.md](./phase0-findings.md) after testing on target Discord build

---

## Related nook docs

- [README](../README.md) — install URLs, user-facing feature list
- [phase0-findings.md](./phase0-findings.md) — device-specific metro discovery results
- [channel-messages-exporter-plan.md](./channel-messages-exporter-plan.md) — feature plan
