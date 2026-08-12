# 2026-08-06 Agent Continuity structured-doc command

## Goal

Replace the incomplete public `docs-meta` naming with the canonical Agent
Continuity command while preserving existing project compatibility.

## Correction

The installed skill documentation still presented `scripts/docs-meta` as the
workflow name even after the product and primary installer had become Agent
Continuity. The corrected rule is that new users see `agent-continuity`; old
spellings survive only at compatibility boundaries.

## Status

Completed under PLAN-0011.

## Result

- New installs expose `agent-continuity`, `agent-continuity init`, and
  `agent-continuity docs` as the canonical command surfaces.
- Fresh project state uses `.agent-continuity/manifest.json`,
  `agent-continuity-owned`, `agent-continuity-docs`, and canonically named
  repo-local scripts and tests.
- `agent-docs`, `agent-docs-init`, `scripts/docs-meta`, `--docs-meta`, old
  manifests, old ownership values, and old generated markers remain accepted
  only as compatibility inputs for existing adopters.
- The source topic directory formerly named `docs-meta/` is now
  `agent-continuity/`.
- Current guides, scaffold templates, skills, examples, diagnostics, and
  generated markers use Agent Continuity naming.
- The local source checkout is now `Documents/VSCode/agent-continuity`; the old
  `Documents/VSCode/AGENT-DOCS` path is a compatibility symlink.
- The installed scaffold skill is now `agent-continuity-scaffold`, with a
  narrow `agent-docs-scaffold` compatibility skill. `project-docs-init` now
  points at the canonical source and commands.

## Verification

- `tests/install-smoke.sh`
- `tests/agent-continuity-init-smoke.sh`
- `tests/agent-continuity-doctor-upgrade-smoke.sh`
- `tests/agent-continuity-docs-smoke.sh`
- `tests/changelog-check-smoke.sh`
- `scripts/agent-continuity docs --root plans check`
- `scripts/agent-continuity docs --root plans check-links`
- `scripts/agent-continuity docs --root . check-links --json`
- `git diff --check`
- `scripts/release-check` (passed)
- Fresh expanded-project audit found no legacy adopter-visible paths, Markdown
  guidance, manifest components, ownership values, or file records.
- Skill validation passed for `agent-continuity-scaffold`, the legacy alias,
  and `project-docs-init`.
