# Tailwind v4 — resolving theme-token colours to concrete values

Research question: is there a better (or official) way to resolve Tailwind v4 design-token colours to concrete values than hand-parsing the project's CSS in `util/tailwind.lua`? Date of research: 2026-10-24. All primary-source reads done live (npm registry, raw.githubusercontent.com, api.github.com, tailwindcss.com).

## Verdicts (one line each)

| Q | Answer |
|---|--------|
| 1 | Nascent "yes but ugly". No *documented* public API resolves a colour through `:root` variables — but `tailwindcss` does export `__unstable__loadDesignSystem(css)` and `compile()` from its main entry, and they hit exactly the same wall: the design system only knows `@theme` entries, so a value of `hsl(var(--primary-500))` comes back raw (see Q4 for why that is by design). |
| 2 | No. The documentColor pipeline resolves `var()` exclusively through `state.designSystem` (`resolveVariableValue`); `:root` declarations never enter the design system, and there is no setting to change that. Open issue #1210 tracks swatches that depend on theme-variable indirection. |
| 3 | No official tool. Nothing in the Tailwind org ingests a v4 CSS entry and emits concrete colours; compiled CSS keeps `var()` chains (browser-resolved). A Node script around `__unstable__loadDesignSystem` + `compile()` is the closest official path — and it does not resolve `:root` refs either. |
| 4 | Yes, by design. `@theme inline` copies the *stored theme value* verbatim into the utility (`theme.ts: resolve()`), and that stored value may itself be `hsl(var(--primary-500))` — Tailwind never chases `var()` into the document's `:root`. |

## Evidence table

| Claim | Source URL | What it actually says |
|---|---|---|
| `tailwindcss` 4.x exports map has no documented colour-resolver API | raw.githubusercontent.com/tailwindlabs/tailwindcss v4.1.14 packages/tailwindcss/package.json | `exports` keys only: `.`, `./colors`, `./defaultTheme`, `./plugin`, `./lib/util/flattenColorPalette`, `./theme.css`, `./preflight.css`, `./utilities.css` |
| `__unstable__loadDesignSystem` exists on the main entry: signature `(css: string, opts: CompileOptions)` returning the design system from `parseCss(...)` | raw.githubusercontent.com/tailwindlabs/tailwindcss v4.1.14 packages/tailwindcss/src/index.ts | Returns the design system without generating CSS; the `__unstable__` prefix signals no stability commitment |
| `compile(css)` returns `{ build(candidates): string, buildSourceMap, sources, root, features }`; `compileAst` is the same with `build(): AstNode[]` | same file | Full surface of the public-ish compile API; neither resolves a per-token colour for `:root`-referring values |
| `designSystem.resolveThemeValue(path, forceInline?)` resolves the theme entry, not variables inside it | raw.githubusercontent.com/tailwindlabs/tailwindcss v4.1.14 packages/tailwindcss/src/design-system.ts | Implementation: `theme.resolve(null, [path], forceInline ? ThemeOptions.INLINE : ThemeOptions.NONE)` |
| `Theme.resolve()` returns the stored value (when INLINE applies) or `this.#var(themeKey)` — it never substitutes a `var()` found inside the stored value | raw.githubusercontent.com/tailwindlabs/tailwindcss v4.1.14 packages/tailwindcss/src/theme.ts | `if (options & ThemeOptions.INLINE) return value.value; return this.#var(themeKey)` |
| documentColor for v4 classes compiles the class and parses its declarations | raw.githubusercontent.com/tailwindlabs/tailwindcss-intellisense main packages/tailwindcss-language-service/src/documentColorProvider.ts | `getDocumentColors` calls `getColor(state, className)`; v4 branch: `state.designSystem.compile([className])[0]` then `getColorFromRoot` |
| `var()` substitution during colour parsing consults only the design system | raw.githubusercontent.com/tailwindlabs/tailwindcss-intellisense main packages/tailwindcss-language-service/src/util/rewriting/var-fallbacks.ts and lookup.ts | `resolveVariableValue(state.designSystem, name)` delegates to `design.resolveThemeValue?.(name, true)`; otherwise "there's no suitable replacement — return null" |
| Therefore `hsl(var(--primary-500))` where `--primary-500` lives in the document's `:root` (not in `@theme`) can never become a parseable colour, and documentColor drops it | Inference from the two source rows above (getColor -> getColorsInString -> replaceCssVarsWithFallbacks -> parseColors) | Consistent with direct measurement on server 0.16.0 |
| No setting changes this | raw.githubusercontent.com/tailwindlabs/tailwindcss-intellisense main packages/vscode-tailwindcss/package.json (contributes.configuration.properties) | Only `tailwindCSS.colorDecorators` (on/off) touches colours; `experimental.configFile`, `includeLanguages`, etc. select projects, not colour resolution |
| Open issue: swatch missing for theme-variable-backed colours | github.com/tailwindlabs/tailwindcss-intellisense/issues/1210 (2025-02-15, open, bug) | "Color swatch not showing up for variables using theme" — same var-indirection symptom |
| Open issue: theme-driven swatch gaps persist after 0.16 | github.com/tailwindlabs/tailwindcss-intellisense/issues/1565 (2026-04-10, open) | "`@theme` section gives errors for comments and lacks color swatches" |
| v0.16.0 (2026-07-17) contains no documentColor or `var()`-resolution work | api.github.com releases/tags/v0.16.0 | Notes list diagnostics, perf, cssConflict and Vue-tag fixes only |
| 0.16.0 is the latest `@tailwindcss/language-server` and `@tailwindcss/language-service` | registry.npmjs.org (dist-tags.latest = 0.16.0 for both) | Confirms the installed version is current |
| Documented `@theme inline` semantics: the utility uses "the theme variable value instead of referencing the actual theme variable" | tailwindcss.com/docs/theme (inline option note) | With the shadcn pattern the emitted utility is `hsl(var(--primary-500))` — the value itself references a `:root` var resolved only by the browser |
| Docs warn inline + variables may give "unexpected values because of how variables are resolved in CSS" | tailwindcss.com/docs/theme | Tailwind explicitly stops at the variable boundary; the browser does the rest |
| Compiled CSS always keeps the unresolved expression | `Theme.resolve()` / `Theme.resolveWith()` in src/theme.ts (both return `#var(themeKey)` or the raw stored value) | No compiler phase parses `:root` of the user stylesheet or evaluates custom properties |

## Consequences for the Lua resolver

**(a) Things that could delete or shrink `util/tailwind.lua`**

- Nothing today. No documented API, LSP setting, or release (checked through 0.16.0, 2026-07-17) resolves `@theme inline` -> `:root` chains. Two open issues (#1210, #1565) sit on exactly this gap.
- Closest official alternative if the logic ever moves out of Lua: a small Node script using `__unstable__loadDesignSystem(entryCss)` + `compile()`/`resolveThemeValue` (this is what the LSP itself does). It reliably handles the default palette and `@theme`-internal chains — the current LSP split — but for `:root`-referring values it returns the raw expression, so it cannot replace the resolver either.
- One consolidation option: make the Lua resolver own *all* `--color-*` chains and drop the LSP documentColor path. Trades ~330 lines for one coherent resolver while losing free LSP behaviour (palette defaults, refresh). Net: keep the current split (matches the AGENTS.md known-issues note).

**(b) Definitively impossible with any Tailwind-supplied code**

- Resolving values that reference custom properties declared outside `@theme`. Both Tailwind's `Theme.resolve` and the language service's `resolveVariableValue` look up the **theme map** by variable name; `:root { --primary-500: 237 45% 50% }` is never registered there. Consequence across the whole official stack: `resolveThemeValue('--color-primary-500')` returns the raw `hsl(var(--primary-500))` string, `compile()` emits it verbatim, and the LSP colour parser returns nothing.
- It will only change via a project-level convention change (put literal colour values inside `@theme` instead of `:root` + `inline` var indirection). Where a project does that, the LSP alone suffices and the resolver covers nothing — consistent with the existing ownership split.
- General ceiling: offline resolution of CSS custom properties duplicates browser behaviour (dark scopes, `light-dark()`, media overrides). The Lua module's simplifications (default palette, dark-block stripping, no `color-mix()`/`calc()`) remain an honest approximation of that, not a bug.

## Could not verify / what would settle it

- No official Tailwind-adjacent npm package outputs resolved v4 colours (two targeted npm searches surfaced only v3-era plugins; absence from searches is a coverage limit, not proof none exists).
- Not checked here: whether the shadcn CLI exports theme JSON that bypasses this entirely (a shadcn feature question, not a Tailwind API one).
- Not measured: `theme()` / `--theme()` behaviour inside the page's own CSS declarations (only utility-class colours verified).
- Watch #1210 and #1565: if either is fixed upstream, re-test `documentColor` on a shadcn-style project before deleting resolver branches.
