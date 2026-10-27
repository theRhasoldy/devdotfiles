# AGENTS.md — nvim config

From-scratch Neovim config for **web work (React/TypeScript/Astro)** and **SQL**.
Replaces the old LazyVim distro config at `~/.config/nvim-lazy` (kept as reference).

## Stack

| Area | Choice | Why |
| --- | --- | --- |
| Plugin manager | `lazy.nvim` | Per-plugin lazy loading, `:Lazy profile`, lockfile |
| Editor core | individual `nvim-mini/mini.*` repos | Small, composable, no telescope/oil/heirline |
| Completion | `blink.cmp` + `supermaven-nvim` | Fast native completion, AI completions as inline ghost text (accept `<M-a>`, word `<M-w>`, clear `<M-e>`) |
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
docs/research/           measured findings behind the non-obvious settings
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
  want to change later (swatch glyph, diagnostic signs, mode icons, picker size)
  are defined there and required where used — never duplicated as literals. Add
  a value to that file when a new one appears; keep behaviour, priorities and
  timings in the module that uses them.
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

## Lazy loading

| Plugin | Trigger |
| --- | --- |
| mini.ai/comment/move/pairs/surround/splitjoin, mini.animate, mini.notify, mini.clue | `VeryLazy` |
| mini.statusline, mini.icons | startup (first-screen correctness) |
| mini.pick, mini.extra, mini.files | `keys` (`<leader>f*`, `<leader>g*`, `<leader>e`, `-`) |
| mini.bufremove | `keys` (`<leader>bd`, `<leader>bD`) |
| mini.hipatterns | `BufReadPost` / `BufNewFile` |
| blink.cmp | `InsertEnter`, `CmdlineEnter` |
| supermaven-nvim | `InsertEnter` |
| nvim-lspconfig, treesitter, mason | `BufReadPre` / `BufNewFile` |
| nvim-ts-autotag | `ft` (tag filetypes) |
| gitsigns, mason-lspconfig | `VeryLazy` |
| codediff | `cmd` (`:CodeDiff`), `<leader>gd`, `<leader>gD` |
| conform | `BufWritePre`, `<leader>cf`, `:ConformInfo` |
| nvim-lint | `BufReadPost` / `BufWritePost` / `InsertLeave` |
| sqmeow | `:Sqmeow`, `<leader>db` |
| opencode.nvim | `:OpenCode`, `<leader>oa/os` |
| mason | `:Mason` (plus `BufReadPre`: its `setup()` puts the bin dir on PATH) |
| lazydev | `ft=lua` |

## LSP

Allowlist in `lua/plugins/lsp.lua` (`mason-lspconfig` runs with
`automatic_enable = false`): `lua_ls`, `vtsls`, `astro`, `tailwindcss`, `cssls`,
`html`, `eslint`, `jsonls`, `yamlls`, `marksman`, `emmet_language_server`,
`bashls`, `fish_lsp`, `sqls`, `postgres_lsp`. The same table drives
`ensure_installed`. `tsc` (TypeScript 7 native) is installed but stays out of it
and attaches only through `:TsgoToggle` / `<leader>cT`, one buffer at a time.

Non-obvious behaviour, all set up once in the `config` of `lsp.lua`:

- `gd`/`gD`/`grt`/`grr`/`gri`/`gO` are buffer-local overrides that open the
  mini.extra LSP picker with the side preview. A lone target jumps through
  `mini.pick.default_choose` plus a tagstack entry instead of showing a one-row
  picker (mini.extra always starts one — Neovim calls `on_list` even for a
  single location). `gd` probes `textDocument/declaration` per buffer and falls
  back to definition, since vtsls advertises `declarationProvider = false`.
- `vim.lsp.buf.references` is wrapped once to default
  `context = { includeDeclaration = false }`; mini.extra passes `nil`, so
  patching the request is the only way without forking the picker.
- Hover floats (`vim.lsp.util.open_floating_preview`) get
  `conceallevel = 2` / `concealcursor = "n"`. Neovim forces the level but leaves
  the cursor line raw, which renders the `typescript` fence instead of the
  signature. `options.lua` also sets `conceallevel = 2` / `concealcursor = "nc"`
  globally so markdown reads compact.
- Diagnostics: filled MDI glyphs from `constants.diagnostics`, `severity_sort`,
  `update_in_insert = false`, bordered float. Statusline prints
  `<glyph> <count>` per severity in the theme's `Diagnostic*` colours.
- Tailwind swatches: `documentColor` results are painted as an EOL `■` into the
  provider's own namespace (`nvim.lsp.document_color:<client id>`) — that is what
  `Provider:on_win()` clears before each repaint, so painting elsewhere leaves
  stale duplicates. Core's style callback is global, so every client except
  tailwindcss is switched off in the `LspAttach` hook.

## Tooling

```sh
stylua .                # format
stylua --check .        # verify formatting
selene .                # lint
```

Binaries live in `~/.local/bin` (including `delta`, configured in
`~/.config/git/config` under `[delta]`). LuaLS gets `vim.*`/plugin globals from
`.luarc.json` (static runtime paths) and, while editing Lua, from `lazydev.nvim`.
Startup: `--startuptime` total is 26–28 ms for a plain buffer.

## Gotchas

- **`mason.nvim` must load before the first attach** — its `setup()` is what
  prepends Mason's bin dir to `PATH`. Deferring it makes every server fail with
  "command is either not installed, missing from PATH, or not executable".
- **`VeryLazy` never fires headless**: `nvim --headless -c 'luafile ...'` exits
  before the `UIEnter`/`LazyDone` chain runs, so `VeryLazy` plugins stay
  unloaded. Verify deferred plugins in a real UI (tmux), not headless, and do not
  assert on their mappings from a headless script.
- **`document_color` cannot be enabled per client.** `is_enabled` ANDs the client
  marker with a *buffer* marker that falls back to `vim.g`, and the buffer
  default is `false` — so `enable(true, { bufnr, client_id })` silently attaches
  nothing. Enable globally (that is what sets the style) and disable the clients
  you do not want.
- **`jsonls` must keep an empty `settings`.** The server recomputes
  `validateEnabled = !!settings.json?.validate?.enable` on every config push, so
  any unrelated `json.*` key silently turns validation off. Same class of trap:
  `tailwindCSS.colorDecorators = false` returns empty colour lists instead of
  unregistering, which empties the swatch layer.
- **`tsc` is TypeScript 7's server.** nvim-lspconfig deprecated the `tsgo` entry;
  Mason's `@typescript/native-preview` provides the binary. `:TsgoToggle` can
  race at buffer open — detaching vtsls before it finishes initialising lets it
  re-attach, leaving both servers on the buffer.
- **`astro` needs a local TypeScript ≤6.x.** `astro-ls` resolves
  `typescript.tsdk` from the workspace and TS 7 dropped `tsserverlibrary.js`;
  Mason's TS 7 cannot serve astro.
- **`tailwindcss` attaches only where Tailwind resolves** (v3 config or v4
  `@import "tailwindcss"`). It also attaches to markdown/typescript because
  those are in the server's own filetype list — upstream behaviour, not a bug.
- **Tailwind swatch ownership is split by design**: the LSP resolves Tailwind
  defaults and v3 `tailwind.config` colours; `util/tailwind.lua` covers v4
  `@theme inline { --color-x: hsl(var(--x)) }` whose raw value sits in `:root`.
  Both paint into separate namespaces, so a class resolves in exactly one place.
  No Tailwind API can replace the resolver — see
  `docs/research/tailwind-color-resolution.md` and `docs/research/tailwind-swatches.md`.
- **`eslint` LSP costs ~7 s on the first file** of a project session (~186 ms
  per file after), because it boots node and loads the project's type-aware
  config. A silent buffer is usually the project config (e.g.
  `eslint-config-prettier` disables `quotes`/`semi`/`indent`) — confirm with
  `npx eslint --print-config <file>` before suspecting the client. Code actions
  are why this replaced `eslint_d`.
- **mini.pick has exactly one window.** Its `<Tab>` preview replaces the list in
  the same float, so the persistent side preview is our own float
  (`lua/util/pick.lua`), fed from `source.show` + the list cursor. That only
  works for file/location pickers; symbols and diagnostics keep mini.pick's own
  preview.
- **`codediff` downloads native binaries** on first use (needs `curl` + network;
  `:Lazy clean` means downloading again). It accepts plain revisions only —
  `<rev>^!` fails, so the commit picker passes `<hash>^ <hash>` and substitutes
  the empty tree for a root commit. Its `q` returns to the previous tab, which
  the pickers rely on after handing off.
- **Supermaven needs one-time activation** (`:SupermavenUseFree` or the Pro
  login); `:SupermavenStatus` shows the state.
- **Minuet's latency is structural, not tunable** — its backend only calls back
  from curl's `on_exit`, so `stream = true` buys nothing (~1.5–1.9 s floor).
  Completion moved to Supermaven; re-adding minuet for latency will not work.
- **OpenCode Go rejects requests without `x-opencode-session`** (`400
  MissingSessionID`); its client sends `ses_<64 hex>`. Only relevant if that
  endpoint is wired up again — minuet needed a `transform` to inject it.
- Minor: `:TSInstall sql` works here with no override; `stylua` and `selene` are
  installed in `~/.local/bin` (only their configs are in the repo).

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
