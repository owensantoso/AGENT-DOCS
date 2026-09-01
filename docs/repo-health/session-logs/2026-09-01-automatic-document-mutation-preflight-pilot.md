---
type: session-log
document_format_version: 2
id: 01a05bbf-be12-736c-a65b-f0d88f8bac82
aliases: []
title: Automatic Document Mutation Preflight Pilot
domain: repo-health
status: in_progress
created_at: "2026-09-01 15:54:47 JST +0900"
updated_at: "2026-09-01 15:55:27 JST +0900"
started_at: "2026-09-01 15:54:47 JST +0900"
ended_at:
timezone: "JST +0900"
participants:
  - Codex root task
  - determinism audit-to-roadmap reviewer
  - Agent Continuity code-path explorer
areas: []
related_plans:
  - 01a05bbf-bcc2-78c2-84f0-153477fae16f
related_briefs:
  - 01a05bbf-f319-75db-adab-c61cd891be5a
related_specs:
  - 01a05bbf-bc0f-7cab-9527-aee9ab9194c2
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-09-01 - Automatic Document Mutation Preflight Pilot

## Session metadata

- Started: 2026-09-01 15:54:47 JST +0900
- Ended: in progress
- Timezone: JST +0900
- Participants: Codex root task; determinism audit-to-roadmap reviewer; Agent
  Continuity code-path explorer
- Todo-backed work: none recorded

## Goal

Dogfood Determinism Audit by converting `AC-DET-04` from a read-only finding
into one proportional, evaluated Agent Continuity contract pilot.

## Timeline

- 2026-09-01 15:54:47 JST +0900 - Session started.
- 2026-09-01 15:55 JST +0900 - Two independent read-only reviews selected the
  doctor-at-mutation pilot and mapped its code seam, assurance target, fixtures,
  repair exceptions, and prose-retirement boundary.
- 2026-09-01 15:55 JST +0900 - Created the owning spec, staged hardening plan,
  first implementation brief, and focused evaluation record.

## Context read

- `docs/repo-health/audits/AUDT-agent-continuity-determinism-audit.md`
- `scripts/agent-continuity`
- `scripts/agent-continuity-docs`
- `tests/agent-continuity-doctor-upgrade-smoke.sh`
- `tests/agent-continuity-docs-smoke.sh`
- General control-chain model and Agent Continuity fixture in the sibling
  `determinism-audit` repository

## Changes

- Durable planning and evaluation artifacts created; implementation pending.

## Decisions

- Pilot `AC-DET-04` because it changes invocation of an already-proven evaluator
  rather than inventing commit, session, remote-policy, or registry semantics.
- Target only `E3 T2 R2 A2 P1 D1` in this slice.
- Use a machine-stable mutation policy; never parse human doctor output.
- Preserve generated-view and UUID-migration repair paths.
- Retire prose only after release, installation, and cold adopter proof.

## Verification

Pending implementation.

## Follow-ups

- Implement and run the focused evaluation.
- Rerun the audit before choosing the next control.
