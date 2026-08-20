---
type: learning
document_format_version: 2
id: 01a0211d-8e63-709e-9528-26425072b798
aliases: []
title: Workflow Failure - Stale Project Tooling Created Legacy Numbered Docs
domain: workflow
status: active
learning_type: lesson
created_at: "2026-08-21 06:39:40 JST +0900"
updated_at: "2026-08-21 06:39:40 JST +0900"
owner: 
source:
  type: task
  link: codex://threads/01a020c4-abdd-7061-9700-61b55d1d8e87
  notes:
areas: []
related_specs: []
related_plans: []
related_briefs: []
related_adrs: []
related_sessions: []
related_research: []
related_todos: []
related_questions: []
supersedes: []
superseded_by: []
linked_paths: []
repo_state:
  based_on_commit: f573871360fbfca45d3c4196a23821554b96e7d2
  last_reviewed_commit: f573871360fbfca45d3c4196a23821554b96e7d2
---

# Workflow Failure - Stale Project Tooling Created Legacy Numbered Docs

## What We Learned

A repository can correctly instruct an agent to use its local Agent Continuity
tool and still be wrong at a newer document-format boundary. Repository-local
instructions and scripts are snapshots. Without a current-version preflight, a
cold agent cannot distinguish "canonical for this checkout" from "superseded by
the installed Agent Continuity release."

The safe gate belongs before the first structured-doc mutation, not after a
numbered plan has already been drafted. `agent-continuity doctor .` compares the
manifest, owned tooling, installed release, and document-format state without
changing project files.

## Previous Assumption

The workflow assumed agents would encounter the newer UUID guidance through the
current CLI or scaffold before using a repo-local document command. In practice,
an existing worktree's `AGENTS.md` explicitly routed the agent to an older local
script, and that instruction won before any version comparison happened.

## Evidence / Source

An active project worktree with manifest schema 1 and 141 version 1 documents
ran its repo-local `next plan` command and received `PLAN-0021`. The canonical
Agent Continuity CLI classified the same checkout as requiring release, tooling,
and document-format upgrades. Its UUID migration preview generated one plan for
all 141 documents, showing that the recovery is automated rather than a manual
file-by-file rewrite.

## Where This Should Change Behavior

- Fresh scaffolded `AGENTS.md` files require `agent-continuity doctor .` before
  the first Agent Continuity docs or tooling mutation in each task.
- The structured-doc workflow applies the same gate before doc-type selection or
  repo-local document commands.
- When drift is reported, agents must not create more legacy documents. They
  either upgrade/migrate or coordinate with the task that owns uncommitted docs.
- Migration remains plan-locked: generate one mapping, commit it, then apply that
  exact mapping and verify the receipt.

## Related Open Questions

- Whether a future installed CLI should offer an explicit remote-update check in
  addition to comparing projects against the locally installed release.
