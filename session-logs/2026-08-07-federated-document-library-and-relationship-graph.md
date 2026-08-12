---
type: session-log
title: Capture Federated Document Library And Relationship Graph
status: completed
created_at: "2026-08-07 15:49:57 JST +0900"
updated_at: "2026-08-08 15:57:47 JST +0900"
codex_thread_id: "019fdae4-b3ef-7191-8173-ecfca7d9e4a0"
---

# 2026-08-07 - Capture Federated Document Library And Relationship Graph

## Goal

Preserve the product and architecture discussion about a polished document library, canonical relationship ownership, Graphify integration, and provider-neutral agent provenance.

## Result

- Added [IDEA-0003](../agent-continuity/ideas/IDEA-0003-federated-document-library-and-relationship-graph.md).
- Distinguished repository-portable Agent Continuity sources from a rebuildable all-repositories library.
- Proposed keeping intrinsic document facts in Markdown while storing each typed relationship once and generating inverse views.
- Added a physical public/private storage boundary: public product repositories remain independently publishable, while private project memory lives in a private vault or companion repository.
- Recorded that private-to-public links are stored only on the private side and that publishing requires explicit promotion or sanitization.
- Positioned Graphify as an optional analysis and visualization adapter rather than the canonical workflow graph.
- Initially recorded `Continuity Library`, `Continuity Forge`, and `Agent Activity Provenance` as possible product names, then removed that premature split after user clarification.
- Reframed the system as independent Git-compatible documentation repositories plus one domain-aware Agent Continuity application.
- Positioned Jujutsu as an optional local workflow over Git-compatible storage rather than a required hosted backend.

## Boundaries

- No existing frontmatter contract was changed.
- No relationship or private-vault storage format was approved or implemented.
- No Graphify package or integration was installed.
- The repository already contained unrelated, in-progress Agent Continuity naming changes; this session added two new files and did not modify that work.

## Next Decision

Create one independent private documentation repository for one public code repository, use Jujutsu locally over a Git-compatible remote, then verify combined navigation and the absence of private metadata in a clean public clone.

## Correction - Repository Unit Versus Global View

What happened: the first recommendation made one private continuity vault the preferred personal pilot.

What led to it: the design optimized for immediate cross-project search and simple setup, and therefore conflated a global read experience with a global commit and permission boundary.

Source: agent architecture assumption.

What changed: one independently versioned documentation repository per project or permission boundary is now the recommended canonical unit. A single vault is only an optional adapter. The Agent Continuity application federates repositories into the global view.

Verification: the idea now distinguishes VCS storage from the human application, includes the Git/Jujutsu boundary, and makes independent repository history part of its promotion criteria.

Follow-up: test one public code repository plus one private documentation repository before choosing any hosting implementation.

## Correction - Forge And Library Were Premature Product Splits

What happened: the design introduced `Continuity Forge` as an infrastructure product and `Continuity Library` as its document-viewing surface. The user understood both as one application and found the distinction confusing.

What led to it: the architecture separated hosting capabilities from presentation responsibilities before the product required separate deployment, ownership, or user experiences.

Source: agent domain-model and naming assumption.

What changed: the idea now describes one Agent Continuity system with authoring/maintenance, versioned sources, a human application, and integrations. “Forge” remains only a GitHub analogy; “library” remains only a generic description of the browsing experience.

Verification: the architecture diagram and product-boundary section now use one application boundary, and the document includes the evolution from Docs Meta to Agent Continuity to its missing human interface.

Follow-up: keep the umbrella name provisional and delay any brand split until separate products are justified by real ownership or deployment boundaries.
