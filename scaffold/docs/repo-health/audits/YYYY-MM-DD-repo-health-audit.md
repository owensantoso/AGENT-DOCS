---
type: repo-health-audit
title: Repo Health Audit
status: completed
created_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
updated_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
audit_started_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
audit_ended_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
timezone: "TZ +0000"
auditor:
scope:
  - docs
  - metadata
  - roadmap
  - architecture
  - duplication
  - refactor-opportunities
  - tests
  - tooling
checks:
  - scripts/docs-meta check
  - scripts/docs-meta health --write
  - scripts/docs-meta roadmap --write
related_issues: []
related_prs: []
repo_state:
  based_on_commit:
  last_reviewed_commit:
next_audit_due:
---

# YYYY-MM-DD - Repo Health Audit

## Scope

- What areas were checked.
- What was intentionally out of scope.

## Checks Run

Commands:

- `scripts/docs-meta check`
- `scripts/docs-meta health --write`
- `scripts/docs-meta roadmap --write`

Manual or agent checks:

- Docs/current-state review:
- Architecture boundary review:
- Duplication/refactor scan:
- Test/lint/build review:
- Issue/PR paper-trail review:

## Findings

### Looks Good

- 

### Needs Attention

- 

### Follow-Up Ideas

- 

## Cleanup Done

- 

## Deferred Follow-Ups

- 

## Next Audit Recommendation

- Suggested next audit:
- Suggested focus:
