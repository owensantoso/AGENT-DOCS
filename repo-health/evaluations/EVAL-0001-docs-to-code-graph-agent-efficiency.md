---
type: evaluation
id: EVAL-0001
title: Docs To Code Graph Agent Efficiency
domain: repo-health
status: draft
created_at: "2026-04-28 03:52:13 JST +0900"
updated_at: "2026-04-28 03:54:54 JST +0900"
owner: "Codex main agent"
hypothesis: "A small docs-to-code graph reduces agent navigation cost and stale-doc misses without hurting implementation quality."
artifact_root: artifacts/evaluations/EVAL-0001/
dataset_version: "draft-v0"
fixture_digest:
run_command: "Manual paired-agent evaluation; automate after fixture design hardens."
metrics_version: "draft-v0"
baseline_eval:
related_research:
  - ../../research/RSCH-0001-docs-code-traceability-tools.md
  - ../../research/RSCH-0002-code-knowledge-graph-and-agent-context-tools.md
  - ../../research/RSCH-0003-documentation-systems-with-source-links.md
  - ../../research/RSCH-0004-tree-sitter-for-docs-to-code-linking.md
  - ../../research/RSCH-0005-ast-indexes-and-static-analysis-for-docs-links.md
  - ../../research/RSCH-0006-lsp-symbol-graphs-for-docs-navigation.md
  - ../../research/RSCH-0007-monocle-swift-symbol-navigation-fit.md
related_diagnostics: []
related_adrs: []
related_specs: []
related_plans: []
related_sessions: []
linked_paths:
  - docs-meta/ideas/IDEA-0001-docs-to-code-graph.md
  - scripts/docs-meta
  - concepts/CONC-0001-read-only-sqlite-docs-index.md
repo_state:
  based_on_commit: 347a99464bb3afdb97bdf15f3c93722e48ebf4d6
  last_reviewed_commit: 347a99464bb3afdb97bdf15f3c93722e48ebf4d6
---

# EVAL-0001 - Docs To Code Graph Agent Efficiency

## Hypothesis

A small docs-to-code graph is worth building if it helps fresh agents find the right implementation surface with less context and fewer search loops while preserving or improving correctness.

The specific hypothesis:

- explicit doc-to-path/code-reference metadata reduces total prompt/context tokens by at least 20 percent on navigation-heavy tasks
- stale-link checks catch at least 80 percent of intentionally stale doc-code references in fixtures
- agent task success and verification pass rate do not regress versus the current workflow

This evaluation should disprove the idea if the graph mostly adds bookkeeping, false confidence, or noisy warnings.

## Candidates

| Candidate | Description | Expected Cost | Expected Gain |
|---|---|---|---|
| A. Baseline docs + `rg` | Current AGENT-DOCS workflow: read docs, use generated views, search code manually. | None | Current reference point |
| B. Explicit path refs | Docs add typed `code_refs` or stricter `linked_paths` for files/folders only. | Low | Faster first relevant file, stale path warnings |
| C. Path refs + stale queue | Candidate B plus generated review queue when linked files changed after `last_reviewed_commit`. | Low-medium | Better stale-doc detection |
| D. Syntax candidates | Candidate C plus Tree-sitter extraction for symbols/ranges in supported languages. | Medium | Better symbol targeting, fewer broad searches |
| E. Swift precision adapter | Candidate C plus Monocle/SourceKit-LSP for Swift symbol lookup and revalidation. | Medium, Swift-only | Precise Swift definition/signature/doc evidence |

Do not evaluate a full CodeQL/Kythe/SCIP-style semantic graph first. That is a later precision layer if smaller candidates show value.

## Dataset / Fixtures

Use paired tasks where agents need to connect docs to code or code to docs.

Recommended first dataset:

| Case ID | Repo | Task Shape | Gold Labels |
|---|---|---|---|
| `nav-doc-to-code-001` | AGENT-DOCS | Given a plan or concept, identify the files/functions likely to change. | Target file set, acceptable search path |
| `stale-path-001` | AGENT-DOCS fixture branch | Move or rename a linked file and ask which docs are stale. | Stale doc IDs and changed paths |
| `code-to-doc-001` | AGENT-DOCS | Given a file/function, find the docs that explain intent and constraints. | Relevant docs, irrelevant docs |
| `impl-brief-001` | AGENT-DOCS | Implement a small docs-meta change from a brief with or without code refs. | Files touched, tests, reviewer result |
| `swift-symbol-001` | Swift target repo | Given a Swift doc/code claim, resolve exact symbol definition and docs with Monocle. | Symbol URI/range/signature |
| `swift-stale-001` | Swift target repo fixture branch | Move a Swift symbol and test relocation or stale marking. | New symbol location, stale old edge |

Keep the first run small: 4 AGENT-DOCS cases and 2 Swift cases are enough to see whether the idea has teeth.

Fixture rules:

- freeze each fixture at a commit
- record gold labels before running agents
- include at least one deliberately stale link
- include at least one ambiguous symbol/path where the system should say "needs review" rather than guess
- keep private app code out of committed artifacts unless sanitized

## Metrics

Primary metrics:

| Metric | Meaning | Collection |
|---|---|---|
| `input_tokens` | Prompt plus provided context tokens | API usage if available; otherwise tokenizer estimate |
| `output_tokens` | Agent response tokens | API usage if available; otherwise tokenizer estimate |
| `tool_output_bytes` | Shell/tool output read by agent | Command harness or transcript parse |
| `files_read_count` | Number of distinct files opened/read | Command harness or transcript parse |
| `search_command_count` | `rg`, `find`, symbol-search, or equivalent commands | Command harness or transcript parse |
| `time_to_first_target_seconds` | Time until first gold target file/symbol is inspected | Manual timestamp or harness |
| `total_elapsed_seconds` | End-to-end task time | Harness |
| `target_precision` | Relevant target files found / total target files opened | Gold comparison |
| `target_recall` | Relevant target files found / relevant target files expected | Gold comparison |
| `stale_precision` | Correct stale warnings / all stale warnings | Gold comparison |
| `stale_recall` | Correct stale warnings / expected stale warnings | Gold comparison |
| `task_success` | Whether the task was completed correctly | Reviewer or tests |

Secondary metrics:

- clarifying questions asked
- wrong-file edits
- reviewer findings by severity
- verification commands passed
- false confidence events where stale or ambiguous edges were treated as fresh
- setup time for candidate-specific tooling

Token metric policy:

- Prefer exact API token usage when available.
- If exact usage is unavailable, estimate with a tokenizer and record `token_source: estimated`.
- Track both tokens and bytes/files because reduced tokens can hide worse navigation behavior.

## Run Command

```bash
# Draft manual procedure.

# 1. Prepare fixtures and gold labels.
mkdir -p artifacts/evaluations/EVAL-0001

# 2. For each case, run paired agents or paired sessions:
#    A: baseline docs + rg
#    B/C/D/E: candidate workflow with the same starting prompt

# 3. Save per-case results as JSONL.
$EDITOR artifacts/evaluations/EVAL-0001/results.jsonl

# 4. Summarize after all cases.
$EDITOR artifacts/evaluations/EVAL-0001/summary.md
```

## Output Format

Per-case JSONL:

```json
{
  "eval_id": "EVAL-0001",
  "dataset_version": "draft-v0",
  "case_id": "nav-doc-to-code-001",
  "candidate": "baseline-docs-rg",
  "repo": "AGENT-DOCS",
  "fixture_commit": "347a99464bb3afdb97bdf15f3c93722e48ebf4d6",
  "status": "ok",
  "token_source": "estimated",
  "metrics": {
    "input_tokens": 0,
    "output_tokens": 0,
    "tool_output_bytes": 0,
    "files_read_count": 0,
    "search_command_count": 0,
    "time_to_first_target_seconds": 0,
    "total_elapsed_seconds": 0,
    "target_precision": 0.0,
    "target_recall": 0.0,
    "stale_precision": null,
    "stale_recall": null,
    "task_success": true
  },
  "gold_targets": [],
  "observed_targets": [],
  "notes": ""
}
```

## Good-Enough Criteria

Build the first implementation only if a low-cost candidate meets all of these:

- at least 20 percent reduction in total tokens or tool output bytes on navigation-heavy cases
- at least 30 percent reduction in search commands or files read
- at least 80 percent stale recall on stale-link fixtures
- no decrease in task success versus baseline
- no increase in high-severity reviewer findings
- setup and maintenance cost stays small enough to explain in one short docs-meta guide

Stop or redesign if:

- warnings are noisy enough that agents ignore them
- symbol/index setup dominates the time saved
- generated graph output causes agents to trust stale or ambiguous links
- the useful result can be achieved by better `linked_paths` checks alone

## Results

Not run yet.

## Recommendation / ADR Input

Current pre-run recommendation:

Start with Candidate B or C, not D/E.

The best first test is:

1. Add a minimal `code_refs` schema for file/folder/path references only.
2. Extend `docs-meta health` or a new read-only command to warn when referenced paths changed after `repo_state.last_reviewed_commit`.
3. Generate a simple doc-to-path traceability report.
4. Run this evaluation on AGENT-DOCS before adding Tree-sitter, Monocle, or compiler indexes.

Why: this gives the highest likely gain per unit of complexity. It attacks the biggest current failure mode, stale or missing doc-code pointers, without requiring language-specific setup.

Monocle should be the first symbol-level experiment, but only in a Swift target repo where the tool is installed and `buildServer.json` or SwiftPM workspace state is known good.

## Reproduction Notes

Future automation can wrap agent runs in a harness that records:

- prompt and model metadata
- exact token usage when API usage is available
- command transcript
- opened file list
- changed file list
- verification commands and exit codes
- reviewer verdict

Until that harness exists, use paired manual sessions and record enough detail in JSONL for comparison.

## Artifact Policy

Commit summaries and sanitized excerpts. Keep raw private JSONL, transcripts, media, payload dumps, and user/private app code local unless explicitly sanitized.
