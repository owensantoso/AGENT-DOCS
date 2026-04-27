# Plans

AGENT-DOCS plans track work on the reusable docs workflow itself.

Use this folder for upstream work that should improve every consuming repo, such as `docs-meta`, scaffold conventions, generated views, adoption guides, and agent-instruction templates.

Do not park target-repo product work here. Product, app, or service plans belong in the consuming repo that owns the outcome.

## Current Plans

| Plan | Purpose |
|---|---|
| [PLAN-0001 - Docs Link Graph and Safe Move Tooling](docs-meta-link-graph-and-safe-move/PLAN-0001-docs-meta-link-graph-and-safe-move.md) | Extend `docs-meta` with backlinks, broken-link checks, orphan checks, link normalization, and safe doc move previews. |
| [PLAN-0002 - Stable Todo System](stable-todo-system/PLAN-0002-stable-todo-system.md) | Add stable Markdown-native todo IDs, lifecycle states, owner/skill metadata, generated views, and checks for agent coordination. |

## Related Concepts

| Concept | Purpose |
|---|---|
| [CONC-0001 - Read-Only SQLite Docs Index](../concepts/CONC-0001-read-only-sqlite-docs-index.md) | Evaluate a generated, read-only SQLite cache for richer docs-meta queries while keeping Markdown canonical. |
| [CONC-0002 - Agent Docs Doctor And Upgrade](../concepts/CONC-0002-agent-docs-doctor-and-upgrade.md) | Define a conservative command family for checking target-repo drift and safely updating AGENT-DOCS-owned assets. |
