# Agent Continuity Scaffold

This folder is shaped like the repo docs tree it creates.

Copy the parts you need into a target repo, then delete examples that do not apply. For exact safe copy commands, use the upstream [../INSTALL.md](../INSTALL.md) guide.

Do not copy this whole folder directly into a target repo root. This folder contains its own `README.md`; copy `AGENTS.md`, `docs/`, optional `agent-instructions/`, optional `skills/`, and optional tools deliberately.

The scaffold is intentionally topic-first:

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

Use one canonical physical home for each doc. Use generated views like `IDEAS.md`, `CONCEPTS.md`, `SPECS.md`, `LEARNINGS.md`, `EXPLAINERS.md`, `QUESTIONS.md`, `AREAS.md`, `AUDITS.md`, `ROADMAP-VIEW.md`, `DOCS-REGISTRY.md`, `TODOS.md`, and `HEALTH.md` for cross-cutting navigation instead of duplicating files.

If the target repo uses `agent-continuity docs`, prefer the CLI for new IDs and generated views:

```bash
agent-continuity docs new idea "<title>" --domain product
agent-continuity docs new concept "<title>" --domain product
agent-continuity docs new research "<title>" --domain research
agent-continuity docs new eval "<title>" --domain repo-health
agent-continuity docs new diag "<title>" --domain repo-health
agent-continuity docs new spec "<title>" --domain product
agent-continuity docs new learning "<title>" --domain repo-health
agent-continuity docs new explainer "<title>" --domain orientation
agent-continuity docs new question "<title>" --domain repo-health
agent-continuity docs update
agent-continuity docs health --write
agent-continuity docs roadmap --write
agent-continuity docs check
```

The example artifact files use `0000` IDs. Replace them with real IDs before committing real project docs.
