# Agent Upgrade Runbook For Existing Installs

Use this when a project already has older AGENT-DOCS or Agent Continuity files
and the human wants an agent to upgrade/check it safely.

Do not rerun `agent-continuity init --write` over an existing customized
project. The project docs are local truth after installation.

## Pasteable Agent Prompt

```text
You are in a project that may already have an older AGENT-DOCS / Agent
Continuity install.

Goal: update the local Agent Continuity command, inspect this project, and apply
only deterministic safe updates. Do not overwrite customized project Markdown.

First, update or install the command without running init:

curl -fsSL https://raw.githubusercontent.com/owensantoso/agent-continuity/main/install.sh | bash -s -- --no-run

Then run:

agent-continuity doctor .
agent-continuity upgrade --dry-run .

Interpret the result:

- If healthy/current: report that nothing else is required.
- If missing manifest / legacy / manual review: do not run init --write. If the
  current files look like the intended local truth, run:
  agent-continuity baseline --dry-run . --profile standard --docs-meta yes
  Review the dry-run output. Only then run the same command with --write if the
  profile/options match the installed shape.
- If only AGENT-DOCS-owned tooling is missing or outdated, run:
  agent-continuity upgrade --write --tooling-only .
- If generated views are stale and manifest-tracked, consider:
  agent-continuity upgrade --write --tooling-only --generated-views .
- If project-owned Markdown is changed, summarize it for human review. Do not
  overwrite it.
- If refused / unknown / incompatible shapes are present, stop and explain the
  exact blocker.

Before finishing, run the target repo's documented verification commands if
available, then run:

git diff --check

Report every command run, what changed, and whether any files still need manual
review.
```

## Why This Is The Safe Path

`agent-continuity init --write` is for first installs. Existing projects often
customize `AGENTS.md`, `docs/CURRENT_STATE.md`, plans, ADRs, session logs, and
other Markdown. Those files should not be replaced by a generic scaffold.

The safe upgrade path separates three cases:

| Case | Tool Behavior |
|---|---|
| Manifest-backed install | `doctor` and `upgrade --dry-run` can compare owned tooling against the manifest. |
| Older install without manifest | `baseline --dry-run` previews whether a conservative manifest can be created. |
| Customized project Markdown | Report-only. The tool does not overwrite local project truth. |

Compatibility commands such as `agent-docs` and `agent-docs-init` still work,
but new instructions should use `agent-continuity`.

## Platform Note

Agent Continuity is currently supported on macOS and Linux shells with Bash,
Git, Python 3.10+, and symlink support. Native Windows is not first-class yet;
use WSL for the closest supported Windows path.
