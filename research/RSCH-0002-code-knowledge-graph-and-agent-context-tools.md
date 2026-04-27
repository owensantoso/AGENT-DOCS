---
type: research-survey
id: RSCH-0002
title: Code Knowledge Graph And Agent Context Tools
domain: research
status: completed
created_at: "2026-04-27 20:12:53 JST +0900"
updated_at: "2026-04-27 22:05:46 JST +0900"
owner: "Codex main agent"
question: "Which existing code knowledge graph and agent-context tools should inform an AGENT-DOCS docs-to-code graph?"
source:
  type: conversation
  link:
  notes: "Requested as part of a parallel research pass on existing tools for integrating docs and code graphs."
external_sources:
  - title: "Sourcegraph indexer documentation"
    url: "https://sourcegraph.com/docs/code-search/code-navigation/writing_an_indexer"
  - title: "Sourcegraph LSIF to SCIP migration"
    url: "https://sourcegraph.com/docs/admin/how-to/lsif-scip-migration"
  - title: "Sourcegraph symbol search documentation"
    url: "https://sourcegraph.com/docs/code-search/types/symbol"
  - title: "Kythe schema overview"
    url: "https://kythe.io/docs/schema-overview.html"
  - title: "Kythe documentation index"
    url: "https://www.kythe.io/docs/"
  - title: "CodeQL overview"
    url: "https://codeql.github.com/docs/codeql-overview/about-codeql/"
  - title: "CodeQL database create CLI manual"
    url: "https://docs.github.com/en/code-security/reference/code-scanning/codeql/codeql-cli-manual/database-create"
  - title: "CodeQL call graph guide"
    url: "https://codeql.github.com/docs/codeql-language-guides/navigating-the-call-graph/"
  - title: "Repository Intelligence Graph paper"
    url: "https://arxiv.org/abs/2601.10112"
repo_findings:
  - "AGENT-DOCS already has stable doc IDs and generated views, so a code graph should be a generated read model over Markdown and source code."
  - "CONC-0001 already sketches a read-only SQLite docs index; code graph tables could extend that cache later."
  - "PLAN-0001 established a conservative docs link graph before mutating commands, which is the right pattern for docs-to-code edges too."
agent_notes:
  - "Sourcegraph SCIP and Kythe are the strongest prior art for source ranges, symbols, and cross-reference graphs."
  - "CodeQL is powerful for queryable semantic analysis, but its security-analysis database is heavier than a first docs navigation layer."
related_ideas:
  - ../docs-meta/ideas/IDEA-0001-docs-to-code-graph.md
related_evaluations: []
related_adrs: []
related_specs: []
related_plans:
  - ../plans/docs-meta-link-graph-and-safe-move/PLAN-0001-docs-meta-link-graph-and-safe-move.md
related_sessions: []
linked_paths:
  - scripts/docs-meta
  - concepts/CONC-0001-read-only-sqlite-docs-index.md
repo_state:
  based_on_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
  last_reviewed_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
---

# RSCH-0002 - Code Knowledge Graph And Agent Context Tools

## Question

Which existing code knowledge graph and agent-context tools should inform an AGENT-DOCS docs-to-code graph?

## Context

The user framed AGENT-DOCS as increasingly graph-like: docs already link to docs, while code has its own natural graph through symbols, calls, references, dependencies, and generated metadata. The missing bridge is a durable way for agents to move from docs to the relevant code without trusting stale line numbers or loose text search.

This survey looks at tools whose primary job is code intelligence or graph-shaped agent context. It focuses on durable data models, language coverage, rebuild/freshness behavior, source-location precision, and fit with AGENT-DOCS's existing rule: Markdown remains canonical; generated views and indexes are disposable read models.

## External Sources

- [Sourcegraph indexer documentation](https://sourcegraph.com/docs/code-search/code-navigation/writing_an_indexer) describes SCIP indexes with documents, occurrences attached to source ranges, defined symbols, hover documentation, diagnostics, and semantic roles for go-to-definition and references.
- [Sourcegraph LSIF to SCIP migration](https://sourcegraph.com/docs/admin/how-to/lsif-scip-migration) documents SCIP as the successor representation for precise code intelligence data in Sourcegraph.
- [Sourcegraph symbol search](https://sourcegraph.com/docs/code-search/types/symbol) describes symbol search as declaration-oriented search with commit-index behavior and incremental symbol index updates.
- [Kythe schema overview](https://kythe.io/docs/schema-overview.html) describes a graph model with anchors for file regions, nodes for semantic entities, edges such as definitions/references, call graphs, hierarchies, and documentation attachment.
- [Kythe documentation](https://www.kythe.io/docs/) includes schema reference, indexer writing, generated-code indexing, storage model, callgraphs, and verifier guidance.
- [CodeQL overview](https://codeql.github.com/docs/codeql-overview/about-codeql/) explains CodeQL databases as language-specific relational representations of source files, AST data, name binding, type information, control flow, and data flow.
- [CodeQL database create CLI manual](https://docs.github.com/en/code-security/reference/code-scanning/codeql/codeql-cli-manual/database-create) documents multi-language database clusters, build modes, and language extractor behavior.
- [CodeQL call graph guide](https://codeql.github.com/docs/codeql-language-guides/navigating-the-call-graph/) shows CodeQL's query model for callables and calls in Java/Kotlin.
- [Repository Intelligence Graph](https://arxiv.org/abs/2601.10112) proposes an evidence-backed architectural graph for LLM code assistants with buildable components, tests, dependencies, and edges traced to concrete build/test definitions.

## Repo / Internal Findings

- [PLAN-0001](../plans/docs-meta-link-graph-and-safe-move/PLAN-0001-docs-meta-link-graph-and-safe-move.md) already made the docs link graph read-only before adding mutation. A docs-to-code graph should follow the same path: inspect, validate, report, then optionally rewrite.
- [CONC-0001](../concepts/CONC-0001-read-only-sqlite-docs-index.md) already proposes a generated SQLite read model. If a code graph becomes useful, it should probably extend that cache rather than create an unrelated canonical database.
- [scripts/docs-meta](../scripts/docs-meta) already validates `linked_paths`, frontmatter contracts, link health, todos, and generated views. The first code graph should grow out of this tooling instead of bypassing it.

## Agent Notes

- The most relevant prior art separates source facts from rendered navigation. SCIP, Kythe, and CodeQL all use machine-readable indexes rather than treating rendered HTML links as truth.
- Agent-context graph tools are emerging quickly, but the stable idea is older: source ranges, symbol identities, reference edges, dependency edges, and freshness metadata need deterministic extraction before LLM summarization.
- For AGENT-DOCS, a graph is most useful if it can answer bounded questions: "which docs mention this symbol?", "which code implements this plan?", "which docs are stale because these files changed?", and "what should an agent read before editing this area?"

## Options Compared

| Option | Data Model | Language Coverage | Freshness Model | Fit For AGENT-DOCS |
|---|---|---|---|---|
| Sourcegraph SCIP | Documents, occurrences, symbols, roles, hover, diagnostics | Depends on indexers; strong ecosystem for popular languages | Rebuild/upload per commit or index run | Strong schema inspiration for source ranges and symbol roles |
| Kythe | Typed graph nodes, anchors, facts, semantic edges | Pluggable indexers; mature but heavier | Extraction artifacts and graph serving pipeline | Strong conceptual fit, likely too heavy as a baseline |
| CodeQL database | Relational semantic database per language | Official extractors for supported languages | Build/extractor driven; language databases can be clustered | Best for deep analysis, not first navigation layer |
| LSP-derived graph | Live server responses: definitions, references, symbols | Broad when servers exist | Tied to workspace state, server version, build/index status | Good interactive revalidation layer |
| Tree-sitter graph | Syntax captures, ranges, definitions, references by query | Broad parser ecosystem, uneven query quality | Cheap local rebuild from files | Good first local candidate layer |
| Agent context graph/MCP tools | Often files, symbols, imports, calls, summaries, embeddings | Tool-specific | Usually generated cache; quality varies | Useful direction, but AGENT-DOCS should keep deterministic source records first |

## Findings

1. The reusable primitive is an occurrence, not a URL. SCIP stores source ranges with symbol roles; Kythe stores anchors for file regions; CodeQL stores extracted relational facts. AGENT-DOCS should store code references as typed data first and render URLs second.

2. Symbol identity is language-specific. SCIP symbol strings, Kythe VNames/nodes, CodeQL entities, LSP symbols, and Tree-sitter captures are not interchangeable. A portable AGENT-DOCS schema should keep a common wrapper plus engine-specific evidence.

3. Graph precision costs build context. CodeQL and precise code-intelligence indexes often need build/extractor context. LSP and SourceKit-LSP need recent build/index state. Tree-sitter is easier to run but less semantic.

4. Freshness must be explicit. Every index is a snapshot of some repo state, build state, parser/indexer version, and configuration. Store `observed_commit`, `generated_at`, engine name/version, and target file content hash where possible.

5. CodeQL is excellent for questions like "what flows here?" or "who calls this?" but is heavier than AGENT-DOCS needs for first-pass doc navigation. It belongs in evaluation or diagnostics layers when semantic queries become necessary.

6. Kythe is the strongest "docs and code in one graph" model because it explicitly models documentation nodes and anchors, but adopting Kythe directly would likely add too much infrastructure for small repos.

7. Sourcegraph/SCIP is the most practical schema reference for a future generated source index: document paths, occurrences, symbols, roles, hover text, and diagnostics map cleanly to agent navigation.

8. Agent-facing graph tools are promising when they expose structured query APIs, but AGENT-DOCS should avoid making model-generated summaries canonical. Summaries can be cached views; extracted source facts should remain verifiable.

## Risks / Unknowns

- Indexes can disagree because each engine sees a different build, dependency, generated-code, macro, or workspace state.
- A general graph can become too noisy unless edge types are constrained. `mentions`, `implements`, `tests`, `calls`, `defines`, `references`, and `evidence_for` should stay distinct.
- Large generated caches may tempt users to treat the database as canonical. AGENT-DOCS should keep caches disposable and rebuildable.
- Directly adopting Sourcegraph, Kythe, or CodeQL may be overkill for lightweight target repos.
- Cross-language links need separate adapters and confidence labels; one "symbol" abstraction will not be equally precise everywhere.

## Recommendation

Use existing code-intelligence systems as schema inspiration, not as required AGENT-DOCS dependencies.

Recommended staged model:

1. Keep Markdown docs and stable doc IDs canonical.
2. Add a generated code-reference layer with records for files, ranges, symbols, occurrences, and doc-code edges.
3. Start with explicit `linked_paths` and future `code_refs` in docs, then generate a report of stale or unresolved links.
4. Use Tree-sitter for cheap syntax candidates, LSP/Monocle for interactive symbol lookup, and SCIP/CodeQL-style indexes only when a repo needs deeper precision.
5. Store engine metadata and confidence for every generated edge.
6. If SQLite indexing moves forward, model code graph tables as an extension of the generated read-only index from CONC-0001.

The first useful tool should answer "what code surfaces does this doc claim to describe, and are those surfaces still present at this commit?" before attempting full call graph or dependency graph intelligence.

## Follow-Ups

- Define a minimal `code_ref` or `DREF-*` record shape that can hold explicit path links, commit-pinned evidence, and optional symbol evidence.
- Prototype a generated report joining docs, `linked_paths`, and changed files since `last_reviewed_commit`.
- Decide whether to adopt SCIP-like terms (`document`, `occurrence`, `symbol`, `role`) for AGENT-DOCS generated indexes.
- Run an evaluation on one Swift repo and one non-Swift repo before choosing any required code indexer.
