---
type: research-survey
id: RSCH-0003
title: Documentation Systems With Source Links
domain: research
status: completed
created_at: "2026-04-27 20:12:53 JST +0900"
updated_at: "2026-04-27 20:17:40 JST +0900"
owner:
question: "What established documentation systems and source-linking patterns should AGENT-DOCS reuse for stable anchors, generated API docs, source links, commit pinning, stale warnings, and docs-index integration?"
source:
  type: conversation
  link:
  notes: "Subagent research task focused on documentation systems that bridge docs and source code."
external_sources:
  - label: "Doxygen configuration"
    url: "https://www.doxygen.nl/manual/config.html"
    accessed_at: "2026-04-27"
    notes: "Source browser, inline source, XML program listings, warnings, and source-link configuration."
  - label: "Doxygen external documentation"
    url: "https://www.doxygen.nl/manual/external.html"
    accessed_at: "2026-04-27"
    notes: "Tag files as compact external documentation inventories."
  - label: "Doxygen special commands"
    url: "https://www.doxygen.nl/manual/commands.html"
    accessed_at: "2026-04-27"
    notes: "Explicit anchors and references."
  - label: "Sphinx autodoc"
    url: "https://www.sphinx-doc.org/en/master/usage/extensions/autodoc.html"
    accessed_at: "2026-04-27"
    notes: "Docstring extraction mixed with hand-written documentation."
  - label: "Sphinx viewcode"
    url: "https://www.sphinx-doc.org/en/master/usage/extensions/viewcode.html"
    accessed_at: "2026-04-27"
    notes: "Generated highlighted source pages and back-links."
  - label: "Sphinx linkcode"
    url: "https://www.sphinx-doc.org/en/master/usage/extensions/linkcode.html"
    accessed_at: "2026-04-27"
    notes: "External source URL resolver."
  - label: "Sphinx intersphinx"
    url: "https://www.sphinx-doc.org/en/master/usage/extensions/intersphinx.html"
    accessed_at: "2026-04-27"
    notes: "External object inventories."
  - label: "MkDocs configuration"
    url: "https://www.mkdocs.org/user-guide/configuration/"
    accessed_at: "2026-04-27"
    notes: "Repository/edit links and link validation strictness."
  - label: "mkdocstrings usage"
    url: "https://mkdocstrings.github.io/usage/"
    accessed_at: "2026-04-27"
    notes: "Markdown-inline API documentation, inventories, and cross-reference behavior."
  - label: "Rustdoc book: what is rustdoc"
    url: "https://doc.rust-lang.org/rustdoc/index.html"
    accessed_at: "2026-04-27"
    notes: "Rust source comments to generated HTML and cargo integration."
  - label: "Rustdoc book: intra-doc links"
    url: "https://doc.rust-lang.org/rustdoc/write-documentation/linking-to-items-by-name.html"
    accessed_at: "2026-04-27"
    notes: "Symbol-name links resolved by rustdoc."
  - label: "Rustdoc book: lints"
    url: "https://doc.rust-lang.org/rustdoc/lints.html"
    accessed_at: "2026-04-27"
    notes: "Broken intra-doc link and private-link warnings."
  - label: "TypeDoc overview/options"
    url: "https://typedoc.org/documents/Overview.html"
    accessed_at: "2026-04-27"
    notes: "Source-link templates, git revision options, JSON output, and warning-as-error controls."
  - label: "Oracle javadoc tool"
    url: "https://docs.oracle.com/en/java/javase/12/tools/javadoc.html"
    accessed_at: "2026-04-27"
    notes: "External docs links, offline inventories, and source HTML generation."
  - label: "SwiftDocC"
    url: "https://swiftlang.github.io/swift-docc/documentation/swiftdocc/"
    accessed_at: "2026-04-27"
    notes: "Documentation catalogs, symbol graphs, and compiled topic graph."
  - label: "Swift-DocC pipeline"
    url: "https://swiftlang.github.io/swift-docc/documentation/swiftdocc/compilerpipeline/"
    accessed_at: "2026-04-27"
    notes: "Symbol graph inputs and dead-link reference resolution."
  - label: "GitHub Docs: permanent links to files"
    url: "https://docs.github.com/en/enterprise-cloud@latest/repositories/working-with-files/using-files/getting-permanent-links-to-files"
    accessed_at: "2026-04-27"
    notes: "Branch links versus commit-pinned permalinks."
  - label: "GitHub Docs: viewing and understanding files"
    url: "https://docs.github.com/en/repositories/working-with-files/using-files/viewing-and-understanding-files"
    accessed_at: "2026-04-27"
    notes: "Blame view and line history."
repo_findings:
  - "AGENT-DOCS already treats source docs as canonical and generated docs-meta views as dashboards; see README.md and scripts/docs-meta."
  - "Research survey frontmatter already carries repo_state.based_on_commit and repo_state.last_reviewed_commit, which can support freshness warnings."
  - "scripts/docs-meta already recognizes research-survey status values including completed and has generated-view/check/health commands that could host link freshness checks."
agent_notes:
  - "Use official docs where practical. Plugin docs are included for mkdocstrings because MkDocs itself delegates API-doc behavior to plugins."
  - "This survey is complete enough for AGENT-DOCS design work, but exact adapter behavior should be rechecked before implementing support for any specific generator output."
related_ideas: []
related_evaluations: []
related_adrs: []
related_specs: []
related_plans: []
related_sessions: []
linked_paths:
  - README.md
  - scripts/docs-meta
  - scaffold/docs/research/README.md
repo_state:
  based_on_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
  last_reviewed_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
---

# RSCH-0003 - Documentation Systems With Source Links

## Question

What established documentation systems and source-linking patterns should AGENT-DOCS reuse for stable anchors, generated API docs, source links, commit pinning, stale warnings, and docs-index integration?

## Context

AGENT-DOCS is Markdown-first repo memory. Its durable docs explain intent, decisions, plans, research, handoffs, and current state; `scripts/docs-meta` derives generated views and checks from those source docs.

The question is not whether AGENT-DOCS should become Doxygen, Sphinx, or DocC. The useful design problem is smaller: how should AGENT-DOCS point from durable prose to source code and generated API/reference systems without creating stale, ambiguous, or unqueryable links?

## External Sources

| System | Source-linked pattern | What AGENT-DOCS can reuse |
| --- | --- | --- |
| Doxygen | `SOURCE_BROWSER` creates source pages; `REFERENCES_LINK_SOURCE` can point references to source; `INLINE_SOURCES` embeds implementation bodies; XML program listings and tag files expose machine-readable link data. | Use generated source/API output as an optional sidecar index, not as the primary AGENT-DOCS authoring model. Doxygen tag files are a precedent for compact cross-project inventories. |
| Doxygen anchors | `\anchor` creates a named invisible anchor and `\ref` targets named anchors, pages, and sections. | Keep stable semantic IDs in source docs (`RSCH-*`, `SPEC-*`, `ADR-*`, `TODO-*`) instead of trusting generated heading slugs alone. |
| Sphinx autodoc | Imports modules, extracts docstrings, and can mix generated API content with hand-written pages. The official docs explicitly frame this as reducing duplicate maintenance while avoiding purely auto-generated API docs. | Preserve a split between hand-authored rationale docs and generated API/reference docs. AGENT-DOCS should link across that boundary, not collapse it. |
| Sphinx viewcode/linkcode | `viewcode` generates highlighted source pages with links from object descriptions and back from source to docs; `linkcode` delegates URL construction to a resolver for externally hosted source. | Source links should be generated from path/symbol metadata by a resolver where possible. Hand-written docs should not manually duplicate URL templates everywhere. |
| Sphinx intersphinx | `objects.inv` maps external documented objects to URLs, with optional local inventory files that still link to remote docs. | A docs-index can ingest or mimic inventories: stable object key, canonical URL, version/source, and update responsibility. |
| MkDocs | `repo_url` plus `edit_uri` produces page source/edit links; validation settings can promote link diagnostics to strict build errors. | Markdown-first docs can still carry source/edit links. Link validation belongs in deterministic tooling, not in prose reminders. |
| mkdocstrings/autorefs | API docs can be injected inline in Markdown with `:::` identifiers; inventories and autorefs support cross-references beyond local headings. | AGENT-DOCS can use lightweight inline references to symbols or local paths, then let docs-meta/index code resolve and validate them. |
| Rustdoc | Generates HTML from Rust comments and Markdown; intra-doc links resolve by item path rather than by fragile URL; rustdoc lints warn on broken links. | Prefer symbol/path identifiers over raw generated URLs when a resolver exists. Treat broken doc/source references as warnings or errors in checks. |
| TypeDoc | `sourceLinkTemplate` supports `{path}`, `{line}`, and `{gitRevision}`; `gitRevision` pins source links; JSON output exposes a machine-readable model; warnings can be treated as errors. | This is the clearest template for AGENT-DOCS source links: path + line + revision are data, and URL rendering is a generated view. |
| Javadoc | `-link` and `-linkoffline` link to external generated docs; `-linksource` emits source HTML with line numbers and links from API docs. | Separate external API inventories from local docs, and make source browsing an optional generated artifact. |
| Swift DocC | Combines source comments, Markdown catalogs, assets, and symbol graphs into a compiled topic graph; the pipeline resolves references to detect potentially dead links. | A docs-index should be a compiled graph from Markdown frontmatter, repo paths, optional symbol indexes, and external source metadata. |
| GitHub permalinks/blame | Branch file URLs move as branch heads change; replacing the branch with a commit ID pins file contents. Blame view shows line-by-line history with commit, author, message, and date. | Distinguish immutable evidence links from current-working-tree links. Store reviewed commit and use blame/permalinks when a research or ADR claim depends on exact historical code. |

## Repo / Internal Findings

- [README.md](../README.md) describes `docs-meta` as the deterministic layer for IDs and generated views. Generated dashboards are views, not state.
- [scripts/docs-meta](../scripts/docs-meta) already knows the `research-survey` doc type, accepts `completed`, scans frontmatter, creates generated views, and has `check`, `check-links`, and `health` commands.
- [scaffold/docs/research/README.md](../scaffold/docs/research/README.md) frames `RSCH-*` as sourced landscape work before a decision or implementation plan.
- Current research frontmatter already carries `repo_state.based_on_commit` and `repo_state.last_reviewed_commit`. That is enough to start warning when a code-backed conclusion was reviewed against an older tree.

## Agent Notes

- Official docs were preferred. For MkDocs API-doc behavior, mkdocstrings is included because core MkDocs intentionally delegates source-code documentation to plugins.
- The systems converge on the same pattern: authored docs stay readable, generated reference docs stay reproducible, and machine-readable inventories connect them.
- Exact generated anchor formats vary by tool and version. Stable AGENT-DOCS IDs and source path/symbol metadata should be the durable layer.

## Options Compared

| Option | Strengths | Weaknesses | Fit for AGENT-DOCS |
| --- | --- | --- | --- |
| Full API-doc generator adoption | Mature source parsing, generated reference pages, source browsers, warnings, inventories. | Language-specific setup, generated output churn, easy to confuse API reference with design memory. | Use only as optional sidecar input when the target repo already has one. |
| Manual Markdown links to source | Simple, readable, no new parser required. | Branch links drift, line links stale, URLs are hard to validate semantically. | Good for small repos if links are relative paths or commit-pinned GitHub permalinks. |
| Symbol/inventory-backed docs-index | Keeps source docs authoritative while allowing generated lookup, warnings, backlinks, stale checks, and multiple language adapters. | Requires schema and resolver discipline; first version should stay small. | Best strategic fit. Build from AGENT-DOCS metadata first, then ingest tool-specific indexes later. |
| Generated source-link URL templates | Centralizes GitHub/GitLab/source-host URL rules and commit pinning. | Needs repository remote and revision metadata; private hosts vary. | Strong fit as a docs-meta helper or generated view. |

## Findings

1. Stable anchors should be semantic before they are visual. Doxygen has explicit anchors, Sphinx and Rustdoc have symbolic cross-references, and AGENT-DOCS already has stable IDs. Generated heading slugs and HTML filenames are useful outputs, not durable source-of-truth IDs.

2. Generated API docs and hand-written docs solve different problems. Sphinx autodoc, Rustdoc, TypeDoc, Javadoc, Doxygen, and DocC all reduce drift for API surface details, but they do not replace rationale, decisions, research, execution boundaries, or current-state handoffs.

3. Source links need a typed model. A durable doc should distinguish `current source path`, `symbol reference`, `commit-pinned evidence`, and `external documentation`. Raw URLs alone do not say whether the reader should expect current truth or historical evidence.

4. Commit pinning is the cleanest stale-link boundary. GitHub documents that branch URLs can change and commit URLs preserve exact file contents. TypeDoc's `{gitRevision}` source-link placeholder shows the same idea in generator form.

5. Inventories are the recurring bridge pattern. Doxygen tag files, Sphinx `objects.inv`, mkdocstrings inventories, Javadoc package/element lists, TypeDoc JSON, Rustdoc JSON workflows, and Swift symbol graphs all separate "what exists" from "how pages render."

6. Stale warnings belong in checks and generated health views. MkDocs strict validation, rustdoc lints, TypeDoc warning-as-error flags, and DocC reference resolution all put freshness feedback in tooling. AGENT-DOCS should do the same through `docs-meta check`, `check-links`, and `health`.

7. Source browsers are useful but secondary. Doxygen, Sphinx viewcode, Javadoc `-linksource`, and hosted GitHub source pages make source inspection easy, but they are outputs. The durable AGENT-DOCS record should store path, revision, symbol, and reviewed-at metadata.

8. Blame is context, not just attribution. GitHub blame can explain why a line changed and whether a doc claim may be old. A future docs-index can use blame or commit metadata to prioritize stale warnings without rewriting source docs.

## Risks / Unknowns

- Generated anchors and output filenames can change across tool versions, themes, or language handlers.
- Line-number links are brittle for current-source links. Commit-pinned line links remain historically accurate but may no longer describe current behavior.
- Sphinx autodoc and viewcode import Python modules, so builds can execute import-time side effects unless projects are disciplined.
- External inventories may be missing, stale, unversioned, private, or hosted at a different URL than the rendered docs.
- A docs-index that tries to parse every language immediately would overreach. The first useful version can validate Markdown paths, commit hashes, URL shapes, and optional symbol strings.

## Recommendation

Use a small AGENT-DOCS source-link model and let `docs-meta` generate or validate views from it.

Recommended link classes:

- `doc_anchor`: stable AGENT-DOCS ID or explicit Markdown anchor.
- `code_current`: relative repo path plus optional line range and symbol, checked against the current working tree.
- `code_evidence`: repo path plus commit SHA plus optional line range, used when a claim depends on exact historical code.
- `symbol_ref`: language plus qualified symbol name plus optional declaring path, resolved by optional adapters.
- `external_doc`: URL plus source label, accessed date, and optional version/inventory URL.

Recommended checks:

- Warn when a completed doc's `repo_state.last_reviewed_commit` is older than the current commit and the doc has code-linked findings.
- Warn on GitHub `blob/main`, `blob/master`, or other branch URLs when the source is being used as evidence.
- Warn when `linked_paths` entries no longer exist.
- Warn when `external_sources` entries lack a URL or accessed date.
- Keep generated dashboards and future docs-index tables derived from source docs; do not hand-edit generated views.

The implementation should start with Markdown/frontmatter validation and GitHub permalink generation. Tool-specific adapters for Doxygen XML/tag files, Sphinx inventories, TypeDoc JSON, Rustdoc JSON, Swift symbol graphs, or Javadoc element lists should be optional later inputs, not baseline requirements.

## Follow-Ups

- Define a minimal `external_sources` and `linked_paths` schema that `scripts/docs-meta check` can validate without breaking existing docs.
- Prototype a `docs-meta health` warning for branch-based GitHub source URLs in completed research, ADR, and spec docs.
- Decide whether source links should live only in frontmatter arrays, inline Markdown links, or both with docs-meta extraction.
- Pair this survey with the sibling AST, LSP, Tree-sitter, and knowledge-graph research docs before choosing a source-symbol adapter strategy.
