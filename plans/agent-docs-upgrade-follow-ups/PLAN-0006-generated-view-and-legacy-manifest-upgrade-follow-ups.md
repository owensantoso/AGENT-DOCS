---
type: plan
id: PLAN-0006
title: Generated View And Legacy Manifest Upgrade Follow-ups
domain: repo-health
status: draft
created_at: "2026-05-02 06:10:23 JST +0900"
updated_at: "2026-05-02 06:10:40 JST +0900"
planned_execution_start:
planned_execution_end:
actual_execution_start:
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
related_issues: []
related_prs: []
repo_state:
  based_on_commit: fab90098867cf1f860ea3de2ca34b5d11ec5e27d
  last_reviewed_commit: fab90098867cf1f860ea3de2ca34b5d11ec5e27d
---

# PLAN-0006 - Generated View And Legacy Manifest Upgrade Follow-ups

**Goal:** Define, but do not yet implement, the post-PLAN-0005 upgrade work
that was intentionally deferred: safe generated-view write mode and deliberate
manifest baselining for legacy installs.

**Status:** Draft/backlog. This plan records follow-up scope so PLAN-0005 can
close without implying these paths are already implementation-ready.

**Source Spec:** [SPEC-0003 - AGENT-DOCS Versioning And Safe Upgrade](../agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md)

---

## Context

PLAN-0005 completed manifest writes for fresh installs, read-only `doctor`,
upgrade dry-run reporting, and narrow `upgrade --write --tooling-only` behavior.
Generated views remain report-only in that path, and unknown legacy installs
remain manual-review until AGENT-DOCS can intentionally create a trustworthy
baseline manifest.

## Proposed Follow-Up Scope

- Generated-view upgrade writes for manifest-tracked generated views through
  known generator commands, with stale-input detection and refusal behavior for
  unknown or locally unsafe generator state.
- Legacy manifest baselining for existing installs that predate
  `.agent-docs/manifest.json`, with explicit preview, ownership classification,
  and refusal of ambiguous project-owned Markdown.

## Non-Goals

- No project-owned Markdown replacement or merge automation.
- No broad `--force` semantics.
- No deletion of target-repo files because upstream no longer ships a template.
- No implementation work until this draft is promoted and split into concrete
  execution tasks or implementation briefs.

## Task Dependencies / Parallelization

- Generated-view write mode can be specified independently from legacy baseline
  creation, as long as both share the PLAN-0005 ownership and path-safety rules.
- Legacy baseline work should define how to prove an existing installed tooling
  file is AGENT-DOCS-owned before any future write mode trusts it.

## Implementation Tasks

Draft tasks only:

- Specify the generated-view write safety model and verification fixtures.
- Specify the legacy baseline manifest workflow and refusal categories.
- Decide whether either path needs separate implementation briefs before work
  begins.

## Validation

When promoted, expected validation should include:

```bash
scripts/release-check
git diff --check
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
```

Add targeted smoke tests for generated-view writes or baseline creation before
shipping either behavior.

## Completion Criteria

- [ ] Generated-view write semantics are specified and tested before mutation is
  enabled.
- [ ] Legacy baseline creation is explicit, previewable, and refuses ambiguous
  installs.
- [ ] PLAN-0005 tooling-only write mode remains unchanged unless a promoted
  task intentionally extends it.
