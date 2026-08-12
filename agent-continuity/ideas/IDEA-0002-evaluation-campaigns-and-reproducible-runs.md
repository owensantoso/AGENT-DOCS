---
type: idea
id: IDEA-0002
title: Evaluation Campaigns And Reproducible Runs
domain: agent-continuity
status: captured
created_at: "2026-08-06 21:21:19 JST +0900"
updated_at: "2026-08-06 21:21:19 JST +0900"
owner: Codex main agent
source:
  type: conversation
  link:
  notes: "User proposed parallel agents implementing competing fixes in isolated Git worktrees or Jujutsu workspaces, followed by one common evaluation and an evidence-backed winner."
areas:
  - agent-continuity
  - evaluations
  - orchestration
related_specs: []
related_research: []
related_issues: []
related_prs: []
related_sessions: []
linked_paths:
  - scaffold/docs/repo-health/evaluations/README.md
  - scaffold/docs/repo-health/evaluations/templates/evaluation-template.md
  - repo-health/evaluations/EVAL-0001-docs-to-code-graph-agent-efficiency.md
  - concepts/CONC-0001-read-only-sqlite-docs-index.md
promoted_to: []
repo_state:
  based_on_commit:
  last_reviewed_commit:
---

# IDEA-0002 - Evaluation Campaigns And Reproducible Runs

## Raw Thought

Make experiments a first-class loop inside Agent Continuity. A diagnostic can identify a slow or unreliable path, an evaluation campaign can define several falsifiable hypotheses and concrete variants, parallel agents can implement those variants in isolated worktrees or Jujutsu workspaces, and one common evaluator can run the frozen protocol and produce a comparable result. The evidence then feeds a decision, plan, and regression test instead of disappearing into chat.

This should also cover small parameter matrices. Mutually exclusive architectures are separate variants; orthogonal configuration choices are factors and levels. Full combinations are useful only while the matrix remains small.

## Why It Might Matter

- Performance work becomes an evidence problem instead of a sequence of guesses.
- Candidate implementations can proceed in parallel without letting each agent grade its own work.
- Correctness guardrails, source fingerprints, fixture digests, and environment metadata make results reproducible.
- Failed hypotheses remain useful evidence rather than becoming lost branches.
- A winning optimization can graduate into the normal regression suite.

## Possible Shape

Keep the existing document families:

```text
DIAG -> EVAL campaign -> generated comparison -> ADR -> PLAN / IMPL
```

One `EVAL-*` Markdown document remains the human source of truth for the question, hypotheses, candidate intent, fixtures, metrics, guardrails, protocol, and predeclared winner rule. Use local IDs inside the evaluation such as `H1`, `V2`, and `M.trigger_to_surface_ms`; do not create global doc families for every hypothesis, variant, or run.

Store machine evidence under the existing artifact root:

```text
artifacts/evaluations/EVAL-####/
  definition.snapshot.json
  variants/V0.json
  runs/<run-id>/
    run.json
    samples.jsonl
    trace.jsonl
    summary.json
  reports/comparison.json
  reports/comparison.md
```

The smallest useful command surface is a sibling `agent-continuity eval` namespace:

- `init-run EVAL-#### --variant V1 --revision <fingerprint>`
- `validate <run-dir>`
- `summarize EVAL-####`
- `compare EVAL-####`

The project-specific harness should execute the product code. Agent Continuity should initially validate provenance and schemas, aggregate measurements, enforce correctness gates, and render comparisons; it should not become an arbitrary code-execution framework.

Parallelize implementation, not benchmarks on the same machine. Run performance trials serially with warmups, repetitions, and randomized or interleaved variant order so CPU, browser, disk, and thermal contention do not choose the winner. Prefer one primary objective plus hard correctness guardrails, paired deltas, p50/p95/max, and a held-out confirmation run over an opaque weighted score.

Markdown remains canonical. JSON and JSONL hold immutable run evidence. Add SQLite only as a disposable, rebuildable read model once repeated cross-evaluation joins or dashboards justify it.

## Questions

- What is the minimum stable schema for experiment definitions, run receipts, samples, exclusions, and comparison reports?
- Should the first runner accept only a declared command from the `EVAL-*`, or remain validation/aggregation-only until several manual campaigns exist?
- How should environment fingerprints distinguish hardware, operating system, browser version, build identity, thermal state, and background load?
- When should a large parameter matrix switch from full factorial runs to staged or fractional exploration?
- Which visualization should be generated first: a comparison table, distribution plot, trace waterfall, or interactive architecture/trace board?
- What promotion rule turns a winning evaluation into a durable regression benchmark?

## Promotion Criteria

Promote this idea to a concept/spec after one real campaign proves the data model. Use the Hold Keys Chrome tab-latency problem as the first fixture: compare trigger-time AppleScript scanning, extension `tabs.query` at trigger, and an extension-pushed live catalog while preserving exact/domain matching and ordinary typing.

Before implementation, freeze the fixtures and success rule, capture at least one baseline run with correlated spans, and define cold and warm paths separately. Promote the storage decision to an ADR only after at least two evaluations need the same structured run format. Add a generated SQLite index only after repeated cross-evaluation queries demonstrate that JSONL scanning is the actual bottleneck.
