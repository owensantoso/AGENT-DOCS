---
type: session-log
title: Docs Meta Review Parser
domain: docs-meta
status: completed
created_at: "2026-04-28 03:07:47 JST +0900"
updated_at: "2026-04-28 03:07:47 JST +0900"
started_at: "2026-04-28 02:18:00 JST +0900"
ended_at: "2026-04-28 03:07:47 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - docs-meta
related_plans:
  - plans/docs-meta-review-parser/PLAN-0003-docs-meta-review-parser.md
related_briefs: []
related_specs:
  - plans/docs-meta-review-parser/SPEC-0002-docs-meta-review-parser.md
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-04-28 - Docs Meta Review Parser

## Session metadata

- Started: 2026-04-28 02:18:00 JST +0900
- Ended: 2026-04-28 03:07:47 JST +0900
- Timezone: JST +0900
- Participants: Owen, Codex
- Todo-backed work: none

## Goal

Implement `scripts/docs-meta review` so audit findings, routed follow-ups, stale docs, and structured TODOs can be reviewed from one deterministic queue.

## Timeline

- 2026-04-28 02:18:00 JST +0900 - Started implementation from `SPEC-0002` and `PLAN-0003`.
- 2026-04-28 02:40:34 JST +0900 - First implementation and smoke coverage passed.
- 2026-04-28 02:55:00 JST +0900 - Fixed spec-review gaps around closeout validation, Markdown fragments, grouping, and ordering.
- 2026-04-28 03:03:55 JST +0900 - Fixed quality-review gaps around source line numbers and Markdown links with titles.
- 2026-04-28 03:07:47 JST +0900 - Fixed final review gaps around external Markdown links, malformed audit rows, and session receipt.

## Context read

- `AGENTS.md`
- `skills/structured-docs-workflow/SKILL.md`
- `plans/docs-meta-review-parser/SPEC-0002-docs-meta-review-parser.md`
- `plans/docs-meta-review-parser/PLAN-0003-docs-meta-review-parser.md`
- `scripts/README.md`
- `tests/docs-meta-smoke.sh`

## Changes

- Added `scripts/docs-meta review`.
- Added audit finding parsing and validation for the required finding-register table.
- Added routed follow-up resolution for stable IDs, repo-local paths, Markdown links, external links, and missing fragments.
- Added review queue items for invalid findings, open findings, blocked or stale follow-ups, stale structured TODOs, and stale lifecycle docs.
- Added human grouped output and JSON output with filters.
- Expanded `tests/docs-meta-smoke.sh` to cover the review queue.
- Marked `SPEC-0002` implemented and `PLAN-0003` completed.

## Decisions

- Decision: keep `review` read-only.
  - Why: source Markdown docs remain canonical; generated or displayed queues are projections.
  - Source of truth: `SPEC-0002`.
- Decision: treat malformed audit finding rows as invalid review items and continue parsing subsequent rows.
  - Why: one bad table row should not hide later findings.
  - Source of truth: smoke test coverage and final review.

## Verification

- Commands run:
  - `tests/docs-meta-smoke.sh`
  - `git diff --check`
  - `scripts/docs-meta check`
  - `scripts/docs-meta --root plans check`
  - `scripts/docs-meta check-links`
  - `scripts/docs-meta review --json`
  - `scripts/docs-meta review --width 100`
- Manual checks:
  - Spec compliance subagent review passed.
  - Code quality subagent review passed after fixes.
  - Final pre-commit review findings were fixed.
- Not run:
  - No package-level test suite exists beyond the shell smoke checks.

## Follow-ups

- Open questions: none.
- Known debt: `scripts/docs-meta --root scaffold/docs check` reports stale generated audit views outside this change.
- Recommended next step: consider whether `review` should become part of a regular docs-health check after it has been used in real repos.
