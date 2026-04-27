---
type: spec
id: SPEC-0002
title: Docs Meta Review Parser
spec_type: repo-health
domain: docs-meta
status: draft
created_at: "2026-04-28 02:05:18 JST +0900"
updated_at: "2026-04-28 02:05:18 JST +0900"
owner:
source:
  type: conversation
  link:
  notes: Request to turn audit findings and other open loops into a deterministic docs-meta review queue.
areas:
  - docs-meta
  - repo-health
  - audits
related_plans:
  - PLAN-0003
related_issues: []
related_prs: []
related_adrs: []
related_sessions: []
supersedes: []
superseded_by: []
linked_paths:
  - concepts/CONC-0003-open-loop-review-cadence.md
  - guides/audits/README.md
  - scaffold/docs/repo-health/audits/YYYY-MM-DD-repo-health-audit.md
repo_state:
  based_on_commit: 37565c53b9bb8f960fdf7fc113264ec1e81a3dfb
  last_reviewed_commit: 37565c53b9bb8f960fdf7fc113264ec1e81a3dfb
---

# SPEC-0002 - Docs Meta Review Parser

## Summary

Add a read-only `scripts/docs-meta review` command that parses audit finding registers and other structured open loops into one deterministic attention queue.

The command should answer: what needs attention, why, where is the source of truth, and what should own the next action?

## Problem / Opportunity

AGENT-DOCS now has audits, audit findings, structured TODOs, plans, questions, diagnostics, research notes, and generated health views. That is useful, but it creates a new failure mode: the repo can accumulate many documented open loops without a single command that shows which ones need review.

Audits especially need mechanical follow-through. A completed audit should not hide open findings with no route, routed findings with missing follow-up docs, stale deferred items, or accepted risks with no rationale.

## Goals

- Parse audit finding registers with a strict, documented table shape.
- Validate finding severity, status, route, follow-up, and resolution rules.
- Surface open, stale, blocked, invalid, or dangling open loops in a human-readable queue.
- Provide JSON output for future tools, CI, hooks, or agent review.
- Keep Markdown source docs canonical; generated output is a projection.
- Make risk-like concerns visible without introducing a first-class `RISK-*` doc type.

## Non-Goals

- Do not create or require a hand-authored risk register.
- Do not create `RISK-*` stable IDs in this first pass.
- Do not mutate docs, auto-close findings, or rewrite tables.
- Do not implement cron jobs, notifications, GitHub issue sync, or project-management boards.
- Do not use AI summarization or embeddings for the first parser.
- Do not parse arbitrary Markdown tables beyond the supported audit finding register shape.

## Current Behavior / Context

- Audit guides define an exact finding-register table:
  `ID`, `Severity`, `Status`, `Finding`, `Route`, `Follow-up`, `Resolution`.
- Audit findings use audit-local IDs such as `FINDING-001`; canonical references are `<audit path>#FINDING-###`.
- Allowed statuses are `open`, `routed`, `resolved`, `deferred`, `accepted-risk`, and `archived`.
- Allowed routes are `TODO`, `DIAG`, `RSCH`, `EVAL`, `QST`, `CONC`, `LRN`, `ADR`, `SPEC`, `PLAN`, `IMPL`, and `none`.
- `docs-meta` already has document metadata, links, todos, recent output, and validation commands.
- `CONC-0003` defines the open-loop review cadence and points toward a future `docs-meta review`.

## Desired Behavior / Target State

`scripts/docs-meta review` should be read-only and quiet when there is nothing actionable.

Default human output should group attention items by urgency:

1. invalid audit finding rows
2. open high/critical findings
3. routed findings with missing or invalid follow-up targets
4. blocked or stale structured TODOs
5. stale ready/in-progress plans or implementation briefs
6. open questions or diagnostics older than the configured threshold
7. deferred or accepted-risk items due for review

The command should support at least:

```bash
scripts/docs-meta review
scripts/docs-meta review --json
scripts/docs-meta review --type audit-findings
scripts/docs-meta review --status open
scripts/docs-meta review --severity high
scripts/docs-meta review --limit 20
scripts/docs-meta review --width 100
```

## Requirements

### Audit Finding Parser

- Parse finding-register tables only when the exact required header is present.
- Ignore table-like examples inside fenced code blocks.
- Preserve source path, row number, finding ID, severity, status, route, follow-up, resolution, and raw row.
- Treat finding IDs as local to the audit source path.
- Emit canonical references as `<path>#FINDING-###`.

### Audit Finding Validation

- Report invalid severity, status, or route values.
- Report duplicate finding IDs within the same audit.
- Report `routed` findings with no follow-up target.
- Report `resolved` findings with no resolution evidence.
- Report `deferred` findings with no reason or revisit trigger.
- Report `accepted-risk` findings with no rationale or owner.
- Report `archived` findings with no reason.
- Report direct fixes as valid when `Status = resolved`, `Route = none`, and `Resolution` contains evidence.
- Report accepted risks as valid when `Status = accepted-risk`, `Route = none`, and `Resolution` contains rationale and owner.

### Follow-Up Resolution

- Resolve follow-up values that look like stable IDs, Markdown links, or repo-local paths.
- Mark missing follow-up targets as review items.
- Do not require `Follow-up` when `Route = none`, unless status-specific rules require evidence in `Resolution`.
- Keep external issue URLs as unresolved-but-accepted links in the first pass unless link validation already supports them.

### Open Loop Queue

- Include audit findings that are `open`, invalid, stale, or dangling.
- Include routed findings whose follow-up target is blocked, archived, missing, or stale.
- Include structured TODOs from existing docs-meta todo parsing when they are blocked, in progress too long, or ready too long.
- Include open `QST`, active `DIAG`, active `RSCH`/`EVAL`, and ready/in-progress `PLAN`/`IMPL` docs when stale thresholds are exceeded.
- Prefer deterministic ordering: severity, status urgency, updated time, then path/reference.

### Risk Language

- Treat risk as a descriptor or signal, not as a source-of-truth doc type.
- Accepted risks should be represented by `accepted-risk` finding status or ADR/plan decision text.
- A future `RISKS.md` or risk register should be a generated projection from findings, ADRs, plans, questions, and TODOs, not a hand-authored canonical file.

### Output

- Default output should be human-readable and terminal-width aware.
- `--json` should return stable machine-readable records.
- Include enough context for an agent to open the right source doc without copying sensitive evidence.
- Do not print raw sensitive payloads; output source references and sanitized summaries only.

## Open Questions

- What stale thresholds should be defaults versus configurable? Recommended first pass: conservative built-in defaults plus flags later.
- Should `docs-meta check` fail on invalid audit finding rows, or should review-only warnings come first? Recommended first pass: `review` reports; `check` integration waits until the parser is proven.
- Should open-loop review include captured ideas? Recommended first pass: no, unless promoted to ready/open status.
- Should accepted risks require a named owner field, or is owner text inside `Resolution` enough? Recommended first pass: owner text in `Resolution`, then revisit if parsing becomes too loose.

## Test / Validation Expectations

- Add parser fixtures for valid and invalid audit finding tables.
- Test fenced-code examples are ignored.
- Test duplicate IDs, invalid enums, and each status-specific closeout rule.
- Test follow-up resolution for stable IDs, Markdown links, repo-local paths, missing targets, and external URLs.
- Test non-audit review items for stale structured TODOs, stale plans/briefs, open questions, active diagnostics, and active research/evaluations.
- Test default human output and `--json`.
- Test `scripts/docs-meta review` is read-only.
- Keep existing `tests/docs-meta-smoke.sh` green.

## Paper Trail

- Related concept: [CONC-0003 - Open Loop Review Cadence](../../concepts/CONC-0003-open-loop-review-cadence.md)
- Related guide: [Audit Guides](../../guides/audits/README.md)
