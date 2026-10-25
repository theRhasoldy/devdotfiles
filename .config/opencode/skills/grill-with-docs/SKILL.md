---
name: grill-with-docs
description: >-
  Grill the user about a plan or decision, but first read the relevant docs/code
  so questions are grounded in the actual artifact. Use for 'grill with docs',
  'grill the PRD', 'grill the RFC', or when a document/codebase should inform
  the grilling.
---

# Grill with Docs

Same methodology as `grilling`, with a documentation pass first.

## Steps

1. **Identify the artifact.** Ask which file(s), PRD, RFC, or code path to
   ground on, if not already named.
2. **Read it.** Use read/grep/glob (or a sub-agent) to load the relevant
   content. Summarize what it says in 3-5 bullets and confirm with the user
   before grilling.
3. **Grill.** Apply the `grilling` methodology: design tree, frontier rounds,
   find facts yourself, decisions are the user's, don't act until confirmed.
   Ground every question in the artifact — cite the section/line when challenging
   a claim.
4. **Track gaps.** Maintain a "doc gaps" list: claims in the artifact that are
   unverified, ambiguous, or contradicted by the codebase. Surface these as
   questions.
5. **Complete** per `grilling`'s completion rules, plus a final "doc updates
   needed" list.

## Notes

- If the artifact is large, read only the sections relevant to the current
  frontier; fetch more on demand.
- Do not rewrite the artifact during grilling; only after explicit confirmation.