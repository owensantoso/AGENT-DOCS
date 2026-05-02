---
type: session-log
title: IMPL-0007-01 Generated View Registration
domain: repo-health
status: completed
created_at: "2026-05-02 09:32:34 JST +0900"
updated_at: "2026-05-02 09:32:34 JST +0900"
started_at: "2026-05-02 09:27:00 JST +0900"
ended_at: "2026-05-02 09:32:34 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
related_plans:
  - plans/generated-view-manifest-registration/PLAN-0007-generated-view-manifest-registration.md
related_briefs:
  - plans/generated-view-manifest-registration/implementation-briefs/IMPL-0007-01-generated-view-registration.md
related_specs:
  - plans/agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-05-02 - IMPL-0007-01 Generated View Registration

## Session metadata

- Started: 2026-05-02 09:27:00 JST +0900
- Ended: 2026-05-02 09:32:34 JST +0900
- Timezone: JST +0900
- Participants: Owen, Codex
- Todo-backed work: none

## Goal

Implement generated-view manifest registration for fresh installs and legacy
baselines without broadening generated-view upgrade writes.

## Changes

- Fresh `agent-docs-init --write` runs `scripts/docs-meta update` when
  `docs-meta` is included, then writes generated-view manifest records for
  existing recognized docs-meta outputs.
- `agent-docs baseline` accepts explicit `--generated-views`, registers only
  existing regular generated-view files from the known docs-meta output set, and
  skips missing or unmarked files without running generators.
- Default baseline behavior remains unchanged and writes
  `"generated_views": []`.
- Generated-view upgrade writes remain opt-in and manifest-tracked only.
- Added smoke coverage for fresh install registration and baseline
  `--generated-views` registration.

## Verification

- `tests/agent-docs-init-smoke.sh`
- `tests/agent-docs-doctor-upgrade-smoke.sh`
- `scripts/release-check`
- `scripts/docs-meta --root plans check`
- `scripts/docs-meta --root plans check-links`
- `git diff --check`
