# Docs Meta

`docs-meta` is a deterministic metadata helper for agent-friendly docs.

It exists to keep repository memory queryable without asking a human or AI agent to manually maintain counters, status tables, generated registries, or todo dashboards. The important rule is simple: Markdown files, filenames, and frontmatter are the source of truth. Generated files are views.

## What It Solves

Agent-driven projects tend to accumulate small bits of comprehension debt:

- the next `IDEA-*`, `SPEC-*`, `PLAN-*`, or `ADR-*` number is guessed instead of derived
- plan and implementation statuses drift from reality
- generated registries are hand-edited and quietly become stale
- todos are scattered across specs, plans, and implementation briefs
- a future session cannot easily reconstruct what docs exist or where work stands

`docs-meta` turns those into mechanical operations. It scans the repo, derives state, and either writes reproducible generated files or fails when they are stale.

## Source Of Truth

Canonical state lives in docs files:

```text
docs/<domain>/specs/SPEC-0001-<slug>.md
docs/<domain>/ideas/IDEA-0001-<slug>.md
docs/<domain>/plans/PLAN-0001-<slug>/PLAN-0001-<slug>.md
docs/<domain>/plans/PLAN-0001-<slug>/IMPL-0001-01-<slug>.md
```

The script reads:

- IDs from frontmatter and filenames
- status from frontmatter
- titles from frontmatter or first heading
- todos from Markdown checkboxes

It writes generated views:

```text
docs/SPECS.md
docs/IDEAS.md
docs/DOCS-REGISTRY.md
docs/TODOS.md
docs/AREAS.md
docs/AUDITS.md
docs/ROADMAP-VIEW.md
docs/HEALTH.md
```

Those generated files should be treated as caches. If they disagree with the source docs, regenerate them instead of editing them by hand.

## Commands

Show the next ID:

```bash
scripts/docs-meta next spec
scripts/docs-meta next idea
scripts/docs-meta next plan
scripts/docs-meta next impl --plan PLAN-0001
scripts/docs-meta next adr
```

Create new docs:

```bash
scripts/docs-meta new spec "Shared Capture Workflow" --domain product --spec-type feature
scripts/docs-meta new idea "Repo Memory Timeline" --domain product
scripts/docs-meta new plan "Shared Capture Implementation" --domain product --spec SPEC-0001
scripts/docs-meta new impl "Persist Capture Drafts" --plan PLAN-0001
scripts/docs-meta new adr "Use Append-Only Worktree Journal"
```

Inspect or update status:

```bash
scripts/docs-meta status
scripts/docs-meta status PLAN-0001
scripts/docs-meta set-status PLAN-0001 in_progress
```

List todos:

```bash
scripts/docs-meta todos
scripts/docs-meta todos PLAN-0001
scripts/docs-meta todos --all
scripts/docs-meta todos --status ready
scripts/docs-meta todos --owner main-agent
scripts/docs-meta todos --agent 019dc454-98e1-7b22-9e79-56226fba0039
scripts/docs-meta todos --skill docs-writer
scripts/docs-meta todos --plan PLAN-0001
scripts/docs-meta todos TODO-0001 --all
scripts/docs-meta todos --json
scripts/docs-meta check-todos
scripts/docs-meta check-todos --strict
scripts/docs-meta next todo
```

### Structured todos

Use ordinary Markdown checkboxes for local, low-ceremony checklists. Use structured `TODO-*` items only when work needs durable coordination across sessions, agents, subagents, skills, commits, or reviews.

Structured todo syntax stays Markdown-readable:

```markdown
- [ ] TODO-0001 [ready] [skill:docs-writer] [plan:PLAN-0002] Define stable todo lifecycle states.
- [ ] TODO-0002 [blocked] [blocker:TODO-0001] [brief:IMPL-0002-01] Add todo validation checks.
- [x] TODO-0003 [done] [verification:tests/docs-meta-smoke.sh] Document AGENTS.md routing rules.
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
| Create | Add `TODO-#### [backlog]` or `[ready]` in the owning doc. Use `scripts/docs-meta next todo` for the next ID. |
| Claim | Change status to `[in_progress]` and add `owner:`, `agent:`, and `updated:`. |
| Block | Change status to `[blocked]` and add `blocker:`, `blocked_by:`, or `reason:`. |
| Send to review | Change status to `[review]` and refresh `updated:`. |
| Close | Check the box, set `[done]`, and add `verification:`, `evidence:`, or `reason:`. |
| Supersede | Set `[superseded]` and add `replacement:` or `reason:`. |
| Archive | Set `[archived]` and add `reason:`. |

IMPORTANT: edit the source doc, not `TODOS.md`. `TODOS.md` is generated from source checkboxes.

Source docs remain canonical. `TODOS.md` is a generated dashboard; regenerate it instead of editing it by hand.

Source-code TODO comments are intentionally not scanned by `docs-meta`. Keep inline TODO comments for local implementation notes that only matter near that code. If an inline TODO needs ownership, delegation, review, cross-session tracking, or commit/PR/session-log references, promote it to a structured Markdown `TODO-*` in the relevant plan, implementation brief, checklist, or state doc, and leave a short code comment pointing to that ID only when it helps the next reader.

When a commit, PR, issue, or session log is todo-backed, cite the `TODO-*` ID there too. Use source-doc metadata such as `issue:#123`, `pr:#456`, and `session:repo-health/session-logs/YYYY-MM-DD-session-title.md` when it helps future lookup, but do not make GitHub the only source of task truth.

`check-todos` validates duplicate IDs, lifecycle/checkbox contradictions, missing claim metadata for `in_progress`, missing freshness for `review`, missing blockers or reasons for `blocked`, missing closeout evidence for `done`, missing plan/brief references, and missing referenced `TODO-*` dependencies. `check-todos --strict` also warns about helpful routing/freshness metadata such as `skill` and `updated` on ready or blocked work.

Regenerate and check generated views:

```bash
scripts/docs-meta update
scripts/docs-meta check
```

`check` also validates frontmatter contracts for known doc types, type-specific statuses, ID/filename agreement, implementation-to-parent-plan ID agreement, and whether generated registry files are stale.

Inspect docs links:

```bash
scripts/docs-meta links
scripts/docs-meta links docs/README.md
scripts/docs-meta backlinks docs/README.md
scripts/docs-meta check-links
scripts/docs-meta orphans
scripts/docs-meta orphans --exclude 'repo-health/session-logs/*'
```

`links` parses standard Markdown links, Markdown image links, path-like autolinks, and Obsidian-style wikilinks. Standard Markdown links are the canonical format; wikilinks are reported for visibility but are not rewritten.

`check-links` exits nonzero when repo-local Markdown links point at missing files, folders without a `README.md` or `index.md`, or paths outside the repo. It does not validate external HTTP links.

`orphans` supports repeatable `--exclude` glob patterns. Individual docs can also opt out with `docs_meta_ignore_orphan: true` or `orphan_ok: true` frontmatter when low-link docs are intentional.

Normalize or move docs safely:

```bash
scripts/docs-meta normalize-links --style relative --dry-run
scripts/docs-meta normalize-links --style relative --write
scripts/docs-meta move docs/old.md docs/new.md --dry-run
scripts/docs-meta move docs/old.md docs/new.md --write
```

Mutating commands are dry-run-first. They preserve link labels and fragments, rewrite only structured Markdown hrefs, and report prose mentions separately for human review.

Show advisory docs-health warnings:

```bash
scripts/docs-meta health
scripts/docs-meta health --stale-days 30 --commit-threshold 20 --audit-days 45
scripts/docs-meta health --json
scripts/docs-meta health --write
```

`health` is intentionally softer than `check`. It flags docs that may be worth reviewing because they are old, still in an open status, missing a review commit, many commits behind `repo_state.last_reviewed_commit`, because the repo has no recent completed repo-health audit, or because link-health signals deserve review. It exits successfully even when warnings exist; treat the output as a review queue, not a CI failure. Running it also refreshes `docs/HEALTH.md`.

Show or write the plan roadmap view:

```bash
scripts/docs-meta roadmap
scripts/docs-meta roadmap --json
scripts/docs-meta roadmap --write
```

`roadmap` sorts `type: plan` docs by `sequence` frontmatter. `PLAN-*` stays stable identity; `sequence.roadmap`, `sequence.sort_key`, `sequence.after`, and `sequence.before` own execution order. Running it also refreshes `docs/ROADMAP-VIEW.md`.

Print and refresh any generated Markdown view:

```bash
scripts/docs-meta view specs
scripts/docs-meta view todos
scripts/docs-meta view audits
scripts/docs-meta view roadmap
scripts/docs-meta view health
```

Generated views include YAML frontmatter with `type: generated-view`, `status: generated`, and `updated_at`. The `updated_at` field changes whenever the view is regenerated.

Run the smoke test after changing `docs-meta` behavior:

```bash
tests/docs-meta-smoke.sh
```

## Naming Model

The default naming model is independent IDs plus explicit relationships:

```text
SPEC-0001
IDEA-0001
PLAN-0001
IMPL-0001-01
ADR-0001
```

Relationships belong in frontmatter:

```yaml
related_specs:
  - SPEC-0001
promoted_to:
  - SPEC-0001
parent_plan: PLAN-0001
sequence:
  roadmap: "3.5.1"
  sort_key: "003.005.001"
  lane: product
  after: [PLAN-0035]
related_issues:
  - "#123"
```

This avoids encoding a many-to-many relationship graph into filenames. An idea can be promoted to a spec, ADR, research note, or plan; a plan can relate to multiple specs; a spec can lead to multiple plans; and an implementation brief can remain visibly scoped to its parent plan.

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

Copy `scripts/docs-meta` into a repo that uses this docs workflow. Then:

1. Ensure idea, spec, plan, implementation brief, and ADR templates have `id`, `type`, `status`, `created_at`, `updated_at`, and relationship frontmatter.
2. Prefer `scripts/docs-meta new ...` for new ideas, specs, plans, implementation briefs, and ADRs.
3. Run `scripts/docs-meta update` after meaningful doc changes.
4. Run `scripts/docs-meta check` before committing docs workflow changes.
5. Run `scripts/docs-meta check-todos` when the repo uses structured `TODO-*` items for durable coordination.

For stricter repos, wire `scripts/docs-meta check`, `scripts/docs-meta check-links`, and `scripts/docs-meta check-todos` into CI or a pre-commit hook. Keep hooks as verification; do not hide surprising doc or todo rewrites inside an automatic commit step.

## Limits

`docs-meta` is intentionally small and conservative.

- It uses simple frontmatter parsing, not a full YAML parser.
- It does not decide what a spec or plan should say.
- It does not replace ADRs, session logs, GitHub issues, or PR descriptions.
- It does not make generated registries canonical.
- It does not validate external HTTP links.
- It does not rewrite prose mentions automatically.

The goal is not to document everything. The goal is to make the important metadata deterministic enough that future humans and agents can trust the map.
