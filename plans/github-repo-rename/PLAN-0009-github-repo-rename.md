---
type: plan
id: PLAN-0009
title: GitHub Repo Rename
domain: repo-health
status: completed
created_at: "2026-05-02 11:19:23 JST +0900"
updated_at: "2026-05-02 11:19:23 JST +0900"
planned_execution_start:
planned_execution_end:
actual_execution_start: "2026-05-02 11:19:23 JST +0900"
actual_execution_end: "2026-05-02 11:19:23 JST +0900"
owner: codex
sequence:
  roadmap:
  sort_key:
  lane: repo-health
  after:
    - PLAN-0008
  before: []
areas:
  - repo-health
related_specs: []
related_concepts: []
related_adrs: []
related_sessions:
  - session-logs/2026-05-02-plan-0009-github-repo-rename.md
related_issues: []
related_prs: []
repo_state:
  based_on_commit: 88d6ecd76dbc8c4e87df93c51b26222bcf61280c
  last_reviewed_commit: 88d6ecd76dbc8c4e87df93c51b26222bcf61280c
---

# PLAN-0009 - GitHub Repo Rename

## Goal

Rename the public GitHub repository from `AGENT-DOCS` to
`agent-continuity`, then update public install URLs and release/archive
references to use the new repository path.

## Scope

- Rename `owensantoso/AGENT-DOCS` to `owensantoso/agent-continuity` on GitHub.
- Update local `origin` to the new repository URL.
- Update public install URLs, private-fork examples, source archive examples,
  and test fixtures that intentionally reference this repository.
- Keep compatibility command names, environment variables, and local manifest
  paths unchanged in this slice.

## Non-Goals

- Do not rename `.agent-docs/manifest.json`.
- Do not rename `AGENT_DOCS_*` environment variables.
- Do not remove `agent-docs` or `agent-docs-init` compatibility commands.
- Do not rename every historical mention of AGENT-DOCS inside completed
  concepts and plans.

## Validation

```bash
scripts/release-check
scripts/changelog-check
scripts/docs-meta --root plans check
scripts/docs-meta --root plans check-links
git diff --check
gh repo view --json name,owner,url
```

## Completion Criteria

- [x] GitHub repository is named `owensantoso/agent-continuity`.
- [x] Local `origin` points at `https://github.com/owensantoso/agent-continuity.git`.
- [x] Public install examples use the new repository path.
- [x] Default installer source URL uses the new repository path.
- [x] Verification passes.
