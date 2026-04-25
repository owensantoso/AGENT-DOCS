# Docs Meta

`docs-meta` is a deterministic metadata helper for agent-friendly docs.

It exists to keep repository memory queryable without asking a human or AI agent to manually maintain counters, status tables, generated registries, or todo dashboards. The important rule is simple: Markdown files, filenames, and frontmatter are the source of truth. Generated files are views.

## What It Solves

Agent-driven projects tend to accumulate small bits of comprehension debt:

- the next `SPEC-*`, `PLAN-*`, or `ADR-*` number is guessed instead of derived
- plan and implementation statuses drift from reality
- generated registries are hand-edited and quietly become stale
- todos are scattered across specs, plans, and implementation briefs
- a future session cannot easily reconstruct what docs exist or where work stands

`docs-meta` turns those into mechanical operations. It scans the repo, derives state, and either writes reproducible generated files or fails when they are stale.

## Source Of Truth

Canonical state lives in docs files:

```text
docs/<domain>/specs/SPEC-0001-<slug>.md
docs/<domain>/plans/PLAN-0001-<slug>/plan.md
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
docs/DOCS-REGISTRY.md
docs/TODOS.md
docs/AREAS.md
```

Those generated files should be treated as caches. If they disagree with the source docs, regenerate them instead of editing them by hand.

## Commands

Show the next ID:

```bash
scripts/docs-meta next spec
scripts/docs-meta next plan
scripts/docs-meta next impl --plan PLAN-0001
scripts/docs-meta next adr
```

Create new docs:

```bash
scripts/docs-meta new spec "Shared Capture Workflow" --domain product --spec-type feature
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
```

Regenerate and check generated views:

```bash
scripts/docs-meta update
scripts/docs-meta check
```

`check` also validates frontmatter contracts for known doc types, type-specific statuses, ID/filename agreement, implementation-to-parent-plan ID agreement, and whether generated registry files are stale.

Run the smoke test after changing `docs-meta` behavior:

```bash
tests/docs-meta-smoke.sh
```

## Naming Model

The default naming model is independent IDs plus explicit relationships:

```text
SPEC-0001
PLAN-0001
IMPL-0001-01
ADR-0001
```

Relationships belong in frontmatter:

```yaml
related_specs:
  - SPEC-0001
parent_plan: PLAN-0001
related_issues:
  - "#123"
```

This avoids encoding a many-to-many relationship graph into filenames. A plan can relate to multiple specs, a spec can lead to multiple plans, and an implementation brief can remain visibly scoped to its parent plan.

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

1. Ensure spec, plan, implementation brief, and ADR templates have `id`, `type`, `status`, `created_at`, `updated_at`, and relationship frontmatter.
2. Prefer `scripts/docs-meta new ...` for new specs, plans, implementation briefs, and ADRs.
3. Run `scripts/docs-meta update` after meaningful doc changes.
4. Run `scripts/docs-meta check` before committing docs workflow changes.

For stricter repos, wire `scripts/docs-meta check` into CI or a pre-commit hook. Keep the hook as verification; do not hide surprising doc rewrites inside an automatic commit step.

## Limits

`docs-meta` is intentionally small and conservative.

- It uses simple frontmatter parsing, not a full YAML parser.
- It does not decide what a spec or plan should say.
- It does not replace ADRs, session logs, GitHub issues, or PR descriptions.
- It does not make generated registries canonical.

The goal is not to document everything. The goal is to make the important metadata deterministic enough that future humans and agents can trust the map.
