---
type: idea
document_format_version: 2
id: 01a03377-4efa-7b87-b747-4b46799bcd54
aliases: []
title: Project Bootstrap, CI, And Semantic Documentation Review
domain: agent-continuity
status: captured
created_at: "2026-08-24 20:10:36 JST +0900"
updated_at: "2026-08-25 03:33:59 JST +0900"
owner: Owen
source:
  type: conversation
  link:
  notes: "Owen proposed turning Agent Continuity into a complete new-project bootstrap that creates the local Git repository, GitHub repository, complete documentation footprint, deterministic GitHub Actions checks, and an optional LLM review layer that detects likely code-to-document drift without unnecessarily paying separate API costs."
areas:
  - agent-continuity
  - repository-bootstrap
  - continuous-integration
  - semantic-review
  - economical-automation
related_specs: []
related_research: []
related_issues: []
related_prs: []
related_ideas:
  - 01a02039-7a65-7579-b782-7b433cd8e001
related_explainers: []
related_sessions:
  - 01a03500-7324-7f48-bb3c-707b1259ba75
linked_paths:
  - install.sh
  - INSTALL.md
  - scripts/agent-continuity
  - scripts/agent-continuity-init
  - scripts/agent-continuity-docs
  - scripts/release-check
  - .github/workflows/ci.yml
promoted_to:
  - 01a034dd-eefc-7038-a814-ce4e28164af3
repo_state:
  based_on_commit: 25fd891b7a242d3e45a35382c6fcd7f3f565fe96
  last_reviewed_commit: 25fd891b7a242d3e45a35382c6fcd7f3f565fe96
---

# Project Bootstrap, CI, And Semantic Documentation Review

## Raw Thought

Agent Continuity should be able to take a fuzzy instruction such as:

> Create a new project called `orient-server`, put it on GitHub, and set it up properly.

and produce a recoverable, verified project rather than only copying documentation files into a directory.

The desired outcome is one command that can:

1. create or adopt a local project directory
2. initialize Git with a predictable default branch
3. install the complete Agent Continuity footprint
4. create truthful starter metadata without numbered examples
5. install deterministic continuous-integration checks
6. verify the generated repository before the first commit
7. create the GitHub repository through the authenticated GitHub CLI
8. push the initial commit
9. optionally protect `main`
10. optionally enable an LLM-backed semantic review layer

The deterministic and semantic layers should stay separate. Deterministic validation can prove that document structure is internally consistent. An LLM can inspect whether a code change probably made a statement in `CURRENT_STATE.md`, `ARCHITECTURE.md`, a spec, or a plan misleading. The LLM result is reasoned review evidence, not mathematical proof.

## Current State And Important Boundary

The upstream Agent Continuity repository already has a GitHub Actions workflow. It currently runs the upstream `scripts/release-check`:

- on direct pushes to `main`
- on pull-request events, without a base-branch filter

That workflow belongs only to this repository. A consuming repository does not inherit it merely because Agent Continuity files were installed there. GitHub Actions event handling is repository-local, so each consuming repository still needs a workflow file under `.github/workflows/`.

The implementation logic does not need to be duplicated. A consuming repository can contain a small caller workflow while Agent Continuity owns a versioned reusable workflow or composite action.

The current public workflow is also a release check for Agent Continuity itself. A target-project check needs a smaller contract that validates the installed repository rather than running Agent Continuity's own installer and smoke-test suite.

## Product Thesis

Agent Continuity should become a **project bootstrap and repository-memory verification layer**, not a replacement build system and not a hosted general-purpose AI reviewer.

The bootstrap should install a portable command contract:

```bash
agent-continuity ci
```

GitHub Actions, Jenkins, a pre-commit hook, or a local agent can all call that same command. Platform YAML should remain a thin adapter. This keeps the actual continuity rules testable outside GitHub and avoids embedding product behavior in one CI vendor.

## Proposed User Experience

### Create A New Project

```bash
agent-continuity project new orient-server
```

Accepted new-project defaults:

- profile: `complete` for every project created by this bootstrap
- local branch: `main`
- CI provider: GitHub Actions
- deterministic checks: enabled
- semantic review: disabled until explicitly selected
- GitHub visibility: ask interactively
- main protection: ask interactively
- mutation mode: preview first unless the user supplies `--write`

Non-interactive example:

```bash
agent-continuity project new orient-server \
  --path ~/Documents/Projects/orient-server \
  --github owensantoso/orient-server \
  --visibility private \
  --profile complete \
  --ci github-actions \
  --protect-main \
  --semantic-review codex-cloud \
  --write
```

### Adopt An Existing Local Project

```bash
agent-continuity project adopt . \
  --profile complete \
  --ci github-actions \
  --github owensantoso/existing-project \
  --write
```

`project adopt` should compose existing conservative `init`, `baseline`, `doctor`, and `upgrade` behavior rather than overwriting project-owned files.

### Preview The Entire Transaction

```bash
agent-continuity project new orient-server --dry-run
```

The preview should show:

- local files and directories to create
- Git commands to run
- GitHub repository name and visibility
- workflow files to install
- repository settings or rulesets to request
- checks that will run
- any external authentication still required
- whether semantic review has a recurring cost

## Bootstrap Transaction

The high-level transaction should be resumable and fail closed:

```text
preflight
   |
   v
create/adopt local directory
   |
   v
git init -b main
   |
   v
complete Agent Continuity init
   |
   v
render truthful starter metadata
   |
   v
install portable CI command + GitHub caller
   |
   v
run local deterministic verification
   |
   v
create initial commit
   |
   v
gh repo create --source ... --remote origin --push
   |
   v
optional branch ruleset / required check
   |
   v
write bootstrap receipt and final report
```

Important properties:

- Do not create the remote until local generation and validation pass.
- Do not claim completion until the exact commit exists remotely and its remote check passes.
- Record the requested and completed external steps in a bootstrap receipt.
- Re-running after interruption should inspect what already exists rather than blindly repeating mutations.
- Existing project-owned files remain project-owned.
- Agent Continuity-owned CI wrappers and workflow callers are recorded in the manifest with checksums and expected modes.
- Repository settings that cannot be verified should remain explicitly pending.

## Generated Repository Shape

The exact complete profile can evolve, but a fresh project should at least contain:

```text
.agent-continuity/
  manifest.json
  bootstrap-receipt.json

.github/
  workflows/
    agent-continuity.yml

AGENTS.md
docs/
  orientation/
    CURRENT_STATE.md
    ONBOARDING.md
    ARCHITECTURE.md
    ROADMAP.md
  product/
    ideas/
    specs/
    plans/
  decisions/
    adr/
    learnings/
    questions/
  repo-health/
    audits/
    evaluations/
    debugging/
    session-logs/
    testing-guide.md
  research/

scripts/
  agent-continuity-docs
```

Fresh repositories should remain UUID-native and aliasless. They should not contain live `IDEA-0000`, `SPEC-0000`, or `PLAN-0000` examples masquerading as project truth.

## Generated GitHub Actions Contract

The project workflow should run deterministic checks for every pushed branch and for pull requests targeting `main`:

```yaml
name: Agent Continuity

on:
  push:
    branches:
      - "**"
  pull_request:
    branches:
      - main
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: agent-continuity-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

Recommended jobs:

```text
continuity / deterministic
project / tests
continuity / semantic-review
```

Policy:

- `continuity / deterministic` runs on every branch push and every PR to `main`.
- `project / tests` invokes the project's own documented verification command when one exists.
- `continuity / semantic-review` runs only on PRs to `main`, or on explicit manual request.
- deterministic checks can become required immediately
- semantic review begins advisory and must earn the right to block merges

A branch with an open PR may cause both a push run and a PR run. That is acceptable for cheap deterministic checks. Concurrency should cancel superseded runs on the same ref.

## Portable Deterministic Check

`agent-continuity ci` should provide one stable entry point over existing commands:

```text
doctor
docs check
docs check-links
docs check-todos
generated-view freshness
manifest-owned tooling integrity
git diff --check
optional project test adapter
```

Suggested result classes:

```text
PASS        repository memory is mechanically valid
WARNING     advisory debt or likely review work
FAIL        deterministic contract is broken
TOOL_ERROR  validation could not be completed reliably
```

It should support:

```bash
agent-continuity ci
agent-continuity ci --format github
agent-continuity ci --json > agent-continuity-report.json
```

GitHub format should emit file-and-line annotations and a job summary. JSON should be uploaded as an artifact so another agent can consume findings without scraping terminal output.

CI must verify generated views, not silently rewrite and commit them. Automatic mutation inside a verification run would create surprising commits, merge conflicts, and unclear ownership.

## Semantic Documentation Review

The semantic layer answers a narrower question than a normal code-review bot:

> Does this change appear to make the repository's durable explanation of itself inaccurate, incomplete, or misleading?

Candidate inputs:

- base and head commit
- changed-file list and bounded diff
- applicable `AGENTS.md`
- `CURRENT_STATE.md`
- `ARCHITECTURE.md`
- related specs, plans, ADRs, questions, and learnings
- docs selected through `linked_paths`
- docs whose `last_reviewed_commit` predates changes in an owned surface
- deterministic-check report

Candidate output:

```json
{
  "schema_version": 1,
  "reviewed_base": "<sha>",
  "reviewed_head": "<sha>",
  "findings": [
    {
      "severity": "warning",
      "confidence": 0.91,
      "code_paths": ["Packages/Transit/Sources/RealtimeFeed.swift"],
      "doc_paths": ["docs/orientation/ARCHITECTURE.md"],
      "claim": "The architecture document still describes transit data as static.",
      "evidence": "The PR adds a realtime feed provider and routes production reads through it.",
      "suggested_action": "Update the architecture statement or record why this implementation does not change the documented boundary."
    }
  ]
}
```

The first version should be read-only:

- no automatic commits
- no automatic doc rewrites
- no broad shell access
- no external network tools
- no final authority over mergeability
- no finding without concrete code and document evidence

A clean result should mean “no likely contradiction found in the inspected scope,” not “the documentation is certainly correct.”

## Semantic Execution Backends

The semantic-review contract should be backend-neutral. Agent Continuity chooses the relevant context and validates the result schema; a provider adapter performs the model call.

### Option A: Codex GitHub Review Through The Existing ChatGPT Plan

Codex can connect directly to a GitHub repository, review a PR after an `@codex review` comment, and follow repository-specific review rules from `AGENTS.md`.

This is the lowest-friction experiment because:

- it uses the existing ChatGPT/Codex account rather than a Platform API key
- it already understands PR review and GitHub comments
- it can be instructed to check code-to-doc consistency
- it requires no local always-on computer
- it avoids building a custom reviewer before validating the idea

Limitations:

- its review format and severity policy are more general than the proposed Agent Continuity JSON contract
- manual `@codex review` is the safest assumption for an individual repository; automatic team-wide review availability may depend on account/workspace settings
- it behaves more like an advisory reviewer than a required CI status
- Agent Continuity has less control over context selection, budgeting, and result parsing

Recommended first experiment: add concise Agent Continuity review rules to `AGENTS.md`, then request several real reviews manually and record false positives, false negatives, and useful findings.

Reference:

- https://developers.openai.com/codex/third-party/github

### Option B: Self-Hosted GitHub Runner Using ChatGPT-Authenticated Codex CLI

This is possible without a Platform API key.

Codex CLI supports `codex login` with a ChatGPT account, and `codex exec` reuses the saved authentication. OpenAI also documents an advanced trusted-CI pattern that persists file-backed `~/.codex/auth.json` and lets Codex refresh it.

A GitHub self-hosted runner on Owen's Mac would listen for jobs and run the local Codex CLI. An inbound webhook or public port is not required; the runner maintains its own connection to GitHub and receives queued jobs.

Advantages:

- uses included ChatGPT/Codex allowance and purchased Codex credits rather than API billing
- can use the already installed CLI and local repository tooling
- can run only when the Mac is online; otherwise jobs remain queued
- can support multiple private repositories through an organization-level runner later

Serious constraints:

- `auth.json` is effectively a password and must never be committed or copied into logs
- the runner is persistent, so malicious workflow code can compromise the Mac and later jobs
- GitHub recommends that self-hosted runners almost never be used for public repositories
- OpenAI's ChatGPT-managed CI-auth guide says not to use that pattern for public or open-source repositories
- one credential copy should be used by one machine or serialized job stream
- the semantic job must not run arbitrary project scripts while Codex credentials are available

Therefore this is a plausible economical backend for trusted private repositories, but it is not the default for public `agent-continuity` PRs.

A safer private-repo shape is:

```text
GitHub event
   |
   v
GitHub-hosted deterministic job
   |
   v
trusted semantic job request
   |
   v
dedicated self-hosted runner label
   |
   v
fixed read-only wrapper -> isolated checkout -> codex exec
   |
   v
schema validation -> check result
```

The fixed wrapper should come from a trusted pinned source, not from the PR branch it is reviewing.

References:

- https://developers.openai.com/codex/auth
- https://developers.openai.com/codex/auth/ci-cd-auth
- https://developers.openai.com/codex/non-interactive-mode
- https://docs.github.com/actions/hosting-your-own-runners
- https://docs.github.com/en/actions/reference/security/secure-use

### Option C: Local Broker Or Bridge

A custom local service could poll GitHub for semantic-review requests, download a diff and selected documents, invoke `codex exec`, then post a check result.

This is preferable to exposing an unauthenticated webhook on a laptop. Polling or a standard self-hosted runner avoids inbound firewall and tunnel configuration.

A broker may eventually be worthwhile if it needs to:

- coordinate many repositories
- queue and deduplicate review requests
- enforce a fixed trusted prompt independently of project branches
- use multiple local or subscription-backed model clients
- suspend work when the user is actively using the computer
- provide one place for budget and audit logs

However, it is effectively a custom CI runner. It should not be the first implementation while GitHub's self-hosted runner already solves job delivery.

Automating the ChatGPT web interface through browser cookies, DOM scripting, or an unofficial message bridge should not be the product path. It is brittle, difficult to secure, hard to audit, and couples repository automation to a consumer UI session. Use Codex CLI, Codex cloud review, or a documented app-server/API surface instead.

### Option D: GitHub-Hosted API Review

The operationally cleanest fully automatic path is a GitHub-hosted job using:

- the official `openai/codex-action`, or
- a small read-only Responses API reviewer with schema-constrained output

A Platform API key is stored as a GitHub secret and exposed only to the review invocation. The job receives `contents: read`, does not run untrusted project code with the key present, and posts or uploads only the validated result.

This costs money separately from the ChatGPT subscription, but it is likely much cheaper than it initially sounds.

At the current published GPT-5.6 Luna rates:

```text
input:        $0.20 / 1M tokens
cached input: $0.02 / 1M tokens
output:       $1.20 / 1M tokens
```

Illustrative review costs below the long-context pricing threshold:

```text
50k input + 5k total output  ~= $0.016
150k input + 15k total output ~= $0.048
100 reviews at the larger shape ~= $4.80 before caching
```

Reasoning tokens are billed as output tokens, so cost controls still matter. The reviewer should:

- use relevant-doc retrieval rather than sending the whole repository
- use low or medium reasoning first
- cap total output tokens
- keep output schema compact
- avoid web search and shell tools
- exploit stable prompt prefixes and caching where available
- skip semantic review when changed paths cannot affect durable docs
- rerun only for a new head SHA
- optionally escalate ambiguous/high-impact cases to a stronger model

GPT-5.6 Luna is a strong first API candidate for this narrow workload because it is explicitly designed for cost-sensitive high-volume use and supports structured output. It should be evaluated against a small real corpus before being trusted as a blocker.

References:

- https://developers.openai.com/codex/github-action
- https://developers.openai.com/api/docs/models/gpt-5.6-luna
- https://developers.openai.com/api/docs/guides/reasoning

## Recommended Delivery Sequence

### Slice 1: Complete Project Bootstrap And Deterministic CI

Implement:

```bash
agent-continuity project new
agent-continuity project adopt
agent-continuity ci
```

Generate a GitHub Actions caller that runs on every branch push and every PR to `main`. Keep semantic review off.

Success means a completely new repository can be created, pushed, recovered on another machine, and shown green without hand-copying setup files.

### Slice 2: Manual Codex Review Experiment

Add root `AGENTS.md` review rules along these lines:

```markdown
## Code Review Rules

### Repository memory consistency

- When code changes behavior, architecture, supported surfaces, commands, or current implementation state, check whether the applicable Agent Continuity docs now make a contradictory or materially incomplete claim.
- Cite both the changed code and the affected document. Do not request documentation updates for implementation details that do not alter a durable claim.
- Treat generated views as caches. Recommend editing canonical source documents, not generated dashboards.
```

Use `@codex review` on representative PRs and collect evidence before building custom automation.

### Slice 3: Semantic Review Contract And Fixture Corpus

Create a provider-neutral JSON schema and a small evaluation set containing:

- obvious contradiction
- stale but harmless implementation detail
- changed code with no owned doc
- changed doc that accurately updates the claim
- generated-view-only diff
- renamed/moved code path
- prompt-injection text inside a source file
- large diff requiring scoped retrieval

Measure precision, recall, cost, latency, and reviewer usefulness.

### Slice 4: One Economical Backend

Choose based on actual usage:

- private trusted repositories and spare subscription allowance: self-hosted Codex CLI
- public repositories or unattended reliability: GitHub-hosted API job
- occasional human-in-the-loop review: built-in Codex GitHub review

Do not build all backends simultaneously.

### Slice 5: Required Semantic Gate, Only If Earned

A semantic gate may become required only after:

- findings are schema-valid and evidence-linked
- provider failures degrade predictably
- false-positive rate is low enough not to train users to ignore it
- a documented bypass exists
- the exact reviewed head SHA is recorded
- cost and latency are bounded
- prompt-injection fixtures pass

Until then, semantic findings are advisory.

## Security And Trust Rules

- Never run ChatGPT-authenticated Codex or API-key-backed review with broad write permissions by default.
- Never expose account auth to fork-controlled code.
- Never use `pull_request_target` to check out and execute untrusted PR code.
- Keep deterministic and secret-bearing semantic jobs separate.
- Pin reusable workflows and third-party actions to a reviewed release or immutable commit.
- Treat PR descriptions, commit messages, source comments, docs, and `AGENTS.md` from an untrusted branch as potentially adversarial input.
- Validate model output against a strict schema before converting it into GitHub annotations.
- Record provider, model, reasoning effort, prompt version, base SHA, head SHA, token usage, and result hash.
- A model outage should not silently produce a green semantic result.
- A semantic-review bypass should be explicit and auditable, not hidden in prose.

## What This Is Not

This idea does not require Agent Continuity to:

- replace GitHub Actions, Jenkins, or local build tools
- become a general CodeRabbit clone
- host a permanent multi-tenant review service
- prove arbitrary prose true
- automatically rewrite docs on every code change
- run an expensive frontier model on every branch commit
- require an API key before deterministic CI is useful
- expose ChatGPT web sessions or browser cookies to automation

## Main Open Questions

- Should `project new` create a GitHub repository by default, or require `--github`?
- `complete` is the accepted universal baseline for `project new`; lighter
  profiles remain available only through the lower-level `agent-continuity init`
  workflow for deliberately smaller/manual adoption.
- Should the generated workflow call a reusable upstream workflow or run the committed local CLI directly?
- How should branch protection be installed across free personal repositories, organizations, and private repositories with different GitHub feature availability?
- Should the first semantic review live entirely in Codex `AGENTS.md` rules before Agent Continuity defines its own provider contract?
- Can a self-hosted runner be safely constrained enough for Owen's private repositories without risking the rest of the Mac?
- What is the smallest fixture corpus that can distinguish useful doc-drift review from noisy “please update docs” comments?
- Which findings, if any, are deterministic enough to promote from advisory to blocking?
- Should `linked_paths` drive context selection directly, or should it feed the broader docs-to-code graph from the related idea?
- How should a PR explicitly state that docs were reviewed and no update was required without creating a meaningless checkbox ritual?

## Promotion Criteria

Promote this idea into a spec and parent plan when:

1. the exact `project new` transaction and failure semantics are accepted
2. the consuming-repo `agent-continuity ci` contract is defined
3. a generated GitHub Actions caller passes in at least one real target repository
4. remote repository creation and recovery are tested with a cold checkout
5. one manual Codex review experiment demonstrates whether repository-memory rules produce useful findings
6. the first semantic backend is chosen based on security, reliability, and measured cost rather than novelty
7. deterministic CI and semantic review remain independently usable
