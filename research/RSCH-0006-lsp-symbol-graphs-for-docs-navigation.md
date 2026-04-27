---
type: research-survey
id: RSCH-0006
title: LSP Symbol Graphs For Docs Navigation
domain: research
status: completed
created_at: "2026-04-27 20:12:54 JST +0900"
updated_at: "2026-04-27 20:15:59 JST +0900"
owner:
question: How can AGENT-DOCS use LSP symbol/navigation data to keep durable docs-to-code links fresh across code movement and edits?
source:
  type: conversation
  link:
  notes: Requested as parallel research on LSP-based symbol navigation for docs-to-code links.
external_sources:
  - title: Language Server Protocol overview
    url: https://microsoft.github.io/language-server-protocol/
  - title: Language Server Protocol Specification 3.17
    url: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/
  - title: clangd index design
    url: https://clangd.llvm.org/design/indexing
  - title: clangd protocol extensions
    url: https://clangd.llvm.org/extensions
  - title: clangd configuration
    url: https://clangd.llvm.org/config
  - title: gopls navigation features
    url: https://go.dev/gopls/features/navigation
  - title: gopls passive features
    url: https://tip.golang.org/gopls/features/passive
  - title: gopls implementation design
    url: https://tip.golang.org/gopls/design/implementation
repo_findings:
  - AGENT-DOCS should treat LSP results as observed facts tied to a repo commit, timestamp, server identity, and negotiated capabilities, not as permanent symbol IDs.
  - Durable links should prefer symbol/range anchors with optional exact line snapshots over bare file:line references.
agent_notes:
  - Edited only this assigned file during the parallel research session.
related_ideas: []
related_evaluations: []
related_adrs: []
related_specs: []
related_plans: []
related_sessions: []
linked_paths: []
repo_state:
  based_on_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
  last_reviewed_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
---

# RSCH-0006 - LSP Symbol Graphs For Docs Navigation

## Question

How should AGENT-DOCS store references from docs to code symbols or definitions if the source facts come from a Language Server Protocol server?

Scope includes LSP definition/reference/workspace-symbol requests, document symbols, semantic tokens, call hierarchy, type hierarchy, location ranges, and server/index staleness. The practical target is a durable doc reference that can be revalidated at a later commit and optionally relocated when line numbers drift.

## Context

LSP is a JSON-RPC protocol between clients and language servers. The official overview describes it as a way to share language features such as completion, go to definition, and references across editors. The same overview distinguishes LSP from LSIF: LSP is live server interaction, while LSIF is a graph format for code navigation without a local source checkout.

For AGENT-DOCS, this means LSP is best treated as an evidence source, not the durable store itself. A doc link can ask a server for symbol facts at a given repo state, but the saved reference needs its own freshness metadata because servers vary in index coverage, startup behavior, project configuration, and support for optional requests.

## External Sources

- [Language Server Protocol overview](https://microsoft.github.io/language-server-protocol/) states that LSP standardizes editor/server communication for features including go to definition and find references, and that LSIF stores programming-artifact navigation data as a graph.
- [LSP 3.17 specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/) is the current official specification as of this survey. It defines `Location`, `LocationLink`, `Range`, document synchronization, document symbols, workspace symbols, semantic tokens, call hierarchy, type hierarchy, and related capability negotiation.
- [clangd index design](https://clangd.llvm.org/design/indexing) documents a real server model: symbols, refs, and relations are indexed; a dynamic file index covers open/edited files; a background index parses the project; static and remote indexes are optional.
- [clangd protocol extensions](https://clangd.llvm.org/extensions) shows that server-specific index/status and symbol-identity extensions exist but are not portable LSP. It also documents that diagnostics may be delayed and that clangd exposes nonstandard file status and symbol info requests.
- [clangd configuration](https://clangd.llvm.org/config) documents that compile commands and index configuration affect how clangd understands code outside the current file.
- [gopls navigation features](https://go.dev/gopls/features/navigation) documents LSP-backed definition, type definition, references, document symbols, workspace symbols, call hierarchy, and type hierarchy for Go, including caveats such as non-exhaustive dynamic-call handling.
- [gopls passive features](https://tip.golang.org/gopls/features/passive) documents semantic tokens and notes that the server may disable them by default because type-checking adds latency.
- [gopls implementation design](https://tip.golang.org/gopls/design/implementation) documents snapshots, overlays, caches, package/type-checking results, and serializable indexes used to answer language-server requests.

## Repo / Internal Findings

- This survey file was created with `repo_state.based_on_commit` and `repo_state.last_reviewed_commit` set to `8a05bdd2ea2b2793145d4552bfbfaf551a616c3d`.
- The research folder currently contains sibling surveys for traceability tools, code knowledge graphs, documentation systems, Tree-sitter, AST/static analysis, and Swift symbol navigation. This file should own only the LSP-specific slice.
- No implementation exists in this repo yet for storing code symbol anchors. The recommendation below is a storage shape for future specs or implementation briefs.

## Agent Notes

Assumptions:

- AGENT-DOCS wants language-agnostic doc-to-code links across many repos, not a server-specific solution for one stack.
- Links should remain useful after nearby edits, file moves, and line-number drift.
- Exact line snapshots are optional because they create storage churn and may duplicate code, but they are valuable for revalidation and human review.
- Server-specific metadata is useful as evidence, but the portable core should use standard LSP types and repo metadata.

## Options Compared

### Bare file and line

Store only `path`, `start_line`, and `end_line`.

Pros:

- Simple to render in Markdown and code review.
- No language server needed to create or read the link.

Cons:

- Breaks silently when code moves.
- Cannot distinguish overloads, generated declarations, aliases, or renamed symbols.
- No way to know whether the line was observed before or after a symbol/index update.

Fit: acceptable for short-lived human notes, not enough for durable AGENT-DOCS references.

### LSP range anchor

Store a `DocumentUri` or repo-relative path plus LSP `Range`, with `positionEncoding`, observed commit, and timestamp.

Pros:

- Matches the protocol's native result shape for `Location`, `LocationLink`, symbols, call hierarchy, and type hierarchy.
- Captures precise selection ranges, including symbol-name ranges rather than full declarations.
- Can be revalidated by asking the server for document symbols or definition at the saved position.

Cons:

- LSP ranges are zero-based, use a negotiated position encoding, and have exclusive end positions. These details must be saved or normalized.
- A range alone still drifts after edits.
- Server behavior varies by language and project configuration.

Fit: good portable baseline, but should be paired with symbol identity and freshness metadata.

### Symbol identity plus observed locations

Store a symbolic anchor such as name, container, kind, language, file path, selection range, definition range, optional server-specific ID, optional LSP `moniker`, commit, timestamp, and exact text snapshot.

Pros:

- Gives a relocation strategy: query by workspace symbol or document symbols, then verify by name/container/kind and text/hash.
- Can distinguish "definition moved" from "symbol disappeared".
- Supports references, call/type edges, and exact line snapshots as evidence rather than as the only anchor.

Cons:

- More fields and more revalidation logic.
- Not every server exposes stable IDs. Standard LSP `SymbolInformation`, `DocumentSymbol`, `WorkspaceSymbol`, and `Location` do not guarantee a cross-session symbol ID.
- Overloads and generated symbols may still need language-specific disambiguation.

Fit: best default for AGENT-DOCS.

### Server-specific graph snapshot

Persist server-specific index data such as clangd symbol IDs/USRs, external index paths, or Go package/type indexes.

Pros:

- Can be more accurate for one language.
- May expose stable IDs or richer graph edges than standard LSP.

Cons:

- Not portable.
- Depends on server internals and versioned behavior.
- Harder for future agents to revalidate without recreating the same environment.

Fit: useful as optional evidence fields, not as the common schema.

## Findings

1. LSP is live, capability-negotiated evidence. The official site says LSP standardizes editor/server communication, while the spec relies on initialization capabilities for feature support. AGENT-DOCS should record the server name/version when available, requested method, capabilities used, and timestamp alongside each link.

2. Ranges are precise but easy to misuse. LSP positions are zero-based line/character offsets; since 3.17, clients and servers can negotiate position encoding, with UTF-16 as the mandatory/default encoding. `Range.end` is exclusive. Saved doc references should normalize to repo-relative paths and store both human line numbers and raw LSP range/encoding.

3. `textDocument/definition` and `textDocument/references` are the primary symbol-grounding requests. Definition can return `Location` or `LocationLink`; `LocationLink` is especially useful because it separates origin selection, target range, and target selection range. References return locations for usages, but completeness depends on server index coverage and language semantics.

4. `textDocument/documentSymbol` and `workspace/symbol` solve different jobs. Document symbols can return hierarchy and symbol ranges for one file. Workspace symbols search across a workspace, usually by fuzzy name, and may support lazy resolution. For revalidation, use document symbols when the file still exists; use workspace symbol search when the file moved or the range no longer matches.

5. Semantic tokens are enrichment, not identity. They can mark declaration/definition/read-only/library distinctions and help validate that a stored range still points at the same kind of construct, but token types/modifiers are negotiated and server-specific. They should not be the sole durable anchor.

6. Call hierarchy and type hierarchy are graph edges, but partial. Standard LSP has prepare-plus-edge requests for calls and types. gopls explicitly warns that dynamic calls are not included in its call hierarchy, and type hierarchy is limited to named types and assignability relations. AGENT-DOCS can store these edges as useful navigation evidence, but should mark them as server-derived and potentially incomplete.

7. Staleness is unavoidable and not standardized as one field. The LSP spec says clients must synchronize document changes before requesting reliable results. clangd documents a dynamic file index plus background/static/remote indexes; gopls documents snapshots, overlays, cache invalidation, and type-checking indexes. AGENT-DOCS should therefore store `observed_commit`, `observed_at`, `workspace_dirty`, `server`, and `index_status` when known, and should revalidate before presenting a link as fresh.

8. Official servers show why project configuration belongs in freshness metadata. clangd's results depend on compile commands and index configuration. gopls results depend on workspace/package loading, snapshots, overlays, and cached indexes. A doc link observed under one server configuration may be stale or wrong under another.

9. LSP has no portable stable symbol ID for all servers. Some servers expose internal IDs through extensions, and LSP has optional `moniker` support, but common navigation results mostly return names, kinds, URIs, and ranges. A durable AGENT-DOCS anchor should combine several weak identifiers rather than assume one stable ID exists.

10. Exact line snapshots are a practical relocation aid. Store a small excerpt or hash of the selected declaration/reference range and optionally the enclosing symbol range. On revalidation, compare exact text first, then use workspace/document symbol queries to relocate, then flag a human review if name/kind match but the snapshot diverges.

## Risks / Unknowns

- Feature support varies by server and client. Some servers support definitions and references but not call hierarchy, type hierarchy, semantic tokens, workspace symbol resolve, or monikers.
- Large repositories may have delayed or incomplete background indexes. A link produced at startup may be less trustworthy than one produced after index completion.
- Generated code, vendored dependencies, symlinks, multi-root workspaces, and virtual documents complicate URI normalization.
- Overloads, re-exports, aliases, macros, type inference, and dynamic dispatch can cause multiple legitimate definition/reference results.
- Server-specific exactness is not captured by the LSP result shape. A `Location` has no confidence score.
- Saving exact code snippets in docs metadata may create churn or expose code in docs artifacts that otherwise would not contain it. Prefer short local snapshots and hashes unless human-readable excerpts are needed.

## Recommendation

Use LSP as a revalidation engine, but store AGENT-DOCS references as repo-native symbolic anchors with freshness evidence.

Recommended core record:

```yaml
doc_code_ref:
  id: DREF-0001
  label: Human readable reference label
  intent: definition # definition | reference | symbol | call-edge | type-edge
  repo:
    root: .
    observed_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
    observed_at: "2026-04-27 20:15:59 JST +0900"
    workspace_dirty: false
  lsp:
    server_name: clangd
    server_version: null
    protocol_version: "3.17"
    position_encoding: utf-16
    method: textDocument/definition
    capabilities:
      definition_link_support: true
      hierarchical_document_symbol_support: true
  symbol:
    language_id: cpp
    kind: Function
    name: parseBrief
    container: agent_docs::planning
    detail: null
    server_symbol_id: null
    moniker: null
  target:
    path: src/planning/briefs.cpp
    uri: file:///repo/src/planning/briefs.cpp
    range:
      start: { line: 41, character: 0 }
      end: { line: 68, character: 1 }
    selection_range:
      start: { line: 41, character: 6 }
      end: { line: 41, character: 16 }
    human_lines: "42-69"
  snapshot:
    mode: optional-exact-lines
    text_sha256: null
    selected_text: null
    enclosing_text_sha256: null
  freshness:
    status: fresh # fresh | stale | needs-revalidation | unresolved
    last_validated_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
    last_validated_at: "2026-04-27 20:15:59 JST +0900"
    index_status: unknown
    notes: null
```

Revalidation flow:

1. If the observed commit equals the current commit and the workspace is clean, treat the link as fresh enough for navigation.
2. If only nearby lines changed, compare the optional snapshot hash or selected text.
3. If the file still exists, query `textDocument/documentSymbol` and match by range overlap, symbol name, kind, container, and selection text.
4. If the file moved or no local match exists, query `workspace/symbol` by name/container, resolve if supported, and verify by kind plus snapshot.
5. For definition/reference links, re-run `textDocument/definition` or `textDocument/references` from the nearest surviving origin anchor.
6. If call/type edges are stored, re-run the prepare request first, then re-run incoming/outgoing or subtypes/supertypes. Mark results partial unless the server docs say the edge class is complete.
7. If the server reports indexing progress/status through work-done progress, logs, diagnostics, or server-specific extensions, save that observation as evidence but keep it optional.

Policy:

- Do not present an LSP-derived doc link as fresh after the target file changed since `observed_commit` unless it has passed revalidation.
- Prefer `LocationLink.targetSelectionRange` or symbol `selectionRange` for clickable anchors, and keep the larger `targetRange` or symbol `range` for relocation context.
- Use server-specific IDs, monikers, or index paths only as optional accelerators.
- Keep the stored schema language-agnostic. Add language/server adapters only for better matching and diagnostics.

## Follow-Ups

- Define a small `DREF-*` schema or frontmatter block for AGENT-DOCS doc-to-code references.
- Prototype a validator that opens an LSP server, records capabilities, resolves document/workspace symbols, and updates `freshness`.
- Decide whether exact snapshots should store plaintext excerpts, hashes only, or both.
- Compare this LSP approach with RSCH-0004 Tree-sitter and RSCH-0005 AST/static-analysis anchors before choosing the default implementation path.
