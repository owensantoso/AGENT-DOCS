# Adoption Checklist

Use this when setting up this workflow in a new repository.

## Minimum setup

- Create a root `AGENTS.md`.
- Create `docs/README.md`.
- Create `docs/orientation/CURRENT_STATE.md`.
- Create `docs/orientation/ONBOARDING.md`.
- Create `docs/orientation/ROADMAP.md`.
- Create `docs/orientation/ARCHITECTURE.md`.
- Create `docs/product/specs/`.
- Create `docs/product/plans/`.
- Create `docs/repo-health/session-logs/`.
- Create `docs/decisions/adr/`.

## Strongly recommended setup

- Create a reusable implementer handoff prompt.
- Create at least one surface-level `AGENTS.md`.
- Create a codebase map for the main app or service surface.
- Create a testing guide that lists the real verification commands.
- Create a seams guide if the repo has compatibility layers or transitional models.
- Copy `scripts/docs-meta` if the repo should deterministically manage `IDEA-*`, `SPEC-*`, `PLAN-*`, `IMPL-*`, status, and docs todos.
- Create `docs/repo-health/state/` for detailed historical state snapshots.
- Create plan templates with YAML frontmatter and exact timestamp fields.

## Before using subagents heavily

- Make sure parent plans state dependencies and safe parallelization explicitly.
- Make sure implementation briefs state ownership and write-conflict notes.
- Make sure naming conventions are unambiguous.
- Make sure `CURRENT_STATE.md` is fresh enough to trust.
- Make sure session logs have exact local timestamps for meaningful actions.

## Ongoing maintenance

- Update `CURRENT_STATE.md` after milestone-sized work.
- Update plan and brief checklists together when both exist.
- Update session logs at closeout for meaningful work.
- Use commit trailers for meaningful commits.
- Keep roadmap ordering intentional.
- Move over-detailed execution notes out of parent plans and into briefs.
- Move over-detailed state history out of `CURRENT_STATE.md` and into `state/`.
- Delete or rewrite stale docs instead of letting them drift quietly.

## Smells to watch for

- every tiny task gets a brief
- parent plans read like pseudo-code
- `CURRENT_STATE.md` grows into a session journal
- no timestamped paper trail exists for AI-heavy changes
- the testing guide promises checks the repo does not actually have
- agents keep implementing from old plans that contradict the codebase
- tasks marked parallel still fight over the same files

If you see these, the docs need simplification, not more layers.
