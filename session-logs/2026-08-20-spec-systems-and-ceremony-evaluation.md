---
type: session-log
title: Spec Systems And Ceremony Evaluation
domain: agent-continuity
status: completed
created_at: "2026-08-20 17:13:32 JST +0900"
updated_at: "2026-08-21 00:14:44 JST +0900"
started_at: "2026-08-20 17:13:32 JST +0900"
ended_at: "2026-08-20 17:29:44 JST +0900"
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
areas:
  - agent-continuity
  - spec-driven-development
  - project-memory
  - documentation-ceremony
  - repository-topology
  - identity-and-dependencies
related_plans: []
related_briefs: []
related_specs: []
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
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
