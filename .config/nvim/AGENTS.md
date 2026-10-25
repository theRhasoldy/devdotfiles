# AGENTS.md — nvim config

From-scratch Neovim config for **web work (React/TypeScript/Astro)** and **SQL**.
Replaces the old LazyVim distro config at `~/.config/nvim-lazy` (kept as reference).

## Stack

| Area | Choice | Why |
| --- | --- | --- |
| Plugin manager | `lazy.nvim` | Per-plugin lazy loading, `:Lazy profile`, lockfile |
| Editor core | individual `nvim-mini/mini.*` repos | Small, composable, no telescope/oil/heirline |
| Completion | `blink.cmp` + `supermaven-nvim` | Fast native completion, AI completions as inline ghost text |
| LSP | native `vim.lsp.config` / `vim.lsp.enable` | No lspconfig `setup()` boilerplate |
| Treesitter | `nvim-treesitter` @ `main` | tsx/astro/css/html/json/sql |
| JSX tags | `nvim-ts-autotag` | Auto-close/rename, no LSP round-trip |
| Format / lint | `conform.nvim` (prettierd) + `nvim-lint` (selene, markdownlint) + `eslint` LSP | LSP stays out of formatting; ESLint needs an LSP for code actions |
| SQL | `sqmeow.nvim` | Schema browser, in-grid editing, blink source |
| Agent | `opencode.nvim` | Chat/ask against the local opencode server |
| Git | `gitsigns.nvim` + `codediff.nvim` | signs/hunks in the buffer; real side-by-side diff review |
| Theme | `cendre` | Dark warm theme, transparent, 3 background depths |

## Layout

```
init.lua                 bootstrap: ui2, config modules, lazy.nvim
AGENTS.md                this file
.luarc.json              LuaLS runtime/library paths for this config dir
stylua.toml selene.toml  Lua formatting/linting for the config itself
neovim.yml               selene globals/standard library
lua/config/
  options.lua            vim options, leader keys, diagnostic signs
  keymaps.lua            non-plugin keymaps only
  autocmds.lua           non-plugin autocmds
  constants.lua          shared glyphs/sizes (the only place for tunables)
lua/util/                on-demand helpers (no startup side effects)
  tailwind.lua           async CSS resolver for Tailwind colours the LSP cannot see
  pick.lua               side-preview panel for mini.pick location pickers
lua/types.lua            editor-only LuaCATS classes (never required at runtime)
lua/plugins/             every file returns a lazy.nvim spec
  editor.lua             mini.ai/comment/move/pairs/surround/splitjoin/bufremove
  navigation.lua         mini.pick + mini.extra + mini.files
  ui.lua                 mini.statusline/icons/notify/clue/hipatterns
  completion.lua         blink.cmp + supermaven-nvim
  lsp.lua                nvim-lspconfig + mason + lazydev
  treesitter.lua         parsers/highlighting
  format-lint.lua        conform + nvim-lint
  sql.lua                sqmeow
  ai.lua                 opencode.nvim
  git.lua                gitsigns + codediff
  terminal.lua           tmux navigation
  colorscheme.lua        theme candidates
```

## Conventions

- **One file per concern, not per plugin.** Add a new plugin to the file whose
  concern it belongs to; create a new file only for a new concern.
- **Keys live in the plugin spec** (`keys = { ... }`) so the plugin lazy-loads on
  first use. Only non-plugin mappings go in `lua/config/keymaps.lua`.
- **Lazy-load by trigger**, never `lazy = false` unless the plugin must be active
  before the first buffer (`opts`, `keys`, `cmd`, `event`, `ft`).
- **LSP servers are an allowlist.** A server only attaches after it is named in
  `vim.lsp.enable` inside `lua/plugins/lsp.lua`; never rely on mason-lspconfig
  auto-enable, which attaches every installed binary.
- **One TypeScript server per buffer.** vtsls is the default, `tsc` (TS 7 native)
  is per-buffer opt-in and detaches vtsls for that buffer only.
- **LSP settings only where they change behaviour.** A setting earns its place
  only if the server reads it over the wire and the default is wrong for this
  stack; VS Code client-only keys, defaults restated, and features that are
  per-buffer opt-in here (inlay hints, code lens) stay out. Rationale and
  evidence per key: `docs/research/lsp-server-settings.md`.
- **No tabs**: `expandtab`, 2-space indent, no tabline plugin.
- **mini modules are standalone repos** (`nvim-mini/mini.pick`, not `mini.nvim`).
  Declare only the modules in use.
- **Comments explain why, not what.** No section labels, no restating the code
  below a comment, no file-header plugin inventories. Keep a comment only for a
  workaround, a hidden invariant, tricky math or an ordering constraint (e.g.
  why `<C-space>` is unused, why surround moved to `gs`).
- **Tunables live in `lua/config/constants.lua`.** Glyphs and sizes that you may
  want to change later (swatch glyph, diagnostic signs, mode icons, picker size) are defined
  there and required where used — never duplicated as literals. Add a value to
  that file when a new one appears; keep behaviour, priorities and timings in
  the module that uses them.
- **Type plugin options.** Every `lua/plugins/*.lua` starts with
  `---@type LazySpec`, and each non-empty `opts`/`config` uses the plugin's own
  class when it ships one (`blink.cmp.Config`, `conform.setupOpts`,
  `lazydev.Config`, `MasonLspconfigSettings`, `opencode.Opts`). The `mini.*` and
  `cendre` option shapes are declared in `lua/types.lua`. `Gitsigns.Config` is
  unusable here because it is `exact` with every field required; empty `opts = {}`
  needs no annotation (lazy types it as `PluginOpts`).
- Lua style: `stylua.toml` (2 spaces, 120 cols), `selene` (std `neovim`).
- Prefer `require("module")` inside functions over plugin globals (`MiniPick`, …)
  so selene stays clean.

## Lazy loading map (current)

| Plugin | Trigger |
| --- | --- |
| mini.ai/comment/move/pairs/surround/splitjoin, mini.animate | `VeryLazy` |
| mini.bufremove | `keys` (`<leader>bd`, `<leader>bD`) |
| mini.statusline, mini.icons | startup (first-screen correctness) |
| mini.pick, mini.extra, mini.files | `keys` (`<leader>f{f,/,b,h,r,g,d,s,k,",R}`, `<leader>g{b,c,C,h,H,m}`, `<leader>e`, `-`) |
| mini.notify, mini.clue | `VeryLazy` |
| mini.hipatterns | `BufReadPost` / `BufNewFile` |
| blink.cmp | `InsertEnter`, `CmdlineEnter` |
| supermaven-nvim | `InsertEnter` |
| nvim-lspconfig, mason-lspconfig, treesitter, nvim-ts-autotag, gitsigns | `BufReadPre` / `BufNewFile` |
| codediff | `cmd` (`:CodeDiff`), `<leader>gd`, `<leader>gD` |
| conform | `BufWritePre`, `<leader>cf`, `:ConformInfo` |
| nvim-lint | `BufReadPost` / `BufWritePost` / `InsertLeave` |
| sqmeow | `:Sqmeow`, `<leader>db` |
| opencode.nvim | `:OpenCode`, `<leader>oa/os` |
| mason | `:Mason` |
| lazydev | `ft=lua` |

LSP servers are an explicit allowlist in `lua/plugins/lsp.lua`
(`mason-lspconfig` runs with `automatic_enable = false`): `lua_ls`, `vtsls`,
`astro`, `tailwindcss`, `cssls`, `html`, `eslint`, `jsonls`, `yamlls`, `marksman`,
`emmet_language_server`, `sqls`, `postgres_lsp`. `tsc` (TypeScript 7 native) is installed but attaches
only through `:TsgoToggle` / `<leader>cT`, one buffer at a time.

## Tooling (the config repo itself)

```sh
stylua .                # format
stylua --check .        # verify formatting
selene .                # lint
```

Binaries live in `~/.local/bin` (including `delta`, configured in
`~/.config/git/config` under `[delta]`). LuaLS gets `vim.*`/plugin globals from
`.luarc.json` (static runtime paths) and, while editing Lua, from
`lazydev.nvim` once the LSP pass is configured.

## Status

- [x] Phase 1 — skeleton, raw plugin specs, lazy loading, tooling, AGENTS.md
  - startup: ~24–28 ms (`--startuptime`), zero boot errors
  - parsers installed: tsx, typescript, javascript, astro, css, html, json, yaml,
    toml, lua, vim, vimdoc, query, markdown, markdown_inline, gitcommit
  - sqmeow Rust engine installed at `~/.local/share/nvim/sqmeow/bin/sqmeow-core`
- [x] Phase 2 — per-plugin configuration (mini modules, keys, statusline, hipatterns)
  - [x] mini.ai `n_lines = 500`; comment/move/pairs/splitjoin on upstream defaults;
    mini.surround moved to the `gs` prefix (`gsa`/`gsd`/`gsr`/`gsf`/`gsF`/`gsh`)
    so plain `s` stays instant instead of waiting for a second key
  - [x] mini.bufremove: `<leader>bd` / `<leader>bD`
  - [x] mini.pick + mini.extra: 17 pickers, float sized from `constants.pick`;
    the 6 git ones live under a `<leader>g` group (`gb` branches, `gc` commits,
    `gC` commits for the current file, `gh`/`gH` unstaged/staged hunks, `gm`
    modified files) — each keeps mini.extra's own unified `<Tab>` preview, and
    choosing a commit or a modified file hands it to codediff (below)
  - [x] `codediff.nvim` for side-by-side review: `<leader>gd` opens the working
    tree, `<leader>gD` the history of the current file, and `q` closes the tab
    back to the previous one. The git pickers' `<CR>` opens the picked commit as
    `<hash>^ <hash>` — codediff rejects `<rev>^!`, and a root commit falls back
    to the empty tree — or the picked file as `--repo <root> -- <path>`, so the
    view never depends on the editor's cwd. Delta is not involved: `[delta]` in
    `~/.config/git/config` (`side-by-side`, `line-numbers`, `syntax-theme=ansi`)
    formats the git CLI only
  - [x] mini.files: `<leader>e` / `-`, yank path / OS open / dotfiles toggle, `c`/`w`/`h` bookmarks
  - [x] mini.statusline: custom active/inactive content, git branch with a `.git/HEAD` fallback for non-gitsigns buffers; the mode word is replaced by an icon from `constants.modes` (`showmode` is off so the message line does not repeat it). `laststatus = 3` means only the active content ever renders — the inactive branch is a one-line filename fallback kept for a future `laststatus = 2`
  - [x] mini.icons / mini.notify: upstream defaults
  - [x] mini.clue wired: `<Leader>`, `<LocalLeader>`, `g` (normal + visual), `z`,
    `[`, `]`, `<C-w>` triggers + find/git/buffer/code/database/opencode/splits groups
  - [x] `gs` is a clue group too (`+surround`, listed in both modes): the
    generated `gs` "Sleep" clue is filtered out, and the six surround mappings
    (`gsa`/`gsd`/`gsf`/`gsF`/`gsh`/`gsr`) appear from their mapping `desc` —
    visual mode shows the three that exist there (`gsa`/`gsf`/`gsF`)
  - [x] mini.animate: scroll only (no cursor animation), 6 ms/step capped at 120 ms; resize 60 ms
  - [x] mini.hipatterns: `#rrggbb` / `#rgb` swatches as a colored `■` block at EOL (token itself untouched)
  - [x] Tailwind class swatches: `textDocument/documentColor` from the Tailwind LSP, painted as an EOL `■` (values are the project's real theme; no palette file).
    No polling: the server registers `documentColor` dynamically only once its
    project scan can answer (measured 1.7 s in a small v4 project, 4.8 s in a
    large v3 one), and Core's `client/registerCapability` handler re-runs the
    capability's `on_attach`, which requests 1 ms later and gets a complete
    first response — there is no empty-then-fill phase to retry around. The
    style callback paints into the provider's own namespace
    (`nvim.lsp.document_color:<client id>`) because `Provider:on_win()` clears
    exactly that namespace before each repaint; painting elsewhere leaves stale
    duplicates on every edit
  - [x] Tailwind v4 `:root` tokens: `lua/util/tailwind.lua` resolves the `var()` chains the LSP refuses to compute. Split is exclusive — LSP owns every `--color-*` chain that stays inside `@theme`, the resolver owns only chains that escape to `:root`/`.dark`, so no class is painted twice.
    Monorepo-aware root resolution prefers `pnpm-workspace.yaml` so shared UI package CSS is scanned for app files; oklch conversion dropped (no `--color-*` token resolves to oklch across projects).
  - [x] diagnostics gutter signs from `constants.diagnostics` (filled MDI glyphs);
    `<leader>fd` reuses the same glyphs and severity colours (mini.extra's
    `show` is wrapped, the letter column is overlaid)
  - [x] `lua/config/constants.lua` (glyphs/sizes) and `lua/types.lua` (option classes)
  - [x] editing modules + mini.animate moved to `VeryLazy`, mini.bufremove to `keys`;
    startup dropped from ~22–30 ms to ~17–20 ms, and no per-buffer work was added.
    Verified in a real UI: modules load and `gsa`/`gc`/`gS`/pairs mappings exist after
    `VeryLazy`; `mini.bufremove` loads on the first `<leader>bd`.
- [x] Phase 3 — web LSP stack + format/lint
  - [x] explicit allowlist (mason-lspconfig `automatic_enable = false`): lua_ls,
    vtsls, astro, tailwindcss, cssls, html, jsonls, yamlls, marksman, emmet,
    sqls, postgres_lsp
  - [x] settings audit (all keys traced to server source / measured):
    `vtsls` keeps only `suggest.completeFunctionCalls` and gains
    `preferences.preferTypeOnlyAutoImports`; `astro.suggest.completeFunctionCalls`
    for parity; `tailwindCSS.classFunctions` (`cn`/`clsx`/`cva`/`twMerge`);
    `css.lint.unknownAtRules = "ignore"` (the server predates Tailwind v4);
    `html.autoClosingTags` (autotag already inserts the tag); marksman
    `preferredTextSyncKind = 2` (upstream defaults to full sync). The lua_ls
    block was removed — `.luarc.json` wins and its telemetry key does not exist
  - [x] `tsc` 7.0.2 (Mason) opt-in per buffer via `:TsgoToggle` / `<leader>cT`;
    the toggle detaches only the current buffer's client, so vtsls keeps serving
    the rest and unsaved buffers survive (no `:edit`); registered separately with
    `vim.lsp.config("tsc", …)` so it cannot auto-attach, and it reads a literal
    `["js/ts"].preferences.*` section (no `completeFunctionCalls` equivalent)
  - [x] diagnostics complete: filled MDI glyphs as signs, `severity_sort`,
    `update_in_insert = false`, bordered float with source; `<leader>cd` opens
    it, `]d`/`[d` are built in, and `<leader>fs` already lists buffer symbols
    through mini.pick (no LSP-only duplicate); `grr`/`gri` are buffer-local
    overrides that open mini.pick (query + preview) instead of Core's quickfix.
    `vim.lsp.buf.references` itself is wrapped once (in the same `config`) to
    default `context = { includeDeclaration = false }`, so the declaration does
    not appear among the usages — mini.extra passes `nil` for the context, so
    patching the request there is the only way without forking the picker; an
    explicit `{ includeDeclaration = true }` still wins. Verified: vtsls reports
    3 locations with the declaration, 2 without, 2 through the wrapper.
    The statusline reuses the same `constants.diagnostics` glyphs and prints
    `<glyph> <count>` per severity, each segment in the theme's `DiagnosticError`
    / `DiagnosticWarn` / `DiagnosticInfo` / `DiagnosticHint` colour (mini's own
    section paints one colour and prefixes a flask icon, so this is a local
    section in `ui.lua`)
  - [x] `lua/util/pick.lua`: a second float to the right of the list shows the
    highlighted entry — the list keeps its 50% column and the panel fills the
    rest. It hooks `source.show` (mini.pick redraws items on every keypress,
    cursor line = selected item) and re-renders on a scheduled callback, then
    flushes with `:redraw` because mini.pick blocks in `getcharstr()`; only the
    location pickers opt in, so `<Tab>` (mini.pick's own preview) still works
    everywhere else. The active picker's own preview comes from
    `MiniPick.get_picker_opts().source.preview` (public API, and `vim.deepcopy`
    preserves function identity) — mini.pick defaults that field to
    `default_preview`, so compare against it to keep passing
    `line_position = "center"` for location pickers.
  - [x] virtual text follows the cursor (`virtual_text.current_line = true`):
    only the cursor line carries a message, rendered by Core on `CursorHold`
    and cleared on the next `CursorMoved` — no autocmd of ours, no per-key work
  - [x] conform: prettierd (js/jsx/ts/tsx/astro/css/scss/html/json/jsonc/yaml/
    markdown/mdx), stylua (lua), shfmt (sh/bash); `<leader>cf` is global,
    format-on-save honours `vim.g.autoformat`, `lsp_format = "never"`
  - [x] nvim-lint: selene (lua) and markdownlint-cli2 (markdown) only, on
    read/write/insert-leave plus the buffer that triggered the load; ESLint moved
    to the `eslint` LSP server (below) because only an LSP can supply code actions
  - [x] ESLint through the `eslint` LSP server (`vscode-eslint`), not eslint_d:
    it resolves the working directory per package itself (lspconfig's
    `workingDirectory = { mode = "auto" }` + `workspaceFolder`), so monorepos
    and per-package eslint versions need no cwd wiring — verified in
    `eternkenz` (eslint 10) and `lavanderie` (eslint 9) from their roots. `gra`
    now lists `Fix this <rule>`, disable-for-line/file and "Fix all
    auto-fixable problems"; `:LspEslintFixAll` applies the whole file. Cost:
    ~7 s for the first JS/TS file of a project session, ~186 ms per file after
    that, versus ~160 ms for the removed eslint_d daemon
  - [x] blink.cmp (the LSP frontend, so configured here): `enter` preset (CR
    accepts, Tab only walks snippets), show → docs → hide moved to `<C-c>`
    because `<C-space>` is the tmux prefix — C-c therefore no longer cancels
    insert; no ghost text, docs on request only, signature help on `(`/`,`,
    `single` borders, kind icons from mini.icons, sources
    lsp/path/snippets/buffer, Rust fuzzy matcher
  - [x] JSX: `nvim-ts-autotag` (close, rename, `</` completion) plus treesitter
    `indentexpr` for js/jsx/ts/tsx/astro/html — the Vim runtime JS/TS indenter is
    JSX-blind and mis-indents tag bodies; other filetypes keep the runtime one
  - startup still ~17–22 ms; the LSP layer adds no per-buffer work beyond attach
- [x] Phase 4 — sqmeow SQL workflow
  - [x] sqmeow lazy-loads on `ft=sql` as well as `:Sqmeow` / `<leader>db`
  - [x] blink.cmp gains a `sqmeow` provider (module `sqmeow.completion.blink`),
    enabled only for `sql` buffers via `sources.per_filetype` (inherits defaults)
- [x] Phase 5 — supermaven-nvim + opencode.nvim
  - [x] supermaven-nvim: inline ghost text in every buffer, accept `<M-a>`,
    accept word `<M-w>`, clear `<M-e>` (the plugin's `<Tab>`/`<C-j>` defaults
    collide with blink's `enter` preset); free tier, `log_level = "off"`
  - [x] opencode.nvim: `<leader>oa` / `<leader>os`, upstream defaults
- [x] Phase 6 — theme, `:checkhealth`, `:Lazy profile` pass
  - cendre theme active (hard bg, transparent, italic virtual text off)
  - `:checkhealth` clean except terminal/tmux environment (graphics protocol, `$TERM`); luarocks disabled (`rocks.enabled = false`) since no plugin requires it
  - startup ~33 ms headless (`--startuptime`)

## Known issues

- **Tailwind swatch ownership is split by design**: the LSP resolves Tailwind
  defaults and v3 `tailwind.config` colours; `util/tailwind.lua` covers
  v4 `@theme inline { --color-x: hsl(var(--x)) }` whose raw value sits in
  `:root`. Both paint into separate namespaces, so a class must resolve in
  exactly one place. The resolver is async (never blocks a buffer load) and
  memoises per class, reads the default palette only (dark blocks skipped),
  drops alpha, and does not evaluate `color-mix()`/`calc()`. No Tailwind API
  can replace it — see `docs/research/tailwind-color-resolution.md`; behaviour
  details in `docs/research/tailwind-swatches.md`.
- **SQL treesitter parser**: `:TSInstall sql` works in this environment; no
  override applied (the registry entry was left untouched).
- **`VeryLazy` never fires headless**: `nvim --headless -c 'luafile ...'` exits
  before the `UIEnter`/`LazyDone` chain runs, so `VeryLazy` plugins stay
  unloaded in scripted runs. Verify deferred plugins in a real UI (tmux), not
  headless, and do not assert on their mappings from a headless script.
- `stylua` (2.6.0) and `selene` (0.32.0) were installed to `~/.local/bin`.
  `stylua`/`selene` are not in the repo, only their configs.
- **`astro` needs a local TypeScript ≤6.x.** `astro-ls` resolves
  `typescript.tsdk` from the workspace; TypeScript 7 dropped
  `tsserverlibrary.js`, so the client only attaches when the project has its own
  `node_modules/typescript` (the normal case). Mason's TS 7 (`tsc`) cannot serve
  astro.
- **`tailwindcss` attaches only where Tailwind resolves**: a project with
  `tailwindcss` installed (v3 config or v4 `@import "tailwindcss"`). It also
  attaches to markdown/typescript because those are in the server's own
  filetype list — that is upstream behaviour, not a config bug.
- **`tsgo` is called `tsc` here.** nvim-lspconfig deprecated the `tsgo` entry in
  favour of `tsc`, which speaks `--lsp` from TypeScript 7.0 upward; Mason's
  `@typescript/native-preview` package provides that binary.
- **mini.pick has exactly one window.** Its `<Tab>` preview replaces the list in
  the same float, so a persistent side preview must be our own float
  (`lua/util/pick.lua`). That helper mirrors the list geometry (bottom-left
  anchored, `constants.pick` width) and reads the selection back from
  `source.show` + the list cursor, which only works for pickers whose items are
  files or locations; a symbols/diagnostics picker would render
  `vim.inspect()` instead, so those keep mini.pick's own preview.
- **`codediff` downloads native binaries.** The first `:CodeDiff` fetches
  `libvscode-diff` and `codediff-watcher` into the plugin directory (needs
  `curl` and network). The diff engine is compiled, so `:Lazy clean` plus a
  reinstall means another download — no local compiler is needed.
- **`codediff` only accepts plain revisions.** `<rev>^!` fails with "Needed a
  single revision", so the commit picker passes both sides (`<hash>^ <hash>`) and
  substitutes the empty-tree hash for a root commit. Its `q` closes the view and
  returns to the previous tab, which is also what the pickers rely on after they
  hand off.
- **`jsonls` must keep an empty `settings`.** The server recomputes
  `validateEnabled = !!settings.json?.validate?.enable` on every config push, so
  adding any unrelated `json.*` key (even `resultLimit`) silently turns
  validation off for every JSON/JSONC buffer. If a key is ever needed, ship
  `json.validate.enable = true` in the same table. Same class of trap:
  `tailwindCSS.colorDecorators = false` returns empty colour lists instead of
  unregistering, which would empty the EOL swatch layer.
- **`:TsgoToggle` raced at buffer open.** Detaching vtsls before its client has
  finished initialising lets it attach afterwards, leaving both servers on the
  buffer; wait for the attach (or toggle again) before trusting the client list.
  Not yet handled programmatically.
- **A silent ESLint buffer is usually the project config, not our wiring.**
  `eternkenz` deliberately sets `@typescript-eslint/no-explicit-any = "off"` and
  ends its config chain with `eslint-config-prettier`, which disables `quotes`,
  `semi`, `indent` and `linebreak-style` — so those probes report nothing there.
  Confirm with `npx eslint --print-config <file>` (severity `0` = off) before
  suspecting the client.
- **`eslint` LSP costs ~7 s on the first file.** The server boots node, loads the
  project's config and type-aware parser on the first JS/TS buffer after start;
  later files are ~186 ms. `eslint.run = "onType"` (lspconfig default) is what
  keeps them fresh; switching it to `onSave` trades freshness for idle CPU.
  The old `eslint_d` path was ~160 ms warm with no cold start, but cannot
  provide code actions — that is the reason it was dropped.

- **Supermaven needs one-time activation.** Neither the free tier nor Pro works
  until `:SupermavenUseFree` (or the Pro login link) has been run once; the
  plugin prompts on first start and `:SupermavenStatus` shows the state. The
  client is a native binary shipped in the plugin directory.
- **Minuet's latency is structural, not tunable.** Its OpenAI-compatible backend
  only invokes the callback from curl's `on_exit`, so `stream = true` buys
  nothing: every suggestion waits for the full response. Measured against
  OpenCode Go (2026-10) that floor was ~1.5–1.9 s per request for
  `deepseek-v4.1-flash`, `glm-5.3-flash` and `mimo-v2.6-flash` alike, mostly
  time-to-first-byte — shortening `context_window`, lowering `max_tokens` or
  raising `throttle` did not move it. That is why completion moved to
  Supermaven; re-adding minuet for latency reasons will not work.
- **OpenCode Go rejects requests without `x-opencode-session`.** Its own client
  sends `ses_<64 hex>` per session; anything else gets
  `400 {"type":"error","error":{"type":"MissingSessionID", …}}`. Relevant only
  if the Go endpoint is wired up again — minuet needed a `transform` to inject
  the header. `thinking = { type = "disabled" }` is honoured there (no reasoning
  tokens); `chat_template_kwargs.thinking` is ignored.

## Do not

- Do not commit `lazy-lock.json` drift without updating it (`:Lazy sync`).
- Do not add telescope/oil/lualine/noice — the mini equivalents are the point.
- Do not add `diffview.nvim` back (last commit 2024-06); `codediff.nvim` is the
  side-by-side viewer here.
- Do not install the full `mini.nvim` repo; use module repos.
- Do not add tab-related options/plugins.
- Do not bind `<C-space>` in the editor — it is the tmux prefix. blink's
  completion chain lives on `<C-c>` for that reason.
- Do not enable two TypeScript servers on one buffer (vtsls + `tsc`), and do not
  re-enable `mason-lspconfig`'s auto-enable.
