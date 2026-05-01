---
type: session-log
title: PLAN-0004 Public Readiness
domain: repo-health
status: completed
created_at: "2026-05-02 02:53:43 JST +0900"
updated_at: "2026-05-02 02:53:43 JST +0900"
started_at: "2026-05-02 02:13:08 JST +0900"
ended_at: "2026-05-02 02:53:43 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
related_plans:
  - plans/public-readiness-and-agent-continuity-rename/PLAN-0004-public-readiness-and-agent-continuity-rename.md
  - plans/agent-docs-doctor-manifest-upgrade/PLAN-0005-agent-docs-doctor-manifest-upgrade.md
related_briefs:
  - plans/public-readiness-and-agent-continuity-rename/IMPL-0004-01-public-install-docs-portability-hardening.md
  - plans/public-readiness-and-agent-continuity-rename/IMPL-0004-02-release-checks-and-ci.md
  - plans/public-readiness-and-agent-continuity-rename/IMPL-0004-03-changelog-versioning-gate.md
related_specs:
  - plans/agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-05-02 - PLAN-0004 Public Readiness

## Session metadata

- Started: 2026-05-02 02:13:08 JST +0900
- Ended: 2026-05-02 02:53:43 JST +0900
- Timezone: JST +0900
- Participants: Owen, Codex
- Todo-backed work: none

## Goal

Execute PLAN-0004's public-readiness pass for AGENT-DOCS without renaming the
repo or implementing the future doctor/upgrade toolchain.

## Timeline

- 2026-05-02 02:13:08 JST +0900 - Started from the committed PLAN-0004 baseline.
- 2026-05-02 02:28:00 JST +0900 - Implemented preview-first install docs,
  installer default dry-run behavior, Git preflight, and ASCII-safe init output.
- 2026-05-02 02:32:00 JST +0900 - Added local release check and GitHub Actions CI.
- 2026-05-02 02:37:00 JST +0900 - Added CHANGELOG.md and changelog gate coverage.
- 2026-05-02 02:44:00 JST +0900 - Added community files and PLAN-0005 follow-up.
- 2026-05-02 02:50:00 JST +0900 - Fixed review findings around changelog-check
  self-gating and commit-message exemptions in CI-style runs.
- 2026-05-02 02:53:43 JST +0900 - Final release check passed.

## Context read

- `AGENTS.md`
- `README.md`
- `INSTALL.md`
- `plans/public-readiness-and-agent-continuity-rename/PLAN-0004-public-readiness-and-agent-continuity-rename.md`
- `plans/public-readiness-and-agent-continuity-rename/IMPL-0004-01-public-install-docs-portability-hardening.md`
- `plans/public-readiness-and-agent-continuity-rename/IMPL-0004-02-release-checks-and-ci.md`
- `plans/public-readiness-and-agent-continuity-rename/IMPL-0004-03-changelog-versioning-gate.md`
- `plans/agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md`

## Changes

- Made public install guidance preview-first and kept write mode explicit.
- Made `install.sh` default to `--dry-run` when it runs init and added a friendly
  Git preflight for clone/update paths.
- Made `scripts/agent-docs-init` dry-run output safe under ASCII/C locales.
- Added `scripts/release-check` and GitHub Actions CI for the smoke suite,
  Python compile, metadata checks, root link scan, changelog gate, diff hygiene,
  and local artifact scan.
- Added `CHANGELOG.md`, `scripts/changelog-check`, and smoke coverage for
  required changelog entries and explicit `Change-Record: not-needed`
  exemptions.
- Added basic community files and issue/PR templates.
- Added PLAN-0005 as the follow-up plan for manifest, read-only doctor, upgrade
  dry-run, and tooling-only write mode.

## Decisions

- Decision: leave the AGENT-DOCS name and repo paths unchanged in this pass.
  - Why: PLAN-0004 treats rename as a later coherent migration after hardening.
  - Source of truth: PLAN-0004 Task 5 status.
- Decision: use a targeted release-check wrapper instead of forcing
  `scripts/docs-meta --root . check`.
  - Why: AGENT-DOCS root docs are not a normal installed docs tree today, but
    root links still need scanning.
  - Source of truth: `scripts/release-check`.
- Decision: require changelog records only for adopter-facing surfaces.
  - Why: internal planning/session docs should not create release-note noise.
  - Source of truth: SPEC-0003 and `scripts/changelog-check`.

## Verification

- Commands run:
  - `tests/changelog-check-smoke.sh`
  - `scripts/changelog-check`
  - `scripts/release-check`
- Review gates:
  - Spec compliance subagent review passed.
  - Code quality subagent review passed after fixing two P2 findings.
- Not run:
  - GitHub Actions after push, because the changes have not been pushed yet.

## Follow-ups

- Run `gh run list --limit 5` after pushing to confirm CI.
- Keep PLAN-0005 as the next implementation sequence for safe doctor/upgrade.
- Rename/package/tag work remains deferred until after public-readiness hardening
  is reviewed on GitHub.
