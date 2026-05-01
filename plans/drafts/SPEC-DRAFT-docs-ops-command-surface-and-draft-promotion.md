---
type: spec
id: SPEC-DRAFT-docs-ops-command-surface-and-draft-promotion
title: Docs Operations Command Surface And Draft Promotion
spec_type: repo-health
domain: repo-health
status: draft
created_at: "2026-05-02 07:54:05 JST +0900"
updated_at: "2026-05-02 07:54:05 JST +0900"
owner: codex
source:
  type: conversation
  link:
  notes: Human asked whether docs-meta should be renamed and whether draft specs/plans should be promoted after rebasing to avoid parallel worktree ID conflicts.
areas:
  - agent-docs
  - docs-ops
  - docs-meta
  - repo-health
related_specs:
  - SPEC-0003
related_plans:
  - PLAN-0004
  - PLAN-0006
  - PLAN-DRAFT-docs-ops-command-surface-and-draft-promotion
related_concepts:
  - CONC-0002
related_sessions:
  - session-logs/2026-05-02-docs-ops-draft-promotion-planning.md
supersedes: []
superseded_by: []
repo_state:
  based_on_commit: f6719dd4eae34c5578f5c07b2b0ee251a69e730d
  last_reviewed_commit: f6719dd4eae34c5578f5c07b2b0ee251a69e730d
draft:
  promotion_target: spec
  promotion_reason: Avoid claiming SPEC-0004 while Agent Continuity and manifest work continues in parallel.
---

# SPEC-DRAFT - Docs Operations Command Surface And Draft Promotion

## Summary

`docs-meta` has grown from a metadata helper into the deterministic docs
operations surface for AGENT-DOCS repositories. AGENT-DOCS should introduce a
clearer public command namespace while preserving the existing `scripts/docs-meta`
command as a compatibility path.

The same work should add a draft-to-stable promotion workflow for specs, plans,
and related planning docs. Draft promotion lets parallel worktrees capture
planning intent without racing for the next `SPEC-*`, `PLAN-*`, or `IMPL-*`
number.

## Problem

The name `docs-meta` now understates the tool's current scope. It creates docs,
assigns IDs, updates generated views, validates frontmatter, manages structured
TODOs, reports review queues, checks links, finds backlinks and orphans,
normalizes links, moves docs safely, projects roadmap views, and reports docs
health.

At the same time, multiple agents or worktrees can independently run
`scripts/docs-meta --root plans next spec` and receive the same next ID. That is
correct for a single checkout but unsafe for parallel planning branches. The
collision is only discovered when branches are merged.

## Goals

- Introduce a clearer preferred command surface for deterministic docs
  operations.
- Keep the existing `scripts/docs-meta` command working for installed repos,
  generated headers, documentation examples, and compatibility.
- Define a feature/package boundary that can later live under
  `features/docs-ops/`.
- Add a draft planning workflow that avoids stable ID conflicts across parallel
  worktrees.
- Promote drafts only after rebasing or merging onto the branch that will own
  the final stable ID.
- Keep Markdown files, filenames, and frontmatter as the source of truth.

## Non-Goals

- Do not immediately hard-rename every `docs-meta` path, flag, generated header,
  manifest component, test, or historical plan.
- Do not make AGENT-DOCS decide the substantive content of specs, plans, or
  product decisions.
- Do not require a central server, lock service, or database to allocate IDs.
- Do not make draft docs valid release artifacts unless they live in explicitly
  allowed draft locations.
- Do not auto-renumber stable docs during ordinary checks.

## Desired Command Model

The preferred long-term command shape should be:

```bash
agent-docs docs new ...
agent-docs docs check
agent-docs docs review
agent-docs docs links
agent-docs docs move ...
agent-docs docs health
agent-docs docs draft spec "Docs Operations Command Surface"
agent-docs docs promote plans/drafts/SPEC-DRAFT-docs-ops-command-surface-and-draft-promotion.md
```

The compatibility command remains:

```bash
scripts/docs-meta ...
```

The feature may be described as `Docs Operations`. The architectural boundary is
the deterministic docs control plane for AGENT-DOCS repositories.

## Docs Operations Boundary

Docs Operations owns mechanical operations over repo-owned documentation:

- create docs from known families;
- assign stable IDs;
- validate frontmatter and generated views;
- update generated registries;
- list and validate structured TODOs;
- report review queues and docs health;
- inspect links, backlinks, and orphans;
- normalize links;
- move docs safely with link updates;
- project roadmap views.

Docs Operations does not own human or agent judgment:

- product direction;
- architecture choices;
- spec or plan substance;
- arbitrary source-code summarization;
- general skill routing;
- GitHub issue management as a source of truth.

## Draft Planning Workflow

Draft specs and plans should live in an explicit draft location:

```text
plans/drafts/
```

Draft filenames should avoid stable numeric IDs:

```text
SPEC-DRAFT-docs-ops-command-surface-and-draft-promotion.md
PLAN-DRAFT-docs-ops-migration.md
IMPL-DRAFT-docs-ops-command-alias.md
```

Draft frontmatter should make the temporary state explicit:

```yaml
type: spec
id: SPEC-DRAFT-docs-ops-command-surface-and-draft-promotion
status: draft
draft:
  promotion_target: spec
  promotion_reason: Avoid claiming a stable ID in parallel work.
```

Promotion should happen after the branch is rebased onto the branch it will
merge into:

```bash
git pull --rebase
agent-docs docs promote plans/drafts/SPEC-DRAFT-docs-ops-command-surface-and-draft-promotion.md
```

The promotion command should:

- compute the next stable ID from the current target branch state;
- rename the file and heading;
- rewrite the draft `id`, `type`, status fields, and promotion metadata;
- update self-references inside the promoted doc;
- optionally move the document from `plans/drafts/` into a stable topic folder;
- run or instruct the user to run generated-view updates and checks.

## Validation Rules

Docs checks should allow draft IDs only in approved draft locations. A future
release check should fail if draft docs remain outside those locations or if a
release branch still contains unresolved planning drafts.

At minimum:

- `SPEC-DRAFT-*` is valid only under `plans/drafts/` until promoted.
- `PLAN-DRAFT-*` is valid only under `plans/drafts/` until promoted.
- `IMPL-DRAFT-*` is valid only under `plans/drafts/` or an explicitly approved
  draft implementation-brief location.
- Stable generated views should not list draft docs unless a specific draft view
  is requested.
- Promotion must refuse when the destination path already exists.

## Migration Strategy

1. Add draft docs and command-surface guidance without renaming installed
   `docs-meta` paths.
2. Add `agent-docs docs ...` as a preferred alias over the existing command
   implementation.
3. Add draft validation to checks in report-only form.
4. Add `draft` and `promote` commands.
5. Package the capability under a future `features/docs-ops/` bundle while
   keeping `scripts/docs-meta` as a shim or portable copied command.
6. Update docs to describe `docs-meta` as the legacy compatibility command.

## Related Draft Plan

[PLAN-DRAFT - Docs Operations Command Surface And Draft Promotion](PLAN-DRAFT-docs-ops-command-surface-and-draft-promotion.md)

## Open Questions

- Should the stable package folder be `features/docs-ops/`,
  `features/docs-operations/`, or `features/agent-docs-docs/`?
- Should target repos install only `scripts/docs-meta`, only `agent-docs`, or
  both?
- Should draft docs ever be committed to long-lived branches, or should they be
  short-lived branch artifacts only?
- Should promotion update cross-file references automatically in the first pass,
  or begin with self-reference rewrites and explicit follow-up guidance?
