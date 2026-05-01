---
type: session-log
title: PLAN-0005 Slice B Doctor And Upgrade Dry Run
domain: repo-health
status: completed
created_at: "2026-05-02 03:56:31 JST +0900"
updated_at: "2026-05-02 04:21:54 JST +0900"
started_at: "2026-05-02 03:38:00 JST +0900"
ended_at: "2026-05-02 04:21:54 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
related_plans:
  - plans/agent-docs-doctor-manifest-upgrade/PLAN-0005-agent-docs-doctor-manifest-upgrade.md
related_briefs: []
related_specs:
  - plans/agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-05-02 - PLAN-0005 Slice B Doctor And Upgrade Dry Run

## Session metadata

- Started: 2026-05-02 03:38:00 JST +0900
- Ended: 2026-05-02 04:21:54 JST +0900
- Timezone: JST +0900
- Participants: Owen, Codex
- Todo-backed work: none

## Goal

Implement PLAN-0005 Tasks 3-4 and the relevant Task 6 docs/tests for read-only
`agent-docs doctor [target]` and `agent-docs upgrade --dry-run [target]`.

## Changes

- Added `agent-docs doctor [target]` as a read-only manifest and drift report.
- Added `agent-docs upgrade --dry-run [target]` as a read-only upgrade preview.
- Reused Slice A profile/action definitions from `agent-docs-init` for upstream
  AGENT-DOCS-owned tooling comparisons.
- Classified healthy/current files, missing legacy manifests, missing owned
  tooling, checksum drift, safe updates/additions, generated-view refreshes,
  project-owned manual-review records, and refused or unknown manifest shapes.
- Kept `agent-docs upgrade --write` refused with exit code `2`.
- Added doctor/dry-run smoke coverage and wired it into `scripts/release-check`.
- Updated README, INSTALL, scripts docs, changelog, and PLAN-0005 metadata.

## Verification

- `tests/agent-docs-doctor-upgrade-smoke.sh`
- `scripts/release-check`
- Spec compliance review passed after fixing symlinked path and unknown owned
  record classification.
- Code quality review passed after hardening manifest root validation,
  symlinked manifest refusal, and checksum shape validation.

## Deferred

- `agent-docs upgrade --write --tooling-only`.
- Deliberate baseline manifest creation for legacy installs.
