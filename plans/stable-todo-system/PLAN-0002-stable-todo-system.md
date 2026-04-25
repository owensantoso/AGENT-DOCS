---
type: plan
id: PLAN-0002
title: Stable Todo System
domain: docs-meta
status: draft
created_at: "2026-04-25 20:18:11 JST +0900"
updated_at: "2026-04-25 20:18:11 JST +0900"
planned_execution_start:
planned_execution_end:
actual_execution_start:
actual_execution_end:
owner:
sequence:
  roadmap:
  sort_key:
  lane: docs-meta
  after:
    - PLAN-0001
  before: []
areas:
  - docs
  - docs-meta
related_specs:
  - SPEC-0001
related_adrs: []
related_sessions: []
related_issues: []
related_prs: []
repo_state:
  based_on_commit: 66aa243b0355baa41045e6b71ece8b1c31185945
  last_reviewed_commit: 66aa243b0355baa41045e6b71ece8b1c31185945
---

# PLAN-0002 - Stable Todo System

**Goal:** Add a stable, Markdown-native todo system to AGENT-DOCS so durable work can be tracked across humans, main agents, subagents, skills, hooks, commits, and optional GitHub mirrors without making `AGENTS.md` the task database.

**Architecture:** Extend `scripts/docs-meta` in stages. First introduce a structured todo parser and generated view that remains compatible with ordinary Markdown checkboxes. Then add validation and query filters. Finally update scaffold guidance and hook/CI recipes. Mutation commands and GitHub mirroring should stay out of the first pass unless the parser/checking foundation proves small and predictable.

**Tech Stack:** AGENT-DOCS Markdown conventions, `scripts/docs-meta`, generated `TODOS.md`, plan/brief frontmatter, AGENTS.md templates, smoke tests, and optional pre-commit/CI shell hooks.

**Source Spec:** [SPEC-0001 - Stable Todo System](SPEC-0001-stable-todo-system.md)

---

## Prerequisites

- PLAN-0001 link graph and safe move tooling is committed, pushed, and available as the docs-meta baseline.
- Current checkbox extraction behavior is preserved or intentionally migrated with tests.
- The first implementation avoids external services and does not require GitHub issue state.

## Why Now

- AGENT-DOCS already has plans, implementation briefs, generated views, and subagent guidance, but todo identity is still line-number based.
- Subagent-heavy work needs stable task IDs, owner/claim conventions, and filterable handoff views.
- Hooks and CI can prevent stale task bookkeeping once the task model is deterministic.
- The link graph work created the right foundation for richer docs-meta query/check commands.

## Product / Workflow Decisions

- Markdown docs remain canonical; generated views are caches.
- `AGENTS.md` remains a short router and should link to todo workflow docs instead of embedding a task ledger.
- Structured todos are opt-in. Ordinary local checkboxes remain valid for small checklists.
- The first pass should prefer read/query/check behavior over mutation behavior.
- Hook guidance should verify todo consistency, not silently claim or complete work.
- GitHub Issues/Projects can be a mirror later; they are not the canonical source in this plan.

## Domain Model / Interfaces

- Domain terms to preserve: `structured todo`, `local checkbox`, `claim`, `owner`, `skill`, `generated todo view`, `mirror`.
- New or changed interfaces: `docs-meta todos`, `docs-meta view todos`, likely `docs-meta check-todos`, and possibly `docs-meta todo ...` mutation commands in a later slice.
- Related area docs: docs-meta, AGENT-DOCS scaffold, agent instructions.

## Design Rules

- Keep the syntax human-readable in plain Markdown.
- Keep stable IDs stable; do not make line number part of identity.
- Do not require structured metadata for every checkbox.
- Do not hide todo rewrites inside generated-view or pre-commit commands.
- Make validation errors specific enough for agents to fix without guessing.
- Keep generated `TODOS.md` useful as a dashboard, not a second editable source.
- Prefer small parser rules over a full Markdown/YAML task language unless tests prove the simple model insufficient.

## Task Dependencies / Parallelization

- Task 1 defines the todo syntax and parser model and must happen first.
- Tasks 2 and 3 can run in parallel after Task 1: CLI/query output and validation checks.
- Task 4 depends on Tasks 1-3: generated `TODOS.md` shape and scaffold/template updates.
- Task 5 depends on Task 4: AGENTS.md, skills guidance, and subagent handoff rules.
- Task 6 is optional/later: mutation commands and GitHub mirroring design.
- Net: parser foundation, read/check surfaces, docs rollout, then optional automation.

## Out Of Scope

- Building a full project management app.
- Requiring GitHub Issues/Projects for local todo tracking.
- Replacing specs, parent plans, or implementation briefs.
- Auto-completing tasks from test results.
- Creating agent hooks that mutate todo state without explicit user/agent action.

## File Structure

Likely create:

```text
plans/stable-todo-system/implementation-briefs/IMPL-0002-01-todo-parser-and-checks.md
```

Likely modify:

```text
scripts/docs-meta
tests/docs-meta-smoke.sh
scripts/README.md
README.md
guides/workflow-overview.md
guides/subagent-execution-loop.md
guides/adoption-checklist.md
scaffold/AGENTS.md
scaffold/agent-instructions/global-AGENTS.md
scaffold/docs/TODOS.md
scaffold/docs/product/plans/README.md
scaffold/docs/product/plans/PLAN-0000-plan-title/PLAN-0000-plan-title.md
scaffold/docs/product/plans/PLAN-0000-plan-title/IMPL-0000-00-implementation-brief-title.md
```

## Implementation Tasks

### Task 1: Define structured todo syntax and parser

**Goal:** Add a small parser that recognizes structured todos while preserving current local checkbox extraction.

- Recognize stable IDs such as `TODO-0001` inside Markdown checkbox items.
- Parse lifecycle state and bracket metadata such as owner, skill, plan, brief, depends-on, blocks, and verification.
- Preserve source path, line number, task text, checkbox state, and raw line for diagnostics.
- Ignore examples inside fenced code blocks.

Dependencies / parallelization:

- Depends on: prerequisites only
- Can run in parallel with: none
- Notes: this is the core seam; keep it well tested before touching docs templates broadly.

### Task 2: Add queryable todo CLI output

**Goal:** Make structured todo data useful to humans, main agents, and subagents.

- Extend `scripts/docs-meta todos` with filters for status, owner, skill, plan, brief, and ID.
- Add JSON output for tool/hook integration.
- Keep current simple text output usable for local checkboxes.
- Consider showing structured todos first and local checkboxes second.

Dependencies / parallelization:

- Depends on: Task 1
- Can run in parallel with: Task 3
- Notes: avoid adding mutation commands in this task.

### Task 3: Add todo validation checks

**Goal:** Catch task-state drift mechanically.

- Add `scripts/docs-meta check-todos` or fold todo validation into `scripts/docs-meta check` with clear output.
- Validate duplicate todo IDs, invalid states, missing owner for `in_progress`, blocked todos without reason/blocker, invalid plan/brief references, and impossible checkbox/status combinations.
- Make warnings versus errors explicit.

Dependencies / parallelization:

- Depends on: Task 1
- Can run in parallel with: Task 2
- Notes: keep checks deterministic and quiet for valid docs.

### Task 4: Update generated todo views and templates

**Goal:** Make the docs scaffold teach the new model.

- Update generated `TODOS.md` columns for ID, status, owner, skill, source, plan/brief, and task.
- Update plan and implementation brief templates with examples of structured todos only where durable coordination matters.
- Update `scripts/README.md` with command reference and source-of-truth rules.
- Update adoption guidance with hook/CI examples.

Dependencies / parallelization:

- Depends on: Tasks 1-3
- Can run in parallel with: Task 5 after generated output shape is stable
- Notes: do not over-template every checklist item.

### Task 5: Wire agent, skill, and subagent guidance

**Goal:** Make agents use the todo system consistently without overloading `AGENTS.md`.

- Add short AGENTS.md routing rules for reading todo views, claiming work, and closeout.
- Update subagent execution guidance so delegated work can cite todo IDs and implementation briefs.
- Explain how skill routing maps to `skill:` todo metadata.
- Clarify that parent plans and implementation briefs remain authoritative for scope and execution details.

Dependencies / parallelization:

- Depends on: Task 4 output shape
- Can run in parallel with: final review
- Notes: keep always-loaded instructions concise.

### Task 6: Decide later automation and mirroring

**Goal:** Capture the next layer without forcing it into the foundation.

- Evaluate explicit mutation commands such as `todo claim`, `todo block`, and `todo done`.
- Evaluate optional GitHub issue or Projects mirroring.
- Evaluate pre-commit/CI recipes and whether todo validation should be part of `docs-meta check` by default.
- Create a follow-up plan or ADR if the decision affects multiple future workflows.

Dependencies / parallelization:

- Depends on: Tasks 1-5
- Can run in parallel with: none
- Notes: this may become its own plan if the first pass is already useful.

## Validation

- `tests/docs-meta-smoke.sh`
- `python3 -m py_compile scripts/docs-meta`
- `scripts/docs-meta --root scaffold/docs check`
- `scripts/docs-meta --root scaffold/docs view todos`
- `scripts/docs-meta --root scaffold/docs check-links`
- `scripts/docs-meta --root plans check`
- `git diff --check`

## Completion Criteria

- Structured todos have stable IDs and documented lifecycle states.
- Generated todo views show structured metadata without becoming canonical state.
- Existing local checkbox extraction still works or has a documented migration path.
- Todo checks catch duplicate IDs and invalid state/reference combinations.
- Plan, brief, AGENTS.md, and adoption docs explain when and how to use structured todos.
- Hook guidance is explicit, conservative, and verification-oriented.

## Risks / Traps

- Over-modeling todos could make humans stop using them.
- Too much metadata in every checkbox would make plans noisy.
- Mutation commands could rewrite user-authored docs in surprising ways.
- GitHub mirroring could create competing sources of truth.
- Subagents may treat todo IDs as scope authority unless docs clearly say parent plans and briefs still govern intent.

## Review Focus

- Spec reviewer: confirm lifecycle and source-of-truth rules are simple enough to maintain.
- Code reviewer: scrutinize parser ambiguity, validation errors, and compatibility with existing checkbox extraction.
- Workflow reviewer: ensure AGENTS.md and skill guidance route to the system without bloating always-loaded context.
