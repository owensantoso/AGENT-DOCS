# Adoption Checklist

Use this when setting up this workflow in a new repository.

For exact copy commands and a pasteable handoff prompt, start with [../INSTALL.md](../INSTALL.md). This checklist is the readiness test after the scaffold has been copied and adapted.

## Copy steps

- Set `AGENT_DOCS=/path/to/AGENT-DOCS` in the target repo shell.
- Copy `scaffold/AGENTS.md` to the target repo root, merging if one already exists.
- Copy `scaffold/docs/` into the target repo's `docs/` folder.
- Optionally copy `scripts/docs-meta` and `tests/docs-meta-smoke.sh`.
- Optionally copy `scaffold/agent-instructions/` into a repo-health or team instructions folder.
- Do not copy `scaffold/README.md` over the target repo's root README.
- Delete or rewrite example `0000` files before treating the docs as target-repo truth.

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
- Make sure agents know to use `reflect-and-improve` when feedback reveals a wrong assumption, ambiguous docs, missed rule, or tooling gap.

## Ongoing maintenance

- Update `CURRENT_STATE.md` after milestone-sized work.
- Update plan and brief checklists together when both exist.
- Update session logs at closeout for meaningful work.
- Use commit trailers for meaningful commits.
- Use `scripts/docs-meta move ... --dry-run` before moving or renaming docs when the repo has `docs-meta`.
- Run `scripts/docs-meta check-links` after docs layout changes.
- Run `scripts/docs-meta check-todos` when the repo uses structured `TODO-*` items for durable work.
- Keep roadmap ordering intentional.
- Move over-detailed execution notes out of parent plans and into briefs.
- Move over-detailed state history out of `CURRENT_STATE.md` and into `state/`.
- Delete or rewrite stale docs instead of letting them drift quietly.
- Treat corrections as blameless system feedback: clarify the workflow, update the smallest durable doc or check, and log the lesson when it should survive the chat.

## Smells to watch for

- every tiny task gets a brief
- parent plans read like pseudo-code
- `CURRENT_STATE.md` grows into a session journal
- no timestamped paper trail exists for AI-heavy changes
- the testing guide promises checks the repo does not actually have
- agents keep implementing from old plans that contradict the codebase
- tasks marked parallel still fight over the same files
- durable cross-session work is tracked only by line-number checkboxes instead of stable `TODO-*` IDs
- the same correction appears in chat more than once but never becomes a doc, template, check, or skill update

If you see these, the docs need simplification, not more layers.
