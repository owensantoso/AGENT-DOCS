# Docs

Map of the documentation system.

## Start Here

1. `<orientation/CURRENT_STATE.md>` - current truth and fanout
2. `<orientation/ONBOARDING.md>` - non-code walkthrough
3. `<orientation/ROADMAP.md>` - sequence and rationale
4. `<orientation/ARCHITECTURE.md>` - architecture and decision provenance
5. `<architecture/README.md>` - architecture area registry and boundary map, if split out
6. `<IDEAS.md>` - global `IDEA-####` registry
7. `<SPECS.md>` - global `SPEC-####` registry
8. `<product/specs/>`, `<architecture/specs/>`, or another topic-first specs folder
9. `<domain>/plans/` - plan folders and implementation briefs

## Top-Level Areas

| Area | Purpose |
|---|---|
| `orientation/` | Current state, onboarding, roadmap, architecture |
| `architecture/` | Split architecture hub and `areas/AREA-*.md` boundary docs when one overview is too dense |
| `product/` | Product ideas, specs, and plans |
| `decisions/` | ADRs, learnings, execution-readiness notes |
| `repo-health/` | Docs/workflow plans, session logs, state history, CI/test hygiene |
| `research/` | Feasibility studies, spikes, findings |
| `operations/` | Release, production, app-store, manual checks |
| `marketing/` | Strategy, launch plans, campaign outputs |

## Rules

- Keep `CURRENT_STATE.md` short and link outward.
- Keep `IDEAS.md` as the global registry for one continuous `IDEA-####` sequence.
- Keep `SPECS.md` as the global registry for one continuous `SPEC-####` sequence.
- Store specs in topic-first folders such as `product/specs/`, `architecture/specs/`, or `repo-health/specs/`.
- Put plans under the domain that owns the outcome.
- Give each meaningful plan its own folder.
- Use session logs for per-session receipts.
- Use ADRs for durable cross-plan decisions.
- If architecture is split, make `AREA-*` IDs match `docs/architecture/areas/AREA-*.md` filenames exactly.
