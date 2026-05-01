---
type: implementation-brief
id: IMPL-0006-01
title: Legacy Manifest Baseline
domain: repo-health
status: ready
created_at: "2026-05-02 06:24:06 JST +0900"
updated_at: "2026-05-02 06:24:06 JST +0900"
parent_plan: PLAN-0006
task_refs:
  - task-1
owner: codex
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
depends_on:
  - PLAN-0005
parallel_with: []
related_specs:
  - SPEC-0003
related_adrs: []
related_sessions:
  - session-logs/2026-05-02-plan-0006-briefing.md
related_issues: []
related_prs: []
linked_paths:
  - plans/agent-docs-upgrade-follow-ups/PLAN-0006-generated-view-and-legacy-manifest-upgrade-follow-ups.md
  - plans/agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md
  - scripts/agent-docs
  - scripts/agent-docs-init
  - tests/agent-docs-doctor-upgrade-smoke.sh
repo_state:
  based_on_commit: c2ea885b8adf93d5f2095c8fd4f3d63b718e5c4f
  last_reviewed_commit: c2ea885b8adf93d5f2095c8fd4f3d63b718e5c4f
---

# IMPL-0006-01 - Legacy Manifest Baseline

## Parent Plan

[PLAN-0006 - Generated View And Legacy Manifest Upgrade Follow-ups](../PLAN-0006-generated-view-and-legacy-manifest-upgrade-follow-ups.md)

## Task Goal

Add a conservative, preview-first baseline path for legacy AGENT-DOCS installs
that do not yet have `.agent-docs/manifest.json`.

The baseline command should create a manifest only when AGENT-DOCS can prove the
target's reusable tooling matches the current upstream action set. Project-owned
Markdown should be recorded as project-owned after install, but never
checksummed or claimed as automatically replaceable.

## Proposed Command Shape

Use the existing command namespace:

```bash
agent-docs baseline --dry-run /path/to/project --profile small --docs-meta yes
agent-docs baseline --write /path/to/project --profile small --docs-meta yes
```

Design notes:

- `--dry-run` is the default if neither `--dry-run` nor `--write` is supplied.
- `--profile` is required in non-interactive use; start with the existing
  profile names.
- `--docs-meta` should mirror install semantics where practical, but may be
  limited to `yes`/`no` for the first slice.
- `--write` must refuse if a manifest already exists; existing manifest updates
  remain the job of `agent-docs upgrade`.

If implementation finds that `baseline` is too vague, prefer
`agent-docs manifest baseline` only if the parser can stay simple. Do not add
more than one public command shape in this slice.

## Scope

- Add read-only baseline preview for targets without `.agent-docs/manifest.json`.
- Add explicit write mode that writes `.agent-docs/manifest.json` last.
- Reuse the same profile action and ownership classification used by
  `agent-docs-init`.
- Record AGENT-DOCS-owned tooling with checksum, expected mode, and source
  action metadata.
- Record starter/project docs as `project-owned-after-install` when present.
- Refuse ambiguous or unsafe legacy shapes.
- Update README, INSTALL, scripts docs, changelog, PLAN-0006/session paper trail,
  and release-check coverage where needed.

## Non-Goals

- Do not create or modify missing source docs or tooling files.
- Do not overwrite project-owned Markdown.
- Do not infer profile automatically in write mode.
- Do not baseline unknown local scripts, locally patched tooling, copied skills,
  or generated views unless the first implementation proves them against known
  upstream actions.
- Do not implement generated-view upgrade writes.
- Do not change PLAN-0005 `upgrade --write --tooling-only` behavior except for
  shared helper refactors needed to keep path-safety consistent.

## Safety Rules

- Refuse if `.agent-docs/manifest.json` exists.
- Refuse symlinked paths, hard-to-classify parent conflicts, non-regular files,
  absolute or `..` manifest paths, and outside-root writes.
- Refuse if an AGENT-DOCS-owned action for the chosen profile is missing from
  the target.
- Refuse if an AGENT-DOCS-owned target file checksum or exact mode differs from
  the current upstream action.
- Refuse if a target path that would be AGENT-DOCS-owned exists but cannot be
  mapped to a known action for the selected profile/options.
- Project-owned Markdown presence is allowed; project-owned Markdown drift is
  not an error and should be described as local truth.
- Write mode should produce a concise report before writing and should leave no
  partial manifest on failure.

## Expected Output

Dry run should classify candidates with exact paths and reasons:

- `baseline owned tooling`: known AGENT-DOCS-owned file matches upstream
  checksum/mode and can be recorded.
- `project-owned after install`: starter/project Markdown present and will be
  recorded without checksum.
- `manual-review/refused`: missing, drifted, symlinked, non-regular, unknown, or
  unsafe paths.

Write mode should print the same classification plus the manifest path written.

## Execution Steps

1. Add failing smoke fixtures for legacy baselining:
   - healthy legacy small/docs-meta target dry-runs without writing;
   - healthy legacy small/docs-meta target writes a valid manifest;
   - existing manifest refuses;
   - missing owned tooling refuses;
   - drifted owned tooling refuses;
   - wrong mode refuses;
   - symlinked owned path refuses and does not write outside target;
   - project-owned Markdown remains unmodified and unchecksummed.
2. Implement the minimal `agent-docs baseline` command and shared manifest
   construction helpers.
3. Update human-facing docs and the PLAN-0006/session paper trail.
4. Run focused tests and full release verification.

## Verification

```bash
tests/agent-docs-doctor-upgrade-smoke.sh
tests/agent-docs-init-smoke.sh
scripts/release-check
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
git diff --check
```

## Review Focus

- Baseline write mode does not become an ownership grab for project docs.
- Profile/options are explicit enough that legacy installs are not guessed into
  a false manifest.
- Path-safety behavior matches PLAN-0005 write mode.
- Failed baseline attempts leave no manifest behind.
- The command names and output are clear enough for future agents to use without
  rereading this brief.

## Done Checklist

- [ ] Baseline preview and write behavior implemented.
- [ ] Refusal and path-safety smoke fixtures pass.
- [ ] Project-owned Markdown remains unmodified and unchecksummed.
- [ ] Docs and session log updated.
- [ ] Full verification passes.
