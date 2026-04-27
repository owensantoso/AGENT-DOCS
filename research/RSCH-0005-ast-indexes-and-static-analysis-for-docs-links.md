---
type: research-survey
id: RSCH-0005
title: AST Indexes And Static Analysis For Docs Links
domain: research
status: completed
created_at: "2026-04-27 20:12:54 JST +0900"
updated_at: "2026-04-27 22:05:46 JST +0900"
owner: "Codex main agent"
question: "How should AGENT-DOCS use AST, compiler, and static-analysis indexes for precise docs-to-code links?"
source:
  type: conversation
  link:
  notes: "Requested as part of the Tree-sitter, AST, and LSP research stream for docs-to-code linking."
external_sources:
  - title: "CodeQL overview"
    url: "https://codeql.github.com/docs/codeql-overview/about-codeql/"
  - title: "CodeQL database create CLI manual"
    url: "https://docs.github.com/en/code-security/reference/code-scanning/codeql/codeql-cli-manual/database-create"
  - title: "CodeQL call graph guide"
    url: "https://codeql.github.com/docs/codeql-language-guides/navigating-the-call-graph/"
  - title: "CodeQL Go library guide"
    url: "https://codeql.github.com/docs/codeql-language-guides/codeql-library-for-go/"
  - title: "clangd index design"
    url: "https://clangd.llvm.org/design/indexing"
  - title: "clangd configuration"
    url: "https://clangd.llvm.org/config"
  - title: "TypeScript compiler API"
    url: "https://github.com/microsoft/TypeScript/wiki/Using-the-Compiler-API"
  - title: "Swift-DocC documentation"
    url: "https://swiftlang.github.io/swift-docc/documentation/swiftdocc/"
  - title: "Swift-DocC open source announcement"
    url: "https://www.swift.org/blog/swift-docc/"
  - title: "Swift.org Cursor setup for SourceKit-LSP"
    url: "https://www.swift.org/documentation/articles/getting-started-with-cursor-swift.html"
repo_findings:
  - "AGENT-DOCS itself is mostly Markdown, Python, and shell, so a first compiler-backed prototype may need a target repo rather than this repo alone."
  - "The existing docs-meta health model already supports commit-based freshness warnings that could be reused for code-backed docs."
agent_notes:
  - "This survey treats AST/compiler indexes as precision layers, not as the first source-of-truth store."
  - "Language-native APIs are powerful but vary sharply by ecosystem, so a common schema must preserve engine-specific evidence."
related_ideas:
  - ../docs-meta/ideas/IDEA-0001-docs-to-code-graph.md
related_evaluations: []
related_adrs: []
related_specs: []
related_plans: []
related_sessions: []
linked_paths:
  - scripts/docs-meta
  - concepts/CONC-0001-read-only-sqlite-docs-index.md
repo_state:
  based_on_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
  last_reviewed_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
---

# RSCH-0005 - AST Indexes And Static Analysis For Docs Links

## Question

How should AGENT-DOCS use AST, compiler, and static-analysis indexes for precise docs-to-code links?

## Context

Tree-sitter can cheaply identify syntax, and LSP can answer live navigation questions. AST/compiler/static-analysis indexes sit one layer deeper: they can know about name binding, types, call graphs, data flow, generated code, build configuration, and precise source locations.

That precision is valuable for docs-to-code links that should survive refactors or support claims like "this plan changed the implementation of X." It also carries cost: indexers are language-specific, build-sensitive, and heavier to install than Markdown parsing.

## External Sources

- [CodeQL overview](https://codeql.github.com/docs/codeql-overview/about-codeql/) describes database creation as extracting source files into a relational representation with AST, name binding, type information, and language-specific schemas.
- [CodeQL database create CLI manual](https://docs.github.com/en/code-security/reference/code-scanning/codeql/codeql-cli-manual/database-create) documents build modes and database clusters for multi-language analysis.
- [CodeQL call graph guide](https://codeql.github.com/docs/codeql-language-guides/navigating-the-call-graph/) shows call graph entities such as callables and calls.
- [CodeQL Go library guide](https://codeql.github.com/docs/codeql-language-guides/codeql-library-for-go/) distinguishes AST, data-flow graph, and call graph views over a codebase.
- [clangd index design](https://clangd.llvm.org/design/indexing) describes symbols, refs, relations, dynamic/background/static/remote indexes, and cached index files.
- [clangd configuration](https://clangd.llvm.org/config) shows how compile commands, external indexes, and background indexing affect source understanding.
- [TypeScript compiler API](https://github.com/microsoft/TypeScript/wiki/Using-the-Compiler-API) documents `Program`, AST traversal, `TypeChecker`, `Symbol`, `Type`, declarations, and documentation extraction.
- [Swift-DocC](https://swiftlang.github.io/swift-docc/documentation/swiftdocc/) documents symbol graph files as API descriptions with `.symbols.json` input to the documentation compiler.
- [Swift-DocC open source announcement](https://www.swift.org/blog/swift-docc/) describes Swift-DocC processing source comments, Markdown, assets, and machine-readable JSON archives, and names SymbolKit as the parser for compiler-emitted symbol graphs.
- [Swift.org Cursor setup](https://www.swift.org/documentation/articles/getting-started-with-cursor-swift.html) notes that SourceKit-LSP provides definition, references, rename, diagnostics, and quick fixes, and that older Swift versions required builds to populate the index.

## Repo / Internal Findings

- `scripts/docs-meta` already stores `repo_state.last_reviewed_commit` and can detect stale docs by commit distance. This is the right freshness hook for code-backed references too.
- The current repo does not yet have a `code_refs` or `DREF-*` schema. Any compiler-backed index should first feed an advisory generated view before source docs depend on it.
- AGENT-DOCS should support target repos with different stacks. A single compiler API cannot be the baseline.

## Agent Notes

- Compiler-backed indexes should be used when correctness matters more than setup cost: public API docs, ADR evidence, migration plans, security-sensitive flows, and refactor verification.
- Compiler indexes are not a replacement for explicit doc intent. A call graph can show what calls what; it cannot say which plan, decision, or invariant owns that relationship unless docs attach that meaning.

## Options Compared

| Option | What It Knows | Rebuild Cost | Source Location Stability | Fit |
|---|---|---|---|---|
| Language-native compiler API | AST, symbols, types, declarations, docs | Medium to high; project setup required | Strong inside one ecosystem | Best for targeted adapters |
| CodeQL database | AST, binding, type, CFG/DFG, call/data-flow libraries | High; build/extractor driven | Strong for supported languages | Best for deep queries and audits |
| clangd index | C/C++ symbols, refs, relations, declaration/definition locations | Medium; compile commands and indexing needed | Strong when build config is correct | Good model for symbol/ref/relation records |
| Swift SymbolGraph/DocC | API symbols and docs for Swift modules | Medium; build/symbol extraction needed | Strong for public API, less for local implementation references | Good for Swift API documentation links |
| TypeScript compiler API | AST, symbols, types, declarations, JSDoc | Medium; tsconfig/module resolution required | Strong when project graph is loaded | Good for JS/TS target repos |
| SourceKit-LSP/Monocle | Live Swift definition/hover/workspace symbol | Medium; build/index/buildServer state needed | Good as observed evidence | Best for agent lookup and revalidation |

## Findings

1. Compiler-backed indexes are the best precision layer for symbol identity. Tree-sitter finds syntax; compilers bind names, types, declarations, imports, overloads, and generated or dependency context.

2. Build configuration is part of the data. CodeQL compiled-language extraction watches builds, clangd depends on compile commands/index config, TypeScript depends on `tsconfig` and module resolution, and SourceKit-LSP depends on SwiftPM/Xcode build context.

3. Store source ranges with engine evidence. A record should include path, line/range, byte or character encoding if available, symbol name, container/module, engine name/version, index/build configuration, observed commit, and confidence.

4. CodeQL is a strong follow-up for repeatable evaluations, not a first docs-link validator. It can answer deep questions about data flow and call graphs, but it is too heavy for ordinary "where is the code this doc means?" navigation.

5. clangd's index vocabulary is a good reusable mental model: `Symbol`, `Ref`, and `Relation`. AGENT-DOCS can use similar terms in generated indexes without adopting clangd directly.

6. Swift SymbolGraph/DocC is useful for public API and docs-topic graphs, but it does not fully replace SourceKit-LSP/Monocle for "symbol under cursor" implementation lookup.

7. TypeScript's compiler API shows the advantage of language-native adapters: `getSymbolAtLocation`, declarations, type information, and documentation comments can be extracted without one LSP call per symbol.

8. Static-analysis indexes should feed confidence, not rewrite meaning. If an AST says a function calls another function, that is an extracted fact; whether the doc should link to that call path is still authored intent or reviewed generated evidence.

## Risks / Unknowns

- Some ecosystems expose stable symbol IDs; others expose only names and ranges. A portable AGENT-DOCS schema must tolerate weak identity.
- Generated code, macros, build flags, platform conditionals, and vendored dependencies can shift what the compiler sees.
- Multi-language repos may require multiple databases or indexers that disagree about paths and source roots.
- Index generation can be slow enough that it belongs in explicit commands or CI jobs, not every docs edit.
- Compiler APIs and index schemas can be version-sensitive, especially for Swift and TypeScript.
- Code snippets embedded in doc metadata may expose more source than intended. Prefer hashes unless readable excerpts are necessary.

## Recommendation

Treat AST/compiler/static-analysis indexes as optional precision adapters behind a common `code_ref` model.

Recommended layering:

1. `docs-meta` owns explicit docs metadata, local paths, and generated health views.
2. Tree-sitter extracts cheap candidate symbols/ranges.
3. LSP/Monocle verifies live navigation questions.
4. Language-native compiler adapters or SCIP/CodeQL-style indexes provide higher-confidence semantic edges when a repo opts in.
5. Every generated edge carries `engine`, `engine_version`, `observed_commit`, `generated_at`, `source_root`, `confidence`, and enough range/symbol data to revalidate.

Do not require compiler-backed indexing for AGENT-DOCS adoption. Add it only for repos where stale doc-code links are causing real cost or where plans/ADRs need precise implementation evidence.

## Follow-Ups

- Define a minimal engine-neutral `code_ref` schema and confidence vocabulary.
- Run an evaluation comparing Tree-sitter, LSP/Monocle, and one compiler API on the same Swift or TypeScript repo.
- Decide whether CodeQL belongs as a `RSCH` follow-up, an `EVAL-*` benchmark, or a diagnostics/audit integration.
- If the SQLite index concept moves forward, reserve tables for `code_symbols`, `code_occurrences`, `code_relations`, and `doc_code_edges`.
