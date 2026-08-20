---
type: session-log
title: Spec Systems And Ceremony Evaluation
domain: agent-continuity
status: completed
created_at: "2026-08-20 17:13:32 JST +0900"
updated_at: "2026-08-20 22:33:40 JST +0900"
started_at: "2026-08-20 17:13:32 JST +0900"
ended_at: "2026-08-20 17:29:44 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex main agent
  - delegated landscape researcher
  - delegated topology reviewer
  - delegated architecture red-team reviewer
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

Owen selected the native Agent Continuity direction for continued design. `RSCH-0010` and `EVAL-0002` are now parked references with explicit reopen triggers rather than active gates. `IDEA-0003` now separates immutable UUID identity, mutable filename locators, Markdown content, document-node records, canonical relationship assertions, and derived graph projections. No schema or corpus migration was implemented in this follow-up.
