---
type: spec
id: SPEC-0001
title: Stable Todo System
spec_type: improvement
domain: docs-meta
status: draft
created_at: "2026-04-25 20:18:11 JST +0900"
updated_at: "2026-04-25 20:18:11 JST +0900"
owner:
source:
  type: conversation
  link:
  notes: "User asked for a systematic todo system for AGENT-DOCS that can interact with skills, AGENTS.md, subagents, and hooks."
areas:
  - docs
  - docs-meta
related_plans:
  - PLAN-0002
related_issues: []
related_prs: []
related_adrs: []
related_sessions: []
supersedes: []
superseded_by: []
repo_state:
  based_on_commit: 66aa243b0355baa41045e6b71ece8b1c31185945
  last_reviewed_commit: 66aa243b0355baa41045e6b71ece8b1c31185945
---

# SPEC-0001 - Stable Todo System

## Summary

AGENT-DOCS needs a durable todo system that keeps Markdown docs as the source of truth while giving agents, skills, subagents, hooks, and optional GitHub mirrors a stable task contract. The system should evolve from the current checkbox-derived `docs-meta todos` view into stable IDs, explicit lifecycle states, ownership metadata, queryable generated views, and deterministic checks.

## Problem / Opportunity

- Current todos are plain Markdown checkboxes extracted by source line number.
- Line-number identity is fragile for subagent delegation, commits, PRs, and handoffs.
- Checkbox state cannot distinguish ready work, claimed work, blocked work, review, done, superseded, or delegated work.
- Existing plan and implementation brief docs already carry task refs, dependencies, owners, and safe parallelization guidance, but `docs-meta todos` does not join or validate that structure.
- AGENTS.md and skills can route behavior, but they should not become the todo database.
- Hooks and CI can make todo hygiene reliable if the checks are deterministic and not surprising.

## Goals

- Make repo-native Markdown the canonical todo source of truth.
- Give todos stable IDs that survive line movement and can appear in briefs, session logs, commits, PRs, and subagent prompts.
- Add explicit lifecycle states that support agent coordination without requiring a server.
- Let todos declare useful routing metadata such as owner, domain, skill, agent role, plan, brief, dependency, and verification where needed.
- Generate a repo-level todo view without creating a second source of truth.
- Add checks that catch stale or contradictory todo/task metadata.
- Keep the model small enough that humans will actually maintain it.

## Non-Goals

- Do not replace GitHub Issues, Projects, PRs, or external trackers.
- Do not require a database, hosted service, or proprietary protocol.
- Do not force every small checkbox to become a structured todo.
- Do not make `AGENTS.md` a large task ledger.
- Do not auto-mutate todo state from hooks in the first implementation pass.

## Users / Actors

- Human maintainers planning and reviewing repo work.
- Main agents coordinating a task or milestone.
- Subagents receiving bounded work.
- Skills that need a reliable task shape and source-of-truth convention.
- CI or hooks that verify docs/task hygiene.
- Optional GitHub issue or project mirrors.

## Current Behavior / Context

- `scripts/docs-meta todos` extracts Markdown checkboxes and reports open/done state, source, path, line, and task text.
- `scaffold/docs/TODOS.md` is generated from checkbox extraction.
- Parent plans describe implementation tasks and dependency/parallelization notes.
- Implementation briefs include `task_refs`, ownership, dependencies, parallelization, and done checklists.
- `AGENTS.md` points agents toward plans, briefs, state docs, and generated views.
- `scripts/docs-meta check` validates doc IDs, status, frontmatter contracts, and generated views, but not semantic todo consistency.

## Desired Behavior / Target State

- Todos that need durable coordination have stable IDs such as `TODO-0001`.
- Each structured todo has a lifecycle state from a small allowed set.
- Structured todos remain Markdown-readable and easy to edit in ordinary docs.
- `docs-meta` can list, filter, and generate todos by status, owner, skill, plan, brief, domain, and dependency where metadata exists.
- `docs-meta check-todos` or equivalent validation catches duplicate IDs, invalid states, invalid references, and completed work with incomplete verification.
- `AGENTS.md` remains a short router that tells agents when to consult todo views and when parent plans or briefs are authoritative.
- Hook/CI guidance uses todo checks as verification, not as hidden state-changing automation.

## Requirements

- A structured todo must be representable in Markdown without custom binary state.
- The first supported syntax must preserve ordinary Markdown checkbox readability.
- The system must support unstructured local checkboxes for small doc-local checklists.
- Structured todos must have stable IDs, status, title/task text, source path, and line in generated output.
- Structured todos should optionally support owner, skill, agent role, parent plan, implementation brief, dependencies, blockers, verification, and updated timestamp.
- Todo lifecycle states must be documented and mechanically validated.
- Generated `TODOS.md` must clearly separate structured durable todos from lightweight local checkboxes if both are shown.
- Mutation commands, if added, must be explicit and dry-run friendly where practical.
- Hooks must be documented as checks only in the first pass.

## Suggested Lifecycle

Use this lifecycle unless implementation finds a simpler equivalent:

```text
backlog -> ready -> in_progress -> review -> done
```

Additional terminal or exceptional states:

```text
blocked
superseded
archived
```

## Candidate Syntax

The exact syntax belongs to the implementation plan, but it should stay close to ordinary Markdown:

```markdown
- [ ] TODO-0001 [ready] [owner:main-agent] [skill:docs-writer] Define stable todo lifecycle states.
- [ ] TODO-0002 [blocked] [blocks:TODO-0005] [plan:PLAN-0002] Add todo validation checks.
- [x] TODO-0003 [done] [verification:tests/docs-meta-smoke.sh] Document AGENTS.md routing rules.
```

## Type-Specific Notes

### Repo Health

- Workflow/tooling impact: `scripts/docs-meta`, scaffold templates, generated views, AGENTS.md guidance, adoption checklist, and hook/CI guidance.
- Maintenance rule: structured todos are for durable coordination; ordinary checkboxes remain acceptable for local one-off checklists.
- Rollout: read/query/check support first, optional state mutation and GitHub mirroring later.

## Domain Language

- `structured todo` means a durable Markdown todo item with a stable `TODO-*` ID and validated metadata.
- `local checkbox` means an ordinary Markdown checkbox that is useful near its source doc but not stable enough for cross-session coordination.
- `claim` means an agent or human marks intent to work on a todo; it must not silently imply completion.
- `generated todo view` means `TODOS.md` or CLI output derived from source docs.
- `mirror` means optional sync to an external tracker; it is never canonical unless a future ADR says otherwise.

## Architecture / Data Implications

- `docs-meta` needs a todo parser that can preserve current checkbox extraction while adding structured todo records.
- `docs-meta` checks need a todo validation layer separate from generated-view staleness.
- Plan and implementation brief templates need stable task/todo conventions.
- AGENTS.md templates need short routing rules for todo lookup, claim/assignment discipline, and closeout.
- Hook guidance should call deterministic checks such as `scripts/docs-meta check` and `scripts/docs-meta check-todos`.

## Open Questions

- Should `TODO-*` IDs be global across the repo or scoped by plan, such as `PLAN-0002-T01`?
- Should implementation tasks in parent plans become structured todos, or should todos primarily live inside implementation briefs?
- Should `in_progress` require an owner/agent field?
- Should blocked todos require a reason and/or blocker reference?
- Should generated `TODOS.md` include local unstructured checkboxes by default or only with an option?
- Should optional GitHub issue mirroring be part of the first implementation or a later plan?
