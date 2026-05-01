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

From the target repo root, install or update the CLI and preview the recommended small profile:

```bash
curl -fsSL https://raw.githubusercontent.com/owensantoso/AGENT-DOCS/main/install.sh | bash -s -- --profile small --dry-run
```

The curl installer installs `agent-docs-init` and previews by default. Write mode requires explicit intent:

```bash
agent-docs-init --profile small --dry-run
agent-docs-init --profile small --write
```

If you omit the target path, non-interactive mode uses the current directory and interactive mode asks whether to install into the current directory or another path. The standalone `agent-docs-init` command also defaults to dry-run unless you pass `--write`.

Install or update the CLI without running init:

```bash
curl -fsSL https://raw.githubusercontent.com/owensantoso/AGENT-DOCS/main/install.sh | bash -s -- --no-run
```

If you are installing from a private fork, authenticate with GitHub CLI and let `gh` handle the token instead of placing a bearer token in shell history or process listings:

```bash
gh auth login
gh api -H "Accept: application/vnd.github.raw" /repos/OWNER/AGENT-DOCS/contents/install.sh | AGENT_DOCS_REPO_URL=https://github.com/OWNER/AGENT-DOCS.git bash -s -- --profile small --dry-run
```

Repeated installs update `~/.agent-docs`, refresh the `agent-docs-init` symlink, and report when the command is already installed. Existing target files are listed during dry-run; write mode refuses to overwrite them unless you pass `--force`. An existing `docs/` folder is fine when the selected profile only needs to create missing files inside it.

Supported platforms and prerequisites:

- macOS or Linux shell with Bash.
- Git for installer clone/update paths.
- Python 3.10 or newer.
- Symlink support for the installed `agent-docs-init` command.
- A user-local bin directory such as `~/.local/bin` on `PATH`, or set `AGENT_DOCS_BIN_DIR`.

Manual full-scaffold install:

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

After a full-scaffold install, edit at least these files before asking another agent to use the repo:

- `AGENTS.md`
- `docs/README.md`
- `docs/orientation/CURRENT_STATE.md`
- `docs/orientation/ONBOARDING.md`
- `docs/orientation/ROADMAP.md`
- `docs/orientation/ARCHITECTURE.md`
- `docs/repo-health/codebase-map.md`
- `docs/repo-health/testing-guide.md`

Remove example files that do not apply, or keep them only if they are clearly marked as examples.

For a small-profile install, the first files are flatter:

- `AGENTS.md`
- `docs/README.md`
- `docs/CURRENT_STATE.md`
- `docs/ARCHITECTURE.md`
- `docs/ROADMAP.md`
- `docs/plans/`
- `docs/decisions/`
- `docs/session-logs/`

## Optional Metadata CLI

Install `docs-meta` when the target repo should mechanically manage IDs, generated registries, todos, docs links, safe doc moves, roadmap views, and docs health checks.

Current stable-ID families include `IDEA`, `RSCH`, `EVAL`, `DIAG`, `CONC`, `SPEC`, `PLAN`, `IMPL`, `ADR`, `LRN`, `EXPL`, `QST`, and `TODO`.

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

These are `AGENTS.md` instruction templates, not Codex `SKILL.md` packages. `skill:<name>` TODO metadata is routing metadata unless the target environment separately provides matching skills.

For example:

```bash
mkdir -p docs/repo-health/agent-instructions
cp "$AGENT_DOCS/scaffold/agent-instructions/"*.md ./docs/repo-health/agent-instructions/
```

Then adapt the placeholders before relying on them.
These copied files are reference templates until you rename or place them as real surface-level `AGENTS.md` files where they govern active work.

## Optional Structured Docs Skill

If the target environment supports repo-local skills, copy the structured docs workflow skill too. This uses the scaffold copy, which is written for target repos after installation:

```bash
mkdir -p skills/structured-docs-workflow
cp "$AGENT_DOCS/scaffold/skills/structured-docs-workflow/SKILL.md" ./skills/structured-docs-workflow/SKILL.md
```

This gives fresh implementation agents a fast path for state docs, plans, briefs, structured `TODO-*`, and `docs-meta` usage.

## What To Keep Or Delete

Keep:

- `AGENTS.md` as the first agent entry point
- `docs/README.md` as the docs map
- For small-profile repos, `docs/CURRENT_STATE.md`, `docs/ARCHITECTURE.md`, and `docs/ROADMAP.md`
- `docs/orientation/CURRENT_STATE.md` as the short truth page
- `docs/orientation/ONBOARDING.md` for the non-code walkthrough
- `docs/orientation/ROADMAP.md` for sequence and rationale
- `docs/orientation/ARCHITECTURE.md` for system boundaries
- `docs/orientation/explainers/` for reusable human-facing explanations
- `docs/decisions/learnings/` for lessons learned and corrected assumptions
- `docs/decisions/questions/` for durable questions with status and resolution history
- `docs/repo-health/audits/` for reusable audit guides and repo-health audit receipts
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
- Generated files such as `IDEAS.md`, `CONCEPTS.md`, `SPECS.md`, `LEARNINGS.md`, `EXPLAINERS.md`, `QUESTIONS.md`, `TODOS.md`, and `ROADMAP-VIEW.md` are treated as views, not hand-maintained source.
- A quick search for unreplaced placeholder text such as `<path>` or `<command>` comes back clean enough for handoff.

## Paste This Prompt To Another Agent

Use the small-profile prompt when the target repo has flat docs:

```text
You are in a repo that uses the AGENT-DOCS workflow.

Start by reading:
1. AGENTS.md
2. docs/README.md
3. docs/CURRENT_STATE.md
4. docs/ARCHITECTURE.md
5. docs/ROADMAP.md

Then report:
- whether the docs are enough to understand the repo without chat history
- which placeholders or stale example files remain
- which verification commands are supported today
- what the next safest work item is

Do not implement from an implementation brief alone. Read its parent plan first.
```

Use this growing/full-profile prompt when the target repo has `docs/orientation/` and repo-health docs:

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

If the repo has a root ./run command, prefer it for verification:
- ./run check for the fast handoff baseline.
- ./run agent-check before meaningful closeout or commit when available.

If those commands do not exist, recommend adding them or document the closest equivalent in docs/repo-health/testing-guide.md.
```

## Verification

In this `AGENT-DOCS` repo, run:

```bash
tests/docs-meta-smoke.sh
```

In the target repo, run whichever of these exist:

```bash
./run check
./run agent-check
scripts/docs-meta update
scripts/docs-meta check
scripts/docs-meta check-links
scripts/docs-meta check-todos
```

If any command fails because target-repo examples were deleted or renamed, fix the source docs or generated views rather than hiding the failure.
