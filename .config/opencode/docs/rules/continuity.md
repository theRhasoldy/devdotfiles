# CONTINUITY.md Format

`.agent/CONTINUITY.md` is the canonical workspace state file. It is exempt from scope approval — update it without asking. Create it on first material change if it doesn't exist.

Sections:

- PLAN — current goal, acceptance criteria, next steps (written for the next session, not this one).
- DECISIONS — durable choices with brief rationale; supersede, never silently edit.
- PROGRESS — what's done, what changed mid-course, and why.
- DISCOVERIES — unexpected findings (bugs, perf tradeoffs, undocumented behavior) with evidence (test output, error messages).
- OUTCOMES — completed at task end: achieved, remaining, lessons learned.

Anti-bloat:

- Total file under 80 lines; when a section grows past 15 lines, compress older entries into single milestone bullets.
- No raw logs, transcripts, or pasted output longer than 3 lines.
