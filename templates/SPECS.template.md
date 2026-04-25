# Spec Registry

Global registry for durable specs. Use one continuous `SPEC-####` sequence across all domains, even when spec files live in topic-first folders.

Before creating a new spec manually:

1. Find the highest existing `SPEC-####` in this registry and existing spec files.
2. Use the next unused global number.
3. Store the spec under the topic folder that owns it.
4. Add the spec to this registry in ID order.

## Registry

| ID | Title | Type | Domain | Status | Path | Source |
|---|---|---|---|---|---|---|
| `SPEC-0001` | <title> | <feature/improvement/bug/architecture/repo-health/research> | <domain> | <draft/proposed/approved/implemented/superseded> | `<domain>/specs/SPEC-0001-<slug>.md` | <conversation, issue, review, research, etc.> |

## Naming Rules

- IDs are global: `SPEC-0001`, `SPEC-0002`, `SPEC-0003`.
- Filenames start with the ID: `SPEC-0001-<slug>.md`.
- Folders are topic-first: `docs/product/specs/`, `docs/architecture/specs/`, `docs/repo-health/specs/`, `docs/research/specs/`, etc.
- Do not use date-only spec filenames for durable specs.
- If an existing repo still uses `docs/specs/`, follow local convention unless the task is explicitly migrating docs hierarchy.

When the repo has `scripts/docs-meta`, prefer:

```bash
scripts/docs-meta next spec
scripts/docs-meta new spec "<title>" --domain product --spec-type improvement
scripts/docs-meta update
scripts/docs-meta check
```

The registry prevents scattered topic folders from creating duplicate spec numbers. `docs-meta` can regenerate it from the repo tree and frontmatter.
