# Install AGENT-DOCS In Another Repo

Use this when you want a fresh human or agent on another computer to install this docs workflow into a target repository.

The goal is not to copy every example. The goal is to give the target repo a clear agent read order, current-state docs, planning docs, session logs, ADRs, and optional deterministic metadata tooling.

## Fast Answer

1. Put this `AGENT-DOCS` repo somewhere the target repo can read.
2. Open the target repo.
3. Copy the minimum scaffold files listed below.
4. Replace placeholders with target-repo-specific names, paths, commands, and facts.
5. Run the verification commands.
6. Tell future agents to start at the target repo's root `AGENTS.md`.

Do not copy the whole `scaffold/` folder into a target repo root. It contains its own `README.md` and examples that should be placed deliberately.

## Minimum Install

From the target repo root, set `AGENT_DOCS` to the path of this repo:

```bash
AGENT_DOCS=/path/to/AGENT-DOCS
```

Then copy the minimum useful docs shape:

```bash
cp "$AGENT_DOCS/scaffold/AGENTS.md" ./AGENTS.md
mkdir -p docs
rsync -av "$AGENT_DOCS/scaffold/docs/" ./docs/
```

If the target repo already has `AGENTS.md` or `docs/`, merge carefully instead of overwriting. Keep existing product, architecture, and operations docs unless you intentionally replace them.

After copying, edit at least these files before asking another agent to use the repo:

- `AGENTS.md`
- `docs/README.md`
- `docs/orientation/CURRENT_STATE.md`
- `docs/orientation/ONBOARDING.md`
- `docs/orientation/ROADMAP.md`
- `docs/orientation/ARCHITECTURE.md`
- `docs/repo-health/codebase-map.md`
- `docs/repo-health/testing-guide.md`

Remove example files that do not apply, or keep them only if they are clearly marked as examples.

## Optional Metadata CLI

Install `docs-meta` when the target repo should mechanically manage IDs, generated registries, todos, docs links, safe doc moves, roadmap views, and docs health checks.

```bash
mkdir -p scripts tests
cp "$AGENT_DOCS/scripts/docs-meta" ./scripts/docs-meta
cp "$AGENT_DOCS/tests/docs-meta-smoke.sh" ./tests/docs-meta-smoke.sh
chmod +x ./scripts/docs-meta ./tests/docs-meta-smoke.sh
```

Recommended first run in the target repo:

```bash
scripts/docs-meta update
scripts/docs-meta check
scripts/docs-meta check-links
```

If the target repo already has a `scripts/README.md`, do not overwrite it. Link to this repo's `scripts/README.md` from the target repo's docs, or copy the relevant command reference into a target-specific tools doc.

## Optional Agent Instruction Templates

The reusable instruction templates live here:

```text
scaffold/agent-instructions/
  global-AGENTS.md
  surface-AGENTS.md
```

Use `global-AGENTS.md` as personal or organization-level Codex guidance. Use `surface-AGENTS.md` for a specific app, package, service, or docs area inside the target repo.

For example:

```bash
mkdir -p docs/repo-health/agent-instructions
cp "$AGENT_DOCS/scaffold/agent-instructions/"*.md ./docs/repo-health/agent-instructions/
```

Then adapt the placeholders before relying on them.

## What To Keep Or Delete

Keep:

- `AGENTS.md` as the first agent entry point
- `docs/README.md` as the docs map
- `docs/orientation/CURRENT_STATE.md` as the short truth page
- `docs/orientation/ONBOARDING.md` for the non-code walkthrough
- `docs/orientation/ROADMAP.md` for sequence and rationale
- `docs/orientation/ARCHITECTURE.md` for system boundaries
- `docs/repo-health/session-logs/` for timestamped receipts
- `docs/decisions/adr/` for durable decisions

Delete or rewrite:

- example `0000` files that do not describe real target-repo work
- placeholder paths, commands, owners, and timestamps
- generated views that are stale after deleting examples; regenerate with `scripts/docs-meta update` when installed

## Make It Obvious For The Next Agent

Before handing off the target repo, make these true:

- Root `AGENTS.md` says exactly what to read first.
- `CURRENT_STATE.md` says what exists today and what is unfinished.
- `testing-guide.md` lists commands that actually work in that repo.
- Parent plans explain scope, non-goals, dependencies, and safe parallelization.
- Implementation briefs exist only for bounded work that benefits from delegation or resumability.
- Session logs exist for meaningful setup, planning, debugging, or implementation sessions.
- Generated files such as `IDEAS.md`, `SPECS.md`, `TODOS.md`, and `ROADMAP-VIEW.md` are treated as views, not hand-maintained source.

## Paste This Prompt To Another Agent

Use this prompt in the target repo after copying the scaffold:

```text
You are in a repo that uses the AGENT-DOCS workflow.

Start by reading:
1. AGENTS.md
2. docs/README.md
3. docs/orientation/CURRENT_STATE.md
4. docs/orientation/ONBOARDING.md
5. docs/orientation/ROADMAP.md
6. docs/orientation/ARCHITECTURE.md
7. docs/repo-health/testing-guide.md

Then report:
- whether the docs are enough to understand the repo without chat history
- which placeholders or stale example files remain
- which verification commands are supported today
- what the next safest work item is

Do not implement from an implementation brief alone. Read its parent plan first. If docs-meta is installed, use scripts/docs-meta check and scripts/docs-meta check-links before closeout.
```

## Verification

In this `AGENT-DOCS` repo, run:

```bash
tests/docs-meta-smoke.sh
```

In the target repo, run whichever of these exist:

```bash
scripts/docs-meta update
scripts/docs-meta check
scripts/docs-meta check-links
scripts/docs-meta check-todos
```

If any command fails because target-repo examples were deleted or renamed, fix the source docs or generated views rather than hiding the failure.
