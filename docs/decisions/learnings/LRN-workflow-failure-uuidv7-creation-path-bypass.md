---
type: learning
document_format_version: 2
id: 01a05af3-a18a-72d6-9dad-83fd39ff27d3
aliases: []
title: Workflow Failure - UUIDv7 Creation Path Bypass
domain: workflow
status: active
learning_type: lesson
created_at: "2026-09-01 12:11:51 JST +0900"
updated_at: "2026-09-01 12:24:00 JST +0900"
owner: Codex
source:
  type: codex-task
  link: codex://threads/01a0498d-557e-78b0-b276-b5d3e34cf858
  notes:
areas: []
related_specs: []
related_plans: []
related_briefs: []
related_adrs: []
related_sessions:
  - 01a05af8-6ca8-7b57-a5f0-f4e6a81e9736
related_research: []
related_todos: []
related_questions: []
supersedes: []
superseded_by: []
linked_paths:
  - scripts/agent-continuity-docs
  - tests/agent-continuity-docs-smoke.sh
  - scripts/README.md
  - skills/structured-docs-workflow/SKILL.md
  - scaffold/skills/structured-docs-workflow/SKILL.md
  - scaffold/docs/repo-health/session-logs/README.md
  - scaffold/docs/repo-health/session-logs/YYYY-MM-DD-session-title.md
repo_state:
  based_on_commit: 55f9b242f1bbed6888e21ec8fac9e62217967a0b
  last_reviewed_commit: 55f9b242f1bbed6888e21ec8fac9e62217967a0b
---

# Workflow Failure - UUIDv7 Creation Path Bypass

## Intended Outcome

Fresh Agent Continuity documents should receive UUID version 7 (UUIDv7)
identity deterministically. Owen should never have to remind an agent which UUID
variant a document-format-v2 record requires.

The current delivery stage is a bounded workflow correction. The decision to
prove is whether one first-class session-log creation path closes the only
frequent structured-doc family that still requires manual identity handling.

## Observed Failure

During the LogicVein mounted-source slice, an implementation brief and session
log were hand-authored with generic UUIDs. `agent-continuity docs check`
correctly rejected both because document format v2 requires RFC 9562 UUIDv7.
The documents then had to be re-identified and every reference regenerated.

Owen identified this as a repeated cross-project pattern rather than a one-off
typo.

## Evidence And Cost

- `agent-continuity docs new impl` already called the correct UUIDv7 generator;
  hand-authoring bypassed that supported path.
- `agent-continuity docs new` had no `session` or `session-log` family.
- The shipped session example omitted `document_format_version`, `id`, and
  `aliases`, requiring manual identity decisions.
- The immediate project gate failed, followed by reference replacement,
  generated-view regeneration, and another full gate.

## Contributing Causes

| Source | Classification | Contribution |
|---|---|---|
| Supported brief command was bypassed | Agent execution miss | A correct-by-construction route existed but was not used. |
| Session-log family absent from `docs new` | Tooling gap | Manual creation remained necessary for a routine durable document. |
| Copy-first session template lacked v2 identity | Template incentive | The nearest example invited a format-v1-shaped document. |
| Skill said “use” or “prefer” rather than “must begin through” | Instruction weakness | Prose did not establish one canonical creation entrance. |

## Corrected Stage And First Real Test

Adapt the existing generator instead of adding another identity system. The
first real test is one disposable adopter repository where:

```text
agent-continuity docs new session "Cold UUID Session"
  -> dated session-log path
  -> UUIDv7 plus aliases: []
  -> in_progress lifecycle and exact local timestamps
  -> agent-continuity docs check passes
```

Stop after that vertical path and the existing release gate pass. Do not widen
this slice into migration or arbitrary document-family generation.

## Risk Decisions And Deferred Triggers

- Existing bad identities are never silently changed. Revisit migration only
  through the existing plan-locked migration workflow.
- A standalone `generate-id` command is deferred because it would preserve the
  split manual workflow this slice is removing. Reconsider only if a real
  unsupported document family repeatedly needs fresh structured identity.
- Document-format-v1 compatibility remains unchanged.

## Authoritative Changes

- `scripts/agent-continuity-docs`
- `tests/agent-continuity-docs-smoke.sh`
- `scripts/README.md`
- `skills/structured-docs-workflow/SKILL.md`
- `scaffold/skills/structured-docs-workflow/SKILL.md`
- `scaffold/docs/repo-health/session-logs/README.md`
- `scaffold/docs/repo-health/session-logs/YYYY-MM-DD-session-title.md`
- `CHANGELOG.md`

## Recurrence Checks

- Every supported generated family, including session logs, must be v2,
  UUIDv7, and aliasless in smoke coverage.
- The session-log smoke case must assert its dated path and lifecycle fields.
- A fixed UUIDv4 document must continue to fail `docs check`.
- A cold installed invocation must use the public command surface, not import
  the generator directly.

## Verification

- `tests/agent-continuity-docs-smoke.sh` passed with generated in-progress and
  completed sessions plus explicit UUIDv4 rejection.
- `scripts/release-check` passed all installation, initialization, doctor,
  upgrade, documentation, link, smoke, syntax, and diff checks.
- The canonical checkout was installed locally through `install.sh --no-run`;
  the installed `agent-continuity` command resolves to this checkout.
- A disposable cold adopter used the installed public command to create a
  session with UUID version 7, document format 2, `aliases: []`, an
  `in_progress` lifecycle, and a passing `agent-continuity docs check`.
- Publication and remote continuous integration remain pending explicit
  authority. Local verification does not imply public release.

## Previous Assumption

The workflow assumed correct validation plus general “use the CLI” guidance was
enough. The failure shows creation must be correct by construction for routine
families; validation remains the backstop for unsupported manual work.
