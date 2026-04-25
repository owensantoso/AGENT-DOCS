---
type: implementation-brief
id: IMPL-0002-01
title: Todo Parser, Checks, and Agent Guidance
domain: docs-meta
status: draft
created_at: "2026-04-25 20:24:23 JST +0900"
updated_at: "2026-04-25 20:24:23 JST +0900"
planned_execution_start:
planned_execution_end:
actual_execution_start:
actual_execution_end:
parent_plan: PLAN-0002
task_refs:
  - task-1
  - task-2
  - task-3
  - task-4
  - task-5
owner:
areas:
  - docs
  - docs-meta
depends_on: []
parallel_with: []
related_specs:
  - SPEC-0001
related_adrs: []
related_sessions: []
related_issues: []
related_prs: []
repo_state:
  based_on_commit: d58cd8e44d046d219b8cf97a6827fa7293eafa2b
  last_reviewed_commit: d58cd8e44d046d219b8cf97a6827fa7293eafa2b
---

# IMPL-0002-01 - Todo Parser, Checks, and Agent Guidance

## Parent plan

- [PLAN-0002 - Stable Todo System](../PLAN-0002-stable-todo-system.md)

This brief groups Tasks 1-5 from the parent plan because the todo parser, query output, validation, generated view shape, templates, and agent guidance all share the same source-of-truth contract. Task 6, automation and external mirroring, stays out of scope until the foundation is proven.

## Tracking issue

- <GitHub sub-issue link, if created>

The issue tracks this execution slice. This brief owns the execution detail.

## Task goal

Add first-pass structured todo support to `scripts/docs-meta` and teach the AGENT-DOCS scaffold how humans, main agents, subagents, and skills should use it.

After this task:

- Durable todos can use stable `TODO-*` IDs in Markdown checkbox items.
- `docs-meta todos` can expose structured todo metadata and still preserve local checkbox behavior.
- Todo consistency can be checked mechanically.
- Generated `TODOS.md`, scaffold templates, AGENTS.md guidance, and adoption docs explain the workflow without making `AGENTS.md` the task database.

## Scope

In scope:

- Structured todo parsing for Markdown checkbox items.
- Query/filter output for structured todos and local checkboxes.
- Deterministic todo validation checks.
- Generated todo dashboard updates.
- Scaffold, guide, and script documentation updates.
- Agent/subagent/skill routing guidance for todo IDs and metadata.
- Smoke tests for valid and invalid todo examples.

Out of scope:

- Automatic todo state mutation commands such as `todo claim` or `todo done`.
- GitHub Issues, Projects, or external tracker mirroring.
- Pre-commit hooks that rewrite todo state.
- Replacing parent plans, implementation briefs, or session logs.
- A full Markdown parser unless the existing lightweight approach proves unsafe.

## Ownership

- Owns: `scripts/docs-meta` todo parsing/query/check behavior, generated `TODOS.md`, todo command documentation, scaffold plan/brief examples, agent instruction routing, subagent execution guidance, and smoke tests.
- Adjacent briefs own: future mutation commands, GitHub mirroring, CI hook packages, or extraction of `docs-meta` into a separate project.
- Integration expectation: implement as one cohesive docs-meta foundation slice; update generated views only after parser/check behavior is stable.

## Preserve

- Ordinary Markdown checkboxes remain valid for local, low-ceremony checklists.
- Generated views remain caches; source docs remain canonical.
- `scripts/docs-meta check` remains deterministic and quiet for valid docs.
- Existing idea/spec/plan/brief/ADR ID behavior remains unchanged.
- `AGENTS.md` stays concise and points to deeper docs instead of embedding a ledger.

## Dependencies / parallelization

- Depends on: PLAN-0001 link graph and safe move tooling already committed at `66aa243` or later.
- Can run in parallel with: none for implementation, because parser and generated output shape are shared hot seams.
- Write-conflict notes: avoid parallel edits to `scripts/docs-meta`, `tests/docs-meta-smoke.sh`, `scaffold/docs/TODOS.md`, plan/brief templates, and AGENTS.md templates while this brief is in flight.

## Entry point

- Start from: [scripts/docs-meta](../../../scripts/docs-meta)
- Main seam to extend: current `task_rows`, `todos_markdown`, CLI `todos`, generated views, and `check` validation flow.

## Files to read first

- [SPEC-0001 - Stable Todo System](../SPEC-0001-stable-todo-system.md)
- [PLAN-0002 - Stable Todo System](../PLAN-0002-stable-todo-system.md)
- [scripts/docs-meta](../../../scripts/docs-meta)
- [scripts/README.md](../../../scripts/README.md)
- [tests/docs-meta-smoke.sh](../../../tests/docs-meta-smoke.sh)
- [scaffold/docs/product/plans/README.md](../../../scaffold/docs/product/plans/README.md)
- [guides/subagent-execution-loop.md](../../../guides/subagent-execution-loop.md)
- [scaffold/AGENTS.md](../../../scaffold/AGENTS.md)

## Files likely to change

Create:

```text
none expected for the first implementation pass
```

Modify:

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

## Execution steps

### 1. Define the structured todo data model

Add a small `TodoItem`-style structure that records:

- stable ID, if present
- checkbox state
- lifecycle status
- task text
- metadata fields
- source doc, source line, and source doc ID
- whether the item is structured or local-only

Use `TODO-####` as the first stable ID shape. Treat IDs as global within the scanned root for this pass.

### 2. Parse structured todos without breaking local checkboxes

Extend current checkbox parsing so it recognizes examples like:

```markdown
- [ ] TODO-0001 [ready] [owner:main-agent] [skill:docs-writer] Define stable todo lifecycle states.
- [ ] TODO-0002 [blocked] [blocker:TODO-0001] [plan:PLAN-0002] Add todo validation checks.
- [x] TODO-0003 [done] [verification:tests/docs-meta-smoke.sh] Document AGENTS.md routing rules.
```

Parsing rules:

- Only parse todo syntax on Markdown checkbox lines.
- Ignore fenced code blocks and inline examples where practical.
- Interpret the first bracket token after the ID as lifecycle status when it matches an allowed state.
- Interpret later bracket tokens as `key:value` metadata.
- Leave unsupported bracket text in the task text or diagnostics rather than guessing.
- Keep local checkbox extraction for lines without `TODO-*` IDs.

### 3. Add query and JSON output

Extend `scripts/docs-meta todos` with filters:

```bash
scripts/docs-meta todos --status ready
scripts/docs-meta todos --owner main-agent
scripts/docs-meta todos --skill docs-writer
scripts/docs-meta todos --plan PLAN-0002
scripts/docs-meta todos --brief IMPL-0002-01
scripts/docs-meta todos TODO-0001
scripts/docs-meta todos --json
```

Output rules:

- Text output should remain grep-friendly.
- JSON output should include all parsed fields.
- `--all` should include done structured todos and done local checkboxes.
- Filtering should not require every todo to have every metadata field.

### 4. Add todo validation

Add `scripts/docs-meta check-todos` unless implementation shows it is cleaner to fold into `check` with a distinct error prefix.

Validation should fail for:

- duplicate structured todo IDs
- invalid lifecycle status
- checked checkbox with non-terminal active status such as `ready` or `in_progress`
- unchecked checkbox with `done` status
- `in_progress` without `owner`
- `blocked` without `blocker`, `blocked_by`, or `reason`
- `plan:` or `brief:` references that do not resolve to scanned docs
- dependency/blocker references to missing `TODO-*` IDs when the referenced todo is expected in the same scanned root

Validation may warn, not fail, for:

- structured todo missing `skill`
- structured todo missing `updated`
- local checkboxes in long-lived plans that might deserve stable IDs

### 5. Update generated `TODOS.md`

Revise `todos_markdown` so the generated view makes source-of-truth boundaries obvious.

Suggested sections:

- `# Docs Todos`
- `## Structured Todos`
- `## Local Checkboxes`

Suggested structured columns:

```text
ID | Status | Owner | Skill | Source | Line | Plan | Brief | Task
```

Suggested local checkbox columns:

```text
State | Source | Line | Task
```

If no structured todos exist, show a short sentence rather than an empty wall of table chrome.

### 6. Update docs and templates

Update documentation in the smallest useful places:

- `scripts/README.md`: command reference, syntax, lifecycle, checks, and hook/CI guidance.
- `scaffold/docs/product/plans/README.md`: when to use structured todos versus local checkboxes.
- Plan template: include stable todo examples only where durable coordination matters.
- Implementation brief template: show how a brief can own or reference structured todos.
- `guides/subagent-execution-loop.md`: cite todo IDs in delegation and closeout.
- `guides/adoption-checklist.md`: add todo check adoption steps.
- `README.md`: mention stable todo support in docs-meta capability summary.

### 7. Wire concise agent guidance

Update `scaffold/AGENTS.md` and global agent-instruction examples with brief routing rules:

- Read generated `TODOS.md` or run `scripts/docs-meta todos` when resuming or delegating todo-backed work.
- Use parent plans/briefs for scope; use todo IDs for coordination and progress references.
- Do not create structured todos for tiny local checklist items.
- When marking durable todo work complete, update source docs and run todo checks.

Keep this short. The detailed workflow belongs in docs, not always-loaded instructions.

### 8. Verify and tighten

Run the full focused verification set, inspect generated `TODOS.md`, and adjust docs if output is confusing.

## Verification

Run:

```bash
tests/docs-meta-smoke.sh
python3 -m py_compile scripts/docs-meta
scripts/docs-meta --root scaffold/docs check
scripts/docs-meta --root scaffold/docs check-links
scripts/docs-meta --root scaffold/docs todos --all
scripts/docs-meta --root scaffold/docs view todos
scripts/docs-meta --root scaffold/docs check-todos
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
git diff --check
```

If `check-todos` is intentionally folded into `check`, replace the explicit `check-todos` command with the final command shape in this brief and the docs before closeout.

Manual review:

- Confirm generated `scaffold/docs/TODOS.md` is readable for both structured todos and local checkboxes.
- Confirm AGENTS.md guidance stays short.
- Confirm examples do not imply every checkbox needs a stable ID.

## Risks / traps

- Regex parsing can overreach into examples or code blocks.
- A too-clever metadata syntax could make todos unpleasant to write.
- Validation can become noisy if warnings are treated as errors too early.
- Generated `TODOS.md` can look authoritative if docs do not clearly say it is a cache.
- Subagents may mistake todo IDs for scope authority; parent plans and implementation briefs must remain the scope source.
- Requiring owners too aggressively can make backlog capture cumbersome.

## Review focus

- Spec reviewer: lifecycle, stable ID semantics, source-of-truth boundaries, and non-goals.
- Code reviewer: parser boundaries, invalid metadata diagnostics, JSON shape, and no regressions to local checkbox extraction.
- Workflow reviewer: AGENTS.md brevity, subagent handoff usefulness, and hook/CI guidance being verification-only.

## Done checklist

- [ ] Structured todo parser implemented.
- [ ] Local checkbox extraction preserved.
- [ ] Todo filters and JSON output implemented.
- [ ] Todo validation implemented and documented.
- [ ] Generated `TODOS.md` updated and regenerated.
- [ ] Plan/brief templates show durable todo usage without over-template creep.
- [ ] AGENTS.md and subagent guidance updated concisely.
- [ ] Smoke tests cover valid structured todos, invalid structured todos, filters, JSON, and local checkboxes.
- [ ] Verification commands pass.
