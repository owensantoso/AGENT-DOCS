---
type: research-survey
document_format_version: 2
id: 01a02039-7a68-71be-a2b2-624187822473
aliases:
  - "RSCH-0008"
title: Adaptive Goal-To-Outcome Planning Research Landscape
domain: research
status: completed
created_at: "2026-08-08 18:34:41 JST +0900"
updated_at: "2026-08-08 18:34:41 JST +0900"
owner: "Codex main agent"
question: "Which research traditions already cover fuzzy intent, adaptive elicitation, hierarchical decomposition, actionable-frontier selection, mixed human-agent execution, evidence, and replanning, and what combination remains uncommon?"
source:
  type: conversation
  link: "codex://thread/019fdae4-b3ef-7191-8173-ecfca7d9e4a0"
  notes: "Requested as an extra-high parallel research pass after the user generalized Agent Continuity into a personal goal-to-outcome and executive-function system."
external_sources:
  - title: "AHRQ Hierarchical Task Analysis"
    url: "https://digital.ahrq.gov/health-it-tools-and-resources/evaluation-resources/workflow-assessment-health-it-toolkit/all-workflow-tools/hierarchical-task-analysis"
  - title: "iStar 2.0 Language Guide"
    url: "https://www.ifi.uzh.ch/dam/jcr%3Adc1e764b-3e84-4ae0-a5fb-f7d2b4645b4e/iStar2.0_guide.pdf"
  - title: "Work Domain Analysis"
    url: "https://www.dst.defence.gov.au/publication/work-domain-analysis-concepts-guidelines-and-cases"
  - title: "OMG Case Management Model and Notation"
    url: "https://www.omg.org/cmmn/index.htm"
  - title: "Resource-rational human task decomposition"
    url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC10234566/"
  - title: "Adaptive planning depth"
    url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC11978448/"
  - title: "Continual Planning and Acting"
    url: "https://citeseerx.ist.psu.edu/document?doi=9034bff3f9f4930316ad8c7bc35a2ce6dfddcd06&repid=rep1&type=pdf"
  - title: "Principles of Mixed-Initiative User Interfaces"
    url: "https://www.microsoft.com/en-us/research/publication/principles-mixed-initiative-user-interfaces/"
  - title: "Guidelines for Human-AI Interaction"
    url: "https://www.microsoft.com/en-us/research/wp-content/uploads/2019/01/Guidelines-for-Human-AI-Interaction-camera-ready.pdf"
  - title: "Applied Cognitive Task Analysis"
    url: "https://pubmed.ncbi.nlm.nih.gov/9819578/"
  - title: "Behavior Change Technique Taxonomy"
    url: "https://pubmed.ncbi.nlm.nih.gov/23512568/"
  - title: "Lived Informatics model"
    url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC12435389/"
repo_findings:
  - "IDEA-0006 already models fuzzy intent, progressive decomposition, an actionable stopping rule, human-agent-service execution, evidence, and replanning."
  - "IDEA-0005 already separates goals, knowledge artifacts, work items, assignments, executors, runs, results, evidence, gates, and semantic events."
  - "The current product direction explicitly keeps personal use first and treats organizational scaling as deferred."
agent_notes:
  - "An extra-high independent research agent surveyed requirements engineering, goal modeling, human factors, artificial-intelligence planning, case management, mixed initiative, executive-function scaffolding, personal informatics, and organizational planning."
  - "The synthesis below distinguishes sourced traditions from product inference; it does not claim that the proposed application has established clinical efficacy."
related_ideas:
  - ../agent-continuity/ideas/IDEA-0005-general-human-agent-execution-graph.md
  - ../agent-continuity/ideas/IDEA-0006-adaptive-goal-to-outcome-quest-planning.md
related_evaluations: []
related_adrs: []
related_specs: []
related_plans: []
related_sessions:
  - ../session-logs/2026-08-08-personal-first-research-and-relationship-store.md
linked_paths:
  - agent-continuity/ideas/IDEA-0005-general-human-agent-execution-graph.md
  - agent-continuity/ideas/IDEA-0006-adaptive-goal-to-outcome-quest-planning.md
repo_state:
  based_on_commit: 9750871c50443d669e20be01e684fa8c1ce8b37b
  last_reviewed_commit: 9750871c50443d669e20be01e684fa8c1ce8b37b
---

# RSCH-0008 - Adaptive Goal-To-Outcome Planning Research Landscape

## Question

Which research traditions already cover fuzzy intent, adaptive elicitation, hierarchical decomposition, actionable-frontier selection, mixed human-agent execution, evidence, and replanning, and what combination remains uncommon?

## Short Answer

The idea is not a new primitive. It is an uncommon product synthesis of several mature and partially connected research traditions.

A compact research description is:

> A personal, mixed-initiative, open-world continual planner that turns ill-structured intent into a progressively elaborated goal-task-condition graph, then exposes a small actionable frontier for human, agent, or service execution.

Almost every clause has substantial prior work. No single surveyed field or system clearly owns the entire loop from private fuzzy intent through adaptive questioning, personal planning depth, mixed execution, evidence, interruption, and semantic replanning.

The strongest conclusion is that **good enough—start now** should remain a central design principle. Research supports planning only as deeply as the current branch, risk, reversibility, uncertainty, familiarity, and cognitive capacity require.

## Research Map

| Product concern | Established fields and vocabulary | Maturity | Remaining product question |
|---|---|---|---|
| Fuzzy intent | Ill-structured and wicked problems, discovery, problem framing, requirements elicitation | Established as a problem; uneven automation | How to formalize a personal want without freezing it too early |
| Adaptive questioning | Laddering, preference elicitation, active learning, value of information | Mature in bounded domains | Which answer changes the plan enough to justify interrupting the person? |
| Why and how | Goal-oriented requirements, iStar, KAOS, means-ends analysis, qualities, obstacles | Mature analysis methods | How to expose precise semantics without an enterprise modeling interface |
| Recursive decomposition | Hierarchical Task Analysis, Work Breakdown Structure, Hierarchical Task Network planning | Very mature | How deep should this branch go for this person now? |
| Alternatives | AND/OR refinement, methods, conditional branches | Very mature formally | How to preserve options without showing an enormous graph |
| Ready work | Preconditions, effects, entry criteria, sentries, partial-order planning | Very mature | Which one to five valid actions best fit time, energy, attention, risk, and context? |
| Start before full planning | Satisficing, least commitment, rolling-wave and continual planning | Established principle | What is the safe and useful stopping threshold? |
| Monitor and replan | Plan-act-monitor loops, discrepancy explanation, plan repair, goal revision | Mature research | How should messy real-world evidence revise only the affected branch? |
| Mixed execution | Mixed initiative, adjustable autonomy, SharedPlans, delegation and commitments | Decades of research | Who may propose, commit, spend, contact, approve, revoke, or recover? |
| Executive-function support | Action planning, implementation intentions, prompts, self-monitoring, organizational-skills interventions | Component evidence exists | Does this product reduce overwhelm and improve resumption rather than create more planning work? |
| Personal continuity | Personal informatics, lapsing, stopping, resumption and reflection | Mature tracking literature | How to move from retrospective tracking to prospective orchestration |
| Organization scale | Work Breakdown Structure, Critical Path Method, Business Process Model and Notation, Case Management Model and Notation, Business Motivation Model | Mature but fragmented | How to add authority, resources, policy, privacy and portfolio conflict without corrupting the personal model |

## This Is Not One Graph

The word “graph” currently hides several different semantics. They may share storage, but their edge types must not be collapsed.

| Structure | Question answered | Representative semantics |
|---|---|---|
| Means-ends or abstraction graph | Why does this matter, and how could it be achieved? | `serves`, `realized_by` |
| Goal-refinement graph | Which outcomes or strategies satisfy the parent? | AND refinement, OR refinement, contribution, obstacle |
| Work-decomposition hierarchy | What scope or deliverable is this part of? | `part_of`, `contributes_to` |
| Execution dependency graph | What must be true first, and what is executable now? | `requires`, `blocked_by`, precondition, entry criterion |
| Actor and authority graph | Who wants, owns, performs, approves, or delegates? | `accountable_for`, `assigned_to`, `approved_by` |
| Evidence and provenance graph | What observation supports this claim or completion? | `evidenced_by`, `observed_in`, `derived_from` |

[Work Domain Analysis](https://www.dst.defence.gov.au/publication/work-domain-analysis-concepts-guidelines-and-cases) is especially useful because it distinguishes why/how abstraction from part-whole decomposition. The [iStar 2.0 guide](https://www.ifi.uzh.ch/dam/jcr%3Adc1e764b-3e84-4ae0-a5fb-f7d2b4645b4e/iStar2.0_guide.pdf) supplies actors, goals, qualities, tasks, resources, dependencies, and refinement vocabulary.

An AND refinement also requires group semantics. Three independent pairwise `contributes_to` edges do not preserve that children A, B, and C are jointly sufficient only as a set. The eventual relationship model should support a refinement or method entity when group sufficiency matters.

## Closest Research And Practice Traditions

### Fuzzy Intent And Elicitation

Problem-framing literature explains why the problem changes while it is being understood. Goal-oriented requirements engineering adds structured why, how, who, quality, and obstacle questions.

[LadderBot](https://publikationen.bibliothek.kit.edu/1000096469) is a close prototype precedent: it explored conversational self-elicitation for requirements through structured laddering, but stopped near need articulation rather than continued execution.

Active learning contributes the computational intuition of asking the query expected to reduce uncertainty most. [Settles' survey](https://minds.wisconsin.edu/handle/1793/60660) is useful, with an important limitation: active learning normally assumes a known hypothesis space, while a personal goal often begins open-ended.

A practical question policy should ask when:

- the answer chooses between materially different branches
- an action is costly, risky, irreversible, or externally consequential
- a missing fact blocks the current frontier
- authority or consent is ambiguous

Otherwise, record a visible provisional assumption and permit progress.

### Human Task And Cognitive Analysis

[Hierarchical Task Analysis](https://digital.ahrq.gov/health-it-tools-and-resources/evaluation-resources/workflow-assessment-health-it-toolkit/all-workflow-tools/hierarchical-task-analysis) represents goals, subgoals, operations, and plans, including sequence and alternatives. It also exposes the classic failure mode: decomposition can continue indefinitely and must use a stopping rule.

[Applied Cognitive Task Analysis](https://pubmed.ncbi.nlm.nih.gov/9819578/) captures judgments, cues, difficult decisions, and tacit expertise that procedural task lists miss. This matters when the hard part of moving house is not “open property website” but deciding what location, trade-offs, documents, risk, and landlord conditions are acceptable.

### Formal Hierarchical Planning

Hierarchical Task Network (HTN) planning decomposes compound activities into executable actions. [SHOP2](https://research.ibm.com/publications/shop2-an-htn-planning-system) is a well-known implementation.

Hierarchical Goal Network planning distinguishes desired world states more clearly from procedural tasks. [The original HGN paper](https://www.cs.umd.edu/~nau/papers/shivashankar2011hierarchical.pdf) helps preserve distinctions such as:

- goal: housing is secured
- task: compare three apartments
- quality: affordable
- condition or resource: proof of income is available
- external milestone: landlord approves the application
- alternative methods: use a guarantor or increase the deposit

The first product need not implement a symbolic planner, but it should avoid representing all of these as identical checklist rows.

### Adaptive Cases And Workflows

Business Process Model and Notation (BPMN) is strongest when activities and control flow can be substantially specified in advance. [Case Management Model and Notation](https://www.omg.org/cmmn/index.htm) (CMMN) addresses evolving knowledge-driven work through cases, case files, stages, discretionary tasks, milestones, events, and entry or exit criteria.

CMMN is probably the closest enterprise abstraction. A move is a living case whose plan grows as information appears. The opportunity is to make this personally usable rather than expose enterprise notation.

### Mixed Human And Agent Execution

[Principles of Mixed-Initiative User Interfaces](https://www.microsoft.com/en-us/research/publication/principles-mixed-initiative-user-interfaces/) addresses when a machine should act, ask, wait, or return control. [Guidelines for Human-AI Interaction](https://www.microsoft.com/en-us/research/wp-content/uploads/2019/01/Guidelines-for-Human-AI-Interaction-camera-ready.pdf) emphasize uncertainty disclosure, contextual timing, correction, explanations, cautious adaptation, dismissal, and global controls.

[SharedPlans](https://www.sciencedirect.com/science/article/pii/0004370295001034) is a deeper collaborative-planning precedent for partial knowledge, commitments, and contracted-out actions.

The core unsolved product concern is authority rather than assignment alone:

- who may propose work?
- who may commit the person or organization?
- who may contact someone, disclose data, or spend money?
- what requires approval?
- what evidence is sufficient?
- who owns recovery after failure?

### Evidence, Monitoring, And Replanning

Continual planning integrates planning, acting, sensing, monitoring, and delayed refinement. [Brenner and Nebel](https://citeseerx.ist.psu.edu/document?doi=9034bff3f9f4930316ad8c7bc35a2ce6dfddcd06&repid=rep1&type=pdf) provide a useful overview.

Goal-Driven Autonomy adds expectations, observations, discrepancies, explanations, and revised goals. This suggests a richer completion record:

```text
expected result
observed result
source or evidence
discrepancy
explanation
resulting plan or goal revision
```

Do not begin by silently inferring goals from observed behavior. Plan recognition introduces ambiguity and privacy risk that a first personal product does not need.

## Why “Good Enough—Start Now” Matters

The selected phrase has multiple research foundations:

- HTA uses risk-sensitive reasoning about when more decomposition is worth the effort.
- [Resource-rational decomposition research](https://pmc.ncbi.nlm.nih.gov/articles/PMC10234566/) models human subgoal choices as a trade-off between solution benefit and planning cost.
- [Adaptive planning-depth research](https://pmc.ncbi.nlm.nih.gov/articles/PMC11978448/) studies how people vary depth and interleave planning with execution.
- Rolling-wave planning elaborates near-term work more than distant work.
- Least-commitment planning postpones unnecessary ordering and parameter choices.
- Continual planning deliberately postpones refinement until new information arrives.

A stronger replacement for a global “spiciness” control is:

> Elaborate until the next action is understandable and safe enough to attempt, while leaving reversible, uncertain, and distant branches abstract.

Depth can depend on:

- consequence of failure
- probability of failure
- reversibility
- uncertainty
- familiarity and skill
- present cognitive capacity
- cost of asking or planning further
- authority and external impact

This supports the user-facing escape hatch while giving the planner an intelligible default policy.

## Executive-Function And Personal-Use Evidence Boundary

Behavior-change research includes action planning, implementation intentions, problem solving, self-monitoring, feedback, prompts, cues, and practical support. The [Behavior Change Technique Taxonomy](https://pubmed.ncbi.nlm.nih.gov/23512568/) provides a useful vocabulary.

Evidence for Attention-Deficit/Hyperactivity Disorder (ADHD) interventions varies by intervention, population, and study quality. This survey does not establish that a task-planning application treats ADHD. The product should evaluate practical outcomes such as time to first action, missed prerequisites, perceived overwhelm, recovery after interruption, and verified progress.

The [Lived Informatics model](https://pmc.ncbi.nlm.nih.gov/articles/PMC12435389/) also treats lapsing, stopping, and resuming as normal. Re-entry and “what changed while I was away?” should be primary behavior, not an error state.

## Personal First, Organization Later

Starting personally is the correct scope. An organizational system adds qualitative concerns rather than merely more graph nodes:

- conflicting stakeholders and goals
- roles, teams, departments, and organizations
- delegated authority and approval policy
- resource capacity and scheduling
- access control and privacy partitions
- audit, compliance, retention, and legal hold
- portfolio priorities and cross-project conflicts
- contractual obligations and service levels
- cross-company identity and trust

Preserve only the upward-compatible primitives now:

- stable actor identity
- actor kind that may later include role, team, or organization
- separate accountability from execution
- explicit authority and provenance
- workspace and project boundaries
- append-only semantic events
- schema-versioned import and export

Do not build organization accounts, permissions, resource pools, portfolio dashboards, billing, or compliance workflows for the personal version.

## What Is Genuinely Uncommon

The uncommon combination is not AI-generated subtasks. It is:

- open-ended personal intent rather than a pre-modeled business process
- adaptive elicitation before and during planning
- explicit goals, qualities, conditions, tasks, decisions, obstacles, and evidence
- AND/OR goal refinement plus real execution dependencies
- progressive detail that changes by branch, context, and person
- a deliberately small actionable frontier
- a visible why-chain and unlock-chain for each action
- human, agent, service, or another person as replaceable executor types
- evidence-backed completion and semantic replanning
- graceful recovery after interruption or abandonment
- learning reusable playbooks without forcing each case through a rigid template

Requirements engineering typically stops before execution. Automated planning assumes domain knowledge. Workflow systems assume organizational process infrastructure. Behavior-change systems usually lack typed dependency semantics. Personal-informatics products emphasize tracking. Task managers flatten work into lists.

## Recommended Reading Order

1. [AHRQ Hierarchical Task Analysis](https://digital.ahrq.gov/health-it-tools-and-resources/evaluation-resources/workflow-assessment-health-it-toolkit/all-workflow-tools/hierarchical-task-analysis)
2. [iStar 2.0 Language Guide](https://www.ifi.uzh.ch/dam/jcr%3Adc1e764b-3e84-4ae0-a5fb-f7d2b4645b4e/iStar2.0_guide.pdf)
3. [Work Domain Analysis](https://www.dst.defence.gov.au/publication/work-domain-analysis-concepts-guidelines-and-cases)
4. [Official CMMN overview](https://www.omg.org/cmmn/index.htm)
5. [Resource-rational task decomposition](https://pmc.ncbi.nlm.nih.gov/articles/PMC10234566/)
6. [Continual Planning and Acting](https://citeseerx.ist.psu.edu/document?doi=9034bff3f9f4930316ad8c7bc35a2ce6dfddcd06&repid=rep1&type=pdf)
7. [Mixed-Initiative User Interfaces](https://www.microsoft.com/en-us/research/publication/principles-mixed-initiative-user-interfaces/)
8. [Applied Cognitive Task Analysis](https://pubmed.ncbi.nlm.nih.gov/9819578/)
9. [Behavior Change Technique Taxonomy](https://pubmed.ncbi.nlm.nih.gov/23512568/)
10. [Lived Informatics](https://pmc.ncbi.nlm.nih.gov/articles/PMC12435389/)

## Risks And Unknowns

- The formal vocabulary may create more cognitive burden than it removes.
- Large-language-model decomposition can invent prerequisites or false certainty.
- A technically ready action may remain emotionally or contextually unsuitable.
- The planner may overfit to the user's corrections without learning transferable playbooks.
- Capturing personal goals, behavior, evidence, and interruptions creates sensitive data.
- Enterprise vocabulary may tempt the project into premature multi-user scope.
- Product novelty must be evaluated as an end-to-end experience, not inferred from a literature gap.

## Recommendation

Treat the work as a research-informed product synthesis, not a new science and not merely another task manager.

The first evaluation should compare the personal cockpit against ordinary Codex chat plus files. Test whether it reduces orientation time, produces a more accurate actionable frontier, prevents giant-plan dumping, supports resumption, and links completion to evidence.

Do not adopt a full formal-planning ontology. Preserve only the distinctions that the dinner, moving, and software fixtures prove necessary.

## Follow-Ups

- Define a small personal ontology for goal, quality, condition, compound work, action, refinement, dependency, actor, gate, evidence, and event.
- Run a concierge evaluation of “good enough—start now” using risk, reversibility, uncertainty, and familiarity as the decomposition policy.
- Create an evaluation before making ADHD or executive-function efficacy claims.
- Keep organizational actors and authority as future compatibility notes, not first-version features.

The strongest retrieval cue is: **plan only as deeply as the current branch requires, act, observe reality, and elaborate from evidence.**
