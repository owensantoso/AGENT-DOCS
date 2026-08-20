# Agent Continuity Scripts

This folder contains two main scripts:

| Script | Purpose |
|---|---|
| `../install.sh` | bootstrap installer that puts `agent-continuity` plus compatibility commands on PATH |
| `agent-docs` | compatibility command namespace for Agent Continuity workflows |
| `agent-docs-init` | compatibility selected scaffold installer for target repos |
| `agent-continuity-docs` | implementation behind `agent-continuity docs` |
| `changelog-check` | changelog gate for reusable adopter-facing surfaces |
| `release-check` | local release-readiness wrapper used by CI |

## Agent Continuity Init

From the repo you want to document, install or update the command and preview the recommended standard footprint:

```bash
curl -fsSL https://raw.githubusercontent.com/owensantoso/agent-continuity/main/install.sh | bash -s -- --profile standard --dry-run
```

Use `--no-run` when you only want to install or update the command:

```bash
curl -fsSL https://raw.githubusercontent.com/owensantoso/agent-continuity/main/install.sh | bash -s -- --no-run
```

For private forks, authenticate with GitHub CLI and pipe the raw installer through `gh api` so the token stays out of shell history and process listings:

```bash
gh auth login
gh api -H "Accept: application/vnd.github.raw" /repos/OWNER/agent-continuity/contents/install.sh | AGENT_CONTINUITY_REPO_URL=https://github.com/OWNER/agent-continuity.git bash -s -- --profile standard --dry-run
```

Then use `agent-continuity init` to install the smallest useful Agent Continuity
footprint into another repo:

```bash
agent-continuity init --profile standard --dry-run
agent-continuity init --profile standard --write
agent-continuity init --profile standard --docs yes --write
agent-continuity init /path/to/project --profile standard --dry-run
agent-continuity init /path/to/project --profile expanded --dry-run
agent-continuity init /path/to/project --profile complete --dry-run
```

If no target path is provided, non-interactive mode uses the current directory and interactive mode asks whether to install into the current directory or another path.

Repeated installs are safe: the bootstrapper updates the local source checkout,
refreshes command symlinks, and reports when `agent-continuity`, `agent-docs`,
and `agent-docs-init` are already installed. Existing project files are listed
in dry-run, and write mode refuses to overwrite them unless `--force` is
explicitly provided.

Profiles:

| Profile | Meaning | Default |
|---|---|---|
| `core` | prototype, script, or single-person experiment | smallest flat docs, no document tooling |
| `standard` | real app with a few features and occasional agents | recommended default, no document tooling |
| `expanded` | multiple surfaces, handoffs, bugs, or decisions | selected topic folders, Agent Continuity document tooling |
| `complete` | long-lived repo with many agents and generated views | full scaffold and Agent Continuity document tooling |

Compatibility aliases still work for at least one release cycle: `tiny` maps to
`core`, `small` maps to `standard`, `growing` maps to `expanded`, and `full`
maps to `complete`. New manifests record the canonical profile key.

The interactive selector explains each profile and previews the tree while you
move through the choices. `core` and `standard` synthesize lighter docs,
including a smaller `ARCHITECTURE.md`; `expanded` and `complete` copy selected
files from `scaffold/`.

### Installed Manifest

Explicit write installs create `.agent-continuity/manifest.json`.

Schema version 2 contains:

- `schema_version`: currently `2`
- `agent_continuity_release`: named Calendar Versioning release
- `document_format_target`: currently `2`
- `installed_at` and `updated_at`: UTC timestamps
- `source`: Agent Continuity repository URL, ref, commit, and local source path when available
- `profile`: selected canonical profile
- `optional_components`: includes `agent-continuity-docs` when selected by a new install
- `files`: installed file records
- `generated_views`: present for future generated-view tracking, empty in this slice

File records use conservative ownership. Reusable tooling such as
`agent-continuity docs` and `tests/agent-continuity-docs-smoke.sh` is recorded as
`agent-continuity-owned` with a SHA-256 checksum and expected mode such as `755`.
Starter docs and templates are recorded as `project-owned-after-install` without
checksums, because target-repo Markdown becomes local truth after installation
and is not an automatic upgrade target.

### Legacy Manifest Baseline

Legacy installs without `.agent-continuity/manifest.json` can intentionally create a
baseline manifest only after a preview:

```bash
agent-continuity baseline --dry-run /path/to/project --profile standard --docs yes
agent-continuity baseline --write /path/to/project --profile standard --docs yes
```

`--dry-run` is the default. `--profile` is required and uses the same profile
keys as init. `--docs` accepts `auto`, `yes`, or `no`.

Baseline write mode creates only `.agent-continuity/manifest.json` and writes it last.
It records selected Agent Continuity-owned tooling only when the target file exists,
is a regular file inside the target, does not traverse symlinks, and matches the
current upstream checksum and exact expected mode. Starter/project docs are
recorded as `project-owned-after-install` when present, without checksums.
Existing manifests, missing or drifted owned tooling, wrong modes, symlinked
paths, non-directory parent conflicts, and non-regular files are refused.

### Doctor And Upgrade Dry Run

Inspect a manifest-backed target without writing files:

```bash
agent-continuity doctor /path/to/project
agent-continuity upgrade /path/to/project
agent-continuity upgrade --dry-run /path/to/project
```

Both commands read manifest schemas 1 and 2. Schema 1 is reported as a
tooling-only upgrade, while v1 authored documents are reported as a separate
content migration. Reports
include exact paths and reasons for healthy/current files, missing legacy
manifests, missing Agent Continuity-owned tooling, checksum drift, safe automatic
additions, candidate tooling updates, generated-view refreshes, project-owned manual-review
items, and refused or unknown shapes. Legacy installs without a manifest remain
manual-review.

### Tooling-Only Upgrade Write Mode

The only supported upgrade write path is:

```bash
agent-continuity upgrade --write --tooling-only /path/to/project
agent-continuity upgrade --write --tooling-only --generated-views /path/to/project
```

`agent-continuity upgrade --write` without `--tooling-only` exits `2`. Tooling-only
write mode may restore missing Agent Continuity-owned files, update manifest-clean
owned files from the current upstream action set, repair a missing executable bit
when the file content still matches the manifest, and update
`.agent-continuity/manifest.json` last. It creates backups for touched existing files
under `.agent-continuity/backups/<timestamp>/` and writes
`.agent-continuity/backups/<timestamp>/audit.json` with the touched paths, operation
kinds, and backup paths. Project-owned Markdown is report-only. Generated views
are report-only unless `--generated-views` is explicitly combined with
`--write --tooling-only`; that mode regenerates manifest-tracked generated views
through supported local generators, initially `agent-continuity docs update`.

Exit codes:

- `0`: healthy/current
- `1`: warnings or actionable drift
- `2`: invalid usage, refused, unknown, or incompatible shapes

Tooling-only write mode exits with the post-write classification, so a target
that is fully repaired by the write exits `0`.

Supported platforms and prerequisites: Bash on macOS or Linux, Git for installer clone/update paths, Python 3.10 or newer, symlink support, and a user-local bin directory such as `~/.local/bin` on `PATH` or an explicit `AGENT_CONTINUITY_BIN_DIR`.

## Structured Document Commands

`agent-continuity docs` is the deterministic structured-document interface.

It exists to keep repository memory queryable without asking a human or AI agent to manually maintain identity, status tables, generated registries, or todo dashboards. The important rule is simple: Markdown and frontmatter are authored truth, filenames are mutable locators, and generated files are views.

## What It Solves

Agent-driven projects tend to accumulate small bits of comprehension debt:

- branches assign conflicting numbered document identities
- plan and implementation statuses drift from reality
- generated registries are hand-edited and quietly become stale
- todos are scattered across specs, plans, and implementation briefs
- a future session cannot easily reconstruct what docs exist or where work stands

Agent Continuity turns those into mechanical operations. It scans the repo, derives state, and either writes reproducible generated files or fails when they are stale.

## Source Of Truth

Canonical state lives in docs files:

```text
docs/<domain>/specs/SPEC-<slug>.md
docs/<domain>/ideas/IDEA-<slug>.md
docs/<domain>/concepts/CONC-<slug>.md
docs/<domain>/plans/PLAN-<slug>/PLAN-<slug>.md
docs/<domain>/plans/PLAN-<slug>/IMPL-<brief-slug>.md
```

The script reads:

- UUIDv7 identities and legacy aliases from frontmatter
- status from frontmatter
- titles from frontmatter or first heading
- todos from Markdown checkboxes

It writes generated views:

```text
docs/SPECS.md
docs/IDEAS.md
docs/CONCEPTS.md
docs/LEARNINGS.md
docs/EXPLAINERS.md
docs/QUESTIONS.md
docs/DOCS-REGISTRY.md
docs/TODOS.md
docs/AREAS.md
docs/AUDITS.md
docs/ROADMAP-VIEW.md
docs/HEALTH.md
```

Those generated files should be treated as caches. If they disagree with the source docs, regenerate them instead of editing them by hand.

## Release Check

Run the same public-readiness checks used by CI:

```bash
scripts/release-check
```

The wrapper runs the installer, init, document-tooling, and compatibility smoke tests, compiles the Python
entry points, validates the adopter-facing changelog gate, checks structured
plan metadata and repo-root links, and finishes with `git diff --check`.

Run the changelog gate directly when changing reusable Agent Continuity surfaces:

```bash
scripts/changelog-check
```

The gate requires `CHANGELOG.md` when adopter-facing files such as installer,
scaffold, skill, reusable guide, or public command docs change. Use the explicit
marker `Change-Record: not-needed` in commit or PR text only when the path
changed without changing adopter behavior.

## Commands

Inspect the next legacy numeric alias. These commands exist for migrated
repositories and ID-retirement workflows; new documents do not use them:

```bash
agent-continuity docs next spec
agent-continuity docs next idea
agent-continuity docs next rsch
agent-continuity docs next eval
agent-continuity docs next diag
agent-continuity docs next plan
agent-continuity docs next impl --plan PLAN-0001
agent-continuity docs next adr
agent-continuity docs next lrn
agent-continuity docs next expl
agent-continuity docs next qst
agent-continuity docs next conc
```

Create new docs:

```bash
agent-continuity docs new spec "Shared Capture Workflow" --domain product --spec-type feature
agent-continuity docs new idea "Repo Memory Timeline" --domain product
agent-continuity docs new concept "Selections, Snapshots, And Dynamic Sections" --domain product
agent-continuity docs new research "Embedding Options Survey" --domain research
agent-continuity docs new eval "Embedding Model Bakeoff" --domain repo-health
agent-continuity docs new diag "Simulator Freeze Investigation" --domain repo-health
agent-continuity docs new plan "Shared Capture Implementation" --domain product --spec <spec UUID>
agent-continuity docs new impl "Persist Capture Drafts" --plan <plan UUID>
agent-continuity docs new adr "Use Append-Only Worktree Journal"
agent-continuity docs new learning "Why plans and specs are separate" --domain repo-health
agent-continuity docs new explainer "How specs and plans fit together" --domain orientation
agent-continuity docs new question "Should specs and plans be one-to-one?" --domain repo-health
```

Fresh documents use document format v2, receive UUIDv7 identity, write
`aliases: []`, and use type-plus-slug locators. Inspect or migrate formats with:

```bash
agent-continuity docs format-status
agent-continuity docs migrate-uuids --prepare-plan .agent-continuity/migrations/document-format-v2.json --write
git add .agent-continuity/migrations/document-format-v2.json
git commit -m "Prepare Agent Continuity UUID migration"
agent-continuity docs migrate-uuids --plan .agent-continuity/migrations/document-format-v2.json --write
```

Migration preserves old numeric IDs as aliases, changes no filenames or
relationship fields, refuses uncommitted plans and divergent preimages, and
writes its receipt last. Commit the receipt with the migrated documents.

Retire the current next implementation-brief ID without creating live work:

```bash
agent-continuity docs retire-id IMPL-0017-03 \
  --plan PLAN-0017 \
  --reason "The proposed slice was withdrawn before its brief was created." \
  --source-type codex-task \
  --source-link codex://threads/<thread-id>
```

`retire-id` is preview-only unless `--write` is passed. This legacy-compatibility command supports `IMPL-*`
only and requires the target to equal `agent-continuity docs next impl --plan
PLAN-####` for a live primary plan. Provenance requires a non-empty
`--source-type` plus at least one non-empty `--source-link` or
`--source-notes`.

The write creates exactly one project-owned typed tombstone at
`docs/id-retirements/<IMPL-ID>.md`. Exact repeats are byte-preserving and
idempotent; conflicting repeats, live collisions, future jumps, unsafe path
shapes, status changes, and direct or containing-directory moves are refused.
Link-rewrite operations exclude tombstones as source documents while continuing
to process other docs. Tombstones count for allocation and `DOCS-REGISTRY.md`
only. They do not satisfy live doc or TODO references, contribute global TODO
items, or appear in type-specific registries. “Permanent” means immutable
through supported Agent Continuity commands plus normal Git governance; manual
deletion remains visible to Git and is not intercepted by a background service.

The publication guarantee is target-path atomic no-overwrite: the command
stages one complete tombstone, performs a final rescan, and exclusively
publishes it only while that exact path remains absent. V1 does not lock or
serialize the wider repository IMPL namespace. Repository-level concurrent
allocators still require ordinary exclusive branch and owner discipline.

Inspect or update status:

```bash
agent-continuity docs status
agent-continuity docs status <document UUID>
agent-continuity docs show <document UUID or legacy alias>
agent-continuity docs set-status <document UUID> in_progress
```

`show` is the per-doc inspection command. It prints one doc's metadata, related docs from frontmatter, `linked_paths`, and local todos.

List todos:

```bash
agent-continuity docs todos
agent-continuity docs todos PLAN-0001
agent-continuity docs todos --all
agent-continuity docs todos --status ready
agent-continuity docs todos --owner main-agent
agent-continuity docs todos --agent 019dc454-98e1-7b22-9e79-56226fba0039
agent-continuity docs todos --skill docs-writer
agent-continuity docs todos --plan PLAN-0001
agent-continuity docs todos TODO-0001 --all
agent-continuity docs todos --json
agent-continuity docs check-todos
agent-continuity docs check-todos --strict
agent-continuity docs next todo
```

Show the open-loop review queue:

```bash
agent-continuity docs review
agent-continuity docs review --type audit-findings
agent-continuity docs review --status open
agent-continuity docs review --severity high
agent-continuity docs review --json
```

`review` is read-only. It parses audit finding registers, validates finding lifecycle rules, resolves routed follow-up targets, and surfaces blocked or stale open-loop docs and structured todos. Use it when you want the repo to answer "what needs attention next?" without hand-scanning audits, plans, questions, diagnostics, research, evaluations, and TODOs.

### Structured todos

Use ordinary Markdown checkboxes for local, low-ceremony checklists. Use structured `TODO-*` items only when work needs durable coordination across sessions, agents, subagents, skills, commits, or reviews.

Structured todo syntax stays Markdown-readable:

```markdown
- [ ] TODO-0001 [ready] [skill:docs-writer] [plan:PLAN-0002] Define stable todo lifecycle states.
- [ ] TODO-0002 [blocked] [blocker:TODO-0001] [brief:IMPL-0002-01] Add todo validation checks.
- [x] TODO-0003 [done] [verification:tests/agent-continuity-docs-smoke.sh] Document AGENTS.md routing rules.
```

Allowed lifecycle states:

```text
backlog
ready
in_progress
blocked
review
done
superseded
archived
```

Common metadata keys:

```text
owner
agent
skill
plan
brief
depends
depends_on
blocks
blocker
blocked_by
reason
verification
evidence
issue
pr
session
replacement
updated
```

Use `owner:` for the accountable person, role, or coordinating agent. Use `agent:` for the exact runner, chat, thread, subagent, or tool-session identifier when a TODO is claimed so the work is searchable in chat logs. Use `updated:` as an exact local timestamp, for example `2026-04-25 16:20:00 JST +0900`.

### Where structured todos live

Place each `TODO-*` in the lowest durable doc that owns the work:

| Work shape | Put the `TODO-*` in |
|---|---|
| Milestone, work package, dependency, or cross-brief progress | Parent plan |
| One bounded execution slice | Implementation brief |
| Operational checklist, repo-health pass, or temporary maintenance queue | Checklist, state, audit, or repo-health doc |
| Inline code note that now needs ownership, delegation, review, or a paper trail | Promote to the related plan or brief; leave a short code comment pointing to the `TODO-*` only if useful |

Parent plans and implementation briefs remain the scope authority. `TODO-*` IDs are progress handles, not replacement requirements.

### Lifecycle actions

Use these edits on the source checkbox line:

| Action | Required update |
|---|---|
| Create | Add `TODO-#### [backlog]` or `[ready]` in the owning doc. Use `agent-continuity docs next todo` for the next ID. |
| Claim | Change status to `[in_progress]` and add `owner:`, `agent:`, and `updated:`. |
| Block | Change status to `[blocked]` and add `blocker:`, `blocked_by:`, or `reason:`. |
| Send to review | Change status to `[review]` and refresh `updated:`. |
| Close | Check the box, set `[done]`, and add `verification:`, `evidence:`, or `reason:`. |
| Supersede | Set `[superseded]` and add `replacement:` or `reason:`. |
| Archive | Set `[archived]` and add `reason:`. |

IMPORTANT: edit the source doc, not `TODOS.md`. `TODOS.md` is generated from source checkboxes.

Source docs remain canonical. `TODOS.md` is a generated dashboard; regenerate it instead of editing it by hand.

Source-code TODO comments are intentionally not scanned by Agent Continuity. Keep inline TODO comments for local implementation notes that only matter near that code. If an inline TODO needs ownership, delegation, review, cross-session tracking, or commit/PR/session-log references, promote it to a structured Markdown `TODO-*` in the relevant plan, implementation brief, checklist, or state doc, and leave a short code comment pointing to that ID only when it helps the next reader.

When a commit, PR, issue, or session log is todo-backed, cite the `TODO-*` ID there too. Use source-doc metadata such as `issue:#123`, `pr:#456`, and `session:repo-health/session-logs/YYYY-MM-DD-session-title.md` when it helps future lookup, but do not make GitHub the only source of task truth.

`check-todos` validates duplicate IDs, lifecycle/checkbox contradictions, missing claim metadata for `in_progress`, missing freshness for `review`, missing blockers or reasons for `blocked`, missing closeout evidence for `done`, missing plan/brief references, and missing referenced `TODO-*` dependencies. `check-todos --strict` also warns about helpful routing/freshness metadata such as `skill` and `updated` on ready or blocked work.

### Learning records

Use `LRN-*` learning records for lessons learned: durable corrected assumptions, surprising discoveries, plan corrections, and runtime/tooling discoveries that should change future behavior.

Create one when the lesson should survive the chat:

```bash
agent-continuity docs new learning "Why specs and plans are not one-to-one" --domain repo-health
agent-continuity docs next lrn
agent-continuity docs view learnings
agent-continuity docs view explainers
agent-continuity docs view questions
```

Do not use learning records for routine implementation narration. Use session logs for what happened, ADRs for durable decisions, research notes for investigations, specs for requirements, and plans or briefs for execution scope.

Ask ordinary clarification questions in chat. Keep local open questions in the owning spec, plan, implementation brief, research note, session log, explainer, or learning record. Create a `QST-*` only when unresolved uncertainty needs durable status, ownership, links, or resolution history across sessions. Promote a question to `TODO-*` only when it needs action, verification, or closeout.

Use `EXPL-*` explainers for reusable human-facing teaching material. Include a visualization-pass-style diagram when structure, flow, state, ownership, or behavior is clearer visually than in prose.

Use `CONC-*` concept notes for semi-mature domain models, taxonomy, ontology, naming, or source-of-truth sketches. Concepts are more reasoned than raw ideas, but they are not yet binding specs, ADRs, plans, or user-facing explainers.

### Evidence docs

Use `RSCH-*` research surveys when the question is "what options exist?" and the answer needs sourced landscape work before a spec, ADR, plan, or evaluation.

Use `EVAL-*` evaluations when the question can be answered by repeatable fixtures, metrics, timings, thresholds, or a bakeoff. The Markdown doc records the protocol and recommendation; raw outputs belong under `artifacts/evaluations/EVAL-####/` and are git-ignored by default unless explicitly sanitized.

Use `DIAG-*` diagnostic records when a real run, crash, freeze, slow flow, or flaky behavior needs structured evidence to outlive chat. Raw traces belong under `artifacts/diagnostics/DIAG-####/` and are git-ignored by default; commit summaries and sanitized excerpts.

Regenerate and check generated views:

```bash
agent-continuity docs update
agent-continuity docs check
```

`check` also validates frontmatter contracts for known doc types, type-specific statuses, UUIDv7 and alias uniqueness, v1 ID/filename compatibility, retirement tombstone paths, provenance, parent plans and scanner collisions, and whether generated registry files are stale.

Inspect docs links:

```bash
agent-continuity docs links
agent-continuity docs links docs/README.md
agent-continuity docs backlinks docs/README.md
agent-continuity docs check-links
agent-continuity docs orphans
agent-continuity docs orphans --exclude 'repo-health/session-logs/*'
```

`links` parses standard Markdown links, Markdown image links, path-like autolinks, and Obsidian-style wikilinks. Standard Markdown links are the canonical format; wikilinks are reported for visibility but are not rewritten.

`check-links` exits nonzero when repo-local Markdown links point at missing files, folders without a `README.md` or `index.md`, or paths outside the repo. It does not validate external HTTP links.

`orphans` supports repeatable `--exclude` glob patterns. Individual docs can also opt out with `docs_meta_ignore_orphan: true` or `orphan_ok: true` frontmatter when low-link docs are intentional.

Normalize or move docs safely:

```bash
agent-continuity docs normalize-links --style relative --dry-run
agent-continuity docs normalize-links --style relative --write
agent-continuity docs move docs/old.md docs/new.md --dry-run
agent-continuity docs move docs/old.md docs/new.md --write
```

Mutating commands are dry-run-first. They preserve link labels and fragments, rewrite only structured Markdown hrefs, and report prose mentions separately for human review.

Show advisory docs-health warnings:

```bash
agent-continuity docs health
agent-continuity docs health --stale-days 30 --commit-threshold 20 --audit-days 45
agent-continuity docs health --json
agent-continuity docs health --write
```

`health` is intentionally softer than `check`. It flags docs that may be worth reviewing because they are old, still in an open status, missing a review commit, many commits behind `repo_state.last_reviewed_commit`, because the repo has no recent completed repo-health audit, or because link-health signals deserve review. It exits successfully even when warnings exist; treat the output as a review queue, not a CI failure. Running it also refreshes `docs/HEALTH.md`.

Show or write the plan roadmap view:

```bash
agent-continuity docs roadmap
agent-continuity docs roadmap --json
agent-continuity docs roadmap --write
```

`roadmap` sorts `type: plan` docs by optional `sequence` frontmatter for presentation. UUIDs and filenames never encode execution order; blocking order belongs in explicit typed dependencies. Running it also refreshes `docs/ROADMAP-VIEW.md`.

Print and refresh any generated Markdown view:

```bash
agent-continuity docs view ideas
agent-continuity docs view specs
agent-continuity docs view learnings
agent-continuity docs view explainers
agent-continuity docs view questions
agent-continuity docs view registry
agent-continuity docs view todos
agent-continuity docs view areas
agent-continuity docs view audits
agent-continuity docs view roadmap
agent-continuity docs view health
```

Generated views include YAML frontmatter with `type: generated-view`, `status: generated`, and `updated_at`. The `updated_at` field changes whenever the view is regenerated.

Run the smoke test after changing `agent-continuity docs` behavior:

```bash
tests/agent-continuity-docs-smoke.sh
```

## Naming Model

UUIDv7 is canonical identity. Type prefixes and slugs are human locators;
numeric values appear only as aliases on migrated records:

```text
document_format_version: 2
id: 019d2f60-7d3a-7bb0-bf46-ae03ee6b6472
aliases: []
type: plan
```

Relationships belong in frontmatter:

```yaml
related_specs:
  - <spec UUID>
promoted_to:
  - <spec UUID>
parent_plan: <plan UUID>
sequence:
  roadmap: "3.5.1"
  sort_key: "003.005.001"
  lane: product
  after: [<plan UUID>]
related_issues:
  - "#123"
linked_paths:
  - apps/web/src/routes/todos.tsx
  - packages/core/todo/parser.ts
```

This avoids encoding a many-to-many relationship graph into filenames. An idea can be promoted to a concept, spec, ADR, research note, or plan; a concept can be promoted to a spec, ADR, plan, architecture doc, or explainer; a plan can relate to multiple specs; a spec can lead to multiple plans; and an implementation brief can remain visibly scoped to its parent plan.

Use `linked_paths` for repo files or folders that matter to a doc but are not themselves structured docs. Keep paths repo-relative.

## File Metadata

Filesystem metadata such as created time, modified time, and last opened time is useful locally, but it is not a reliable repo memory contract. It can change during copies, checkouts, rebases, restores, or editor operations, and it does not explain why a doc was reviewed.

Use frontmatter for semantic metadata that should travel with the repo:

```yaml
created_at: "2026-04-25 10:44:01 JST +0900"
updated_at: "2026-04-25 10:44:01 JST +0900"
repo_state:
  based_on_commit: <commit>
  last_reviewed_commit: <commit>
```

Use generated views or local logs for derived activity such as "last viewed", per-file history, or stale-doc review queues. Those are observations about use, not canonical doc content.

## Repo State

Created docs include repo-state frontmatter when Git is available:

```yaml
repo_state:
  based_on_commit: <commit>
  last_reviewed_commit: <commit>
```

Use this to understand which repository state a spec, plan, or implementation brief was based on. This is especially useful when work spans multiple sessions or the code changes before the doc is executed.

## Adoption

Install Agent Continuity document tooling in a repo that uses this workflow. Then:

1. Ensure idea, research, evaluation, diagnostic, spec, plan, implementation brief, and ADR templates have `id`, `type`, `status`, `created_at`, `updated_at`, and relationship frontmatter.
2. Prefer `agent-continuity docs new ...` for new ideas, research surveys, evaluations, diagnostics, specs, plans, implementation briefs, and ADRs.
3. Run `agent-continuity docs update` after meaningful doc changes.
4. Run `agent-continuity docs check` before committing docs workflow changes.
5. Run `agent-continuity docs check-todos` when the repo uses structured `TODO-*` items for durable coordination.

For stricter repos, wire `agent-continuity docs check`, `agent-continuity docs check-links`, and `agent-continuity docs check-todos` into CI or a pre-commit hook. Keep hooks as verification; do not hide surprising doc or todo rewrites inside an automatic commit step.

## Limits

The structured-document implementation is intentionally small and conservative.

- It uses simple frontmatter parsing, not a full YAML parser.
- It does not decide what a spec or plan should say.
- It does not replace ADRs, session logs, GitHub issues, or PR descriptions.
- It does not make generated registries canonical.
- It does not validate external HTTP links.
- It does not rewrite prose mentions automatically.

The goal is not to document everything. The goal is to make the important metadata deterministic enough that future humans and agents can trust the map.
