# Doc Types And Responsibilities

This workflow works best when each doc has one job.

## Root `AGENTS.md`

Purpose:

- define read order
- point to the canonical docs
- state repo-wide rules
- explain the planning hierarchy

Should answer:

- what should an agent read first?
- which docs win if they disagree?
- what project rules must every change obey?

## `CURRENT_STATE.md`

Purpose:

- provide a short current truth page
- describe what is built today and what is missing
- fan out to deeper docs for detail

Should answer:

- what exists right now?
- what is still missing?
- what caveats or traps matter today?
- where should I look next?

This should be updated regularly, especially after multi-task or milestone work, but it should not become a journal. Move long historical ledgers to state snapshots.

## State history

Purpose:

- preserve historical state snapshots that are too bulky for `CURRENT_STATE.md`

Should answer:

- what did the repo look like at this point in time?
- what detailed inventory was preserved before a state-doc trim or major milestone?

## `ROADMAP.md`

Purpose:

- explain sequence and product rationale
- separate the mainline from side branches and backlog

Should answer:

- what should probably happen next?
- why is one milestone ahead of another?

## `ARCHITECTURE.md`

Purpose:

- define the intended forward system shape
- explain boundaries and long-lived seams
- define durable area vocabulary and caller-facing interfaces when architecture is split

Should answer:

- what layers exist?
- what is canonical versus derived?
- which boundaries should feature work preserve?
- which interfaces create the seams future work should use?
- where is the decision provenance for major claims?

## ADR

Purpose:

- record durable cross-plan decisions, alternatives, and guardrails

Should answer:

- what decision was made?
- why did this option win?
- what alternatives were rejected?
- what future work must preserve or explicitly supersede?

## Learning record

Purpose:

- preserve durable corrected understanding with a globally unique `LRN-####` paper-trail ID
- capture surprising lessons, corrected assumptions, plan corrections, or runtime/tooling discoveries
- prevent future humans or agents from repeating the same confusion

Should answer:

- what did we learn?
- what previous assumption or confusion did this correct?
- what evidence or source supports the corrected understanding?
- where should this change future behavior?
- what questions remain unresolved?

Learning records are not session logs, ADRs, specs, or plans. If the doc mainly says what happened, use a session log. If it chooses a durable direction, use an ADR. If it defines requirements or execution scope, use a spec, plan, or brief.

## Explainer

Purpose:

- explain a concept, flow, or system path for humans
- hold small visuals, examples, and common misunderstandings
- keep `ONBOARDING.md` short while still giving deeper teaching material

Should answer:

- who should read this?
- what confusion does it resolve?
- what is the short answer?
- what mental model or visual helps?
- how does this connect to source docs or code?

Explainers use `EXPL-####` IDs when reusable teaching material needs stable links. Use a visualization pass when structure, flow, state, ownership, or behavior is clearer visually than in prose.

## Question

Purpose:

- preserve durable uncertainty with a globally unique `QST-####` paper-trail ID
- track status, ownership, links, and resolution history for questions that outgrow one local doc
- separate unresolved uncertainty from lessons learned, explainers, decisions, and TODOs

Should answer:

- what is the question?
- why does it matter?
- what do we know so far?
- what evidence, decision, or verification would answer it?
- what resolved it, if status is `answered`?

Questions are not tasks by default. Promote a question to `TODO-*` only when it needs action, ownership, verification, or closeout.

## Session log

Purpose:

- leave a short timestamped receipt for meaningful human/agent work

Should answer:

- when did important actions happen?
- what was the goal?
- what context was read?
- what changed?
- what decisions were made?
- what verification ran?
- what follow-up remains?

## Idea

Purpose:

- preserve early sparks, rambles, and possible future work before they are ready for requirements
- give fuzzy thoughts one globally unique `IDEA-####` paper-trail ID
- keep speculative material out of specs, plans, and current-state docs

Should answer:

- what is the raw thought?
- why might it matter?
- what shape could it take?
- what questions are unresolved?
- what would need to be true before promoting it to a spec, research note, ADR, or plan?

## Spec

Purpose:

- define durable requirements before implementation planning
- preserve product, technical, workflow, or architecture language before build strategy hardens it into code
- provide one globally unique `SPEC-####` paper-trail ID

Should answer:

- what should be true and why?
- what kind of spec is this: feature, bug, improvement, architecture, repo-health, or research?
- which terms, actors, lifecycle states, or ownership boundaries are canonical?
- what decisions are already locked in?
- what is explicitly not decided yet?
- where does it live in the topic-first docs tree?

## Parent `plan-*` doc

Purpose:

- define milestone intent, architecture, invariants, tasks, dependencies, and safe parallelization
- identify important domain terms and interface choices that implementation must preserve

Should answer:

- what shape should this milestone have?
- what must not regress?
- which module/API/service boundaries need a stable caller-facing contract?
- which tasks are sequential versus parallel?
- where should work be grouped or split?
- what is the plan status, creation time, and execution window?

## `impl-*` implementation brief

Purpose:

- define one bounded execution slice for an implementer or subagent

Should answer:

- what should be done next?
- which files and seams matter?
- what does this brief own?
- what verification proves it is done?
- when was the brief created and executed?

## Codebase map

Purpose:

- shorten orientation time for new agents

Should answer:

- where do the main modules live?
- what are the best entry points by task?

## Seams guide

Purpose:

- explain compatibility layers, migrations, transitional models, or boundary traps

Should answer:

- which model or repository is canonical today?
- where should new work extend the system instead of inventing a parallel seam?

## Testing guide

Purpose:

- document the real verification story

Should answer:

- what commands exist?
- what they cover well
- what still needs manual verification

## Surface-level `AGENTS.md`

Purpose:

- record local conventions for one app, service, or package

Should answer:

- which docs to read before touching this surface?
- what commands and conventions are local to this area?

## Frontmatter

New durable docs should use YAML frontmatter when useful.

Typical fields:

- `type`
- `domain`
- `status`
- `created_at`
- `updated_at`
- `actual_execution_start`
- `actual_execution_end`
- `related_specs`
- `related_adrs`
- `related_sessions`

Use exact local timestamps. Leave unknown fields blank rather than inventing metadata.
