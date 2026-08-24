# Codex ↔ ChatGPT Local Repository Bridge

> **Status:** bootstrap proposal and local pilot  
> **Reviewed:** 2026-08-25  
> **Candidate implementation:** [CodeWeave](https://github.com/abhij1306/codeweave), reviewed at commit [`6ed56bab433eebf5a81ab77c4ea66770946dacb0`](https://github.com/abhij1306/codeweave/tree/6ed56bab433eebf5a81ab77c4ea66770946dacb0)

This repository is intended to own a small but important integration layer:

- **Codex** remains the main coding and execution agent.
- **ChatGPT** can inspect the same real local worktree for architecture discussion, review, debugging, documentation, and occasional guarded edits.
- **Agent Continuity** remains the durable source of project truth and handoff state.
- **Git and worktrees** remain the coordination and recovery mechanism.

The name “bridge” is conceptual. Version 1 is **not** model-to-model messaging and does not synchronize two chat transcripts. It gives both surfaces controlled access to the same local repository state and defines a safe workflow for handing work between them.

If this file is being read under `incubator/codex-chatgpt-bridge/` in another repository, that location is only a staging area. Promote this folder into a dedicated repository named `codex-chatgpt-bridge` before treating it as canonical.

## Why this should be a separate repository

This work supports Agent Continuity, but it is not the Agent Continuity documentation system itself. It may eventually contain:

- machine-local setup and doctor scripts;
- reviewed MCP configuration templates;
- a worktree launcher;
- security profiles and tool allowlists;
- test prompts and acceptance checks;
- optional adapters or a hardened CodeWeave fork;
- reusable skills for review and handoff workflows.

Putting those concerns inside `agent-continuity` would blur the boundary between durable project-memory conventions and one particular local tool integration. Putting them inside `continuity-workspace` would blur a user-facing product with developer infrastructure. A dedicated repository gives this experiment room to succeed, fail, or change implementations cleanly.

## The intended operating model

```text
                    durable intent and evidence
             ┌────────────────────────────────────┐
             │ Agent Continuity docs in the repo  │
             └────────────────────────────────────┘
                              ▲
                              │
                              │ read / update
                              │
┌──────────────────┐     ┌────┴──────────────┐     ┌──────────────────┐
│ Codex             │     │ Local Git worktree│     │ ChatGPT desktop  │
│ implementation,   │◀───▶│ code, docs, diff, │◀───▶│ architecture,    │
│ tests, automation │     │ tests, history    │ MCP │ review, handoff  │
└──────────────────┘     └───────────────────┘     └──────────────────┘
          │                        │                         │
          └──────────── Git commits, branches and worktrees ┘
```

For the initial pilot, ChatGPT reaches the worktree through a local [Model Context Protocol](https://modelcontextprotocol.io/) server. CodeWeave is the leading candidate because it combines repository retrieval, guarded edits, Git operations, and bounded command execution in one repository-scoped MCP server.

## What CodeWeave provides

The reviewed version advertises a fixed 25-tool surface:

- repository summary, indexing, maps, text search, symbol search, exact reads, definitions, references, and diagnostics;
- guarded single-file edits plus multi-file preview and transaction operations;
- Git status, diff, log, show, blame, preflight, stage, commit, restore, and push;
- Bash execution with status, paged output, timeout, and cancellation.

Its editing model is more disciplined than handing a model a generic shell. Reads can return handles tied to a workspace snapshot and content hash; later edits can require those preconditions. Multi-file operations report partial application and recovery failures honestly rather than claiming stronger atomicity than they provide.

See the upstream [tool reference](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/docs/tools.md) and [architecture](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/docs/architecture.md).

## The important security boundary

CodeWeave has two very different kinds of capability:

1. **Repository file tools** are capability-confined to one configured workspace.
2. **Bash is not sandboxed.** It runs as the operating-system user and can access anything that user can access, regardless of the configured repository root.

A workspace path restricts CodeWeave’s own file operations and the accepted Bash working directory. It does not stop a shell command from reading another directory, changing unrelated files, using credentials, or making network requests.

Therefore the default pilot policy is:

- use a disposable Git worktree;
- allow only read-oriented CodeWeave tools at first;
- keep `bash`, Git mutation, and code mutation disabled through the MCP client allowlist;
- require explicit approval when write tools are later introduced;
- never expose a local CodeWeave HTTP endpoint directly to the public internet;
- keep one active writer per worktree.

Read upstream [SECURITY.md](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/SECURITY.md) before expanding access.

## Local desktop path versus ChatGPT web

The recommended first path is **local STDIO through the ChatGPT desktop/Codex host**:

- current OpenAI documentation says the ChatGPT desktop app, Codex CLI, and IDE extension share MCP configuration;
- the desktop app supports both local STDIO servers and Streamable HTTP servers;
- MCP configuration supports per-server tool allowlists, denylists, and approval modes;
- this path does not require an internet-facing CodeWeave server.

Official reference: [OpenAI MCP documentation](https://learn.chatgpt.com/docs/extend/mcp).

ChatGPT web is a different deployment path. Web conversations use remote MCP-backed plugins/apps. A web setup requires a remote HTTPS MCP endpoint or a properly authenticated tunnel/gateway. CodeWeave’s own [ChatGPT connection guide](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/docs/connect-chatgpt.md) is written for that remote path.

The remote path is not part of the first pilot.

## Relationship to Codex

CodeWeave does not make ChatGPT “become Codex,” and it does not replace Codex’s coding harness, sandboxing, review UI, or agent loop.

The useful division is:

### Codex

- performs primary implementation;
- runs broader test and verification loops;
- creates and manages worktrees;
- carries out machine setup;
- packages repeatable workflows as scripts or skills.

### ChatGPT with CodeWeave

- reads the exact local implementation and uncommitted diff;
- discusses architecture with access to current source rather than pasted snippets;
- reviews Codex output independently;
- checks whether work matches plans and durable docs;
- prepares or applies small, reviewed patches;
- updates Agent Continuity records from evidence in the worktree.

### Agent Continuity

- records what is true now;
- preserves decisions, plans, implementation boundaries, and evidence;
- allows either client to resume without relying on hidden chat history.

## Concurrency rule

Do not let Codex and ChatGPT write to the same worktree at the same time.

CodeWeave serializes mutations made through one running CodeWeave process, but it cannot coordinate an external Codex process editing the same files. Use one of these patterns:

- one client writes while the other remains read-only;
- explicit handoff: stop work, inspect status/diff, then transfer control;
- separate Git worktrees for genuinely parallel work.

Git is the recovery boundary. Review diffs before commit and preserve small commits.

## Language support caveat

At the reviewed commit, built-in Tree-sitter support covers Python, TypeScript/JavaScript, Rust, Go, Java, C#, C, C++, and JSON. Optional configured language-server support exists for Rust, Python, and TypeScript.

Swift, GDScript, Markdown, HTML, YAML, TOML, and other files can still be read, searched lexically, and edited, but they do not receive the same semantic support.

This makes `agent-continuity` or a TypeScript project a better first pilot than a SwiftUI or Godot-heavy repository.

## Pilot outcome

The first pilot should answer only these questions:

1. Can ChatGPT desktop reliably connect to a repository-scoped CodeWeave instance over STDIO?
2. Can it understand an Agent Continuity repository from live files without large copy-pastes?
3. Can it inspect an uncommitted Codex diff and produce a useful independent review?
4. Do tool allowlists and approval settings keep the trial acceptably constrained?
5. Is the workflow meaningfully better than using Codex alone plus GitHub access?

A successful pilot does **not** require remote web access, arbitrary Bash, automatic commits, pushes, or multi-repository switching.

## Proposed repository shape after promotion

```text
AGENTS.md
README.md
docs/
  ARCHITECTURE.md
  CURRENT_STATE.md
  SETUP_AND_CODEX_HANDOFF.md
config/
  README.md
scripts/
  README.md
```

Only the first three source files exist in this bootstrap. Codex should create the smallest additional structure justified by the pilot rather than scaffolding an elaborate platform immediately.

## Start here

1. Read [`AGENTS.md`](AGENTS.md).
2. Read [`docs/SETUP_AND_CODEX_HANDOFF.md`](docs/SETUP_AND_CODEX_HANDOFF.md).
3. Give Codex the handoff prompt in that document.
4. Run the pilot against a disposable worktree.
5. Record the actual result before adding more automation.

## Sources reviewed

### CodeWeave

- [README](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/README.md)
- [Installation](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/docs/installation.md)
- [Tool reference](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/docs/tools.md)
- [Architecture](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/docs/architecture.md)
- [Security policy](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/SECURITY.md)
- [Example configuration](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/config.example.json)
- [ChatGPT remote connection guide](https://github.com/abhij1306/codeweave/blob/6ed56bab433eebf5a81ab77c4ea66770946dacb0/docs/connect-chatgpt.md)

### OpenAI

- [Model Context Protocol for ChatGPT desktop and Codex](https://learn.chatgpt.com/docs/extend/mcp)
- [ChatGPT Developer mode for remote MCP apps](https://developers.openai.com/api/docs/guides/developer-mode)
- [MCP and connector security guidance](https://developers.openai.com/api/docs/guides/tools-connectors-mcp)
