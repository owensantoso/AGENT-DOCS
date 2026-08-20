---
type: spec
document_format_version: 2
id: 01a02039-7a66-7cd8-8f67-76e75cedc4f8
aliases:
  - "SPEC-0004"
title: Agent Continuity Structured Docs Command
domain: repo-health
spec_type: improvement
status: approved
created_at: "2026-08-06 00:00:00 JST +0900"
updated_at: "2026-08-06 00:00:00 JST +0900"
owner: codex
source:
  type: conversation
  link:
  notes: Human requested canonical Agent Continuity naming for new projects with legacy docs-meta compatibility.
related_plans:
  - PLAN-0011
linked_paths:
  - scripts/agent-continuity
  - scripts/agent-continuity-init
  - scripts/agent-continuity-docs
repo_state:
  based_on_commit: 9750871
  last_reviewed_commit: 9750871
---

# SPEC-0004 - Agent Continuity Structured Docs Command

## Problem

The product and installer are named Agent Continuity, but new-project guidance
still presents `docs-meta` as a separate first-class tool. That split makes a
new installation look partially renamed and caused an agent to describe the
legacy helper as the product workflow.

## Required behavior

1. New users run structured-document operations through
   `agent-continuity docs ...`.
2. New installations use Agent Continuity naming for the option, optional
   component, repo-local tool, smoke test, generated-view marker, and manifest
   generator.
3. Current guides, scaffold templates, and examples teach only the canonical
   Agent Continuity command unless they are specifically documenting migration.
4. Existing projects using `scripts/docs-meta`, `--docs-meta`, the `docs-meta`
   manifest component, or the `scripts/docs-meta update` generator continue to
   work.
5. Compatibility names are clearly labelled legacy and are not emitted by new
   installations.
6. Upgrade and baseline safety rules remain unchanged: preview first, no
   project-owned Markdown overwrite, checksummed owned tooling, and explicit
   generated-view writes.

## Compatibility boundary

Legacy spellings remain accepted inputs for old projects. They may appear in
compatibility shims, migration tests, historical records, and explanations of
old manifests. They must not remain the recommended command or the canonical
shape of newly generated projects.

## Definition of done

- `agent-continuity docs --help` and representative document commands work.
- A fresh expanded or complete install contains only canonically named owned
  document tooling and records only the canonical optional component.
- A legacy fixture with `scripts/docs-meta` and an old manifest still passes
  doctor/upgrade compatibility checks.
- Current reusable docs and scaffold instructions use `agent-continuity docs`.
- Focused smoke tests and the full release check pass.
