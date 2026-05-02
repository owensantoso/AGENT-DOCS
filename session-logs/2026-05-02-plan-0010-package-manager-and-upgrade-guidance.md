---
type: session-log
title: PLAN-0010 Package Manager And Upgrade Guidance
domain: repo-health
status: completed
created_at: "2026-05-02 20:40:37 JST +0900"
updated_at: "2026-05-02 20:40:37 JST +0900"
started_at: "2026-05-02 20:40:37 JST +0900"
ended_at: "2026-05-02 20:40:37 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - repo-health
related_plans:
  - plans/package-manager-distribution/PLAN-0010-package-manager-distribution.md
related_briefs: []
related_specs: []
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-05-02 - PLAN-0010 Package Manager And Upgrade Guidance

## Goal

Make the package-manager follow-up visible and document how existing projects
with older AGENT-DOCS installs should move onto the Agent Continuity command
surface safely.

## Changes

- Added PLAN-0010 as the draft follow-up for Homebrew or similar
  package-manager distribution.
- Added README guidance for updating the local command and inspecting an
  existing project.
- Added INSTALL guidance that distinguishes manifest-backed upgrades,
  legacy/manual-review baselines, generated-view refreshes, and project-owned
  Markdown review.

## Verification

- `scripts/release-check`
- `scripts/changelog-check`
- `scripts/docs-meta --root plans check`
- `scripts/docs-meta --root plans check-links`
- `git diff --check`
