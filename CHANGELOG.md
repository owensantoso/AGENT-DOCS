# Changelog

Adopter-facing AGENT-DOCS changes are recorded here. Internal planning notes,
session logs, and repo-private docs do not need entries unless they change how
another repository installs, runs, verifies, or reuses AGENT-DOCS.

## Unreleased

### For adopters

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

- Added `scripts/changelog-check` for local and CI changelog enforcement.
- Added smoke coverage for changelog-required, changelog-present, internal-only,
  and explicit-exemption cases.
- Made `scripts/changelog-check` compatible with clean trees on macOS Bash 3.2.
