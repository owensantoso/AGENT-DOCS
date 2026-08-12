---
type: session-log
title: Capture General Human-Agent Execution Graph
domain: agent-continuity
status: completed
created_at: "2026-08-08 16:31:35 JST +0900"
updated_at: "2026-08-08 17:29:45 JST +0900"
started_at: "2026-08-08 16:27:00 JST +0900"
ended_at: "2026-08-08 17:29:45 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - agent-continuity
  - orchestration
  - human-gates
  - non-software-work
  - work-tracking
related_plans: []
related_briefs: []
related_specs: []
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-08-08 - Capture General Human-Agent Execution Graph

## Goal

Compare Agent Continuity with Jira, Confluence, Jira Product Discovery, and Linear, then preserve the broader idea that the system can coordinate human-agent outcomes beyond software development.

## Context Read

- [IDEA-0003](../agent-continuity/ideas/IDEA-0003-federated-document-library-and-relationship-graph.md)
- [IDEA-0004](../agent-continuity/ideas/IDEA-0004-semantic-history-and-work-projections.md)
- [EXPL-0002](../docs/orientation/explainers/EXPL-0002-documents-work-delivery-and-semantic-history.md)
- Jira, Confluence, Jira Product Discovery, and Linear official product documentation linked from IDEA-0005 and EXPL-0003
- Prior Court Scout evidence-gate model for legitimate badminton access research

## Result

- Added [IDEA-0005](../agent-continuity/ideas/IDEA-0005-general-human-agent-execution-graph.md).
- Added [EXPL-0003](../docs/orientation/explainers/EXPL-0003-agent-continuity-jira-linear-and-general-execution.md).
- Recorded that Jira is already a general work system, Confluence is a linked knowledge layer, and Jira Product Discovery covers ideas and insights before delivery.
- Recorded that Linear already has substantial documents, initiatives, dependencies, version history, and explicit agent delegation with retained human accountability.
- Reframed the candidate product as a provider-neutral human-agent execution and evidence graph rather than another agent-enabled issue tracker.
- Added general concepts for goal, work item, accountable owner, assignment, executor, run, result, evidence, gate, and semantic event.
- Separated accountable ownership from assignment so delegating execution to an agent does not silently transfer human responsibility.
- Distinguished human action, human gate, and blocker.
- Proposed a generated Human Inbox for unresolved requests with explicit evidence and resumption contracts.
- Used software, badminton access, marketing, and purchase/travel examples to test the generalized model.

## Boundaries

- No Jira, Linear, Confluence, or Rovo connector was installed or configured.
- No product name, canonical domain model, tracker authority policy, or implementation architecture was approved.
- No event index, execution runtime, Human Inbox, or provider adapter was implemented.
- Existing unrelated naming-migration changes in the repository were not modified.

## Verification

- Official sources were used for current Jira, Confluence, Jira Product Discovery, and Linear capabilities.
- Strict Mermaid layout lint passed for IDEA-0005 and EXPL-0003.
- The diagrams were structurally checked but not rendered because no Mermaid renderer is installed in the workspace.
- Agent Continuity `check` and `check-links` reported no errors for IDEA-0005, EXPL-0003, or this session log.
- Whitespace validation passed for the files changed by this capture.
- The repository-wide Agent Continuity check still reports unrelated naming-migration and incomplete-template errors; those existing changes were not modified.

## Follow-Up

Test the same minimum execution vocabulary against one software project and Court Scout before promoting the model into a concept or approving a provider-integration architecture.

## Correction - Tracker Reuse Does Not Remove Planning Artifacts

What happened: the recommendation not to rebuild Jira or Linear tracker interfaces sounded like a recommendation to remove plans and implementation briefs and keep only specifications.

What led to it: the product-boundary explanation distinguished Agent Continuity from commodity tracker features but did not immediately restate which existing Agent Continuity artifacts remain authoritative.

Source: explainer ambiguity.

What changed: IDEA-0005 and EXPL-0003 now explicitly preserve `IDEA -> SPEC -> PLAN -> optional IMPL / execution brief -> work items -> runs -> evidence`. Reusing Jira, Linear, or GitHub applies to operational ticket views and workflow state, not to the specification, planning, or bounded-handoff responsibilities.

Verification: both documents now state the preserved hierarchy next to the product-boundary recommendation rather than relying on links to earlier planning guidance.

Follow-up: decide whether non-software bounded handoffs need a new `EXEC-*` type only after real fixtures prove that `IMPL-*` is too software-specific.
