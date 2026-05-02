---
type: implementation-brief
id: IMPL-0008-01
title: Command And Profile Rename
domain: repo-health
status: completed
created_at: "2026-05-02 10:37:34 JST +0900"
updated_at: "2026-05-02 11:08:26 JST +0900"
parent_plan: PLAN-0008
task_refs:
  - task-1
owner: codex
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
depends_on:
  - PLAN-0008
parallel_with: []
related_specs: []
related_adrs: []
related_sessions:
  - session-logs/2026-05-02-impl-0008-01-command-and-profile-rename.md
related_issues: []
related_prs: []
linked_paths:
  - plans/agent-continuity-public-rename/PLAN-0008-agent-continuity-public-rename.md
  - install.sh
  - scripts/agent-docs
  - scripts/agent-docs-init
  - tests/install-smoke.sh
  - tests/agent-docs-init-smoke.sh
  - tests/agent-docs-doctor-upgrade-smoke.sh
repo_state:
  based_on_commit: c7d989bed4f6c3a3806b5f4d3717d78eb85f6bf0
  last_reviewed_commit: c7d989bed4f6c3a3806b5f4d3717d78eb85f6bf0
---

# IMPL-0008-01 - Command And Profile Rename

## Parent Plan

[PLAN-0008 - Agent Continuity Public Rename](../PLAN-0008-agent-continuity-public-rename.md)

## Task Goal

Implement the first public rename slice:

- primary command: `agent-continuity`;
- compatibility commands: `agent-docs`, `agent-docs-init`;
- public profiles: `core`, `standard`, `expanded`, `complete`;
- compatibility profile aliases: `tiny`, `small`, `growing`, `full`.

## Scope

- Update installer symlink installation so `agent-continuity` is installed when
  `scripts/agent-docs` is available.
- Keep installer refusal behavior safe for existing unrelated commands.
- Make `agent-continuity init` and `agent-docs init` share implementation.
- Update profile parsing in `scripts/agent-docs-init` so old names resolve to
  canonical new profile keys.
- Update baseline profile parsing in `scripts/agent-docs` the same way.
- Ensure new manifests write canonical profile keys.
- Update smoke tests for new commands and aliases.
- Update README, INSTALL, CHANGELOG, PLAN-0008, this brief, and add a session
  log.

## Non-Goals

- Do not rename files on disk such as `scripts/agent-docs` in this slice.
- Do not rename `.agent-docs/manifest.json`.
- Do not remove old command/profile names.
- Do not rename the repository or add package-manager distribution.
- Do not add on-demand audit/template commands yet.

## TDD Steps

1. Add failing tests for `agent-continuity` install and `agent-continuity init`.
2. Add failing tests for new profile names and old aliases.
3. Implement profile alias resolution and canonical manifest writes.
4. Implement installer command alias.
5. Update docs and paper trail.
6. Run focused tests and full release verification.

## Verification

```bash
tests/install-smoke.sh
tests/agent-docs-init-smoke.sh
tests/agent-docs-doctor-upgrade-smoke.sh
scripts/release-check
scripts/changelog-check
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
git diff --check
```

## Done Checklist

- [x] `agent-continuity` command installs and works.
- [x] New profile names work and write canonical profile values.
- [x] Old profile aliases continue to work.
- [x] Baseline accepts new and old profile names.
- [x] Docs/changelog/paper trail are updated.
- [x] Full verification passes.
- [x] Coordinator review gates pass.
