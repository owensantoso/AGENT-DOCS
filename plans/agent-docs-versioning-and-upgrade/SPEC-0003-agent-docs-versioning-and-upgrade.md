---
type: spec
id: SPEC-0003
title: AGENT-DOCS Versioning And Safe Upgrade
spec_type: repo-health
domain: repo-health
status: draft
created_at: "2026-05-02 01:35:10 JST +0900"
updated_at: "2026-05-02 04:56:46 JST +0900"
owner: codex
source:
  type: conversation
  link:
  notes: Human asked for a safe middle-ground versioning, changelog, doctor, and upgrade workflow for AGENT-DOCS without overwriting customized target-repo Markdown.
areas:
  - agent-docs-init
  - docs-meta
  - repo-health
related_plans:
  - PLAN-0005
related_briefs: []
related_adrs: []
related_ideas: []
related_concepts:
  - CONC-0002
related_sessions:
  - session-logs/2026-05-02-plan-0004-public-readiness.md
  - session-logs/2026-05-02-plan-0005-post-review-upgrade-semantics.md
supersedes: []
superseded_by: []
repo_state:
  based_on_commit: 7b540a5b90f7f318f80d5e0e2dc66ae90afea269
  last_reviewed_commit: 7b540a5b90f7f318f80d5e0e2dc66ae90afea269
---

# SPEC-0003 - AGENT-DOCS Versioning And Safe Upgrade

## Problem

AGENT-DOCS is copied or installed into target repositories, then those target
repositories evolve. Some installed files remain reusable tooling, while other
Markdown files become project-owned truth. A future update workflow must help
target repos learn about upstream improvements without casually overwriting
customized docs.

Commit messages alone are not enough for this job. They preserve exact upstream
development history, but they do not give downstream adopters a concise answer
to:

- what changed in AGENT-DOCS that matters to installed repos;
- whether they need to copy new guidance, rerun tooling, or update CI;
- which changes are safe to apply automatically;
- which changes require human or agent review because local Markdown may have
  become project truth.

## Goals

- Provide a human- and agent-readable upgrade memory for adopter-facing
  AGENT-DOCS changes.
- Let target repos inspect their installed AGENT-DOCS shape and drift without
  writing files.
- Allow narrow, safe automatic updates for AGENT-DOCS-owned tooling and generated
  artifacts.
- Keep customized project docs protected by default.
- Make CI able to enforce that adopter-facing AGENT-DOCS changes are documented.
- Preserve a simple workflow that does not turn every small commit into release
  ceremony.

## Non-Goals

- Do not build a full package manager for Markdown docs.
- Do not auto-merge upstream scaffold text into project-owned target-repo docs.
- Do not require one changelog file per changed file.
- Do not require every internal AGENT-DOCS commit to have a release note.
- Do not make `.agent-docs/manifest.json` the source of truth for target-repo
  product, architecture, or planning knowledge.
- Do not make upgrades destructive, surprising, or dependent on `--force`.

## Requirements

### Changelog

AGENT-DOCS should have a human-readable `CHANGELOG.md` or equivalent release
notes file.

The changelog should record adopter-facing changes, not every internal commit.
Recommended sections:

- `For adopters`
- `For future agents`
- `Tooling changes`
- `Migration notes`
- `Verification`

The changelog may start with dated entries instead of strict semantic versions.
Formal versions can be added later if AGENT-DOCS begins publishing tagged
releases.

### Changelog Enforcement

CI should require a changelog update when adopter-facing surfaces change.

Initial versioned surfaces:

- `scaffold/**`
- `skills/**`
- `scripts/docs-meta`
- `scripts/agent-docs-init`
- `install.sh`
- `INSTALL.md`
- `README.md`
- reusable guides that affect installation, adoption, verification, or agent
  workflow

CI should allow an explicit exemption, such as a commit or PR marker:

```text
Change-Record: not-needed
```

Exemptions are appropriate for typo-only edits, internal planning docs, session
logs, generated-output refreshes, or repo-private notes that do not change
adopter behavior.

### Installed Manifest

Future install or upgrade commands should write a small manifest in target repos:

```text
.agent-docs/manifest.json
```

The manifest should include:

- schema version;
- AGENT-DOCS source repository and ref or commit;
- selected profile;
- installed optional components, such as `docs-meta`;
- installed file records for AGENT-DOCS-owned files;
- checksums for AGENT-DOCS-owned files only;
- generated-view records when applicable;
- install or last-upgrade timestamp.

The manifest should help detect drift. It must not imply AGENT-DOCS owns
project-specific docs forever.

### Ownership Classification

Upgrade tooling should classify target files before suggesting or applying
changes.

Required categories:

- `agent-docs-owned`: tooling, smoke tests, copied skills, or other assets whose
  checksum still matches the manifest base.
- `generated`: files with a generated-view frontmatter/header and a known
  generator command.
- `auto-add-safe`: missing AGENT-DOCS-owned files or templates where no target
  path conflict exists.
- `project-owned`: local truth docs such as `AGENTS.md`, `CURRENT_STATE.md`,
  architecture docs, product docs, specs, plans, ADRs, session logs, and any
  starter file that has clearly been customized.
- `unknown`: files or install shapes the tool cannot classify safely.

Only `agent-docs-owned`, `generated`, and `auto-add-safe` files are candidates
for automatic writes.

### Doctor Command

The first command should be read-only:

```bash
agent-docs doctor
```

It should report:

- whether AGENT-DOCS appears to be installed;
- detected profile and installed optional components;
- installed manifest details, when present;
- missing or stale AGENT-DOCS-owned tooling;
- stale generated views;
- project-owned docs that differ from upstream templates and must not be
  overwritten;
- unknown or incompatible install shapes;
- exact recommended next commands.

`doctor` should make update safety visible before any write command exists.

### Upgrade Dry Run

After `doctor` is useful, AGENT-DOCS may add:

```bash
agent-docs upgrade --dry-run
```

Bare `agent-docs upgrade` should behave as a read-only preview/report, equivalent
to dry-run. The default upgrade path should gather evidence and explain upgrade
work; it must not mutate files.

Dry-run output should be categorized:

- candidate tooling updates;
- safe automatic additions;
- generated view refreshes;
- report-only manual review items;
- refused or incompatible items.

Dry-run should show file paths, reasons, installed source metadata, current
AGENT-DOCS source metadata when available, and adopter-facing changelog or
migration notes for the relevant source range when those notes can be found. It
should not write files.

Project-owned docs should get an adaptive-review explanation, not a mechanical
merge promise. For example, if local `AGENTS.md` differs from the installed base
and upstream scaffold guidance also changed, the report should say which
upstream guidance changed and ask a human or agent to adapt relevant concepts
while preserving local repo-specific instructions. It should not claim that the
file can be deterministically upgraded.

### Safe Write Mode

After dry-run behavior is trusted, AGENT-DOCS may add a narrow write mode:

```bash
agent-docs upgrade --write --tooling-only
```

Write mode may:

- update `agent-docs-owned` tooling when the current checksum matches the
  manifest base;
- add missing non-conflicting AGENT-DOCS-owned files;
- regenerate generated views through the target repo's installed generator;
- update `.agent-docs/manifest.json`.

Write mode must not:

- overwrite project-owned docs;
- delete target-repo docs because upstream no longer ships a template;
- use broad `--force` semantics;
- write through symlinked target paths;
- write outside the target repo root;
- pretend unknown legacy installs are safe.

Normal write mode should be limited to deterministic work. Before any write, the
tool should produce or reuse a write plan, verify current checksums and file
modes still match the manifest, create backups for touched files, write the
manifest last, and refuse the entire operation for incompatible manifest shapes,
symlinked paths, outside-root paths, unknown ownership, unsupported optional
components, or local drift in AGENT-DOCS-owned files.

Backups should be structured so a future rollback command can exist, even if
rollback is not implemented in the first write slice.

### Project-Owned Replacement Escape Hatch

Replacing project-owned Markdown is not part of normal upgrade behavior. If
AGENT-DOCS ever supports it, it should be a separate, intentionally scary
recovery/reset command rather than `upgrade --force`.

Recommended future shape:

```bash
agent-docs replace-project-docs --dry-run /path/to/project --paths AGENTS.md
agent-docs replace-project-docs --write /path/to/project \
  --paths AGENTS.md \
  --backup-dir .agent-docs/backups/<timestamp> \
  --i-understand-this-replaces-project-owned-docs \
  --confirm-replace-project-owned-docs "REPLACE PROJECT-OWNED DOCS"
```

That future command should require exact paths, a prior dry-run or frozen replace
plan for non-interactive use, mandatory backups, checksum revalidation at write
time, refusal of broad roots such as `.` or `docs/` by default, refusal of
symlinks and outside-root paths, and an audit record. It should remain hidden
from the normal quick-start workflow.

### Three-Way Update Rule

For AGENT-DOCS-owned text files, the update model should be conservative:

- If `current == installed_base`, replace with new upstream.
- If `current != installed_base` and `upstream == installed_base`, report local
  drift only.
- If both current and upstream changed, show a reviewable diff or merge preview
  and do not auto-write by default.

Project-owned Markdown should remain report-only even when a three-way merge
looks possible.

### Schema And Compatibility Changes

AGENT-DOCS cannot guarantee that every future docs schema, frontmatter, path, or
parser change can be retroactively applied to existing project-owned docs. The
upgrade workflow should distinguish deterministic detection from deterministic
repair.

Usually deterministic:

- updating manifest-clean AGENT-DOCS-owned tooling;
- adding missing non-conflicting AGENT-DOCS-owned files;
- regenerating manifest-tracked generated views through known generators;
- adding new generated views where the component/profile owns them.

Usually manual/adaptive:

- renaming frontmatter keys in source docs;
- adding required fields whose values are project-specific, such as `areas`;
- moving or renaming project-owned docs and repairing local links;
- changing status vocabularies, TODO syntax, doc-type names, or parser
  strictness;
- adopting new `AGENTS.md` or `CURRENT_STATE.md` guidance into customized local
  docs;
- changing install profile meanings after a target repo has already adopted a
  profile.

For these manual/adaptive cases, upgrade reports should include examples,
affected paths or counts, relevant changelog notes, and suggested agent review
prompts. They should not auto-rewrite source-of-truth Markdown.

### Legacy Installs

Existing target repos may not have a manifest. The first `doctor` version should
infer the install shape where practical, but classify writes as manual-review
until a baseline manifest is intentionally created.

## Desired User Experience

A target repo should be able to run:

```bash
agent-docs doctor
```

and get a boring, pasteable report:

- installed profile;
- upstream commit checked;
- candidate tooling updates available;
- generated views stale;
- project-owned docs needing review;
- migration notes to read;
- exact commands to run next.

If the target repo chooses to run:

```bash
agent-docs upgrade --dry-run
```

it should see exactly what would change and why each change is safe or manual.

If it runs:

```bash
agent-docs upgrade --write --tooling-only
```

only the boring safe part should happen.

## Open Questions

- Should release identifiers begin as dates, semantic versions, or upstream
  commit ranges?
- Should the changelog live at `CHANGELOG.md`, `version/CHANGELOG.md`, or another
  path?
- Should `agent-docs doctor` be part of `agent-docs-init`, a new `agent-docs`
  command, or a separate script?
- How should the first manifest be created for existing repos that were installed
  before manifests existed?
- Should CI enforce changelog updates at commit level, pull-request level, or
  both?
- What exact exemption marker should CI accept for adopter-facing path changes
  that do not need a changelog entry?

## Acceptance Criteria

- A changelog convention exists and distinguishes adopter-facing changes from
  internal commit history.
- CI can detect adopter-facing surface changes and require either a changelog
  update or explicit exemption.
- Install or baseline tooling can write a manifest for AGENT-DOCS-owned files.
- `agent-docs doctor` can classify an installed target repo without writing
  files.
- Upgrade dry-run can show safe, manual-review, and refused changes by category.
- Tooling-only write mode updates only manifest-recognized AGENT-DOCS-owned files,
  generated views, and non-conflicting additions.
- Project-owned Markdown is never overwritten by default.

## Promotion Notes

- `CONC-0002` captured the original doctor/upgrade direction. This spec narrows
  the requirements around changelog, manifest, CI enforcement, and safe update
  boundaries.
- [PLAN-0005 - Agent Docs Doctor Manifest Upgrade](../agent-docs-doctor-manifest-upgrade/PLAN-0005-agent-docs-doctor-manifest-upgrade.md)
  sequences manifest, read-only doctor, dry-run upgrade, and tooling-only write
  mode after PLAN-0004 public-readiness hardening.
