<!-- lean-ctx-rules -->
<!-- version: 11 -->

lean-ctx shadow mode: native read/search/shell calls auto-route to ctx_* — no tool-mapping needed.
File editing → the host's native edit tool (lean-ctx only handles reads).
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

# OpenCode Global Config Workspace

Global OpenCode configuration (agents, plugins, skills, MCP servers) — changes here affect every project.
Package manager: npm (`package.json` → `@opencode-ai/plugin`).
Apply changes with `opencode reload`; talk to the running server via `opencode api …`.

## Scope Control

- Only modify files directly required by the current task. Out-of-scope changes (refactors, cleanup, "improvements") → list files + reason, wait for approval.
- Never rename, move, or delete any file without explicit instruction.
- Exception: `.agent/CONTINUITY.md` is a sanctioned state file — update without extra approval.

## Planning

- 1–2 files changed: one-sentence approach, proceed.
- 3+ files: brief plan (file + change each), get approval.
- Architectural/cross-cutting: full plan — sequenced steps, risks, rollback; approval; implement in stages.
- When in doubt, over-plan. A wasted paragraph costs less than a wasted refactor.
- New feature → read [docs/rules/planning.md](/home/rhasoldy/.config/opencode/docs/rules/planning.md) first (goal, steelman, alignment verdict).
- Plans are documents: the concise-chat style governs replies, not plan content.

## Editing Files

- Smallest safe change; patch-style edits over full-file rewrites; preserve existing style and conventions.
- After changes, run the project's standard checks when feasible (format, lint, test, build, typecheck).

## Comments

- No redundant comments — don't restate what the code already says.
- No comments on self-explanatory code blocks (obvious loops, getters, simple conditionals).
- Comment only non-obvious logic that a developer unfamiliar with the codebase would struggle to follow: why a workaround exists, hidden invariants, tricky math, unusual ordering. Explain *why*, not *what*.

## Secrets

- Never print secrets; redact sensitive strings in output.
- Don't ask users to paste secrets; prefer authenticated CLIs; avoid secret-exposing commands (broad env dumps, `cat ~/.ssh/*`).

## State

- If `.agent/CONTINUITY.md` exists, read it at the start of every turn; update when something materially changes. Format: [docs/rules/continuity.md](/home/rhasoldy/.config/opencode/docs/rules/continuity.md).

## Load on trigger

- React/TypeScript work (.ts/.tsx/.jsx) → first read [docs/rules/react-typescript.md](/home/rhasoldy/.config/opencode/docs/rules/react-typescript.md)
- Recency-dependent request ("latest", "current", "as of now") → read [docs/rules/accuracy-sourcing.md](/home/rhasoldy/.config/opencode/docs/rules/accuracy-sourcing.md)
- Task confirmed complete + complex/non-obvious → read [docs/rules/knowledge-capture.md](/home/rhasoldy/.config/opencode/docs/rules/knowledge-capture.md)

## Definition of Done

- Requested change implemented or question answered.
- Checks run (build, lint, tests, typecheck) and passing, or deviations listed as out-of-scope.
- Documentation updated for impacted areas.
- Impact explained: what changed, where, why; follow-ups listed.
- `.agent/CONTINUITY.md` updated if state or decisions changed.
