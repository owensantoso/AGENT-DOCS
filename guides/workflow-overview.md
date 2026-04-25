# Workflow Overview

This workflow treats docs as the coordination layer for agent work.

The goal is not more ceremony. The goal is to make it cheap for a main agent to:

- learn the current repo state quickly
- decide what is actually in scope
- break work into safe chunks
- delegate bounded slices to subagents
- integrate results without losing architectural control

## The stack

### 1. Orientation and reality docs

These describe the repo as it exists today:

- `orientation/CURRENT_STATE.md`
- `orientation/ONBOARDING.md`
- `<surface>-codebase-map.md`
- `<surface>-testing-guide.md`
- `<domain>-seams.md`
- `repo-health/state/`

Use these to avoid implementing against stale assumptions.

### 2. Direction docs

These describe where the repo is going:

- `orientation/ROADMAP.md`
- `orientation/ARCHITECTURE.md`
- `product/ideas/`
- `product/specs/`
- domain-specific specs or research notes
- `docs/IDEAS.md` as the global registry for `IDEA-####` IDs
- `docs/SPECS.md` as the global registry for `SPEC-####` IDs

When available, use `scripts/docs-meta` to derive IDs, status, registries, and todos from the repo tree instead of manually maintaining counters. Use structured `TODO-*` items for durable cross-session coordination; keep one-off local checklist items as ordinary Markdown checkboxes.

Use these to understand sequencing, target shape, and feature intent.

### 3. Planning docs

These describe how a specific milestone should be executed:

- parent `PLAN-*` docs inside a plan folder
- task-scoped `impl-task-*` implementation briefs in the same plan folder

Use these to decide ordering, grouping, ownership, and verification.

Plans should live under the topic that owns the work:

- `product/plans/` for user-facing product capability
- `repo-health/plans/` for docs, workflow, CI, test hygiene, and maintainability
- `research/` for feasibility studies and spikes
- `operations/` for release, App Store, production, or manual operational work
- `marketing/` for launch and growth planning

### 4. Decision and memory docs

These keep reasoning durable after the chat disappears:

- `decisions/adr/`
- `decisions/learnings/`
- `repo-health/session-logs/`
- commit trailers such as `Plan:`, `Session:`, and `Verification:`

Use these to reconstruct why a change happened.

Use `LRN-*` learning records for lessons learned that should change future behavior. Use `EXPL-*` explainers for reusable human-facing teaching material. Use `QST-*` questions only for durable uncertainty that needs status, ownership, links, or resolution history across sessions. Ask ordinary clarification questions in chat, and keep local open questions in the owning doc until they outgrow it. Keep authoritative truth in the owning orientation, architecture, spec, plan, ADR, or testing doc.

### 5. Entry-point docs

These tell future agents how to boot into the repo cleanly:

- root `AGENTS.md`
- surface-level `AGENTS.md`
- reusable implementer handoff prompt

Use these to reset context safely when a new session begins.

## The main-agent model

The main agent owns:

- reading the current state
- choosing the execution sequence
- deciding which tasks should be grouped
- deciding which tasks can be parallelized safely
- integrating subagent work
- keeping docs aligned with the finished implementation

Subagents own:

- one bounded implementation brief or similarly well-scoped task
- a clear file or seam ownership area
- reporting completion against explicit done criteria

## Why the plan/brief split matters

Without the split, one doc usually becomes both too vague and too detailed.

- If it stays high-level, subagents do not know what to do next.
- If it gets too detailed, the main plan becomes noisy and fragile.

The split solves that:

- parent plan = intent, architecture, boundaries, dependencies
- implementation brief = execution order, likely files, verification, traps

## A healthy execution shape

The usual sequence is:

1. Read state and architecture docs.
2. Read the relevant spec.
3. Read the parent plan.
4. Decide which tasks are foundational, parallelizable, or follow-through.
5. Create or use implementation briefs for the bounded slices that deserve them.
6. Delegate only the slices that are safe to own independently.
7. Integrate and verify.
8. Update compact state docs, plan/brief status, and the timestamped session log.
9. Use commit trailers for meaningful commits.

If the docs are doing their job, a fresh agent should be able to enter midstream without relying on old chat memory.

When user feedback reveals a wrong assumption, ambiguous docs, missed rule, or tooling gap, use `reflect-and-improve`: pause, identify what made the miss likely, update the smallest durable source, and record the lesson when it should survive the chat.

When moving or renaming docs, use `docs-meta move` so Markdown backlinks are updated from the same link graph that powers `backlinks`, `check-links`, `orphans`, and `normalize-links`.
