<!-- lean-ctx-rules -->
<!-- version: 9 -->

lean-ctx shadow mode: native read/search/shell calls auto-route to ctx_* — no tool-mapping needed.
File editing → native Edit/StrReplace (lean-ctx only handles reads).
Exclusive tools (no native trigger): ctx_compose (understand code, call first), ctx_search(action=symbol) (exact symbol), ctx_search(action=semantic) (by meaning), ctx_callgraph (callers), ctx_knowledge / ctx_session (memory).
<!-- lean-ctx-compression -->
OUTPUT STYLE: concise
- Bullet points over paragraphs
- Skip filler words and hedging ("I think", "probably", "it seems")
- 1-sentence explanations max, then code/action
- No repeating what the user said
<!-- /lean-ctx-compression -->
<!-- lean-ctx-solution -->
SOLUTION EFFICIENCY: stop at first level that applies:
skip (YAGNI) → reuse codebase → stdlib → native platform → installed dep → one-line → minimum code.
Never skip: validation, security, error handling.
<!-- /lean-ctx-solution -->
<!-- /lean-ctx-rules -->

# Workflow & Safety Rules

## Scope Control

- Only modify files directly required by the current task. If a change would touch files outside the stated scope — including refactors, cleanup, or "improvements" — list the files and the reason, then wait for approval.
- Never rename, move, or delete any file without explicit instruction.

## Planning

Before coding, choose a planning level based on scope:

- 1–2 files changed: no written plan; state the approach in one sentence and proceed.
- 3+ files changed: write a brief plan listing each file and the change; get approval before starting.
- Architectural or cross-cutting change: write a full plan with sequenced steps, risks, and rollback approach; get approval. Implement in stages, validating after each.
- When in doubt, over-plan. A wasted paragraph costs less than a wasted refactor.

## Accuracy and Sourcing

When a request depends on recency ("latest", "current", "as of now"):

- Establish the current date/time with `date -Is` and state it explicitly.
- Prefer official/primary sources (vendor docs, release notes, changelogs); record source dates when relevant.
- Verify APIs/library functions exist in the current version's docs (Context7 MCP when available) before use. If unverifiable, flag as UNCONFIRMED.
- Use web search only when it materially improves correctness (up-to-date APIs, recent advisories, release notes); prefer official docs.

## Editing Files

- Make the smallest safe change that solves the issue; prefer patch-style edits (small, reviewable diffs) over full-file rewrites.
- Preserve existing style and conventions.
- After making changes, run the project's standard checks when feasible (format, lint, test, build, typecheck).

## Secrets and Sensitive Data

- Never print secrets (tokens, private keys, credentials) to terminal output; redact sensitive strings in any displayed output.
- Do not request users paste secrets; prefer existing authenticated CLIs.
- Avoid commands that might expose secrets (e.g., dumping env vars broadly, `cat ~/.ssh/*`).

## CONTINUITY.md

Maintain `.agent/CONTINUITY.md` as the canonical state file for this workspace. Read it at the start of every turn; update only when something materially changes.
Sections:

- PLAN — current goal, acceptance criteria, next steps (written for the next session, not this one).
- DECISIONS — durable choices with brief rationale; supersede, never silently edit.
- PROGRESS — what's done, what changed mid-course, and why.
- DISCOVERIES — unexpected findings (bugs, perf tradeoffs, undocumented behavior) with evidence (test output, error messages).
- OUTCOMES — completed at task end: achieved, remaining, lessons learned.
  Anti-bloat:
- Total file under 80 lines; when a section grows past 15 lines, compress older entries into single milestone bullets.
- No raw logs, transcripts, or pasted output longer than 3 lines.

## Definition of Done

A task is done when:

- The requested change is implemented or the question answered.
- When source code changed: build attempted, linting run, and errors/warnings addressed or explicitly listed as out-of-scope.
- Tests and typecheck pass as applicable.
- Documentation updated for impacted areas.
- Impact explained: what changed, where, why; follow-ups listed if anything was intentionally left out.
- `.agent/CONTINUITY.md` updated if the change affects goal, state, or decisions.

## Knowledge Capture
When the user confirms a task was completed successfully and it involved a complex problem, debugging session, or non-obvious solution:
- Proactively suggest scribing the task/problem and its solution as an Obsidian note (problem → approach → outcome format).
- Offer to draft the note content; wait for approval before writing anywhere.
- When scribing, use the `obsidian-cli` skill (`obsidian` CLI: create/search notes) and follow `obsidian-markdown` conventions (frontmatter properties, wikilinks, callouts).

# React / TypeScript Rules

Apply these rules whenever writing or editing React/TypeScript code.

## Logic & Effects

- Default to event-driven triggers (event handlers, callbacks, subscriptions) instead of `useEffect`. Use effects only to sync with external systems outside React (DOM APIs, third-party widgets, websockets, analytics).
- Never mirror props into state or compute derivable values in `useEffect` — derive during render.
- Never chain fetch → setState in `useEffect` manually; use the project's data layer (React Query/SWR/server actions) when available.

## Control Flow

- Prefer lookup maps (`Record<K, V>` objects or `Map`) of configs/handlers/renderers over long `if-else` chains or `switch` on values.
- Use early returns/guards; keep nesting shallow.

## TypeScript

- No `any` — ever. Use precise types, generics, or `unknown` + narrowing. `any` only as a last resort in truly generic utility code, with a comment explaining why.
- No TypeScript `enum`. Use `as const` frozen objects with `typeof` / `(typeof X)[keyof typeof X]` derived types.
- Shared/reusable utility functions go into the shared utils module (e.g. `lib/utils.ts`), never duplicated inline in components.
- Use `import type` for type-only imports.

## State & Hooks

- Minimum number of states: derive what can be computed from existing state/props instead of storing it.
- Consolidate related state into a single object or custom hook; don't split one concern across many `useState` calls.
- Don't call the same hook multiple times for the same purpose — extract repeated logic into a custom hook and call it once.
- Colocate state as close to its usage as possible; lift only when sharing is required.

## UI & Styling

- Always compose UI from the project's custom components (shadcn/ui primitives) — never raw `<button>`/etc. when a component exists.
- Styling uses design tokens only: Tailwind classes backed by the theme config or shadcn tokens. No arbitrary values like `text-[10px]`, `w-[137px]` — extend the token/theme config instead.
- Variants come from `cva` (or the component library's variant API), not ad-hoc template strings.

## Clean Code (additional)

- List keys: stable IDs, never array index.
- Prefer composition (`children`, slot props) over prop drilling; Context only for genuinely global concerns (theme, auth).
- Every async/data view handles loading, error, and empty states explicitly.
- Components do one thing; split when a component exceeds ~150 lines or mixes data fetching with presentation.
- Extract reusable logic (not just JSX) into custom hooks under a hooks directory.
- Validate external data at boundaries with the project's schema lib (e.g. zod) when present.
- Memoize (`useMemo`/`useCallback`/`memo`) only for measured performance problems or referential-stability requirements — not by default.
- Name components in PascalCase, hooks with `use` prefix, files to match the exported component.
- Before creating a new component, check the project's existing convention for component files (`ComponentName.tsx` directly vs `ComponentName/index.tsx` folder style) and follow it.
