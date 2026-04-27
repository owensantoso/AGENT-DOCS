---
type: research-survey
id: RSCH-0001
title: Docs Code Traceability Tools
domain: research
status: completed
created_at: "2026-04-27 20:12:53 JST +0900"
updated_at: "2026-04-27 20:16:28 JST +0900"
owner: "Codex subagent"
question: "What existing tools and practices should inform AGENT-DOCS links from Markdown source-of-truth docs to code locations, traceability matrices, permalinks, and stale-link handling?"
source:
  type: conversation
  link:
  notes: "Requested current web research for a focused RSCH document. Other subagents were assigned sibling research docs."
external_sources:
  - title: "GitHub Docs: Getting permanent links to files"
    url: "https://docs.github.com/en/repositories/working-with-files/using-files/getting-permanent-links-to-files"
    type: official-docs
    relevance: "Commit SHA permalinks preserve the exact file version seen during review."
  - title: "GitHub Docs: Creating a permanent link to a code snippet"
    url: "https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-a-permanent-link-to-a-code-snippet"
    type: official-docs
    relevance: "Line and range anchors can point to code or plain Markdown at a specific commit."
  - title: "GitLab Docs: File management permalinks"
    url: "https://docs.gitlab.com/user/project/repository/files/"
    type: official-docs
    relevance: "Permalinks cover files, directories, line selections, and Markdown anchors."
  - title: "GitLab Docs: Documentation style guide"
    url: "https://docs.gitlab.com/development/documentation/styleguide/"
    type: official-docs
    relevance: "Advises linking to commits for specific code lines and refreshing stale line links."
  - title: "MkDocs Configuration: validation"
    url: "https://www.mkdocs.org/user-guide/configuration/#validation"
    type: official-docs
    relevance: "Markdown file, nav, anchor, and absolute-link validation can fail strict builds."
  - title: "Docusaurus Configuration: broken links"
    url: "https://www.docusaurus.io/docs/api/docusaurus-config#onbrokenlinks"
    type: official-docs
    relevance: "Production builds can throw, warn, log, or ignore broken links and anchors."
  - title: "Sphinx linkcode extension"
    url: "https://www.sphinx-doc.org/en/master/usage/extensions/linkcode.html"
    type: official-docs
    relevance: "Adds source-code links to documented objects through project-defined URL resolution."
  - title: "Sphinx intersphinx extension"
    url: "https://www.sphinx-doc.org/en/master/usage/extensions/intersphinx.html"
    type: official-docs
    relevance: "Uses generated object inventories to resolve cross-project documentation links."
  - title: "Sphinx linkcheck configuration"
    url: "https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-the-linkcheck-builder"
    type: official-docs
    relevance: "External link checks include anchor validation, ignores, auth, redirects, and legacy exclusions."
  - title: "Sphinx-Needs documentation"
    url: "https://sphinx-needs.readthedocs.io/en/stable/"
    type: official-docs
    relevance: "Defines, links, and analyzes requirements-like objects in docs-as-code projects."
  - title: "Doorstop documentation"
    url: "https://doorstop.readthedocs.io/en/latest/"
    type: official-docs
    relevance: "Stores linkable requirements and related items as YAML files in version control."
  - title: "OpenFastTrace user guide"
    url: "https://github.com/itsallcode/openfasttrace/blob/main/doc/user_guide.md"
    type: project-docs
    relevance: "Uses stable requirement IDs and source-code comment tags to produce trace reports."
  - title: "JabRef requirements documentation"
    url: "https://devdocs.jabref.org/requirements/"
    type: project-docs
    relevance: "Real project example of OpenFastTrace over Markdown requirements and source tags."
  - title: "StrictDoc traceability documentation"
    url: "https://strictdoc.readthedocs.io/en/stable/stable/docs/strictdoc_01_user_guide-TRACE.html"
    type: official-docs
    relevance: "Supports requirement-to-source links via source markers or requirement-side file relations."
  - title: "StrictDoc traceability matrix"
    url: "https://strictdoc.readthedocs.io/en/stable/traceability_matrix.html"
    type: official-docs
    relevance: "Shows generated requirement, source file, and source range traceability output."
  - title: "lychee"
    url: "https://github.com/lycheeverse/lychee"
    type: project-docs
    relevance: "Fast link checker for Markdown, HTML, reStructuredText, websites, URLs, and mail addresses."
  - title: "lychee-action"
    url: "https://github.com/lycheeverse/lychee-action"
    type: project-docs
    relevance: "GitHub Action examples for scheduled link checking, issue creation, cache, ignores, and JSON output."
  - title: "Detecting outdated code element references in software repository documentation"
    url: "https://link.springer.com/article/10.1007/s10664-023-10397-6"
    type: research-paper
    relevance: "Empirical work on detecting stale documentation references to code elements."
repo_findings:
  - "AGENT-DOCS already treats Markdown files as source-of-truth durable docs and generated docs-meta views as dashboards."
  - "The repo already has stable document IDs in filenames and YAML frontmatter, which fit traceability graph node IDs."
  - "A docs-to-code graph can start as generated metadata over existing Markdown, then add code symbol extraction later."
agent_notes:
  - "This survey favors practices that work with plain Markdown and Git before heavier requirements-management tooling."
  - "Commit permalinks are reliable historical evidence, but stable doc IDs and generated indexes are better long-term graph keys."
related_ideas: []
related_evaluations: []
related_adrs: []
related_specs: []
related_plans: []
related_sessions: []
linked_paths:
  - "scripts/docs-meta"
  - "skills/structured-docs-workflow/SKILL.md"
repo_state:
  based_on_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
  last_reviewed_commit: 8a05bdd2ea2b2793145d4552bfbfaf551a616c3d
---

# RSCH-0001 - Docs Code Traceability Tools

## Question

What existing tools and practices should inform AGENT-DOCS links from Markdown source-of-truth docs to code locations, traceability matrices, permalinks, and stale-link handling?

## Context

AGENT-DOCS is optimized for durable Markdown docs with stable IDs, YAML frontmatter, source-owned TODOs, and `docs-meta` generated views. The useful question is not whether to replace that with a full ALM or documentation platform. The useful question is which conventions and checks can make doc-to-code links trustworthy while preserving plain files and agent-friendly handoffs.

This pass focuses on:

- links from docs to exact code files, lines, ranges, or symbols
- traceability matrices over docs, code, tests, and decisions
- stale-link detection for internal Markdown links and external URLs
- design implications for a future generated docs-to-code graph

## External Sources

- [GitHub permanent file links](https://docs.github.com/en/repositories/working-with-files/using-files/getting-permanent-links-to-files): branch URLs drift as commits land; pressing `y` or using a commit SHA gives a stable file URL for the exact version under review.
- [GitHub code snippet permalinks](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-a-permanent-link-to-a-code-snippet): single-line and line-range anchors can point to code, and plain Markdown files can be addressed with `?plain=1#L...`.
- [GitLab file permalinks](https://docs.gitlab.com/user/project/repository/files/): GitLab positions permalinks as stable references for files, directories, code sections, and Markdown anchors.
- [GitLab documentation style guide](https://docs.gitlab.com/development/documentation/styleguide/): for specific code lines, GitLab recommends commit links instead of branch links and tells maintainers to refresh links when line numbers move.
- [MkDocs validation settings](https://www.mkdocs.org/user-guide/configuration/#validation): MkDocs can warn on missing nav targets, missing Markdown targets, broken anchors, absolute links, and unrecognized links; `mkdocs build --strict` can turn warnings into CI failures.
- [Docusaurus broken-link settings](https://www.docusaurus.io/docs/api/docusaurus-config#onbrokenlinks): production builds can fail on broken links and warn or throw on broken anchors and Markdown links.
- [Sphinx `linkcode`](https://www.sphinx-doc.org/en/master/usage/extensions/linkcode.html): Sphinx can add source-code links to documented objects when the project provides URL-resolution logic.
- [Sphinx `intersphinx`](https://www.sphinx-doc.org/en/master/usage/extensions/intersphinx.html): object inventories (`objects.inv`) let projects resolve cross-project object links without hardcoding final URLs.
- [Sphinx linkcheck configuration](https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-the-linkcheck-builder): linkcheck supports anchor validation, ignored URLs, ignored documents, redirects, auth, and rate-limit behavior, which are all needed for non-flaky link checks.
- [Sphinx-Needs](https://sphinx-needs.readthedocs.io/en/stable/): requirements-like objects can be defined in docs, linked to one another, filtered, tabulated, and visualized.
- [Doorstop](https://doorstop.readthedocs.io/en/latest/): requirements and related linkable items live as YAML files beside source code; Doorstop validates traceability and publishes multiple output formats.
- [OpenFastTrace user guide](https://github.com/itsallcode/openfasttrace/blob/main/doc/user_guide.md): Markdown requirements and source comment tags can generate coverage and trace reports.
- [JabRef requirements docs](https://devdocs.jabref.org/requirements/): a real Markdown project uses OpenFastTrace IDs such as `req~...~1` and source tags such as `[impl->req~...~1]` to check forward and backward tracing.
- [StrictDoc traceability guide](https://strictdoc.readthedocs.io/en/stable/stable/docs/strictdoc_01_user_guide-TRACE.html): StrictDoc supports both source-code-side relation markers and requirement-side links to source files, including language-aware parsing for some languages.
- [StrictDoc traceability matrix](https://strictdoc.readthedocs.io/en/stable/traceability_matrix.html): generated matrices can include requirement nodes, source files, ranges, implementation files, and tests.
- [lychee](https://github.com/lycheeverse/lychee) and [lychee-action](https://github.com/lycheeverse/lychee-action): Markdown and HTML link checking can run locally or in CI, with scheduled workflows, caches, ignore files, JSON/Markdown output, and issue creation.
- [Detecting outdated code element references in software repository documentation](https://link.springer.com/article/10.1007/s10664-023-10397-6): empirical research supports treating stale code-element mentions in docs as a detectable maintenance problem, not just a manual review concern.

## Repo / Internal Findings

- AGENT-DOCS already has the most important traceability primitive: stable doc IDs such as `RSCH-0001`, frontmatter metadata, and typed file names.
- `docs-meta` generated views should remain dashboards. If a traceability matrix is added, it should be generated from source docs and code metadata, not hand-maintained.
- Markdown portability matters. Relative links are still the right default for doc-to-doc references inside the repo; commit permalinks are better for exact historical evidence and review references.
- The current research-doc shape can support early graph fields without a platform migration: `external_sources`, `linked_paths`, `related_*`, `repo_state`, and future `code_refs` or `trace_refs` fields.
- A future graph should distinguish "current intended code surface" from "historical evidence at commit SHA." These are different link semantics.

## Agent Notes

- Primary-source practices converge on the same rule: line links are fragile unless pinned to a commit; even pinned line links can become stale as explanatory context changes.
- Existing requirements tools prove that IDs and generated matrices work, but their markup can be heavy for a lightweight agent workflow.
- The lowest-risk AGENT-DOCS path is to add traceability metadata and checks to `docs-meta`, then evaluate richer symbol extraction separately.

## Options Compared

| Option | Strengths | Limits | Fit for AGENT-DOCS |
| --- | --- | --- | --- |
| Commit permalink to file or line range | Exact historical evidence; supported by GitHub and GitLab | Line numbers do not express semantic ownership; links can point to old code forever | Good for citations, reviews, and session logs |
| Branch-relative path plus optional line | Easy to read locally; works in editors; current by default | Drifts silently as code moves | Good for current "owned surface" hints, not audit evidence |
| Stable doc IDs plus generated matrix | Queryable, durable, agent-friendly | Needs schema and generator discipline | Best foundation |
| Source comment markers | Bidirectional and easy for code search; proven by OpenFastTrace and StrictDoc | Adds process weight to code files; duplicate or stale markers need validation | Useful opt-in for high-value specs or safety-like domains |
| Requirement-side file relations | Does not require code edits; good for third-party or generated code | Coarser unless paired with symbol/range extraction | Good first graph edge type |
| Sphinx-style inventories and `linkcode` | Symbol-level links and generated object inventories | Sphinx/reStructuredText assumptions do not map directly to AGENT-DOCS Markdown | Useful design pattern, not a direct dependency |
| Dedicated requirements tool | Mature trace matrices, validation, exports | May overtake AGENT-DOCS conventions and add adoption cost | Evaluate only if requirements rigor becomes central |
| Link checkers in CI | Catches broken doc and external links | External checks can be flaky due rate limits, auth, redirects, or remote outages | Use strict local checks and scheduled softer external checks |

## Findings

- Treat stable IDs as graph keys. Code locations move; IDs such as `SPEC-*`, `PLAN-*`, `ADR-*`, `TODO-*`, and future `CODE-*` handles are better long-term graph nodes than raw line numbers.
- Use two link classes. "Current location" links can be repo-relative paths for humans and editors. "Evidence" links should be commit-pinned permalinks.
- Generate traceability views. A matrix should come from source docs, code markers, frontmatter, and parser output. Hand-written matrices will drift.
- Keep generated views separate from source docs. This matches the existing `docs-meta` principle that dashboards are derived from authoritative files.
- Start with file-level and range-level edges before symbol-level edges. File and range links can be validated with normal filesystem checks; symbol links require AST, LSP, or language-specific parsers.
- Link checking should be tiered. Internal Markdown links and anchors should be blocking in CI. External URL checks should be scheduled or cached, with explicit ignores and ownership for failures.
- Source markers are valuable but should be opt-in. They are strongest for requirements, tests, and implementation claims where bidirectional tracing matters enough to justify touching code.
- Existing docs-as-code traceability tools separate identity from presentation. AGENT-DOCS should follow that pattern by storing durable IDs in Markdown/frontmatter and letting generated outputs choose tables, reports, or graph views.

## Risks / Unknowns

- Commit permalinks can become misleading if readers interpret old code as current behavior.
- Branch links and line anchors can silently drift, especially across formatting changes.
- External link checks can fail for reasons unrelated to documentation quality, including rate limiting, auth, redirects, TLS, and temporary outages.
- Source markers create maintenance work and possible merge conflicts if required everywhere.
- Symbol-level doc links need language-aware indexing; this should be coordinated with the sibling AST, LSP, and code knowledge graph research.
- A traceability graph can become noisy unless edge types are explicit: "mentions", "implements", "tests", "decides", "supersedes", "evidence", and "current_surface" should not be collapsed into one generic link.

## Recommendation

For AGENT-DOCS, adopt a staged approach:

1. Keep Markdown docs and stable doc IDs as the source of truth.
2. Add a small, explicit convention for doc-to-code references. Start with repo-relative paths for current surfaces and commit-pinned permalinks for evidence.
3. Extend `docs-meta` to validate internal Markdown links, anchors, frontmatter `linked_paths`, and any future `code_refs`.
4. Generate a traceability view from source metadata rather than asking authors to maintain a matrix by hand.
5. Add external URL checking as a scheduled or manually triggered check with cache and ignore support, not as an always-blocking edit-time gate.
6. Prototype richer docs-to-code graph edges only after the file/range convention is stable.

The core design rule: author stable intent in Markdown, generate navigation and matrices from metadata, and use commit permalinks only when the reader must see the exact historical code snapshot.

## Follow-Ups

- Define a minimal `code_refs` or `trace_refs` frontmatter schema, including edge type, path, optional line/range, optional symbol, optional commit, and rationale.
- Decide whether source-code markers are allowed in target repos, and if so which doc types may require them.
- Add or prototype `scripts/docs-meta check-links` behavior for local Markdown files, headings, generated view exclusions, and `linked_paths`.
- Evaluate `lychee` for external URL checks and decide whether output should create a session log, issue, or generated report.
- Coordinate with sibling research on tree-sitter, LSP, static analysis, and code knowledge graphs before designing symbol-level edges.
