---
type: implementation-brief
id: IMPL-0007-01
title: Generated View Registration
domain: repo-health
status: completed
created_at: "2026-05-02 09:27:16 JST +0900"
updated_at: "2026-05-02 09:32:34 JST +0900"
parent_plan: PLAN-0007
task_refs:
  - task-1
  - task-2
  - task-3
owner: codex
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
depends_on:
  - PLAN-0006
parallel_with: []
related_specs:
  - plans/agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md
related_adrs: []
related_sessions:
  - session-logs/2026-05-02-impl-0007-01-generated-view-registration.md
related_issues: []
related_prs: []
linked_paths:
  - plans/generated-view-manifest-registration/PLAN-0007-generated-view-manifest-registration.md
  - scripts/agent-docs-init
  - scripts/agent-docs
  - tests/agent-docs-init-smoke.sh
  - tests/agent-docs-doctor-upgrade-smoke.sh
repo_state:
  based_on_commit: 537ffb81c867f4b3fa03717683e185d16e30366a
  last_reviewed_commit: 537ffb81c867f4b3fa03717683e185d16e30366a
---

# IMPL-0007-01 - Generated View Registration

## Parent Plan

[PLAN-0007 - Generated View Manifest Registration](../PLAN-0007-generated-view-manifest-registration.md)

## Task Goal

Register `scripts/docs-meta update` generated views in `.agent-docs/manifest.json`
without manual manifest editing.

Fresh installs that include `docs-meta` should generate and register known
generated views during explicit write mode. Legacy baselines should offer an
explicit registration option for existing generated views while keeping default
baseline behavior conservative.

## Command Shape

Fresh install remains the same command:

```bash
agent-docs-init /path/to/project --profile small --docs-meta yes --write
```

When `docs-meta` is included, write mode runs the trusted installed
`scripts/docs-meta update` equivalent after scaffold files are copied and before
the manifest is written. The manifest records produced known generated views
with `path`, `generator`, and `checksum_sha256`.

Baseline gets an explicit option:

```bash
agent-docs baseline --dry-run --generated-views /path/to/project --profile small --docs-meta yes
agent-docs baseline --write --generated-views /path/to/project --profile small --docs-meta yes
```

Baseline `--generated-views` should register only existing recognized generated
views. It must not run a generator or overwrite files in this slice.

## Scope

- Add shared generated-view registration helpers for known
  `scripts/docs-meta update` outputs.
- During fresh install write mode with `docs-meta`, generate known views and
  record checksums in the new manifest.
- During baseline with `--generated-views`, record existing generated views only
  when they are known outputs, regular files, inside the target, and visibly
  generated.
- Keep default baseline behavior unchanged unless `--generated-views` is passed.
- Update README/plan/session docs for the new registration behavior.
- Add smoke coverage proving fresh install and legacy baseline manifests contain
  generated-view records without manual manifest edits.

## Non-Goals

- Do not infer generated-view records for installs without `docs-meta`.
- Do not make baseline run `scripts/docs-meta update`.
- Do not overwrite source-of-truth Markdown in baseline mode.
- Do not broaden the generated-view write command beyond manifest-tracked views.
- Do not add arbitrary generator support.

## Safety Rules

- Generated-view records use only supported generator
  `scripts/docs-meta update`.
- Paths must be known outputs for that generator.
- Paths must be relative, inside the target, non-symlinked, and regular files.
- Baseline registration requires a generated-view marker before recording an
  existing output.
- If baseline `--generated-views` is requested with `--docs-meta no`, refuse or
  report manual review rather than recording unusable generator records.
- Manifest writes remain last.

## Suggested TDD Steps

1. Add failing smoke coverage for fresh install generated-view records.
2. Add failing smoke coverage for baseline `--generated-views` registration.
3. Implement minimal registration helpers and wire fresh install.
4. Wire baseline `--generated-views` with conservative existing-file checks.
5. Update README, PLAN-0007, this brief, and session log.
6. Run focused checks, review gates, and full release verification.

## Verification

```bash
tests/agent-docs-init-smoke.sh
tests/agent-docs-doctor-upgrade-smoke.sh
scripts/release-check
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
git diff --check
```

## Done Checklist

- [x] Fresh installs with `docs-meta` record generated views without manual
  manifest edits.
- [x] Baseline `--generated-views` records existing recognized generated views
  while default baseline remains unchanged.
- [x] Generated-view registration refuses or skips ambiguous unsafe outputs.
- [x] PLAN-0006 generated-view writes remain opt-in and manifest-tracked only.
- [x] Docs, session log, review gates, and full verification are complete.
