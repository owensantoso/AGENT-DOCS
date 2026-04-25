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
6. [plans/README.md](plans/README.md) - upstream AGENT-DOCS and docs-meta improvement plans

Reusable global and surface-level agent instructions live under `scaffold/agent-instructions/`. Keep those separate from repo-specific docs so personal defaults, project rules, and future persona files can evolve without crowding every target repo root.

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
  ideas/
  specs/
  plans/
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
  IDEAS.md
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
      PLAN-<id>-<slug>/
        PLAN-<id>-<slug>.md
        IMPL-<id>-<task-ref>-<slug>.md
    ideas/
  decisions/
    adr/
    learnings/
    execution-readiness.md
  repo-health/
    ideas/
    specs/
    plans/
      <repo-health-topic>/
        PLAN-<id>-<slug>.md
        IMPL-<id>-01-<slug>.md
    audits/
    session-logs/
    state/
  research/
    ideas/
    specs/
  operations/
    ideas/
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
IDEA -> SPEC -> PLAN -> IMPL -> Issue / PR
```

- Ideas own early sparks, rambles, possible future work, and not-yet-formed thoughts.
- Specs own durable requirements and language before implementation planning. They may describe features, bugs, improvements, architecture, repo-health work, or research-backed decisions.
- Plans own intent, architecture, scope, sequencing, and the build-time interface choices that matter.
- Implementation briefs own bounded execution detail.
- Architecture area docs own durable vocabulary, boundaries, and caller-facing interfaces for each `AREA-*`.
- Parent GitHub issues usually track plans or work packages.
- Sub-issues usually track implementation briefs or independently grabbable slices.

## Deterministic Metadata

When installed in a repo, [scripts/docs-meta](scripts/docs-meta) gives agents and humans a deterministic way to manage docs metadata. It scans Markdown filenames and frontmatter as the source of truth, then creates generated views from that state.

This exists because agents are good at synthesis but unreliable at bookkeeping. They can forget the next `IDEA-*` or `SPEC-*` number, miss a stale status, or hand-edit a registry that no longer matches the repo. `docs-meta` moves that work into a small script.

Use it for:

- next `IDEA-*`, `SPEC-*`, `PLAN-*`, `IMPL-*`, and `ADR-*` IDs
- creating new ideas, specs, plans, implementation briefs, and ADRs
- updating frontmatter status
- extracting Markdown todos
- regenerating `IDEAS.md`, `SPECS.md`, `DOCS-REGISTRY.md`, `TODOS.md`, `AREAS.md`, `AUDITS.md`, and `ROADMAP-VIEW.md`
- checking duplicate IDs, stale generated docs, metadata contracts, statuses, and mismatched filenames
- inspecting docs links, backlinks, broken repo-local links, and orphan docs
- normalizing repo-local Markdown hrefs to relative links
- moving or renaming docs with backlink rewrites and dry-run previews
- showing advisory docs-health warnings for docs that may be stale or worth reviewing
- producing a stable-ID plan roadmap from `sequence` frontmatter
- printing generated views in the CLI while refreshing their Markdown cache and `updated_at` metadata

The repo tree remains the source of truth. Generated files are views, not separate state.

Read [scripts/README.md](scripts/README.md) for the rationale, command reference, and adoption notes.

Upstream `docs-meta` feature work belongs in [plans/](plans/), not in the consuming repo that first exposes the need.

## Smaller Project Shape

Small repos do not need the full scaffolding. Start with the smallest set that prevents confusion.

```text
docs/
  CURRENT_STATE.md
  ARCHITECTURE.md
  ROADMAP.md
  plans/
    PLAN-<id>-<slug>/
      PLAN-<id>-<slug>.md
      IMPL-<id>-01-<slug>.md
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

## Scaffold Map

The [scaffold/](scaffold/) folder is shaped like the docs tree it creates. For a new repo, copy the parts of that folder you need instead of translating a flat template list into paths by hand.

Use scaffold files as starting points, not as mandatory paperwork. Keep one canonical home for each doc, then use generated registries like `IDEAS.md`, `SPECS.md`, `AREAS.md`, `AUDITS.md`, `ROADMAP-VIEW.md`, and `HEALTH.md` for cross-cutting views.

### Entry Points

- [scaffold/AGENTS.md](scaffold/AGENTS.md) - root agent index and repo rules
- [scaffold/agent-instructions/global-AGENTS.md](scaffold/agent-instructions/global-AGENTS.md) - personal/global Codex instructions for always-on orchestration habits
- [scaffold/agent-instructions/surface-AGENTS.md](scaffold/agent-instructions/surface-AGENTS.md) - local instructions for one app, package, or service
- [scaffold/docs/README.md](scaffold/docs/README.md) - map for a repo's `docs/` folder
- [scripts/docs-meta](scripts/docs-meta) - deterministic docs metadata CLI

### Orientation And Reality

- [scaffold/docs/orientation/ONBOARDING.md](scaffold/docs/orientation/ONBOARDING.md) - non-code product/system walkthrough
- [scaffold/docs/orientation/CURRENT_STATE.md](scaffold/docs/orientation/CURRENT_STATE.md) - compact truth page and fanout
- [scaffold/docs/orientation/ROADMAP.md](scaffold/docs/orientation/ROADMAP.md) - ordered sequence and rationale
- [scaffold/docs/orientation/ARCHITECTURE.md](scaffold/docs/orientation/ARCHITECTURE.md) - system shape and decision provenance
- [scaffold/docs/architecture/README.md](scaffold/docs/architecture/README.md) - split architecture hub and area registry
- [scaffold/docs/architecture/areas/AREA-EXAMPLE.md](scaffold/docs/architecture/areas/AREA-EXAMPLE.md) - `AREA-*` boundary doc example
- [scaffold/docs/repo-health/codebase-map.md](scaffold/docs/repo-health/codebase-map.md) - current module map and entry points
- [scaffold/docs/repo-health/data-seams.md](scaffold/docs/repo-health/data-seams.md) - canonical seams, compatibility layers, and extension rules
- [scaffold/docs/repo-health/testing-guide.md](scaffold/docs/repo-health/testing-guide.md) - real verification commands and limits

### Product And Planning

- [scaffold/docs/IDEAS.md](scaffold/docs/IDEAS.md) - global idea registry using one continuous `IDEA-####` sequence
- [scaffold/docs/product/ideas/IDEA-0000-idea-title.md](scaffold/docs/product/ideas/IDEA-0000-idea-title.md) - lightweight capture example for early ideas and future possibilities
- [scaffold/docs/SPECS.md](scaffold/docs/SPECS.md) - global spec registry using one continuous `SPEC-####` sequence
- [scaffold/docs/product/specs/SPEC-0000-spec-title.md](scaffold/docs/product/specs/SPEC-0000-spec-title.md) - durable spec example for features, bugs, improvements, architecture, repo-health, and research
- [scaffold/docs/product/specs/feature-spec-compatibility.md](scaffold/docs/product/specs/feature-spec-compatibility.md) - compatibility pointer for older feature-spec workflows
- [scaffold/docs/product/plans/README.md](scaffold/docs/product/plans/README.md) - guide for parent plans and implementation briefs
- [scaffold/docs/product/plans/PLAN-0000-plan-title/PLAN-0000-plan-title.md](scaffold/docs/product/plans/PLAN-0000-plan-title/PLAN-0000-plan-title.md) - parent plan example
- [scaffold/docs/product/plans/PLAN-0000-plan-title/IMPL-0000-00-implementation-brief-title.md](scaffold/docs/product/plans/PLAN-0000-plan-title/IMPL-0000-00-implementation-brief-title.md) - bounded execution brief example
- [scaffold/optional/central-implementation-briefs/README.md](scaffold/optional/central-implementation-briefs/README.md) - optional central brief-folder guide for repos that keep briefs separate
- [scaffold/docs/repo-health/prompts/reusable-implementer-handoff-prompt.md](scaffold/docs/repo-health/prompts/reusable-implementer-handoff-prompt.md) - boot prompt for fresh implementation sessions

### Memory And Decisions

- [scaffold/docs/decisions/adr/README.md](scaffold/docs/decisions/adr/README.md) - ADR folder guide and decision index
- [scaffold/docs/decisions/adr/ADR-0000-decision-title.md](scaffold/docs/decisions/adr/ADR-0000-decision-title.md) - durable decision record example
- [scaffold/docs/repo-health/session-logs/README.md](scaffold/docs/repo-health/session-logs/README.md) - timestamped session-log convention
- [scaffold/docs/repo-health/session-logs/YYYY-MM-DD-session-title.md](scaffold/docs/repo-health/session-logs/YYYY-MM-DD-session-title.md) - session receipt example
- [scaffold/docs/repo-health/audits/README.md](scaffold/docs/repo-health/audits/README.md) - periodic repo-health checkup convention
- [scaffold/docs/repo-health/audits/YYYY-MM-DD-repo-health-audit.md](scaffold/docs/repo-health/audits/YYYY-MM-DD-repo-health-audit.md) - broad docs/architecture/maintenance/test/tooling audit receipt
- [scaffold/docs/repo-health/state/README.md](scaffold/docs/repo-health/state/README.md) - state-history snapshot guide

### Domain-Specific Work

- [scaffold/docs/research/notes/research-note.md](scaffold/docs/research/notes/research-note.md) - research question, findings, recommendation
- [scaffold/docs/operations/checklists/release-checklist.md](scaffold/docs/operations/checklists/release-checklist.md) - release or operational checklist
- [scaffold/docs/marketing/plans/marketing-plan.md](scaffold/docs/marketing/plans/marketing-plan.md) - launch or growth campaign plan

## What Is Most Reusable

The most reusable idea in this workflow is not the exact folder tree. It is the separation of jobs:

- current state tells you what is true now
- specs and roadmap explain product direction
- parent plans define intent, boundaries, invariants, sequencing, and parallelization
- implementation briefs define bounded execution slices
- session logs leave timestamped receipts for important work
- ADRs preserve durable decisions and rejected alternatives

Start small, then add structure only when the absence of structure is costing you comprehension.
