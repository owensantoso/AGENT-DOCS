# Subagent Execution Loop

This workflow assumes one main agent may coordinate one or more smaller agents.

## The loop

1. Read the current state, architecture, spec, and parent plan.
2. Decide the execution shape from the parent plan.
3. Identify bounded tasks that are safe to delegate.
4. Create or refine implementation briefs where needed.
5. Assign each subagent one brief and one ownership area.
6. Integrate the results centrally.
7. Verify against both the brief and the parent plan.
8. Update state docs, checklists, and the session log.
9. Use commit trailers for meaningful commits.

When a repo uses structured `TODO-*` items, cite relevant todo IDs in delegation prompts and closeout notes. Parent plans and implementation briefs own scope; `TODO-*` IDs own progress references. `skill:<name>` todo metadata can guide skill routing, but it is not a substitute for reading the plan or brief.

For todo-backed delegation, the main agent should usually claim or assign the TODO before handing it off:

- set `[in_progress]`
- add `owner:` for the accountable role or person
- add `agent:` for the exact runner, subagent, chat, thread, or tool-session identifier when available
- add `updated:` with an exact local timestamp

Subagents should report the TODO IDs they touched and the verification they ran. They should not mark a source TODO done unless the delegation prompt explicitly gives them that authority.

## How to decide task grouping

Group tasks into one implementation brief when they share most of the following:

- the same primary seam
- the same hot files
- the same invariant
- the same verification bundle
- tight coupling where splitting would create churn or temporary invalid states

Common good groupings:

- route vocabulary plus root router foundation
- schema plus repository changes that must land together
- parser plus destination handling when they exercise the same seam

## How to decide task splitting

Split tasks into separate briefs when they have most of the following:

- disjoint file ownership
- low coupling
- different verification paths
- different risk profiles
- real parallelization value

Common good splits:

- persistence foundation versus UI surface work
- domain derivation logic versus docs follow-through
- backend plumbing versus one feature surface that consumes it

## Parallelization rules

Parallelization is safe when:

- both tasks can proceed after the same foundation lands
- file ownership is mostly disjoint
- there is no shared hot file that would force one task to wait anyway
- the parent plan makes the dependency explicit

Parallelization is unsafe when:

- both tasks rewrite the same root composition file
- one task needs the other task's new API or migration to exist first
- one task is effectively a moving target until the other stabilizes

## Ownership rules for delegated briefs

Each brief should say:

- what it owns
- what adjacent briefs own
- whether it expects integration with parallel slices
- which files are likely write-conflict hotspots
- creation time, execution time, status, and dependencies in frontmatter

If ownership is fuzzy, the brief is not ready for delegation.

## Main-agent responsibilities during delegation

The main agent should not disappear while subagents work.

It should:

- preserve architectural consistency
- monitor cross-brief assumptions
- resolve plan/code mismatches
- integrate shared seams
- keep docs and checklists truthful
- update source `TODO-*` checkboxes and run todo checks when delegated work is todo-backed

## A simple heuristic

If a task can be described as "one coherent seam change with one done condition," it probably fits one brief.

If the task description needs several separate ownership statements or would create avoidable conflicts, it probably wants more than one brief.
