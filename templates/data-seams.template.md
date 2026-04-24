# Data Model And Seams

Use this doc to explain canonical models, compatibility layers, migrations in progress, and places where agents might accidentally extend the wrong seam.

## Why this doc exists

- <reason 1>
- <reason 2>

## Canonical seams today

- <canonical repository, table, service, or model>
- <canonical repository, table, service, or model>

## Compatibility or transitional seams

- <compatibility seam>
- <what it still supports>
- <why it is not the long-term target>

## Extension rules

- Extend <preferred seam> for near-term work.
- Do not invent a parallel path when <existing seam> already owns the concern.
- If a forward architecture seam exists in docs but not in code yet, extend the shipped precursor seam unless the plan says otherwise.

## Common mistakes

- <mistake>
- <mistake>

## Read this before changing

- `<file>`
- `<file>`
- `<file>`
