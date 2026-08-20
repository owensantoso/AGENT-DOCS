---
type: session-log
document_format_version: 2
id: 01a02039-7a6a-78da-9eb8-81a332e5b303
aliases: []
title: Spec Systems And Ceremony Evaluation
domain: agent-continuity
status: completed
created_at: "2026-08-20 17:13:32 JST +0900"
updated_at: "2026-08-21 02:41:52 JST +0900"
started_at: "2026-08-20 17:13:32 JST +0900"
ended_at: "2026-08-21 02:41:52 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex main agent
  - delegated landscape researcher
  - delegated topology reviewer
  - delegated architecture red-team reviewer
  - delegated relation-storage reviewer
  - delegated graph-database reviewer
  - delegated plan-and-brief reviewer
  - delegated UUID implementation reviewer
areas:
  - agent-continuity
  - spec-driven-development
  - project-memory
  - documentation-ceremony
  - repository-topology
  - identity-and-dependencies
related_plans:
  - ../agent-continuity/plans/PLAN-0012-versioned-uuid-document-identity/PLAN-0012-versioned-uuid-document-identity.md
related_briefs: []
related_specs: []
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits:
  - d87ea088b643fce77d23d559c57b81a94344dec0
  - 663934fe4f03b703db210fb6023b99cbe3619684
---

# 2026-08-20 - Spec Systems And Ceremony Evaluation

## Session Metadata

- Started: 2026-08-20 17:13:32 JST +0900
- Ended: 2026-08-20 17:29:44 JST +0900
- Timezone: JST +0900
- Participants: Owen, Codex main agent, and three bounded research/review agents
- Todo-backed work: none; this session records research and an evaluation protocol, not approved implementation

## Goal

Preserve the research and proposed decision path for whether Agent Continuity should adopt or adapt GitHub Spec Kit or OpenSpec, split code from private operational documentation, simplify its document taxonomy, and measure whether richer provenance earns its ceremony.

## Context Read

- `README.md`
- `AGENTS.md`
- `skills/structured-docs-workflow/SKILL.md`
- `guides/workflow-overview.md`
- `guides/doc-types-and-responsibilities.md`
- `scripts/README.md`
- `agent-continuity/ideas/IDEA-0003-federated-document-library-and-relationship-graph.md`
- `agent-continuity/ideas/IDEA-0004-semantic-history-and-work-projections.md`
- `research/RSCH-0009-graphify-and-canonical-relationship-store-fit.md`
- `repo-health/evaluations/EVAL-0001-docs-to-code-graph-agent-efficiency.md`
- prior project-memory decisions about project-local truth and global projections
- current official Spec Kit, OpenSpec, and Beads documentation linked from `RSCH-0010`

## Changes

- Added `research/RSCH-0010-spec-systems-and-agent-continuity-fit.md`:
  - compares Spec Kit, OpenSpec, and Agent Continuity by primary job rather than feature count
  - records the private project-operations satellite plus thin-hub topology
  - proposes a functional split into memory kernel, one delivery owner, triggered evidence extensions, typed relationships, derived control plane, and storage topology
  - records adaptive document-admission triggers and identity/dependency prior art
  - includes visual comparison and adaptive-ceremony diagrams
- Added `repo-health/evaluations/EVAL-0002-documentation-ceremony-and-recovery-value.md`:
  - defines staged artifact-set, surfacing, and live-tool comparisons
  - separates small, interrupted, and cross-boundary cohorts
  - measures accepted outcomes, recovery, evidence accuracy, human correction, document overhead, and per-document material use
  - pre-registers continuation and stop gates before results exist
- Updated `agent-continuity/ideas/IDEA-0003-federated-document-library-and-relationship-graph.md` with the current revamp hypothesis and links to the research and evaluation.

## Decisions

- Decision: preserve the current architecture as a hypothesis pending evaluation, not as an approved migration.
  - Why: Spec Kit, OpenSpec, and Agent Continuity overlap around specs, plans, and tasks, so installing layers before assigning one owner would create duplicate truth.
  - Source of truth: `RSCH-0010` and `EVAL-0002`.
- Decision: compare artifact shapes before live tools.
  - Why: this isolates the value of the information model from the quality of different command harnesses and prompts.
  - Source of truth: `EVAL-0002` Stage 1.
- Decision: test the control plane separately on the same corpus.
  - Why: better retrieval can make useful provenance cheaper, while a polished projection can also conceal stale or unnecessary artifacts.
  - Source of truth: `EVAL-0002` Stage 2.
- Decision: treat project size as a weak proxy and activate document types from uncertainty, longevity, concurrency, reversibility, privacy, and evidence risk.
  - Why: a small high-risk project can need more durable evidence than a large disposable prototype.
  - Source of truth: `RSCH-0010` adaptive-ceremony model.

These are research and protocol decisions. No durable product architecture decision has been promoted to an ADR.

## Verification

- Commands run:
  - repository status, branch, worktree, and current commit inspection
  - Agent Continuity ID and status inspection
  - official web-source review for Spec Kit, OpenSpec, and Beads
  - `scripts/release-check` - passed, including installer, init, doctor/upgrade, document-tooling, changelog, compile, plan metadata, repo-root link, and diff checks
  - custom new-document local-link, ID/filename, and Mermaid-source correspondence checks - passed
  - strict Mermaid layout lint for both diagrams - passed
  - SVG delivery lint at 700 CSS pixels - passed at estimated 24.22 pixels and 19.12 pixels minimum text size
- Manual checks:
  - inspected both neutral-theme PNG renders; composition, label ownership, endpoints, and reading order passed
- Verification caveat:
  - the default structured-doc command scopes its normal registry to `docs/`, while this repository retains legacy root-level research and evaluation collections; the new files were therefore also checked with repo-root and targeted custom validation
  - a strict whole-repo metadata check exposes pre-existing legacy `linked_paths` resolution debt and a scaffold placeholder error; the release baseline does not run that unsupported whole-root metadata mode
  - machine storage pressure was critical, so Mermaid was rendered from an already cached renderer and no package or browser download was attempted
- Not run:
  - no evaluation fixtures or candidate runs
  - no Spec Kit or OpenSpec installation
  - no repository migration
  - no ID-schema change
  - no public or remote write

## Follow-Ups

- Freeze the two calibration fixtures only if Owen wants to run the evaluation.
- Use calibration results to classify document types as core, trigger-only, merge candidates, or retire candidates.
- Pilot a live tool only if the artifact and surfacing comparisons identify a concrete gap.
- Handle branch-safe IDs, aliases, and typed relationships as a separate schema and migration decision.

## Follow-Up Correction - 2026-08-20 22:33 JST

The breadth of the comparison became cognitively expensive before it produced a necessary implementation decision. Source: orchestration and presentation scope, not a failure of the underlying research.

Owen selected the native Agent Continuity direction for continued design. `RSCH-0010` and `EVAL-0002` are now parked references with explicit reopen triggers rather than active gates. This checkpoint proposed separate document-node records; the later 23:31 correction supersedes that physical model while retaining UUID identity, mutable filename locators, typed relationships, and derived graph projections. No schema or corpus migration was implemented in this follow-up.

## Follow-Up Correction - 2026-08-20 23:31 JST

What happened: a later explanation changed the existing subject-sharded relationship proposal into one YAML file per relationship and drew the Markdown file plus a separate node YAML as two canonical objects. That would create hundreds of tiny files in the current corpus and introduce a new one-to-one identity and locator synchronization burden.

What led to it: logical graph records were conflated with their physical filesystem serialization. Source: agent modeling assumption and presentation ambiguity. The prior durable proposal itself already said one relation file per subject, not one file per edge.

What changed:

- Owen selected UUIDv7 for immutable document identity. UUIDv7 does not encode workflow order; explicit dependency relationships do.
- The Markdown record is now the proposed authored graph node. It owns UUIDv7, intrinsic metadata, content, and ordinary outgoing typed relationships.
- Reciprocal fields are not stored. Inverses such as `contains` and `blocks` are generated.
- A separate relation overlay is optional and source-sharded: at most one YAML file per subject when a relation needs independent visibility, provenance, authorization, lifecycle, or a non-document source. One-file-per-edge is rejected as the default.
- Ordinary edge identity is the tuple `(subject UUID, predicate, object UUID)`. An edge gains its own UUID only if it becomes independently addressable.
- SQLite remains a disposable projection. A canonical graph database is deferred until transactional concurrent writes, application-owned authoring, measured traversal limits, or database-level permissions make it necessary.
- PLAN and IMPL remain separate semantic types, but IMPL is optional. Zero briefs is valid for a directly executable plan; multiple briefs require independently ownable, dependency-addressable, verifiable, stable slices and a concrete coordination benefit.

Verification:

- Three independent reviews converged on the storage correction, graph-database deferral, and adaptive PLAN/IMPL distinction; a fourth diff review caught edge-identity, privacy, parser-compatibility, cycle, and legacy-numbering ambiguities before commit.
- `scripts/release-check` passed. A pre-existing ignored `scripts/__pycache__` directory was moved aside for the hygiene gate and restored immediately afterward.
- Strict static Mermaid layout lint passed for the three materially changed diagrams.
- Rendered composition and delivered readability were not run: `owen-storage-history pressure-status --quiet` returned critical-pressure exit `12`, and no already-installed Mermaid renderer was available. No package or browser download was attempted.
- The earlier session caveat about unsupported whole-repository metadata checks and legacy `linked_paths` debt still applies; the supported release suite is the verification authority used here.
- No schema, tooling, or corpus migration was implemented.

## Follow-Up Requirement - 2026-08-21 00:14 JST

Owen clarified why reciprocal relationship fields were originally attractive: entering through either endpoint should reveal the relationship neighborhood. In `A depends_on B`, a reader starting from B must be able to discover that A depends on it even when the edge is authored only on A.

The proposed response separates authorship from presentation. Store one canonical directed edge, then require the resolved node view used for execution to include outgoing and incoming edges. Predicate-specific inverse labels present the same assertion from either endpoint; `depends_on` becomes static `depended_on_by` from the target, while `blocks` is reserved for a status-dependent presentation. The resolver can scan Markdown on demand, so a generated SQLite index remains an optimization.

Raw single-file self-containment, single authorship, and the absence of any resolver or generated material cannot all hold simultaneously. The remaining open product decision is whether ordinary raw Markdown on a Git host must show incoming relationships. If so, use a mechanically refreshed, explicitly non-canonical generated block; otherwise the repository-scanning node view is the execution entry point. No tooling behavior changed in this follow-up.

## Follow-Up Decisions - 2026-08-21 01:11 JST

Owen accepted the planned-work frontier direction, requested explicit Agent Continuity versioning before UUID migration, and reopened the code-versus-docs repository boundary. Three bounded reviewers checked the current upgrade machinery, Agent Task Graph readiness semantics, and public/private topology.

Current findings and decisions:

- The rough sequence `Agent Meta > Agent Continuity > Agent Task Graph` is an orientation aid, not an authority hierarchy. Agent Meta owns harness policy and improvement, Agent Continuity owns durable project truth, Goal To Outcome owns selection and admission, and Agent Task Graph owns one live execution episode.
- Agent Continuity `frontier` is proposed to report selected durable work whose represented prerequisites and gates permit consideration at a pinned source revision. Agent Task Graph `ready` already reports pending execution nodes whose incoming execution predecessors succeeded. A separate runtime preflight must still check capacity, tools, permissions, worktree isolation, authorization, external state, and human gates.
- Agent Continuity already has manifest-schema version 1, source-commit and checksum records, `doctor`, read-only upgrade previews, and narrow tooling-only writes. It has no named tool release, scaffold/adopter version, or document-format version. The current upgrader deliberately does not mutate project-owned Markdown.
- The UUID change therefore requires a distinct document format v2 and a separate resumable `migrate` workflow. The useful Agent Skills precedent is to separate release identity, schema identity, fingerprints, receipts, and installed state; per-document content revisions are unnecessary because Git already owns that history.
- Random UUIDs prevent independent new-document allocation collisions but do not prevent two branches from assigning different UUIDs to the same existing document. Existing-doc migration requires one canonical committed plan with preimage hashes and UUIDv7 assignments, idempotent application, and a completion receipt written last.
- Migrate one project repository at a time. The first identity pass preserves numeric aliases, paths, and existing relationship fields; precise relationship families and optional filename renames follow separately.
- Do not move every document out of a code repository. Public product truth and contributor-critical docs remain with public code. Private operational memory moves to one private operations repository per coherent project and authorization/retention boundary; one such repository may coordinate several code repositories.
- A later thin private hub may register projects and genuinely cross-project assertions but must not become a giant canonical docs vault. Private sources may point to public nodes; public sources must not reveal that private sources, backlinks, counts, or repository pointers exist.
- UUID migration and repository extraction are separate changes. If content was already public, deleting or moving it does not erase Git history.

The proposal and this session record were updated. No release system, manifest schema, migration command, UUID assignment, frontier command, Agent Task Graph adapter, repository move, or public/remote write was implemented.

Verification:

- `scripts/release-check` passed, including installer, init, doctor/upgrade, structured-document, changelog, compile, plan metadata, repo-root link, and diff checks.
- The pre-existing ignored `scripts/__pycache__` directory was moved aside for the release hygiene gate and restored immediately afterward.
- A direct subtree metadata check still reports the repository's previously recorded root-relative `linked_paths` debt; no new failure was introduced by this follow-up.

## Follow-Up Implementation - 2026-08-21 02:31 JST

Owen selected the native Agent Continuity UUID direction and explicitly added
one creation invariant: fresh documents and freshly initialized repositories
must not receive old number-based aliases merely because migrated documents
have them.

Implemented result:

- Agent Continuity release `2026.08.21.1` introduces manifest schema 2 and
  document format 2 as separate version axes.
- Fresh structured documents receive an RFC UUIDv7 canonical `id`,
  `aliases: []`, and a type-plus-slug locator. The `new` command no longer calls
  a numeric allocator.
- The initializer omits numbered example records and generated views, UUID-binds
  real starter records without aliases, and records document-format target 2.
- Numeric aliases are created only by the existing-document migration or an
  explicit legacy `retire-id` tombstone.
- `format-status` reports v1, v2, and invalid records. `doctor` reports manifest
  and document-format migration separately and checks named release metadata.
- `migrate-uuids` prepares an immutable Git-committed mapping, records known
  worktrees and exact pre/postimage hashes, refuses unplanned v1 additions or
  divergent files before mutation, resumes mixed expected state, and writes a
  matching completion receipt last.
- The canonical scaffold skill now routes new repositories through the
  preview-first initializer instead of raw scaffold copying.

Self-hosted migration receipt:

- foundation commit: `d87ea088b643fce77d23d559c57b81a94344dec0`
- migration-plan commit: `663934fe4f03b703db210fb6023b99cbe3619684`
- migration ID: `01a02039-7a6a-78c6-ab78-480b3b5759b0`
- migration plan: `.agent-continuity/migrations/document-format-v2.json`
- completion receipt:
  `.agent-continuity/migrations/document-format-v2.json.receipt.json`
- corpus result: 75 v2 records, zero v1 records, zero invalid records; 51
  historical numeric identities retained as aliases and 24 formerly ID-less
  records aliasless

Verification before self-migration:

- `scripts/release-check` passed.
- Focused document, initializer, doctor/upgrade, install, and skill validation
  suites passed.
- Migration coverage includes an uncommitted-plan refusal, exact committed
  apply, lookup by UUID and alias, relationship-field preservation, idempotence,
  mixed-state resume, unplanned-v1 refusal before mutation, and divergent
  preimage byte preservation.

Independent implementation review found two cutover gaps before closeout. A
fresh aliasless audit still inherited a v1 `AUDT-####` validator, and an
all-postimage corpus with a missing receipt could appear healthy. Both were
corrected: audit numbering is now v1-only, `doctor` inspects canonical migration
state and supplies the resume command, the full receipt contract is validated,
and a valid completion receipt closes the v1 compatibility window while
allowing ordinary later edits that retain planned identity and aliases.

The visibility/repository-boundary question remains parked. No document
repository split, relationship normalization, broad filename rename, graph
database, public write, installation, or release publication was performed.
