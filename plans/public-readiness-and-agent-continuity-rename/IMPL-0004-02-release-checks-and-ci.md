---
type: implementation-brief
id: IMPL-0004-02
title: Release Checks And CI
domain: repo-health
status: completed
created_at: "2026-05-02 02:13:08 JST +0900"
updated_at: "2026-05-02 09:17:43 JST +0900"
parent_plan: PLAN-0004
task_refs:
  - task-2
depends_on:
  - task-0
parallel_with:
  - IMPL-0004-01
areas:
  - docs-meta
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

# IMPL-0004-02 - Release Checks And CI

## Parent Plan

[PLAN-0004 - Public Readiness And Agent Continuity Rename](PLAN-0004-public-readiness-and-agent-continuity-rename.md)

## Task Goal

Make AGENT-DOCS public-readiness checks repeatable locally and in GitHub Actions.

## Scope

- Add a CI workflow for installer/init/docs-meta smoke tests, Python compile, and
  diff hygiene.
- Define a release-grade local check for AGENT-DOCS itself.
- Decide whether to adapt `scripts/docs-meta --root . check` or create a
  dedicated release-check wrapper.
- Ensure link checks are meaningful or explicitly documented when waived.

## Non-Goals

- Do not implement changelog enforcement in this brief; it belongs to
  `IMPL-0004-03`.
- Do not publish releases or tags.
- Do not add package-manager distribution.

## Files Likely To Change

```text
.github/workflows/ci.yml
scripts/docs-meta
scripts/README.md
tests/docs-meta-smoke.sh
README.md
```

## Verification

```bash
tests/install-smoke.sh
tests/agent-docs-init-smoke.sh
tests/docs-meta-smoke.sh
python3 -m py_compile scripts/agent-docs-init scripts/docs-meta
git diff --check
```

After push:

```bash
gh run list --limit 5
```

## Review Focus

- CI runs the same checks humans are asked to trust.
- Release checks do not silently pass by scanning an empty or irrelevant docs
  root.
- Link-check failures are either fixed or explicitly justified.

## Closeout

Completed as part of PLAN-0004 public-readiness hardening. GitHub Actions is
green on `main` at `639228d`.
