---
type: plan
id: PLAN-0007
title: Generated View Manifest Registration
domain: repo-health
status: draft
created_at: "2026-05-02 09:17:43 JST +0900"
updated_at: "2026-05-02 09:17:43 JST +0900"
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
    - PLAN-0006
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
  - session-logs/2026-05-02-plan-0004-closeout.md
related_issues: []
related_prs: []
repo_state:
  based_on_commit: 639228d728c5a36e179c829cb661504af53be09b
  last_reviewed_commit: 639228d728c5a36e179c829cb661504af53be09b
---

# PLAN-0007 - Generated View Manifest Registration

**Goal:** Make PLAN-0006 generated-view upgrade writes useful without manual
manifest editing by adding a safe way for fresh installs and legacy baselines to
record generated-view manifest entries.

**Status:** Draft. This is the next likely implementation direction after
PLAN-0006, but it still needs a focused brief before coding.

**Source Spec:** [SPEC-0003 - AGENT-DOCS Versioning And Safe Upgrade](../agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md)

---

## Context

PLAN-0006 added:

- `agent-docs baseline` for legacy installs without manifests;
- `agent-docs upgrade --write --tooling-only --generated-views` for
  manifest-tracked generated views.

Fresh installs and baselines still write:

```json
"generated_views": []
```

That means generated-view writes are safe but not yet ergonomic: they only work
when a generated-view record is already present in the manifest.

## Scope

- Decide when generated views are applicable for each profile and optional
  component set.
- Add generated-view manifest records for installs that include `docs-meta`,
  after generated files exist and can be checksummed.
- Add an explicit legacy-baseline path for registering or refreshing generated
  views without guessing ownership of project-authored docs.
- Reuse PLAN-0006 safety checks for supported generator commands, output
  allowlists, generated markers, symlinks, hardlinks, non-regular paths, backup
  destinations, generator trust, and manifest-last writes.

## Non-Goals

- Do not make baseline overwrite source-of-truth Markdown by default.
- Do not record generated views for installs that do not include `docs-meta`.
- Do not accept arbitrary generator commands from manifests.
- Do not broaden generated-view writes beyond manifest-tracked files.

## Open Design Questions

- Should fresh `agent-docs-init --docs-meta yes --write` run
  `scripts/docs-meta update` automatically, or should it only record generated
  views that already exist?
- Should baseline have a separate explicit flag, such as `--generated-views`, to
  refresh and register generated views?
- Which generated views should be registered for small/growing/full profiles?
- Should missing generated views during baseline be refused, generated, or
  ignored unless explicitly requested?

## Candidate Implementation Slices

### Task 1: Design And Brief

Create an implementation brief that chooses install/baseline command semantics
and exact generated-view registration rules.

### Task 2: Fresh Install Generated-View Registration

For installs that include `docs-meta`, generate or detect applicable generated
views, record their checksums in `.agent-docs/manifest.json`, and prove the
round trip with `agent-docs upgrade --write --tooling-only --generated-views`.

### Task 3: Legacy Baseline Generated-View Registration

Add an explicit baseline registration path for generated views, keeping default
baseline conservative.

## Validation

Expected validation should include:

```bash
tests/agent-docs-init-smoke.sh
tests/agent-docs-doctor-upgrade-smoke.sh
scripts/release-check
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
git diff --check
```

## Completion Criteria

- [ ] Fresh installs that include `docs-meta` can produce manifest-tracked
  generated views without manual manifest edits.
- [ ] Legacy baselines have an explicit safe path for generated-view
  registration or refresh.
- [ ] Generated-view registration refuses ambiguous or unsafe generated outputs.
- [ ] PLAN-0006 generated-view upgrade writes remain opt-in and manifest-tracked
  only.
