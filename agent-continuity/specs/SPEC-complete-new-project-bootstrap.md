---
type: spec
document_format_version: 2
id: 01a034dd-eefc-7038-a814-ce4e28164af3
aliases: []
title: Complete New Project Bootstrap
spec_type: feature
domain: agent-continuity
status: approved
created_at: "2026-08-25 02:42:34 JST +0900"
updated_at: "2026-08-25 03:33:59 JST +0900"
owner: Owen
source:
  type: conversation
  link: codex://threads/01a034a3-7994-7ea1-9b8f-ee6296a77a35
  notes:
areas:
  - agent-continuity
  - repository-bootstrap
  - continuous-integration
related_plans:
  - 01a034e4-2791-74ab-90da-7fce88bf52a7
related_issues: []
related_prs: []
related_adrs: []
related_sessions:
  - 01a03500-7324-7f48-bb3c-707b1259ba75
supersedes: []
superseded_by: []
linked_paths:
  - scripts/agent-continuity
  - scripts/agent-continuity-init
  - scripts/agent-continuity-project
  - scripts/agent-continuity-ci
  - install.sh
  - scripts/release-check
  - scaffold/.github/workflows/agent-continuity.yml
  - tests/agent-continuity-project-smoke.sh
  - tests/agent-continuity-ci-smoke.sh
repo_state:
  based_on_commit: dd4036b6bbaa43a895bfc5564c7312bfa77c36cd
  last_reviewed_commit: dd4036b6bbaa43a895bfc5564c7312bfa77c36cd
---

# Complete New Project Bootstrap

## Summary

Agent Continuity must provide one preview-first command that creates a new Git
repository with the complete Agent Continuity footprint, deterministic local
verification, and a ready-to-run GitHub Actions workflow. When explicitly
requested, the same transaction may create and push a GitHub repository after
the local repository has passed verification.

## Problem / Opportunity

Starting a real project currently requires the caller to separately create a
directory, initialize Git, choose and install an Agent Continuity profile,
invent a CI workflow, run several checks, create the first commit, and then
create and push a GitHub repository. The pieces exist, but the safe sequence and
evidence are still human- or agent-assembled each time.

That repeated assembly is exactly where new repositories acquire incomplete
documentation footprints, unverified generated views, missing CI, or remote
state that does not match the reported local commit.

## Goals

- Make `complete` the fixed Agent Continuity profile for every repository
  created through the new-project bootstrap.
- Provide one explicit dry-run/write transaction for local repository creation.
- Install a repository-local deterministic verifier and GitHub Actions caller.
- Create a valid `main` branch and initial commit only after local verification
  passes.
- Optionally create and push a GitHub repository when the caller explicitly
  supplies its name and visibility.
- Leave a machine-readable bootstrap receipt and a human-readable result.

## Non-Goals

- Choosing an application framework, language, package manager, or build system.
- Creating or modifying an existing non-empty project; that remains an adoption
  workflow rather than `project new`.
- Running project-specific tests that Agent Continuity cannot know yet.
- Enabling semantic or model-backed documentation review in this milestone.
- Installing branch protection or repository rulesets in this milestone.
- Treating CI success as proof of product behavior or human acceptance.

## Current Behavior / Context

- `agent-continuity init --profile complete --write` installs the complete
  documentation footprint and manifest into a caller-selected directory.
- Complete installs vendor `scripts/agent-continuity-docs`, but they do not
  currently include one repository-local continuity verifier or GitHub Actions
  workflow.
- The public `agent-continuity` dispatcher supports init, docs, doctor, upgrade,
  and baseline commands but not project creation or a single CI contract.
- The Agent Continuity source repository has its own release workflow; consuming
  repositories do not inherit it.

## Desired Behavior / Target State

The ordinary local path is:

```bash
agent-continuity project new <name> --path <path> --write
```

The ordinary GitHub path is:

```bash
agent-continuity project new <name> \
  --path <path> \
  --github <owner>/<repo> \
  --visibility private \
  --write
```

Without `--write`, the command previews the complete transaction and creates
nothing. The command always uses profile `complete`; it does not expose a
profile flag that can silently weaken the universal new-project baseline.

The transaction boundary is:

```text
preflight -> create directory -> git init main -> complete init
          -> named front doors -> local continuity CI -> receipt -> initial commit
          -> optional GitHub create/push -> final verification/report
```

## Requirements

### CLI contract

1. `agent-continuity project new` accepts a project name and optional explicit
   target path.
2. Dry-run is the default; mutation requires `--write`.
3. The command always installs profile `complete` with document tooling.
4. The target must be absent or empty. Existing non-empty directories are
   refused without mutation.
5. The default branch is `main`.
6. GitHub creation requires both `--github` and `--visibility`; supplying either
   without the other is invalid.
7. GitHub visibility is one of `private`, `public`, or `internal`.

### Generated repository contract

8. The repository contains the complete Agent Continuity footprint and a valid
   `.agent-continuity/manifest.json`.
9. It contains a truthful root `README.md` that names the project, points to the
   primary orientation docs and verifier, and leaves unknown product purpose and
   stack choices explicit rather than guessed. The root `AGENTS.md` uses the
   supplied project name.
10. It contains Agent Continuity-owned, checksummed executable tooling at
   `scripts/agent-continuity-docs` and `scripts/agent-continuity-ci`.
11. It contains `.github/workflows/agent-continuity.yml` with read-only contents
    permission, concurrency cancellation, branch-push coverage, pull requests
    targeting `main`, and manual dispatch.
12. It contains `.agent-continuity/bootstrap-receipt.json` describing requested
    and completed local/remote phases without secrets or machine-local absolute
    paths. Fresh manifest provenance likewise omits installer-local paths and
    strips URL userinfo, query strings, and fragments before storage.

### Verification and transaction contract

13. `agent-continuity ci [target]` and the vendored
    `scripts/agent-continuity-ci` run the same deterministic contract.
14. The contract verifies manifest-owned file presence, checksum, and mode;
    structured document validity; repository-local links; structured TODOs;
    generated-view freshness; and `git diff --check`.
15. CI never rewrites generated views or project-owned Markdown.
16. The initial commit is created only after the deterministic contract passes.
17. A GitHub repository is never created before local generation and
    verification pass.
18. GitHub creation and push use the authenticated `gh` command without placing
    credentials in arguments, receipts, or logs.
19. A remote-enabled run reports success only after the exact local `main` commit
    is confirmed at `origin/main`.
20. On failure, the command stops at the failed phase, reports the preserved
    local path and next diagnostic command, and does not claim completion.

### Compatibility

21. Existing `agent-continuity init` profile behavior and legacy command/profile
    aliases continue to work.
22. Existing projects do not gain a workflow or new owned file except through a
    separately requested init/upgrade/adoption path.

## Open Questions

- Whether a later `project adopt` command should compose the same verifier and
  workflow installer for existing repositories.
- Whether branch rulesets should become a separately authorized follow-up after
  the repository exists and its first remote CI run is observable.
- Whether the remote-enabled path should optionally wait for the first GitHub
  Actions run in a later milestone.

## Test / Validation Expectations

- A smoke test proves dry-run creates no target.
- A cold local write test proves the complete footprint, manifest ownership,
  workflow, receipt, `main` branch, and initial commit.
- Re-running against the non-empty target is refused without changing its HEAD
  or tracked bytes.
- CI fails when an owned file is missing, modified, or non-executable.
- CI fails when generated views, document links, or structured TODOs are stale.
- A stubbed `gh` integration test proves remote creation occurs only after local
  verification and that the requested visibility is preserved.
- Existing init, doctor/upgrade, docs, compatibility, and release smoke suites
  remain green.

## Paper Trail

- Promoted from
  `agent-continuity/ideas/IDEA-project-bootstrap-ci-and-semantic-doc-review.md`.
- The user explicitly confirmed that `complete` is the universal new-project
  baseline; this is an accepted product requirement, not an open default choice.
