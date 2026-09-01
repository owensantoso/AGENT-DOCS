---
type: plan
document_format_version: 2
id: 01a05bbf-bcc2-78c2-84f0-153477fae16f
aliases: []
title: Agent Continuity Determinism Hardening
domain: repo-health
status: in_progress
created_at: "2026-09-01 15:54:47 JST +0900"
updated_at: "2026-09-01 15:55:27 JST +0900"
owner:
sequence:
  roadmap:
  sort_key:
  lane: repo-health
  after: []
  before: []
areas: []
related_specs:
  - 01a05bbf-bc0f-7cab-9527-aee9ab9194c2
related_adrs: []
related_sessions:
  - 01a05bbf-be12-736c-a65b-f0d88f8bac82
related_issues: []
related_prs: []
linked_paths: []
repo_state:
  based_on_commit: 56ce042f774de556b3dae50e5333faae3430a303
  last_reviewed_commit: 56ce042f774de556b3dae50e5333faae3430a303
---

# Agent Continuity Determinism Hardening

## Goal

Increase Agent Continuity determinism one bounded control at a time, starting
with automatic document-mutation preflight, while preserving explicit semantic,
human, external-policy, and repair-authority boundaries.

## Architecture

The completed audit is read-only evidence. Each hardening slice follows:

```text
AUDT finding -> SPEC invariant -> PLAN stage -> IMPL boundary -> EVAL fixtures
             -> implementation -> rerun audit -> retire only redundant prose
```

Agent Continuity continues to own its requirements and enforcement code. The
sibling `determinism-audit` repository owns the reusable control-chain schema
and revision-pinned case-study view.

The first slice adds a machine-stable mutation policy to `doctor` and calls it
inside the shipped document helper before supported writes. It does not add
remote authority or autonomous repair.

## Task Dependencies / Parallelization

- The automatic-preflight spec and focused evaluation precede implementation.
- Mutation classification and doctor policy must land together; separating them
  would create either an unused evaluator or an unguarded trigger.
- Focused fixtures may be authored alongside implementation after their red
  expectations are fixed.
- Prose reduction follows release, installation, and cold downstream proof. It
  must not run in parallel with the initial source implementation.
- Later controls depend on a rerun of the audit after this pilot. They do not
  block the first slice.

## Implementation Tasks

- [ ] Pilot `AC-DET-04`: bind doctor policy to every supported document mutation
  and verify no-write refusal.
- [ ] Re-audit `AC-DET-04`, record the achieved vector and remaining bypasses,
  then reduce only redundant preflight prose after release/install/cold proof.
- [ ] Harden document validation reach and generated-view presence from
  `AC-DET-03` with explicit failing fixtures.
- [ ] Specify commit/range metadata semantics for `AC-DET-01` before adding
  hooks or CI enforcement.
- [ ] Specify qualifying-change and exemption semantics for session receipts in
  `AC-DET-07`.
- [ ] Stabilize local checks before requesting separate authority for GitHub
  protection from `AC-DET-05`.
- [ ] Define an adopter registry before recurring drift work from `AC-DET-06`.

## Validation

For the first pilot:

```bash
tests/agent-continuity-docs-preflight-smoke.sh
tests/agent-continuity-doctor-upgrade-smoke.sh
tests/agent-continuity-docs-smoke.sh
scripts/release-check
```

Evaluation must include healthy success, blocked drift with unchanged bytes,
repair-path reachability, read-only diagnosis, command-classification coverage,
and a cold installed complete-profile adopter before prose retirement.

## Completion Criteria

The plan remains open across staged controls. The first pilot is complete when:

- `AC-DET-04` reaches at least `E3 T2 R2 A2 P1 D1` on evidence;
- every shipped document command has an explicit mutation classification;
- unsafe state refuses before mutation through both supported entry paths;
- repair and diagnosis paths remain usable;
- the full release suite passes;
- a released and installed cold adopter passes before duplicate manual preflight
  prose is removed; and
- the audit and evaluation record achieved state without claiming fleet reach,
  remote enforcement, or direct-editor interception.

Do not maximize every assurance axis automatically. Complete one evidence-backed
slice, rerun the audit, and let the changed evidence choose the next control.
