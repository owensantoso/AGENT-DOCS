---
type: repo-health-audit
document_format_version: 2
id: 01a05b47-fae7-7aac-acbc-288de294e646
aliases: []
title: Agent Continuity Determinism Audit
status: completed
audit_kind: paper-trail
created_at: "2026-09-01 13:43:59 JST +0900"
updated_at: "2026-09-01 13:44:03 JST +0900"
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
related_specs: []
related_plans: []
related_adrs: []
related_sessions:
  - 01a05b47-fb80-78a2-9baa-3c118f5a7434
repo_state:
  based_on_commit: ac446cc725a749c73801087b56c60553652abb98
  last_reviewed_commit: ac446cc725a749c73801087b56c60553652abb98
---

# Agent Continuity Determinism Audit

## Scope

This audit reviews how Agent Continuity requirements are evaluated, invoked,
applied, evidenced, and kept current. It covers the canonical source repository
at `ac446cc725a749c73801087b56c60553652abb98`, the complete-profile scaffold,
and evidence from existing adopter runs. It does not claim live coverage over
an enumerated adopter fleet because no such registry exists.

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
| AC-DET-01 | high | open | Commit title and provenance-trailer conventions are prose-only (`E0 T0 R0 A0 P1 D0`). Existing history contains inconsistent raw versus Git-parseable trailers. | contract | Add commit-message and pushed-range validation with passing/failing fixtures. | Not implemented in this audit. |
| AC-DET-02 | medium | open | Structured-document construction is a strong contract, but invocation still depends on selecting the supported command (`E3 T1 R2 A2 P2 D1`). | harden | Detect or prevent unsupported fresh document construction at the owning transition. | Constructor exists; invocation coverage remains open. |
| AC-DET-03 | high | open | Repository CI is event-triggered and revision-bound, but its coverage has false-negative paths and no demonstrated merge-blocking authority (`E2 T2 R1 A0 P2 D1`). | contract | Expand fixtures and declared roots, then bind the stable check to protected-branch policy. | CI exists; protection is not implemented here. |
| AC-DET-04 | high | open | `doctor` is a deterministic preflight whose ignition remains prose-owned (`E3 T1 R2 A0 P1 D1`). The mutation command does not itself prove the preflight ran. | contract | Bind version/format preflight to the structured-doc mutation boundary and emit a revision-bound receipt. | Evaluator exists; automatic trigger does not. |
| AC-DET-05 | high | open | A failed or absent CI run can be observed without preventing entry to `main`; the audited default branch had no required ruleset (`E2 T2 R1 A0 P2 D0`). | external policy | After local evaluator stabilization, configure and audit required remote checks with controlled break-glass. | Requires a separate authorized GitHub policy change. |
| AC-DET-06 | medium | open | No registered adopter denominator or scheduled drift control detects missing hooks, stale installations, removed workflows, absent rulesets, or missed runs (`E0 T0 R0 A0 P0 D0`). | recurring audit | Define an explicit registry, a read-only drift command, freshness receipts, and missed-run detection. | No recurring mechanism exists. |
| AC-DET-07 | high | open | Session creation is deterministic, but whether a qualifying change set has exactly one receipt or justified exemption is only weakly evaluated (`E1 T1 R1 A0 P1 D0`). | contract | Validate receipt cardinality and commit linkage at the change-set boundary. | Session constructor exists; lifecycle gate does not. |
| AC-DET-08 | informational | accepted boundary | `CURRENT_STATE` truth is semantic. Syntax can require an impact declaration and cited evidence, but cannot prove the prose is true (`E0 T1 R0 A0 P1 D0`). | keep reasoning | Keep semantic review human/model-owned; automate evidence presence and freshness only. | Correctly excluded from a numeric target profile. |

## Recommendations

1. Implement contract checks in failure-order, not prose-order:
   commit/range metadata, document-root coverage, doctor-at-mutation, and session
   receipt linkage.
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

- Create a dedicated Agent Continuity hardening plan from `AC-DET-01` through
  `AC-DET-07`; this audit does not authorize implementation or GitHub mutation.
- Use the sibling `determinism-audit` repository for the reusable framework and
  the future Interface Toolbox / Visual Design Director comparison.
- Refresh this audit before implementation if the source revision, remote
  policy, installed release, or adopter set changes.
