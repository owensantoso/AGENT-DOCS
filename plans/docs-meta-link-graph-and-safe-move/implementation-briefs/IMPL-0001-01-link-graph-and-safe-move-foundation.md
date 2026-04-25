---
type: implementation-brief
id: IMPL-0001-01
title: Link Graph and Safe Move Foundation
domain: docs-meta
status: completed
created_at: "2026-04-25 18:32:17 JST +0900"
updated_at: "2026-04-25 19:37:16 JST +0900"
planned_execution_start:
planned_execution_end:
actual_execution_start:
actual_execution_end: "2026-04-25 19:37:16 JST +0900"
parent_plan: PLAN-0001
task_refs:
  - task-1
  - task-2
  - task-3
  - task-4
  - task-5
  - task-6
owner:
areas:
  - docs
  - docs-meta
depends_on: []
parallel_with: []
related_specs: []
related_adrs: []
related_sessions: []
related_issues: []
repo_state:
  based_on_commit: a4f9e21abc4337a886096625c8fabb3643ae884f
  last_reviewed_commit: a4f9e21abc4337a886096625c8fabb3643ae884f
---

# Implementation Brief - Link Graph and Safe Move Foundation

## Parent Plan

- [PLAN-0001 - Docs Link Graph and Safe Move Tooling](../PLAN-0001-docs-meta-link-graph-and-safe-move.md)

This brief intentionally groups the full first implementation pass because parser, resolver, read-only graph commands, health integration, normalization, and safe move behavior all share the same link graph model.

## Task Goal

Add a conservative link graph layer to `scripts/docs-meta`, then expose backlinks, broken-link checks, orphan checks, relative-link normalization, and safe doc move previews.

After this task:

- `docs-meta` can answer “what links to this doc?”
- broken repo-local links are deterministic check output
- orphan docs can be reviewed with allowlists
- repo-local absolute links can be normalized to relative Markdown links
- doc moves can be dry-run before any file or backlink changes

## Scope

In scope:

- link parsing and resolution for Markdown docs
- read-only link graph commands
- advisory link-health rollup
- dry-run-first link normalization
- dry-run-first safe doc move/rename
- docs updates for link style and move workflow

Out of scope:

- external URL validation
- auto-rewriting prose mentions
- Obsidian wiki links as canonical format
- mass-renaming historical plans/specs
- replacing `scripts/docs-generate`

## Ownership

- Owns: AGENT-DOCS `scripts/docs-meta`, docs-meta generated views, docs link workflow docs, and smoke tests.
- Adjacent briefs own: future broader docs layout changes or historical plan renaming.
- Integration expectation: implement as one bounded repo-health tooling slice; keep generated output updated after source changes.

## Preserve

- `scripts/docs-meta check` remains deterministic and quiet when docs are valid.
- `scripts/docs-generate` remains separate from docs-meta.
- Generated views are regenerated, not hand-edited.
- Safe move and normalize commands do not mutate files unless explicitly requested.

## Dependencies / Parallelization

- Depends on: parent-plan prerequisites only.
- Can run in parallel with: none for implementation; review can run in parallel after the first working parser.
- Write-conflict notes: avoid unrelated docs layout moves while implementing move tooling.

## Entry Point

- Start from: [scripts/docs-meta](../../../scripts/docs-meta)
- Main seam to extend: docs-meta scan/update/check command structure.

## Files To Read First

- [scripts/docs-meta](../../../scripts/docs-meta)
- [README.md](../../../README.md)
- [guides/workflow-overview.md](../../../guides/workflow-overview.md)
- [guides/adoption-checklist.md](../../../guides/adoption-checklist.md)
- [plans/README.md](../../README.md)

## Files Likely To Change

Create:

```text
temporary test fixtures if needed
```

Modify:

```text
scripts/docs-meta
docs/README.md
docs/repo-health/README.md
docs/repo-health/planning/README.md
docs/HEALTH.md
docs/DOCS-REGISTRY.md
```

## Execution Steps

### 1. Build LinkRef parsing and resolution

Add structured link records and a resolver that can classify repo-local docs, repo-local non-doc files, folders, fragments, external URLs, generated files, and missing targets.

### 2. Add read-only graph commands

Implement `links`, `backlinks`, `check-links`, and `orphans` before any command that writes files.

### 3. Add health integration

Fold broken links, absolute repo-local links, and orphans into advisory health output with allowlists.

### 4. Add relative-link normalization

Implement `normalize-links --style relative --dry-run`, then write mode. Preserve labels and fragments.

### 5. Add safe move

Implement `move OLD NEW --dry-run`, then write mode. Refuse high-risk moves by default when appropriate and report prose mentions separately.

### 6. Document and close out

Document canonical link style, move workflow, backlink lookup, and orphan review. Regenerate views and run final checks.

## Verification

Run:

```bash
scripts/docs-meta links
scripts/docs-meta backlinks docs/README.md
scripts/docs-meta check-links
scripts/docs-meta orphans
scripts/docs-meta normalize-links --style relative --dry-run
scripts/docs-meta update
scripts/docs-meta check
scripts/docs-generate --check
git diff --check
```

Also run a safe-move fixture check before using the command on real docs:

```bash
scripts/docs-meta move <fixture-old.md> <fixture-new.md> --dry-run
```

## Risks / Traps

- Link parsing with regex can damage Markdown if write-mode rewrites too broadly.
- Orphan reports can become noisy without explicit allowlists.
- Absolute filesystem links may be useful in local Codex UI, but should not be canonical repo docs links.
- Folder links need clear behavior: prefer folder `README.md` when it exists.
- Historical migration records may intentionally contain old paths and should not be treated as live broken links.

## Review Focus

- Spec reviewer: confirm the commands match the link-style and safe-move policy.
- Code reviewer: scrutinize parser boundaries, dry-run output, path resolution, and write-mode safety.

## Done Checklist

- [x] shared link graph exists
- [x] backlinks command works for path or ID
- [x] broken-link check works
- [x] orphan check works
- [x] normalize-links dry-run and write mode work
- [x] move dry-run and write mode work
- [x] docs health includes link signals
- [x] docs workflow docs are updated
- [x] verification commands pass
