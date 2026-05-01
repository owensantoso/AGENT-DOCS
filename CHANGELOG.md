# Changelog

Adopter-facing AGENT-DOCS changes are recorded here. Internal planning notes,
session logs, and repo-private docs do not need entries unless they change how
another repository installs, runs, verifies, or reuses AGENT-DOCS.

## Unreleased

### For adopters

- The installer now publishes `agent-docs` as the future command namespace while
  keeping `agent-docs-init` as the compatible init command.
- Explicit write installs now create `.agent-docs/manifest.json` with schema
  version 1, profile/source metadata, optional component records, conservative
  file ownership, and checksums for AGENT-DOCS-owned tooling.
- Added read-only `agent-docs doctor [target]` and `agent-docs upgrade
  --dry-run [target]` reports for manifest health, drift, safe additions,
  candidate tooling updates, generated-view refreshes, manual-review items,
  and refused shapes.
- Added `agent-docs upgrade --write --tooling-only [target]` for deterministic
  AGENT-DOCS-owned tooling updates, missing owned-file restores, executable-bit
  repairs, backups under `.agent-docs/backups/<timestamp>/`, and manifest-last
  updates. Bare `agent-docs upgrade` remains a read-only preview, and
  `--write` without `--tooling-only` is refused. Successful tooling-only writes
  return the post-write classification, so fully repaired targets exit `0`.
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
  doctor, dry-run upgrade, and tooling-only write mode.

### Tooling changes

- Added `agent-docs init ...` as a thin delegator to `agent-docs-init`.
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
- Added `scripts/changelog-check` for local and CI changelog enforcement.
- Added smoke coverage for changelog-required, changelog-present, internal-only,
  and explicit-exemption cases.
- Made `scripts/changelog-check` compatible with clean trees on macOS Bash 3.2.
