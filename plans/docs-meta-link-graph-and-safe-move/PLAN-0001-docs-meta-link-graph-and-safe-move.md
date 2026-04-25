---
type: plan
id: PLAN-0001
title: Docs Link Graph and Safe Move Tooling
domain: docs-meta
status: completed
created_at: "2026-04-25 18:32:17 JST +0900"
updated_at: "2026-04-25 19:37:16 JST +0900"
planned_execution_start:
planned_execution_end:
actual_execution_start:
actual_execution_end: "2026-04-25 19:37:16 JST +0900"
owner:
sequence:
  roadmap:
  sort_key:
  lane: docs-meta
  after: []
  before: []
areas:
  - docs
  - docs-meta
related_specs: []
related_adrs: []
related_sessions: []
related_issues: []
repo_state:
  based_on_commit: a4f9e21abc4337a886096625c8fabb3643ae884f
  last_reviewed_commit: a4f9e21abc4337a886096625c8fabb3643ae884f
---

# PLAN-0001 - Docs Link Graph and Safe Move Tooling

**Goal:** Extend `scripts/docs-meta` from metadata/generated-view tooling into a lightweight docs knowledge-base tool that can inspect links, report backlinks and orphans, normalize repo-local links, and safely move or rename docs with reference updates.

**Architecture:** Add a shared link graph layer inside `scripts/docs-meta` before adding any mutating commands. The graph should parse Markdown links, image links, and optional Obsidian-style wikilinks into structured records; resolve each repo-local target; then power read-only commands first. Safe move and normalize commands should be explicit, conservative, and dry-run by default so docs cleanup does not become silent path churn.

**Tech Stack:** AGENT-DOCS `scripts/docs-meta`, Markdown docs, YAML frontmatter, generated docs-meta views, `git diff --check`, focused `rg` verification, and target-repo generated-doc checks when a consuming repo has them.

---

## Prerequisites

- AGENT-DOCS is treated as the upstream source for `docs-meta` behavior.
- A consuming repo's docs physical layout migration is complete enough that canonical homes are stable before mutating commands are used there.
- `scripts/docs-meta check` passes in AGENT-DOCS and in any target repo used as an implementation fixture before mutating behavior is trusted.
- Link style policy is accepted: standard Markdown links with relative hrefs, repo-root-style labels when clarity matters, and no repo-internal `/Users/...` filesystem links as canonical docs links.

## Why Now

- The physical layout migration exposed how easy it is to leave stale references during folder moves.
- AGENT-DOCS is the right place to harden this once, then copy or install it into consuming repos.
- Backlinks, orphans, and broken-link checks are docs-meta concerns, not one app repo's bespoke cleanup logic.
- Normalizing links before more AGENT-DOCS adopters appear will make future docs work friendlier to GitHub, local editors, and Obsidian.

## Product / Workflow Decisions

- `docs-meta` owns hand-authored docs metadata and link integrity; `docs-generate` remains the code-derived facts generator.
- Standard Markdown links are canonical. Avoid Obsidian `[[wiki links]]` as the stored source of truth.
- Relative hrefs are canonical for repo-local links. Labels may show repo-root-style paths for readability.
- Folder references should link to a `README.md` when a meaningful index exists; otherwise use code spans for folder names.
- Safe move tooling should report unresolved prose mentions, but should not rewrite prose that is not a Markdown link.

## Design Rules

- Read-only graph commands must come before mutating commands.
- Mutating commands require `--dry-run` support and should show exactly which files and links would change.
- Preserve link labels, fragments, query strings, and image-link syntax when rewriting hrefs.
- Do not follow or validate external URLs in the first pass.
- Orphan checks need allowlists because generated views, session logs, archives, future briefs, and migration records can be intentionally low-link.
- Historical `plan-*` filenames should not be renamed by default.

## Extraction Checkpoint

Keep `docs-meta` inside AGENT-DOCS while it is still tightly coupled to the scaffold and docs workflow. Revisit a separate `docs-meta` repository when at least two of these are true:

- `docs-meta` has its own versioned release or install story.
- More than one repo consumes it directly from source.
- It has tests, fixtures, and command behavior that need independent CI.
- The script grows beyond scaffold metadata into a general Markdown knowledge-base tool.
- AGENT-DOCS changes and `docs-meta` changes start wanting different review cadences.

If split out, AGENT-DOCS should depend on `docs-meta` as a tool and keep only workflow guidance plus scaffold templates.

## Task Dependencies / Parallelization

- Task 1 builds the link parser and resolver foundation and must happen first.
- Tasks 2 and 3 can run in parallel after Task 1: read-only graph commands and link health integration.
- Task 4 depends on the read-only graph commands: relative-link normalization.
- Task 5 depends on Tasks 1, 2, and 4: safe move/rename.
- Task 6 is closeout: docs, generated views, and verification.
- Net: one foundation, two parallel read-only surfaces, two sequential mutation surfaces, then closeout.

Implementation completed in one bounded pass because the parser, read-only commands, mutation commands, docs updates, and smoke tests shared the same code surface.

## Out Of Scope

- Mass-renaming historical plan/spec files.
- Replacing `scripts/docs-generate`.
- Validating external HTTP links.
- Rewriting non-link prose references automatically.
- Making Obsidian-specific `[[wiki links]]` the canonical docs format.

## File Structure

Likely create:

```text
plans/docs-meta-link-graph-and-safe-move/implementation-briefs/IMPL-0001-01-link-graph-and-safe-move-foundation.md
```

Likely modify:

```text
scripts/docs-meta
scripts/README.md
README.md
guides/workflow-overview.md
guides/adoption-checklist.md
tests/docs-meta-smoke.sh
```

## Implementation Tasks

### Task 1: Add a structured link graph - Completed

**Goal:** Parse and resolve repo-local doc links into reusable records.

- Add a `LinkRef`-style structure with source path, line number, raw href, label, fragment, resolved target, link kind, and status.
- Parse Markdown inline links, image links, autolinks if practical, and Obsidian-style wikilinks as noncanonical inputs.
- Resolve relative, root-relative, repo-absolute filesystem, directory, anchor-only, and external URL targets.

Dependencies / parallelization:

- Depends on: prerequisites only
- Can run in parallel with: none
- Notes: this is the core shared layer; keep it read-only.

### Task 2: Add read-only link commands - Completed

**Goal:** Expose graph inspection without changing files.

- Add `scripts/docs-meta links`.
- Add `scripts/docs-meta backlinks PATH_OR_ID`.
- Add `scripts/docs-meta check-links`.
- Add `scripts/docs-meta orphans`.
- Support plain text and JSON output where useful.

Dependencies / parallelization:

- Depends on: Task 1
- Can run in parallel with: Task 3
- Notes: read-only commands should be useful before any normalization exists.

### Task 3: Fold link health into docs health - Completed

**Goal:** Make link integrity visible in generated repo-health views.

- Add broken-link warnings to `docs-meta health`.
- Add absolute repo-local link warnings.
- Add orphan warnings with allowlists or frontmatter escape hatches.
- Document severity levels.

Dependencies / parallelization:

- Depends on: Task 1
- Can run in parallel with: Task 2
- Notes: generated health should remain advisory, not noisy enough to become ignored.

### Task 4: Normalize repo-local links - Completed

**Goal:** Convert repo-local links to portable relative Markdown hrefs.

- Add `scripts/docs-meta normalize-links --style relative --dry-run`.
- Add write mode only after dry-run output is stable.
- Preserve visible labels unless explicitly requested.
- Avoid changing external URLs and generated files.

Dependencies / parallelization:

- Depends on: Tasks 1-2
- Can run in parallel with: none
- Notes: start with absolute `/Users/...` links inside repo docs.

### Task 5: Add safe doc move/rename - Completed

**Goal:** Move or rename a doc while updating Markdown backlinks systematically.

- Add `scripts/docs-meta move OLD NEW --dry-run`.
- Add write mode after dry-run validation.
- Move the file, rewrite resolved Markdown links to the new target, preserve fragments, and report unresolved textual mentions.
- Refuse or warn on historical plan/spec moves unless an explicit override is passed.

Dependencies / parallelization:

- Depends on: Tasks 1, 2, and 4
- Can run in parallel with: none
- Notes: default behavior should be conservative and reviewable.

### Task 6: Document and verify the workflow - Completed

**Goal:** Make the new link tooling part of normal docs maintenance.

- Document link style and move workflow in `docs/README.md`.
- Add “use `docs-meta move` for doc moves” to repo-health planning guidance.
- Regenerate docs-meta views.
- Run focused link checks and old-path searches.

Dependencies / parallelization:

- Depends on: Tasks 1-5
- Can run in parallel with: final review only
- Notes: this is where the tool becomes the expected workflow.

## Validation

- `tests/docs-meta-smoke.sh`
- `git diff --check`

## Completion Criteria

- [x] `docs-meta` can list links and backlinks for any repo doc.
- [x] Broken repo-local links are reported deterministically.
- [x] Orphan docs are reported.
- [x] Absolute repo-local links can be normalized to relative Markdown links with dry-run preview.
- [x] Safe move can preview and perform a doc move with backlink rewrites.
- [x] `docs/HEALTH.md` includes link-health signals without overwhelming normal docs work.
