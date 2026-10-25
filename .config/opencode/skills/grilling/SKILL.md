---
name: grilling
description: >-
  Grill the user relentlessly about a plan, decision, or idea until reaching a
  shared understanding. Use when the user wants to stress-test their thinking,
  or uses any 'grill' trigger phrase (grill, grill me, grill this, stress-test,
  challenge my plan, poke holes).
---

# Grilling

Interview the user relentlessly until you reach a shared understanding. Model
the topic as a **design tree**: every decision branches into the decisions that
hang off it.

## Method

1. **Seed the tree.** Restate the topic in one sentence and list the
   top-level decisions you see. Confirm with the user before grilling.
2. **Work the frontier.** The frontier is every decision whose prerequisites
   are already settled — questions you can ask now without guessing at answers
   you haven't heard. Ask the whole frontier in one round.
3. **Format a round** (see template below): number each question, give a
   recommended answer. Wait for the user's answers before the next round.
4. **Reshape after answers.** Settled decisions push the frontier outward and
   unblock downstream questions. Recompute; ask the next round. A question
   whose answer depends on another still-open question belongs to a later round.
5. **Find facts yourself.** When a frontier question needs a fact from the
   environment (filesystem, tools, docs), dispatch a sub-agent to find it; never
   ask the user for something you could look up. A running exploration is an
   unsettled prerequisite — only downstream questions wait; ask the rest now.
6. **Decisions are the user's.** Put each to them and wait. Do not decide for
   them; recommend, don't impose.
7. **Stop conditions.** A round with an empty frontier means done — but also
   stop early if the user says "enough", "that's all", or "let's move on".
8. **Do not act** on the topic until the user confirms shared understanding.

## Round template

```
❓ **Q1** - **<question title>**: <question body, may be multiple paragraphs, including choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body>

➡️ <your recommended answer>
```

Rules for a round:
- One topic per question; keep each question self-contained.
- Always give a recommended answer (even if tentative) — never leave it blank.
- Group related choices as A/B/C when it helps.
- If a question needs a fact you're still fetching, mark it "pending fact" and
  skip it this round.

## Handling answers

- **"I don't know" / "you decide"** — propose a default with rationale, ask
  them to accept or override. Don't silently pick.
- **Vague answer** — restate your interpretation and confirm before moving on.
- **Contradiction with an earlier answer** — flag it explicitly and resolve
  before continuing.
- **New branch introduced** — add it to the tree and revisit the frontier.
- **Scope creep** — note it, park it in an "out of scope" list, stay on the
  current branch.

## Fact-finding

- Dispatch sub-agents (explore/research) for environment facts; don't block the
  whole round on them.
- Cite the source (file path, URL, command output) for every fact you assert.
- If a fact can't be found, say so and turn it into a decision or an
  assumption the user must accept.

## Completion

When the frontier is empty (or the user stops early):

1. Summarize: settled decisions, parked/out-of-scope items, open assumptions.
2. List what would change if any assumption turns out wrong.
3. Ask: "Shared understanding reached — proceed, or keep grilling?"
4. Only act (write code, plan, commit) after explicit confirmation.

## Anti-patterns

- Don't ask questions whose answers you can find yourself.
- Don't ask more than one round's worth at a time.
- Don't re-ask a settled question.
- Don't pad with strawman options you'd never recommend.
- Don't end without a summary.