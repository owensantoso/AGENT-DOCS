---
type: concept
id: CONC-0001
title: Read-Only SQLite Docs Index
domain: docs-meta
status: draft
concept_type: architecture
created_at: "2026-04-27 08:34:23 JST +0900"
updated_at: "2026-04-27 08:34:23 JST +0900"
owner:
source:
  type: conversation
  link:
  notes: Discussion about whether a generated SQLite index would improve docs-meta queryability over script-only commands.
areas:
  - docs
  - docs-meta
related_specs: []
related_plans:
  - ../plans/docs-meta-link-graph-and-safe-move/PLAN-0001-docs-meta-link-graph-and-safe-move.md
  - ../plans/stable-todo-system/PLAN-0002-stable-todo-system.md
related_briefs: []
related_adrs: []
related_ideas: []
related_questions: []
related_sessions: []
promoted_to: []
supersedes: []
superseded_by: []
repo_state:
  based_on_commit: 18959da605df05790f894724c6ac4f54bc2a6b1b
  last_reviewed_commit: 18959da605df05790f894724c6ac4f54bc2a6b1b
---

# CONC-0001 - Read-Only SQLite Docs Index

## Purpose

Capture the possible evolution from a script-only docs metadata helper to a generated, read-only SQLite index.

This is a concept note, not implementation approval. It is more concrete than a raw idea because the recommended shape is clear: Markdown remains canonical, while SQLite becomes a disposable query cache.

## Candidate Model

Keep Markdown files, filenames, frontmatter, links, and checkboxes as the source of truth.

Add an optional generated SQLite database under a cache/generated path, for example:

```text
.generated/docs.db
```

Potential command shape:

```bash
scripts/docs-meta index --sqlite .generated/docs.db
scripts/docs-query stale-concepts
scripts/docs-query open-work-by-area
```

The SQLite database would be read-only from the workflow's point of view. Regenerate it from Markdown whenever source docs change.

## Why A Script Alone Is Enough Today

The current script model is simpler and better for direct commands:

- derive the next stable ID
- validate statuses and frontmatter contracts
- regenerate Markdown views
- list links, backlinks, or todos
- fail deterministically in CI

For these workflows, adding SQLite would add moving parts without changing the user experience much.

## Where SQLite Could Help

SQLite becomes meaningfully useful when the workflow needs many predictable joins across docs data:

- docs by type, status, area, owner, and freshness
- link graph queries that combine source docs, target docs, fragments, and broken-link state
- todo queries joined to plan/spec/doc metadata
- concept notes related to roadmaps or plans
- stale docs by `repo_state.last_reviewed_commit`
- generated dashboards that would otherwise require one bespoke script command per question

Example query shape:

```sql
select d.id, d.title, l.target_id
from docs d
join links l on l.source_doc_id = d.id
where d.type = 'concept'
  and d.status in ('draft', 'active')
  and l.target_type = 'roadmap';
```

## Source-Of-Truth Rules

- Markdown remains canonical.
- SQLite is a generated read model, not an editable store.
- Generated Markdown registries remain caches.
- CI should be able to delete and rebuild the SQLite database.
- The SQLite schema should be treated like an internal index contract, not product data.

## Benefits

- More precise cross-cutting queries without adding a new bespoke subcommand for every question.
- Easier agent inspection of docs state using stable tables.
- Better foundation for health dashboards, stale-work queues, and relationship reports.
- Possible future integration point for local full-text search or embeddings without changing source docs.

## Costs And Risks

- More tooling to maintain.
- Schema migrations or compatibility handling for the generated index.
- Possible confusion if users think the database is canonical.
- Potential binary/cache churn if the database is accidentally committed.
- More complexity than the current workflow needs for simple repositories.

## Recommendation

Do not make SQLite canonical.

Do not add it until `docs-meta` has enough repeated cross-cutting queries that the script is growing awkward command-by-command.

When it is time, add it as an optional generated cache:

- ignored by git by default
- rebuildable from Markdown
- covered by a smoke test
- documented as read-only

## Promotion Paths

- Promote to a spec when the first concrete SQLite-backed query set is chosen.
- Promote to a plan when implementation sequencing, schema, and verification are ready.
- Promote to an ADR only if AGENT-DOCS chooses SQLite as a durable tooling direction that consuming repos should rely on.

## Related Docs

- [PLAN-0001 - Docs Link Graph and Safe Move Tooling](../plans/docs-meta-link-graph-and-safe-move/PLAN-0001-docs-meta-link-graph-and-safe-move.md)
- [PLAN-0002 - Stable Todo System](../plans/stable-todo-system/PLAN-0002-stable-todo-system.md)
- [Docs Meta README](../scripts/README.md)
