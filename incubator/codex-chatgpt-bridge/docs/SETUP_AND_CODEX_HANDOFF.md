---
status: proposed
reviewed: 2026-08-25
candidate: codeweave
candidate_commit: 6ed56bab433eebf5a81ab77c4ea66770946dacb0
---

# Setup Plan and Codex Handoff

## Objective

Create a conservative local pilot in which the ChatGPT desktop app can inspect one disposable Git worktree through CodeWeave over STDIO.

The pilot is successful when ChatGPT can read the repository, search it, inspect Git status and an uncommitted diff, and produce a useful review without being granted shell access or write capability.

## Confirmed platform facts

As of 2026-08-25, OpenAI’s current MCP documentation states that:

- the ChatGPT desktop app, Codex CLI, and IDE extension share MCP configuration for the same Codex host;
- the desktop app can add both STDIO and Streamable HTTP MCP servers;
- configuration supports `enabled_tools`, `disabled_tools`, a default approval mode, and per-tool approval overrides;
- ChatGPT web does not read the local Codex MCP configuration and instead uses remote MCP-backed plugins/apps.

Source: [OpenAI MCP documentation](https://learn.chatgpt.com/docs/extend/mcp).

CodeWeave’s current ChatGPT guide describes the remote web path using an HTTPS `/mcp` endpoint and an authenticated gateway. That is valid for ChatGPT web but is unnecessary for this local desktop pilot.

## Candidate assessment

CodeWeave is a credible pilot candidate because it offers:

- one fixed repository per process;
- deterministic repository retrieval and exact reads;
- optional language-server intelligence with Tree-sitter and lexical fallbacks;
- hash- and handle-guarded edits;
- explicit preview and transaction tools;
- Git inspection and mutation tools;
- bounded Bash lifecycle tools;
- MCP safety annotations.

The reviewed package version is `0.2.0`. It is pre-1.0 and should be treated as an early external dependency, not trusted infrastructure.

### Critical security fact

CodeWeave’s repository file tools are constrained to the configured workspace. Its Bash tool is not sandboxed and runs with the permissions of the operating-system user.

The pilot therefore excludes:

- `bash`
- `bash_cancel`
- all code mutation tools
- `git_stage`
- `git_commit`
- `git_restore`
- `git_push`

## Recommended pilot repository

Use an isolated worktree of `owensantoso/agent-continuity` because:

- it is documentation- and Python-heavy;
- CodeWeave has suitable semantic and structural support;
- the repository has clear read-order and current-state conventions;
- a review task can be tested without touching a production application;
- it directly exercises the intended Agent Continuity handoff loop.

Do not use the primary checkout.

## Target architecture

```text
ChatGPT desktop / Codex host
        │
        │ STDIO
        ▼
CodeWeave process
        │
        │ fixed workspace.path
        ▼
disposable agent-continuity Git worktree
```

A separate CodeWeave configuration is required for each repository or worktree because the workspace cannot be switched for the lifetime of the process.

## Phase 0 — Promote this bootstrap

Create a new **private** GitHub repository:

```text
owensantoso/codex-chatgpt-bridge
```

Recommended description:

```text
Local-first MCP workflow for letting ChatGPT and Codex inspect and coordinate over real Git worktrees safely.
```

Copy the contents of the staged `incubator/codex-chatgpt-bridge/` folder to the new repository root.

Then initialize only the smallest useful Agent Continuity footprint. Prefer the `core` profile initially:

```bash
agent-continuity init --profile core --dry-run
agent-continuity init --profile core --write
```

Adapt the generated `docs/CURRENT_STATE.md` and `docs/ARCHITECTURE.md` so they describe the actual bridge pilot. Do not overwrite the bootstrap `README.md` or `AGENTS.md`.

## Phase 1 — Inspect the machine without mutating setup

Before installing anything, record:

```bash
sw_vers
uname -m
xcode-select -p
git --version
rustc --version || true
cargo --version || true
codex --version || true
which codeweave || true
```

Inspect the current Codex configuration without printing secrets:

```bash
test -f "$HOME/.codex/config.toml" && sed -n '1,240p' "$HOME/.codex/config.toml"
```

If the file contains credentials or sensitive headers, do not copy them into logs or the repository.

Locate the main local checkout of `agent-continuity` and confirm it is clean before creating a worktree:

```bash
git -C /absolute/path/to/agent-continuity status --short
git -C /absolute/path/to/agent-continuity rev-parse --show-toplevel
git -C /absolute/path/to/agent-continuity rev-parse origin/main
```

## Phase 2 — Create a disposable worktree

Use a dedicated branch and worktree. Choose paths that match the local machine:

```bash
PILOT_ROOT="$HOME/Developer/pilots"
SOURCE_REPO="/absolute/path/to/agent-continuity"
PILOT_WORKTREE="$PILOT_ROOT/agent-continuity-codeweave-pilot"

mkdir -p "$PILOT_ROOT"

git -C "$SOURCE_REPO" fetch origin main

git -C "$SOURCE_REPO" worktree add \
  -b experiment/codeweave-pilot \
  "$PILOT_WORKTREE" \
  origin/main
```

If the branch already exists, inspect it rather than deleting or force-moving it.

Verify:

```bash
git -C "$PILOT_WORKTREE" status --short --branch
git -C "$PILOT_WORKTREE" rev-parse --show-toplevel
```

## Phase 3 — Install the reviewed CodeWeave commit

Install Rust with the official `rustup` path only if Rust is missing. Review shell installers before execution.

Pin the first pilot to the reviewed upstream commit:

```bash
cargo install \
  --git https://github.com/abhij1306/codeweave \
  --rev 6ed56bab433eebf5a81ab77c4ea66770946dacb0 \
  --locked
```

Confirm the exact executable:

```bash
CODEWEAVE_BIN="$(command -v codeweave)"
test -n "$CODEWEAVE_BIN"
"$CODEWEAVE_BIN" --help
```

Do not silently replace another existing CodeWeave installation. If one exists, identify its source and version first.

## Phase 4 — Create a machine-local CodeWeave configuration

Keep generated configuration outside every Git repository:

```bash
CW_HOME="$HOME/.config/codeweave/agent-continuity-pilot"
CW_CONFIG="$CW_HOME/config.json"

mkdir -p "$CW_HOME"

"$CODEWEAVE_BIN" init \
  --path "$PILOT_WORKTREE" \
  --config "$CW_CONFIG"

"$CODEWEAVE_BIN" doctor \
  --config "$CW_CONFIG"
```

Inspect the generated JSON. Verify at minimum:

- `workspace.path` is exactly the disposable worktree;
- the server host remains loopback-only if HTTP settings exist;
- no private token or generated config is inside the Git worktree;
- timeouts and file-size limits are reasonable;
- semantic backends are not assumed to be active unless installed and enabled.

STDIO does not require the CodeWeave HTTP bearer token.

## Phase 5 — Add a read-only MCP server

Prefer a deterministic configuration with an explicit tool allowlist.

The initial allowlist is:

```text
workspace
code_retrieve
code_intelligence
code_preview
git_status
git_diff
git_log
git_show
git_blame
git_preflight
```

`code_preview` may construct and return a proposed diff but does not write files.

The resulting Codex configuration should be equivalent to:

```toml
[mcp_servers.codeweave_agent_continuity_pilot]
command = "/absolute/path/to/codeweave"
args = [
  "serve",
  "--transport",
  "stdio",
  "--config",
  "/Users/USERNAME/.config/codeweave/agent-continuity-pilot/config.json",
]
enabled = true
required = false
enabled_tools = [
  "workspace",
  "code_retrieve",
  "code_intelligence",
  "code_preview",
  "git_status",
  "git_diff",
  "git_log",
  "git_show",
  "git_blame",
  "git_preflight",
]
default_tools_approval_mode = "prompt"
startup_timeout_sec = 20
tool_timeout_sec = 120
```

Use absolute paths.

### Preferred modification path

First check whether the current `codex mcp add` command can express all required fields:

```bash
codex mcp --help
codex mcp add --help
```

If it cannot express the allowlist and approval policy, patch `~/.codex/config.toml` directly:

1. make a timestamped backup;
2. parse or patch deterministically rather than appending duplicate sections;
3. preserve unrelated configuration byte-for-byte where practical;
4. validate the resulting TOML;
5. show a redacted diff;
6. never commit the user-level config.

Example backup:

```bash
cp "$HOME/.codex/config.toml" \
  "$HOME/.codex/config.toml.backup.$(date +%Y%m%d-%H%M%S)"
```

## Phase 6 — Connect and verify

Restart the ChatGPT desktop app or the relevant Codex host after saving MCP configuration.

In the desktop composer, use:

```text
/mcp
```

Confirm that `codeweave_agent_continuity_pilot` is connected and that only the approved tools are available.

### Test 1 — Repository identity

Prompt:

```text
Use only the CodeWeave MCP server. Do not browse the web and do not use any
write or shell tool. Summarize the configured workspace, identify the current
branch and Git status, and tell me the repository read order from AGENTS.md.
```

Expected:

- correct worktree and branch;
- correct Git status;
- read order grounded in `AGENTS.md`;
- no mutation.

### Test 2 — Search and exact read

Prompt:

```text
Use only CodeWeave. Find where the repository defines the responsibility of
CURRENT_STATE.md, then read the smallest exact range that explains it. Cite the
path and line range in your answer. Do not modify anything.
```

Expected:

- search finds the owning documentation;
- response uses an exact bounded read;
- no mutation.

### Test 3 — Review a controlled local diff

Create a harmless, intentionally imperfect documentation change on the pilot branch. Do not use secrets or production behavior.

Then prompt:

```text
Use only CodeWeave. Inspect the current uncommitted diff and the relevant
repository instructions. Review the change for factual accuracy, consistency
with Agent Continuity rules, and maintainability. Do not edit. Return findings
ordered by severity and include exact file references.
```

Expected:

- ChatGPT reads the actual local diff;
- review reflects repository-specific rules;
- useful findings are independent of Codex’s implementation;
- no mutation.

### Test 4 — Preview only

Prompt:

```text
Use only CodeWeave. Prepare the smallest correction for the highest-confidence
review finding using code_preview. Do not call a write tool, Git mutation, or
Bash. Show the proposed diff.
```

Expected:

- a reasonable preview;
- no disk mutation;
- Git status is unchanged except for the intentionally created test diff.

## Phase 7 — Close out the read-only pilot

Record:

- exact CodeWeave commit;
- ChatGPT desktop and Codex versions;
- machine architecture;
- worktree and config locations;
- effective tool allowlist;
- test prompts and summarized outcomes;
- any confirmations shown by the client;
- unexpected errors or missing semantics;
- final Git status.

Then remove or preserve the pilot deliberately:

```bash
git -C "$PILOT_WORKTREE" status --short --branch
```

Do not remove the worktree while it contains unreviewed changes.

## Phase 8 — Optional guarded-write pilot

Only consider this after the read-only pilot is useful.

Add the narrow edit tools one at a time:

```text
code_write
code_replace
code_replace_range
code_insert
code_rename
code_preview
code_transaction
```

Keep these excluded:

```text
bash
bash_cancel
git_restore
git_push
```

Use:

```toml
default_tools_approval_mode = "writes"
```

and override especially risky tools to prompt if needed.

Requirements:

- use a disposable branch;
- require a preview before applying a multi-file transaction;
- inspect Git diff immediately after every write;
- do not enable simultaneous Codex and ChatGPT writers;
- do not allow automatic commit or push during the first write pilot.

## Remote web path — deferred

Do not implement this during the local pilot.

A future ChatGPT web setup would require:

- CodeWeave Streamable HTTP;
- a remote HTTPS endpoint ending in `/mcp`;
- authentication of the external caller before injecting the private origin bearer;
- an OAuth-capable MCP gateway or OpenAI Secure MCP Tunnel where supported;
- explicit review of network exposure, authorization, logging, and secret handling.

Never expose `127.0.0.1:8813` by blindly forwarding it with only the CodeWeave origin bearer.

## Acceptance criteria for the first implementation session

- [ ] A dedicated private repository exists and contains this bootstrap at its root.
- [ ] Core Agent Continuity docs truthfully describe the project.
- [ ] A disposable `agent-continuity` worktree exists.
- [ ] CodeWeave is installed at the reviewed commit.
- [ ] `codeweave doctor` succeeds for the disposable worktree.
- [ ] The ChatGPT desktop/Codex host loads CodeWeave over STDIO.
- [ ] The effective MCP allowlist contains only the ten read-oriented tools listed above.
- [ ] Repository identity, search, exact-read, diff-review, and preview-only tests complete.
- [ ] No unexpected file, Git, shell, or network mutation occurs.
- [ ] Results are recorded and committed to the bridge repository.
- [ ] Nothing is merged or pushed to another project without explicit user intent.

## Ready-to-paste Codex handoff

```text
Create and run the first conservative pilot for the Codex ↔ ChatGPT local
repository bridge.

Source bootstrap:
- Repository: owensantoso/agent-continuity
- Branch: proposal/codex-chatgpt-bridge-bootstrap
- Folder: incubator/codex-chatgpt-bridge

Read the folder's README.md, AGENTS.md, and
docs/SETUP_AND_CODEX_HANDOFF.md before acting.

Goals:
1. Create a new private GitHub repository named
   owensantoso/codex-chatgpt-bridge.
2. Promote the staged folder contents to that repository root.
3. Add the smallest truthful Agent Continuity core footprint without
   overwriting the bootstrap docs.
4. On this Mac, create a disposable worktree of agent-continuity.
5. Install CodeWeave pinned to commit
   6ed56bab433eebf5a81ab77c4ea66770946dacb0.
6. Generate and doctor a machine-local CodeWeave config for that worktree.
7. Add a local STDIO MCP entry to the shared ChatGPT desktop/Codex
   configuration with exactly the documented read-only tool allowlist.
8. Run the documented read-only verification prompts where possible.
9. Record exact commands, redacted results, limitations, and final Git status
   in the new bridge repository.
10. Commit and push only the new bridge repository. Do not merge or push
    changes in agent-continuity without asking.

Hard constraints:
- Do not expose CodeWeave over the public internet.
- Do not enable Bash.
- Do not enable any CodeWeave write or mutating Git tools.
- Do not modify the primary agent-continuity checkout.
- Do not overwrite ~/.codex/config.toml without a timestamped backup and a
  reviewed minimal diff.
- Do not print or commit credentials, tokens, private source, or unredacted
  sensitive config.
- Keep one writer per worktree.
- Stop and report rather than weakening a safety constraint to make the demo
  pass.

Use the existing GitHub authentication and local tools available to Codex. If
GitHub repository creation is blocked by permissions, still create the complete
local repository and report the exact remaining publish command rather than
placing the project into an unrelated repository.
```

## Upstream sources

### CodeWeave

- [Pinned source tree](https://github.com/abhij1306/codeweave/tree/6ed56bab433eebf5a81ab77c4ea66770946dacb0)
- [README](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/README.md)
- [Installation](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/docs/installation.md)
- [Tools](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/docs/tools.md)
- [Architecture](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/docs/architecture.md)
- [Security](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/SECURITY.md)
- [Configuration example](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/config.example.json)
- [Remote ChatGPT setup](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/docs/connect-chatgpt.md)

### OpenAI

- [MCP configuration shared by ChatGPT desktop and Codex](https://learn.chatgpt.com/docs/extend/mcp)
- [ChatGPT Developer mode and remote MCP apps](https://developers.openai.com/api/docs/guides/developer-mode)
- [MCP and connector security guidance](https://developers.openai.com/api/docs/guides/tools-connectors-mcp)
