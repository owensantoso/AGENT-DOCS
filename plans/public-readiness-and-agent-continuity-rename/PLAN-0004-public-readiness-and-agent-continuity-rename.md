---
type: plan
id: PLAN-0004
title: Public Readiness And Agent Continuity Rename
domain: repo-health
status: completed
created_at: "2026-05-02 02:13:08 JST +0900"
updated_at: "2026-05-02 09:17:43 JST +0900"
planned_execution_start:
planned_execution_end:
actual_execution_start: "2026-05-02 02:13:08 JST +0900"
actual_execution_end: "2026-05-02 09:17:43 JST +0900"
owner: codex
sequence:
  roadmap:
  sort_key:
  lane: repo-health
  after:
    - PLAN-0003
  before: []
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
related_specs:
  - SPEC-0003
related_concepts:
  - CONC-0002
related_adrs: []
related_sessions:
  - session-logs/2026-05-02-plan-0004-public-readiness.md
  - session-logs/2026-05-02-plan-0004-closeout.md
related_issues: []
related_prs: []
repo_state:
  based_on_commit: 7b540a5b90f7f318f80d5e0e2dc66ae90afea269
  last_reviewed_commit: 639228d728c5a36e179c829cb661504af53be09b
---

# PLAN-0004 - Public Readiness And Agent Continuity Rename

**Goal:** Prepare AGENT-DOCS for safe public sharing and a possible rename to
Agent Continuity without losing the current repo's history, safety posture, or
installability.

**Architecture:** Harden the existing repo in place first. Treat rename,
release, and Homebrew/package work as later publication steps after the repo is
clean, CI-backed, and safer for first-time users. Keep AGENT-DOCS-owned tooling
separate from project-owned Markdown in any updater or installer behavior.

**Tech Stack:** Bash installer, Python scripts (`agent-docs-init`, `docs-meta`),
Markdown scaffold, smoke tests, GitHub Actions, GitHub repository settings, and
future changelog/manifest tooling from SPEC-0003.

**Source Spec:** [SPEC-0003 - AGENT-DOCS Versioning And Safe Upgrade](../agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md)

**Closeout:** Completed for the public-readiness hardening scope at commit
`639228d`. Rename, tagged release packaging, and Homebrew distribution remain
explicitly deferred publication work, not unfinished PLAN-0004 implementation.

---

## Prerequisites

- Decide that personal GitHub attribution under the current owner is acceptable,
  or rewrite history before any public announcement.
- Commit or explicitly drop the current `SPEC-0003` and `CONC-0002` edits before
  implementation begins.
- Keep the initial hardening pass in the existing repository. Do not create a new
  public repo until the current repo is clean and reviewed.
- Treat `Agent Continuity` as a working product name, not a committed rename,
  until public-readiness blockers are fixed.

## Why Now

- The project has outgrown the narrow "agent docs" framing and is becoming a
  repo-native operating memory/workflow layer for AI-assisted software projects.
- A public repo or package install flow will expose safety issues that were
  acceptable during private/local use.
- Existing installer and docs behavior is close enough to useful that hardening
  the current repo is cheaper than starting over.
- The versioning/doctor/upgrade spec needs a clean public-readiness foundation
  before implementation.

## Product / Workflow Decisions

- Rename in place later rather than spinning off a fresh repository now. A new
  repo would fragment history, issues, links, and install guidance before the
  current repo is hardened.
- Prefer a lowercase future repo/package slug if renaming, such as
  `agent-continuity`. GitHub redirects can preserve old links.
- Homebrew is the likely first package channel after public beta. Pip would
  require Python packaging restructuring; npm should wait unless it is only a
  thin wrapper.
- Public install docs should lead with preview/dry-run behavior. Write mode
  should require explicit user intent.
- `curl | bash` can remain available, but it should be framed as installer
  bootstrap, not a surprising repo mutation command.
- The first updater command should be `doctor`, not `upgrade --write`.

## Design Rules

- No secrets or private local artifacts in public source or release archives.
- Public first-run commands should be preview-first and non-destructive by
  default.
- Keep all destructive or repo-mutating behavior explicit.
- Do not overwrite project-owned Markdown as part of install or upgrade.
- Prefer boring, pasteable diagnostic output over clever automation.
- CI should exercise the same commands public users are asked to trust.
- Release checks must scan the AGENT-DOCS repo root, not only a nonexistent or
  empty `docs/` root.
- Avoid renaming until command names, docs, install URLs, and release notes can
  be changed coherently.

## Audit Findings To Address

### Security / Privacy

- Decide whether public author identity, GitHub owner, and commit metadata are
  acceptable.
- Keep ignored Python cache artifacts out of release artifacts. Working trees may
  contain local ignored caches during development, but public archives should be
  built from Git-tracked content or otherwise exclude them.
- Make private-fork install instructions safer than putting bearer tokens
  directly in a visible shell command.

### Portability

- Fix `agent-docs-init` crashing under ASCII/C locales.
- Document supported platforms and prerequisites: Bash, Git, Python 3.10+,
  symlink support, and user-local PATH behavior.
- Add friendlier preflight errors for missing `git`.
- Ensure small-profile docs and handoff instructions use paths the small profile
  actually creates.

### Public Trust / Distribution

- Change the public quick start to dry-run/no-run first, then explicit write.
- Add CI for smoke tests and Python compile checks.
- Add basic GitHub community files before broad public announcement.
- Add releases/tags before recommending stable install URLs.
- Add changelog/versioning enforcement from SPEC-0003 before repeated public
  releases.

### Repo Health / Tooling

- Add a release-grade metadata check path for AGENT-DOCS itself. The current
  default `scripts/docs-meta check` scans `docs`, while this repo's canonical
  docs mostly live at the repo root.
- Decide whether root-level docs should be made compatible with `docs-meta
  --root . check`, or whether AGENT-DOCS needs a dedicated release check command.
- Remove or ignore local artifacts such as `scripts/__pycache__`.

## Task Dependencies / Parallelization

- Task 0 must happen first: commit or clean the current spec/concept planning
  docs so implementation starts from a stable baseline.
- Tasks 1 and 2 can run in parallel after Task 0: public safety/docs hardening and
  CI/release check hardening.
- Task 3 depends on Tasks 1 and 2: changelog enforcement should land after
  public-facing surfaces and CI/release checks are clear enough to gate.
- Task 4 can run after Task 1 and can finish after Task 2: community files and
  publication guidance need the safer install story and verification commands.
- Task 5 depends on Tasks 1-4: rename decisions should happen after the public
  beta shape is hardened.
- Task 6 is future work after public beta: `doctor`, manifest, and safe upgrade.

## Out Of Scope

- Building `agent-docs doctor` or `upgrade --write` in the public-readiness pass.
- Publishing a Homebrew formula before the repo has CI, tags, and safer install
  docs.
- Rewriting git history unless the owner decides personal attribution is not
  acceptable.
- Renaming all project references in the same pass as basic safety fixes.
- Creating a new repository before the current one is reviewed and hardened.
- Adding a full package manager, database migration framework, or npm wrapper.

## File Structure

Likely modify:

```text
README.md
INSTALL.md
install.sh
scripts/agent-docs-init
scripts/docs-meta
scripts/README.md
guides/adoption-checklist.md
scaffold/AGENTS.md
scaffold/docs/repo-health/testing-guide.md
tests/agent-docs-init-smoke.sh
tests/install-smoke.sh
tests/docs-meta-smoke.sh
.github/workflows/ci.yml
CONTRIBUTING.md
SECURITY.md
CHANGELOG.md
```

Likely remove from the working tree before release:

```text
scripts/__pycache__/
```

## Implementation Tasks

### Task 0: Stabilize Current Planning Docs

**Goal:** Start implementation from a clean planning baseline.

- Review `SPEC-0003` and this plan.
- Commit the planning docs if accepted.
- Keep implementation commits separate from planning commits.

Verification:

- `git status --short`
- `git diff --check`

### Task 1: Public Safety And Portability Hardening

**Goal:** Remove surprising or brittle behavior from the public install/readme
surface.

- Change quick-start docs to preview-first.
- Add prerequisites and supported-platform notes.
- Fix or document private-fork token handling.
- Split small/growing/full profile handoff paths.
- Fix ASCII/C locale output in `agent-docs-init`.
- Add missing `git` preflight or friendlier failure.

Verification:

- `LC_ALL=C PYTHONUTF8=0 scripts/agent-docs-init /tmp/agent-docs-check --profile small --dry-run`
- `tests/agent-docs-init-smoke.sh`
- `tests/install-smoke.sh`
- `git diff --check`

### Task 2: Release-Grade Checks And CI

**Goal:** Make the repository's public safety checks repeatable in GitHub Actions
and locally.

- Add `.github/workflows/ci.yml`.
- Run smoke tests and Python compile checks in CI.
- Define an AGENT-DOCS release check that scans the right roots.
- Decide whether to adapt `docs-meta --root . check` or create a targeted
  release-check script.

Verification:

- `tests/docs-meta-smoke.sh`
- `tests/install-smoke.sh`
- `tests/agent-docs-init-smoke.sh`
- Python compile for scripts
- new release-check command
- GitHub Actions green after push

### Task 3: Changelog And Versioning Gate

**Goal:** Add the first lightweight adopter-facing versioning workflow from
SPEC-0003.

- Add `CHANGELOG.md` with an `Unreleased` or dated public-readiness entry.
- Add CI or a local check that requires a changelog update when adopter-facing
  surfaces change.
- Support an explicit `Change-Record: not-needed` escape hatch for non-adopter
  changes.

Verification:

- changelog check passes when versioned surfaces change with a changelog entry
- changelog check fails in a fixture or dry run when versioned surfaces change
  without a changelog entry or exemption

### Task 4: Community And Publication Files

**Goal:** Make the public repository understandable and safe for outside users.

- Add `CONTRIBUTING.md`.
- Add `SECURITY.md`.
- Add issue and PR templates if useful.
- Make release/archive guidance prefer `git archive` or tagged source archives.
- Remove local cache artifacts before release.

Verification:

- `find . -path ./.git -prune -o \( -name '__pycache__' -o -name '*.pyc' \) -print`
- README and install links still work
- smoke tests still pass

Status:

- Completed for this lightweight pass with root community files, concise issue
  and PR templates, changelog notes, and tracked-source archive guidance.

### Task 5: Rename Decision And Branding Pass

**Goal:** Decide whether to keep `AGENT-DOCS`, rename to `agent-docs`, or rename
to `agent-continuity`.

- Keep `Agent Continuity` as the working product name while hardening.
- After Tasks 1-4, review whether the public name should change.
- If renaming, update repo slug, install URLs, command names, README, docs,
  changelog, and release notes in one coherent pass.
- Prefer leaving command aliases for the old name where practical.

Verification:

- old install path either redirects or is documented
- new install path works from a tagged release
- smoke tests pass under the new command names or aliases

Status:

- Deferred until after hardening. No repo, file, command, or public install URL
  rename is part of this pass.

### Task 6: Doctor / Upgrade Follow-Up Plan

**Goal:** Prepare the future safe updater after public-readiness basics land.

- Create a follow-up plan from SPEC-0003 for manifest, `doctor`, dry-run upgrade,
  and tooling-only write mode.
- Do not implement write-mode upgrade until `doctor` output is trusted.

Verification:

- follow-up plan reviewed and linked from SPEC-0003

Status:

- Completed by [PLAN-0005 - Agent Docs Doctor Manifest Upgrade](../agent-docs-doctor-manifest-upgrade/PLAN-0005-agent-docs-doctor-manifest-upgrade.md).

## Implementation Briefs Needed

Create implementation briefs for the riskier or more coupled slices before
coding them:

- `IMPL-0004-01`: public install/docs portability hardening.
- `IMPL-0004-02`: release-grade checks and CI.
- `IMPL-0004-03`: changelog/versioning gate.

The community files and rename decision can stay in the parent plan unless they
grow. Create additional briefs if rename work becomes a coordinated migration,
`doctor`/manifest work starts before public-readiness tasks are complete, or
multiple subagents need disjoint write scopes.

## Validation

Minimum before public announcement:

```bash
git status --short --branch --untracked-files=all
tests/install-smoke.sh
tests/agent-docs-init-smoke.sh
tests/docs-meta-smoke.sh
python3 -m py_compile scripts/agent-docs-init scripts/docs-meta
git diff --check
find . -path ./.git -prune -o \( -name '__pycache__' -o -name '*.pyc' -o -name '.env*' -o -name '*.pem' -o -name '*.key' -o -name '*.p8' \) -print
rg --files-with-matches --hidden --glob '!.git/**' -i '(/Users/|gmail\.com|api[_-]?key|secret|token|password|private key|BEGIN .*PRIVATE KEY|Authorization: Bearer)'
```

Add after CI exists:

```bash
gh run list --limit 5
```

## Completion Criteria

- [x] Working tree is clean before publication.
- [x] Public quick start is preview-first or explicitly non-mutating.
- [x] Installer prerequisites are documented and preflighted.
- [x] Small-profile docs no longer point users at full-profile-only paths.
- [x] ASCII/C locale dry-run does not crash.
- [x] CI runs install, init, docs-meta smoke tests, Python compile, and diff
      hygiene.
- [x] AGENT-DOCS release checks scan meaningful repo roots.
- [x] Repo-local Markdown links pass, or any root-level link-check limitations
      are explicitly documented and waived.
- [x] Changelog/versioning gate exists for adopter-facing changes.
- [x] Community files exist.
- [x] Release artifacts exclude ignored cache files and other local generated
      artifacts.
- [x] Rename decision is deferred until after hardening; no rename has been
      performed in this pass.
- [x] Follow-up doctor/upgrade plan exists if SPEC-0003 remains in scope.

## Deferred Publication Work

- Decide whether to rename the repo/package to `agent-continuity`.
- Create a tagged public release once release cadence is chosen.
- Add Homebrew or other package-manager distribution after tagged releases are
  reliable.
- Update command aliases, install URLs, README, changelog, and release notes in
  one coherent rename/publication pass if the rename proceeds.
