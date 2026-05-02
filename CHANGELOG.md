# Changelog

Adopter-facing AGENT-DOCS changes are recorded here. Internal planning notes,
session logs, and repo-private docs do not need entries unless they change how
another repository installs, runs, verifies, or reuses AGENT-DOCS.

## Unreleased

### For adopters

- The public GitHub repository is now `owensantoso/agent-continuity`; install
  URLs and the installer default source URL now use that repository path.
- Added a dedicated package-manager distribution follow-up plan for Homebrew or
  a similar install channel after the GitHub install path settles.
- Added upgrade guidance for existing projects with older AGENT-DOCS installs.
- Added an agent-facing upgrade runbook and clarified that native Windows is
  not first-class yet; WSL is the closest supported Windows path.
- The primary installed command is now `agent-continuity`. Existing
  `agent-docs` and `agent-docs-init` commands remain compatibility commands.
- Public install profiles are now `core`, `standard`, `expanded`, and
  `complete`, with `standard` as the recommended default. The old `tiny`,
  `small`, `growing`, and `full` names remain compatibility aliases and new
  manifests record canonical profile keys.
- The installer still publishes `agent-docs` and `agent-docs-init` as
  compatibility commands for existing adopters.
- Explicit write installs now create `.agent-docs/manifest.json` with schema
  version 1, profile/source metadata, optional component records, conservative
  file ownership, and checksums for AGENT-DOCS-owned tooling.
- Added read-only `agent-continuity doctor [target]` and `agent-continuity upgrade
  --dry-run [target]` reports for manifest health, drift, safe additions,
  candidate tooling updates, generated-view refreshes, manual-review items,
  and refused shapes.
- Added `agent-continuity upgrade --write --tooling-only [target]` for deterministic
  AGENT-DOCS-owned tooling updates, missing owned-file restores, executable-bit
  repairs, backups under `.agent-docs/backups/<timestamp>/`, and manifest-last
  updates. Bare `agent-continuity upgrade` remains a read-only preview, and
  `--write` without `--tooling-only` is refused. Successful tooling-only writes
  return the post-write classification, so fully repaired targets exit `0`.
- Added explicit generated-view upgrade writes with `agent-continuity upgrade --write
  --tooling-only --generated-views [target]`. The first supported generator is
  `scripts/docs-meta update`, and only manifest-tracked generated views are
  refreshed.
- Fresh installs that include `docs-meta` now generate and register recognized
  docs-meta generated views in `.agent-docs/manifest.json`. Legacy baseline
  installs can opt in with `agent-continuity baseline --generated-views`, which
  records existing recognized generated views without running generators.
- Added `agent-continuity baseline --dry-run|--write [target] --profile <profile>
  --docs-meta auto|yes|no` so legacy installs without `.agent-docs/manifest.json`
  can preview and create a conservative manifest for matching AGENT-DOCS-owned
  tooling while keeping project Markdown unmodified and unchecksummed.
- Public-readiness work now favors preview-first install and init flows so first
  runs show intended changes before writing files.
- Supported platform and prerequisite guidance is clearer for macOS and Linux
  users running Bash, Git, and Python 3.10+.
- Added contribution, security, issue, and pull request guidance for public
  collaboration.
- Added release/archive guidance that prefers tracked source archives and avoids
  local caches, ignored generated artifacts, and secrets.

### For future agents

- Release checks now include a changelog gate for reusable AGENT-DOCS surfaces.
  Add a `CHANGELOG.md` entry when installer, scaffold, skill, reusable guide, or
  public command behavior changes.
- Use `Change-Record: not-needed` in commit or PR text only when an
  adopter-facing path changed without changing adopter behavior.
- SPEC-0003 follow-up implementation is tracked in PLAN-0005 for manifest,
  doctor, dry-run upgrade, and tooling-only write mode, and PLAN-0006 for legacy
  baseline manifests and opt-in generated-view writes.

### Tooling changes

- Added `agent-continuity init ...` and `agent-docs init ...` as thin
  delegators to `agent-docs-init`.
- Added exit-code semantics for doctor/dry-run reports: `0` healthy/current,
  `1` warnings or actionable drift, and `2` invalid usage, refused, unknown, or
  incompatible shapes.
- Added manifest assertions to init/install smoke coverage and Python compile
  coverage for the new command entry point.
- Added doctor and upgrade dry-run smoke coverage to `scripts/release-check`.
- Added tooling-only upgrade write-mode smoke coverage for preview defaulting,
  write refusal, missing owned-file restore, manifest-clean tooling update,
  executable-bit repair, local drift refusal, symlink refusal, backups, and
  project-owned Markdown non-mutation.
- Hardened tooling-only write mode to refuse unsafe backup paths, non-directory
  parent path conflicts, and exact-mode drift before writing.
- Added smoke coverage for legacy manifest baseline preview/write behavior,
  existing-manifest refusal, empty-target refusal, missing/drifted/wrong-mode
  owned tooling refusal, symlink and hardlink refusal, and project-owned Markdown
  non-mutation.
- Added generated-view upgrade write smoke coverage for dry-run/no-write
  preservation, explicit opt-in regeneration, missing view recreation,
  unsupported generator refusal, malformed record refusal, unsafe path refusal,
  hand-edited drift refusal, generator failure, backups, audits, and manifest
  checksum updates.
- Added generated-view registration smoke coverage for fresh docs-meta installs
  and baseline `--generated-views`.
- Added `scripts/changelog-check` for local and CI changelog enforcement.
- Added smoke coverage for changelog-required, changelog-present, internal-only,
  and explicit-exemption cases.
- Made `scripts/changelog-check` compatible with clean trees on macOS Bash 3.2.
