# Questions

Questions preserve durable uncertainty with a stable `QST-*` ID.

Use `QST-*` when an unresolved question needs status, ownership, links, or resolution history across sessions. Keep local questions inside specs, plans, briefs, research notes, session logs, explainers, or learning records until they need that lifecycle.

Create a new question with:

```bash
scripts/docs-meta new question "Title" --domain product
```

## Statuses

```text
open
investigating
answered
deferred
superseded
archived
```

`answered` questions should include `resolution` or `resolved_by`. `superseded` questions should include `superseded_by` or `reason`.

## Template

Start from `QST-0000-question-title.md` or `scripts/docs-meta new question`.
