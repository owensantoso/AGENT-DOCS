# Agent Instructions

## Purpose

This repository owns the local integration and operating workflow that lets ChatGPT and Codex work safely against real Git worktrees while Agent Continuity remains the durable source of project truth.

This is not a general AI orchestration platform and not a model-to-model messaging system.

## Read order

1. `README.md`
2. `docs/SETUP_AND_CODEX_HANDOFF.md`
3. `docs/CURRENT_STATE.md` and `docs/ARCHITECTURE.md` once Codex creates them
4. the exact upstream CodeWeave and OpenAI documentation linked from the setup document

## Safety rules

- Treat CodeWeave as privileged local developer tooling.
- Never commit CodeWeave bearer tokens, generated `config.json` files containing machine paths, private repository contents, shell history, or credentials.
- Prefer local STDIO for the first pilot.
- Do not create a public tunnel or remote MCP endpoint during the first pilot.
- Use an isolated Git worktree, not the user’s primary checkout.
- Keep `bash`, `git_restore`, `git_push`, Git mutation, and code mutation out of the initial MCP `enabled_tools` list.
- Do not enable Bash merely because the upstream server exposes it.
- Require explicit approval for write-capable tools when they are introduced.
- Keep one active writer per worktree. Do not run Codex and ChatGPT as simultaneous writers against the same checkout.
- Inspect Git status and diff before and after every setup or pilot mutation.
- Do not push or merge without explicit user intent.
- Do not silently modify `~/.codex/config.toml`. Prefer `codex mcp add` where it can express the required configuration; otherwise back up the file, make the smallest deterministic patch, and show the diff.
- Use absolute executable and configuration paths.
- Pin the first CodeWeave install to the reviewed commit. Updating the pin is a deliberate review task.
- State clearly when a result is based on upstream documentation rather than an independently run test.

## Implementation approach

Start with the smallest end-to-end proof:

1. promote this bootstrap into a dedicated private repository;
2. create a disposable worktree for a suitable pilot repository;
3. install and verify the pinned CodeWeave build;
4. add a read-only local STDIO MCP configuration;
5. prove repository summary, search, exact read, Git status, and Git diff;
6. test one realistic review workflow;
7. record results and only then consider guarded writes.

Do not start by building a wrapper application, daemon manager, OAuth gateway, web tunnel, or CodeWeave fork.

## Verification expectations

At minimum, record:

- operating system and relevant client versions;
- exact CodeWeave commit and installed binary path;
- target worktree path without leaking private data;
- `codeweave doctor` result;
- the effective MCP tool allowlist and approval mode;
- whether `/mcp` shows the server connected;
- successful read-only tool calls;
- failed or surprising behavior;
- Git status proving the pilot did not unexpectedly mutate the worktree.

## Documentation expectations

Keep current state short and factual. Separate:

- what has been verified locally;
- what is only proposed;
- upstream behavior;
- local policy decisions;
- unresolved security or usability questions.

When the setup becomes repeatable, package it as a small script or skill. Do not preserve a long manual procedure once automation is safer and clearer.
