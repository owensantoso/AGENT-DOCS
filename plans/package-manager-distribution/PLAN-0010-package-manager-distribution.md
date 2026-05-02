---
type: plan
id: PLAN-0010
title: Package Manager Distribution
domain: repo-health
status: draft
created_at: "2026-05-02 20:40:37 JST +0900"
updated_at: "2026-05-02 20:40:37 JST +0900"
planned_execution_start:
planned_execution_end:
actual_execution_start:
actual_execution_end:
owner: codex
sequence:
  roadmap:
  sort_key:
  lane: repo-health
  after:
    - PLAN-0009
  before: []
areas:
  - repo-health
related_specs: []
related_concepts: []
related_adrs: []
related_sessions:
  - session-logs/2026-05-02-plan-0010-package-manager-and-upgrade-guidance.md
related_issues: []
related_prs: []
repo_state:
  based_on_commit: 99e87936bef53e5a6d833b968b16383b0f56412f
  last_reviewed_commit: 99e87936bef53e5a6d833b968b16383b0f56412f
---

# PLAN-0010 - Package Manager Distribution

## Goal

Make Agent Continuity installable through a package-manager-style command after
the GitHub install path has settled.

Homebrew is the likely first channel because the current audience is macOS-heavy
and the tool is a small shell/Python command bundle. Other channels can follow
after the command and manifest model prove stable.

## Candidate User Experience

```bash
brew tap owensantoso/agent-continuity
brew install agent-continuity
agent-continuity init --profile standard --dry-run
```

The exact tap and formula names are not decided by this plan. The desired
outcome is a simple, repeatable install that does not require users to curl a
script directly.

## Scope

- Decide whether to publish through a tap, a formula in an existing tap, or
  another package channel.
- Add tagged release guidance if the package channel needs stable archives.
- Package the primary `agent-continuity` command.
- Preserve `agent-docs` and `agent-docs-init` compatibility commands if the
  package channel supports installing aliases cleanly.
- Add package-install smoke checks that verify command availability and init
  dry-run behavior.
- Update README, INSTALL, CONTRIBUTING, and release guidance.

## Non-Goals

- Do not remove the curl installer.
- Do not remove compatibility command names.
- Do not rename `.agent-docs/` or `AGENT_DOCS_*` environment variables.
- Do not publish before the release/tag story is explicit enough to reproduce.

## Open Questions

- Should the first distribution be a Homebrew tap under `owensantoso`, or should
  the repo only document a local formula until tagged releases exist?
- Should releases be tagged before the first package-manager formula?
- Should package installs create symlinks for all three commands or only the
  primary `agent-continuity` command plus compatibility aliases when feasible?
- Should package-manager install update behavior delegate to Homebrew entirely,
  or should `agent-continuity upgrade` remain only for target-repo scaffold
  assets?

## Validation Sketch

```bash
brew install ./Formula/agent-continuity.rb
agent-continuity --help
agent-continuity init --profile standard --dry-run /tmp/agent-continuity-smoke
scripts/release-check
```

## Completion Criteria

- [ ] Package-manager install path is documented.
- [ ] Package install can run `agent-continuity --help`.
- [ ] Package install can preview a standard init.
- [ ] Release/archive expectations are documented.
- [ ] Existing curl installer remains documented and working.
