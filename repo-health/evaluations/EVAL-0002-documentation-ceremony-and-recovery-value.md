---
type: evaluation
document_format_version: 2
id: 01a02039-7a67-7e60-976d-d2a36f58346f
aliases:
  - "EVAL-0002"
title: Documentation Ceremony And Recovery Value
domain: repo-health
status: archived
created_at: "2026-08-20 17:13:32 JST +0900"
updated_at: "2026-08-20 22:33:40 JST +0900"
owner: "Codex main agent"
hypothesis: "An adaptive Agent Continuity packet improves accepted task outcomes, cold recovery, and provenance accuracy enough to repay its authoring, retrieval, and maintenance cost; a derived control plane further improves retrieval without becoming a second source of truth."
artifact_root: artifacts/evaluations/EVAL-0002/
dataset_version: "protocol-draft-v0"
fixture_digest:
run_command: "Manual paired-agent protocol for calibration; automate only after the fixtures and scoring rubric harden."
metrics_version: "ceremony-value-v0"
baseline_eval:
related_research:
  - ../../research/RSCH-0010-spec-systems-and-agent-continuity-fit.md
related_diagnostics: []
related_adrs: []
related_specs: []
related_plans: []
related_sessions:
  - ../../session-logs/2026-08-20-spec-systems-and-ceremony-evaluation.md
linked_paths:
  - README.md
  - guides/doc-types-and-responsibilities.md
  - agent-continuity/ideas/IDEA-0003-federated-document-library-and-relationship-graph.md
repo_state:
  based_on_commit: 7ec866c4557e941e1cb5577e3c4be531ac46c940
  last_reviewed_commit: 0de3c733c69f706dbd04ba6ce40879bb739f5f08
---

# EVAL-0002 - Documentation Ceremony And Recovery Value

## Parked - 2026-08-20

This protocol is retained for a future ceremony or token-efficiency investigation, but no run is scheduled. Native Agent Continuity design continues without requiring this evaluation first.

Reopen it only after a concrete signal such as repeated cold-recovery failure, measurable maintenance burden, retrieval overhead, or a deliberate simplification effort. Until then it should create no fixtures, harness work, or adoption obligation.

## Status And Decision Boundary

This is a preserved pre-run protocol. No results exist.

The evaluation may recommend that Agent Continuity document types remain core, become trigger-only, merge into another owner, or retire. It may also recommend a bounded Spec Kit or OpenSpec pilot. It does not authorize installing either tool, migrating repositories, deleting documents, or changing the ID schema.

## Hypothesis

The main hypothesis is:

> An adaptive Agent Continuity packet improves accepted task outcomes, cold recovery, and provenance accuracy enough to repay its authoring, retrieval, and maintenance cost.

Two narrower hypotheses must be tested separately:

1. **Artifact-set hypothesis:** differentiated current state, decision, evidence, and history artifacts improve outcomes compared with a minimal spec/plan/task packet or a current-spec/change packet.
2. **Surfacing hypothesis:** a derived control plane makes the same rich corpus cheaper and safer to use than raw file-tree search, without hiding stale sources or becoming a second authority.

Testing these separately prevents a polished interface from making unnecessary documents look useful, and prevents poor retrieval from making valuable provenance look useless.

## Evaluation Mode

Use a controlled comparison with paired cold agents.

Freeze for every pair:

- task wording and acceptance rubric
- repository commit and code fixture
- model, reasoning level, tool access, permissions, and time budget
- which documentation packet is visible
- whether chat history and machine-local memory are unavailable
- reviewer rubric and severity definitions

Randomize candidate order. Use a fresh task for each run. The scoring reviewer should receive the task, final diff or answer, verification evidence, and artifact-use log, but not the candidate label until scoring is complete.

Do not use one agent sequentially across candidates; learning from the first packet would contaminate later runs.

## Staged Candidates

### Stage 1 - Artifact-Set Value

All candidates use plain files and ordinary repository search. Do not install Spec Kit or OpenSpec yet; the goal is to compare information shapes without confounding them with different command harnesses.

| Candidate | Visible packet | Purpose |
|---|---|---|
| `A-minimal-delivery` | Short current-state page, governing constraints, one feature spec, one plan/task list | Spec Kit-inspired lightweight baseline |
| `B-current-and-change` | Current domain spec plus one proposed change containing rationale, delta, design, and tasks | OpenSpec-inspired truth/change baseline |
| `C-adaptive-continuity` | Memory kernel plus only the Agent Continuity artifacts whose admission triggers apply to the fixture | Test whether differentiated provenance and evidence add value |
| `D-complete-continuity` | Full eligible Agent Continuity corpus, including deliberately irrelevant and stale material | Measure the penalty of rich documents without adaptive admission or good surfacing |

The content must be semantically equivalent where the systems overlap. Do not give Candidate C a hidden answer absent from A and B unless the fixture is explicitly testing whether that class of historical or evidence information should exist.

### Stage 2 - Surfacing Value

Use the exact same Candidate C corpus and task pair:

| Candidate | Retrieval surface | Purpose |
|---|---|---|
| `C1-raw-tree` | File tree, `rg`, and current generated Markdown registries | Baseline retrieval cost |
| `C2-control-plane` | Read-only search, typed filters, backlinks, current/blocked/ready projections, source revision, and freshness labels | Isolate the value of the future control plane |

The control-plane run must still expose and link the canonical source. It fails if an agent cannot distinguish derived, stale, missing, or conflicting data.

### Stage 3 - Live Tool Fit

Only run after Stage 1 and Stage 2 identify a real gap.

| Candidate | Tool trial | Bounded ownership |
|---|---|---|
| `E-spec-kit-live` | Pinned Spec Kit version for one repo-local feature | Owns that feature's spec, plan, tasks, workflow gates, and convergence check |
| `F-openspec-live` | Pinned OpenSpec version inside one private project operations satellite | Owns one current-spec and proposed-change lifecycle |
| `G-agent-continuity-native` | Existing Agent Continuity commands and adaptive profile | Owns the equivalent artifact classes without parallel copies |

Never run a candidate by copying the same authoritative text into two systems. Each trial gets a clean fixture branch or repository copy and one declared owner per artifact class.

## Dataset And Fixtures

### Complexity Cohorts

Project size is recorded but not used as the sole classifier. Cohorts are based on the cost of forgetting and coordination:

| Cohort | Fixture shape | Why it matters |
|---|---|---|
| `S-small-direct` | One repository, one surface, bounded reversible feature, no prior controversy | Rich history may be pure overhead |
| `M-interrupted` | Existing project, cross-cutting change, one interruption, one superseded design choice | Tests recovery, rationale, and stale-plan handling |
| `L-cross-boundary` | Multiple repositories or public/private boundary, concurrent branches, explicit human acceptance or rollback state | Tests identity, ownership, provenance, and evidence distinctions |

### Required Cases

| Case | Required hidden facts and traps | Primary signal |
|---|---|---|
| `small-feature-001` | Clear requirement; no historical ambiguity; one valid implementation path | Does extra documentation slow a simple task? |
| `cold-recovery-001` | Work stopped mid-change; current code differs from original plan; session evidence states what remains | Recovery time and stale-plan avoidance |
| `rejected-option-001` | A plausible prior option was rejected for a durable reason; a decoy doc still mentions it | Decision retrieval and contradiction avoidance |
| `evidence-state-001` | Automated test passed, deployment did not happen, human acceptance is absent | Evidence-state accuracy and hallucination resistance |
| `concurrent-id-001` | Two branches independently create similarly named artifacts and overlapping work | Identity collision, merge repair, and owner selection |
| `public-private-001` | Public code must remain independently usable; private operations context exists but must not leak | Boundary correctness and discovery behavior |

Each fixture must include:

- immutable repository commit or archive digest
- gold current truth and governing owner
- gold relevant artifact set
- at least one irrelevant artifact after the first calibration case
- at least one stale or superseded claim in the medium and large cohorts
- an acceptance test or reviewer rubric that does not depend on candidate terminology
- sanitized content suitable for the chosen artifact policy

### Repetitions

Calibration:

- run `small-feature-001` and `cold-recovery-001`
- compare A, B, C, and D
- use two independent agents per candidate and case
- total: 16 runs

Full first pass:

- run all six cases
- use at least two independent agents per candidate
- repeat any case whose paired outcomes disagree materially before drawing a conclusion

Do not expand to live-tool Stage 3 until the calibration packet, instrumentation, and reviewer agreement are usable.

## Metrics

### Outcome Quality

| Metric | Definition |
|---|---|
| `task_success` | Acceptance tests and required human-independent checks pass |
| `outcome_score` | Blinded reviewer score from 0 to 10 against the frozen rubric |
| `missed_constraint_count` | Governing requirements absent or violated in the result |
| `contradiction_count` | Claims or edits that conflict with a higher-authority source |
| `wrong_owner_edits` | Edits made to a projection, duplicate, or non-owning artifact |
| `evidence_state_accuracy` | Correct classification of proposed, implemented, automatically verified, deployed, and human accepted facts |
| `provenance_answer_score` | Accuracy and source support for why, alternatives, supersession, and evidence questions |
| `review_findings_by_severity` | Critical, high, medium, and low findings after blinded review |

### Recovery And Navigation

| Metric | Definition |
|---|---|
| `time_to_governing_truth_seconds` | Time until the run opens and correctly identifies the canonical source |
| `time_to_first_correct_action_seconds` | Time until the first change or answer aligned with the gold path |
| `cold_recovery_score` | Correct reconstruction of built, verified, pending, blocked, and next states |
| `files_read_count` | Distinct source files opened |
| `search_command_count` | Repository, symbol, and document searches |
| `context_input_tokens` | Exact tokens when available, otherwise tokenizer estimate labelled as estimated |
| `tool_output_bytes` | Bytes returned by search, read, and inspection tools |
| `human_corrective_turns` | Clarifications or corrections needed after the frozen prompt |

### Ceremony And Maintenance

| Metric | Definition |
|---|---|
| `documentation_authoring_seconds` | Time spent creating durable artifacts for the fixture |
| `documentation_maintenance_seconds` | Time spent updating, reconciling, moving, or retiring them |
| `docs_created_count` | New authoritative docs, excluding generated views |
| `docs_touched_count` | Authoritative docs changed during the work |
| `generated_views_touched_count` | Derived views regenerated or repaired |
| `merge_repair_seconds` | Time spent resolving documentation identity or content conflicts |
| `stale_artifact_count` | Opened artifacts whose claims no longer matched their declared base or owner |
| `orphan_artifact_count` | Eligible non-core artifacts with no valid incoming path from an entry surface or relation |
| `duplicate_authority_count` | Facts represented as current authority in more than one artifact owner |

### Per-Document-Type Instrumentation

Record artifact events so the evaluation can distinguish unused clutter from decisive provenance:

```json
{
  "artifact_id": "ADR-0004",
  "artifact_type": "ADR",
  "event": "changed_decision",
  "elapsed_seconds": 18,
  "notes": "Prevented reuse of rejected storage option",
  "reviewer_confirmed": true
}
```

Allowed initial events:

```text
available
opened
cited
changed_decision
caught_error
enabled_recovery
required_evidence
stale
contradictory
maintained
ignored
```

Opening or citing a document is not itself value. Material events are `changed_decision`, `caught_error`, `enabled_recovery`, or `required_evidence`, confirmed by the blinded reviewer or fixture gold labels.

### Derived Measures

```text
ceremony_ratio = (documentation_authoring_seconds + documentation_maintenance_seconds)
                 / total_elapsed_seconds

recovery_gain_seconds = baseline_time_to_governing_truth_seconds
                        - candidate_time_to_governing_truth_seconds

memory_return = (baseline_rework_seconds + baseline_recovery_seconds
                 - candidate_rework_seconds - candidate_recovery_seconds)
                / candidate_documentation_maintenance_seconds

retrieval_yield = materially_used_non_core_artifacts
                  / eligible_non_core_artifacts_available
```

Report these with raw component measures. Do not reduce the evaluation to a single composite score.

## Run Procedure

```bash
# Protocol draft; no harness is implemented yet.

# 1. Freeze each fixture commit/archive and compute its digest.
# 2. Freeze gold labels, acceptance rubric, packet manifests, and decoy/stale docs.
# 3. Randomize candidate order and assign fresh cold agents.
# 4. Run with identical model, reasoning, tools, permissions, and time budget.
# 5. Save tool transcript, final result, verification, and artifact events locally.
# 6. Blind candidate labels and obtain outcome/review scores.
# 7. Aggregate raw metrics, paired differences, reviewer agreement, and failure classes.
# 8. Record any protocol deviation before revealing candidate labels.
```

The first implementation should be a simple fixture manifest plus result schema, not an orchestration platform.

## Output Format

Per-run JSONL:

```json
{
  "eval_id": "EVAL-0002",
  "protocol_version": "protocol-draft-v0",
  "metrics_version": "ceremony-value-v0",
  "case_id": "cold-recovery-001",
  "cohort": "M-interrupted",
  "candidate": "C-adaptive-continuity",
  "replicate": 1,
  "fixture_digest": "",
  "model": "",
  "reasoning_level": "",
  "status": "ok",
  "protocol_deviations": [],
  "metrics": {
    "task_success": false,
    "outcome_score": 0,
    "missed_constraint_count": 0,
    "contradiction_count": 0,
    "wrong_owner_edits": 0,
    "evidence_state_accuracy": 0.0,
    "provenance_answer_score": 0.0,
    "time_to_governing_truth_seconds": 0,
    "time_to_first_correct_action_seconds": 0,
    "cold_recovery_score": 0.0,
    "human_corrective_turns": 0,
    "documentation_authoring_seconds": 0,
    "documentation_maintenance_seconds": 0,
    "total_elapsed_seconds": 0
  },
  "artifact_events": [],
  "review_findings": [],
  "notes": ""
}
```

The summary must retain per-case results. A mean that combines a trivial feature with a privacy-boundary failure is misleading.

## Pre-Registered Good-Enough Criteria

These are initial decision gates, chosen before results. Amend them only before the affected candidate is run, and record the reason.

### Adaptive Agent Continuity Continues

Candidate C earns a broader trial only if all are true:

- no decrease in task-success rate versus both A and B
- no additional critical or high reviewer finding
- correct evidence-state classification in every `evidence-state-001` successful run
- either a median 20 percent reduction in recovery time on medium/large cohorts or at least two reviewer-confirmed material omissions prevented across those cohorts
- median ceremony ratio no greater than 15 percent for small and medium cases, unless a higher ratio is tied to required safety, privacy, legal, release, or human-acceptance evidence

### Complete-By-Default Is Rejected

Candidate D is rejected as a default if either is true:

- it increases median time to governing truth or human corrective turns without improving outcome quality over C
- its stale, orphan, or ignored non-core artifact rate exceeds C by 25 percentage points

The complete taxonomy may still remain available as trigger-only capabilities.

### A Document Type Earns Its Keep

A non-core artifact type is classified after all eligible cases:

- `core`: needed in most eligible cases and cheap to maintain
- `trigger-only`: at least two reviewer-confirmed material events in its applicable cohort, or one prevented critical/high failure
- `merge-candidate`: material value exists, but another artifact owner can preserve it with lower cost and no ambiguity
- `retire-candidate`: no material event, plus measurable maintenance, retrieval, staleness, or duplicate-authority cost

Do not retire a type because it was ineligible for the chosen fixtures. Add an eligible case or mark the evidence insufficient.

### The Control Plane Continues

Candidate C2 earns implementation work only if, against C1 on the same corpus:

- median time to governing truth improves by at least 30 percent
- median files read or tool-output bytes improves by at least 25 percent
- task success and evidence-state accuracy do not decrease
- stale or conflicting source state is never silently presented as current
- every displayed claim can resolve to a canonical source and revision

### Live Spec Kit Or OpenSpec Adoption Continues

A live tool candidate earns a second-project pilot only if:

- it has one unambiguous artifact-ownership map
- it improves accepted-outcome time or reduces human corrective turns by at least 20 percent against the artifact-equivalent native workflow
- it does not increase critical/high review findings or evidence-state confusion
- public/private disclosure and cold discovery behave as declared
- an isolated no-tool exit test reconstructs current truth, active work, and provenance from committed artifacts
- adaptation stays within templates, configuration, a small resolver, and validation; no second synchronization or lifecycle engine is required

## Stop And Redesign Conditions

Stop the current candidate if:

- the fixture accidentally reveals its gold answer through candidate naming or packet metadata
- a run receives different permissions, tool access, source revision, or hidden memory
- the same artifact is authoritative in more than one system
- raw private transcripts or payloads would need to be committed
- a control-plane view cannot report source revision and freshness
- reviewer agreement is too low to distinguish candidate effects
- live OpenSpec or Spec Kit customization expands into a fork or second orchestration product

## Results

Not run.

Evidence state:

- protocol: drafted
- fixtures: not created
- harness: not implemented
- calibration runs: not run
- human review: not run
- adoption decision: open

## Recommendation And ADR Input

Run only the 16-run calibration first. Its purpose is to answer three questions cheaply:

1. Does the adaptive packet outperform the minimal and current/change packets on cold recovery without harming the small task?
2. Does the complete packet create a measurable clutter penalty compared with the adaptive packet?
3. Can the instrumentation attribute value or cost to individual document types reliably enough to guide simplification?

If the answer to the third question is no, improve the fixtures and rubric before building a control plane or running live tool pilots. If the adaptive packet shows no material gain, simplify Agent Continuity before adding integrations. If it does show gain but raw retrieval is expensive, proceed to the control-plane ablation.

Use an architecture decision record only after a stage produces sufficient evidence for a durable choice.

## Reproduction Notes

- Pin external tool versions and archive their relevant templates or configuration digests for live trials.
- Record exact local timestamps, model/reasoning identifiers, and whether token counts are exact or estimated.
- Preserve failed and adverse lifecycle runs; do not report only successful feature delivery.
- Keep human acceptance as a separate evidence field rather than inferring it from tests, archive state, or task completion.
- Publish sanitized aggregate results. Keep raw transcripts and private project material under the ignored artifact root unless Owen explicitly approves a reviewed subset.

## Artifact Policy

Commit:

- protocol, fixture manifest schema, gold-label schema, scoring rubric, aggregate tables, and sanitized failure classes

Keep local by default:

- raw prompts and transcripts
- private repository contents
- tool payloads and machine paths
- unreviewed external workflow files
- personally sensitive context
