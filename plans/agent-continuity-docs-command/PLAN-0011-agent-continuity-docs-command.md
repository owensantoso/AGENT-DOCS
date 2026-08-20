---
type: plan
document_format_version: 2
id: 01a02039-7a66-7447-8ff6-d33c3e7bbc7a
aliases:
  - "PLAN-0011"
title: Agent Continuity Structured Docs Command
domain: repo-health
status: completed
created_at: "2026-08-06 00:00:00 JST +0900"
updated_at: "2026-08-06 00:00:00 JST +0900"
owner: codex
areas:
  - agent-continuity
  - structured-docs
  - compatibility
related_specs:
  - SPEC-0004
related_sessions:
  - session-logs/2026-08-06-agent-continuity-docs-command.md
repo_state:
  based_on_commit: 9750871
  last_reviewed_commit: 9750871
---

# PLAN-0011 - Agent Continuity Structured Docs Command

## Goal

Finish the public rename by moving structured-document operations into the
`agent-continuity` command namespace while preserving old-project behavior.

## Implementation sequence

1. Rename the structured-doc implementation and smoke-test surfaces to Agent
   Continuity names.
2. Add `agent-continuity docs` dispatch.
3. Make new init/manifests/generator records canonical while teaching upgrade
   code both canonical and legacy shapes.
4. Keep a narrow `scripts/docs-meta` compatibility shim and legacy fixtures.
5. Migrate current reusable documentation, scaffolds, and checks.
6. Run canonical fresh-install tests, legacy-upgrade tests, and release checks.

## Non-goals

- Do not rewrite git history or falsify historical completed-plan commands.
- Do not remove compatibility before a separately reviewed deprecation window.
- Do not weaken manifest, path, checksum, backup, or generated-view safety.

## Completion criteria

- [x] Canonical command and repo-local tooling are implemented.
- [x] Fresh projects and manifests contain no canonical dependency on the old
      name.
- [x] Legacy projects remain supported through explicit compatibility paths.
- [x] Current docs and scaffold templates teach the canonical command.
- [x] Changelog and session receipt explain the migration.
- [x] Full verification passes.
