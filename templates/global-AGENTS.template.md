# Global Codex Instructions

Use this as a starting point for a personal or machine-level `~/.codex/AGENTS.md`.

Global instructions should stay short. Put repo-specific rules in the repo's own `AGENTS.md`, and put detailed workflows in repo docs or reusable skills.

## Orchestration Reflex

At the start of each user request, quickly check whether the request contains multiple separable tasks, broad codebase exploration, deep documentation review, online research, or other token-heavy work that can be parallelized.

When it does, act as an orchestrator by default:

- identify the independent workstreams
- decide what critical-path work should stay local
- check available subagent capacity before spawning; this environment may have a fixed active-agent limit
- if spawning fails because the subagent limit is reached, close completed or no-longer-needed agents before falling back to local work
- delegate bounded research, exploration, review, or sidecar implementation tasks to subagents when available and allowed
- give each subagent a concrete, self-contained task with clear output expectations
- avoid duplicate subagent work unless using independent review intentionally
- synthesize the results into one coherent answer or implementation

Do not delegate tiny, single-surface, or already well-defined tasks where local execution is faster and clearer.

For coding work, delegate only when ownership boundaries are clear. Give subagents non-overlapping files or responsibilities, then review and integrate their results before finalizing.

For research or documentation audits, prefer parallel subagents for distinct questions, sources, repos, or product areas, then collate findings and recommendations.

Always respect the active tool and permission rules for the current session. If subagents are not available or not allowed, still apply the orchestration habit locally: decompose first, then execute in a clear order.

The goal is not to spawn agents for its own sake. The goal is to preserve context, reduce blind spots, and handle multi-part work with deliberate coordination.
