# Agent Docs Workflow

Portable docs kit for running an agent-friendly planning and implementation workflow in a new repository.

This pack is designed for repos where:

- feature work starts from a parent plan
- each plan can be broken into bounded implementation briefs
- the main agent coordinates subagents instead of trying to hold the whole milestone at once
- task grouping and parallelization are decided deliberately, not ad hoc
- session memory, decisions, and state history are kept in durable repo docs instead of chat

## Read this first

1. [AGENTS.md](AGENTS.md)
2. [guides/workflow-overview.md](guides/workflow-overview.md)
3. [guides/doc-types-and-responsibilities.md](guides/doc-types-and-responsibilities.md)
4. [guides/subagent-execution-loop.md](guides/subagent-execution-loop.md)
5. [guides/adoption-checklist.md](guides/adoption-checklist.md)

## Templates

- [templates/AGENTS.template.md](templates/AGENTS.template.md)
- [templates/DOCS-README.template.md](templates/DOCS-README.template.md)
- [templates/orientation/ONBOARDING.template.md](templates/orientation/ONBOARDING.template.md)
- [templates/CURRENT_STATE.template.md](templates/CURRENT_STATE.template.md)
- [templates/ROADMAP.template.md](templates/ROADMAP.template.md)
- [templates/ARCHITECTURE.template.md](templates/ARCHITECTURE.template.md)
- [templates/feature-spec.template.md](templates/feature-spec.template.md)
- [templates/research/research-note-template.md](templates/research/research-note-template.md)
- [templates/operations/release-checklist-template.md](templates/operations/release-checklist-template.md)
- [templates/marketing/marketing-plan-template.md](templates/marketing/marketing-plan-template.md)
- [templates/codebase-map.template.md](templates/codebase-map.template.md)
- [templates/data-seams.template.md](templates/data-seams.template.md)
- [templates/testing-guide.template.md](templates/testing-guide.template.md)
- [templates/surface-AGENTS.template.md](templates/surface-AGENTS.template.md)
- [templates/reusable-implementer-handoff-prompt.template.md](templates/reusable-implementer-handoff-prompt.template.md)
- [templates/plans/README.template.md](templates/plans/README.template.md)
- [templates/plans/plan-template.md](templates/plans/plan-template.md)
- [templates/plans/implementation-brief-template.md](templates/plans/implementation-brief-template.md)
- [templates/adr/README.template.md](templates/adr/README.template.md)
- [templates/adr/adr-template.md](templates/adr/adr-template.md)
- [templates/session-logs/README.template.md](templates/session-logs/README.template.md)
- [templates/session-logs/session-log-template.md](templates/session-logs/session-log-template.md)
- [templates/state/README.template.md](templates/state/README.template.md)

## Suggested starter structure

```text
docs/
  README.md
  orientation/
    CURRENT_STATE.md
    ONBOARDING.md
    ROADMAP.md
    ARCHITECTURE.md
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
    plans/
      <repo-health-topic>/
        plan.md
        impl-task-1-<slug>.md
    session-logs/
    state/
  research/
  operations/
  marketing/
AGENTS.md
<surface>/AGENTS.md
```

The exact folders should match the repo. The important rule is topic first, artifact type second: plans live under the domain that owns the work.

## What is most reusable

The most reusable idea in this workflow is the split between:

- parent plans that define intent, boundaries, invariants, sequencing, and parallelization
- implementation briefs that define one bounded execution slice suitable for a smaller model or subagent
- session logs that leave timestamped receipts for important human/agent work
- ADRs that preserve durable cross-plan decisions and alternatives

That separation keeps the main agent focused on architecture and integration while still making delegation safe.
