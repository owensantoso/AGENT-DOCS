---
type: session-log
document_format_version: 2
id: 01a02039-7a6a-7ae6-9afe-c1043dc26852
aliases: []
title: Repository Boundary And Graph Authority Clarification
domain: agent-continuity
status: completed
created_at: "2026-08-08 18:53:49 JST +0900"
updated_at: "2026-08-08 19:38:21 JST +0900"
started_at: "2026-08-08 18:45:00 JST +0900"
ended_at: "2026-08-08 19:38:21 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - agent-continuity
  - repository-boundary
  - relationship-graph
  - product-incubation
related_plans: []
related_briefs: []
related_specs: []
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-08-08 - Repository Boundary And Graph Authority Clarification

## Goal

Clarify whether the emerging personal continuity and goal-to-outcome product deserves a repository separate from the reusable Agent Continuity framework, and remove ambiguity about whether the graph is intended to become canonical.

## Reflection

**What happened:** The previous explanation distinguished canonical relation files from generated Graphify and SQLite output, but the wording made it sound as though making the graph canonical was merely a distant possibility or something being discouraged.

**What led to it:** “Graph” was used for the logical relationship model, its durable storage representation, and generated graph projections without naming those layers separately.

**Source:** Documentation ambiguity, compounded by an emerging product boundary that the earlier idea still described as one repository-level system.

**What changed:** RSCH-0009 now states that the logical relationship graph is the intended canonical authority for relationships, while the first storage representation remains replaceable. IDEA-0003 now distinguishes self-hosting from mixing the framework, product, and broad research in one repository. IDEA-0006 now preserves separate personal-product and general-research horizons.

**Verification:** The revised statements assign one owner to each layer and no longer equate “canonical graph” with “graph database” or “Graphify output.”

**Follow-up:** Decide the new repository only after a short charter and extraction manifest establish ownership and prevent duplicate canonical documents.

## Recommended Boundary

- Keep Agent Continuity active as the reusable document schema, workflow, templates, checks, installation, and compatibility project.
- Incubate the human-facing personal cockpit, canonical relationship engine, goal-to-outcome model, and foundational research in a separate repository.
- Keep the new repository's name provisional until the product promise and ubiquitous language are clearer.
- Reuse Agent Continuity inside the new repository as a consumer and proving ground, but preserve a plain-Markdown bootstrap path when the tooling is unavailable.

At the initial clarification stage this was only a recommendation. The follow-up bootstrap created the two local repositories described below, but moved or copied no source document.

## Follow-Up Repository Decision

The selected working shape is three repositories in total:

1. `agent-continuity` remains the reusable format, command-line tooling, checks, templates, and installation project.
2. `continuity-workspace` is a provisional local product repository. Its first vertical slice is the Agent Continuity viewer, search, and current-state experience. Human execution is a later module in the same repository, not a fourth repository yet.
3. `continuity-foundations` is a provisional local research repository for long-horizon models, competing ontologies, research surveys, and experiments.

The viewer is therefore not added to the Agent Continuity framework repository. Agent Continuity supplies the format and adapters; the product consumes them. The two new names are repository slugs only and may change after product-language work.

Both new repositories were initialized locally on `main` with no remotes and the Agent Continuity `standard` documentation profile. Each contains a repository charter and a disjoint extraction manifest. No application code, database, generated native project, or research source migration was performed.

Bootstrap commits:

- `continuity-workspace` - `9a0225e59062fead8ec5ccd6059a324c05e1e663`
- `continuity-foundations` - `3f558b601fabbb88247bf434632426d2e394593f`

## Graph Authority Rule

The intended end state is graph-native for relationships:

- the logical graph owns explicit typed relationships once
- documents or domain objects own their intrinsic content and state
- external providers own provider-native facts
- generated indexes and Graphify own no authored truth
- a future application database may become the durable canonical graph representation only through an explicit migration

The first version can persist canonical graph assertions as Git-reviewable relation files and generate SQLite views. This is an incremental storage choice, not a retreat from the graph-native end state.

## Extraction Safety

Before creating or populating a new repository:

1. write a one-page repository charter
2. inventory candidate ideas, research, explainers, and sessions
3. classify each source as move, reference, deliberate fork, or leave
4. record original repository, path, document ID, and commit
5. declare the canonical destination before editing both copies
6. replace the old copy with an explicit promotion or supersession pointer only after verifying the destination

The strongest retrieval cue is: **separate the product boundary without separating its provenance, and make the logical graph canonical without prematurely binding it to one database.**
