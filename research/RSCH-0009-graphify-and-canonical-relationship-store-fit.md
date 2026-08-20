---
type: research-survey
document_format_version: 2
id: 01a02039-7a68-7236-a04a-c2e12da6abb5
aliases:
  - "RSCH-0009"
title: Graphify And Canonical Relationship Store Fit
domain: architecture
status: completed
created_at: "2026-08-08 18:34:41 JST +0900"
updated_at: "2026-08-20 23:45:02 JST +0900"
owner: "Codex main agent"
question: "Should Agent Continuity extract typed relationships from document frontmatter into a canonical graph, what role should Graphify play, and what is the smallest personal-first storage architecture?"
source:
  type: conversation
  link: "codex://thread/019fdae4-b3ef-7191-8173-ecfca7d9e4a0"
  notes: "Requested as an extra-high architecture pass after the user questioned duplicated reciprocal frontmatter and proposed externalizing relationships like Graphify."
external_sources:
  - title: "Graphify repository"
    url: "https://github.com/Graphify-Labs/graphify"
  - title: "Graphify concepts"
    url: "https://graphify.com/concepts"
  - title: "Graphify documentation"
    url: "https://graphify.com/docs"
  - title: "Graphify Markdown extractor at inspected commit"
    url: "https://github.com/Graphify-Labs/graphify/blob/3d19463484ebcf773b399ddad9fd3363b2ab3bff/graphify/extractors/markdown.py#L53-L70"
  - title: "Graphify graph build behavior at inspected commit"
    url: "https://github.com/Graphify-Labs/graphify/blob/3d19463484ebcf773b399ddad9fd3363b2ab3bff/graphify/build.py#L741-L750"
  - title: "Graphify edge deduplication at inspected commit"
    url: "https://github.com/Graphify-Labs/graphify/blob/3d19463484ebcf773b399ddad9fd3363b2ab3bff/graphify/build.py#L549-L559"
  - title: "UUID version 7 in RFC 9562"
    url: "https://www.rfc-editor.org/rfc/rfc9562.html#name-uuid-version-7"
  - title: "Neo4j graph database concepts"
    url: "https://neo4j.com/docs/getting-started/appendix/graphdb-concepts/"
  - title: "RDF 1.1 Concepts and Abstract Syntax"
    url: "https://www.w3.org/TR/rdf11-concepts/"
  - title: "RDF 1.1 N-Quads"
    url: "https://www.w3.org/TR/n-quads/"
  - title: "SQLite recursive common table expressions"
    url: "https://www.sqlite.org/lang_with.html"
repo_findings:
  - "IDEA-0003 already proposed one canonical owner per fact, source-sharded explicit relation files, generated inverses, and a disposable SQLite index; it never proposed one file per edge."
  - "CONC-0001 already recommends Markdown as canonical and SQLite as a rebuildable read model."
  - "scripts/agent-continuity-docs currently treats physical Markdown links and frontmatter relation fields as two different mechanisms."
  - "The current relation summary scans parent_plan, related_* fields, supersession, promotion, and resolution fields but does not normalize them into a canonical typed edge store."
  - "A rough corpus scan found about 200 relationship values across about 60 source documents; one-file-per-edge would therefore create hundreds of files immediately."
agent_notes:
  - "An extra-high independent agent inspected current Graphify v0.9.36 at commit 3d19463484ebcf773b399ddad9fd3363b2ab3bff and the local Agent Continuity schema and scripts."
  - "The external version observation is current to this survey date and should be refreshed before implementation."
related_ideas:
  - ../agent-continuity/ideas/IDEA-0003-federated-document-library-and-relationship-graph.md
  - ../agent-continuity/ideas/IDEA-0004-semantic-history-and-work-projections.md
  - ../agent-continuity/ideas/IDEA-0006-adaptive-goal-to-outcome-quest-planning.md
related_evaluations: []
related_adrs: []
related_specs: []
related_plans: []
related_sessions:
  - ../session-logs/2026-08-08-personal-first-research-and-relationship-store.md
  - ../session-logs/2026-08-08-repository-boundary-and-graph-authority-clarification.md
linked_paths:
  - scripts/agent-continuity-docs
  - concepts/CONC-0001-read-only-sqlite-docs-index.md
  - agent-continuity/ideas/IDEA-0003-federated-document-library-and-relationship-graph.md
  - agent-continuity/ideas/IDEA-0004-semantic-history-and-work-projections.md
repo_state:
  based_on_commit: 9750871c50443d669e20be01e684fa8c1ce8b37b
  last_reviewed_commit: 41f4df26c82a555e127372c3ac5576614051cbea
---

# RSCH-0009 - Graphify And Canonical Relationship Store Fit

## Question

Should Agent Continuity extract typed relationships from document frontmatter into a canonical graph, what role should Graphify play, and what is the smallest personal-first storage architecture?

## Short Answer

The user's normalization instinct is correct, with one Graphify correction:

> Graphify externalizes relationships into a generated queryable graph, but it does not make that graph the canonical authored source of truth.

Agent Continuity should store each explicit typed relationship once on its directed source, then generate children, parents, inverse labels, backlinks, graph views, and health checks. This removes duplicated reciprocal assertions without requiring a separate file for every relationship.

The corrected personal-first architecture is:

1. The Markdown record is the graph node and owns its UUIDv7, intrinsic metadata, content, and ordinary outgoing typed relationships.
2. An optional source-sharded YAML overlay owns relationships that cannot safely or naturally live with that Markdown source.
3. SQLite is a disposable local index over documents, explicit relationships, textual references, provider observations, and inferred candidates.
4. Graphify is an optional analysis, visualization, and candidate-edge adapter.
5. No graph database is needed initially.

The storage mechanics are straightforward. The medium-difficulty work is defining predicates, authority, migration, privacy, validation, and one editable owner per fact.

## 2026-08-20 Native-Design Correction

The earlier refinement accidentally made one logical document look like two canonical authored objects: a Markdown record plus a document-node YAML record with a duplicated identity binding and a separately maintained locator. That creates the same kind of one-to-one synchronization burden the graph was meant to remove. Source: agent modeling assumption and presentation ambiguity, not a requirement of graph normalization.

The corrected ownership split is:

1. The Markdown record is the document node. It owns its immutable UUIDv7, kind, lifecycle status, legacy aliases, H1 title, body, inline links, citations, and ordinary outgoing typed relationships.
2. The filesystem scan observes the current locator. No second authored locator field is required.
3. A typed relationship is stored once as `(subject UUID, predicate, object UUID)`. The tuple is its identity until the relationship itself needs independent lifecycle, provenance, annotation, or references.
4. SQLite and user interfaces remain rebuildable projections.
5. Graphify remains optional analysis and candidate-edge generation.

Owen selected UUIDv7 as the identity format. Its timestamp-first layout is branch-safe and approximately creation-sortable, but it does not encode workflow or dependency order. Human filenames use a type prefix plus freely editable descriptive slug; legacy numeric IDs remain aliases or retirement tombstones during migration.

This correction does not weaken the logical graph. The Markdown record materializes as a node in the generated index, and each stored outgoing tuple materializes as a directed typed edge. Logical graph records and operating-system files are different layers.

The current durable proposal had already said **one relation file per subject**, not one file per relationship. The one-file-per-edge interpretation was a later explanatory regression. Even the subject sidecar is now optional in v1: externalization must earn its ceremony through a real privacy, provenance, authorization, non-document-entity, or independent-lifecycle need.

## Three Meanings Of “The Graph Is The Source Of Truth”

The earlier wording can be misread because it uses “graph” for three different layers:

| Layer | Meaning | Canonical? |
|---|---|---|
| Logical relationship graph | Identified entities plus explicit typed assertions such as `PLAN-0012 depends_on SPEC-0012` | Yes, this is the intended authority for relationships |
| Durable graph representation | The files or database records that persist those assertions | Initially outgoing typed fields in Markdown, plus optional source-sharded relation overlays; a later application-owned database may take over through an explicit migration |
| Generated graph projection | SQLite indexes, backlinks, Graphify output, visual layouts, inferred communities, and caches | No; rebuildable or reviewable unless authority is deliberately transferred |

Therefore the end goal may absolutely be described as **graph-native**: relationships, dependencies, refinements, evidence links, and authority are first-class canonical assertions rather than duplicated frontmatter hints. That conclusion does not require choosing a graph database now. YAML edge files, relational tables, Resource Description Framework triples, and a property-graph database can all represent a graph.

The pilot recommendation is not “avoid making the graph canonical.” It is:

> Make the logical relationship graph canonical immediately, while keeping its first durable representation embedded, versioned, inspectable, and replaceable until the vocabulary and write workflows have survived real use.

If the personal application later becomes the primary authoring surface, its transactional database may become canonical for graph entities and assertions. That would be a deliberate authority migration with export, backup, provenance, and compatibility rules—not an accidental promotion of a generated SQLite cache or Graphify output.

## Correcting The Mental Model

| Claim | Verdict | Explanation |
|---|---|---|
| Graphify makes relationships first-class graph edges outside documents | Correct for its generated read model | Its graph can be queried in either direction and combines extracted and inferred relationships |
| Graphify removes relationship truth from source documents | Incorrect | `graph.json` is generated from sources; the original files remain authoritative |
| An external relationship store can remove reciprocal frontmatter duplication | Correct if explicitly made canonical | Store one directional relationship assertion, then derive inverse and backlink views |
| SQLite must be the canonical relationship store | No | Git-reviewable Markdown and optional relation overlays better match current Agent Continuity portability and review; SQLite is a strong index |
| A graph database is required | No | Personal-scale traversals fit SQLite recursive queries and in-memory graph algorithms |

This distinction separates **authority** from **confidence**. Graphify's `EXTRACTED`, `INFERRED`, and `AMBIGUOUS` labels describe how an edge was obtained. They do not say who is allowed to make it control scheduling, blocking, completion, or privacy.

## Current Agent Continuity State

Agent Continuity currently has two graph-like mechanisms:

1. Markdown links, images, wikilinks, and autolinks are parsed into physical references. The tool derives backlinks, broken links, and orphans. See [`link_graph`](../scripts/agent-continuity-docs) in the current script.
2. Frontmatter relationships are summarized separately by scanning `parent_plan`, `related_*`, `supersedes`, `superseded_by`, `promoted_to`, and `resolved_by`.

These are not equivalent:

- An inline Markdown link is an authored reference occurrence with prose and location.
- `IMPL-0012-01 part_of PLAN-0012` is a domain assertion.
- “PLAN-0012 has child IMPL-0012-01” is a generated inverse view.

The current checker mostly protects physical links, schemas, statuses, IDs, and generated views. It does not yet normalize every reciprocal semantic field into one assertion. The relationship-store proposal replaces reciprocal maintenance; it does not eliminate validation.

There is also a current representation mismatch: some `related_*` frontmatter values are stable IDs while others are relative paths. A normalized relation contract should use stable project and entity identities and let the index resolve paths.

## Ownership Model

| Fact kind | Canonical owner | Example |
|---|---|---|
| Document node and intrinsic metadata | Markdown record | UUIDv7, kind, lifecycle status, legacy aliases, H1 title, body |
| Current locator | Filesystem scan | The path at which the UUID-bearing Markdown record was found |
| Ordinary outgoing relationship | Source Markdown frontmatter | `brief-uuid part_of plan-uuid`, stored once on the brief |
| Visibility-separated relationship | Optional source-sharded overlay | A private plan relates to a public specification without modifying the public repository |
| Textual reference occurrence | Markdown body | A sentence links to an ADR |
| Inverse or backlink | Generated index/view | A plan view shows its child brief |
| Extracted relationship | Generated index | Markdown file links to another file |
| Inferred relationship | Candidate queue | Two concepts may describe the same subsystem |
| Provider-native relationship | External provider | GitHub issue 12 is blocked by issue 9 |
| Cross-provider semantic relationship | Agent Continuity relation source | Plan delivered by GitHub pull request 88 |

Do not move every current field at once:

- Add the UUID anchor first and retain current frontmatter during compatibility migration.
- Keep kind, lifecycle state, aliases, the human title, and authored body in Markdown; derive the current locator from the scan.
- Normalize well-defined semantic edges such as `parent_plan`, `depends_on`, `promoted_to`, `supersedes`, `resolved_by`, `evidenced_by`, and delivery links into canonical outgoing predicates.
- Generate `superseded_by`, child lists, and backlinks.
- Audit generic `related_*` fields because many are navigation hints without a precise predicate.
- Keep inline Markdown links; their textual location is useful.
- Keep `areas` as classification until areas become first-class entities.
- Leave `linked_paths` in place during the pilot unless stable code-reference work is included.

## Recommended Architecture

```mermaid
flowchart TD
    subgraph SOURCES["Git-reviewable canonical sources"]
        direction TB
        DOCS["Markdown document nodes<br/>UUIDv7 + properties + content<br/>+ ordinary outgoing edges"]
        RELS["Optional relation overlay<br/>visibility-separated or<br/>independently owned edges"]
    end

    PROVIDERS["External providers<br/>GitHub, agents, and services"]
    INDEX["Generated SQLite index<br/>entities, assertions, events,<br/>search, and inverse views"]
    APP["Personal Continuity cockpit<br/>context, neighborhood,<br/>frontier, and history"]
    GRAPHIFY["Graphify adapter<br/>analysis, communities,<br/>and candidate edges"]
    REVIEW["Candidate review<br/>accept or reject"]

    DOCS --> INDEX
    RELS --> INDEX
    PROVIDERS --> INDEX
    INDEX -->|"Serves projections"| APP
    INDEX -->|"Sanitized export"| GRAPHIFY
    GRAPHIFY -->|"Suggestions"| REVIEW
    REVIEW -->|"Accepted local edge"| DOCS
```

Every incoming arrow means that the disposable index reads or observes the named source. The diagram shows data lineage, not a chosen live synchronization mechanism. File watching, refresh, provider polling, and webhooks remain implementation decisions.

## Canonical Graph Serialization

The default v1 stores each ordinary outgoing edge once in its source Markdown. This adds no files. The flat fields below are syntactically parseable by the current frontmatter reader, but UUIDv7 recognition, aliases, predicate schemas, validation, inverse generation, and projection support remain unimplemented; the abbreviated example would not pass today's document checks:

```yaml
---
id: 019d2f62-a44e-75cb-98c9-38e95b8980d3
type: implementation-brief
status: ready
aliases:
  - IMPL-0012-01

part_of:
  - 019d2f60-7d3a-7bb0-bf46-ae03ee6b6472
depends_on:
  - 019d2f5b-92e0-7444-9a3a-313bd0069f24
---
```

The plan does not also store `contains`, and the dependency target does not also store `blocks`. Those are generated inverse views.

If a relation needs a separate repository or file-ownership boundary, use at most one optional sidecar per subject document—not one file per relationship:

```text
.agent-continuity/
  relations/
    019d2f62-a44e-75cb-98c9-38e95b8980d3.yaml
```

```yaml
schema_version: 1
subject: 019d2f62-a44e-75cb-98c9-38e95b8980d3
implements:
  - 019d2f60-7d3a-7bb0-bf46-ae03ee6b6472
```

This flat sidecar gets separation from repository or file ownership and provenance from Git history. It cannot express edge-specific lifecycle, annotations, authorization, or independently addressable provenance. Those needs require a later structured assertion schema and a real YAML parser.

Use stable project IDs plus entity UUIDs for cross-repository references. Serialize and project every edge at the most restrictive visibility boundary of its endpoints and the relationship fact itself. An edge that reveals a private endpoint or a private relationship between public nodes must never live in a public source. Filter unauthorized edges before generating backlinks, counts, inferred neighborhoods, or exports. A genuinely symmetric relation should be stored once using canonical endpoint ordering or a workspace-owned assertion.

Keep two identity layers distinct:

- The **semantic edge** is the resolved tuple `(subject UUID, predicate, object UUID)`.
- An **assertion occurrence** records that a particular source or authority asserted that tuple. It may receive a generated index-local ID so evidence can reference it. That generated key is not an authored edge UUID.

One explicit local edge normally has one assertion occurrence. Multiple sources may support the same semantic edge without turning them into parallel workflow dependencies. Promote an assertion occurrence to an authored UUID only when it needs an independent lifecycle, annotations, or references outside the projection.

## Generated SQLite Index

SQLite can normalize every source into queryable assertions without becoming canonical:

```sql
PRAGMA foreign_keys = ON;

CREATE TABLE entity (
  entity_key       TEXT PRIMARY KEY,
  project_id       TEXT NOT NULL,
  local_id         TEXT NOT NULL,
  entity_type      TEXT,
  source_uri       TEXT NOT NULL,
  source_revision  TEXT,
  visibility_scope TEXT NOT NULL
);

CREATE TABLE edge_assertion (
  assertion_id     TEXT PRIMARY KEY,
  subject_key      TEXT NOT NULL REFERENCES entity(entity_key),
  predicate        TEXT NOT NULL,
  object_key       TEXT NOT NULL REFERENCES entity(entity_key),
  assertion_kind   TEXT NOT NULL,
  authority_uri    TEXT,
  provenance_uri   TEXT NOT NULL,
  source_revision  TEXT,
  source_repository TEXT NOT NULL,
  visibility_scope TEXT NOT NULL,
  confidence       REAL,
  disposition      TEXT NOT NULL,
  observed_at      TEXT,
  valid_from       TEXT,
  valid_to         TEXT,
  UNIQUE (subject_key, predicate, object_key, assertion_kind, provenance_uri)
);

CREATE TABLE edge_evidence (
  assertion_id TEXT NOT NULL REFERENCES edge_assertion(assertion_id),
  evidence_uri TEXT NOT NULL,
  role         TEXT NOT NULL,
  PRIMARY KEY (assertion_id, evidence_uri, role)
);

CREATE INDEX edge_assertion_outgoing
  ON edge_assertion(subject_key, predicate, object_key);

CREATE INDEX edge_assertion_incoming
  ON edge_assertion(object_key, predicate, subject_key);
```

Recommended meanings:

- `authority_uri`: who owns the fact
- `provenance_uri`: where this assertion or observation came from
- `assertion_id`: a generated projection key for one assertion occurrence, not automatically an authored edge UUID
- `assertion_kind`: `explicit`, `extracted`, `inferred`, or `provider`
- `visibility_scope`: the most restrictive visibility of both endpoints and the edge fact itself
- `disposition`: `accepted`, `candidate`, `rejected`, or `retracted`
- `confidence`: primarily for inferred relationships, not a substitute for authority
- `observed_at`: provider snapshot time
- `valid_from` and `valid_to`: optional until a real time-bounded relationship requires them

External or temporarily unresolved endpoints must be represented as explicit stub entities before an assertion is indexed; foreign-key checks must not be disabled to admit dangling edges. SQLite recursive Common Table Expressions are sufficient for personal-scale ancestry, dependency, frontier, and unlock queries. Full-text search can use SQLite FTS. Deleting the index must leave all authored documents and explicit edges intact.

The real-world action workspace may legitimately use writable SQLite or SwiftData as canonical for its live operational actions. That is a different bounded product with different diff and merge needs:

- Agent Continuity knowledge edges: Git-reviewable Markdown plus optional relation overlays
- action-workspace tasks, dependencies, schedule, and status: app-native writable database
- shared vocabulary and index: normalized entity, assertion, provider, evidence, and event contracts

## What Graphify Actually Contributes

The current inspected Graphify version builds generated graph data, reports, interactive views, incremental/global graphs, and query or analysis interfaces. Markdown links become generic `references` relationships, while model-backed processing may infer semantic relationships.

Graphify is useful for:

- source and document extraction
- incremental content-hash caching
- source-located extracted edges
- `EXTRACTED`, `INFERRED`, and `AMBIGUOUS` epistemic labels
- path, neighborhood, query, and explain interfaces
- community and relationship suggestions
- source-code and pull-request impact overlays
- optional exports to other graph tools

Do not adopt:

- `graph.json` as canonical Agent Continuity data
- generic `references` as the domain vocabulary
- path-derived document identity
- undirected or simple-graph behavior as workflow truth
- inferred edges in scheduling, blocking, authorization, or completion logic
- confidence as a replacement for authority
- union-merging generated output as the authored conflict model
- a graph database merely because Graphify can export to one

The integration contract should be:

```text
canonical docs + optional relation overlays
  -> generated SQLite/application projection
  -> sanitized Graphify export

Graphify suggestions
  -> candidate review queue
  -> accepted suggestion writes to its canonical source
```

Acceptance must never mean editing generated Graphify JSON.

## Storage Options Compared

| Option | Strength | Main cost | Recommendation |
|---|---|---|---|
| Reciprocal frontmatter | Portable and visible with each doc | Duplicate truth and awkward inverse maintenance | Keep only for compatibility during migration |
| One-sided typed frontmatter | No additional files; relationship sits with its source | Same-document content and relationship edits can overlap | **Default v1** |
| One global YAML relationship file | Git-reviewable | Merge-conflict hotspot and poor privacy partitioning | Avoid |
| Source-sharded relation YAML | Reviewable, portable, one assertion owner | Adds one sidecar per connected source and requires predicate tooling | Optional overlay when separation earns its keep |
| One YAML file per relationship | Maximum edit isolation | Hundreds of tiny files, noisy review, and unnecessary edge identity | Reject as the default |
| Generated SQLite | Fast joins, recursion, search, timelines | Schema/cache maintenance and authority confusion risk | Recommended disposable index |
| Canonical SQLite for documents | Easy transactional app writes | Poor Git diffs, merging, review, and agent editing | Defer or reject for repo-owned knowledge |
| Canonical SQLite for action workspace | Good native operational state | Needs backup/export and app lifecycle | Appropriate for that bounded product |
| Graph database | Powerful graph query ecosystem | Server, migrations, auth, backup, operational complexity | Premature |
| Graphify graph output | Immediate analysis and visualization | Derived, generic, inference-heavy, not workflow-authoritative | Optional adapter only |

## Migration And Validation Sequence

1. Freeze the current schema; do not bulk-migrate yet.
2. Define only five or six predicates from real personal use: likely `part_of`, `depends_on`, `implements`, `supersedes`, `evidenced_by`, and one provider projection relationship.
3. Build a read-only normalizer that reports frontmatter relations, Markdown occurrences, duplicate inverses, unresolved targets, and ambiguous `related_*` values.
4. Pilot one-sided typed frontmatter on 10–20 artifacts in one private personal project; add a source-sharded sidecar only for one relationship that genuinely needs separation.
5. Generate inverses and a disposable SQLite index.
6. Build one neighborhood view: parents, children, blockers, evidence, and textual backlinks.
7. Migrate one relation family at a time. Start with `supersedes`; generate `superseded_by`; compare the old and new projections; then remove the duplicate field.
8. Add validation for endpoint existence, allowed predicate/type combinations, cardinality, UUID and alias uniqueness, duplicate semantic edges and assertion occurrences, irreflexive and acyclic `depends_on`, `part_of`, and `supersedes` relations, provider reconciliation, and edge-level public/private leakage.
9. Export a sanitized pilot to Graphify and compare its analysis value. Import output only as candidates.
10. Connect the action workspace later through explicit authority rules.

Relationship normalization removes reciprocal-update logic. It does not remove validators; it gives them one unambiguous assertion source.

## Difficulty

| Work | Difficulty | Why |
|---|---|---|
| Store and query edges | Low | YAML parsing and SQLite rows are straightforward |
| Generate inverse views | Low | Deterministic predicate mappings and backlinks |
| Define precise predicates | Medium to high | Vague `related_*` fields hide several meanings |
| Migrate existing documents | Medium | Requires compatibility, comparison, and gradual removal |
| Cross-repository identity and privacy | Medium to high | Hidden nodes and private backlinks must not leak |
| External-provider reconciliation | High later | Each provider has different state, events, identities, and authority |
| Multi-user collaboration | High and deferred | Access control, conflicts, audit, retention, and tenancy |

## Personal First And Deferred B2B Concerns

Preserve stable identities, authority, provenance, visibility boundaries, schema-versioned export, and append-only events. Do not build organization/tenant accounts, role-based access control, approval policies, provider webhooks, legal retention, multi-user conflict handling, or service-level infrastructure for the first personal product.

Those are not reasons to distort the personal schema. A future company product can add policy and identity around the same assertions if the personal ontology proves useful.

## Risks And Unknowns

- The predicate vocabulary may become either vague or bureaucratically large.
- Embedded relation fields can make frontmatter busy if the vocabulary or edge count grows without discipline.
- A sidecar relation overlay can feel detached during ordinary Markdown editing without good tooling.
- Source-sharded files still conflict when several agents edit the same subject.
- Generated and canonical data may be confused in the UI.
- Model-inferred edges can look authoritative unless candidate status is unmistakable.
- Cross-repository private edges can reveal sensitive facts through backlinks or counts.
- Migrating every generic `related_*` field may destroy useful loose navigation.
- Current Graphify behavior and interfaces may change; pin and re-evaluate any adapter.

## Recommendation

Approve the architecture only as a pilot direction, not a bulk schema migration:

> Markdown records are the document nodes and own ordinary outgoing typed edges once. Optional source-sharded overlays own only relationships that need a separate visibility, provenance, authorization, or lifecycle boundary. SQLite owns no authored truth; it provides fast derived views. Graphify may analyze and suggest, but never authorize or silently mutate workflow relationships.

The first valuable implementation is not a graph database. It is a type-aware document neighborhood that proves one migrated relation family is easier to author, understand, validate, and navigate than reciprocal frontmatter.

## Follow-Ups

- Turn the five-predicate embedded-edge pilot and compatibility rules into a specification after the personal cockpit evaluation selects its first queries.
- Add an evaluation that compares legacy and normalized projections on 10–20 artifacts.
- Update CONC-0001 only after the index query set and canonical relationship-source contract are approved.
- Use a sanitized Graphify export to evaluate query and visualization value without sharing private continuity sources.

The strongest retrieval cue is: **store each outgoing relationship once, derive its inverse, externalize only when separation has a concrete job, and keep inference out of authority.**
