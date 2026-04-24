# Implementation Brief Template

Use this for new `impl-*` docs.

Keep it concrete enough for delegation, but do not turn it into a pseudo-patch.

---
type: implementation-brief
domain: product
status: draft
created_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
updated_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
planned_execution_start:
planned_execution_end:
actual_execution_start:
actual_execution_end:
parent_plan:
task_refs: []
owner:
depends_on: []
parallel_with: []
related_specs: []
related_adrs: []
related_sessions: []
---

# Implementation Brief - <Plan/Task Title>

## Parent plan

- [plan.md](plan.md)

<Optional note if this brief intentionally groups multiple parent-plan tasks.>

## Task goal

<What this bounded task or grouped task should accomplish, in plain language.>

After this task:

- <outcome>
- <outcome>
- <outcome>

## Scope

In scope:

- <owned work>
- <owned work>
- <owned work>

Out of scope:

- <explicit non-goal>
- <explicit non-goal>
- <explicit non-goal>

## Ownership

- Owns: <files, seams, or behavior this brief is responsible for>
- Adjacent briefs own: <nearby seams this brief must not absorb>
- Integration expectation: <whether this brief is standalone or expected to integrate parallel slices>

## Preserve

- <invariant or UX behavior that must not regress>
- <invariant or UX behavior that must not regress>
- <constraint from the parent plan>

## Dependencies / parallelization

- Depends on: <brief path(s), task numbers, or "parent-plan prerequisites only">
- Can run in parallel with: <brief path(s) or "none">
- Write-conflict notes: <which files or surfaces must stay disjoint if parallelized>

## Entry point

- Start from: `<primary file>`
- Main seam to extend: <repository, view model, settings seam, migration seam, service seam, etc.>

## Files to read first

- `<important file 1>`
- `<important file 2>`
- `<important file 3>`

## Files likely to change

Create:

```text
<new files>
```

Modify:

```text
<existing files>
```

## Execution steps

### 1. <Step title>

<Concrete instruction.>

### 2. <Step title>

<Concrete instruction.>

### 3. <Step title>

<Concrete instruction.>

### 4. <Step title>

<Concrete instruction.>

## Verification

Run:

```bash
<focused verification commands>
```

Also run if this task touches schema, settings storage, shared persistence, or integration plumbing:

```bash
<migration, reset, smoke, or broader verification commands>
```

Manual smoke if relevant:

- <manual check>
- <manual check>

## Risks / traps

- <common failure mode>
- <boundary or scope trap>
- <regression risk>

## Review focus

- Spec reviewer: <what to check for plan compliance>
- Code reviewer: <what quality or architecture risk to scrutinize>

## Done checklist

- [ ] <done condition>
- [ ] <done condition>
- [ ] <verification complete>
