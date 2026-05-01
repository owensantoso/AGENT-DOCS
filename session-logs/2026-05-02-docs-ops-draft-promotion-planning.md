---
type: session-log
title: Docs Operations Draft Promotion Planning
domain: repo-health
status: completed
created_at: "2026-05-02 07:54:05 JST +0900"
updated_at: "2026-05-02 07:54:05 JST +0900"
owner: codex
areas:
  - agent-docs
  - docs-ops
  - docs-meta
related_docs:
  - plans/drafts/SPEC-DRAFT-docs-ops-command-surface-and-draft-promotion.md
  - plans/drafts/PLAN-DRAFT-docs-ops-command-surface-and-draft-promotion.md
repo_state:
  based_on_commit: f6719dd4eae34c5578f5c07b2b0ee251a69e730d
  last_reviewed_commit: f6719dd4eae34c5578f5c07b2b0ee251a69e730d
---

# Docs Operations Draft Promotion Planning

## Summary

Created a branch-local draft spec for the future Docs Operations command surface
and draft-to-stable promotion workflow. The draft avoids claiming `SPEC-0004`
while Agent Continuity and manifest work continues in parallel.

Added the matching branch-local draft plan so implementation can be scoped
without claiming `PLAN-0007`.

## Decisions Captured

- Treat `docs-meta` as the legacy compatibility command.
- Prefer `agent-docs docs ...` as the future public command namespace.
- Use `Docs Operations` as the capability name.
- Add draft planning docs under `plans/drafts/` to avoid parallel worktree ID
  conflicts.
- Promote drafts only after rebasing onto the branch that will own the final
  stable ID.
- Keep implementation briefs until after promotion unless delegation needs them
  earlier.

## Verification

- `scripts/docs-meta --root plans check`
- `scripts/docs-meta --root plans check-links`
