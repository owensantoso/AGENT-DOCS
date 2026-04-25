# Implementation Briefs

This folder holds task-scoped execution briefs when a repo intentionally uses a central implementation-briefs folder.

The preferred newer shape is one folder per plan:

```text
<domain>/plans/<plan-slug>/
  plan.md
  impl-task-<task-ref>-<slug>.md
```

Use a central implementation-briefs folder only if that is simpler for the repo.

Use these when a task is:

- large enough to delegate
- tricky enough to need concrete execution steps
- easier to implement from a focused task doc than from the full milestone plan
- dependent enough that future implementers need an explicit note about sequencing or safe parallelism

Parent plan still wins on intent and scope.

Naming convention:

```text
impl-task-<task-ref>-<slug>.md
```

Use `<task-ref>` to mirror the parent-plan task numbers:

- single task: `2`
- contiguous range: `1-3`
- explicit grouped list: `1-2-and-4`

Each brief should also state:

- what it depends on
- what other work, if any, can run in parallel
- whether any parallel work needs disjoint file ownership
- what it owns versus what adjacent briefs own
- what invariants or UX behavior it must preserve
- the primary seam or file an implementer should start from
