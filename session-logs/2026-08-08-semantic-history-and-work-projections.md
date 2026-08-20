---
type: session-log
document_format_version: 2
id: 01a02039-7a6a-7ad6-b772-b1f90d48db55
aliases: []
title: Capture Semantic History And Work Projections
domain: agent-continuity
status: completed
created_at: "2026-08-08 16:20:26 JST +0900"
updated_at: "2026-08-08 16:26:44 JST +0900"
started_at: "2026-08-08 16:18:49 JST +0900"
ended_at: "2026-08-08 16:26:44 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - agent-continuity
  - document-library
  - semantic-history
  - work-tracking
related_plans: []
related_briefs: []
related_specs: []
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-08-08 - Capture Semantic History And Work Projections

## Goal

Preserve the idea of field-aware document history and clarify how Agent Continuity artifacts should relate to GitHub work tracking without duplicating truth.

## Context Read

- `guides/doc-types-and-responsibilities.md`
- `scaffold/docs/product/plans/README.md`
- Plan, implementation-brief, marketing-plan, and session-log templates
- The historical `PLAN-0004` closeout commits and diffs
- [IDEA-0003](../agent-continuity/ideas/IDEA-0003-federated-document-library-and-relationship-graph.md)

## Result

- Added [IDEA-0004](../agent-continuity/ideas/IDEA-0004-semantic-history-and-work-projections.md).
- Added [EXPL-0002](../docs/orientation/explainers/EXPL-0002-documents-work-delivery-and-semantic-history.md) as the concise human-facing mental model.
- Confirmed that current metadata stores commit context, issue and pull-request links, commit trailers, and session `commits` lists, but no semantic transition index.
- Used the real `PLAN-0004` closeout to distinguish a lifecycle-transition commit from its linked implementation evidence.
- Proposed a rebuildable semantic event projection over Git-backed typed documents and explicit relationships.
- Separated knowledge artifacts, work items, delivery objects, evidence objects, and semantic events.
- Separated artifact, work, and delivery lifecycles instead of treating their statuses as interchangeable.
- Kept implementation briefs as optional bounded handoff artifacts rather than a mandatory stage.
- Identified the existing Markdown-canonical `TODO-*` model as an authority decision that must be resolved before GitHub work synchronization.
- Recorded that marketing already has an area and template, while new product or design types should require distinct lifecycle and UI semantics.

## Boundaries

- No event index, GitHub synchronization, or application UI was implemented.
- No current frontmatter or status schema was changed.
- The proposal is captured as an idea, not an approved Architecture Decision Record (ADR) or specification.
- Existing unrelated naming-migration changes in the repository were not modified.

## Verification

- Inspected commit `537ffb81c867f4b3fa03717683e185d16e30366a` and its `PLAN-0004` field transitions.
- Inspected implementation/verification commit `639228d728c5a36e179c829cb661504af53be09b`.
- Confirmed current commit-trailer guidance and session-log `commits` schema.
- Strict Mermaid layout lint passed for IDEA-0004 and EXPL-0002.
- `git diff --check` passed for the files changed by this capture.
- Agent Continuity `check` and `check-links` reported no errors for IDEA-0004, EXPL-0002, or this session log.
- The repository-wide Agent Continuity check still reports unrelated missing-link errors from the in-progress naming migration and an incomplete audit template; those existing changes were not modified.

## Follow-Up

Prototype semantic-history extraction for one repository and decide the one-way authority rules for GitHub issue and dependency projections before adding synchronization.
