---
type: session-log
title: IMPL-0008-01 Command And Profile Rename
domain: repo-health
status: completed
created_at: "2026-05-02 10:43:16 JST +0900"
updated_at: "2026-05-02 11:08:26 JST +0900"
started_at: "2026-05-02 10:37:34 JST +0900"
ended_at: "2026-05-02 11:08:26 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
related_plans:
  - plans/agent-continuity-public-rename/PLAN-0008-agent-continuity-public-rename.md
related_briefs:
  - plans/agent-continuity-public-rename/implementation-briefs/IMPL-0008-01-command-and-profile-rename.md
related_specs: []
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-05-02 - IMPL-0008-01 Command And Profile Rename

## Session metadata

- Started: 2026-05-02 10:37:34 JST +0900
- Ended: 2026-05-02 11:08:26 JST +0900
- Timezone: JST +0900
- Participants: Owen, Codex
- Todo-backed work: none

## Goal

Implement the first public rename slice from PLAN-0008: install
`agent-continuity`, keep `agent-docs` and `agent-docs-init` compatibility, and
rename public install profiles to `core`, `standard`, `expanded`, and
`complete`.

## Changes

- `install.sh` now installs `agent-continuity` as the primary command symlink to
  `scripts/agent-docs`, while preserving existing command symlinks.
- `scripts/agent-docs-init` accepts canonical profile keys and compatibility
  aliases, then writes canonical profile values to new manifests.
- `scripts/agent-docs` baseline and manifest comparison paths resolve old
  aliases to canonical profile actions.
- README, INSTALL, CHANGELOG, PLAN-0008, and IMPL-0008-01 now describe the
  public command/profile rename and compatibility behavior.
- Smoke tests cover `agent-continuity` installation/delegation, canonical
  profile manifests, and compatibility aliases.
- Review fixes made the command wrapper self-identify as `agent-continuity`
  for help, init help, recommendations, refusal text, and audit records when
  invoked through the primary command.

## Verification

- `tests/install-smoke.sh`
- `tests/agent-docs-init-smoke.sh`
- `tests/agent-docs-doctor-upgrade-smoke.sh`
- `scripts/release-check`
- `scripts/changelog-check`
- `scripts/docs-meta --root plans check`
- `scripts/docs-meta --root plans check-links`
- `git diff --check`
