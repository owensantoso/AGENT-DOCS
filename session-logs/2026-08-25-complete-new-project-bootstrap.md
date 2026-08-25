---
type: session-log
document_format_version: 2
id: 01a03500-7324-7f48-bb3c-707b1259ba75
aliases: []
title: Complete New Project Bootstrap
domain: agent-continuity
status: completed
created_at: "2026-08-25 03:20:17 JST +0900"
updated_at: "2026-08-25 03:33:59 JST +0900"
started_at: "2026-08-25 02:34:00 JST +0900"
ended_at: "2026-08-25 03:33:59 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex main agent
areas:
  - agent-continuity
  - repository-bootstrap
  - continuous-integration
related_plans:
  - 01a034e4-2791-74ab-90da-7fce88bf52a7
related_briefs: []
related_specs:
  - 01a034dd-eefc-7038-a814-ce4e28164af3
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-08-25 - Complete New Project Bootstrap

## Goal

Turn the captured bootstrap proposal into the first complete milestone: one
preview-first command that creates a new Git repository with the complete Agent
Continuity footprint, repository-local deterministic CI, a GitHub Actions
caller, truthful starter front doors, a bootstrap receipt, and an initial
commit, with optional explicit GitHub creation and push.

## Corrected Requirement

Owen explicitly corrected an agent assumption that `standard` should remain the
new-project default. `complete` is the accepted universal baseline for
`agent-continuity project new`. Lower-level `agent-continuity init` profiles
remain available for deliberate manual adoption, but the project bootstrap does
not expose a weakening profile flag.

Source classification: agent assumption, not prompt ambiguity. The correction
is now durable in the promoted spec, completed milestone plan, public docs, and
smoke coverage that asserts `profile == complete`.

## Implemented

- Added `agent-continuity project new` through a dedicated transaction module.
- Kept dry-run as the default and required `--write` for local mutation.
- Required `--github` and explicit `--visibility` together for remote mutation.
- Composed the existing complete initializer rather than duplicating scaffold
  generation.
- Added a truthful named root `README.md` and replaced the known repository-name
  placeholder in `AGENTS.md` without inventing product purpose or stack choices.
- Added `agent-continuity ci [target]` and a vendored deterministic verifier.
- Added a least-privilege GitHub Actions workflow that directly invokes the
  vendored verifier in a cold checkout.
- Recorded the verifier, its portable smoke wrapper, and workflow as
  checksummed Agent Continuity-owned manifest artifacts.
- Added local and stubbed-GitHub transaction receipts and exact remote-commit
  verification.
- Removed machine-local absolute paths from fresh manifests and bootstrap
  receipts so publishing a generated repository does not disclose the local
  directory layout. Manifest repository provenance also strips URL userinfo,
  queries, and fragments that could contain credentials.
- Kept semantic review, branch protection, stack selection, licensing, and
  project-specific tests outside this milestone.

## Verification

- Red tests first:
  - `tests/agent-continuity-ci-smoke.sh` initially failed because the verifier
    did not exist.
  - `tests/agent-continuity-project-smoke.sh` initially failed because the
    dispatcher had no `project` command.
- Focused smoke suites passed:
  - complete init and owned-artifact coverage
  - checksum, mode, link, TODO, generated-view, and Git-whitespace failures
  - dry-run non-mutation, local write, non-empty-target refusal, and portable
    receipt assertions
  - stubbed private GitHub creation after local verification, two pushes, and
    exact final `origin/main` equality
  - existing doctor/upgrade, docs, install, and compatibility coverage
- `scripts/release-check` passed after removing only the Python bytecode cache
  created by an earlier direct compile probe.
- An independent disposable cold-project proof created a clean one-commit
  `main` repository, verified five Agent Continuity-owned artifacts against the
  manifest, and passed both the dispatcher and vendored CI entry points.

## Verification Limits

- No real GitHub repository was created or pushed. The remote transaction used
  a stubbed `gh` command and local bare Git remote so ordering, visibility, push,
  receipt, and exact-commit behavior could be tested without an external write.
- The generated GitHub Actions YAML was inspected and exercised through its
  invoked local command, but no hosted Actions run exists until a real project
  is published.
- No project-specific build or product behavior exists for the bootstrap to
  test; each generated project must add its own stack-specific CI once chosen.
- The repository's unsupported whole-root structured-metadata check still
  exposes pre-existing legacy linked-path resolution debt. The supported
  release gate and repo-root link scan passed.

## Repository State

- Branch: `proposal/project-bootstrap-ci-semantic-review`
- Worktree:
  `/Users/macintoso/Documents/Codex/2026-08-25/ch/work/agent-continuity-project-bootstrap`
- Base proposal commit: `dd4036b6bbaa43a895bfc5564c7312bfa77c36cd`
- No implementation commit or remote push was created in this session.

The milestone is implemented and machine-verified in the isolated worktree.
Integration, publication, and installation remain separate human-controlled
gates.
