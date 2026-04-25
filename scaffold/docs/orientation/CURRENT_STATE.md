---
type: current-state
title: Current State
domain: orientation
status: draft
created_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
updated_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
owner:
areas: []
related_specs: []
related_plans: []
related_adrs: []
related_sessions: []
repo_state:
  based_on_commit:
  last_reviewed_commit:
---

# Current State

Fast truth page for what exists now and where to look next. Keep this file short. It should fan out to durable docs instead of becoming a session journal.

Canonical freshness lives in `updated_at` frontmatter.

Detailed historical state snapshots live in `<state-history-folder>`.

## What Exists Today

<One paragraph on the current shipped reality.>

Built and usable:

- <major current capability>
- <major current capability>
- <major current capability>

## Not Yet Built

- <major missing capability>
- <major missing capability>

## Current Product / System Model

Use this mental model:

- <canonical thing>
- <derived thing>
- <compatibility seam>
- <forward direction>

Source docs:

- Architecture: `<architecture-path>`
- Product/spec baseline: `<spec-path>`
- Onboarding: `<onboarding-path>`

## Roadmap Position

<Short summary of where the repo sits in the roadmap.>

Source docs:

- Roadmap: `<roadmap-path>`
- Plans: `<plans-folder>`
- Specs: `<specs-folder>`

## Key Gotchas

- <verification caveat>
- <compatibility-layer warning>
- <tooling or environment trap>

## Verification Baseline

Recent meaningful verification has included:

- `<command>`
- `<command>`
- `<manual check type>`

For current commands, use:

- `<testing guide path>`
- `<surface AGENTS path>`

## Where To Look

| Need | Read |
|---|---|
| First orientation | `<onboarding-path>` |
| Current architecture | `<architecture-path>` |
| Roadmap order | `<roadmap-path>` |
| Product/data model | `<spec-path>` |
| Durable decisions | `<adr-folder>` |
| Session paper trail | `<session-logs-folder>` |
| Historical state snapshots | `<state-history-folder>` |

## Maintenance Rule

When a plan or multi-task change finishes, update this file only with:

- new current truth
- changed roadmap position
- new gotchas
- links to deeper source docs

Move detailed narratives, session receipts, and decision rationale to the appropriate fanout doc.
