---
type: session-log
title: Personal-First Research And Relationship Store
domain: agent-continuity
status: completed
created_at: "2026-08-08 18:34:41 JST +0900"
updated_at: "2026-08-08 18:41:26 JST +0900"
started_at: "2026-08-08 18:10:00 JST +0900"
ended_at: "2026-08-08 18:34:41 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
  - research landscape subagent
  - Graphify architecture subagent
  - personal-first strategy subagent
areas:
  - agent-continuity
  - research
  - relationship-graph
  - personal-product
  - graphify
related_plans: []
related_briefs: []
related_specs: []
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-08-08 - Personal-First Research And Relationship Store

## Goal

Research the broader intellectual domain behind adaptive goal-to-outcome planning, keep the first product personally useful rather than enterprise-first, and verify whether Graphify supports extracting canonical relationships from document frontmatter.

## Workstreams

Three independent extra-high agent passes covered:

1. research across requirements elicitation, goal modeling, human factors, hierarchical and continual planning, adaptive case management, mixed initiative, executive-function support, personal informatics, and organizational scaling
2. current Graphify behavior plus the local Agent Continuity relationship schema, SQLite concept, scripts, source ownership, migration, and privacy boundaries
3. a personal-first product strategy comparing the document viewer, graph/index, general action workspace, and a narrow combined vertical

## Durable Results

- Added [RSCH-0008](../research/RSCH-0008-adaptive-goal-to-outcome-planning-landscape.md).
- Added [RSCH-0009](../research/RSCH-0009-graphify-and-canonical-relationship-store-fit.md).
- Updated [IDEA-0006](../agent-continuity/ideas/IDEA-0006-adaptive-goal-to-outcome-quest-planning.md) with the personal-first project-cockpit wedge and deferred business-to-business concerns.
- Updated [IDEA-0003](../agent-continuity/ideas/IDEA-0003-federated-document-library-and-relationship-graph.md) with current Graphify capabilities and the verified derived-adapter boundary.

## Research Conclusions

- The product is an uncommon synthesis rather than a new primitive. Mature traditions cover each major component, but no surveyed field clearly owns the full personal fuzzy-intent-to-evidence loop.
- The proposed graph contains different semantics: means-ends, goal refinement, work decomposition, execution dependency, actor/authority, and evidence/provenance.
- “Good enough—start now” has serious grounding in risk-sensitive task analysis, resource-rational decomposition, least commitment, rolling-wave planning, and continual planning.
- Personal-first is the correct scope. Organizational use introduces qualitatively different identity, authority, resource, privacy, audit, compliance, and portfolio concerns.
- The recommended first product is a local native project cockpit combining typed Continuity context with a calm actionable frontier, not a generic graph viewer or universal life planner.

## Graphify And Storage Conclusions

- The user's normalization idea is correct: one canonical typed relationship assertion can generate both directions and remove reciprocal frontmatter drift.
- Graphify externalizes relationships only in a generated read model. Its graph does not become the authored source of truth.
- Source-sharded, Git-reviewable relation files are the recommended canonical source for Agent Continuity knowledge edges.
- SQLite is the recommended disposable index for search, traversal, inverse views, semantic events, provider observations, and candidate edges.
- Writable SQLite or SwiftData may be canonical for the separate action workspace's operational state.
- Graphify should remain an optional sanitized analysis and suggestion adapter. Inferred edges must enter a candidate review queue before becoming explicit.
- A graph database is unnecessary for the personal pilot.

## Product Sequence

1. Run a concierge frontier proof on active personal projects.
2. Build a read-only local Continuity cockpit over the existing parser and relationships.
3. Add one normalized relation family and a document-neighborhood view.
4. Add a minimal personal operational loop with one to five actions, why/unlock context, evidence, and resumption.
5. Test one actual non-software undertaking after the software-project loop earns repeat use.
6. Separate the action product only if users naturally use it independently of repository context.
7. Consider organization features only after real collaboration demand appears.

## Verification Boundary

- Current external product and research claims are linked from the two `RSCH-*` documents.
- Graphify behavior was inspected at the version and commit recorded in RSCH-0009; it may drift.
- `agent-continuity docs --root research` discovers both surveys, reports `RSCH-0010` as the next research ID, validates their schema and linked paths, and reports no broken Markdown links within the research family.
- The command's default `--root docs` does not discover the repository-level `research/`, `agent-continuity/ideas/`, or `session-logs/` directories during the current naming migration. Using `--root .` discovers the files but misidentifies the parent directory as the repository root. This is a pre-existing discovery-boundary defect, not evidence that the new surveys are absent.
- Relation summaries remain unresolved because current `related_*` frontmatter stores paths while `relation_summary()` looks up stable IDs. RSCH-0009 records this mismatch as part of the relationship-normalization problem rather than concealing it.
- No Graphify instance, relationship migration, SQLite database, or product application was implemented.
- The three independent agents did not edit files; the main agent created the durable synthesis.
- Existing unrelated naming-migration changes in the repository were preserved.

## Follow-Up

Run the concierge personal-project cockpit evaluation before approving a specification, relationship migration, or application implementation plan.

The strongest closeout rule is: **prove one personally valuable orientation-to-action loop before abstracting upward to organizations or outward to a universal planner.**
