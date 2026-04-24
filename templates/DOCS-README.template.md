# Docs

Map of the documentation system.

## Start Here

1. `<orientation/CURRENT_STATE.md>` - current truth and fanout
2. `<orientation/ONBOARDING.md>` - non-code walkthrough
3. `<orientation/ROADMAP.md>` - sequence and rationale
4. `<orientation/ARCHITECTURE.md>` - architecture and decision provenance
5. `<product/specs/>` - product or system specs
6. `<domain>/plans/` - plan folders and implementation briefs

## Top-Level Areas

| Area | Purpose |
|---|---|
| `orientation/` | Current state, onboarding, roadmap, architecture |
| `product/` | Product specs, product plans, future ideas |
| `decisions/` | ADRs, learnings, execution-readiness notes |
| `repo-health/` | Docs/workflow plans, session logs, state history, CI/test hygiene |
| `research/` | Feasibility studies, spikes, findings |
| `operations/` | Release, production, app-store, manual checks |
| `marketing/` | Strategy, launch plans, campaign outputs |

## Rules

- Keep `CURRENT_STATE.md` short and link outward.
- Put plans under the domain that owns the outcome.
- Give each meaningful plan its own folder.
- Use session logs for per-session receipts.
- Use ADRs for durable cross-plan decisions.
