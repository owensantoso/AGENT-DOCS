# Idea Registry

Global registry for lightweight ideas. Use one continuous `IDEA-####` sequence across all domains, even when idea files live in topic-first folders.

Ideas are for preserving sparks, rambles, possible future work, or not-yet-formed product/repo thoughts. They are intentionally lighter than specs.

Before creating a new idea manually:

1. Find the highest existing `IDEA-####` in this registry and existing idea files.
2. Use the next unused global number.
3. Store the idea under the topic folder that owns it.
4. Add the idea to this registry in ID order.

## Registry

| ID | Title | Domain | Status | Path | Source | Promoted To |
|---|---|---|---|---|---|---|
| `IDEA-0001` | <title> | <domain> | <captured/exploring/promoted/rejected/archived> | `<domain>/ideas/IDEA-0001-<slug>.md` | <conversation, issue, review, research, etc.> | <SPEC/ADR/research/plan links> |

## Naming Rules

- IDs are global: `IDEA-0001`, `IDEA-0002`, `IDEA-0003`.
- Filenames start with the ID: `IDEA-0001-<slug>.md`.
- Folders are topic-first: `docs/product/ideas/`, `docs/repo-health/ideas/`, `docs/research/ideas/`, etc.
- Do not promote an idea by renaming it. Create a spec, research note, ADR, or plan and link it in `promoted_to`.

When the repo has `scripts/docs-meta`, prefer:

```bash
scripts/docs-meta next idea
scripts/docs-meta new idea "<title>" --domain product
scripts/docs-meta update
scripts/docs-meta check
```

The registry prevents scattered topic folders from creating duplicate idea numbers. `docs-meta` can regenerate it from the repo tree and frontmatter.
