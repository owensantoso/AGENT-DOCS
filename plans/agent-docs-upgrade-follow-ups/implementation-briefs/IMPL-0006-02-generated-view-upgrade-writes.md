---
type: implementation-brief
id: IMPL-0006-02
title: Generated View Upgrade Writes
domain: repo-health
status: completed
created_at: "2026-05-02 07:39:15 JST +0900"
updated_at: "2026-05-02 07:51:06 JST +0900"
parent_plan: PLAN-0006
task_refs:
  - task-2
owner: codex
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
depends_on:
  - IMPL-0006-01
parallel_with: []
related_specs:
  - plans/agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md
related_adrs: []
related_sessions:
  - session-logs/2026-05-02-plan-0006-briefing.md
  - session-logs/2026-05-02-impl-0006-01-legacy-manifest-baseline.md
  - session-logs/2026-05-02-impl-0006-02-generated-view-upgrade-writes.md
related_issues: []
related_prs: []
linked_paths:
  - plans/agent-docs-upgrade-follow-ups/PLAN-0006-generated-view-and-legacy-manifest-upgrade-follow-ups.md
  - scripts/agent-docs
  - scripts/docs-meta
  - tests/agent-docs-doctor-upgrade-smoke.sh
repo_state:
  based_on_commit: ad7b09d5d0e142dcdd77f0847ec32e5fc7db5936
  last_reviewed_commit: ad7b09d5d0e142dcdd77f0847ec32e5fc7db5936
---

# IMPL-0006-02 - Generated View Upgrade Writes

## Parent Plan

[PLAN-0006 - Generated View And Legacy Manifest Upgrade Follow-ups](../PLAN-0006-generated-view-and-legacy-manifest-upgrade-follow-ups.md)

## Task Goal

Allow `agent-docs upgrade --write` to regenerate manifest-tracked generated
views through known local generator commands, while preserving the PLAN-0005
principle that source-of-truth Markdown and project-owned docs are never
rewritten automatically.

## Current State

`agent-docs doctor` and `agent-docs upgrade --dry-run` already classify manifest
`generated_views` records as `generated view refreshes` when the target file is
missing or its checksum differs from the manifest. `agent-docs upgrade --write
--tooling-only` leaves those refreshes report-only unless `--generated-views` is
also provided.

Fresh installs and legacy baselines currently write an empty `generated_views`
array. This brief only enables writes for generated views that are already
manifest-tracked. Adding generated-view records for new installs can be a later
brief if needed.

## Command Shape

Keep write mode explicit:

```bash
agent-docs upgrade --write --tooling-only --generated-views /path/to/project
```

Rules:

- Bare `agent-docs upgrade` and `agent-docs upgrade --dry-run` remain read-only.
- `agent-docs upgrade --write` without `--tooling-only` still refuses.
- `--generated-views` is only valid with `--write --tooling-only`.
- Without `--generated-views`, generated views remain report-only exactly as
  they do today.

This keeps the first generated-view mutation path deliberately opt-in while
reusing the existing safe write mode instead of adding a broad force flag.

## Scope

- Add generated-view write operations for manifest records that pass validation.
- Run only known generator commands. Initially allow:
  - `scripts/docs-meta update`
- Require the generator executable/script to live inside the target repo and not
  be reached through a symlink.
- Run the generator from the target repo root.
- Refresh all stale or missing generated views covered by the generator in one
  generator run, then verify the manifest-tracked paths.
- Create backups for changed existing generated-view files and for
  `.agent-docs/manifest.json`.
- Update `generated_views[*].checksum_sha256` after successful regeneration.
- Update manifest source metadata and `updated_at` last.
- Add smoke coverage for success and refusal cases.
- Update README/INSTALL/scripts docs and CHANGELOG if adopter-facing command
  behavior changes.

## Non-Goals

- Do not create or infer new generated-view manifest records.
- Do not regenerate views that are not present in `manifest.generated_views`.
- Do not overwrite source-of-truth Markdown such as plans, specs, ADRs,
  session logs, or project-owned docs.
- Do not accept arbitrary shell commands from the manifest.
- Do not add a broad `--force` or `--all` write mode.
- Do not make generated-view writes part of default `--tooling-only` behavior.

## Safety Model

Before running a generator, refuse the whole write if any manifest or filesystem
shape is ambiguous:

- `manifest.generated_views` is missing or not a list when `--generated-views`
  is requested.
- Any generated-view record is not an object.
- Any generated-view path is empty, absolute, contains `..`, resolves outside
  the target, traverses a symlink, has a non-directory parent, or is a directory.
- Any generated-view record is missing a valid 64-character lowercase
  `checksum_sha256`.
- Any generated-view record names an unsupported generator.
- Any supported generator path is missing, not a regular file, not executable
  when required, outside the target, symlinked, or locally drifted if it is also
  manifest-tracked as AGENT-DOCS-owned tooling.
- The current generated-view file exists and its checksum does not match the
  manifest checksum unless it has generated-view frontmatter or a generated-view
  header that makes it clearly derived.

Generated views are derived artifacts, but this first write slice should still
be conservative: if a file looks hand-edited and cannot be recognized as a
generated view, report it instead of overwriting it.

## Suggested Implementation Steps

1. Add failing smoke tests for generated-view write behavior.
2. Add a generated-view operation builder separate from tooling operations.
3. Validate generated-view records and generator commands before any write.
4. Extend `upgrade` argument parsing with `--generated-views`.
5. Apply tooling operations first, if any, then run supported generators, then
   verify generated-view outputs, then write the manifest last.
6. Keep backups under `.agent-docs/backups/<timestamp>/` and include generated
   views in the audit file.
7. Update docs and changelog.
8. Run the full verification set.

## Smoke Test Targets

Add tests to `tests/agent-docs-doctor-upgrade-smoke.sh` covering:

- dry-run reports stale generated views without writing;
- `--write --tooling-only` without `--generated-views` leaves generated views
  report-only;
- `--write --tooling-only --generated-views` regenerates a stale
  manifest-tracked generated view, updates its manifest checksum, creates a
  backup for an existing changed view, and writes the manifest last;
- missing generated view is recreated when the generator can produce it;
- unsupported generator refuses with no writes;
- malformed generated-view records refuse with no writes;
- symlinked generated-view path refuses with no writes;
- directory generated-view path refuses with no writes;
- generated-view current checksum drift without a recognizable generated-view
  marker refuses instead of overwriting a possible hand-edited file;
- generator failure refuses and leaves the manifest unchanged.

## Verification

```bash
tests/agent-docs-doctor-upgrade-smoke.sh
tests/agent-docs-init-smoke.sh
scripts/release-check
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
git diff --check
```

## Done Checklist

- [x] Generated-view write behavior implemented behind explicit
  `--generated-views`.
- [x] Unsupported or ambiguous generated-view/generator shapes refuse before
  writing.
- [x] Generated-view backups and manifest-last write behavior are covered.
- [x] Default dry-run and tooling-only write semantics remain unchanged.
- [x] Docs, changelog, plan state, and session log updated.
- [x] Full verification passes.
