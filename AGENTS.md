# Agent Docs Workflow - Agent Notes

This folder is a reusable documentation kit for agent-driven software work.

## Read order

1. `README.md`
2. `INSTALL.md` when setting this workflow up in another repo
3. `guides/workflow-overview.md`
4. `guides/doc-types-and-responsibilities.md`
5. `guides/subagent-execution-loop.md`
6. `guides/adoption-checklist.md`
7. the files under `scaffold/` that match the repo you are setting up

## Purpose

Use this pack when you want to bootstrap a repo that supports:

- high-level milestone planning
- bounded implementation briefs
- subagent-driven execution
- explicit task grouping and parallelization
- lightweight but durable repo memory
- timestamped session logs, ADRs, and compact state docs

## Rules

- Do not copy templates blindly. Adapt naming, paths, verification commands, and stack-specific guidance.
- Do not copy the whole `scaffold/` folder into a target repo root. Use `INSTALL.md` so target repo files such as `README.md` are not overwritten accidentally.
- Keep parent plans architectural. Do not turn them into pseudo-patches.
- Only create implementation briefs when they make delegation, resumability, or verification meaningfully safer.
- Group tasks when they share one seam, one hot file set, one verification path, or one tightly coupled invariant.
- Split tasks when they have disjoint ownership, can run in parallel safely, or would otherwise create avoidable merge conflicts.
- Keep `CURRENT_STATE.md` accurate. It is the first reality check for future agents.
- Keep `CURRENT_STATE.md` short. Move detailed historical ledgers to state snapshots.
- Add timestamped session logs for meaningful implementation, planning, debugging, or docs workflow sessions.
- Use YAML frontmatter in new durable docs so status, timestamps, links, and domain can be queried later.
- Use structured `TODO-*` items for durable cross-session or delegated work. Source docs own TODO state; generated `TODOS.md` is only a dashboard.
- Make verification docs honest. List what the repo actually supports today, not an imagined future CI setup.
- When feedback reveals a missed rule, wrong assumption, ambiguous docs, or workflow failure, use `reflect-and-improve` and update the smallest durable source that would prevent a repeat.

## Output expectation

A repo using this kit should end up with:

- a clear read order for agents
- a stable doc hierarchy
- reusable templates for planning and execution
- reusable templates for ADRs, session logs, state history, and onboarding
- a practical handoff path for fresh sessions and delegated work
