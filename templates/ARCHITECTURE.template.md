# Architecture

System overview for <repo or product>. This document describes the intended forward architecture. For what is actually built today, see `docs/CURRENT_STATE.md`.

## Product

<one or two paragraphs describing the product and major surfaces>

## Reality check

- <what the current branch or repo still does today>
- <what upcoming work retargets or replaces>
- If this document and `CURRENT_STATE.md` disagree, treat:
  - `CURRENT_STATE.md` as truth for what exists now
  - this file as truth for what upcoming implementation should target

## Decision provenance

Use this section as the map from architecture claims to the docs that explain why those claims exist.

| Area | Decision source |
|---|---|
| Current shipped state | `<current-state-path>` |
| Roadmap order and rationale | `<roadmap-path>` |
| Approved product or system baseline | `<spec-path>` |
| Durable architecture decisions | `<adr-folder>` |
| Session-to-commit traceability | `<session-logs-path>` |

## Tech stack

| Layer | Tech |
|---|---|
| <layer> | <stack> |
| <layer> | <stack> |

## System boundaries

- <boundary 1>
- <boundary 2>
- <boundary 3>

## Canonical model or core system seams

- <canonical entity or seam>
- <canonical entity or seam>
- <derived or compatibility seam>

## Working rules

- <invariant>
- <invariant>
- <ownership rule>

## Critical flows

### Write path

1. <step>
2. <step>
3. <step>

### Read path

1. <step>
2. <step>
3. <step>

## Replaceability targets

These layers should change the most if implementation plumbing is swapped later:

- <replaceable layer>
- <replaceable layer>

These layers should change the least:

- <stable call site or product layer>
- <stable call site or product layer>

## Module layout

```text
<high-level folder layout>
```
