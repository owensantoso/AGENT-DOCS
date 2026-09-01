---
type: evaluation
document_format_version: 2
id: 01a05bbf-bd70-7c1b-ad48-31887886423e
aliases: []
title: Automatic Document Preflight Pilot
domain: repo-health
status: active
created_at: "2026-09-01 15:54:47 JST +0900"
updated_at: "2026-09-01 15:55:27 JST +0900"
owner:
hypothesis: Automatic mutation-boundary preflight blocks unsafe document writes without blocking healthy, repair, or read-only paths.
artifact_root: artifacts/evaluations/01a05bbf-bd70-7c1b-ad48-31887886423e/
dataset_version:
fixture_digest:
run_command: tests/agent-continuity-docs-preflight-smoke.sh
metrics_version: automatic-document-preflight-v1
baseline_eval:
related_research: []
related_diagnostics: []
related_adrs: []
related_specs:
  - 01a05bbf-bc0f-7cab-9527-aee9ab9194c2
related_plans:
  - 01a05bbf-bcc2-78c2-84f0-153477fae16f
related_sessions:
  - 01a05bbf-be12-736c-a65b-f0d88f8bac82
linked_paths: []
repo_state:
  based_on_commit: 56ce042f774de556b3dae50e5333faae3430a303
  last_reviewed_commit: 56ce042f774de556b3dae50e5333faae3430a303
---

# Automatic Document Preflight Pilot

## Hypothesis

A machine-stable doctor policy invoked inside the shipped document helper can
raise trigger and local authority without changing the evaluator, inventing a
new semantic requirement, or breaking the commands that repair detected drift.

## Candidates

- Baseline: manual `doctor` reminder in `AGENTS.md` and skills.
- Pilot: automatic policy classification and refusal at the document mutation
  boundary.

## Dataset / Fixtures

1. Healthy complete-profile manifest and ordinary `docs new`.
2. Installed-release drift and an attempted ordinary mutation.
3. Owned-tool checksum drift and attempted ordinary/migration writes.
4. Generated-view-only drift and `docs update` repair.
5. Document-format-v1 drift, ordinary mutation refusal, and UUID migration
   preview/write reachability.
6. Read-only doctor and document diagnosis under blocking drift.
7. Current command taxonomy through both top-level and direct helper entry.

## Metrics

- Unsafe mutation refusal rate: `100%` across declared blocking fixtures.
- Bytes changed on refusal: `0` by a stable repository-tree digest.
- Healthy mutation success: `100%` for the representative fixture.
- Repair-path reachability: `100%` for generated-view and migration fixtures.
- Read-only diagnosis reachability: `100%` for declared diagnostic fixtures.
- Command classification coverage: every current subcommand asserted.
- Existing release regression: `scripts/release-check` passes.

## Run Command

```bash
tests/agent-continuity-docs-preflight-smoke.sh
scripts/release-check
```

## Output Format

The focused smoke suite prints one success line and exits `0`. Failure output
names the policy, command, fixture, and unexpected mutation or exit code. The
session log records a compact receipt; raw temporary fixture trees are deleted
by the test harness.

## Good-Enough Criteria

- All listed metrics pass once locally.
- The full release suite remains green.
- One installed cold complete-profile adopter passes before prose is retired.
- No dashboard, statistical benchmark, repeated stochastic trial, or remote CI
  is required for this deterministic bounded pilot.

## Results

Pending implementation.

## Recommendation / ADR Input

Pending. If any write occurs before refusal or a repair path is blocked, keep
the manual preflight prose and revise the policy boundary before proceeding.

## Reproduction Notes

Run from the Agent Continuity repository root. The focused script owns only
temporary repositories and must not mutate installed skills or downstream
projects.

## Artifact Policy

Commit summaries and sanitized excerpts. Keep raw private JSONL, transcripts, media, and payload dumps local unless explicitly sanitized.
