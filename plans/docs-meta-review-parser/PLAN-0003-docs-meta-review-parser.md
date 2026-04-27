---
type: plan
id: PLAN-0003
title: Docs Meta Review Parser
domain: docs-meta
status: completed
created_at: "2026-04-28 02:05:18 JST +0900"
updated_at: "2026-04-28 03:07:47 JST +0900"
planned_execution_start:
planned_execution_end:
actual_execution_start: "2026-04-28 02:18:00 JST +0900"
actual_execution_end: "2026-04-28 03:07:47 JST +0900"
owner:
sequence:
  roadmap:
  sort_key:
  lane: docs-meta
  after:
    - PLAN-0002
  before: []
areas:
  - docs
  - docs-meta
  - repo-health
related_specs:
  - SPEC-0002
related_adrs: []
related_sessions:
  - session-logs/2026-04-28-docs-meta-review-parser.md
related_issues: []
related_prs: []
repo_state:
  based_on_commit: 37565c53b9bb8f960fdf7fc113264ec1e81a3dfb
  last_reviewed_commit: 07b98ee04d1a9e8f3a422b1ee6c837c3289709d9
---

# PLAN-0003 - Docs Meta Review Parser

**Goal:** Add a read-only `scripts/docs-meta review` command that parses audit findings and other open loops into one deterministic attention queue.

**Architecture:** Build a small audit-finding parser first, then layer validation and aggregation on top. Keep Markdown docs canonical. Keep `review` read-only until the data model and output format are stable.

**Tech Stack:** AGENT-DOCS Markdown conventions, `scripts/docs-meta`, audit finding tables, existing document metadata/todo parsers, smoke tests, and JSON output for future tool integration.

**Source Spec:** [SPEC-0002 - Docs Meta Review Parser](SPEC-0002-docs-meta-review-parser.md)

---

## Prerequisites

- Audit guide contract is stable enough to parse: required columns, enums, and closeout rules are documented.
- PLAN-0002 todo parsing is available as an input for TODO-related review items.
- `scripts/docs-meta check`, `check-links`, and current smoke tests are green before parser work starts.

## Why Now

- AGENT-DOCS now has enough structured docs that open loops can pile up quietly.
- Audit findings need a deterministic path from evidence to follow-up, without relying on memory or manual scanning.
- The review queue is the missing bridge between documentation and actual maintenance.
- Building this before a risk register prevents premature `RISK-*` scope while still surfacing risk-like concerns.

## Product / Workflow Decisions

- `docs-meta review` is a projection, not a source of truth.
- Audit docs remain the source for audit findings.
- TODO docs remain the source for executable tasks.
- QST, DIAG, RSCH/EVAL, ADR, SPEC, PLAN, and IMPL docs remain the source for their own lifecycle.
- Risk is a descriptor. A risk register, if useful later, should be generated from existing sources rather than authored as a separate canonical doc.

## Design Rules

- Read-only first.
- Parse the smallest supported table shape; do not build a generic Markdown table database.
- Make invalid rows visible without guessing intent.
- Prefer false negatives over noisy false positives in the first default view.
- `--json` output should be stable enough for tests and future automation.
- Human output should be readable in normal terminals.
- Do not print raw sensitive evidence from audit docs.

## Task Dependencies / Parallelization

- Task 1 must happen first: audit finding parser and fixtures.
- Tasks 2 and 3 can run in parallel after Task 1: validation rules and follow-up resolution.
- Task 4 depends on Tasks 1-3: review queue aggregation.
- Task 5 depends on Task 4: output shape and filters.
- Task 6 closes out docs, generated views, and verification.
- Net: parser foundation, validation/resolution, aggregation/output, docs closeout.

## Out Of Scope

- Mutating commands such as `review close`, `review route`, or automatic table rewrites.
- Adding `RISK-*` docs or a hand-authored risk register.
- CI gating by default.
- GitHub Issues/Projects sync.
- Cron jobs, reminders, or notifications.
- AI summarization of open loops.

## File Structure

Likely create:

```text
plans/docs-meta-review-parser/implementation-briefs/IMPL-0003-01-review-parser-foundation.md
```

Likely modify:

```text
scripts/docs-meta
tests/docs-meta-smoke.sh
scripts/README.md
README.md
guides/audits/README.md
scaffold/docs/repo-health/audits/YYYY-MM-DD-repo-health-audit.md
```

## Implementation Tasks

### Task 1: Add audit finding parser - Completed

**Goal:** Parse the exact audit finding-register table into structured records.

- Recognize the required table header.
- Ignore fenced-code examples.
- Capture source path, line number, local finding ID, severity, status, route, follow-up, resolution, and raw row.
- Produce canonical references as `<path>#FINDING-###`.
- Add focused fixtures and parser tests.

Dependencies / parallelization:

- Depends on: prerequisites only.
- Can run in parallel with: none.

### Task 2: Add validation rules - Completed

**Goal:** Make malformed or incomplete findings visible.

- Validate severity/status/route enums.
- Detect duplicate finding IDs within one audit.
- Enforce closeout requirements for `routed`, `resolved`, `deferred`, `accepted-risk`, and `archived`.
- Classify errors versus warnings.

Dependencies / parallelization:

- Depends on: Task 1.
- Can run in parallel with: Task 3.

### Task 3: Resolve follow-up targets - Completed

**Goal:** Connect routed findings to the docs that own follow-up.

- Resolve stable IDs via existing docs metadata.
- Resolve Markdown links and repo-local paths.
- Allow external issue URLs as external targets.
- Report missing or archived follow-up targets.

Dependencies / parallelization:

- Depends on: Task 1.
- Can run in parallel with: Task 2.

### Task 4: Build review queue aggregation - Completed

**Goal:** Combine findings, TODOs, and stale lifecycle docs into one attention queue.

- Include invalid/open/stale/dangling audit findings.
- Include blocked or stale structured TODOs.
- Include stale ready/in-progress plans and implementation briefs.
- Include stale open QST/DIAG/RSCH/EVAL docs.
- Keep captured ideas out of the queue unless promoted.

Dependencies / parallelization:

- Depends on: Tasks 1-3.
- Can run in parallel with: none.

### Task 5: Add CLI output and filters - Completed

**Goal:** Make review output useful to humans and agents.

- Add `scripts/docs-meta review`.
- Add `--json`, `--type`, `--status`, `--severity`, `--limit`, and `--width`.
- Make default human output grouped by urgency.
- Make JSON stable enough for tests and future tooling.

Dependencies / parallelization:

- Depends on: Task 4.
- Can run in parallel with: docs drafting after output shape stabilizes.

### Task 6: Document and verify the workflow - Completed

**Goal:** Make the review queue part of normal AGENT-DOCS maintenance.

- Update command docs.
- Update audit guide references if command names or constraints changed.
- Add or update smoke coverage.
- Run `git diff --check`, docs-meta smoke tests, and docs-meta checks.

Dependencies / parallelization:

- Depends on: Tasks 1-5.
- Can run in parallel with: final review only.

## Validation

- `git diff --check`
- `tests/docs-meta-smoke.sh`
- `scripts/docs-meta check`
- `scripts/docs-meta --root plans check`
- focused parser tests or fixture assertions added during Task 1

## Completion Criteria

- [x] `scripts/docs-meta review` parses valid audit finding tables.
- [x] Invalid audit finding rows are reported deterministically.
- [x] Routed findings resolve stable-ID, Markdown-link, and path follow-ups.
- [x] Open/stale/dangling audit findings appear in default human output.
- [x] Blocked or stale structured TODOs appear in the review queue.
- [x] Stale ready/in-progress plans and implementation briefs appear in the review queue.
- [x] Stale open QST, active DIAG, active RSCH, and active EVAL docs appear in the review queue.
- [x] `--json` returns stable machine-readable records.
- [x] Existing docs-meta commands and smoke tests remain green.
