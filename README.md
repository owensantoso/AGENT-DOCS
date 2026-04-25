# Agent Docs Workflow

Portable docs kit for running an agent-friendly planning and implementation workflow in a repository.

The core idea is simple: docs should let a fresh human or AI agent understand current reality, planned intent, execution boundaries, and the reason a change happened without needing old chat history.

This kit is useful when:

- feature work starts from a parent plan
- product, system, bug, architecture, or repo-health requirements can be captured as specs before planning
- plans are broken into bounded implementation briefs when useful
- agents or humans need to resume work across sessions
- decisions, session history, and verification need durable homes
- the repo is large enough that "just read the code" is not a kind onboarding path

## Read This First

1. [AGENTS.md](AGENTS.md) - local instructions for working in this repo
2. [guides/workflow-overview.md](guides/workflow-overview.md) - the workflow in one pass
3. [guides/doc-types-and-responsibilities.md](guides/doc-types-and-responsibilities.md) - what each doc type owns
4. [guides/subagent-execution-loop.md](guides/subagent-execution-loop.md) - how to split, delegate, and integrate work
5. [guides/adoption-checklist.md](guides/adoption-checklist.md) - how to install the workflow in another repo

## The Folder Model

Use a topic-first docs hierarchy. The top-level folder should describe the kind of work or knowledge, and artifact types like `plans/` should live under the topic that owns them.

The useful question is:

> Who needs to care about this later?

### Orientation

```text
docs/orientation/
  CURRENT_STATE.md
  ONBOARDING.md
  ROADMAP.md
  ARCHITECTURE.md
```

Use this for first-contact docs.

- `CURRENT_STATE.md`: short truth page for what exists now and where to look next
- `ONBOARDING.md`: non-code walkthrough of the product/system and mental model
- `ROADMAP.md`: sequence, priority, and rationale
- `ARCHITECTURE.md`: system boundaries, canonical seams, and decision provenance

These files should be skimmable. If one starts becoming a history journal, move the detail elsewhere.

When architecture gets too dense for one overview, split it into an architecture hub plus area docs:

```text
docs/architecture/
  README.md
  areas/
    AREA-MODEL.md
    AREA-SYNC.md
```

Area IDs and filenames should match exactly. `AREA-SYNC` lives in `docs/architecture/areas/AREA-SYNC.md`. Use those IDs in plan frontmatter, session logs, commit trailers, PR paper trails, and issue bodies. A change can touch multiple areas.

### Product

```text
docs/product/
  specs/
  plans/
  future-ideas/
```

Use this for user-facing product behavior or product-enabling architecture.

Examples:

- capture flow
- search
- sync
- data model changes that unlock product behavior
- import/export
- UI surfaces
- specs

Even if a product plan is architecture-heavy, it still belongs here when the reason for the work is product capability.

### Decisions

```text
docs/decisions/
  adr/
  learnings/
  execution-readiness.md
```

Use this for durable reasoning.

- `adr/`: decisions that affect multiple future plans or long-lived architecture
- `learnings/`: surprising lessons, plan corrections, runtime/tooling discoveries
- `execution-readiness.md`: preflight assumptions and environment blockers

Do not put routine implementation notes here. Use session logs or implementation briefs for those.

### Repo Health

```text
docs/repo-health/
  plans/
  session-logs/
  state/
```

Use this for the project machinery itself.

Examples:

- docs information architecture
- CI setup
- test reliability
- dependency/tooling upgrades
- release workflow cleanup
- agent workflow conventions
- state-history snapshots
- timestamped session receipts

This is where you put work that makes the repo easier to understand, verify, or maintain but does not directly change the product.

### Research

```text
docs/research/
```

Use this for uncertainty.

Examples:

- feasibility spikes
- provider/library comparisons
- market or technical investigations
- findings that may lead to a spec, plan, or "do not build this yet"

Research docs should make the question and recommendation obvious. They do not need to become implementation plans unless the repo chooses to act on them.

### Operations

```text
docs/operations/
```

Use this for running, shipping, or recovering the project.

Examples:

- release checklists
- App Store/TestFlight readiness
- hosted service setup
- migration rollout notes
- manual QA checklists
- incident or production recovery notes

If the work is about safely operating the project rather than designing or building the product, it probably belongs here.

### Marketing

```text
docs/marketing/
```

Use this for growth, launch, positioning, and public-facing strategy.

Examples:

- launch plans
- campaign scripts
- audience research
- messaging
- distribution plans
- marketing outputs

Marketing can use the same plan/brief pattern when execution needs structure, but it should stay in the marketing domain.

## Suggested Full Structure

```text
docs/
  README.md
  SPECS.md
  orientation/
    CURRENT_STATE.md
    ONBOARDING.md
    ROADMAP.md
    ARCHITECTURE.md
  architecture/
    README.md
    areas/
      AREA-<NAME>.md
  product/
    specs/
    plans/
      plan-<id>-<slug>/
        plan.md
        impl-task-<task-ref>-<slug>.md
    future-ideas/
  decisions/
    adr/
    learnings/
    execution-readiness.md
  repo-health/
    specs/
    plans/
      <repo-health-topic>/
        plan.md
        impl-task-1-<slug>.md
    session-logs/
    state/
  research/
    specs/
  operations/
    specs/
  marketing/
    specs/
AGENTS.md
<surface>/AGENTS.md
```

The important rule is topic first, artifact type second. A plan lives under the domain that owns the outcome.

## Work Item Mapping

Use the docs as the source of truth and GitHub as tracking:

```text
SPEC -> PLAN -> IMPL -> Issue / PR
```

- Specs own product or system requirements.
- Specs own durable requirements and language before implementation planning. They may describe features, bugs, improvements, architecture, repo-health work, or research-backed decisions.
- Plans own intent, architecture, scope, sequencing, and the build-time interface choices that matter.
- Implementation briefs own bounded execution detail.
- Architecture area docs own durable vocabulary, boundaries, and caller-facing interfaces for each `AREA-*`.
- Parent GitHub issues usually track plans or work packages.
- Sub-issues usually track implementation briefs or independently grabbable slices.

## Deterministic Metadata

When installed in a repo, [scripts/docs-meta](scripts/docs-meta) gives agents and humans a deterministic way to manage docs metadata. It scans Markdown filenames and frontmatter as the source of truth, then creates generated views from that state.

This exists because agents are good at synthesis but unreliable at bookkeeping. They can forget the next `SPEC-*` number, miss a stale status, or hand-edit a registry that no longer matches the repo. `docs-meta` moves that work into a small script.

Use it for:

- next `SPEC-*`, `PLAN-*`, `IMPL-*`, and `ADR-*` IDs
- creating new specs, plans, implementation briefs, and ADRs
- updating frontmatter status
- extracting Markdown todos
- regenerating `SPECS.md`, `DOCS-REGISTRY.md`, `TODOS.md`, and `AREAS.md`
- checking duplicate IDs, stale generated docs, metadata contracts, statuses, and mismatched filenames

The repo tree remains the source of truth. Generated files are views, not separate state.

Read [scripts/README.md](scripts/README.md) for the rationale, command reference, and adoption notes.

## Smaller Project Shape

Small repos do not need the full scaffolding. Start with the smallest set that prevents confusion.

```text
docs/
  CURRENT_STATE.md
  ARCHITECTURE.md
  ROADMAP.md
  plans/
    plan-<slug>/
      plan.md
      impl-task-1-<slug>.md
  decisions/
    adr/
  session-logs/
AGENTS.md
```

For very small repos, this is often enough:

```text
docs/
  CURRENT_STATE.md
  ARCHITECTURE.md
  plans/
  session-logs/
AGENTS.md
```

Add `product/`, `repo-health/`, `research/`, `operations/`, or `marketing/` only when those categories start competing for space. The hierarchy should reduce ambiguity, not advertise sophistication.

## Template Map

Use templates as starting points, not as mandatory paperwork. Copy only what the repo needs.

### Entry Points

- [templates/AGENTS.template.md](templates/AGENTS.template.md) - root agent index and repo rules
- [templates/global-AGENTS.template.md](templates/global-AGENTS.template.md) - personal/global Codex instructions for always-on orchestration habits
- [templates/surface-AGENTS.template.md](templates/surface-AGENTS.template.md) - local instructions for one app, package, or service
- [templates/DOCS-README.template.md](templates/DOCS-README.template.md) - map for a repo's `docs/` folder
- [scripts/docs-meta](scripts/docs-meta) - deterministic docs metadata CLI

### Orientation And Reality

- [templates/orientation/ONBOARDING.template.md](templates/orientation/ONBOARDING.template.md) - non-code product/system walkthrough
- [templates/CURRENT_STATE.template.md](templates/CURRENT_STATE.template.md) - compact truth page and fanout
- [templates/ROADMAP.template.md](templates/ROADMAP.template.md) - ordered sequence and rationale
- [templates/ARCHITECTURE.template.md](templates/ARCHITECTURE.template.md) - system shape and decision provenance
- [templates/architecture/README.template.md](templates/architecture/README.template.md) - split architecture hub and area registry
- [templates/architecture/area-template.md](templates/architecture/area-template.md) - `AREA-*` boundary doc template
- [templates/codebase-map.template.md](templates/codebase-map.template.md) - current module map and entry points
- [templates/data-seams.template.md](templates/data-seams.template.md) - canonical seams, compatibility layers, and extension rules
- [templates/testing-guide.template.md](templates/testing-guide.template.md) - real verification commands and limits

### Product And Planning

- [templates/SPECS.template.md](templates/SPECS.template.md) - global spec registry using one continuous `SPEC-####` sequence
- [templates/spec.template.md](templates/spec.template.md) - durable spec template for features, bugs, improvements, architecture, repo-health, and research
- [templates/feature-spec.template.md](templates/feature-spec.template.md) - compatibility pointer for older feature-spec workflows
- [templates/plans/README.template.md](templates/plans/README.template.md) - guide for parent plans and implementation briefs
- [templates/plans/plan-template.md](templates/plans/plan-template.md) - parent plan template
- [templates/plans/implementation-brief-template.md](templates/plans/implementation-brief-template.md) - bounded execution brief template
- [templates/plans/implementation-briefs/README.template.md](templates/plans/implementation-briefs/README.template.md) - optional central brief-folder guide for repos that keep briefs separate
- [templates/reusable-implementer-handoff-prompt.template.md](templates/reusable-implementer-handoff-prompt.template.md) - boot prompt for fresh implementation sessions

### Memory And Decisions

- [templates/adr/README.template.md](templates/adr/README.template.md) - ADR folder guide and decision index
- [templates/adr/adr-template.md](templates/adr/adr-template.md) - durable decision record
- [templates/session-logs/README.template.md](templates/session-logs/README.template.md) - timestamped session-log convention
- [templates/session-logs/session-log-template.md](templates/session-logs/session-log-template.md) - session receipt template
- [templates/state/README.template.md](templates/state/README.template.md) - state-history snapshot guide

### Domain-Specific Work

- [templates/research/research-note-template.md](templates/research/research-note-template.md) - research question, findings, recommendation
- [templates/operations/release-checklist-template.md](templates/operations/release-checklist-template.md) - release or operational checklist
- [templates/marketing/marketing-plan-template.md](templates/marketing/marketing-plan-template.md) - launch or growth campaign plan

## What Is Most Reusable

The most reusable idea in this workflow is not the exact folder tree. It is the separation of jobs:

- current state tells you what is true now
- specs and roadmap explain product direction
- parent plans define intent, boundaries, invariants, sequencing, and parallelization
- implementation briefs define bounded execution slices
- session logs leave timestamped receipts for important work
- ADRs preserve durable decisions and rejected alternatives

Start small, then add structure only when the absence of structure is costing you comprehension.
