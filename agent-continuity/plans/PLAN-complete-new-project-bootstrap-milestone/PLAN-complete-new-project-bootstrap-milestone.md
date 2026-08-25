---
type: plan
document_format_version: 2
id: 01a034e4-2791-74ab-90da-7fce88bf52a7
aliases: []
title: Complete New Project Bootstrap Milestone
domain: agent-continuity
status: completed
created_at: "2026-08-25 02:49:22 JST +0900"
updated_at: "2026-08-25 03:33:59 JST +0900"
owner: Owen
sequence:
  roadmap:
  sort_key:
  lane: agent-continuity
  after: []
  before: []
areas:
  - agent-continuity
  - repository-bootstrap
  - continuous-integration
related_specs:
  - 01a034dd-eefc-7038-a814-ce4e28164af3
related_adrs: []
related_sessions:
  - 01a03500-7324-7f48-bb3c-707b1259ba75
related_issues: []
related_prs: []
linked_paths:
  - scripts/agent-continuity
  - scripts/agent-continuity-init
  - scripts/agent-continuity-project
  - scripts/agent-continuity-ci
  - scripts/release-check
  - tests/agent-continuity-init-smoke.sh
  - tests/agent-continuity-project-smoke.sh
  - tests/agent-continuity-ci-smoke.sh
  - scaffold/.github/workflows/agent-continuity.yml
repo_state:
  based_on_commit: dd4036b6bbaa43a895bfc5564c7312bfa77c36cd
  last_reviewed_commit: dd4036b6bbaa43a895bfc5564c7312bfa77c36cd
---

# Complete New Project Bootstrap Milestone

## Goal

Deliver and prove one preview-first `agent-continuity project new` transaction
that creates a Git repository with the complete Agent Continuity footprint,
repository-local deterministic CI, a GitHub Actions caller, a bootstrap receipt,
and an initial commit. Support explicit GitHub creation/push without exercising a
real remote during automated tests.

## Architecture

The public dispatcher remains the installed caller interface. Two sibling deep
modules own the new behavior:

- `scripts/agent-continuity-ci` owns target-repository deterministic
  verification and is vendored into complete projects.
- `scripts/agent-continuity-project` owns the new-project transaction and
  composes the existing initializer, the repository-local verifier, Git, and an
  optional authenticated GitHub CLI adapter.

The generated GitHub Actions workflow invokes the vendored verifier directly.
It therefore works in a cold checkout without installing the Agent Continuity
dispatcher from the network. Project-specific build/test commands remain owned
by the target project and its own workflow jobs.

The dangerous path is explicit: dry-run is default; `--write` permits local
mutation; `--github` plus `--visibility` additionally permits remote creation
and push. No branch protection or model-backed review belongs to this milestone.

## Task Dependencies / Parallelization

The work is intentionally sequential because the same installer action set,
manifest ownership list, dispatcher, and release gate are hot files:

```text
verifier contract and red tests
  -> complete-profile owned artifacts and generated workflow
  -> project transaction and red/green smoke test
  -> public docs/changelog
  -> full release and cold-project proof
```

No implementation briefs are needed: one task owns the complete vertical slice,
and splitting it would add coordination without creating independent ownership.

## Implementation Tasks

1. Add failing verifier smoke coverage for a healthy complete target and for
   checksum, mode, structured-doc, link, TODO, and generated-view failures.
2. Implement `scripts/agent-continuity-ci` and dispatch it through
   `agent-continuity ci`.
3. Add the verifier, its smoke test, and
   `.github/workflows/agent-continuity.yml` to the complete profile as
   checksummed Agent Continuity-owned artifacts.
4. Add failing `project new` smoke coverage for dry-run non-mutation, complete
   local write, initial commit/receipt, non-empty-target refusal, and a stubbed
   GitHub path that proves ordering and visibility.
5. Implement `scripts/agent-continuity-project` and `agent-continuity project`
   dispatch while composing the existing initializer rather than duplicating its
   scaffold logic.
6. Update public help, installation/adoption guidance, changelog, and the
   proposal paper trail.
7. Run focused suites, the full release check, and one independently inspected
   disposable cold-project proof.

## Validation

```bash
tests/agent-continuity-ci-smoke.sh
tests/agent-continuity-project-smoke.sh
tests/agent-continuity-init-smoke.sh
tests/agent-continuity-doctor-upgrade-smoke.sh
scripts/release-check
```

The cold proof must run the installed branch command against a fresh temporary
parent, inspect the resulting manifest/workflow/receipt/Git state, and execute
both `agent-continuity ci <target>` and the vendored verifier.

## Completion Criteria

- [x] `complete` is mechanically fixed for `project new` and documented as the
      accepted universal new-project baseline.
- [x] Dry-run creates no target and reports every local/remote phase.
- [x] Local write creates the complete footprint, green verifier, `main`, receipt,
      and initial commit.
- [x] The generated workflow is cold-checkout runnable and least-privilege.
- [x] Explicit GitHub arguments are validated and the stubbed integration proves
      remote mutation follows local verification.
- [x] Existing init/upgrade/docs/legacy behavior remains green.
- [x] Full release verification and the cold-project proof pass.
