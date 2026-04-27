---
type: research-survey
id: RSCH-0004
title: Tree Sitter For Docs To Code Linking
domain: research
status: completed
created_at: "2026-04-27 20:12:53 JST +0900"
updated_at: "2026-04-27 20:16:13 JST +0900"
owner:
question: "How could Tree-sitter support docs-to-code linking in AGENT-DOCS, and where should it stop in favor of LSP, AST, or compiler-backed indexes?"
source:
  type: conversation
  link:
  notes: User requested a sourced research note on Tree-sitter for docs-to-code linking.
external_sources:
  - "https://tree-sitter.github.io/tree-sitter/index.html"
  - "https://tree-sitter.github.io/tree-sitter/using-parsers/1-getting-started.html"
  - "https://tree-sitter.github.io/tree-sitter/using-parsers/2-basic-parsing.html"
  - "https://tree-sitter.github.io/tree-sitter/using-parsers/3-advanced-parsing.html"
  - "https://tree-sitter.github.io/tree-sitter/using-parsers/queries/1-syntax.html"
  - "https://tree-sitter.github.io/tree-sitter/using-parsers/queries/2-operators.html"
  - "https://tree-sitter.github.io/tree-sitter/using-parsers/queries/3-predicates-and-directives.html"
  - "https://tree-sitter.github.io/tree-sitter/using-parsers/queries/4-api.html"
  - "https://tree-sitter.github.io/tree-sitter/4-code-navigation.html"
  - "https://tree-sitter.github.io/tree-sitter/3-syntax-highlighting.html"
  - "https://github.com/tree-sitter/tree-sitter/wiki/List-of-parsers"
  - "https://docs.github.com/en/repositories/working-with-files/using-files/navigating-code-on-github"
  - "https://github.com/github/code-navigation"
  - "https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/"
  - "https://sourcegraph.com/docs/code-search/code-navigation/writing_an_indexer"
repo_findings:
  - "scripts/docs-meta treats Markdown files, filenames, and frontmatter as canonical source and generated files as views."
  - "CONC-0001 proposes optional read-only SQLite as a disposable docs index cache, not a source of truth."
agent_notes:
  - "Synthesis: Tree-sitter is a strong syntax index layer but not a complete semantic resolver."
related_ideas: []
related_evaluations: []
related_adrs: []
related_specs: []
related_plans: []
related_sessions: []
linked_paths:
  - concepts/CONC-0001-read-only-sqlite-docs-index.md
  - scripts/README.md
repo_state:
  based_on_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
  last_reviewed_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
---

# RSCH-0004 - Tree Sitter For Docs To Code Linking

## Question

How could Tree-sitter support docs-to-code linking in AGENT-DOCS, and where should it stop in favor of LSP, AST, or compiler-backed indexes?

## Context

AGENT-DOCS already treats Markdown docs as the durable source of truth, with `docs-meta` deriving IDs, registries, links, TODO dashboards, and health views from files and frontmatter. A docs-to-code linking layer would add a different kind of generated read model: "this doc refers to this code symbol, range, or source path."

The useful question is not whether Tree-sitter can parse code. It can. The question is whether its syntax trees and query language are enough to create trustworthy links between durable docs and moving code. The short answer: Tree-sitter is a good first syntax layer for fast, local, build-free extraction of code structure, but precise cross-file symbol resolution should come from LSP or compiler-backed indexes.

## External Sources

- [Tree-sitter introduction](https://tree-sitter.github.io/tree-sitter/index.html): Tree-sitter is an incremental parsing library and parser generator that builds concrete syntax trees and updates them efficiently as source changes.
- [Using parsers: getting started](https://tree-sitter.github.io/tree-sitter/using-parsers/1-getting-started.html): the core runtime objects are language, parser, tree, and syntax node; each language is generated from a grammar.
- [Using parsers: basic parsing](https://tree-sitter.github.io/tree-sitter/using-parsers/2-basic-parsing.html): syntax nodes expose types, parent/child relationships, field names, byte offsets, and row/column points. Tree-sitter produces concrete syntax trees with named and anonymous nodes.
- [Using parsers: advanced parsing](https://tree-sitter.github.io/tree-sitter/using-parsers/3-advanced-parsing.html): incremental update requires editing the old tree, reparsing with the old tree, and then using the new tree; included ranges support multi-language files.
- [Tree-sitter query syntax](https://tree-sitter.github.io/tree-sitter/using-parsers/queries/1-syntax.html), [operators](https://tree-sitter.github.io/tree-sitter/using-parsers/queries/2-operators.html), [predicates and directives](https://tree-sitter.github.io/tree-sitter/using-parsers/queries/3-predicates-and-directives.html), and [query API](https://tree-sitter.github.io/tree-sitter/using-parsers/queries/4-api.html): queries are S-expression patterns over syntax trees, with captures, fields, predicates, directives, and immutable query objects.
- [Tree-sitter code navigation systems](https://tree-sitter.github.io/tree-sitter/4-code-navigation.html): Tree-sitter tag queries can label named entities with captures such as `@definition.function`, `@reference.call`, `@name`, and optional `@doc`.
- [Tree-sitter syntax highlighting](https://tree-sitter.github.io/tree-sitter/3-syntax-highlighting.html): highlighting uses language query files, including local-scope queries and injection queries for embedded languages.
- [Tree-sitter parser list wiki](https://github.com/tree-sitter/tree-sitter/wiki/List-of-parsers): parser coverage is broad but distributed across official and community-maintained grammars, with varying parser freshness, ABI, generated grammar files, and external scanner details.
- [GitHub code navigation docs](https://docs.github.com/en/repositories/working-with-files/using-files/navigating-code-on-github) and [github/code-navigation](https://github.com/github/code-navigation): GitHub uses Tree-sitter for search-based code navigation over supported languages, requires parser and tag-query support, and describes mature parser/query requirements for adding languages.
- [Language Server Protocol 3.17 specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/): LSP defines semantic navigation surfaces such as go to definition, find references, document symbols, workspace symbols, semantic tokens, hover, call hierarchy, type hierarchy, rename, and diagnostics.
- [Sourcegraph SCIP indexer docs](https://sourcegraph.com/docs/code-search/code-navigation/writing_an_indexer): precise code indexes store occurrences, definitions, symbols, references, hover data, and diagnostics; robust indexers typically use compiler frontends or language servers after semantic analysis.

## Repo / Internal Findings

- `scripts/docs-meta` is intentionally source-first: Markdown files, filenames, frontmatter, and checkboxes are canonical, while generated files are reproducible views.
- [CONC-0001](../concepts/CONC-0001-read-only-sqlite-docs-index.md) already frames SQLite as an optional read-only cache for repeated cross-doc joins. A docs-to-code index should follow the same rule: generated, disposable, rebuildable, and never canonical.
- AGENT-DOCS is currently mostly Markdown plus a Python `scripts/docs-meta` command and shell smoke tests. For this repo itself, initial Tree-sitter coverage would mainly need Markdown, Python, and shell. For consuming repos, language coverage must be selected per target stack.
- Existing generated views such as registries, TODO dashboards, and health reports should not be hand-edited. A code-link index should produce views or query results, not mutate source docs unless a human or agent explicitly accepts a change.

## Agent Notes

This survey treats "docs-to-code linking" as a generated relationship between a durable doc node and a source-code target. The target may be a path, byte/range span, symbol declaration, reference occurrence, doc comment, or code block. Tree-sitter can create many good candidate targets, but it cannot prove all semantic relationships by itself.

## Options Compared

| Option | Best Fit | Weakness | AGENT-DOCS Fit |
|---|---|---|---|
| Explicit Markdown links only | Stable path links, line anchors, human-authored references | Breaks on renames and cannot discover related code | Keep as canonical minimum |
| Regex or grep extraction | Fast text matching for names, paths, and comments | High false positives, weak around syntax nesting | Useful fallback only |
| Tree-sitter syntax index | Fast structural outlines, definitions, references, code chunks, doc comments, ranges | Syntax-aware but not type-aware or build-aware | Recommended first generated code layer |
| LSP-backed live lookup | Go to definition, references, hover, document/workspace symbols, diagnostics | Requires language server setup and live workspace state | Use for interactive verification and semantic enrichment |
| Compiler or AST/SCIP index | Precise symbol graph, imports, overloads, generated code, cross-file references | More expensive and stack-specific | Use where links need high confidence or CI-grade precision |
| Hybrid index | Tree-sitter candidates plus LSP/compiler confirmation | More moving parts and confidence modeling | Best long-term shape |

## Findings

### Incremental parsing is useful for watch mode, not required for batch indexes

Tree-sitter supports efficient reparsing by applying an edit to the old tree, passing that old tree into a new parse, and comparing changed ranges. That matters if AGENT-DOCS eventually runs a local daemon, editor integration, or file-watcher that updates docs-to-code candidates as code changes.

For a simple CLI or CI run, a full parse per changed file is easier to reason about. The index can start with batch parsing and add incremental updates later. When incremental mode is added, store enough edit information to update both byte offsets and row/column points, then invalidate only records whose ranges intersect Tree-sitter changed ranges.

### Concrete syntax trees are precise about source shape

Tree-sitter produces concrete syntax trees, which retain tokens such as parentheses and commas. For docs-to-code linking, this is valuable because a link target often needs an exact source span, not just an abstract declaration object. Named nodes let the index behave more like an AST when it wants declarations, expressions, parameters, and bodies without every punctuation token.

The practical rule is to index named nodes for symbols and structural chunks, but keep byte ranges for exact reconstruction and link anchors. Anonymous token nodes are still useful for narrow edits, formatting-sensitive snippets, and query patterns that need operators or delimiters.

### Node ranges are byte-first and need conversion discipline

Tree-sitter nodes expose `start_byte`, `end_byte`, `start_point`, and `end_point`. Points are zero-based rows and columns, and columns are byte counts from the beginning of the line in Tree-sitter's C API. LSP positions use zero-based line and character offsets whose encoding is negotiated, with UTF-16 as the default.

An AGENT-DOCS index should store:

- source path relative to repo root
- repo commit or content hash
- language and parser version
- node type and capture name
- symbol name and optional container name
- `start_byte`, `end_byte`
- `start_row`, `start_column`, `end_row`, `end_column`
- source text hash for the span

Do not treat Tree-sitter node IDs as durable IDs. A stable docs-to-code target should be based on path, language, parser/query versions, source range, symbol name, and content hash.

### Queries are the main extraction contract

Tree-sitter queries are a good fit for extracting declarations, references, doc comments, imports, exports, tests, and code chunks because query files can be versioned and tested independently of the indexer. Code-navigation tag queries already use captures such as `@definition.function`, `@definition.class`, `@reference.call`, and `@name`.

For AGENT-DOCS, query files should be treated as data contracts:

- keep per-language query files under a dedicated indexer/query directory
- record query file hashes in generated index metadata
- prefer field-name-specific patterns over broad node-type matches
- capture doc comments as optional `@doc` when adjacent comments matter
- include tests or snapshots for each language's expected captures

Tree-sitter predicates and directives can filter names, match doc-comment forms, and annotate injection languages. That is enough for high-quality candidate extraction, but not enough for full semantic resolution.

### Grammar coverage is broad but uneven

Tree-sitter has many official and community parsers, but each language still needs an available grammar, compiled parser, and queries for the features AGENT-DOCS wants. The GitHub code-navigation docs are a useful reality check: code navigation support depends on a mature parser, tag queries, and sometimes fully qualified name query support.

For AGENT-DOCS itself, the first practical language set should be small:

- Markdown/frontmatter links through existing `docs-meta`, not Tree-sitter as the primary parser
- Python for `scripts/docs-meta`
- shell for smoke tests and install scripts

For target repos, language support should be explicit in configuration. Unsupported languages should degrade to explicit Markdown links and text search, not silently produce low-confidence symbol links.

### Tree-sitter is not a semantic symbol resolver

Tree-sitter can identify syntax patterns and produce search-based code navigation data, but it does not type-check, resolve imports, understand build configuration, expand macros, choose overloads, evaluate generated sources, or know package-level symbol identity. Local-scope queries can improve highlights and local variable consistency, but they are still query-driven syntax analysis.

This creates predictable failure modes:

- two same-named functions in different modules look similar unless the query captures useful containers
- dynamic languages may need runtime or type-inference knowledge to distinguish calls
- C/C++ macros, conditional compilation, and generated headers need compiler context
- TypeScript path aliases and project references require project configuration
- Swift, Java, Kotlin, Rust, Go, and C# navigation is usually better when backed by their language servers or compiler frontends

The index should label Tree-sitter results as `syntax` or `search_based`, not `precise`.

### LSP and compiler indexes should own high-confidence semantics

LSP exposes go-to-definition, references, document symbols, workspace symbols, semantic tokens, hover, diagnostics, call hierarchy, type hierarchy, and rename-related operations. Compiler-backed or SCIP-style indexes go further by storing semantic occurrences and symbol identities for project-wide navigation.

Tree-sitter should feed candidate extraction and chunking. LSP should verify live workspace questions. Compiler or SCIP indexes should own high-confidence, cross-file, cross-package, or CI-gated symbol claims.

### Practical index design

A Tree-sitter-backed docs-to-code index should be a generated read model, probably adjacent to the optional SQLite idea in [CONC-0001](../concepts/CONC-0001-read-only-sqlite-docs-index.md).

Recommended tables or equivalent records:

| Record | Purpose |
|---|---|
| `files` | path, language, content hash, parser version, indexed timestamp |
| `captures` | query capture records with path, node type, capture, byte range, point range, text hash |
| `symbols` | normalized definitions with name, kind, container, signature excerpt, doc excerpt |
| `occurrences` | definitions and references with role, kind, range, source engine, confidence |
| `doc_links` | explicit Markdown code links, path links, symbol mentions, frontmatter references |
| `link_candidates` | candidate doc-to-code relationships with engine, score, ambiguity, and reason |
| `engine_metadata` | Tree-sitter version, parser versions, query hashes, LSP/compiler index source |

Resolution order:

1. Preserve explicit Markdown links as canonical user intent.
2. Resolve exact path-plus-range targets directly.
3. Use Tree-sitter definitions for unique same-repo symbol matches.
4. Use Tree-sitter references and doc-comment adjacency for candidate backlinks.
5. Use LSP or compiler/SCIP data to confirm ambiguous or high-value links.
6. Mark unresolved or ambiguous candidates rather than inventing certainty.

Suggested confidence labels:

| Confidence | Meaning |
|---|---|
| `explicit` | Human-authored doc link to path, range, or symbol key |
| `precise` | Confirmed by LSP/compiler/SCIP semantic data |
| `syntax_unique` | Unique Tree-sitter definition candidate in the configured scope |
| `syntax_ambiguous` | Multiple syntax candidates require review |
| `text_fallback` | Regex/search match only |

## Risks / Unknowns

- Parser availability and query quality vary by language.
- Query maintenance becomes real work once AGENT-DOCS supports many stacks.
- Byte ranges can drift if the index is not tied to content hashes or commits.
- LSP position encodings need careful conversion from Tree-sitter byte columns.
- Search-based symbol links can produce false positives and false negatives.
- Generated views can confuse users if they are not clearly labeled as caches.
- Multi-language documents, generated code, macros, and build-conditioned code need stack-specific treatment.

## Recommendation

Use Tree-sitter as the first generated syntax index for docs-to-code linking, not as the final authority for semantic symbol identity.

The best AGENT-DOCS fit is a hybrid:

- Markdown/frontmatter remains canonical.
- `docs-meta` continues to own doc metadata, generated registries, TODOs, and link checks.
- Tree-sitter provides fast local extraction of structural code targets, ranges, chunks, definitions, references, doc comments, and candidate backlinks.
- LSP enriches or verifies live workspace navigation when an agent needs precise "go to definition" or "find references" behavior.
- Compiler/AST/SCIP indexes own high-confidence semantic claims, especially across files, packages, generated code, or strongly typed build systems.

Do not add a broad Tree-sitter abstraction until there is a concrete docs-to-code workflow. Start with one narrow prototype:

1. Index Python definitions and shell script functions in this repo.
2. Store generated results in a disposable cache or JSON snapshot.
3. Link one research or architecture doc to exact code ranges.
4. Record confidence labels and ambiguity.
5. Add fixture tests for query captures before expanding language support.

Promote this research into a spec or ADR only after the workflow chooses whether docs-to-code links are advisory search aids, generated health signals, or binding documentation requirements. That decision changes how much precision AGENT-DOCS needs.

## Follow-Ups

- Create a small evaluation if comparing Tree-sitter-only candidates against LSP or compiler-backed answers on real repos.
- If the SQLite docs-index concept moves forward, include code-link tables as generated read-model tables rather than a separate canonical store.
- Define a minimal `code target` vocabulary before implementation: path target, range target, symbol definition, symbol reference, doc-comment association, generated backlink.
