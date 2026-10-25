---
name: scribe
description: Scribe a note into the user's Obsidian vault at ~/Documents/mind using its property framework (up, kind, status, created) and wire it into the right topic hub. Use when the user says "scribe", "add this to my vault", "save to Obsidian", "write this into mind", or asks to capture/plan/document a thought, feature, fix, session, or source.
---

# Scribe — write a note into the mind vault

Vault root: `/home/rhasoldy/Documents/mind`

The vault is link-first: five broad folders hold the note *form*, and the hubs in `00 Atlas` are the real structure. There is **no `type` and no `category` property** — do not add them. A note's domain comes from the `up` chain.

## Hard rules

- Never touch files outside the vault.
- Never overwrite an existing note. If the title exists, ask the user.
- Every new note gets `created: <today YYYY-MM-DD>`.
- Exception: dated notes use their title date — `2026-10-20.md` → `2026-10-20`, `2026-W43.md` → that ISO week's Monday, `2026.md` → `2026-01-01`.
- `kind` and `status` only on **work notes** (built, fixed, shipped, investigated). Knowledge/reference/source notes omit both.
- Allowed properties: `up`, `kind`, `status`, `created`, plus optional `src` (external URL on a literature note), `links` (issue references), `aliases` (alternate titles). Do not invent other properties.
- YAML wikilinks are quoted: `"[[Title]]"`; multiple parents are a YAML list.
- Reuse **exact** existing link text. Many filenames start with a Nerd Font icon (e.g. `󰩹 Brain Dump`, ` Home.canvas`), so find the file and copy its exact name — never reconstruct an icon.
- **Verify every `up` target exists.** If it does not, use the nearest existing hub or create a stub (step 6) — never leave a dangling parent link.
- Never invent hubs silently. If nothing fits, ask or create a stub hub (step 6).

## 1. Route to a folder

| The note is… | Folder |
|---|---|
| A map of content / hub for a topic | `00 Atlas` |
| A fleeting thought, idea, lesson, how-to, opinion, rant | `01 Cards` |
| A literature note from an external source (book, article, video, podcast, docs) | `02 Sources` |
| A life area page (Health, Job, Learn, Relationships, School, Self) | `00 Atlas` |
| A project, issue, session, or work artifact | `03 Calendars/Projects` |
| A daily/weekly log | `03 Calendars/Logs/<Year>/` |
| A template | `04 Extras/Templates` |

Default when uncertain: `01 Cards`.

Logs follow the current convention: `03 Calendars/Logs/2026/2026-10-20.md`.

File naming: sentence case, no trailing punctuation, match the user's phrasing (e.g. `Implementing Protected Routes in Next JS App Router.md`).

## 2. Frontmatter

```yaml
---
up:
  - "[[Next JS]]"
kind: fix
status: active
created: 2026-10-20
---
```

### `up` — the parent topic (also the domain)

Point at the **most specific existing hub or hub**, not the folder:

- React hooks note → `"[[React Hooks]]"` (if it exists), else `"[[React]]"`
- Next.js error → `"[[Next JS]]"`
- a life/opinion thought → `"[[󰩹 Brain Dump]]"`
- fallback when nothing fits → `"[[󰩹 Brain Dump]]"`

Multiple parents are fine when the note genuinely belongs to two topics:

```yaml
up:
  - "[[React]]"
  - "[[MPA vs SPA]]"
```

### `kind` — commit-style work intent (work notes only)

| kind | use when | git analogue |
|---|---|---|
| `feature` | building/planning new functionality or a product | `feat` |
| `fix` | resolving a bug or error | `fix` |
| `debug` | postmortem of a hard-to-debug problem (symptoms, dead ends, root cause) | — |
| `refactor` | restructuring without behavior change | `refactor` |
| `build` | build/deploy/infra work | `build` |
| `chore` | tooling, config, maintenance, upgrades | `chore` |
| `docs` | documentation, diagrams, session/talk content | `docs` |
| `perf` | performance work | `perf` |
| `test` | testing work | `test` |
| `research` | spike/exploration before work starts | — |

Decision rules:

- "Fixing / solving / error with X" → `fix`
- "Implementing / building / adding X" → `feature`
- "I've been stuck on this for hours" → new `debug` note about the struggle; the eventual resolution note is `fix`
- "Setting up / upgrading / config" → `chore` (or `build` if deployment/CI)

### `status` — work lifecycle (work notes only)

`idea` → `active` → `stuck` | `blocked` → `done` | `dropped`

- `idea` — captured, not started
- `active` — being executed right now
- `stuck` — technically struggling / don't know how yet
- `blocked` — waiting on someone/something external
- `done` — shipped or closed
- `dropped` — abandoned deliberately

Set `status: idea` for plans and `active` for work being executed. Update it whenever the user reports a change (step 7). Omit the property entirely when the work state is unknown.

## 3. Write the body

- Preserve the user's content and intent; do not embellish.
- Project/issue notes start with a short `#` heading or the relevant section.
- Use `##` sections when the content has clear parts.
- Include code blocks and links exactly as given.

## 4. Create the file

Write to `<folder>/<Title>.md`, then continue to step 5.

## 5. Wire it into the topic graph

1. Find the parent hub/hub named in `up` (exact filename).
2. Add a bullet `- [[<Title>]]` under the most fitting section heading; create the heading if missing, matching the hub's style (`# Concepts` is the common default).
3. If the parent is a hub note (e.g. `React`), link back from it too, so the graph is bidirectional.
4. If the note is a work note, also link it under its project note when one exists (e.g. `Lavanderie`, `Dsquares Design System`).

## 6. When the parent topic has no hub

Create a stub in `00 Atlas`:

```markdown
---
up: "[[ Home.canvas| Home]]"
created: <today>
---

# Concepts

- [[<New Note>]]
```

Use the exact `Home.canvas` link text from an existing hub. Then link the new hub from `[[󰩹 Brain Dump]]` or the closest parent topic.

## 7. Maintain status

When the user says a note/project is stuck, blocked, done, dropped, or active again:

1. Locate that note (search by title and `up` references).
2. Update only its `status` property with the Edit tool.
3. If they describe the struggle, also scribe a child `debug`/`fix` note with `up: "[[<That Note>]]"`.
4. Never change other properties while doing this.

Examples:

- "I'm stuck on the websocket reconnect bug" → set the feature/issue note to `status: stuck`, scribe a `kind: debug` note linked up to it.
- "the export task is done" → set it to `status: done`.

## 8. Report back

One short block:

```
Created: 01 Cards/Fixing X Error.md
up: [[Next JS]] · kind: fix · status: done
Linked into: [[Next JS]], [[󰑣 Development]]
```

Do not paste the whole note back.

## Examples

**"Scribe that I finally fixed the CSP error on the dashboard"**
→ `01 Cards/Fixing CSP Error on Dashboard.md`, `up: "[[Next JS]]"` (or the closest hub), `kind: fix`, `status: done`, bullet added to the hub.

**"Plan a new feature for exporting gamification as a module"**
→ `03 Calendars/Projects/Exporting Gamification Module.md`, `up: "[[Exporting Gamification as A Module]]"` or the owning project, `kind: feature`, `status: idea`, linked from the project note.

**"I've been debugging this hydration mismatch for 3 hours"**
→ `01 Cards/Debugging Hydration Mismatch.md`, `up: "[[Next JS]]"`, `kind: debug`, `status: stuck`, plus set any related feature note to `stuck`.

**"Scribe notes from this article on Btrfs snapshots"**
→ `02 Sources/Btrfs Snapshots.md`, `up: "[[ Linux]]"`, `src: <url>`, **no kind/status**.

**"Scribe my day"**
→ `03 Calendars/Logs/2026/2026-10-20.md`, `created: 2026-10-20`, no `up`, no `kind`, no `status`.
