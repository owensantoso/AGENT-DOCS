---
type: session-log
title: IMPL-0006-01 Legacy Manifest Baseline
domain: repo-health
status: completed
created_at: "2026-05-02 06:36:33 JST +0900"
updated_at: "2026-05-02 07:02:56 JST +0900"
started_at: "2026-05-02 06:31:00 JST +0900"
ended_at: "2026-05-02 07:02:56 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
related_plans:
  - plans/agent-docs-upgrade-follow-ups/PLAN-0006-generated-view-and-legacy-manifest-upgrade-follow-ups.md
related_briefs:
  - plans/agent-docs-upgrade-follow-ups/implementation-briefs/IMPL-0006-01-legacy-manifest-baseline.md
related_specs:
  - plans/agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-05-02 - IMPL-0006-01 Legacy Manifest Baseline

## Session metadata

- Started: 2026-05-02 06:31:00 JST +0900
- Ended: 2026-05-02 07:02:56 JST +0900
- Timezone: JST +0900
- Participants: Owen, Codex
- Todo-backed work: none

## Goal

Implement the first PLAN-0006 slice: a preview-first `agent-docs baseline`
command for legacy installs that lack `.agent-docs/manifest.json`.

## Changes

- Added `agent-docs baseline --dry-run|--write [target] --profile <profile>
  --docs-meta auto|yes|no`.
- Reused `agent-docs-init` profiles and `action_ownership` so only known
  AGENT-DOCS-owned tooling can be checksummed as owned.
- Kept project/starter Markdown as `project-owned-after-install` when present,
  without checksums or mutation.
- Refused existing manifests, empty/unrelated targets, missing/drifted/wrong-mode
  owned tooling, symlinked and hardlinked owned paths, non-directory parent
  conflicts, non-regular files, and unsafe manifest paths.
- Added smoke coverage for baseline preview/write and refusal cases.
- Updated adopter-facing command docs and CHANGELOG notes.

## Review

- Spec review found an unselected owned-path parent conflict gap; fixed with a
  refusal and regression test.
- Code/security review found empty-target and hardlink baseline false-positive
  gaps; fixed both with refusal checks and smoke coverage.
- Final focused re-review passed.

## Verification

- `tests/agent-docs-doctor-upgrade-smoke.sh`
- `tests/agent-docs-init-smoke.sh`
- `scripts/release-check`
- `scripts/docs-meta --root plans check`
- `scripts/docs-meta --root plans check-links`
- `git diff --check`

## Deferred

- Generated-view write mode remains deferred to a future PLAN-0006 brief.
