---
type: session-log
title: PLAN-0009 GitHub Repo Rename
domain: repo-health
status: completed
created_at: "2026-05-02 11:19:23 JST +0900"
updated_at: "2026-05-02 11:19:23 JST +0900"
started_at: "2026-05-02 11:19:23 JST +0900"
ended_at: "2026-05-02 11:19:23 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - repo-health
related_plans:
  - plans/github-repo-rename/PLAN-0009-github-repo-rename.md
related_briefs: []
related_specs: []
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-05-02 - PLAN-0009 GitHub Repo Rename

## Goal

Rename the public repository to `agent-continuity` and update the install
surface so new adopters use the new repository URL immediately.

## Changes

- Renamed GitHub repository from `owensantoso/AGENT-DOCS` to
  `owensantoso/agent-continuity`.
- Updated local `origin` to
  `https://github.com/owensantoso/agent-continuity.git`.
- Updated public install, private-fork, source archive, and test fixture URLs
  from `AGENT-DOCS` to `agent-continuity`.
- Kept compatibility commands, environment variables, and `.agent-docs`
  manifest paths unchanged.

## Verification

- `gh repo view --json name,owner,url`
- `scripts/release-check`
- `scripts/changelog-check`
- `scripts/docs-meta --root plans check`
- `scripts/docs-meta --root plans check-links`
- `git diff --check`
