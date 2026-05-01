---
type: testing-guide
title: Testing Guide
domain: repo-health
status: draft
created_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
updated_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
owner:
surface:
areas: []
related_specs: []
related_plans: []
related_adrs: []
related_sessions: []
repo_state:
  based_on_commit:
  last_reviewed_commit:
---

# Testing Guide

Current verification guide for `<surface>`. This document should describe what the repo actually supports today, not an ideal future CI setup.

## What exists today

Current verification is a mix of:

- <test type>
- <test type>
- <manual or smoke type>

What does not exist yet:

- <missing automation>
- <missing automation>

## Primary commands

From the repo root:

```bash
./run
./run check
./run agent-check
<command>
<command>
```

If this repo has a root `./run` command, keep it as the first place humans and agents look for verification commands.

- `./run check` should be the fast handoff baseline: generated docs metadata if present, whitespace/diff hygiene, and the practical unit/test baseline.
- `./run agent-check` should be the fuller closeout/pre-commit sweep when the repo needs one: refresh/check generated docs, print repo-health advisory queues, run `git diff --check`, and run the practical test baseline.
- Destructive checks, device installs, cloud calls, database resets, and manual UI checks should remain explicit opt-ins unless the command name clearly says what it will do.

## What the tests cover well

- <coverage area>
- <coverage area>
- <coverage area>

## What still needs manual checking

- <manual check>
- <manual check>

## Smoke or integration checks

```bash
<smoke command>
```

Use this as a developer sanity check, not necessarily as a release gate.

## Typical verification bundles

### Docs-only change

- Read the affected source and docs carefully.
- Run `./run check` or the equivalent docs metadata checks when generated docs, IDs, frontmatter, links, or TODOs changed.

### Local feature change

```bash
./run check
<command>
<command>
```

Then run the most relevant manual checks.

### Meaningful closeout or pre-commit

```bash
./run agent-check
```

If `./run agent-check` does not exist yet, run the closest equivalent:

```bash
scripts/docs-meta update
scripts/docs-meta check
git diff --check
<primary test command>
```

Then add any surface-specific checks required by the changed area.

### Schema or backend-adjacent change

```bash
<command>
<command>
<command>
```

## Interpreting failures

- <common failure>
- <common failure>

## Current limits to remember

- passing tests do not prove end-to-end behavior
- smoke checks do not replace UI or integration verification
