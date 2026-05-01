---
name: structured-docs-workflow
description: Use when working with AGENT-DOCS structured repository docs, including doc-type selection, read order, plans versus implementation briefs, structured TODO-* items, and docs-meta workflows.
---

# Structured Docs Workflow

Use this skill when the task is about how AGENT-DOCS structured docs fit together or how to use them safely in a repo.

This skill is a router and quick-start guide. The source of truth still lives in the repo docs and `scripts/docs-meta`.

## Fast Path

If you are implementing:

1. read `docs/orientation/CURRENT_STATE.md`
2. read the parent `PLAN-*`
3. read the relevant `IMPL-*`
4. read the testing guide and any surface `AGENTS.md`
5. use this skill when you need to choose or update the right structured docs

If you are planning or drafting docs:

1. use this skill first
2. choose the owning doc type
3. use `scripts/docs-meta` for IDs, status, and generated views

If you are adopting the workflow in another repo:

1. go to `INSTALL.md`
2. copy the scaffold and `scaffold/skills/structured-docs-workflow/SKILL.md`
3. adapt placeholders before handoff

## Use This For

- booting a fresh implementation session in a repo that uses AGENT-DOCS
- choosing which durable doc type to create or update
- deciding whether work belongs in an idea, spec, plan, implementation brief, ADR, session log, learning, explainer, or question
- understanding the read order for a fresh agent
- using structured `TODO-*` items
- using `scripts/docs-meta` for IDs, status, generated views, todo checks, and link checks
- using `scripts/docs-meta review` to find audit findings, routed follow-ups, stale docs, and TODOs needing attention
- explaining the workflow to another agent or installing it into another repo

## Start Here

Read these in order when you need the full workflow:

1. `README.md`
2. `INSTALL.md` when the task is about adopting this workflow in another repo
3. `guides/workflow-overview.md`
4. `guides/doc-types-and-responsibilities.md`
5. `scaffold/docs/product/plans/README.md`
6. `scripts/README.md`

## Which Doc Owns What

- `docs/orientation/CURRENT_STATE.md`: what is true now
- `docs/orientation/ONBOARDING.md`: non-code walkthrough
- `docs/orientation/ROADMAP.md`: sequence and rationale
- `docs/orientation/ARCHITECTURE.md`: intended system shape and boundaries
- `docs/<domain>/ideas/IDEA-*`: early thoughts worth preserving
- `docs/<domain>/specs/SPEC-*`: durable requirements and language
- `docs/<domain>/plans/PLAN-*`: milestone intent, scope, architecture, sequencing
- `docs/<domain>/plans/.../IMPL-*`: bounded execution detail for one slice
- `docs/decisions/adr/ADR-*`: durable cross-plan decisions
- `docs/repo-health/session-logs/*`: timestamped work receipts
- `docs/decisions/learnings/LRN-*`: lessons learned worth reusing
- `docs/orientation/explainers/EXPL-*`: reusable human-facing explanations
- `docs/decisions/questions/QST-*`: durable unresolved questions with ownership or history

## Planning Rules

- Read the parent `PLAN-*` before acting on an `IMPL-*`.
- Parent plans own intent, boundaries, dependencies, and non-goals.
- Implementation briefs own task-level order, ownership, and verification detail.
- Implementation briefs are optional; skip them when the parent plan is small,
  directly executable, and has simple ownership and verification.
- Treat specs and plans as versioned truth. When a newer doc fully or partially
  supersedes an older one, mark or note that relationship explicitly instead of
  leaving silent contradictions.
- Generated views such as `TODOS.md`, `SPECS.md`, `LEARNINGS.md`, and `ROADMAP-VIEW.md` are dashboards, not the source of truth.

## Structured Todos

Use ordinary Markdown checkboxes for local, disposable checklists.

Use structured `TODO-*` items only when work needs durable coordination across sessions, agents, subagents, commits, reviews, or handoffs.

Example:

```markdown
- [ ] TODO-0001 [ready] [skill:docs-writer] [plan:PLAN-0002] Define stable todo lifecycle states.
```

Rules:

- put each `TODO-*` in the lowest durable doc that owns the work
- keep plans and briefs authoritative for scope; `TODO-*` IDs are progress handles
- when claiming a todo, add `owner:`, `agent:`, and `updated:`
- use `blocked` plus `blocker:` or `reason:` when stalled
- update the source checkbox line, not just generated `TODOS.md`

`skill:<name>` is routing metadata only. It does not guarantee a matching environment skill exists.

Detailed syntax and lifecycle rules live in `scripts/README.md` and `scaffold/docs/product/plans/README.md`.

## docs-meta Commands

Use `scripts/docs-meta` for mechanical workflow tasks instead of inventing IDs or hand-maintaining registries.

Common commands:

```bash
scripts/docs-meta next spec
scripts/docs-meta next todo
scripts/docs-meta new plan "Title" --domain product --spec SPEC-0001
scripts/docs-meta todos --status ready
scripts/docs-meta review
scripts/docs-meta check-todos
scripts/docs-meta update
scripts/docs-meta check
scripts/docs-meta check-links
```

## Verification Wrappers

When the target repo has a root project command, prefer it over memorizing many separate commands:

```bash
./run check
./run agent-check
```

Expected convention:

- `./run check` is the fast handoff baseline.
- `./run agent-check` is the fuller closeout/pre-commit sweep.
- Advisory repo-health queues may report existing debt without failing the hard gate; mention relevant findings in the handoff.
- Destructive checks, database resets, device installs, and manual UI checks stay explicit unless the command name makes the behavior obvious.

## Install And Handoff

When the task is about bootstrapping another repo:

1. use `INSTALL.md` for exact copy steps
2. adapt placeholders before handoff
3. make the target repo's `AGENTS.md` and `docs/orientation/CURRENT_STATE.md` truthful
4. run the relevant verification commands

## Guardrails

- Do not create extra doc layers when an existing doc type already owns the job.
- Do not use structured `TODO-*` items for tiny local chores.
- Do not hand-edit generated views except to recover from tooling failure.
- Do not implement from an `IMPL-*` brief alone without first reading its parent `PLAN-*`.
- Do not confuse reusable `AGENTS.md` templates with environment-provided Codex skills.
