---
type: idea
id: IDEA-0001
title: Docs To Code Graph
domain: docs-meta
status: captured
created_at: "2026-04-27 20:14:25 JST +0900"
updated_at: "2026-04-27 22:05:46 JST +0900"
owner: "Codex main agent"
source:
  type: conversation
  link:
  notes: "User asked whether AGENT-DOCS could bridge the docs graph and code graph, with stale-aware links to files, lines, symbols, commits, and Monocle/Swift symbol lookup."
areas:
  - docs-meta
  - code-intelligence
related_specs: []
related_research:
  - ../../research/RSCH-0001-docs-code-traceability-tools.md
  - ../../research/RSCH-0002-code-knowledge-graph-and-agent-context-tools.md
  - ../../research/RSCH-0003-documentation-systems-with-source-links.md
  - ../../research/RSCH-0004-tree-sitter-for-docs-to-code-linking.md
  - ../../research/RSCH-0005-ast-indexes-and-static-analysis-for-docs-links.md
  - ../../research/RSCH-0006-lsp-symbol-graphs-for-docs-navigation.md
  - ../../research/RSCH-0007-monocle-swift-symbol-navigation-fit.md
related_issues: []
related_prs: []
related_sessions: []
linked_paths:
  - scripts/docs-meta
  - concepts/CONC-0001-read-only-sqlite-docs-index.md
  - plans/docs-meta-link-graph-and-safe-move/PLAN-0001-docs-meta-link-graph-and-safe-move.md
promoted_to: []
repo_state:
  based_on_commit: d8202def7a3fc561a48fa9267d82122caf51150d
  last_reviewed_commit: d8202def7a3fc561a48fa9267d82122caf51150d
---

# IDEA-0001 - Docs To Code Graph

## Raw Thought

AGENT-DOCS is becoming a graph: docs link to docs, plans link to briefs, research links to decisions, TODOs link to execution, and `docs-meta` can already inspect links/backlinks. Code is also naturally graph-shaped through files, symbols, definitions, references, calls, imports, tests, packages, and generated docs.

The idea is to bridge those two graphs so an agent can move from durable docs to the exact code surface the doc is talking about, then back from code to the docs that explain intent, history, decisions, and follow-up work.

The hard part is staleness. File lines drift, symbols move, and generated indexes reflect a particular commit and tool state. The bridge should therefore record observed evidence with commit/timestamp/tool metadata and mark edges stale or needing revalidation when code changes.

## Why It Might Matter

- Agents could start from a plan, ADR, research note, or concept and jump directly to the relevant code without broad search.
- Docs could warn when their linked code surfaces changed after `repo_state.last_reviewed_commit`.
- Code review could ask, "which docs claim ownership of this symbol or file?"
- Fresh sessions could recover not only what docs exist, but what code they describe.
- Swift repos could use Monocle/SourceKit-LSP as a precise symbol lookup layer for source locations, signatures, and documentation.
- The generated graph could become a better retrieval layer than dumping entire docs or code files into context.

## Possible Shape

Keep Markdown canonical and make the docs-to-code graph generated.

Potential source fields:

```yaml
code_refs:
  - id: DREF-0001
    intent: current_surface
    path: scripts/docs-meta
    symbol:
      language: python
      name: validate_linked_paths
    evidence:
      observed_commit: d8202def7a3fc561a48fa9267d82122caf51150d
      observed_at: "2026-04-27 22:05:46 JST +0900"
      engine: explicit-path
      confidence: explicit
    freshness:
      status: needs-revalidation
```

Potential generated records:

- `doc_nodes`: stable docs and frontmatter metadata.
- `code_files`: repo-relative path, language, content hash, last indexed commit.
- `code_symbols`: symbol name, kind, container/module, engine, source range, confidence.
- `code_occurrences`: definitions, references, calls, imports, tests, and documentation comments.
- `doc_code_edges`: doc ID to file/range/symbol with intent, evidence, freshness, and confidence.
- `stale_edges`: generated review queue when code changed after the doc's last reviewed commit.

Likely layers:

1. Explicit doc-to-path links and `linked_paths`.
2. Commit-pinned evidence links for historical claims.
3. Tree-sitter syntax extraction for cheap candidates.
4. LSP/Monocle verification for interactive precision.
5. Optional compiler/SCIP/CodeQL adapters for high-confidence semantic edges.
6. Optional SQLite read model if cross-cutting queries outgrow simple `docs-meta` subcommands.

## Questions

- Should the stable ID family be `DREF-*`, `CREF-*`, or just structured `code_refs` under the owning doc?
- Should code references live in frontmatter, body blocks, or both?
- What edge intents are necessary in the first version: `mentions`, `current_surface`, `implements`, `tests`, `decides`, `evidence_for`, `definition`, `reference`?
- How strict should stale checks be? Advisory health warning, CI failure, or only explicit review queue?
- Should exact code snippets be stored, or only hashes and commit-pinned permalinks?
- Which repo should host the first prototype: AGENT-DOCS itself, a Swift app with Monocle available, or a mixed-language target repo?
- Does the SQLite docs-index concept become the natural home for generated code graph tables?

## Promotion Criteria

Promote this idea when at least one concrete workflow is chosen:

- stale warnings for docs with `linked_paths`
- generated doc-to-file traceability matrix
- symbol-aware doc links for Swift through Monocle
- Tree-sitter syntax index for repo-local code ranges
- SQLite read model for joined docs/code graph queries

Before implementation, create a spec or concept for the `code_ref` schema and an evaluation that compares at least two engines on real repo examples.

Related research:

- [RSCH-0001 - Docs Code Traceability Tools](../../research/RSCH-0001-docs-code-traceability-tools.md)
- [RSCH-0002 - Code Knowledge Graph And Agent Context Tools](../../research/RSCH-0002-code-knowledge-graph-and-agent-context-tools.md)
- [RSCH-0003 - Documentation Systems With Source Links](../../research/RSCH-0003-documentation-systems-with-source-links.md)
- [RSCH-0004 - Tree Sitter For Docs To Code Linking](../../research/RSCH-0004-tree-sitter-for-docs-to-code-linking.md)
- [RSCH-0005 - AST Indexes And Static Analysis For Docs Links](../../research/RSCH-0005-ast-indexes-and-static-analysis-for-docs-links.md)
- [RSCH-0006 - LSP Symbol Graphs For Docs Navigation](../../research/RSCH-0006-lsp-symbol-graphs-for-docs-navigation.md)
- [RSCH-0007 - Monocle Swift Symbol Navigation Fit](../../research/RSCH-0007-monocle-swift-symbol-navigation-fit.md)
