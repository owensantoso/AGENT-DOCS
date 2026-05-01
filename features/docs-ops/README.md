# Docs Operations

Docs Operations is the deterministic command surface for AGENT-DOCS
documentation workflows. It keeps Markdown source docs canonical while moving
repeatable bookkeeping into tooling.

## Boundary

Docs Operations owns mechanical docs work:

- stable ID allocation;
- source-doc creation from known families;
- generated views;
- metadata and link checks;
- structured TODO validation;
- review, roadmap, and health projections;
- safe doc moves;
- branch-local draft creation and promotion.

Docs Operations does not own the substance of specs, plans, architecture
decisions, product direction, or agent judgment.

## Command Surface

Preferred namespace:

```bash
agent-docs docs ...
```

Compatibility command:

```bash
scripts/docs-meta ...
```

Target repos may continue installing `scripts/docs-meta` as the portable copied
command until install and upgrade tooling can safely consume feature manifests.

## Draft Promotion

Parallel planning work should use draft IDs under `plans/drafts/`:

```text
SPEC-DRAFT-<slug>
PLAN-DRAFT-<slug>
```

Promotion happens after rebasing or merging onto the branch that will own the
stable ID:

```bash
agent-docs docs promote plans/drafts/SPEC-DRAFT-<slug>.md --write
```

Promotion assigns the next stable ID, moves the doc, rewrites Markdown
backlinks, removes draft metadata, and refuses unsafe destination shapes.

## Future Feature Manifest Shape

```yaml
id: docs-ops
name: Docs Operations
commands:
  - source: bin/docs
    install_as: agent-docs docs
compatibility_commands:
  - source: bin/docs
    install_as: scripts/docs-meta
owned_files:
  - scripts/docs-meta
  - tests/docs-meta-smoke.sh
checks:
  - tests/docs-meta-smoke.sh
  - scripts/docs-meta --root plans check
  - scripts/docs-meta --root plans check-links
```

This file is the feature boundary note for now. A later packaging pass can move
implementation files under `features/docs-ops/` after install and upgrade
tooling know how to install from feature manifests.

