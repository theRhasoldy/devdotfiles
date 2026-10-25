# LSP server settings — what actually changes behaviour over `vim.lsp`

Research question: for each server enabled in `lua/plugins/lsp.lua`, which `settings` (or `init_options`) change behaviour under Neovim's native client, which are VS Code-only no-ops, and which can hurt? Date of research: 2026-10-24. All primary-source reads done live (upstream clones — installed versions where the package ships sources, HEAD where it does not — the `nvim-lspconfig` defaults actually on disk, the Neovim 0.13.0-dev runtime, and the installed server binaries). Rows marked **measured** were executed against the installed binaries, not inferred.

## How Neovim routes settings

Three facts decide every answer below.

| # | Fact | Where |
|---|---|---|
| 1 | `workspace/configuration` is answered by splitting the requested section on `.` and walking `client.settings` (case-sensitive). A missing section returns `vim.NIL` (JSON `null`). | `runtime/lua/vim/lsp/handlers.lua:210` |
| 2 | `workspace/didChangeConfiguration` is sent once, at init, and only `if next(self.settings)` — an empty `settings` table means the server never hears from the client. | `runtime/lua/vim/lsp/client.lua:629` |
| 3 | `vim.lsp.config(name, cfg)` deep-merges onto `lsp/<name>.lua` (`tbl_deep_extend('force')`): partial tables keep lspconfig's defaults, lists are replaced rather than appended. | `runtime/lua/vim/lsp.lua:361` |

Consequences:

- Keys are **nested to match the section the server asks for**, not the VS Code dotted path reversed: `typescript = { preferences = { ... } }`, but `["js/ts"] = { ... }` because that section literally contains a slash.
- "Empty table" ≠ "no settings". lspconfig already ships `settings` for `cssls`, `yamlls`, `lua_ls`, `tailwindcss` and `tsc`, so those five already receive a `didChangeConfiguration` with defaults. `html` ships `settings = {}` and `jsonls` omits the field, so neither sends one; `astro`, `marksman` and `emmet_language_server` have no `settings` at all.
- `settings` and `init_options` arrive by different routes and both are effectively fixed for the life of the client: `init_options` becomes `initializationOptions` once (`client.lua:590`); `settings` is pushed in the single init notification (only when the table is non-empty) or pulled on demand (`workspace/configuration`: per document for `cssls`/`html`/`tailwindcss`, once at init for `vtsls`, lazily for `astro`). `jsonls` reads only the pushed form, so today it hears nothing. `:LspRestart` is the reliable way to apply an edit; nothing here hot-reloads a changed `settings` table.

## Verdicts (one line each)

| Server / question | Verdict |
|---|---|
| `lua_ls` | Nothing to add, and the current block is dead weight: 2 keys duplicate `.luarc.json` (which wins over client settings) and `telemetry.enable` is not a LuaLS key at all. `runtime.path` is **not** needed — LuaLS resolves `require("config.x")` from `lua/config/x.lua` by walking parent directories. |
| `vtsls` | Keep `suggest.completeFunctionCalls` (the only non-default line). Add `preferences.preferTypeOnlyAutoImports = true` when the workspace uses `verbatimModuleSyntax`. Delete `includePackageJsonAutoImports` and both `importModuleSpecifier` lines — all three equal the schema default. |
| `astro` | One setting has parity value: `astro.suggest.completeFunctionCalls`. Everything else is either inert (`updateImportsOnFileMove` needs `willRenameFiles`, which core never sends) or mapped to "no opinion" (`importModuleSpecifier = "shortest"`). |
| `tailwindcss` | One: `tailwindCSS.classFunctions` for `cn`/`clsx`/`cva`/`twMerge` (default `[]`, so helper-wrapped classes get no completions or swatches today). Do not set `emmetCompletions` (duplicates the emmet server) or `colorDecorators = false` (empties every colour response, which the swatch layer depends on). |
| `cssls` | One: `css.lint.unknownAtRules = "ignore"`. Measured: the installed server reports all seven Tailwind v4 at-rules as Warning. |
| `html` | One, non-obvious: `html.autoClosingTags = true` hides the server's `</div>` completion, which `nvim-ts-autotag` already inserts. Measured: 1 item → 0 items after `<div>`. |
| `jsonls` | Leave it empty. Any `json.*` key you add silently switches validation **off** unless `json.validate.enable = true` is in the same table (measured). |
| `yamlls` | Nothing. `redhat.telemetry.enabled` (already in lspconfig's defaults) is never read by the server — it is a VS Code client setting. The schemastore catalog fetch is the only real cost and is worth keeping. |
| `marksman` | No LSP settings channel at all: config is TOML read at initialize. The only `initializationOptions` key is `preferredTextSyncKind` (`2` = incremental). |
| `emmet_language_server` | Nothing. `settings` is ignored; options are read from `initializationOptions` once at init. `showSuggestionsAsSnippets` only adds `kind: 15` — expansions are already snippets. |
| `tsc` (TS 7, opt-in) | Same preference as vtsls (`preferTypeOnlyAutoImports`), but it must be registered with a separate `vim.lsp.config("tsc", …)` call: putting it in `servers` would attach it to every TS buffer. `suggest.completeFunctionCalls` has no tsgo equivalent. |
| VS Code key verbatim? | Only if the *server* reads it. Client-side features (`*.updateImportsOnFileMove`, `redhat.telemetry`, `Lua.telemetry`, emmet `excludeLanguages`) do nothing over LSP. |
| Formatting settings? | No. `conform` runs with `lsp_format = "never"`, so `*.format.enable` for html/json/yaml/tsc is never exercised. |
| Inlay hints / code lens? | No. Both are per-buffer opt-in in this Neovim (`_capability.lua:246`); lua_ls `hint.enable`/`codeLens.enable` and lspconfig's `tsc` defaults configure output nobody requests. |
| Startup cost of `settings`? | Nil. Settings are tables sent after the server starts; of the per-buffer features only documentColor is enabled here (the Tailwind swatch layer), and the rest are off until asked for. |

## Evidence table

| Claim | Source | What it actually says |
|---|---|---|
| Neovim resolves a section by splitting on `.` and walking `client.settings`; missing → `vim.NIL` | `neovim/neovim` `runtime/lua/vim/lsp/handlers.lua:210-241` | `local keys = vim.split(section, '.', { plain = true }); return vim.tbl_get(table, unpack(keys))` … `if value == nil then value = vim.NIL end` |
| `didChangeConfiguration` is pushed once at init and gated on non-empty settings | `runtime/lua/vim/lsp/client.lua:629` | `if next(self.settings) then self:notify('workspace/didChangeConfiguration', { settings = self.settings }) end` |
| `vim.lsp.config` merges over the lspconfig default | `runtime/lua/vim/lsp.lua:361` | `rconfig.resolved_config = vim.tbl_deep_extend('force', self._configs['*'] or {}, rtp_config or {}, self._configs[name] or {})` |
| lspconfig ships non-empty settings for cssls | `~/.local/share/nvim/lazy/nvim-lspconfig/lsp/cssls.lua:39` | `settings = { css = { validate = true }, scss = { validate = true }, less = { validate = true } }` |
| lspconfig ships non-empty settings for yamlls (incl. the telemetry key) | same dir, `yamlls.lua:73` | `redhat = { telemetry = { enabled = false } }, yaml = { format = { enable = true } }` |
| lspconfig ships settings for lua_ls (hints/lenses) and tailwindcss (`classAttributes`, `lint`), and for `tsc` (`js/ts` hints/lenses) | `lsp/lua_ls.lua:87`, `lsp/tailwindcss.lua:90`, `lsp/tsc.lua:71` | `Lua = { codeLens = { enable = true }, hint = { enable = true, semicolon = 'Disable' } }`; `tailwindCSS = { validate = true, lint = {...}, classAttributes = {...} }`; `['js/ts'] = { inlayHints = {...}, referencesCodeLens = {...} }` |
| `html` and `jsonls` send no settings at init | `lsp/html.lua:40`, `lsp/jsonls.lua` (no `settings` field) | `settings = {}`; jsonls defines only `cmd`, `filetypes`, `init_options`, `root_markers` |
| cssls asks for a section named after the document's language id | installed `vscode-langservers-extracted/lib/css-language-server/cssServer.js:235` | `section: textDocument.languageId` |
| cssls default for unknown at-rules is Warning | `vscode-css-languageservice` `src/services/lintRules.ts:43` | `UnknownAtRules: new Rule('unknownAtRules', l10n.t("Unknown at-rule."), Warning)` |
| The at-rule data shipped with cssls has 25 entries and none of the Tailwind ones | installed `.../lib/umd/data/webCustomData.js` | `@charset … @layer @media @page @property @supports @container @scope @starting-style @view-transition` — no `@theme`, `@utility`, `@custom-variant`, `@apply`, `@tailwind`, `@source`, `@plugin` |
| **Measured**: those seven are all flagged, at severity 2 | `vscode-css-language-server` (installed 4.10.0) via `doValidation` | `Unknown at rule @theme / @utility / @apply / @plugin / @source / @custom-variant / @tailwind`, all severity 2 (Warning); 0 with `{lint:{unknownAtRules:"ignore"}}` |
| **Measured**: cssls over a real Neovim client behaves the same | `nvim --headless` + `vim.lsp.config("cssls", {...})` | default → `{"property value expected", "Unknown at rule @theme"}`; with `css.lint.unknownAtRules="ignore"` → `{"property value expected"}` |
| jsonls recomputes validation from scratch on every config push | installed `.../lib/json-language-server/jsonServer.js:263` | `validateEnabled = !!settings.json?.validate?.enable` |
| **Measured**: adding one unrelated `json.*` key turns validation off | `vscode-json-language-server` (installed), driven both by a raw LSP client and by `nvim --headless` | invalid JSON + trailing comma → 2 errors with no settings; **0 errors** with `{json={resultLimit=1000}}` (`vim.wait` timed out); 2 errors again with `validate.enable=true` added |
| html reads `html.autoClosingTags` to suppress its own closing-tag proposals | installed `.../lib/html-language-server/modes/htmlMode.js:57` | `options.hideAutoCompleteProposals = htmlSettings?.autoClosingTags === true` |
| **Measured**: that setting removes the `</div>` item | `vscode-html-language-server` (installed) | after `<div>`, no settings → `[{label:"</div>", kind:10, textEdit.newText:"$0</div>", insertTextFormat:2}]`; with `html.autoClosingTags=true` → `[]` |
| yamlls pulls `yaml`, `http`, `[yaml]`, `editor`, `files`, and never a `redhat` section | installed `yaml-language-server/out/server/src/languageserver/handlers/settingsHandlers.js:45` | `getConfiguration([{section:'yaml'},{section:'http'},{section:'[yaml]'},{section:'editor'},{section:'files'}])` |
| yamlls downloads the schemastore catalog when enabled | same file, line 207 | `if (this.yamlSettings.schemaStoreEnabled && !schemaStoreIsSet) { const schemaStore = await this.getSchemaStoreMatchingSchemas(...) }` |
| tailwind pulls exactly two sections, per URI, cached | tailwindcss-intellisense `v0.16.0` `packages/tailwindcss-language-server/src/config.ts:30` | `getConfiguration({ section: 'editor', scopeUri: uri })` and `{ section: 'tailwindCSS', scopeUri: uri }`, merged onto `getDefaultTailwindSettings()` |
| tailwind `classFunctions` defaults to empty and matches on function *names* only | `packages/tailwindcss-language-service/src/util/state.ts:193`, `README.md:101` | `classFunctions: []`; "Each entry is treated as regex pattern that matches on a function name. You *cannot* match on content before or after the function name" |
| tailwind `colorDecorators=false` empties the response rather than unregistering | `.../src/documentColorProvider.ts:22` | `if (settings.tailwindCSS.colorDecorators === false) return colors` (an empty array) |
| tailwind `emmetCompletions` is a server-side emmet expansion, off by default | `.../src/completionProvider.ts:2169` | `if (settings.tailwindCSS.emmetCompletions !== true) return null` |
| LuaLS applies client config first, then `.luarc.json` | LuaLS `a58fc7b` `script/provider/provider.lua:60` | `config.update(folder, clientConfig, rc)` |
| LuaLS ignores config keys that are not in its template | `script/config/config.lua:217-223` | `if template[fullKey] then m.setByScope(...) elseif template['Lua.' .. fullKey] ... elseif type(value) == 'table' then expand(value, fullKey)` |
| There is no `Lua.telemetry.*` key in 3.19.1 | `script/config/template.lua` (grep: no match) and `doc/en-us/config.md` (only a passing mention of the separate telemetry server) | No telemetry option is loaded, so the current `telemetry = { enable = false }` is dropped by the loader |
| LuaLS finds modules by walking parent directories, so `lua/?.lua` is implicit | `script/workspace/require-path.lua:108-122` | `repeat cutedPath = currentPath:sub(pos); head = currentPath:sub(1, pos-1) … until not pos or strict` — for `lua/config/x.lua` the `lua/` prefix yields the name `config.x` |
| **Measured**: `require("config.constants")` type-checks without `runtime.path` | LuaLS 3.19.1 `--check` on a fixture and on this repo | fixture `c.f(1)` on a `---@param s string` reports `param-type-mismatch`; `--check` on this repo reports only `assign-type-mismatch` in `config/options.lua`, no module-resolution errors |
| vtsls reads the whole settings tree at init through section `""` | vtsls `9ff4ce4` `packages/server/src/index.ts:50` | `conn.sendRequest(ConfigurationRequest.type, { items: [{ section: "" }] })` |
| vtsls sources its defaults from the bundled VS Code extension schema | `packages/service/vscode/extensions/typescript-language-features/package.json` | `typescript.preferences.importModuleSpecifier` default `shortest`; `typescript.preferences.includePackageJsonAutoImports` default `auto`; `typescript.suggest.completeFunctionCalls` default `false`; `typescript.preferences.preferTypeOnlyAutoImports` default `false` |
| `preferTypeOnlyAutoImports` reaches tsserver per document | `packages/service/vscode/extensions/typescript-language-features/src/languageFeatures/fileConfigurationManager.ts:202` | `preferTypeOnlyAutoImports: preferencesConfig.get<boolean>('preferTypeOnlyAutoImports', false)` |
| vtsls registers only the *notification* for file renames | `packages/server/src/index.ts:138` | `conn.workspace.onDidRenameFiles(service.renameFiles)` — no `onWillRenameFiles` |
| `vtsls.autoUseWorkspaceTsdk` switches to the workspace TypeScript | vtsls `README.md:15` | "To switch to the workspace version, use command `typescript.selectTypeScriptVersion` or set configuration option `vtsls.autoUseWorkspaceTsdk` to `true`" |
| Project-wide diagnostics are a second, experimental tsserver | bundled extension `package.json:1424` + `tsServer/spawner.ts:127` | `"typescript.tsserver.experimental.enableProjectDiagnostics": { "default": false, "tags": ["experimental"] }`; `return configuration.enableProjectDiagnostics;` selects the semantic server |
| Volar derives the config section from the language id | astro 2.16.14 `volar-service-typescript/lib/shared.js:7` | `getConfigTitle(document)` returns `typescript`/`javascript` for react ids, otherwise `document.languageId` |
| Volar reads `<section>.suggest.completeFunctionCalls` for `.astro` buffers | `volar-service-typescript/lib/plugins/semantic.js:286` | `getConfiguration(getConfigTitle(document) + '.suggest.completeFunctionCalls') ?? false` |
| Volar maps `importModuleSpecifier` only for non-default values | `volar-service-typescript/lib/configs/getUserPreferences.js:81` | `case 'shortest'` is absent; `default: return undefined` |
| Volar caches a `getConfiguration(section)` result (no `scopeUri`) until a `didChangeConfiguration` clears it | installed `@volar/language-server/lib/features/configurations.js:26-40` | `if (!scopeUri && didChangeConfiguration) { if (!configurations.has(section)) configurations.set(section, getConfigurationWorker(section, scopeUri)); return configurations.get(section) }`; `configurations.clear()` runs in `onDidChangeConfiguration` |
| astro accepts only three init options | installed astro 2.16.14 `dist/nodeServer.js:14-19` | `params.initializationOptions?.typescript?.tsdk` (required, or it throws); `params.initializationOptions?.contentIntellisense ?? false` |
| astro's rename-import support is gated on `willRenameFiles` | installed astro 2.16.14 `dist/plugins/typescript/index.js:22-29` | `async provideFileRenameEdits(…)` + `if (astroConfig?.updateImportsOnFileMove.enabled === false) return null` |
| emmet reads `initializationOptions` once, at init | emmet-language-server `d0ddd92` `index.ts:81` | `globalConfig = params.initializationOptions \|\| {}` (no `onDidChangeConfiguration` consumer) |
| emmet `showSuggestionsAsSnippets` changes only the item kind | README table + **measured** against 2.8.0 | default → `{label:"ul>li*2", insertTextFormat:2, detail:"Emmet Abbreviation"}`; with the flag → same plus `"kind":15` |
| marksman reads its config from TOML at initialize | marksman `5cee45b` `Marksman/Server.fs:493,554` | `tryLoadUserConfig()` reads `config.toml`; `ServerUtil.calcTextSync userConfig workspace clientDesc` runs inside `onInitialize` |
| marksman's only init option is the text-sync kind | `Marksman/State.fs:16-38` | `type InitOptions = { preferredTextSyncKind: Option<TextSync> }`; `json.SelectToken("preferredTextSyncKind")`, `2` = Incremental |
| marksman defaults to full sync | `Tests/default.marksman.toml` (`[core] text_sync = "full"`) and `Config.fs:166` | `coreTextSync = Some Full`, with the comment "Defaults to `full` because the editors have bugs in incremental sync which result in slightly correpted state" (sic) |
| tsgo pulls `js/ts`, `typescript`, `javascript`, `editor` | TypeScript native-preview `89d5d5b2` `internal/lsp/server.go:810-847` | `Section: new("js/ts")` … `configMap["js/ts"] = config` |
| tsgo supports a fixed preference list — no `suggest.completeFunctionCalls`, no `tsserver.*` | `internal/ls/lsutil/userpreferences.go` | `config:` tags are `preferences.importModuleSpecifier`, `preferences.preferTypeOnlyAutoImports`, `preferences.quoteStyle`, `preferences.jsxAttributeCompletionStyle`, `inlayHints.*`, `referencesCodeLens.*`, `implementationsCodeLens.*`, `organizeImports.*`, `validate.enabled`, `format.enabled`, `suggest.autoImports` … |
| tsgo already prefers the shortest specifier | `internal/modulespecifiers/preferences.go:221` | `relativePreference := RelativePreferenceShortest` before any preference is applied |
| Inlay hints, code lens and documentColor are opt-in per buffer | `runtime/lua/vim/lsp/_capability.lua:246` | `vim.nonnil(bufnr and vim.b[bufnr][var], vim.g[var], false)` — buffers default to disabled |
| Neovim never advertises watched-file registration on Linux | `runtime/lua/vim/lsp/protocol.lua:635` | `dynamicRegistration = sysname == 'Darwin' or sysname == 'Windows_NT'` |

## Per-server detail

### `lua_ls` — nothing to set

```lua
lua_ls = {},  -- .luarc.json is the source of truth; lspconfig's own defaults still merge in
```

- The current block sets `runtime.version`, `workspace.checkThirdParty` (both already in `.luarc.json`, which is applied *after* client settings and therefore wins) and `telemetry.enable` (not a key in 3.19.1 — `template.lua` has no telemetry entry, so `config.update` drops it). Net effect: zero.
- `runtime.path` is a myth for this layout. `require-path.lua` walks every parent prefix of the file, so `lua/config/constants.lua` is already addressable as `config.constants`. Verified by type-checking a fixture that calls a typed function with the wrong argument (`param-type-mismatch` fired) and by running `--check` over this repo (32 findings, all in `config/options.lua`, all `assign-type-mismatch` on `vim.Option`; none about module resolution).
- If you ever add a `settings` block here, remember LuaLS reads `Lua.*`, `files.associations`, `files.exclude`, `editor.semanticHighlighting.enabled` and `editor.acceptSuggestionOnEnter` (`script/config/loader.lua:90`), and that `workspace.checkThirdParty = "Ask"` opens a modal `window/showMessageRequest` the first time it detects a supported library (`script/library.lua:488`).

### `vtsls` — one keep, one add, three deletions

```lua
vtsls = {
  settings = {
    typescript = {
      -- Default is false; true turns completions for functions/methods into
      -- parameter snippets instead of bare names.
      suggest = { completeFunctionCalls = true },
      preferences = {
        -- Default is false; prevents TS1484 on auto-imported types in
        -- workspaces with `verbatimModuleSyntax` (Vite/Astro templates).
        preferTypeOnlyAutoImports = true,
      },
    },
    javascript = {
      suggest = { completeFunctionCalls = true },
    },
  },
},
```

- `includePackageJsonAutoImports = "auto"` and `importModuleSpecifier = "shortest"` (repeated in both language blocks) are the schema defaults, so they are pure noise. `importModuleSpecifier` is redundant for the same reason in `tsc` (see below).
- Do not add `vtsls.autoUseWorkspaceTsdk = true` here: vtsls needs a JS `tsserverlibrary.js`, which TypeScript 7 no longer ships — the same constraint already documented for `astro`.
- Do not add `typescript.updateImportsOnFileMove.enabled`: vtsls only registers `onDidRenameFiles`, and nothing in core Neovim emits rename notifications.
- Do not add `typescript.tsserver.experimental.enableProjectDiagnostics`: it spawns a second, semantic tsserver for unopened files (`spawner.ts:127`) and is the one setting here with a measurable cost. `maxTsServerMemory` (default 3072 MB) is not a problem worth solving pre-emptively.

### `astro` — one parity setting

```lua
astro = {
  settings = {
    -- Volar reads `<languageId>.suggest.completeFunctionCalls`; for .astro
    -- documents the section is `astro`, so this mirrors the vtsls setting.
    astro = { suggest = { completeFunctionCalls = true } },
  },
},
```

- `astro.typescript.*` does **not** exist: the section name is the language id, so keys sit directly under `astro` (`astro.preferences.*`, `astro.suggest.*`). The astro extension contributes only six settings (`language-server.ls-path`, `language-server.runtime`, `trace.server`, `content-intellisense`, `auto-import-cache.enabled`, `updateImportsOnFileMove.enabled`), so `astro.preferences.*`/`astro.suggest.*` exist only in the Volar service — code-level fact, no published schema.
- `astro.preferences.importModuleSpecifier = "shortest"` is a no-op: Volar maps only `project-relative`/`relative`/`non-relative` and returns `undefined` otherwise, which is the default anyway.
- `astro.updateImportsOnFileMove.enabled` is inert (it gates `provideFileRenameEdits`, i.e. `workspace/willRenameFiles`).
- `contentIntellisense` (init option, not `settings`) only pays off with `.astro/collections/collections.json` present, and its reload path depends on `didChangeWatchedFiles`, which this Neovim does not advertise on Linux. Skip it.
- Volar looks this up without a `scopeUri`, so the value is cached for the life of the server; only a `didChangeConfiguration` clears that cache, and Neovim sends exactly one, at init (none at all while `settings` is empty). Budget one `:LspRestart` after editing any `astro.*` key.
- `typescript.tsdk` is already resolved by lspconfig's `before_init`; do not hardcode it.

### `tailwindcss` — one setting, one hard "don't"

```lua
tailwindcss = {
  settings = {
    tailwindCSS = {
      -- Default []: without this, `cn(...)`/`clsx(...)`/`cva(...)` are opaque
      -- and get no completions, hovers, lint or colour swatches.
      classFunctions = { "cn", "clsx", "cva", "twMerge" },
    },
  },
},
```

- Entries are regexes matched against the *function name only* (`util/find.ts:186`), so `cn` covers `cn(...)` and `` cn`...` `` but not `styles.cn(...)`.
- `classAttributes` already includes `class`/`className`/`class:list`/`classList`/`ngClass`; no change needed for JSX.
- Do **not** set `colorDecorators = false`: the server keeps the capability but returns an empty list for every request, which silently kills the EOL swatch layer in `lsp.lua`.
- Do **not** set `emmetCompletions = true`: the Tailwind server would emit its own emmet expansions into JSX/HTML and you already run a dedicated emmet server.
- `experimental.configFile` is only for monorepos where auto-detection picks the wrong v4 CSS entrypoint; `lint.suggestCanonicalClasses` (Warning) is the canonical-class migration aid and is useful as-is.

### `cssls` — one setting (the noisy one)

```lua
cssls = {
  settings = {
    -- Default is Warning; the shipped at-rule data predates Tailwind v4, so
    -- every @theme/@utility/@apply/@plugin/@source/@custom-variant/@tailwind
    -- line is flagged. lspconfig's css/scss/less validate=true is kept by merge.
    css = { lint = { unknownAtRules = "ignore" } },
  },
},
```

- This is the only filetype-level diagnostics conflict in the stack: Tailwind syntax in the entry stylesheet, reported by a server that has never heard of Tailwind.
- If you ever open `.scss`/`.less` with the same directives, add `scss`/`less` siblings; the server picks the section by `document.languageId`.
- `css = { validate = false }` would silence everything, including real errors — do not.

### `html` — one setting, opposite intent

```lua
html = {
  settings = {
    -- nvim-ts-autotag already inserts `</div>`; without this the server
    -- offers a second one as a snippet completion.
    html = { autoClosingTags = true },
  },
},
```

- Measured effect after `<div>`: `[]` instead of `[{label="</div>", insertTextFormat=2}]`.
- Nothing else here is worth setting: `html.validate.scripts/styles` only gate *embedded* CSS/JS in `.html`, and the formatter is never called (`lsp_format = "never"`).

### `jsonls` — leave empty, and know why

```lua
jsonls = {},
```

If you ever do add one, the shape is `jsonls = { settings = { json = { validate = { enable = true }, … } } }` — the `validate` key is not optional.

- `jsonServer.js:263` recomputes `validateEnabled = !!settings.json?.validate?.enable` on every `didChangeConfiguration`. Today no settings are sent (lspconfig defines none), so the server keeps its `true` default. One unrelated key (e.g. `resultLimit`) flips it to `false` and every JSON/JSONC buffer goes quiet.
- Measured in real Neovim: invalid JSON with a trailing comma → `{"Value expected", "Trailing comma"}` with no settings, nothing at all with `{ json = { resultLimit = 1000 } }`, both back with `validate.enable = true` added.

### `yamlls` — nothing

```lua
yamlls = {},
```

- `redhat.telemetry.enabled` is a VS Code client setting; the server never requests a `redhat` section. lspconfig already sets it to `false`, so it is harmless but inert.
- Keep schemastore enabled: the catalog fetch is one request at start and is what makes `docker-compose.yml`, `.github/workflows/*.yml` and friends validate at all.
- `yaml.format.enable = true` is unused while conform formats, and lspconfig's `on_init` forces `documentFormattingProvider = true` regardless, so toggling it changes nothing observable.

### `marksman` — file config, one init option

```lua
marksman = {
  init_options = {
    -- 2 = incremental. With no config.toml, marksman falls back to full sync,
    -- so Neovim re-sends the whole buffer on every keystroke.
    preferredTextSyncKind = 2,
  },
},
```

- Everything else lives in `~/.config/marksman/config.toml` or a project `.marksman.toml` and is read at initialize: `markdown.file_extensions`, `title_from_heading`, `glfm_heading_ids`, `incremental_references` (experimental, default false), `[completion]`, `[code_action]`. A `settings` table here is silently ignored.
- Upstream defaults to full sync because it distrusts editors' incremental sync; Neovim's is reliable, but this is the one setting to revert if links/references start misbehaving after edits.

### `emmet_language_server` — nothing

```lua
emmet_language_server = {},
```

- `settings` is dead: only `initializationOptions` is read, once, at init (`index.ts:81`).
- `showSuggestionsAsSnippets` is cosmetic — measured: the item is already `insertTextFormat: 2`; the flag only adds `kind: 15` (snippet icon/kind in the menu).
- `excludeLanguages` is pointless here: use `filetypes` in the LSP config, as the README itself suggests for Neovim. `includeLanguages` is unnecessary because lspconfig's list already has `astro`, `javascriptreact`, `typescriptreact`, `html` and `css`.

### `tsc` (TypeScript 7 native, opt-in) — separate registration

```lua
-- Keep this OUT of the `servers` table: vim.lsp.enable() would attach it to
-- every JS/TS buffer and break one-server-per-buffer.
vim.lsp.config("tsc", {
  settings = {
    -- Literal key: the section really is "js/ts".
    ["js/ts"] = {
      preferences = { preferTypeOnlyAutoImports = true },
    },
  },
})
```

- tsgo supports `preferences.*` (import specifier, quote style, JSX attribute style, type-only auto-imports), `suggest.autoImports`, `inlayHints.*`, `referencesCodeLens.*`, `implementationsCodeLens.*`, `organizeImports.*`, `validate.enabled` and `format.enabled`. It supports **no** `tsserver.*` keys and **no** `suggest.completeFunctionCalls`, so a buffer toggled to `tsc` loses the parameter-snippet completions that vtsls gives it.
- `preferences.importModuleSpecifier = "shortest"` is redundant: `getModuleSpecifierPreferences` starts at `RelativePreferenceShortest` when no preference is set.
- `js/ts.implicitProjectConfig.*` is not read at all — the server derives everything from the project's tsconfig.
- `init_options.userPreferences` is only consulted when the client cannot answer `workspace/configuration` (`server.go:800`), so do not use it here.

## Not worth setting (and why)

| Key | Why not |
|---|---|
| `Lua.runtime.path` | LuaLS already walks parent prefixes; adding `lua/?.lua` changes nothing. Measured. |
| `Lua.telemetry.enable` | Does not exist in 3.19.1; dropped by the config loader. |
| `Lua.format.enable = false` | Formatting is never requested (`conform`, `lsp_format = "never"`); it only removes a capability nobody asks for. |
| `typescript.preferences.includePackageJsonAutoImports` | Default is `auto`; the current line is the default restated. |
| `typescript.preferences.importModuleSpecifier` (vtsls + tsc) | Default is `shortest` in both servers. |
| `typescript.updateImportsOnFileMove.enabled`, `astro.updateImportsOnFileMove.enabled` | Need `workspace/willRenameFiles`; vtsls does not even register it. |
| `redhat.telemetry.enabled` | Never read by yaml-language-server. |
| `emmet.showSuggestionsAsSnippets` | No behavioural change beyond `kind: 15`. |
| `tailwindCSS.emmetCompletions` | Duplicates the emmet server you already run. |
| `tailwindCSS.showPixelEquivalents` / `rootFontSize` | Presentation only; defaults are right. |
| `tailwindCSS.colorDecorators` | Must stay `true` — the swatch layer depends on it. |
| `html.validate.scripts` / `.styles` | Only gate embedded CSS/JS inside `.html`; nothing in this stack. |
| `*.format.enable` for html/json/yaml/tsc | LSP formatters are never invoked. |
| `inlayHints.*`, `referencesCodeLens.*`, `implementationsCodeLens.*` | Inert: those capabilities are off per buffer until enabled. |
| `yaml.schemas` for the usual suspects | schemastore already covers GitHub Actions, compose, etc.; add entries only for project-specific files. |
| `json.resultLimit` / `jsonFoldingLimit` | Only for pathological files, and they come with the `validate.enable` footgun. |

## Open questions

- **`astro.suggest.completeFunctionCalls` end-to-end.** Verified in the bundled Volar code, not in a running Astro project: confirm that `workspace/configuration` for section `astro.suggest.completeFunctionCalls` is answered by Neovim (it should be, per fact 1) and that completions inside `.astro` script blocks change shape. Requires a project with `node_modules/typescript` ≤ 6.
- **`tailwindCSS.classFunctions` coverage.** Function-name regexes were verified; not verified is whether the server also picks up classes in a `cva({ variants: { … } })` object once the function is registered (the finder looks for the call and then scans its arguments, which suggests yes).
- **`marksman` incremental sync.** `preferredTextSyncKind = 2` selects incremental, but whether marksman's incremental path is bug-free with Neovim's sync was not exercised on a large vault.
- **jsonls pull diagnostics.** The footgun is proven for the push path. If Neovim ever prefers `textDocument/diagnostic` for jsonls, re-test; the current client code path is push-only.
- **cssls at-rule data refresh.** The shipped list has no Tailwind v4 directives; whether a future `vscode-langservers-extracted` update adds them (making `unknownAtRules = "ignore"` unnecessary) is worth re-checking after an upgrade.
