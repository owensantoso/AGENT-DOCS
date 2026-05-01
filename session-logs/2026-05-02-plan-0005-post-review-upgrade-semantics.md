---
type: session-log
title: PLAN-0005 Post Review Upgrade Semantics
domain: repo-health
status: completed
created_at: "2026-05-02 04:56:46 JST +0900"
updated_at: "2026-05-02 04:56:46 JST +0900"
started_at: "2026-05-02 04:22:00 JST +0900"
ended_at: "2026-05-02 04:56:46 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex
areas:
  - agent-docs
  - repo-health
related_plans:
  - plans/agent-docs-doctor-manifest-upgrade/PLAN-0005-agent-docs-doctor-manifest-upgrade.md
related_specs:
  - plans/agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md
related_adrs: []
related_todos: []
related_issues: []
related_prs: []
commits: []
---

# 2026-05-02 - PLAN-0005 Post Review Upgrade Semantics

## Goal

Run an extra post-merge review sweep on PLAN-0005 Slice B, fix worthwhile
classifier findings, and record the upgrade semantics that should govern the
remaining write-mode work.

## Review Inputs

Six focused review perspectives considered:

- product semantics and adopter mental model;
- schema/frontmatter migration compatibility;
- tooling-only write-mode engineering;
- dangerous project-doc replacement policy;
- agent-mediated adaptive update workflow;
- concrete migration failure modes.

## Decisions

- Bare `agent-docs upgrade` should remain read-only and behave as preview/report
  mode.
- `agent-docs upgrade --write --tooling-only` should only apply deterministic
  AGENT-DOCS-owned tooling and generated-view work.
- Project-owned Markdown should receive adaptive/manual review guidance, not
  automatic rewrites.
- Destructive project-owned doc replacement, if ever supported, should be a
  separate recovery/reset command with explicit paths, mandatory backups, typed
  confirmation, checksum revalidation, and audit records.
- Schema, frontmatter, parser, path, and template changes in project-owned docs
  are compatibility events. They should be reported with examples and suggested
  agent review prompts unless a deterministic migration is proven safe.

## Changes

- Hardened `agent-docs doctor` / `agent-docs upgrade --dry-run` classification
  after the review sweep.
- Renamed update wording from `safe automatic updates available` to the more
  conservative `candidate tooling updates available`.
- Updated SPEC-0003 and PLAN-0005 to preserve the upgrade semantics before
  Slice C write-mode implementation begins.

## Verification

- `tests/agent-docs-doctor-upgrade-smoke.sh`
- `tests/docs-meta-smoke.sh`
- `scripts/release-check`
