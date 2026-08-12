---
type: session-log
title: Capture Adaptive Goal-To-Outcome Planning
domain: agent-continuity
status: completed
created_at: "2026-08-08 17:40:11 JST +0900"
updated_at: "2026-08-08 18:06:00 JST +0900"
started_at: "2026-08-08 17:31:00 JST +0900"
ended_at: "2026-08-08 18:06:00 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - agent-continuity
  - intent-discovery
  - executive-function
  - hierarchical-planning
related_plans: []
related_briefs: []
related_specs: []
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-08-08 - Capture Adaptive Goal-To-Outcome Planning

## Goal

Preserve and evaluate the idea that Agent Continuity could help form and execute any goal—from dinner to moving house to software—by adaptively clarifying intent, decomposing work to a personally useful depth, and remaining present through evidence and replanning.

## Context Read

- [IDEA-0005](../agent-continuity/ideas/IDEA-0005-general-human-agent-execution-graph.md)
- [EXPL-0003](../docs/orientation/explainers/EXPL-0003-agent-continuity-jira-linear-and-general-execution.md)
- Agent Continuity structured-doc workflow and idea-capture guidance
- Official or primary sources linked in IDEA-0006 for Goblin Tools, Tiimo, Taskade, Design Council, the International Institute of Business Analysis, Children and Adults with Attention-Deficit/Hyperactivity Disorder, Getting Things Done, and Hierarchical Task Network planning

## Result

- Added [IDEA-0006](../agent-continuity/ideas/IDEA-0006-adaptive-goal-to-outcome-quest-planning.md).
- Added [EXPL-0004](../docs/orientation/explainers/EXPL-0004-from-fuzzy-intent-to-next-action.md).
- Positioned the concept as an adaptive intent-to-outcome loop rather than merely recursive AI task generation.
- Preserved ideas, specifications, plans, optional implementation/execution briefs, live work, runs, and evidence as distinct scalable responsibilities.
- Defined a contextual actionability stopping rule and lazy decomposition rather than eager infinite expansion.
- Distinguished the quest-tree interface metaphor from the canonical AND/OR dependency and feedback graph.
- Recorded material overlap with Goblin Tools, Tiimo, Taskade, Getting Things Done, design and business analysis, coaching, and Hierarchical Task Network planning.
- Identified the candidate wedge as continuous discovery, personal granularity, execution, evidence, semantic history, resumption, and replanning.
- Proposed dinner for two, moving house, and a software feature as contrasting evaluation fixtures.

## Important Research Correction

The initial intuition that conventional project management focuses mainly on the latter half is directionally useful but incomplete. The former half already exists as product discovery, design research, service design, business analysis, consulting, coaching, and domain-specialist work. The product opportunity is to make useful portions of that support continuous and connected to execution, not to claim that the practice did not exist before AI.

Recursive task breakdown is also not a unique feature. Current products already offer adjustable task decomposition, brain-dump conversion, scheduling, project generation, dependencies, agents, and automations. Any product specification must therefore test the end-to-end continuity claim rather than treating nested subtasks as sufficient differentiation.

## Boundaries

- No medical or therapeutic efficacy claim was made.
- The landscape scan was bounded to documented capabilities and did not constitute hands-on comparative product evaluation.
- No canonical `QUEST-*` artifact, final domain model, product name, or implementation architecture was approved.
- No runtime, application, database, or external integration was implemented.
- Existing unrelated naming-migration changes in the repository were not modified.

## Verification

- Sources were restricted to official product/practice documentation and primary or survey material for Hierarchical Task Network planning.
- Strict Mermaid layout lint passed for IDEA-0006 and EXPL-0004. The diagrams use grouped subgraphs, labeled feedback arrows, distinct shapes, and color classes to encode phases and decisions.
- YAML frontmatter parsing, local Markdown target checks, and trailing-whitespace checks passed for the five created or updated documents.
- The current `agent-continuity docs check-links` command returned `No links found` during the in-progress naming and path migration, so it was not treated as link proof; an independent local-target check verified the relevant Markdown links instead.
- `agent-continuity docs check` returned no errors, but it shares the same migration context and was not treated as coverage of files outside its current discovery paths.

## Follow-Up

Prototype the smallest conversation-to-next-action loop and evaluate it against ordinary chat and static checklists on dinner, moving house, and software-feature fixtures before promoting IDEA-0006 into a concept or product specification.

## Boundary Refinement - Continuity Versus Real-World Execution

The user identified that real-world human execution may deserve a separate product analogous to how GitHub provides the software execution environment. This is a valid bounded-context split with one correction: GitHub is not an agent work plane, because humans and automation also work there. It is a domain-specific software execution provider.

IDEA-0005 and IDEA-0006 now distinguish:

- Agent Continuity as the durable intent, knowledge, decision, plan, provenance, and cross-provider history layer
- execution providers as owners of live operational state
- GitHub, GitLab, or local tooling as software execution providers
- a candidate real-world action workspace as an independently useful provider for hierarchical goals, dependency frontiers, schedules, focus, human gates, and evidence

The real-world workspace may execute work through humans, agents, and services. This executor-neutral boundary survives improvements in automation better than a permanent human-versus-agent split.

The move-house example also clarified that the required structure is a hierarchical dependency graph or AND/OR graph, not a generated checklist. `contributes_to`, `requires` or `blocked_by`, and `alternative_to` must remain distinct. The interface should expose only the small actionable frontier and be able to explain why each action exists, why it is available now, what it unlocks, who can perform it, and what evidence completes it.

## Independent Architecture And Product Reviews

Two independent agent passes challenged and researched the boundary:

- The architecture review recommended one shared relationship core with separately useful Continuity, software-provider, and real-world action surfaces. It rejected both one undifferentiated mega-product and two disconnected truth systems. It recommended a modular monolith for the first implementation, stable entity references, explicit owners, a small relationship vocabulary, append-only semantic events, and owner-controlled projections.
- The product/workflow review found close precedents in Confluence plus Jira, Case Management Model and Notation plus Business Process Model and Notation, ServiceNow case tasks and playbooks, Camunda mixed human/service workflows, HL7 FHIR plan definitions and execution tasks, Asana Work Graph, Hierarchical Task Analysis, and object-centric process mining.

The combined finding is that the architecture pattern is established, while the candidate differentiation is consumer-grade adaptive case management: fuzzy-intent discovery, personally variable decomposition, actionable-frontier presentation, navigable why chains, evidence-driven replanning, and provider-neutral personal continuity.
