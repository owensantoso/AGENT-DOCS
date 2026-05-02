---
type: plan
id: PLAN-0008
title: Agent Continuity Public Rename
domain: repo-health
status: completed
created_at: "2026-05-02 10:37:34 JST +0900"
updated_at: "2026-05-02 11:08:26 JST +0900"
planned_execution_start:
planned_execution_end:
actual_execution_start: "2026-05-02 10:37:34 JST +0900"
actual_execution_end: "2026-05-02 11:08:26 JST +0900"
owner: codex
sequence:
  roadmap:
  sort_key:
  lane: repo-health
  after:
    - PLAN-0004
    - PLAN-0007
  before: []
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
related_specs: []
related_concepts:
  - CONC-0002
related_adrs: []
related_sessions:
  - session-logs/2026-05-02-impl-0008-01-command-and-profile-rename.md
related_issues: []
related_prs: []
repo_state:
  based_on_commit: c7d989bed4f6c3a3806b5f4d3717d78eb85f6bf0
  last_reviewed_commit: c7d989bed4f6c3a3806b5f4d3717d78eb85f6bf0
---

# PLAN-0008 - Agent Continuity Public Rename

## Goal

Make the public-facing command and install language use `agent-continuity` while
keeping existing `agent-docs` and `agent-docs-init` commands working as
compatibility aliases.

At the same time, rename public install profiles from size/maturity wording to
footprint wording:

| Old alias | New profile |
|---|---|
| `tiny` | `core` |
| `small` | `standard` |
| `growing` | `expanded` |
| `full` | `complete` |

`standard` should be the recommended default.

## Product Rule

Profiles choose the starting local scaffold footprint only. They do not limit
available capabilities. Audits, templates, generated views, and future
`agent-continuity` commands should be available on demand from any profile when
the relevant tooling is installed or explicitly requested.

## Scope

- Install a primary `agent-continuity` command.
- Allow `agent-continuity init|doctor|upgrade|baseline` to use the existing
  command implementation.
- Add new profile names `core`, `standard`, `expanded`, and `complete`.
- Keep old profile names as aliases for at least one release cycle.
- Record canonical profile names in new manifests.
- Accept old aliases in baseline/upgrade-compatible paths where profile input is
  required, but keep safety checks unchanged.
- Update README, INSTALL, changelog, and tests.

## Non-Goals

- Do not rename the GitHub repository in this slice.
- Do not remove `agent-docs` or `agent-docs-init`.
- Do not add Homebrew packaging.
- Do not build the future on-demand audit/template command catalog yet.
- Do not change generated-view write safety or manifest schema version.

## Compatibility

Existing commands must continue to work:

```bash
agent-docs-init --profile small --write
agent-docs init --profile growing --dry-run
agent-docs baseline --profile small --docs-meta yes --dry-run
```

New commands should be documented as preferred:

```bash
agent-continuity init --profile standard --dry-run
agent-continuity init --profile standard --docs-meta yes --write
agent-continuity baseline --profile standard --docs-meta yes --dry-run
```

## Validation

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

## Completion Criteria

- [x] `agent-continuity` installs and delegates to the command namespace.
- [x] New profile names work for init and baseline.
- [x] Old profile aliases still work.
- [x] New manifests record canonical profile names.
- [x] Docs explain profiles as starting footprints, not capability limits.
- [x] Changelog records adopter-facing command/profile changes.
- [x] Full verification passes.
- [x] Coordinator review gates pass.
