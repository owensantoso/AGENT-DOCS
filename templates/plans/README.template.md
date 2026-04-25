# Planning Docs Guide

This repo uses specs, plans, and implementation briefs on purpose.

Starter templates live here:

- `docs/SPECS.md` and the repo's spec template
- `docs/plans/templates/plan-template.md`
- `docs/plans/templates/implementation-brief-template.md`

Reusable implementation-session handoff prompt:

- `docs/plans/reusable-implementer-handoff-prompt.md`

If this repo has `scripts/docs-meta`, use it for mechanical metadata:

```bash
scripts/docs-meta next spec
scripts/docs-meta next plan
scripts/docs-meta next impl --plan PLAN-0000
scripts/docs-meta new spec "<title>" --domain product --spec-type feature
scripts/docs-meta new plan "<title>" --domain product --spec SPEC-0000
scripts/docs-meta new impl "<title>" --plan PLAN-0000
scripts/docs-meta set-status PLAN-0000 in_progress
scripts/docs-meta todos
scripts/docs-meta update
scripts/docs-meta check
```

Do not ask agents to guess the next ID when the repo can derive it.

## Topic-first planning

Plans should live under the topic/domain that owns the work:

- `product/plans/` - user-facing product capability
- `repo-health/plans/` - docs, workflow, CI, test hygiene, maintainability
- `research/` - feasibility studies and spikes
- `operations/` - release, production, App Store, or manual operational work
- `marketing/` - launch and growth planning

Each meaningful plan should get its own folder:

```text
<domain>/plans/<plan-slug>/
  plan.md
  impl-task-<task-ref>-<slug>.md
```

Use the old flat file convention only when the repo intentionally chooses simpler docs.

## Source-of-truth stack

Use this hierarchy:

```text
SPEC -> PLAN -> IMPL -> Issues / PRs
```

- `SPEC` owns durable requirements and language: what should be true and why.
- `PLAN` owns intent, architecture, scope, sequencing, dependencies, and validation strategy.
- `IMPL` owns bounded execution detail for one task or grouped slice.
- GitHub issues track approved work. They should link to specs, plans, and implementation briefs rather than replace them.
- PRs deliver one reviewable change and link back to the relevant issue/docs.

## ID and filename conventions

Use independent IDs for specs and plans. Do not force plan numbers to match spec numbers.

```text
SPEC-0001
PLAN-0001
IMPL-0001-01
```

Recommended paths:

```text
docs/<domain>/specs/SPEC-0001-<slug>.md
docs/<domain>/plans/PLAN-0001-<slug>/plan.md
docs/<domain>/plans/PLAN-0001-<slug>/IMPL-0001-01-<slug>.md
```

Relationships belong in frontmatter:

```yaml
related_specs:
  - SPEC-0001
parent_plan: PLAN-0001
```

This keeps filenames readable while still supporting one-to-one, one-to-many, many-to-one, and no-spec plans.

## Status and todos

Canonical status lives in frontmatter:

```yaml
status: draft
```

Allowed common statuses:

```text
draft
proposed
ready
in_progress
blocked
completed
implemented
superseded
```

Use Markdown checkboxes for local task lists. `docs-meta todos` can derive a repo-level task view without making a second source of truth.

## The planning layers

### 1. Specs

Specs define durable requirements before implementation planning. They may describe features, bugs, improvements, architecture, repo-health work, or research-backed decisions.

They define:

- the user/system/workflow problem
- goals and non-goals
- user stories, primary flows, bug evidence, or improvement target shape
- requirements and edge behavior
- open questions
- architecture or data implications
- test expectations

They should answer:

> What should be true, for whom, and why?

They should not define task sequencing or become a pseudo-plan.

### 2. Architecture or milestone plans

These are the main plan docs.

They define:

- the goal of a milestone or phase
- architectural boundaries
- sequencing
- task dependencies and safe parallelization opportunities
- invariants
- non-goals or out-of-scope work
- the review standard for the work

They should answer:

> What are we trying to achieve, what shape should the solution have, and what must not be violated while we do it?

They should not try to fully pre-author every code edit or turn into a pseudo-patch.

### 3. Implementation briefs

Files named like:

```text
impl-task-<task-ref>-<slug>.md
```

These are execution docs for one bounded task or grouped task.

They define:

- exact task scope
- explicit dependencies and parallelization notes
- files likely to change
- concrete execution steps
- verification commands
- edge cases and traps
- handoff notes useful to a smaller model or subagent

They should answer:

> For this bounded task, what should the implementer do next, in what order, and how do we know it is done?

## Relationship between the two

The important rule is:

> The spec defines requirements truth. The main `plan-*` doc defines intent and boundaries. The `impl-*` brief defines execution details for one bounded slice.

If both exist:

- spec wins on requirements, user promises, bug expectations, and target behavior
- plan wins on product intent, scope, architecture, and non-goals
- implementation brief wins on execution order and verification details

If they disagree, update the lower-level artifact or explicitly revise the higher-level source of truth.

Never implement from an `impl-*` brief alone if the parent plan exists and has not been read.

## When to create an implementation brief

Create one when:

- a task is large enough that execution order matters
- a subagent or smaller model could implement it independently
- the main plan would become noisy if it included all the detail
- the work has tricky verification or migration steps
- resumability across sessions or worktrees would help

Do not create implementation briefs for every tiny task by default.

## Recommended structure

### Frontmatter

New parent plans and implementation briefs should start with YAML frontmatter.

Use frontmatter for metadata that future tools or Obsidian-style workflows may query:

- `type`: `plan` or `implementation-brief`
- `domain`: `product`, `repo-health`, `research`, `operations`, or `marketing`
- `status`: `draft`, `ready`, `in-progress`, `blocked`, `completed`, `superseded`, or `archived`
- `created_at`: exact local creation timestamp
- `updated_at`: exact local last meaningful update timestamp
- `planned_execution_start` / `planned_execution_end`: intended execution window, if known
- `actual_execution_start` / `actual_execution_end`: filled when execution actually begins/finishes
- `related_specs`, `related_adrs`, `related_sessions`: links to source docs and receipts

For implementation briefs, also include:

- `parent_plan`
- `task_refs`
- `depends_on`
- `parallel_with`

Leave unknown fields blank rather than inventing dates or links.

### GitHub issues

When GitHub issues are used:

- parent issues usually track a parent plan or approved work package
- sub-issues usually track implementation briefs or independently grabbable slices
- decision sub-issues track unresolved choices
- investigation sub-issues track ambiguity reduction
- issues should link to the source docs in a paper trail

Do not make issues the only memory system when specs, plans, or implementation briefs exist.

### Main plan

Recommended sections:

- Goal
- Architecture
- Prerequisites
- Why now
- Product decisions
- Design rules or invariants
- Task dependencies and parallelization
- Out of scope
- File structure
- Implementation tasks
- Validation
- Completion criteria

### Implementation brief

Recommended sections:

- Parent plan
- Task goal
- Scope and non-goals
- Ownership
- Preserve
- Dependencies and parallelization
- Entry point
- Files to read first
- Files likely to change
- Execution steps
- Verification
- Risks and traps
- Review focus
- Done checklist

## Naming conventions

Folder-based plan:

```text
<domain>/plans/<plan-slug>/plan.md
```

Implementation briefs:

```text
<domain>/plans/<plan-slug>/impl-task-<task-ref>-<slug>.md
```

Use `<task-ref>` to mirror the parent-plan task numbers:

- single task: `2`
- contiguous range: `1-3`
- explicit grouped list: `1-2-and-4`

## Grouping guidance

Group tasks into one brief when:

- they share one seam or hot file set
- they should land together to avoid churn
- they have one verification bundle
- splitting them would create a temporary invalid state

Split tasks when:

- ownership is disjoint
- they can run in parallel
- they have different verification paths
- combining them would make the brief vague or conflict-prone
