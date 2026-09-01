---
type: repo-health-audit
document_format_version: 2
id: 01a05b47-fae7-7aac-acbc-288de294e646
aliases: []
title: Agent Continuity Determinism Audit
status: completed
audit_kind: paper-trail
created_at: "2026-09-01 13:43:59 JST +0900"
updated_at: "2026-09-01 16:43:44 JST +0900"
audit_started_at: "2026-09-01 13:43:59 JST +0900"
audit_ended_at: "2026-09-01 13:43:59 JST +0900"
owner:
scope:
  - structured document construction and validation
  - mutation preflight invocation
  - commit and session provenance
  - repository event CI and merge authority
  - installation and recurring drift detection
checks:
  - eight-control assurance matrix
  - declared configured observed enforcing separation
  - evaluator trigger reach authority proof drift separation
  - deterministic report repeatability
related_specs:
  - 01a05bbf-bc0f-7cab-9527-aee9ab9194c2
related_plans:
  - 01a05bbf-bcc2-78c2-84f0-153477fae16f
related_adrs: []
related_sessions:
  - 01a05b47-fb80-78a2-9baa-3c118f5a7434
repo_state:
  based_on_commit: ac446cc725a749c73801087b56c60553652abb98
  last_reviewed_commit: 0ae69937e805307cc385af6e8da518d56ba12215
---

# Agent Continuity Determinism Audit

## Scope

This audit reviews how Agent Continuity requirements are evaluated, invoked,
applied, evidenced, and kept current. It covers the canonical source repository
from the baseline at `ac446cc725a749c73801087b56c60553652abb98` through local
release `2026.09.01.2` at `0ae69937e805307cc385af6e8da518d56ba12215`,
the complete-profile scaffold, and evidence from existing adopter runs. It does
not claim live coverage over an enumerated adopter fleet because no such
registry exists.

## Questions

- Which controls are executable contracts versus prose that a model or human
  must remember?
- Where is the evaluator deterministic but the trigger, reach, authority,
  proof, or drift detection weak?
- Which requirements are safe contract candidates, and which remain semantic
  or human judgment boundaries?
- Does an observed CI run actually have authority to block the protected
  transition?

## Sources Reviewed

- Current repo state: `ac446cc725a749c73801087b56c60553652abb98`
- Pilot release state: `0ae69937e805307cc385af6e8da518d56ba12215`
- `scripts/agent-continuity-docs`
- `scripts/agent-continuity-ci`
- `scaffold/AGENTS.md`
- `scaffold/.github/workflows/agent-continuity.yml`
- Existing structured-document, CI, generated-view, UUID migration, and adopter
  run receipts reviewed during the originating Codex task
- General audit fixture and stable report in the sibling `determinism-audit`
  repository:
  - `examples/agent-continuity/audit.json`
  - `examples/agent-continuity/report.md`

## Method

Each requirement was represented as a control chain:

```text
requirement -> applicability -> evaluator -> trigger -> reach -> authority
            -> proof -> drift detection -> escalation or remediation
```

The audit records six independent `0..3` assurance axes: evaluator (`E`),
trigger (`T`), reach (`R`), authority (`A`), proof (`P`), and drift (`D`). It
also records declared, configured, observed, and enforcing as separate facts.
An independent model review rejected the earlier single maturity ladder as the
formal model because it hid “strong engine, weak ignition” cases.

The complete matrix is versioned as JSON in `determinism-audit` and was rendered
twice through the same standard-library command to check deterministic ordering
and output. This repository retains the Agent Continuity-specific findings and
recommendations; the sibling repository owns the reusable methodology.

## Findings

| ID | Severity | Status | Finding | Route | Follow-up | Resolution |
|---|---|---|---|---|---|---|
| AC-DET-01 | high | open | Commit title and provenance-trailer conventions are prose-only (`E0 T0 R0 A0 P1 D0`). Existing history contains inconsistent raw versus Git-parseable trailers. | none | Not routed. | Add commit-message and pushed-range validation only after exact convention semantics exist. |
| AC-DET-02 | medium | open | Structured-document construction is a strong contract, but invocation still depends on selecting the supported command (`E3 T1 R2 A2 P2 D1`). | none | Not routed. | Constructor exists; unsupported direct construction remains a separate future control. |
| AC-DET-03 | high | open | Repository CI is event-triggered and revision-bound, but its coverage has false-negative paths and no demonstrated merge-blocking authority (`E2 T2 R1 A0 P2 D1`). | none | Not routed. | Expand fixtures and declared roots before raising remote authority. |
| AC-DET-04 | high | resolved | Supported manifest-backed document mutations now invoke a deterministic doctor policy and refuse unsafe state before writing (`E3 T2 R2 A2 P1 D2`). | none | No follow-up required. | Releases `2026.09.01.1` and `2026.09.01.2` passed exact-commit cold worktree checks. Direct editor/shell writes and per-run receipts remain explicitly outside this control. |
| AC-DET-05 | high | open | A failed or absent CI run can be observed without preventing entry to `main`; the audited default branch had no required ruleset (`E2 T2 R1 A0 P2 D0`). | none | Not routed. | Requires a separate authorized GitHub policy change after local stabilization. |
| AC-DET-06 | medium | open | No registered adopter denominator or scheduled drift control detects missing hooks, stale installations, removed workflows, absent rulesets, or missed runs (`E0 T0 R0 A0 P0 D0`). | none | Not routed. | Define an explicit registry before recurring drift work. |
| AC-DET-07 | high | open | Session creation is deterministic, but whether a qualifying change set has exactly one receipt or justified exemption is only weakly evaluated (`E1 T1 R1 A0 P1 D0`). | none | Not routed. | Specify qualifying-change and exemption semantics before implementation. |
| AC-DET-08 | info | resolved | `CURRENT_STATE` truth is semantic. Syntax can require an impact declaration and cited evidence, but cannot prove the prose is true (`E0 T1 R0 A0 P1 D0`). | none | No follow-up required. | Semantic review remains human/model-owned; evidence presence may be automated separately. |

## Recommendations

1. Continue contract checks in failure-order, not prose-order: commit/range
   metadata, broader document-root validation, and session receipt linkage.
2. Give local CI broader evaluator coverage and explicit failing fixtures before
   raising its authority. A deterministic false negative is still a trapdoor in
   a lab coat.
3. Configure GitHub required-check policy only as a separate authorized change
   after the check name and behavior are stable. Record break-glass policy and
   verify it against an exact revision.
4. Create a registered adopter denominator before claiming cross-repository
   reach. Unknown installations must stay unknown rather than silently passing.
5. Add a recurring drift audit as a backstop for missing hooks, workflows,
   installations, policies, and stale runs. Do not use scheduling as a
   substitute for event-time blocking.
6. Keep semantic truth, human acceptance, and remediation outside the assurance
   score. Mechanically require evidence where possible; preserve judgment where
   the predicate is not stable.

## Follow-Ups

- Continue the dedicated Agent Continuity hardening plan one bounded control at
  a time; this audit does not authorize GitHub mutation.
- Use the sibling `determinism-audit` repository for the reusable framework and
  the future Interface Toolbox / Visual Design Director comparison.
- Refresh this audit before implementation if the source revision, remote
  policy, installed release, or adopter set changes.

## Pilot Re-audit

`AC-DET-04` moved from `E3 T1 R2 A0 P1 D1` to
`E3 T2 R2 A2 P1 D2`.

- Trigger rose because every supported write-capable document command is
  classified and invokes the policy automatically.
- Authority rose because unsafe release, tooling, incompatible, and
  document-format state blocks before repository bytes change.
- Drift rose because the trigger lives in versioned, checksum-tracked tooling
  and release/install drift is itself part of the gate.
- Proof remains `P1` because ordinary successful executions are silent and do
  not emit revision- and policy-bound receipts.
- Reach remains `R2` because direct editor and shell writes, old unupgraded
  helpers, and unknown fleet members are not intercepted.

Only duplicated invocation procedure was reduced. The scaffold and structured
docs skill still explain intent, refusal diagnosis, upgrade/migration recovery,
concurrent-doc ownership, and the direct-write boundary.
