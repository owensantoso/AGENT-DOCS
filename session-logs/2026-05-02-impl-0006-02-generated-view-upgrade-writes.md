---
type: session-log
title: IMPL-0006-02 Generated View Upgrade Writes
domain: repo-health
status: completed
created_at: "2026-05-02 07:51:06 JST +0900"
updated_at: "2026-05-02 08:53:35 JST +0900"
started_at: "2026-05-02 07:41:00 JST +0900"
ended_at: "2026-05-02 08:53:35 JST +0900"
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
  - plans/agent-docs-upgrade-follow-ups/implementation-briefs/IMPL-0006-02-generated-view-upgrade-writes.md
related_specs:
  - plans/agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-05-02 - IMPL-0006-02 Generated View Upgrade Writes

## Session metadata

- Started: 2026-05-02 07:41:00 JST +0900
- Ended: 2026-05-02 08:53:35 JST +0900
- Timezone: JST +0900
- Participants: Owen, Codex
- Todo-backed work: none

## Goal

Implement the second PLAN-0006 slice: explicit generated-view writes for
manifest-tracked generated views during `agent-docs upgrade --write
--tooling-only --generated-views`.

## Changes

- Added `--generated-views` as an opt-in flag that is valid only with
  `--write --tooling-only`.
- Added generated-view write operations separate from tooling operations.
- Limited generator execution to the known `scripts/docs-meta update` command.
- Validated generated-view records, supported generator paths, upstream and
  manifest checksums, symlinks, hardlinks, non-regular outputs, backup
  destinations, and possible hand-edited current files before writing.
- Regenerated stale or missing manifest-tracked generated views, updated their
  manifest checksums, included them in backup audit records, and wrote the
  manifest last.
- Runs the trusted source checkout `scripts/docs-meta` under Python safe-path
  mode with `PYTHONPATH`/`PYTHONHOME` stripped, while still requiring the target
  installed generator to be current manifest-owned tooling.
- Preserved dry-run and default `--write --tooling-only` behavior as
  report-only for generated views.
- Added smoke coverage for success and refusal cases.
- Updated adopter-facing docs, CHANGELOG, PLAN-0006, and this brief.

## Verification

- `tests/agent-docs-doctor-upgrade-smoke.sh`
- `tests/agent-docs-init-smoke.sh`
- `scripts/release-check`
- `scripts/docs-meta --root plans check`
- `scripts/docs-meta --root plans check-links`
- `git diff --check`

## Notes

- Fresh installs and legacy baselines still create empty `generated_views`
  arrays. This slice only acts on records already present in the manifest.

## Correction - 2026-05-02 08:05:15 JST +0900

- What happened: spec review found that `docs/HEALTH.md` was listed as a
  `scripts/docs-meta update` output even though `update` does not write it, and
  generated-view backups were persisted after generator mutation.
- Source: agent implementation miss; the generator output allowlist was broader
  than the actual generator behavior, and the backup timing did not match the
  brief.
- What changed: removed `docs/HEALTH.md` from the supported update output set,
  added a regression for tracked `docs/HEALTH.md`, persisted generated-view
  backups before invoking the generator, and restored tracked generated-view
  snapshots on generator or verification failure.
- Verification: `tests/agent-docs-doctor-upgrade-smoke.sh`, `git diff --check`.

## Correction - 2026-05-02 08:14:28 JST +0900

- What happened: spec re-review found combined `--tooling-only
  --generated-views` could restore or update tooling first, then fail during
  generated-view regeneration with the manifest unchanged.
- Source: agent implementation miss; the write sequence did not treat
  generated-view verification as a precondition for tooling writes.
- What changed: generated-view backups and generator verification now happen
  before any tooling operation is persisted, and smoke coverage verifies that a
  failed generator leaves a missing owned tooling file missing.
- Verification: `tests/agent-docs-doctor-upgrade-smoke.sh`, `git diff --check`.

## Correction - 2026-05-02 08:53:35 JST +0900

- What happened: code/security review found additional generator and filesystem
  trust gaps: manifest-blessed but non-upstream generators could run,
  hardlinked generated outputs could modify outside files, pre-existing backup
  destination hardlinks could be overwritten, target-local Python modules could
  shadow imports when executing the target generator, and non-regular untracked
  generator outputs could hang the generator.
- Source: agent implementation miss; the first implementation treated target
  manifest trust and path checks as sufficient for generator execution.
- What changed: generator execution now requires current AGENT-DOCS upstream
  checksum, runs the source checkout generator with Python safe-path mode and a
  stripped Python environment, refuses hardlinked/non-regular generated outputs,
  refuses pre-existing backup destinations, and adds smoke regressions for the
  reviewed cases.
- Verification: `tests/agent-docs-doctor-upgrade-smoke.sh`,
  `tests/agent-docs-init-smoke.sh`, `scripts/release-check`,
  `scripts/docs-meta --root plans check`,
  `scripts/docs-meta --root plans check-links`, `git diff --check`.
