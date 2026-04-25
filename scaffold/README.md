# AGENT-DOCS Scaffold

This folder is shaped like the repo docs tree it creates.

Copy the parts you need into a target repo, then delete examples that do not apply. The scaffold is intentionally topic-first:

```text
docs/
  orientation/
  architecture/
  product/
  decisions/
  repo-health/
  research/
  operations/
  marketing/
```

Use one canonical physical home for each doc. Use generated views like `IDEAS.md`, `SPECS.md`, `AREAS.md`, `AUDITS.md`, `ROADMAP-VIEW.md`, `DOCS-REGISTRY.md`, `TODOS.md`, and `HEALTH.md` for cross-cutting navigation instead of duplicating files.

If the target repo uses `scripts/docs-meta`, prefer the CLI for new IDs and generated views:

```bash
scripts/docs-meta new idea "<title>" --domain product
scripts/docs-meta new spec "<title>" --domain product
scripts/docs-meta update
scripts/docs-meta health --write
scripts/docs-meta roadmap --write
scripts/docs-meta check
```

The example artifact files use `0000` IDs. Replace them with real IDs before committing real project docs.
