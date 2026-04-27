# Agent Docs Workflow

AGENT-DOCS gives AI-assisted repos a durable operating memory, so each new human or agent can see what is true now, what has been decided, what evidence exists, and what work is safe to do next without rereading old chat history.

It solves the failure mode where project knowledge exists, but is scattered across stale chats, ad hoc notes, oversized plans, and hand-maintained indexes. The differentiator is the split between source-of-truth docs, generated views, and bounded execution handoffs.

This is a **scalable workflow**, not a requirement to install every folder and doc type on day one. Start with the smallest shape that prevents confusion, then add structure only when the absence of structure is costing you comprehension.

## Quick Start

From the repo you want to document, install or update the CLI and immediately run the init flow:

```bash
curl -fsSL https://raw.githubusercontent.com/owensantoso/AGENT-DOCS/main/install.sh | bash
```

The curl installer installs `agent-docs-init` and runs it once in write mode by default. Use `bash -s -- --dry-run` to preview instead. The interactive CLI asks where to install, explains the project-size profiles, and previews the tree. Use `small` when unsure. Existing target files are listed first, and write mode refuses to overwrite them unless you pass `--force`.

Install or update the CLI without running init:

```bash
curl -fsSL https://raw.githubusercontent.com/owensantoso/AGENT-DOCS/main/install.sh | bash -s -- --no-run
```

If you are installing from a private fork, authenticate with GitHub CLI and use an authenticated raw request:

```bash
gh auth login
gh auth setup-git
curl -H "Authorization: Bearer $(gh auth token)" -fsSL https://raw.githubusercontent.com/OWNER/AGENT-DOCS/main/install.sh | AGENT_DOCS_REPO_URL=https://github.com/OWNER/AGENT-DOCS.git bash
```

Non-interactive examples:

```bash
agent-docs-init --profile small --dry-run
agent-docs-init --profile small --write
agent-docs-init /path/to/project --profile full --write
```

## Why This Exists

Agent-driven projects usually do not fail because nobody wrote notes. They fail because the next session cannot tell which note is canonical, which plan is current, which decision still applies, or which evidence is safe to trust.

| Common Failure | AGENT-DOCS Answer |
|---|---|
| Current reality is inferred from code and stale chat | `CURRENT_STATE.md` is the first truth page |
| Ideas, specs, plans, and decisions blur together | Each doc type has one job and one owner of truth |
| Agents guess the next ID or hand-edit registries | `docs-meta` derives IDs and generated views from source docs |
| Bug evidence disappears into pasted logs | `DIAG-*` records preserve sanitized run evidence |
| Research, benchmarks, and decisions get mixed | `RSCH-*`, `EVAL-*`, and `ADR-*` stay separate |
| Plans become too large to hand off safely | `PLAN-*` owns scope; `IMPL-*` owns bounded execution |

The point is not the folder tree. The point is making repo memory resumable: source docs hold truth, generated views handle bookkeeping, and implementation briefs tell agents exactly what work is safe to do next.

## Start Here

| Need | Go To |
|---|---|
| Install this workflow in another repo | [INSTALL.md](INSTALL.md) |
| Understand the whole workflow in one pass | [guides/workflow-overview.md](guides/workflow-overview.md) |
| Decide which document type owns what | [guides/doc-types-and-responsibilities.md](guides/doc-types-and-responsibilities.md) |
| Run a scoped audit | [guides/audits/README.md](guides/audits/README.md) |
| Learn how agents split and integrate work | [guides/subagent-execution-loop.md](guides/subagent-execution-loop.md) |
| Follow an adoption checklist | [guides/adoption-checklist.md](guides/adoption-checklist.md) |
| Use the workflow as a Codex skill | [skills/structured-docs-workflow/SKILL.md](skills/structured-docs-workflow/SKILL.md) |
| Plan upstream AGENT-DOCS improvements | [plans/README.md](plans/README.md) |
| Explore the SQLite docs-index concept | [concepts/CONC-0001-read-only-sqlite-docs-index.md](concepts/CONC-0001-read-only-sqlite-docs-index.md) |
| Explore future doctor/upgrade safety | [concepts/CONC-0002-agent-docs-doctor-and-upgrade.md](concepts/CONC-0002-agent-docs-doctor-and-upgrade.md) |
| Explore open-loop review cadence | [concepts/CONC-0003-open-loop-review-cadence.md](concepts/CONC-0003-open-loop-review-cadence.md) |

## Choose A Size

AGENT-DOCS has one full scaffold today: [scaffold/](scaffold/). You do not need to copy all of it. For small projects, copy a subset and grow toward the full tree only when the project earns it.

| Profile | Use When | Recommended Shape |
|---|---|---|
| Tiny | prototype, script, single-person experiment | `AGENTS.md`, `docs/CURRENT_STATE.md`, `docs/ARCHITECTURE.md` |
| Small / MVP | real app with a few features and occasional agents | flat `docs/`, simple `plans/`, optional `ADR` and `DIAG` |
| Growing | multiple surfaces, recurring bugs, decisions, or handoffs | topic folders, `SPEC`, `PLAN`, `IMPL`, `ADR`, `DIAG`, session logs |
| Full | long-lived repo with many agents, plans, domains, and generated views | copy/adapt [scaffold/](scaffold/) plus `scripts/docs-meta` |

### Minimal Shapes

For a tiny repo:

```text
AGENTS.md
docs/
  CURRENT_STATE.md
  ARCHITECTURE.md
```

For a small product or MVP:

```text
AGENTS.md
docs/
  README.md
  CURRENT_STATE.md
  ARCHITECTURE.md
  ROADMAP.md
  plans/
  decisions/
  session-logs/
```

For a full AGENT-DOCS-style repo, use [scaffold/](scaffold/) as the source tree and delete what is irrelevant.

## Install

Use the installed command when you want the CLI to explain profiles, show the structure preview, and copy the selected scaffold. If you omit the target path, it uses the current directory in non-interactive mode and asks about the current directory in interactive mode:

```bash
agent-docs-init
```

The installer is idempotent around existing project files: it may create missing docs inside an existing `docs/` folder, but it lists exact file conflicts and refuses to overwrite those files in write mode unless `--force` is explicitly provided.

Non-interactive examples:

```bash
agent-docs-init --profile small --dry-run
agent-docs-init --profile small --write
agent-docs-init /path/to/project --profile small --dry-run
agent-docs-init /path/to/project --profile small --docs-meta yes --write
agent-docs-init /path/to/project --profile full --write
```

If you have cloned this repo and want to run the script directly during development, use `scripts/agent-docs-init` from the repo root.

`tiny` and `small` synthesize smaller files, including a simpler `ARCHITECTURE.md`. `growing` and `full` copy selected files from the full scaffold. This keeps small-project docs lighter without duplicating the whole scaffold tree.

Manual install still works if you want the full scaffold plus deterministic metadata tooling:

```bash
AGENT_DOCS=/path/to/AGENT-DOCS
cp "$AGENT_DOCS/scaffold/AGENTS.md" ./AGENTS.md
mkdir -p docs
rsync -av "$AGENT_DOCS/scaffold/docs/" ./docs/
mkdir -p scripts tests
cp "$AGENT_DOCS/scripts/docs-meta" ./scripts/docs-meta
cp "$AGENT_DOCS/tests/docs-meta-smoke.sh" ./tests/docs-meta-smoke.sh
chmod +x ./scripts/docs-meta ./tests/docs-meta-smoke.sh
```

Then adapt placeholders, delete irrelevant examples, and make `AGENTS.md` plus the current-state doc truthful for that repo.

Reusable global and surface-level agent instructions live under [scaffold/agent-instructions/](scaffold/agent-instructions/). These are reusable `AGENTS.md` templates, not Codex `SKILL.md` skills. Repo-local skills live under [skills/](skills/), while [scaffold/skills/](scaffold/skills/) contains copies intended for target repos.

## Workflow

The docs are the source of truth. GitHub issues, PRs, branches, and chat history are useful tracking surfaces, but durable intent and evidence should land in the docs.

```mermaid
flowchart TD
  Chat["Conversation / observation"] --> Size["Choose smallest useful shape"]
  Size --> Current["CURRENT_STATE: what is true now"]
  Size --> Idea["IDEA: possible future work"]
  Size --> Diag["DIAG: one real failure or slow run"]
  Size --> Research["RSCH: option landscape"]

  Idea --> Spec["SPEC: desired behavior"]
  Research -. informs .-> Eval["EVAL: repeatable comparison"]
  Research -. informs .-> Spec
  Diag -. evidence .-> Spec
  Diag -. evidence .-> Plan["PLAN: implementation boundaries"]
  Eval -. evidence .-> Adr["ADR: durable decision"]
  Spec --> Plan
  Adr --> Plan
  Plan --> Impl["IMPL: bounded execution brief"]
  Impl --> Session["Session log: work receipt"]
  Session --> Learn["LRN: durable lesson"]
```

Read this as a menu, not a required pipeline. A small bug may go straight from chat to code plus a session log. A risky model choice may need research, evaluation, ADR, and a plan.

## Document Types

Use the smallest durable doc that answers the actual question.

| Prefix | Type | Owns | Use When |
|---|---|---|---|
| `IDEA` | Idea | raw future possibility | A thought is worth keeping but not ready for requirements |
| `CONC` | Concept | domain model, naming, taxonomy | The team is confused about language or source of truth |
| `RSCH` | Research survey | sourced option landscape | You need to know what options exist |
| `EVAL` | Evaluation | repeatable fixtures, metrics, thresholds | You need evidence about which approach works better |
| `DIAG` | Diagnostic record | one real run, crash, freeze, slow flow | Debug evidence should outlive chat or pasted logs |
| `SPEC` | Spec | desired behavior and requirements | Implementation needs shared language and acceptance criteria |
| `ADR` | Architecture decision | durable decision and rejected alternatives | Future plans should honor the choice |
| `PLAN` | Parent plan | implementation scope, sequencing, boundaries | Work has multiple steps, risks, or handoff needs |
| `IMPL` | Implementation brief | bounded execution task | A plan needs delegation, resumability, or a focused handoff |
| `AREA` | Architecture area | boundary, owner, interface vocabulary | A subsystem needs stable references across work |
| `QST` | Question | unresolved uncertainty with status | A question needs ownership, evidence, or resolution history |
| `LRN` | Learning | lesson that should change future behavior | A correction or discovery should survive the chat |
| `EXPL` | Explainer | human-facing explanation or mental model | A concept needs teaching, diagrams, or reusable explanation |
| Session log | Receipt | what happened in a meaningful session | Future readers need timeline, verification, and decisions |
| Audit | Repo-health check | docs/tooling/codebase workflow health | The repo needs periodic drift or hygiene review |

## Folder Model

Use a topic-first docs hierarchy. The top-level folder should describe the kind of work or knowledge, and artifact folders like `plans/` should live under the topic that owns them.

| Area | Owns | Typical Contents |
|---|---|---|
| `orientation/` | first-contact truth and walkthroughs | `CURRENT_STATE`, onboarding, roadmap, architecture, explainers |
| `architecture/` | split architecture boundaries | `AREA-*` docs and architecture hub |
| `product/` | user-facing behavior and product-enabling architecture | ideas, concepts, specs, plans, implementation briefs |
| `decisions/` | durable reasoning | ADRs, learnings, questions, execution readiness |
| `repo-health/` | project machinery | docs workflow, audits, session logs, state, testing, generated facts |
| `research/` | uncertainty and sourced investigation | research surveys, notes, source comparisons |
| `operations/` | running and shipping | release checklists, deployment notes, incident recovery |
| `marketing/` | launch and growth | positioning, campaign plans, audience research |

The useful question is:

> Who needs to care about this later?

If two categories are not competing for space yet, do not split them just to match the full scaffold.

## Full Structure

The full scaffold is shaped like this:

```text
docs/
  README.md
  IDEAS.md
  CONCEPTS.md
  SPECS.md
  orientation/
  architecture/
    areas/
  product/
    ideas/
    concepts/
    specs/
    plans/
  decisions/
    adr/
    learnings/
    questions/
  repo-health/
    audits/
    debugging/
    evaluations/
    session-logs/
    state/
  research/
  operations/
  marketing/
AGENTS.md
<surface>/AGENTS.md
```

The important rule is topic first, artifact type second. A plan lives under the domain that owns the outcome.

## Scaffold Map

The [scaffold/](scaffold/) folder is shaped like the docs tree it creates. Copy the parts you need instead of translating a flat template list into paths by hand.

| Scaffold Area | Includes |
|---|---|
| [scaffold/AGENTS.md](scaffold/AGENTS.md) | root agent index and repo rules |
| [scaffold/agent-instructions/](scaffold/agent-instructions/) | reusable global and surface `AGENTS.md` templates |
| [guides/audits/](guides/audits/) | reusable repo-agnostic audit-kind guides, copied into full-profile repos under `docs/repo-health/audits/guides/` |
| [scaffold/docs/README.md](scaffold/docs/README.md) | target repo docs map and doc-type workflow diagram |
| [scaffold/docs/orientation/](scaffold/docs/orientation/) | current state, onboarding, roadmap, architecture |
| [scaffold/docs/architecture/](scaffold/docs/architecture/) | architecture hub and `AREA-*` example |
| [scaffold/docs/product/](scaffold/docs/product/) | ideas, concepts, specs, plans, implementation briefs |
| [scaffold/docs/decisions/](scaffold/docs/decisions/) | ADRs, learnings, durable questions |
| [scaffold/docs/repo-health/](scaffold/docs/repo-health/) | audits, diagnostics, evaluations, session logs, testing, state |
| [scaffold/docs/research/](scaffold/docs/research/) | `RSCH-*` convention and research notes |
| [scaffold/docs/operations/](scaffold/docs/operations/) | release and operational checklists |
| [scaffold/docs/marketing/](scaffold/docs/marketing/) | launch and campaign planning |
| [scripts/agent-docs-init](scripts/agent-docs-init) | interactive selected scaffold installer |
| [scripts/docs-meta](scripts/docs-meta) | deterministic docs metadata CLI |

## Docs Meta

When installed in a repo, [scripts/docs-meta](scripts/docs-meta) scans Markdown filenames and frontmatter as the source of truth, then creates generated views from that state.

This exists because agents are good at synthesis but unreliable at bookkeeping. They can forget the next ID, miss a stale status, or hand-edit a registry that no longer matches the repo. `docs-meta` moves that work into a small script.

| Need | Command |
|---|---|
| Create a doc | `scripts/docs-meta new <family> "<title>" --domain <domain>` |
| Find next ID | `scripts/docs-meta next <family>` |
| Update generated views | `scripts/docs-meta update` |
| Validate metadata and generated views | `scripts/docs-meta check` |
| Validate structured todos | `scripts/docs-meta check-todos` |
| Inspect links | `scripts/docs-meta links`, `check-links`, `backlinks`, `orphans` |
| Move docs safely | `scripts/docs-meta move OLD NEW --dry-run` |
| Check freshness | `scripts/docs-meta health --write` |

Supported stable-ID families include `IDEA`, `RSCH`, `EVAL`, `DIAG`, `CONC`, `SPEC`, `PLAN`, `IMPL`, `ADR`, `LRN`, `EXPL`, `QST`, and `TODO`.

Generated files such as `IDEAS.md`, `CONCEPTS.md`, `SPECS.md`, `DOCS-REGISTRY.md`, `TODOS.md`, `AREAS.md`, `AUDITS.md`, `ROADMAP-VIEW.md`, and `HEALTH.md` are views, not separate state. Fix the source docs, then regenerate.

Read [scripts/README.md](scripts/README.md) for the command reference and adoption notes.

## What To Reuse

The most reusable idea in this workflow is not the exact folder tree. It is the separation of jobs.

| Job | Reusable Pattern |
|---|---|
| Current reality | keep a short current-state page |
| Product direction | separate specs and roadmap from implementation plans |
| Execution | use parent plans for scope and implementation briefs for bounded handoff |
| Evidence | keep research, evaluation, and diagnostic evidence separate from decisions |
| Decisions | use ADRs for durable choices future plans must honor |
| Memory | use session logs for receipts and learnings for behavior-changing lessons |
| Teaching | use explainers when humans need durable mental models or diagrams |
| Uncertainty | use questions when unresolved uncertainty needs ownership or history |

Start small, then add structure only when the absence of structure is costing you comprehension.
