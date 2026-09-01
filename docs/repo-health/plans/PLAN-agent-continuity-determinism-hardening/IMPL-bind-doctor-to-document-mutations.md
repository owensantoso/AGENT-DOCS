---
type: implementation-brief
document_format_version: 2
id: 01a05bbf-f319-75db-adab-c61cd891be5a
aliases: []
title: Bind Doctor to Document Mutations
domain: repo-health
status: in_progress
created_at: "2026-09-01 15:55:01 JST +0900"
updated_at: "2026-09-01 15:55:27 JST +0900"
parent_plan: 01a05bbf-bcc2-78c2-84f0-153477fae16f
task_refs: []
owner:
areas: []
depends_on: []
parallel_with: []
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

# Bind Doctor to Document Mutations

## Parent Plan

- 01a05bbf-bcc2-78c2-84f0-153477fae16f

## Task Goal

Raise `AC-DET-04` to the proportional pilot target by running a deterministic
doctor mutation policy before every supported document write, with no mutation
on refusal and no regression to repair or diagnostic commands.

## Scope

Owned implementation paths:

- `scripts/agent-continuity`
- `scripts/agent-continuity-docs`
- `tests/agent-continuity-docs-preflight-smoke.sh`
- `scripts/release-check`

Documentation, release metadata, installation, downstream prose reduction, and
remote policy are outside this brief and remain with the parent task.

## Execution Steps

1. Add an exact dispatcher path to the child environment.
2. Add a machine-stable `doctor --policy` contract with `docs-write` and
   `docs-migration-write` modes.
3. Add a fail-closed document-command mutation classifier.
4. Resolve the manifest-backed target repository from the document root.
5. Run the appropriate policy before reading or writing document state.
6. Keep successful command stdout unchanged and put refusals on stderr.
7. Add red-first healthy, drift, no-mutation, repair, diagnosis, and entry-path
   fixtures.
8. Add the focused smoke suite to `scripts/release-check`.

## Verification

```bash
tests/agent-continuity-docs-preflight-smoke.sh
tests/agent-continuity-doctor-upgrade-smoke.sh
tests/agent-continuity-docs-smoke.sh
scripts/release-check
```

Record exact before/after digests for refused mutations and retain expected
policy exit codes in the evaluation.

## Done Checklist

- [ ] Implementation complete
- [ ] Verification complete
