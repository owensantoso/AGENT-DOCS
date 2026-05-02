---
type: implementation-brief
id: IMPL-0004-01
title: Public Install Docs Portability Hardening
domain: repo-health
status: completed
created_at: "2026-05-02 02:13:08 JST +0900"
updated_at: "2026-05-02 09:17:43 JST +0900"
parent_plan: PLAN-0004
task_refs:
  - task-1
depends_on:
  - task-0
parallel_with:
  - IMPL-0004-02
areas:
  - agent-docs-init
  - repo-health
related_specs:
  - SPEC-0003
related_sessions:
  - session-logs/2026-05-02-plan-0004-public-readiness.md
  - session-logs/2026-05-02-plan-0004-closeout.md
repo_state:
  based_on_commit: 7b540a5b90f7f318f80d5e0e2dc66ae90afea269
  last_reviewed_commit: 639228d728c5a36e179c829cb661504af53be09b
---

# IMPL-0004-01 - Public Install Docs Portability Hardening

## Parent Plan

[PLAN-0004 - Public Readiness And Agent Continuity Rename](PLAN-0004-public-readiness-and-agent-continuity-rename.md)

## Task Goal

Make the public install/readme surface preview-first, portable, and accurate for
both small and growing/full profiles.

## Scope

- Change public quick-start docs to lead with dry-run/no-run before write mode.
- Document supported platforms and prerequisites.
- Fix or replace private-fork token instructions so secrets are not encouraged in
  visible shell commands.
- Split small-profile handoff/readme instructions from growing/full paths.
- Fix `agent-docs-init` ASCII/C locale dry-run crashes.
- Add a friendly `git` preflight or equivalent clear failure.

## Non-Goals

- Do not rename the project or command.
- Do not add Homebrew, pip, or npm packaging.
- Do not build `doctor` or upgrade commands.

## Files Likely To Change

```text
README.md
INSTALL.md
install.sh
scripts/agent-docs-init
scripts/README.md
guides/adoption-checklist.md
tests/agent-docs-init-smoke.sh
tests/install-smoke.sh
```

## Verification

```bash
LC_ALL=C PYTHONUTF8=0 scripts/agent-docs-init /tmp/agent-docs-check --profile small --dry-run
tests/agent-docs-init-smoke.sh
tests/install-smoke.sh
python3 -m py_compile scripts/agent-docs-init
git diff --check
```

## Review Focus

- Public first-run behavior is non-surprising.
- Small-profile docs reference files that actually exist.
- No command examples expose secret values in process listings or shell history
  without a warning and safer alternative.

## Closeout

Completed as part of PLAN-0004 public-readiness hardening. Verification is
recorded in the linked session logs and `scripts/release-check`.
