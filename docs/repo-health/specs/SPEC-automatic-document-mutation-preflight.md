---
type: spec
document_format_version: 2
id: 01a05bbf-bc0f-7cab-9527-aee9ab9194c2
aliases: []
title: Automatic Document Mutation Preflight
spec_type: repo-health
domain: repo-health
status: approved
created_at: "2026-09-01 15:54:47 JST +0900"
updated_at: "2026-09-01 15:55:27 JST +0900"
owner:
source:
  type: conversation
  link: codex://threads/01a05af8-157d-7423-9abc-216d2842f4c8
  notes:
areas: []
related_plans:
  - 01a05bbf-bcc2-78c2-84f0-153477fae16f
related_issues: []
related_prs: []
related_adrs: []
related_sessions:
  - 01a05bbf-be12-736c-a65b-f0d88f8bac82
supersedes: []
superseded_by: []
linked_paths: []
repo_state:
  based_on_commit: 56ce042f774de556b3dae50e5333faae3430a303
  last_reviewed_commit: 56ce042f774de556b3dae50e5333faae3430a303
---

# Automatic Document Mutation Preflight

## Summary

Supported `agent-continuity docs` mutations in a manifest-backed repository
must automatically run a machine-stable Agent Continuity drift policy before
the first write. Unsafe installed-release, owned-tooling, or document-format
state must refuse the mutation without changing repository bytes.

This is the first bounded pilot from `AC-DET-04` in the Agent Continuity
determinism audit. It moves an existing evaluator from prose-owned invocation to
the mutation boundary; it does not invent a new semantic rule.

## Problem / Opportunity

`agent-continuity doctor` already detects release, owned-tooling, manifest,
document-format, and generated-view drift deterministically. The complete
scaffold currently relies on `AGENTS.md` and skills to remind an agent to run it
before structured-document changes. The checker is strong, but its ignition is
probabilistic.

Naively blocking on any generic `doctor` warning would also block legitimate
repair paths: generated-view commands repair generated-view drift, and UUID
migration repairs document-format drift. The write boundary needs an explicit
policy rather than parsing human-formatted output.

## Goals

- Invoke preflight automatically for every supported write-capable document
  subcommand in repositories with `.agent-continuity/manifest.json`.
- Refuse unsafe writes before any repository bytes change.
- Keep read-only diagnosis and preview commands available during drift.
- Give generated-view and UUID-migration repair paths the smallest exceptions
  needed to repair their own category.
- Keep successful existing command output stable.
- Raise `AC-DET-04` from `E3 T1 R2 A0 P1 D1` to the proportional pilot target
  `E3 T2 R2 A2 P1 D1`.

## Non-Goals

- Intercept direct editor, shell, or `apply_patch` writes.
- Upgrade stale pre-pilot vendored tooling automatically.
- Create fleet-wide reach, periodic drift monitoring, or revision-bound run
  receipts.
- Configure Git hooks, GitHub Actions, branch protection, or rulesets.
- Decide truthful document content, document type, concurrent-work ownership,
  or whether a proposed migration/upgrade should be authorized.
- Remove the diagnostic `doctor` command or all Agent Continuity prose.

## Current Behavior / Context

- `doctor` has versioned implementation and passing/failing fixtures.
- `agent-continuity docs` dispatches directly to the document helper without a
  preflight.
- The document helper exposes both always-writing and conditional-writing
  commands alongside read-only diagnosis.
- `view` always writes a generated view even though its name sounds read-only.
- The canonical source repository has no manifest; source-repository document
  work must remain possible and is outside adopter preflight applicability.

## Desired Behavior / Target State

For a manifest-backed adopter:

```text
parse arguments -> resolve docs root -> classify mutation policy
                -> resolve repository -> run doctor policy
                -> refuse or dispatch existing command
```

Policy families:

- `docs-write`: ordinary authored or generated document mutation.
- `docs-migration-write`: UUID migration preparation or application.
- no policy: known read-only or dry-run command.

The policy returns `0` when the mutation may proceed, `1` for applicable
actionable drift, and `2` for invalid, incompatible, unavailable, or unsafe
state. Success is silent. Failure is named on standard error.

## Requirements

1. The document helper must classify every current subcommand as read-only,
   ordinary write, conditional write, or migration write. An unknown future
   command must fail closed as a write candidate.
2. Always-writing commands are `new`, `set-status`, `update`, and `view`.
3. `retire-id`, `normalize-links`, `move`, `health`, and `roadmap` are writes
   only when `--write` is present.
4. `migrate-uuids` uses migration policy only when `--write` is present.
5. The remaining current commands and conditional-command previews are
   read-only and must not require mutation preflight.
6. Resolve the target repository through Git top-level from the document root,
   with a bounded non-Git fallback. Skip adopter preflight when no canonical
   manifest exists.
7. The top-level dispatcher must pass its exact executable path to the helper.
   A manifest-backed direct helper invocation may use a compatible installed
   dispatcher resolved from `PATH`; it must fail closed if no compatible gate
   is available.
8. `docs-write` must block legacy/incompatible manifests, document-format
   migration, missing or modified owned tooling, installed-release drift, safe
   owned-tool additions, and refused/unknown shapes.
9. `docs-write` may allow generated-view refresh notices and project-owned
   manual-review notices; it must never interpret them as repaired.
10. `docs-migration-write` may additionally allow the document-format migration
    category because it is the repair path. It must still block release,
    owned-tooling, and incompatible-state drift.
11. Failure must happen before document reads that can write caches or any
    explicit repository mutation. A before/after tracked-tree digest must be
    unchanged.
12. Successful preflight must add no output to existing successful document
    commands.
13. Doctor, format status, migration preview, checks, links, review, and other
    read-only diagnosis must remain callable during blocking drift.

## Open Questions

- Whether a later proof layer should emit revision-bound preflight receipts.
- Whether stale pre-pilot helpers should eventually be detected by a registry
  or installation self-audit.
- Whether generated-view drift should remain allowed for all ordinary writes or
  become command-specific after real adopter evidence.

## Test / Validation Expectations

Use a small focused smoke suite plus the existing release baseline:

1. Every current subcommand has an asserted policy classification.
2. Healthy manifest-backed `docs new` succeeds and creates only the expected
   document.
3. Installed-release or owned-tool drift makes the same command fail before any
   bytes change.
4. Generated-view-only drift remains repairable by `docs update`.
5. A v1 document blocks ordinary writes while migration preview and migration
   write remain reachable.
6. Owned-tool drift blocks migration write too.
7. Read-only diagnosis remains available under blocking drift.
8. Both top-level and direct shipped helper entry points are covered.
9. `tests/agent-continuity-docs-smoke.sh` and `scripts/release-check` pass.

## Paper Trail

- Audit: `docs/repo-health/audits/AUDT-agent-continuity-determinism-audit.md`
- Plan: `docs/repo-health/plans/PLAN-agent-continuity-determinism-hardening/PLAN-agent-continuity-determinism-hardening.md`
- Brief: `docs/repo-health/plans/PLAN-agent-continuity-determinism-hardening/IMPL-bind-doctor-to-document-mutations.md`
- Evaluation: `docs/repo-health/evaluations/EVAL-automatic-document-preflight-pilot.md`
- Session: `docs/repo-health/session-logs/2026-09-01-automatic-document-mutation-preflight-pilot.md`
