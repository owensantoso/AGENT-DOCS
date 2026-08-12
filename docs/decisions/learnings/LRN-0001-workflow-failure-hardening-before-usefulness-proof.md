---
type: learning
id: LRN-0001
title: Workflow Failure - Hardening Before Usefulness Proof
domain: workflow
status: active
learning_type: lesson
created_at: "2026-08-09 18:09:54 JST +0900"
updated_at: "2026-08-09 18:09:54 JST +0900"
owner: Owen
source:
  type: conversation
  link:
  notes: Independent review of Continuity Workspace history and workflow guidance after an explicit user correction.
areas: []
related_specs: []
related_plans: []
related_briefs: []
related_adrs: []
related_sessions: []
related_research: []
related_todos: []
related_questions: []
supersedes: []
superseded_by: []
linked_paths:
  - guides/doc-types-and-responsibilities.md
  - guides/workflow-overview.md
  - skills/structured-docs-workflow/SKILL.md
  - scaffold/docs/product/specs/SPEC-0000-spec-title.md
  - scaffold/docs/product/plans/PLAN-0000-plan-title/PLAN-0000-plan-title.md
  - scaffold/docs/product/plans/PLAN-0000-plan-title/IMPL-0000-00-implementation-brief-title.md
repo_state:
  based_on_commit: 9750871c50443d669e20be01e684fa8c1ce8b37b
  last_reviewed_commit: 9750871c50443d669e20be01e684fa8c1ce8b37b
---

# LRN-0001 - Workflow Failure - Hardening Before Usefulness Proof

This learning records a process failure, not an individual failure. The durable
lesson is that an eventual product roadmap must not become the prerequisite
sequence for testing whether the product is useful.

Evidence labels in this record mean:

- **Confirmed:** directly supported by repository history or current documents.
- **Inferred:** the most likely process dynamic, but not directly observable in
  the repository.
- **Proposed:** a corrective rule that still needs repeated use before it should
  become tooling or schema.

## Intended Decision

The first decision was narrow:

> Is a local browser reader over one real Agent Continuity project useful enough
> that Owen would choose to use it again?

The shortest valid evidence was one end-to-end path:

```text
explicit local project
  -> discover real Markdown
  -> show a document list
  -> select and render one document
  -> let Owen use it and decide keep, change, or stop
```

The first implementation did not need to prove the eventual product's complete
query model, distribution boundary, browser matrix, or adversarial hardening.

## Observed Failure

**Confirmed:** the workflow turned the usefulness question into a seven-pull-
request horizontal plan. The functional React reader was scheduled only after
workspace contracts, a source adapter, a loopback companion, a query engine,
and an integration API converged. The first implemented pull request explicitly
produced a placeholder and stated that it was not a usable viewer.

The browser-platform correction then added a production-shaped loopback threat
model before the reader had displayed a real document. Requirements included a
one-time bootstrap capability, a separate in-memory session capability, exact
Host and Origin checks, redirect rejection, storage and history audits, Content
Security Policy tests, log sentinels, hostile filenames, symlink replacement,
two browser engines, and percentile benchmarks.

The resulting sequence was architecture-first rather than evidence-first:

```text
actual sequence
  docs packet -> contracts -> horizontal foundations -> integration -> UI -> user test

needed sequence
  smallest safe vertical reader -> user test -> observed needs -> selective hardening
```

## Evidence And Cost

### Confirmed timeline

The affected repository was `continuity-workspace`.

| Commit | Confirmed change | Process implication |
|---|---|---|
| `9a0225e` | Defined a viewer-first charter whose success checks included locating a known document and choosing to reopen the product. | The original decision was behavioral usefulness. |
| `2c92c1b` | Paused application work and added an implementation-grade spec, plan, dependency map, and seven implementation briefs. | Missing planning artifacts became gates before learning. |
| `b1796db` | Corrected an agent-inferred native platform to React plus a local companion and rewrote the planning packet. | A wrong platform assumption made the pre-code packet expensive to replace. |
| `69fa6c1` | Added the workspace, placeholder UI, model contracts, boundary checks, fixtures, and verification harness. | The first implementation still could not read a project document. |
| `3711b98` | Closed the PR 1 paper trail while recording that no adapter, server, or query engine existed. | Completion evidence was precise, but it proved foundation quality rather than product usefulness. |

Relevant affected-repository sources included:

- `docs/CHARTER.md`
- `docs/product/specs/SPEC-0001-local-project-viewer-slice.md`
- `docs/product/plans/PLAN-0001-local-project-viewer-foundation/PLAN-0001-local-project-viewer-foundation.md`
- `docs/product/plans/PLAN-0001-local-project-viewer-foundation/IMPL-0001-01-react-workspace-and-snapshot-contract.md`
- `docs/product/plans/PLAN-0001-local-project-viewer-foundation/IMPL-0001-03-loopback-companion-and-project-access.md`
- `docs/session-logs/2026-08-09-local-project-viewer-planning-packet.md`
- `docs/session-logs/2026-08-09-web-first-platform-correction.md`
- `docs/session-logs/2026-08-09-react-workspace-and-snapshot-contract.md`

### Confirmed repository cost

The review measured repository changes with `git show --stat` and
`git show --numstat`:

- The initial planning packet added 1,531 lines across 20 documentation files.
- The React recast added 1,308 lines and removed 818 across 31 files.
- PR 1 added 4,639 lines, including a 2,562-line lockfile.
- A rough path-based grouping of the remaining PR 1 additions found 560
  production/model lines, 753 test/fixture lines, 646 tooling lines, and 118
  documentation lines.
- The visible React application remained a 14-line placeholder.
- The custom import-boundary implementation and its tests totaled 701 lines.
- PR 1 closed with 45 Vitest tests and Chromium/WebKit placeholder smoke tests,
  while reading zero real project documents.

These numbers do not show that the checks were intrinsically wrong. They show
that their timing and density were disproportionate to the unresolved product
decision. Exact historical token consumption was not available from Git and is
therefore not claimed here.

## Causal Factors

| Source | Classification | Contribution |
|---|---|---|
| "Scaffold everything needed," "do we have enough documentation," and "should each slice be a separate PR?" | Prompt ambiguity, moderate | Justified some planning and reviewable seams, but did not require postponing the first reader until PR 6. |
| Native macOS selection before confirmation | Agent assumption, confirmed | Fused local source authority with the presentation platform and forced a large rewrite. |
| "First useful version" treated as the first implementation milestone | Agent framing, major | Collapsed feasibility, usefulness POC, personal MVP, and production hardening into one acceptance surface. |
| Horizontal package and PR decomposition | Architecture/planning incentive, major | Optimized independent ownership and parallel worktrees while leaving no early end-to-end user value. |
| `IDEA -> SPEC -> PLAN -> IMPL` treated as a pipeline | Docs/template incentive, major | Turned the earliest missing artifact into a prerequisite even though Agent Continuity describes the stack as a menu. |
| Specs and briefs requested edge behavior, risks, review focus, and validation without a delivery stage | Template gap, major | Gave every plausible future concern equal standing with the happy-path experiment. |
| Approved specs and plans win during implementation | Execution incentive, major amplifier | Once the contract grew, implementers and reviewers were correct locally to satisfy it, even though the stage was wrong globally. |
| Separate spec and code-quality gates with repair/re-review loops | Orchestration/review incentive, amplifier | Rewarded finding additional edge cases without a countervailing scope or information-value budget. |
| No first-test date, token/time ceiling, or maximum number of invisible PRs | Missing stopping rule, primary | Nothing forced the workflow to close the real-source-to-browser loop early. |
| No ordinary "deferred risk with trigger" state | Risk-model gap, primary | A concern was either accepted as a requirement or omitted, encouraging defensive inclusion. |

**Inferred:** the long-horizon product and architecture discussion made the
eventual system unusually salient. The workflow then optimized for coherence of
that system rather than information gain from the next reversible experiment.

## Stage Model

Use the smallest stage that can answer the next decision. Time is the primary
budget because it is observable; token ceilings are secondary where the runtime
reports them.

| Stage | Decision | Exit criterion | Default cap | Agent/review shape |
|---|---|---|---|---|
| Feasibility spike | Can the path work at all? | One real repository is scanned and one real document is rendered, or one concrete blocker is identified. | 45-90 minutes or about 10-15k observable tokens, whichever comes first. | Main agent only; no independent review. |
| Usefulness POC | Does the interaction help the first user? | One command opens the chosen project; the user browses and reads two or three known documents and chooses keep, change, or stop. | 2-4 hours or about 40-50k total observable tokens; stop after two implementation cycles. | Main plus at most one implementer; one bounded smoke review after the loop works. |
| Personal MVP | Is it useful and reliable enough for repeated personal use? | Several real uses identify which search, relationship, provenance, refresh, and recovery behavior actually matters. | One user-visible day or about 25k tokens per vertical increment. | At most two disjoint workers and one combined review per vertical pull request. |
| Hardening or distribution | Is it safe for persistent, wider, or external exposure? | A separately approved threat model, compatibility target, and operational acceptance suite pass. | Estimate and approve separately from the POC/MVP. | Deliberate orchestration and independent security/performance review are justified here. |

Stopping rules:

- No more than one non-user-visible foundation change may precede a human-
  testable vertical slice.
- If a POC has not reached manual testing after two implementation cycles or
  four hours, stop and simplify.
- If review findings would expand the current-stage workload by more than 25%,
  request a scope decision instead of absorbing them silently.
- Once the first end-to-end path works, pause for human use before adding the
  next subsystem.
- Do not materialize implementation briefs for deferred hardening until its
  revisit trigger fires.

## Current Corrective Action

**Proposed and authorized, not yet proven complete at the time of this record:**

- Keep the completed PR 1 foundation rather than spending more work removing
  already-passing infrastructure.
- Insert one early vertical document-reader POC before the original PRs 2-7.
- Accept one explicit project path.
- Discover root `README.md`, root `AGENTS.md`, and `docs/**/*.md`.
- Parse only enough frontmatter and Markdown to list, select, and render real
  documents.
- Bind the local server to `127.0.0.1`, keep source access read-only, disable raw
  HTML and automatic remote resources, and omit source-opening subprocesses.
- Verify one focused fixture, one browser flow, and one manual read against the
  real project.
- Freeze search ranking, Git history, current-context projection, backlinks,
  persistent registration, session-capability exchange, hostile-filename and
  symlink-race matrices, multi-browser acceptance, and percentile benchmarking
  until the POC produces user evidence.

The corrective action is complete only when the user can try the reader. A
parser test, compiled placeholder, or architecture review is not equivalent.

## Risk-Based Verification Rule

Rate each discovered concern from 1 to 4 on:

- **Impact:** nuisance to irreversible/public/credential harm.
- **Likelihood:** contrived to expected in current-stage use.
- **Exposure:** one trusted explicit invocation to internet or multi-user use.
- **Irreversibility:** restart/delete-branch recovery to unrecoverable loss or
  disclosure.

Use:

```text
priority = impact x likelihood x max(exposure, irreversibility)
```

Apply it proportionally:

- `32-64`: mitigate before the current test.
- `16-31`: mitigate now only when required for the current path or cheap enough
  to consume no more than about 10-15% of the stage budget; otherwise defer.
- below `16`: normally defer unless the safeguard is nearly free.
- Regardless of score, block destructive source writes, credential leakage,
  public/external writes, non-loopback exposure, and irreversible migrations.

Record deferred concerns in one owning plan or brief table:

| Risk | Current-stage rationale | Score | Deferred until | Revisit trigger |
|---|---|---:|---|---|

A deferred risk is acknowledged evidence, not unfinished current-stage work. A
review may add a row; it may not silently promote the row into acceptance scope.

## Prevention And Recurrence Checks

Before approving a spec or plan for a new product path, answer:

1. What decision is this stage trying to make?
2. What is the earliest real user-visible test?
3. After which pull request or elapsed-time budget can the user try it?
4. Is more than one non-user-visible foundation slice ahead of that test?
5. Which safeguards are mandatory now, and which risks are explicitly deferred?
6. What budget or failed-cycle count forces simplification?
7. Will review findings be classified as **must fix now**, **defer with
   trigger**, or **outside this stage**?

If the user asks "when can I try it?" and the answer is not already prominent
in the plan, treat that as a workflow defect and correct the sequence before
continuing.

## Proposed Exact Skill And Template Changes

These are proposed reusable changes, not requirements to implement inside this
learning-record change.

### Planning router

Add this route to `planning/SKILL.md`:

> "Try it," "POC," "spike," "ASAP," or "validate usefulness" -> smallest
> reversible end-to-end experiment. Use one short plan or implementation brief;
> do not require the full artifact chain unless a hard-to-reverse decision is
> unavoidable.

Qualify its earliest-artifact rule:

> The earliest missing artifact is subordinate to the earliest falsifiable user
> outcome. Known intent is sufficient for a reversible POC; missing durable
> documents must not become implementation gates.

### Spec writer

Add:

> Before expanding requirements, state the delivery stage, decision to prove,
> first human test, and budget/stop condition. At feasibility or POC stage,
> specify the primary path and only likely or load-bearing failures. Put other
> edge cases in Deferred Risks rather than acceptance criteria.

### Spec-to-plan writer

Add before architecture decomposition:

> Draft the earliest end-to-end user-visible slice first. If more than one non-
> user-visible task or pull request precedes it, regroup vertically or tell the
> user exactly when testing becomes possible and obtain explicit approval.
> Every plan names its First Human Test and Budget/Stop Rule.

### Plan-to-implementation workflow

Add:

> Revalidate the delivery stage and first human test before executing an
> approved brief. A later user correction toward speed or usefulness supersedes
> earlier completeness assumptions. Amend a horizontal sequence with a vertical
> proof instead of blindly executing the next foundation brief.

### Orchestrated implementation

Add:

> POC default: main agent or one implementer. Do not automatically commission
> separate spec and code reviewers. After the end-to-end behavior works, run one
> bounded combined review. Classify findings as Must fix now, Deferred with
> trigger, or Outside this stage. Only Must fix now findings cause a repair and
> re-review loop.

### Deliberate orchestration

Its existing proportionality rule is sound. Add only:

> Judge breadth by the current-stage decision, not the eventual product vision.
> A one-user reversible POC remains small even when the future product is broad.

### Verification before completion

Preserve evidence before claims, but clarify:

> Full verification means complete evidence for the exact stage-scoped claim,
> not every check in the eventual product specification. A POC may be complete
> as a POC after its focused end-to-end smoke and explicit limitation statement;
> it must not be called an MVP or production-ready.

Before delegation, verify only the preconditions being claimed; do not run the
eventual completion suite merely because work is moving to another agent.

### Agent Continuity templates

Without adding a new document type or schema field, add these small sections to
the plan template:

- Delivery Stage
- Decision To Prove
- First Human Test
- Budget And Stop Rule
- Deferred Risks

Add this to the implementation-brief template:

> Do not create briefs for deferred hardening until its trigger fires. A POC
> brief should normally own one complete user-visible path.

Do not add a linter for these sections on the first example. First prove that
the prose convention changes actual planning behavior.

## Revisit Trigger

Use `LRN-*` with `domain: workflow` for systematic workflow failures for now.
Do not invent `FAIL-*` or `INC-*` on one example.

Reconsider a dedicated failure or incident family only after at least three
independent workflow-failure learning records exist across at least two affected
repositories, and those records reveal repeated lifecycle needs that `LRN-*`
cannot express cleanly, such as severity, incident state, recurrence count,
time-to-detection, or remediation ownership.

Until that trigger fires, aggregation comes from the existing generated learning
registry and the queryable `domain: workflow` metadata.

The strongest prevention rule is: **prove the smallest useful vertical loop
before hardening the architecture that might eventually deliver it.**
