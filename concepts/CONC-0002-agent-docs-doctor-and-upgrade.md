---
type: concept
id: CONC-0002
title: Agent Docs Doctor And Upgrade
domain: repo-health
status: draft
concept_type: tooling
created_at: "2026-04-27 22:19:21 JST +0900"
updated_at: "2026-05-02 02:40:23 JST +0900"
owner:
source:
  type: conversation
  link:
  notes: Request for an upstream design record for a future agent-docs upgrade/update command.
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
related_specs:
  - SPEC-0003
related_plans:
  - PLAN-0005
related_briefs: []
related_adrs: []
related_ideas: []
related_questions: []
related_sessions: []
promoted_to:
  - SPEC-0003
supersedes: []
superseded_by: []
repo_state:
  based_on_commit: d8202def7a3fc561a48fa9267d82122caf51150d
  last_reviewed_commit: d8202def7a3fc561a48fa9267d82122caf51150d
---

# CONC-0002 - Agent Docs Doctor And Upgrade

## Purpose

Capture a safe future command family for checking and updating an installed AGENT-DOCS workflow inside a target repo.

This is a concept note, not implementation approval. The design center is conservative: the tool should help a target repo see drift, understand available upstream improvements, and apply only AGENT-DOCS-owned updates without overwriting project-owned docs.

## Command Shape

Start with a read-only MVP:

```bash
agent-docs doctor
```

Later commands can build on the same detection model:

```bash
agent-docs diff
agent-docs upgrade --dry-run
agent-docs upgrade --write
```

`doctor` should answer what is installed, what is missing, and where the target repo differs from the current upstream scaffold or tooling. `diff` should show the candidate changes. `upgrade` should apply only changes that fall inside the safe update scope.

Before any write command exists, `doctor` should also answer whether an update appears safe to do programmatically. If safety is unclear, it should say why and stop at a manual-review recommendation.

## Read-Only Doctor MVP

The first useful version should not write files.

It should inspect a target repo and report:

- whether AGENT-DOCS appears to be installed
- installed profile or best-effort detected shape
- installed manifest or stamp, when present
- missing required scripts or tests for the detected profile
- stale generated views that should be regenerated
- missing templates that can be safely added
- project-owned docs that differ from upstream examples and must not be overwritten
- exact commands a human or agent can run next

The output should be boring and explicit. A target repo should be able to paste the report into a session log or issue without losing the important facts.

## Manifest And Stamp

A future installer or upgrade command should leave a small machine-readable record in the target repo.

Possible shapes:

```text
.agent-docs/manifest.json
.agent-docs/stamp.json
```

The record can include:

- AGENT-DOCS source repository and ref
- installed command version or commit
- selected profile
- installed optional components, such as `docs-meta`
- files installed as AGENT-DOCS-owned assets
- checksums for AGENT-DOCS-owned assets only
- timestamp of the install or last upgrade

The stamp should help detect drift. It should not make AGENT-DOCS the owner of product docs, architecture docs, plans, specs, ADRs, or any other target-repo knowledge.

## Ownership Rules

Never overwrite project-owned docs.

Project-owned docs include:

- `AGENTS.md`
- `docs/orientation/CURRENT_STATE.md`
- architecture, product, planning, decision, research, and session-log docs
- any file that has been edited away from a generated starter template and now carries repo-specific truth

AGENT-DOCS can suggest updates for those files, but the default behavior should be report-only. If a future command offers patches for project-owned docs, they should be shown as reviewable diffs and require explicit user approval outside the normal safe update path.

## Safe Update Scope

The safe update scope is limited to files AGENT-DOCS can clearly own or regenerate:

- `scripts/docs-meta`
- `tests/docs-meta-smoke.sh`
- other AGENT-DOCS-installed scripts and smoke tests
- generated docs views, when the target repo already treats them as generated
- missing template files that do not conflict with existing target files
- missing optional directories required by an enabled profile or component
- internal manifest or stamp files

Even inside this scope, write mode should preview changes first and refuse ambiguous overwrites.

## Drift And Diff Model

The target repo can be checked against upstream by combining:

- the installed manifest or stamp
- checksums for AGENT-DOCS-owned assets
- the current upstream scaffold and scripts
- target-repo generated-view freshness checks
- existing `docs-meta` validation, when installed

`agent-docs diff` should show what would change by category:

- update AGENT-DOCS-owned tooling
- add missing safe templates
- regenerate stale generated views
- report project-owned docs that need human review
- report unsupported or unknown files

The key behavior is visibility before mutation. A target repo should be able to see exactly what changed, why it is considered safe, and which files require manual review.

## Compatibility And Migrations

This may eventually become a small versioning system, but the first useful version should stay modest.

`agent-docs doctor` can classify update compatibility:

- `safe`: installed assets are recognized, checksums match or diffs are only in AGENT-DOCS-owned files, and generated views can be refreshed.
- `manual-review`: links, folders, templates, or project-owned docs changed enough that an agent or human should inspect the diff.
- `incompatible`: the installed shape is too old, unknown, or locally rewritten for the current upgrader to reason about safely.

A simple migration model could be a list of named upgrade notes between AGENT-DOCS versions or commits, for example:

```text
2026-04-27-add-doc-families
2026-04-27-health-banner-owner
```

Each note would describe:

- what changed upstream
- which files are safe to update automatically
- which links or paths may need review
- which validation commands prove the target repo is healthy afterward

This does not need to be a full migration framework at first. The important part is that the tool refuses to pretend an update is safe when compatibility is unknown.

## Non-Goals

- Do not make `upgrade` a repo-wide formatter.
- Do not merge upstream starter docs into project-owned docs automatically.
- Do not delete target-repo docs because upstream no longer ships a matching template.
- Do not make the manifest the source of truth for project knowledge.
- Do not require every repo to install the full scaffold before it can be checked.
- Do not build a complex package-manager or database-migration system before simple compatibility reports prove useful.

## Promotion Paths

- Promote to a spec when the first `agent-docs doctor` acceptance criteria and report format are ready.
- Promote to a plan when implementation sequencing across installer, scripts, tests, and docs is ready.
- Promote to an ADR only if AGENT-DOCS commits to a durable ownership boundary or manifest format that consuming repos should rely on.
- Split compatibility and migration notes into their own spec if real target repos start needing multi-step upgrades rather than direct tooling refreshes.

## Related Docs

- [SPEC-0003 - AGENT-DOCS Versioning And Safe Upgrade](../plans/agent-docs-versioning-and-upgrade/SPEC-0003-agent-docs-versioning-and-upgrade.md)
- [PLAN-0005 - Agent Docs Doctor Manifest Upgrade](../plans/agent-docs-doctor-manifest-upgrade/PLAN-0005-agent-docs-doctor-manifest-upgrade.md)
- [Docs Meta README](../scripts/README.md)
- [AGENT-DOCS Install Guide](../INSTALL.md)
- [CONC-0001 - Read-Only SQLite Docs Index](CONC-0001-read-only-sqlite-docs-index.md)
