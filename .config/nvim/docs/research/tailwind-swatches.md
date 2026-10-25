# Tailwind colour swatches in Neovim 0.13 — research

Research question: simplest reliable way to render Tailwind class-colour swatches (coloured block, token text unstyled) with mini.hipatterns on Neovim 0.13, over a mix of Tailwind v3 and v4 projects. Date of research: 2026-10-24.

## Verdict (ranked)

| # | Approach | Effort | Deps | Accurate for v3 + v4 custom colours |
|---|----------|--------|------|-------------------------------------|
| 1 | Tailwind LSP + built-in vim.lsp.document_color (Neovim 0.12/0.13) | ~10–15 lines Lua + Mason install of the server (Phase 3 anyway) | @tailwindcss/language-server (npm) | Yes — Tailwind's own resolver handles var()/hsl(var(--x))/oklch()/config |
| 2 | Keep mini.hipatterns hex + existing bundled v3 palette (current state) | 0 — already implemented (~60 lines) | none | Defaults + v3 hex only; no v4 custom colours |
| 3 | catgoose/nvim-colorizer.lua (virtualtext eol ■, bundled Tailwind data + optional LSP) | ~20 lines opts + 1 plugin | none | Bundled defaults yes; custom via LSP mode |
| 4 | Planned ~250-line module (palette data + ripgrep scan + var/hsl/oklch resolution + cache) | ~250 lines | ripgrep | Approximate; a poor re-implementation of Tailwind's compiler |

**Recommendation for this config: #1, with #2 as the no-LSP fallback.** Do not write the 250-line module. Phase 3 installs tailwindcss-language-server via Mason anyway; its `textDocument/documentColor` capability hands Neovim server-resolved RGB (oklch/hsl/var chains already converted), and Neovim's built-in `vim.lsp.document_color` module paints them with a custom EOL-swatch style in ~10 lines. mini.hipatterns keeps plain hex for buffers without the LSP.

Sketch (verify option shape at runtime — see "Could not verify"):

```lua
-- in lua/plugins/lsp.lua (or an LspAttach autocmd):
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == "tailwindcss" then
      local hipatterns = require("mini.hipatterns")
      local ns = vim.api.nvim_create_namespace("tailwind_swatch")
      vim.lsp.document_color.enable(true, { bufnr = ev.buf, client_id = ev.data.client_id }, {
        style = function(b, range, hex_code)
          vim.api.nvim_buf_set_extmark(b, ns, range.start_row, range.end_col or 0, {
            virt_text = { { "■", hipatterns.compute_hex_color_group(hex_code, "fg") } },
            virt_text_pos = "eol",
            priority = 2000,
          })
        end,
      })
    end
  end,
})
```

## Findings

### 1. mini.hipatterns has no Tailwind helper

- Fact. doc/mini-hipatterns.txt (local install at ~/.local/share/nvim/lazy/mini.hipatterns/doc/mini-hipatterns.txt) mentions Tailwind zero times. Common examples: hex colors via gen_highlighter.hex_color(), a generic "colored words" recipe (pattern %S+ plus a user-supplied name->hex table), censor, trailing whitespace, extmark_opts/virt_text customisation (what this config already uses for the EOL swatch). Any Tailwind highlighter is user-supplied Lua + user-supplied colour data.

### 2. Neovim 0.13 has built-in documentColor support

- Fact. vim.lsp.document_color exists: "provides LSP support for highlighting color references in a document. Highlighting is enabled by default" — https://neovim.io/doc/user/lsp/ (tag lsp-document_color).
- Fact. Its style option accepts 'background'|'foreground'|'virtual'|custom string|fun(bufnr, range, hex_code); a plain string becomes virtual text — an EOL ■ swatch is one small function. Source: same docs + runtime source https://fossies.org/linux/neovim/runtime/lua/vim/lsp/document_color.lua (virtual style = inline virt_text).
- Fact. The capability (textDocument/documentColor, textDocument/colorPresentation) shipped in 0.12: https://neovim.io/doc/user/news-0.12/ and PR https://github.com/neovim/neovim/pull/33440 (merged 2025-04-24).
- Fact. documentColor returns {r,g,b} floats in [0,1]; the module converts to #rrggbb hex itself (document_color.lua get_hex_code) — oklch/hsl/var conversion is outsourced to the server entirely.
- Fact. Enabled by default on LspAttach; opt out with vim.lsp.document_color.enable(false, { bufnr = ev.buf }).
- Fact (interplay). catgoose colorizer docs confirm the built-in feature works with arbitrary LSP servers and that plugins default to disabling it to avoid duplicate highlights ("Neovim built-in LSP document colors (0.12+)" section).

### 3. The Tailwind LSP exposes documentColor

- Fact. @tailwindcss/language-server implements onDocumentColor / onColorPresentation; tw.ts registers textDocument/documentColor among common capabilities: https://deepwiki.com/tailwindlabs/tailwindcss-intellisense/2.3-language-server (secondary, describing src/tw.ts 914–945).
- Fact. Live protocol log showing the server dynamically registering textDocument/documentColor: https://github.com/sublimelsp/LSP-tailwindcss/issues/29 (2021).
- Fact. The Tailwind IntelliSense maintainer has debugged VS Code documentColor requests sent to this server: https://github.com/microsoft/vscode/issues/182534 (2023) — colour decorators for utility classes in class attributes are delivered over documentColor in production.
- Inference. The server returns colours for the same class-name ranges it completes (HTML class attrs, CSS, JS template strings); v4 support is in the same server (issue https://github.com/tailwindlabs/tailwindcss-intellisense/issues/1245 shows v4 settings keys).
- Inference. Colours are returned only after the server lazily detects a Tailwind project (v4: CSS with @import "tailwindcss"/@theme; v3: tailwind.config.*) — standalone HTML outside a detected project gets none.
- Inference. No public custom request like "tailwindcss/getColor" is documented anywhere checked; the standard documentColor/colorPresentation pair is the supported surface.
- Setup: native vim.lsp.config/enable + Mason install; nvim-lspconfig ships lsp/tailwindcss.lua (https://github.com/neovim/nvim-lspconfig/blob/main/lsp/tailwindcss.lua). Already planned Phase 3.

### 4. Existing plugins and how they get colours

- brenoprata10/nvim-highlight-colors
  - Fact (README): supports hex/rgb/hsl/CSS vars/named + Tailwind; LSP support via textDocument/documentColor; render 'virtual' with virtual_symbol ■ and virtual_symbol_position 'eol' — https://github.com/brenoprata10/nvim-highlight-colors.
  - Fact (source, lua/nvim-highlight-colors/init.lua): Tailwind patterns are built in (bundled Tailwind data — cannot read project configs), and the plugin disables its own Tailwind patterns when a tailwindcss LSP client is attached: `TAILWIND = { is_enabled = options.enable_tailwind and #utils.get_lsp_clients(active_buffer_id, "tailwindcss") == 0 ... }`.
- catgoose/nvim-colorizer.lua (successor of the NvChad fork; the NvChad README currently serves the same doc)
  - Fact (README): parsers.tailwind (bundled Tailwind colour names, enable = true) AND parsers.tailwind.lsp consuming the Tailwind LSP's documentColor, with update_names feeding resolved custom colours back into the instant name-parser; display virtualtext char ■ position eol — exactly the desired swatch. https://github.com/catgoose/nvim-colorizer.lua.
- norcalli/nvim-colorizer.lua — Fact (source): current matcher options are css/names/RGB/RRGGBB/RRGGBBAA/rgb_fn/hsl_fn only; no tailwind parser in the archived repo: https://github.com/norcalli/nvim-colorizer.lua/blob/master/lua/colorizer.lua. Claims that norcalli does Tailwind are outdated.
- Ecosystem conclusion: bundled Tailwind default-palette data for instant paint, optionally corrected by the Tailwind LSP for per-project accuracy. None parse project CSS with ripgrep.

### 5. Tailwind v4 canonical machine-readable theme

- Fact. @import "tailwindcss" pulls node_modules/tailwindcss/index.css, which does @import "./theme.css" layer(theme); theme.css contains ALL --color-* vars in oklch() plus --color-black/#fff: https://tailwindcss.com/docs/theme ("Default theme variables"); verified by fetching https://unpkg.com/tailwindcss@4.1.16/theme.css and /index.css (2026-10-24). Project colours live in user @theme blocks (same page).
- Fact. Compiled output contains only used variables by default; @theme static forces all (same docs, "Generating all CSS variables"). Inference: a compiled dist/ CSS is lossy; theme.css + project @theme blocks is the true source, but both are CSS you must convert (oklch→sRGB) — that conversion in Lua is ~30+ subtle lines and gamut handling is nontrivial.
- Inference. No documented public API emits the merged resolved palette (project over defaults) as data; the playground uses internal @tailwindcss/node compile(). This absence is why the LSP is the clean machine interface.

### 6. Hex-only swatching as the simpler convention

- Fact. mini.hipatterns docs reduce the recipe to hex_color = hipatterns.gen_highlighter.hex_color(); "colored words" is a generic pattern + user table.
- Fact. nvim-highlight-colors defaults enable_tailwind = false — class-name colouring is opt-in even in a plugin built around it.
- Inference. Class-name swatching is clearly valued (three independent implementations), but every one ships a copy of the default palette — the existing config/tailwind.lua table IS the standard simplification. It gives instant default-colour swatches everywhere; the LSP adds project accuracy.

## Concrete recommendation for this config

1. Do not write the ripgrep + var()/hsl()/oklch() resolution module. Keep lua/config/tailwind.lua (v3 hex palette) and the current hipatterns setup untouched for now.
2. In Phase 3, install tailwindcss-language-server via Mason and enable natively. Built-in vim.lsp.document_color then lights up (default background style); add the ~10-line LspAttach hook (sketch above) for the EOL ■ style reusing hipatterns.compute_hex_color_group(hex, "fg").
3. Once verified in both a v3 and a v4 project, remove the hipatterns "tailwind" highlighter (generic class-token scan) to avoid double swatches; keep hex_color + shorthand for non-LSP buffers.
4. Registered fallback if the LSP route frustrates: swap the colour job to catgoose/nvim-colorizer.lua (virtualtext eol ■ + bundled tailwind + LSP). Not preferred because the config's convention is mini modules for UI.

## Verified in practice (implementation, 2026-10-24)

Rank #1 was implemented (`lua/plugins/lsp.lua`) and measured against real projects. Three findings contradict parts of the research above:

1. **`:root`-scoped custom properties are NOT resolved.** `--color-primary-500: hsl(var(--primary-500))` in `@theme inline` with `--primary-500: 237 45% 50%` in `:root` yields **no** documentColor entry (checked in `eternkenz`, and reproduced in a scratch v4 project). When both the raw value and the `--color-*` are inside `@theme`, it resolves. So a design-system palette built on `:root` tokens gets no swatches, while Tailwind defaults and v3 `tailwind.config` colours do resolve.
2. **The server registers `documentColor` dynamically** (~1.5 s after attach), not in its initialize result. Neovim only creates a capability provider for methods the client supports *at attach time*, so a plain `document_color.enable()` in `LspAttach` silently does nothing.
3. **The first response is empty** until the server finishes its workspace scan, and the built-in provider only re-requests on buffer change — swatches stay missing until the first edit unless the request is retried.

Working measurement: v3 project (`hiddkenz`) → `bg-primary` #003566, `text-secondary` #f2bc2a, `border-accent` #ff3629. v4 monorepo (`eternkenz`) → `bg-slate-800` #1d293d, `text-red-500` #fb2c36 (v4 oklch values, not the v3 hex), custom `-primary-500`/`-danger-500` → nothing. Astro `.astro` buffers work once the project is detected.

Consequence for this config: a runtime CSS-parsing module covers exactly the gap (1) leaves open — `lua/util/tailwind.lua` resolves only `--color-*` entries whose `var()` chain escapes `@theme`, and the server keeps everything it can resolve. Ownership is exclusive, so no class is painted twice. Static palette data stays deleted: it duplicates the server's defaults and goes stale between v3/v4.

Loading is asynchronous by design, so a buffer never waits on it: `rg` runs as a child process, the palette is parsed once on the event loop afterwards, and `User ThemeColorsReady` triggers a repaint (ui.lua). Measured: first call 0.06 ms, memoised lookup 0.1 µs, 202-file project ready 5.8 ms after open with a single 2.2 ms parse tick (1–3 CSS files: ~0.3 ms).

Three limits, all deliberate:

- **Dark palettes are ignored.** `.dark`, `[data-theme="dark"]` and `@media (prefers-color-scheme: dark)` blocks are skipped while scanning, so swatches show the palette's default state. Without this the last declaration in file order wins, which in `bookenz` meant `bg-primary-500` showed dark #ea580c instead of light #f97316.
- **Alpha is dropped.** `#rgba`/`#rrggbbaa` are not accepted (a theme token is opaque); `rgba()`/`hsla()` use their first three components.
- **`color-mix()`/`calc()` are not evaluated.** A value like `--color-danger-25: color-mix(in srgb, var(--color-red-500) 5%, transparent)` produces no swatch; values mixing in Tailwind's own scale (`--color-danger-500: var(--color-red-500)`) are left to the server, which resolves them.

## Could not verify (what would settle it)

- Exact vim.lsp.document_color.enable() opts nesting in the running 0.13 (:help vim.lsp.document_color.enable once on 0.13).
- Whether the Tailwind LSP returns documentColor for tsx/vue/astro buffers without classRegex/includedLanguages settings — settle by opening a real project post-Phase 3 and tracing requests; test HTML class attributes first.
- server.ts was not exhaustively searched for an undocumented custom colour request; the "no getColor" claim rests on doc/issue-level absence.
- Mason registry version of the server at install time — verify in Phase 3.
