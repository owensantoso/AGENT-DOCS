---
type: plan
id: PLAN-0005
title: Agent Docs Doctor Manifest Upgrade
domain: repo-health
status: draft
created_at: "2026-05-02 02:40:23 JST +0900"
updated_at: "2026-05-02 02:40:23 JST +0900"
planned_execution_start:
planned_execution_end:
actual_execution_start:
actual_execution_end:
owner: codex
sequence:
  roadmap:
  sort_key:
  lane: repo-health
  after:
    - PLAN-0004
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
related_issues: []
related_prs: []
repo_state:
  based_on_commit: aeb7558fc9a6b5b5bfd11e2cd738b2d181a22b4d
  last_reviewed_commit: aeb7558fc9a6b5b5bfd11e2cd738b2d181a22b4d
---

# PLAN-0005 - Agent Docs Doctor Manifest Upgrade

**Goal:** Implement the safe update path from SPEC-0003: installed manifests,
read-only `doctor`, dry-run upgrade reporting, and a narrow tooling-only write
mode.

**Architecture:** Build trust in layers. First record what AGENT-DOCS installed,
then make drift visible without writing, then preview upgrade categories, and
only then allow writes for manifest-recognized AGENT-DOCS-owned tooling,
generated views, and non-conflicting additions.

**Tech Stack:** Bash installer, Python `agent-docs-init` or future `agent-docs`
entry point, JSON manifest files, Markdown scaffold, `docs-meta`, smoke tests,
and release-check/CI coverage.

**Source Spec:** [SPEC-0003 - AGENT-DOCS Versioning And Safe Upgrade](../agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md)

---

## Prerequisites

- PLAN-0004 public-readiness hardening is complete enough that installer,
  release-check, changelog, CI, and community guidance are stable.
- `CHANGELOG.md` and the changelog gate are trusted for adopter-facing changes.
- The command shape is decided: extend `agent-docs-init`, add `agent-docs`, or
  ship a separate script.
- Security review confirms target-path, symlink, and outside-repo write rules.

## Why Now

- Target repos need to learn about upstream AGENT-DOCS improvements without
  losing customized project truth.
- A manifest gives future tools a conservative basis for ownership and drift.
- `doctor` lets adopters inspect their install before any upgrade write mode
  exists.
- Dry-run and tooling-only write mode can stay boring when the classification
  model is visible and tested first.

## Product / Workflow Decisions

- Markdown docs in target repos are project-owned by default after install.
- The manifest records AGENT-DOCS-owned assets; it is not a source of truth for
  target-repo product, architecture, or planning knowledge.
- `doctor` must be read-only and useful before upgrade write mode is built.
- Dry-run output should classify every candidate as safe automatic update, safe
  addition, generated refresh, manual review, refused, or unknown.
- Write mode starts as `--tooling-only`; no broad `--force` semantics.

## Design Rules

- Preview before mutation.
- Refuse ambiguous ownership.
- Never overwrite project-owned Markdown by default.
- Never write through symlinked target paths or outside the target repo root.
- Prefer exact paths, reasons, and next commands over clever summarization.
- Keep legacy installs manual-review until a baseline manifest is intentionally
  created.

## Task Dependencies / Parallelization

- Task 1 must happen first: decide command shape and manifest schema.
- Task 2 depends on Task 1: write manifests during install or baseline creation.
- Task 3 depends on Tasks 1 and 2: implement read-only `doctor`.
- Task 4 depends on Task 3: implement upgrade dry-run categories.
- Task 5 depends on Task 4 and security review: implement tooling-only write
  mode.
- Task 6 closes out docs, changelog, release checks, and target-repo examples.

## Out Of Scope

- Auto-merging upstream scaffold Markdown into customized project docs.
- Deleting target-repo docs because upstream no longer ships a template.
- Package-manager publishing, Homebrew formula work, or tagged release
  automation.
- Full semantic versioning or migration framework beyond the manifest and
  changelog-backed notes needed for this plan.
- Renaming AGENT-DOCS or changing public install URLs.

## File Structure

Likely modify:

```text
README.md
INSTALL.md
CHANGELOG.md
scripts/agent-docs-init
scripts/README.md
scripts/release-check
tests/agent-docs-init-smoke.sh
tests/install-smoke.sh
tests/docs-meta-smoke.sh
```

Likely create:

```text
tests/doctor-smoke.sh
tests/upgrade-dry-run-smoke.sh
```

Create implementation briefs before coding begins if the command-shape decision
or manifest schema needs review across multiple workers.

## Implementation Tasks

### Task 1: Decide Command Shape And Manifest Schema

**Goal:** Commit the smallest stable contract for installed metadata and command
entry points.

- Decide whether the public command is `agent-docs-init`, `agent-docs`, or a
  separate helper.
- Define `.agent-docs/manifest.json` schema version, source ref, profile,
  optional components, owned-file records, checksums, generated-view records, and
  timestamps.
- Document project-owned versus AGENT-DOCS-owned classifications.

Verification:

- Schema examples reviewed in docs.
- Security-sensitive path rules are called out before implementation.

### Task 2: Write Or Baseline Manifests

**Goal:** Record AGENT-DOCS-owned install state without claiming ownership of
project docs.

- Write a manifest for new installs.
- Provide a deliberate baseline path for existing installs, if needed.
- Hash only AGENT-DOCS-owned assets and generated-view records.

Verification:

- Fresh tiny, small, growing, and full profile dry-runs stay non-mutating.
- Write-mode install creates the expected manifest without overwriting target
  files.

### Task 3: Add Read-Only Doctor

**Goal:** Make installed shape and drift visible without writing files.

- Detect profile, optional components, manifest details, missing tooling, stale
  generated views, project-owned docs, and unknown shapes.
- Print exact recommended next commands.
- Return useful exit codes for healthy, warning, and incompatible states.

Verification:

- Doctor smoke tests cover fresh install, missing manifest, stale tooling,
  project-owned drift, and unknown legacy install.

### Task 4: Add Upgrade Dry Run

**Goal:** Show what upgrade would do by safety category.

- Report safe automatic updates, safe additions, generated refreshes,
  manual-review items, refused items, and unknown items.
- Include paths and reasons for every candidate.
- Keep output pasteable for issues and session logs.

Verification:

- Dry-run tests prove no files are written.
- Mixed safe/manual/refused fixtures classify deterministically.

### Task 5: Add Tooling-Only Write Mode

**Goal:** Apply only the safe, manifest-recognized subset after dry-run behavior
is trusted.

- Update AGENT-DOCS-owned tooling when the current checksum matches the manifest
  base.
- Add missing non-conflicting AGENT-DOCS-owned files.
- Regenerate generated views through the installed generator.
- Update `.agent-docs/manifest.json`.

Verification:

- Write-mode tests prove project-owned Markdown is not modified.
- Symlink and outside-root write attempts are refused.
- Manifest checksums update only after successful writes.

### Task 6: Document And Gate The Workflow

**Goal:** Make the updater safe to maintain and safe to recommend.

- Update README, INSTALL, scripts docs, changelog, and security guidance.
- Add release-check coverage for manifest/doctor/upgrade smoke tests.
- Record any deferred migration questions as follow-up docs.

Verification:

- `scripts/release-check`
- `git diff --check`
- docs-meta checks for plans and links

## Validation

Minimum before implementation is complete:

```bash
scripts/release-check
git diff --check
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
```

Add targeted manifest, doctor, dry-run, and write-mode smoke tests as each task
lands.

## Completion Criteria

- [ ] Manifest schema is documented and versioned.
- [ ] Fresh installs can write a manifest for AGENT-DOCS-owned assets.
- [ ] Existing installs have a deliberate baseline path or remain manual-review.
- [ ] `doctor` is read-only and classifies install state deterministically.
- [ ] Upgrade dry-run reports safe, manual-review, refused, and unknown work.
- [ ] Tooling-only write mode updates only manifest-recognized safe files.
- [ ] Project-owned Markdown is never overwritten by default.
- [ ] Release-check and CI cover the shipped command path.
