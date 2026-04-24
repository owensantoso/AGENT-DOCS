# <Surface Name> Codebase Map

Evergreen orientation guide for the current `<surface>` area. This is a map of what exists on disk today, not a forward plan.

## Read order

1. `<surface>/AGENTS.md`
2. `<primary entry point>`
3. `<root composition file>`
4. `<main persistence or service seam>`
5. `<schema or config seam>`
6. `<testing guide or seams doc>`

## Top-level layout

### App or entry

- `<path>`
- <what lives here>

### Features or modules

- `<path>`
- <what lives here>

### Domain

- `<path>`
- <what lives here>

### Persistence or backend

- `<path>`
- <what lives here>

## Important seams

### Canonical versus compatibility

- <what is canonical today>
- <what is transitional or compatibility-only>

### Current versus forward architecture

- `CURRENT_STATE.md` describes what exists now.
- `ARCHITECTURE.md` describes the forward direction.

## Good entry points by task

- boot/composition: <files>
- repository/schema work: <files>
- feature behavior: <files>
- verification/debug: <files>

## What is intentionally missing

- <missing area that future agents might otherwise assume exists>
