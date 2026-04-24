---
type: architecture-area
id: AREA-<NAME>
status: draft
created_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
updated_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
owners: []
related_specs: []
related_adrs: []
related_plans: []
related_sessions: []
---

# AREA-<NAME> - <Area Title>

Use this doc for one stable architecture area. The `id` and filename must match:

```text
docs/architecture/areas/AREA-<NAME>.md
```

## Owns

- <boundary, subsystem, or responsibility>
- <boundary, subsystem, or responsibility>

## Does Not Own

- <nearby boundary owned elsewhere>
- <nearby boundary owned elsewhere>

## Stable Invariants

- <rule that should survive refactors>
- <rule that should survive refactors>

## Intended Flow

1. <step>
2. <step>
3. <step>

## Current Mismatch Notes

- <where current implementation differs from intended architecture>
- <what not to mistake for a stable rule>

## Related Areas

- `AREA-<OTHER>` - <relationship>

## Related Docs

- <spec, ADR, plan, session log, or source-of-truth doc>

The area doc is a boundary contract. Put execution sequencing in plans, receipts in session logs, and durable rationale in ADRs.
