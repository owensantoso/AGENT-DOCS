---
type: evaluation
document_format_version: 2
id: 01a05bbf-bd70-7c1b-ad48-31887886423e
aliases: []
title: Automatic Document Preflight Pilot
domain: repo-health
status: completed
created_at: "2026-09-01 15:54:47 JST +0900"
updated_at: "2026-09-01 16:43:44 JST +0900"
owner:
hypothesis: Automatic mutation-boundary preflight blocks unsafe document writes without blocking healthy, repair, or read-only paths.
artifact_root: artifacts/evaluations/01a05bbf-bd70-7c1b-ad48-31887886423e/
dataset_version: agent-continuity-2026.09.01.2
fixture_digest: git:0ae69937e805307cc385af6e8da518d56ba12215
run_command: tests/agent-continuity-docs-preflight-smoke.sh
metrics_version: automatic-document-preflight-v1
baseline_eval: E3 T1 R2 A0 P1 D1
related_research: []
related_diagnostics: []
related_adrs: []
related_specs:
  - 01a05bbf-bc0f-7cab-9527-aee9ab9194c2
related_plans:
  - 01a05bbf-bcc2-78c2-84f0-153477fae16f
related_sessions:
  - 01a05bbf-be12-736c-a65b-f0d88f8bac82
linked_paths:
  - scripts/agent-continuity
  - scripts/agent-continuity-docs
  - tests/agent-continuity-docs-preflight-smoke.sh
  - scripts/release-check
repo_state:
  based_on_commit: 56ce042f774de556b3dae50e5333faae3430a303
  last_reviewed_commit: 0ae69937e805307cc385af6e8da518d56ba12215
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

- Every current document subcommand has an asserted mutation classification;
  unknown future commands enter the guarded write class.
- Healthy top-level and direct-installed-helper writes passed without changing
  existing successful output.
- Release, owned-tooling, canonical-root, custom-root, and nested non-Git drift
  fixtures refused before mutation. Stable before/after tree digests matched.
- Generated-view refresh, UUID migration, and read-only diagnosis remained
  reachable.
- An independent review found three pre-release gaps: a dispatcher injected
  only by the release harness, policy inspection of the wrong document root,
  and shallow non-Git manifest discovery. Regression fixtures were added after
  all three were fixed; re-review found no remaining P1/P2 code issue.
- `scripts/release-check` passed from clean detached worktrees at releases
  `2026.09.01.1` and `2026.09.01.2`. The second release includes the post-proof
  prose reduction.

Achieved assurance: `E3 T2 R2 A2 P1 D2`.

Proof remains `P1`: the evaluation is revision-bound, but ordinary successful
preflight executions are silent and do not emit their own revision- and
policy-bound receipts. Reach remains `R2`: supported manifest-backed command
paths are covered, while direct editor and shell writes are outside the guard.

## Recommendation / ADR Input

Accept the pilot. It exceeds the proportional target on drift and meets the
trigger and local-authority goals without overstating proof, fleet reach, or
remote enforcement. Keep run receipts and direct-write interception as separate
future controls rather than enlarging this slice.

## Reproduction Notes

Check out `0ae69937e805307cc385af6e8da518d56ba12215` and run from the Agent
Continuity repository root. The focused and full suites own only temporary
fixtures; they do not mutate installed skills or downstream projects.

## Artifact Policy

Commit summaries and sanitized excerpts. Keep raw private JSONL, transcripts, media, and payload dumps local unless explicitly sanitized.
