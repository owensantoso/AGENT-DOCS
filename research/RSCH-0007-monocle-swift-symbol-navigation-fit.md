---
type: research-survey
id: RSCH-0007
title: Monocle Swift Symbol Navigation Fit
domain: research
status: completed
created_at: "2026-04-27 20:12:54 JST +0900"
updated_at: "2026-04-27 22:05:46 JST +0900"
owner: "Codex main agent"
question: "How should AGENT-DOCS use Monocle for Swift docs-to-code linking and symbol freshness?"
source:
  type: conversation
  link:
  notes: "Requested as a separate deep dive after mentioning Monocle was installed for Swift symbol lookup."
external_sources:
  - title: "Local Monocle README"
    url: "local-monocle-cache/README.md"
  - title: "Local Monocle AGENTS.md"
    url: "local-monocle-cache/AGENTS.md"
  - title: "Local Monocle SymbolInfo.swift"
    url: "local-monocle-cache/Sources/MonocleCore/SymbolInfo.swift"
  - title: "Local Monocle LspSession.swift"
    url: "local-monocle-cache/Sources/MonocleCore/LspSession.swift"
  - title: "SwiftedMind/monocle GitHub repository"
    url: "https://github.com/SwiftedMind/monocle"
  - title: "SourceKit-LSP repository"
    url: "https://github.com/swiftlang/sourcekit-lsp"
  - title: "Swift.org Cursor setup for SourceKit-LSP"
    url: "https://www.swift.org/documentation/articles/getting-started-with-cursor-swift.html"
repo_findings:
  - "A local Monocle source checkout exists at local Monocle source cache."
  - "The local checkout remote is https://github.com/SwiftedMind/monocle.git at commit 31dd6500c3b26e7e698e910072af5662b955711f."
  - "A Homebrew core formula named monocle also exists locally but points to bgpkit/monocle, which is unrelated to the SwiftedMind agent tool."
  - "The `monocle` executable was not found on PATH in this AGENT-DOCS shell session."
agent_notes:
  - "This survey is grounded primarily in the local cached Monocle source, not the unrelated Homebrew core formula metadata."
  - "Monocle is a Swift/SourceKit-LSP adapter and should be treated as a language-specific precision tool, not a universal docs graph store."
related_ideas:
  - ../docs-meta/ideas/IDEA-0001-docs-to-code-graph.md
related_evaluations: []
related_adrs: []
related_specs: []
related_plans: []
related_sessions: []
linked_paths:
  - research/RSCH-0006-lsp-symbol-graphs-for-docs-navigation.md
repo_state:
  based_on_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
  last_reviewed_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
---

# RSCH-0007 - Monocle Swift Symbol Navigation Fit

## Question

How should AGENT-DOCS use Monocle for Swift docs-to-code linking and symbol freshness?

## Context

Monocle is relevant because the user specifically called out a Swift-focused tool that agents can use to look up symbol definitions. Unlike a broad docs graph or syntax parser, Monocle is already shaped for agent workflows: given a Swift file, line, and column, it returns SourceKit-LSP-backed definition, signature, and documentation data.

This makes Monocle a likely adapter for Swift target repos in an AGENT-DOCS docs-to-code graph. The caveat is important: it should provide observed symbol evidence and revalidation help, not become the source of truth for docs intent.

## External Sources

- Local Monocle README: `local Monocle source cache/README.md`.
- Local Monocle agent guide: `local Monocle source cache/AGENTS.md`.
- Local Monocle model code: `local Monocle source cache/Sources/MonocleCore/SymbolInfo.swift`.
- Local Monocle LSP session code: `local Monocle source cache/Sources/MonocleCore/LspSession.swift`.
- Local Monocle remote: `https://github.com/SwiftedMind/monocle.git`, checked out at `31dd6500c3b26e7e698e910072af5662b955711f`.
- [SwiftedMind/monocle](https://github.com/SwiftedMind/monocle) is the project named by the local checkout.
- [SourceKit-LSP](https://github.com/swiftlang/sourcekit-lsp) provides Swift and C-family LSP features, including code completion and jump-to-definition, built on sourcekitd and clangd.
- [Swift.org Cursor setup](https://www.swift.org/documentation/articles/getting-started-with-cursor-swift.html) documents SourceKit-LSP editor features and notes index/build freshness requirements for some Swift versions.

## Repo / Internal Findings

- The AGENT-DOCS repo itself is not a Swift project, so Monocle is mainly relevant to consuming repos with Swift code.
- `research/RSCH-0006-lsp-symbol-graphs-for-docs-navigation.md` already defines a general LSP-backed `doc_code_ref` shape. Monocle can fill the Swift-specific `lsp` and `symbol` evidence fields.
- The local Monocle cache includes daemon support, workspace detection, symbol search, package listing, and SourceKit-LSP session management.
- Running `command -v monocle && monocle --help` returned no executable in this shell, so this survey records source-level fit rather than a live CLI run.

## Agent Notes

- Treat local Monocle docs as the primary source because they describe the installed/cached SwiftedMind tool. The local Homebrew API formula for `monocle` is unrelated BGP software and should not be used for this purpose.
- Monocle's CLI uses one-based line and column positions, while LSP uses zero-based positions internally. Any AGENT-DOCS adapter must store this conversion explicitly.
- Monocle is read-only. That matches AGENT-DOCS's preference for generated evidence and explicit human/agent acceptance before mutating docs.

## Options Compared

| Option | Strengths | Limits | Fit |
|---|---|---|---|
| Use raw SourceKit-LSP | Standard LSP surface, direct capabilities | More protocol/session work for agents | Good lower-level primitive |
| Use Monocle CLI | Agent-friendly JSON, definition + hover in one call, workspace-aware | Swift-only, needs tool installed and SourceKit-LSP configured | Best Swift adapter |
| Use Swift SymbolGraph/DocC | Good public API/topic graph | Less direct for cursor-based implementation lookup | Good complementary API-doc source |
| Use Tree-sitter Swift | Fast syntax ranges without build setup | Not semantic enough for dependencies/overloads | Useful fallback/chunking layer |
| Use CodeQL or compiler indexes | Deeper semantic/static analysis | Heavier setup and broader than navigation | Later precision/evaluation layer |

## Findings

1. Monocle is explicitly agent-oriented. Its README describes a read-only CLI for Swift symbol lookup via SourceKit-LSP, designed so agents can get definition location, signature, and documentation without opening Xcode.

2. The core command shape maps directly to doc-code revalidation: `monocle inspect --file <path> --line <line> --column <column> --json`. The location must point inside the identifier and uses one-based coordinates.

3. Monocle exposes the right evidence for AGENT-DOCS: symbol name, kind, module, definition URI, start/end line and character, signature, documentation, and optional snippet.

4. `monocle symbol --query ... --json` can search workspace symbols by name, with options for exact matching, enrichment, scope, preference, and context lines. This is useful when a stored file/range link went stale and needs relocation candidates.

5. Monocle is SourceKit-LSP-backed, so it inherits LSP freshness caveats. The README says Xcode projects/workspaces need `buildServer.json` for reliable dependency/SDK framework resolution, while SwiftPM packages can be resolved directly.

6. The local AGENTS.md states the architecture clearly: core manages LSP sessions and sends requests; CLI wraps core; daemon keeps SourceKit-LSP warm. This is a good fit for repeated agent lookups.

7. The `SymbolInfo` model uses one-based line and character fields in JSON-facing data. The `LspSession` code converts from user-provided one-based coordinates to zero-based LSP `Position`.

8. Monocle currently appears optimized for definition, hover, inspect, package listing, and workspace symbol search. References, document symbols, and broader graph extraction may require future Monocle features or direct SourceKit-LSP calls.

9. Monocle should not be made canonical. It is best stored as observed evidence tied to repo commit, workspace root, tool version/source commit, SourceKit-LSP version, buildServer state, and timestamp.

## Risks / Unknowns

- The `monocle` binary was not on PATH during this survey, despite the cached source checkout. Installing or linking the intended SwiftedMind CLI is a separate setup step.
- The local Homebrew formula metadata for `monocle` points to unrelated BGP software, so automation must avoid `brew install monocle` unless the intended tap is explicit.
- SourceKit-LSP can return incomplete results if the project has not built recently, if `buildServer.json` is missing for Xcode projects, or if dependencies/SDK settings are stale.
- Swift macros, generated sources, conditional compilation, package checkouts, and DerivedData state can affect symbol resolution.
- Monocle's output is excellent for point lookup, but a full docs-to-code graph still needs batch indexing or a separate source-symbol extraction path.

## Recommendation

Use Monocle as the preferred Swift precision adapter for AGENT-DOCS, behind the same language-neutral `doc_code_ref` or `code_ref` schema recommended by the LSP survey.

Recommended Swift flow:

1. A doc stores an explicit current surface such as `Sources/App/FooView.swift` plus optional symbol name.
2. When an agent needs precision, it calls Monocle at a known file/line/column or searches with `monocle symbol`.
3. The generated code-link cache stores Monocle output as evidence: symbol, kind, module, definition URI, human lines, signature hash or snippet hash, documentation hash, workspace root, Monocle source version, SourceKit-LSP version if available, observed commit, and timestamp.
4. If the file or line range changes, AGENT-DOCS revalidates with Monocle symbol search and inspect rather than trusting old line anchors.
5. If Monocle cannot resolve the symbol, mark the edge `unresolved` or `needs-revalidation` instead of deleting the authored doc link.

Monocle should complement Tree-sitter and LSP research:

- Tree-sitter: cheap Swift syntax chunks and candidate symbols.
- Monocle: precise SourceKit-LSP-backed Swift symbol evidence for agents.
- SymbolGraph/DocC: API documentation graph for public modules.
- Generated docs index: durable join table that connects AGENT-DOCS docs to observed Swift code facts.

## Follow-Ups

- Add a setup note to consuming Swift repos: install `SwiftedMind/cli/monocle`, verify `xcrun sourcekit-lsp --help`, and generate `buildServer.json` for Xcode projects.
- Prototype a `docs-meta code inspect-swift` helper that shells out to Monocle and stores generated evidence in a disposable cache.
- Decide whether `monocle symbol --enrich` output is enough for stale-link relocation, or whether AGENT-DOCS also needs direct SourceKit-LSP references/document-symbol calls.
- In a Swift target repo, run one real Monocle lookup and preserve its JSON as an `EVAL-*` or diagnostic fixture before designing automation.
