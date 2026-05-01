---
type: plan
id: PLAN-DRAFT
title: Docs Operations Command Surface And Draft Promotion
domain: repo-health
status: draft
created_at: "2026-05-02 07:54:05 JST +0900"
updated_at: "2026-05-02 07:54:05 JST +0900"
owner: codex
sequence:
  roadmap:
  sort_key:
  lane: repo-health
  after:
    - PLAN-0006
  before: []
areas:
  - agent-docs
  - docs-ops
  - docs-meta
  - repo-health
related_specs:
  - SPEC-DRAFT-docs-ops-command-surface-and-draft-promotion
  - SPEC-0003
related_concepts:
  - CONC-0002
related_adrs: []
related_sessions:
  - session-logs/2026-05-02-docs-ops-draft-promotion-planning.md
related_issues: []
related_prs: []
repo_state:
  based_on_commit: f6719dd4eae34c5578f5c07b2b0ee251a69e730d
  last_reviewed_commit: f6719dd4eae34c5578f5c07b2b0ee251a69e730d
draft:
  promotion_target: plan
  promotion_reason: Avoid claiming PLAN-0007 while Agent Continuity and manifest work continues in parallel.
---

# PLAN-DRAFT - Docs Operations Command Surface And Draft Promotion

**Goal:** Introduce a clearer Docs Operations command surface for the current
`docs-meta` capability, add a safe draft-to-stable promotion workflow for
parallel planning branches, and prepare the feature for eventual package-style
organization without breaking installed repos.

**Status:** Draft. This plan should be promoted only after rebasing onto the
branch that will own the final stable `PLAN-*` ID.

**Source Spec:** [SPEC-DRAFT - Docs Operations Command Surface And Draft Promotion](SPEC-DRAFT-docs-ops-command-surface-and-draft-promotion.md)

---

## Context

`docs-meta` is now the deterministic docs operations tool for AGENT-DOCS:
creation, IDs, generated views, validation, TODOs, links, review queues, safe
moves, roadmap projections, and health checks. The name still works as a legacy
script path, but it no longer explains the user-facing capability well.

Separately, AGENT-DOCS planning docs currently allocate stable IDs by scanning a
single checkout. That works on one branch, but parallel worktrees can both claim
the same next `SPEC-*` or `PLAN-*` ID. This plan treats draft promotion as part
of the same Docs Operations boundary because ID allocation is one of the core
deterministic responsibilities.

## Scope

- Add a preferred `agent-docs docs ...` namespace for the existing docs
  operations command surface.
- Keep `scripts/docs-meta` working as a compatibility path.
- Add draft planning document support under `plans/drafts/`.
- Add explicit draft promotion behavior that assigns stable IDs after rebase or
  merge.
- Define the eventual `features/docs-ops/` package boundary without requiring a
  disruptive file move in the first implementation pass.
- Update docs so future humans and agents understand the naming, compatibility,
  and draft workflow.

## Non-Goals

- No immediate removal of `scripts/docs-meta`.
- No broad rename of historical `docs-meta` plans, session logs, generated
  headers, or installed manifest component names.
- No central ID service.
- No automatic promotion of drafts during ordinary checks.
- No attempt to make Docs Operations author or judge spec/plan substance.

## Architecture

The first implementation should be deliberately additive:

```text
agent-docs docs ...  -> preferred namespace
scripts/docs-meta    -> legacy compatibility command
```

In the first pass, `agent-docs docs` can delegate to the existing implementation
rather than moving the script into a package. The package layout can follow once
the command and draft contracts are stable:

```text
features/
  docs-ops/
    README.md
    feature.json
    bin/
      docs
    tests/
      docs-ops-smoke.sh
```

The stable installed target-repo command can remain `scripts/docs-meta` until an
upgrade path proves that a newer installed shape is safe.

## Task Dependencies / Parallelization

- Task 1 should happen first because it only changes documentation and command
  naming guidance.
- Task 2 can follow independently after Task 1 and should add non-mutating draft
  validation before write behavior.
- Task 3 depends on Task 2 because promotion relies on draft parsing and
  validation.
- Task 4 can be planned in parallel but should not move files until Tasks 1-3
  make the command contract stable.

## Implementation Tasks

### Task 1: Preferred Docs Operations Namespace

**Goal:** Add `agent-docs docs ...` as the preferred user-facing command surface
for existing docs operations without breaking `scripts/docs-meta`.

Expected behavior:

- `agent-docs docs check` delegates to the current docs check implementation.
- `agent-docs docs new`, `next`, `update`, `links`, `review`, `roadmap`,
  `health`, `move`, and related commands follow the existing `docs-meta`
  semantics.
- Help text and docs describe `Docs Operations` as the capability and
  `scripts/docs-meta` as the compatibility command.
- Existing tests for `scripts/docs-meta` continue to pass.

Suggested verification:

```bash
tests/docs-meta-smoke.sh
tests/agent-docs-init-smoke.sh
scripts/release-check
```

### Task 2: Draft Document Recognition And Validation

**Goal:** Teach Docs Operations that draft planning docs are allowed only in
approved draft locations and should not claim stable numeric IDs.

Expected behavior:

- `plans/drafts/SPEC-DRAFT-*.md` and `plans/drafts/PLAN-DRAFT-*.md` are
  recognized as draft planning docs.
- `scripts/docs-meta --root plans check` accepts draft docs only in
  `plans/drafts/`.
- Stable generated views exclude drafts unless a draft-specific view is
  requested.
- A stricter release check can report unresolved drafts before release or
  publication.

Suggested verification:

```bash
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
tests/docs-meta-smoke.sh
```

### Task 3: Draft Creation And Promotion Commands

**Goal:** Add explicit commands for creating and promoting draft docs.

Preferred commands:

```bash
agent-docs docs draft spec "Docs Operations Command Surface"
agent-docs docs draft plan "Docs Operations Migration"
agent-docs docs promote plans/drafts/SPEC-DRAFT-docs-ops-command-surface.md
```

Compatibility commands may also exist:

```bash
scripts/docs-meta draft spec "Docs Operations Command Surface"
scripts/docs-meta promote plans/drafts/SPEC-DRAFT-docs-ops-command-surface.md
```

Promotion should:

- require the source file to be an approved draft;
- compute the next stable ID from the current checkout;
- choose a stable destination path;
- update frontmatter `id`, `type`, `status`, timestamps, and draft metadata;
- update the main heading and self-references;
- refuse if the destination already exists;
- leave cross-file reference rewriting conservative unless explicitly requested;
- run or prompt for generated-view updates and checks.

Suggested verification:

```bash
tests/docs-meta-smoke.sh
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
git diff --check
```

### Task 4: Feature Package Preparation

**Goal:** Prepare Docs Operations for eventual feature-package organization
without requiring the first implementation to move every file.

Expected behavior:

- Add a `features/docs-ops/README.md` or equivalent landing document that maps
  the capability boundary, command surface, compatibility paths, tests, and
  install behavior.
- Add a manifest-shaped design for future source packaging.
- Keep root command paths stable until install and upgrade tooling can install
  from feature manifests safely.

Suggested verification:

```bash
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
scripts/release-check
```

## Promotion Path For This Draft

Before implementation, rebase this branch onto the target branch and promote
the draft spec and plan:

```bash
git pull --rebase
agent-docs docs promote plans/drafts/SPEC-DRAFT-docs-ops-command-surface-and-draft-promotion.md
agent-docs docs promote plans/drafts/PLAN-DRAFT-docs-ops-command-surface-and-draft-promotion.md
```

Until `agent-docs docs promote` exists, perform promotion manually with
`scripts/docs-meta --root plans next spec` and `scripts/docs-meta --root plans
next plan`, then update filenames, frontmatter, headings, links, generated
views, and checks.

## Verification For The Whole Plan

```bash
tests/docs-meta-smoke.sh
tests/agent-docs-init-smoke.sh
tests/agent-docs-doctor-upgrade-smoke.sh
scripts/release-check
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
git diff --check
```

## Done Checklist

- [ ] Preferred `agent-docs docs ...` command namespace exists.
- [ ] `scripts/docs-meta` remains compatible.
- [ ] Draft docs are recognized and constrained to approved draft locations.
- [ ] Draft creation and promotion commands exist.
- [ ] Promotion refuses collisions and updates the promoted doc consistently.
- [ ] Docs explain Docs Operations, compatibility, and draft promotion.
- [ ] Feature-package preparation is documented without breaking install flows.
