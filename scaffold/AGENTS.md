# <Repo Name> - Agent Index

Short index. Read the file for your task.

## Start here

1. `<current state path>` - what is built today. Read first, always.
2. `<onboarding path>` - product/user-flow or system walkthrough.
3. `<roadmap path>` - ordered roadmap and rationale.
4. `<architecture path>` - system overview, boundaries, data flow, and decision provenance.
5. `<approved spec path>` - current approved product or technical spec.
6. `<planning guide path>` - how parent plans differ from implementation briefs.
7. `docs/product/plans/` - plan guide and examples for new plans and briefs.
8. `<session logs guide path>` - timestamped session receipts and commit-trailer convention.
9. `<surface codebase map path>` - current module map and entry points.
10. `<seams guide path>` - canonical versus compatibility seam guidance.
11. `<testing guide path>` - verification commands, limits, and manual-check references.

## By task

| Task | Read |
|---|---|
| Any code change | `docs/CURRENT_STATE.md` + relevant surface `AGENTS.md` |
| Implementing a plan | `docs/plans/README.md` + parent `plan-*` doc + relevant `impl-*` brief(s) |
| Starting a fresh implementation session | `docs/plans/reusable-implementer-handoff-prompt.md` |
| Closing a meaningful work session | `<session logs guide path>` |
| Surface codebase orientation | `docs/CURRENT_STATE.md` + codebase map + surface `AGENTS.md` |
| Model / repository seam question | `docs/CURRENT_STATE.md` + seams guide + `docs/ARCHITECTURE.md` |
| Verification / test command question | testing guide + surface `AGENTS.md` + any execution-readiness doc |
| Future feature request | `docs/IDEAS.md` + relevant `docs/<domain>/ideas/IDEA-####-<slug>.md` |

## Rules

- Never invent scope. If it is not in a spec or plan, ask.
- Update `docs/CURRENT_STATE.md` at the end of any plan or multi-task change.
- Keep `docs/CURRENT_STATE.md` short; move detailed history to state snapshots.
- Add a timestamped session log for meaningful implementation, planning, or debugging sessions.
- Use commit trailers for meaningful commits: `Plan:`, `Brief:`, `Spec:`, `ADR:`, `Session:`, `Area:`, and `Verification:` as applicable.
- Capture early, fuzzy, or future-facing thoughts as `IDEA-*` docs instead of bloating specs or plans.
- If the repo uses `docs/architecture/areas/AREA-*.md`, use those exact `AREA-*` IDs in plan frontmatter, session logs, PRs, issues, and `Area:` commit trailers.
- Planning doc hierarchy matters.
  - Parent `plan-*` docs define scope, architecture, invariants, and non-goals.
  - `impl-*` briefs define task-level execution details for one bounded task or grouped task.
  - Parent plans win on intent and boundaries.
  - Implementation briefs win on execution order and verification details.
- Do not implement from an implementation brief alone without first reading its parent plan.
- Parent plans and implementation briefs should explicitly call out dependencies and safe parallelization.
- When feedback reveals a missed rule, wrong assumption, ambiguous docs, or workflow failure, use `reflect-and-improve` and update the smallest durable source that would prevent a repeat.

## Behavioral guidelines

### Think before coding

- State assumptions explicitly.
- If multiple interpretations exist, surface them instead of choosing silently.
- Prefer the simpler approach when it still satisfies the plan.

### Simplicity first

- Minimum code that solves the problem.
- No abstractions for single-use code unless the plan requires them.
- No speculative configurability.

### Surgical changes

- Touch only what you must.
- Match local style and structure unless the task is explicitly a refactor.
- Clean up orphans created by your own work.

### Goal-driven execution

- Turn vague tasks into verifiable outcomes.
- Prefer tasks that can be tested or otherwise checked explicitly.

### Reflect and improve

- Treat corrections, contradictions, frustration signals, and missed rules as chances to improve the shared system.
- Name what happened, classify the source, update the smallest useful doc/template/check/skill, and record a session-log note when the lesson should survive the chat.

### Planning workflow

- Use the parent plan to understand intent and boundaries.
- Use `impl-*` briefs for bounded execution and delegation.
- When drafting a parent plan, make dependencies and safe parallelization explicit.
- When drafting a brief, make ownership, write-conflict notes, and verification explicit.
- New durable docs should use YAML frontmatter with status, exact local timestamps, domain, and relevant links where useful.
