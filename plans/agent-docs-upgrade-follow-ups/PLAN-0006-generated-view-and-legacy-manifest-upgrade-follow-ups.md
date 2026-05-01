---
type: plan
id: PLAN-0006
title: Generated View And Legacy Manifest Upgrade Follow-ups
domain: repo-health
status: in_progress
created_at: "2026-05-02 06:10:23 JST +0900"
updated_at: "2026-05-02 07:02:56 JST +0900"
planned_execution_start:
planned_execution_end:
actual_execution_start: "2026-05-02 06:36:33 JST +0900"
actual_execution_end:
owner: codex
sequence:
  roadmap:
  sort_key:
  lane: repo-health
  after:
    - PLAN-0005
  before: []
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
related_specs:
  - SPEC-0003
related_concepts:
  - CONC-0002
related_adrs: []
related_sessions:
  - session-logs/2026-05-02-plan-0005-closeout.md
  - session-logs/2026-05-02-plan-0006-briefing.md
  - session-logs/2026-05-02-impl-0006-01-legacy-manifest-baseline.md
related_issues: []
related_prs: []
repo_state:
  based_on_commit: fab90098867cf1f860ea3de2ca34b5d11ec5e27d
  last_reviewed_commit: fab90098867cf1f860ea3de2ca34b5d11ec5e27d
---

# PLAN-0006 - Generated View And Legacy Manifest Upgrade Follow-ups

**Goal:** Implement the post-PLAN-0005 upgrade work that was intentionally
deferred: deliberate manifest baselining for legacy installs first, then safe
generated-view write mode after the generator-specific safety model is proven.

**Status:** In progress. Legacy manifest baseline work from `IMPL-0006-01` is
implemented; generated-view writes remain a later task until a separate brief is
created.

**Source Spec:** [SPEC-0003 - AGENT-DOCS Versioning And Safe Upgrade](../agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md)

---

## Context

PLAN-0005 completed manifest writes for fresh installs, read-only `doctor`,
upgrade dry-run reporting, and narrow `upgrade --write --tooling-only` behavior.
Generated views remain report-only in that path, and unknown legacy installs
remain manual-review until AGENT-DOCS can intentionally create a trustworthy
baseline manifest.

## Scope

- Legacy manifest baselining for existing installs that predate
  `.agent-docs/manifest.json`, with explicit preview, ownership classification,
  and refusal of ambiguous project-owned Markdown.
- Generated-view upgrade writes for manifest-tracked generated views through
  known generator commands, with stale-input detection and refusal behavior for
  unknown or locally unsafe generator state.

## Non-Goals

- No project-owned Markdown replacement or merge automation.
- No broad `--force` semantics.
- No deletion of target-repo files because upstream no longer ships a template.
- No implementation work beyond `IMPL-0006-01` until additional tasks are
  promoted into concrete implementation briefs.

## Task Dependencies / Parallelization

- Task 1 comes first: legacy manifest baseline preview and write mode. This
  gives older installs a safe path into the manifest model before adding more
  write behavior.
- Task 2 can be designed independently after Task 1, but should reuse the
  PLAN-0005/Task 1 path-safety, backup, and manifest-last rules.
- Do not split Task 1 further unless implementation review finds the baseline
  command shape or safety model is too large for one pass.

## Implementation Tasks

### Task 1: Legacy Manifest Baseline

**Brief:** [IMPL-0006-01 - Legacy Manifest Baseline](implementation-briefs/IMPL-0006-01-legacy-manifest-baseline.md)

**Goal:** Add a preview-first way for legacy installs without
`.agent-docs/manifest.json` to create a manifest for AGENT-DOCS-owned tooling
only when ownership can be proven conservatively.

Core behavior:

- Add a dry-run/preview path that shows which files can be baselined and why.
- Add explicit write mode for creating `.agent-docs/manifest.json` only when
  every AGENT-DOCS-owned baseline candidate is known, regular, inside target,
  non-symlinked, and checksum/mode-compatible with the current upstream action
  set.
- Keep starter/project Markdown as `project-owned-after-install`; never
  checksum or auto-own local product/architecture/planning docs.
- Refuse unknown profiles, unknown optional components, path conflicts,
  symlinks, non-regular files, outside-root paths, and ambiguous legacy shapes.

Verification:

- Legacy target with known tooling and project docs previews then writes a valid
  manifest.
- Missing/unknown/drifted tooling remains manual-review or refused, not guessed.
- Project-owned Markdown is not modified.
- Write mode creates the manifest last; a second baseline write refuses cleanly
  because manifest updates belong to `agent-docs upgrade`.

### Task 2: Generated-View Upgrade Writes

**Brief:** not yet created.

**Goal:** Let upgrade write mode regenerate manifest-tracked generated views
through known generator commands after the generated-view safety model is
specified.

Keep this as a later brief because generator writes need separate decisions
around stale source docs, generator version drift, existing hand-edited generated
files, and whether generation should happen before or after owned-tooling
updates in one transaction.

## Validation

Expected validation should include:

```bash
scripts/release-check
git diff --check
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
```

Add targeted smoke tests for baseline creation before shipping Task 1. Add
separate targeted smoke tests for generated-view writes before shipping Task 2.

## Completion Criteria

- [x] Legacy baseline creation is explicit, previewable, and refuses ambiguous
  installs.
- [ ] Generated-view write semantics are specified and tested before mutation is
  enabled.
- [ ] PLAN-0005 tooling-only write mode remains unchanged unless a promoted
  task intentionally extends it.
