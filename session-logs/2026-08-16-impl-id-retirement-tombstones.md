---
type: session-log
document_format_version: 2
id: 01a02039-7a6a-7bc6-b14b-c2fe3df71fcf
aliases: []
title: IMPL ID retirement tombstones
status: completed
created_at: "2026-08-16 05:47:52 JST +0900"
updated_at: "2026-08-16 06:55:53 JST +0900"
started_at: "2026-08-16 05:20:00 JST +0900"
ended_at: "2026-08-16 06:55:53 JST +0900"
timezone: "JST +0900"
participants:
  - Owen
  - Codex task 01a00714-9867-78e0-9f70-512ad0a53edd
related_todos: []
---

# IMPL ID retirement tombstones

## Goal

Add a narrow, permanent retirement record for the current next `IMPL-*` ID so
an abandoned identifier cannot later be reallocated as live work.

## Contract

- `retire-id` supports IMPL IDs only and previews by default.
- A write requires a matching live parent plan, reason, and source provenance.
- The fixed project-owned tombstone path is
  `docs/id-retirements/<IMPL-ID>.md`.
- Tombstones advance allocation and the global registry but never satisfy live
  references.
- Exact repeats preserve bytes; conflicts, status changes, moves, collisions,
  future jumps, and unsafe paths fail without overwriting the target.

The atomicity guarantee is scoped to exclusive no-overwrite publication at the
one tombstone target path. It does not serialize the wider repository IMPL
namespace; concurrent allocators require ordinary exclusive branch and owner
discipline.

## Independent review correction

The independent review requested four bounded corrections before Place
adoption:

- directory moves and all link-rewrite source sets now preserve tombstone
  immutability;
- global TODO allocation, listing, validation, generated views, and review
  ignore tombstone checkboxes while explicit `show` and `status` still inspect
  the document;
- an idempotent repeat now requires the complete existing tombstone to pass the
  current schema validator before stable caller inputs are compared; and
- adopter documentation now distinguishes target-path atomic publication from
  repository-wide allocator serialization.

Test-first receipts observed the unfixed behavior in sequence: a tombstone
`TODO-9998` advanced `next todo` to `TODO-9999`; a directory containing the
tombstone moved successfully; a tombstone missing frontmatter `id` returned
`ALREADY RETIRED`; and `normalize-links --write` changed tombstone bytes. Each
case passed after its corresponding narrow correction. Final verification is
recorded below.

## Verification

- `tests/agent-continuity-docs-smoke.sh` — passed, including red/green coverage
  for an empty retirement status.
- `tests/agent-continuity-init-smoke.sh` — passed.
- `tests/agent-continuity-doctor-upgrade-smoke.sh` — passed with captured exit
  `0`.
- `scripts/changelog-check` — passed.
- `scripts/release-check` — passed without weakening or skipping any subcommand.
- `git diff --check` — passed inside the release gate.

The apparent doctor/release discrepancy was investigated before any speculative
fix. The standalone doctor suite exited `0`, and a traced release wrapper exited
`0` through every subcommand. The misleading non-zero came from the diagnostic
zsh shell rejecting its reserved `status` variable after the suite had run; the
other partial result was a 30-second command-session yield, not process failure.
No repository change was made for that tooling artifact.

Storage remained at warning pressure (`owen-storage-history pressure-status
--quiet` exit `11`). Verification used temporary test fixtures only; no
worktree, repository copy, dependency download, build archive, installation,
publication, or downstream Place edit was performed.

### Independent review verification

- `tests/agent-continuity-docs-smoke.sh` — passed with the four new review
  regressions.
- `tests/agent-continuity-init-smoke.sh` — passed.
- `tests/agent-continuity-doctor-upgrade-smoke.sh` — passed with captured exit
  `0`.
- `scripts/changelog-check` — passed.
- `scripts/agent-continuity docs --root session-logs check` — passed.
- `scripts/release-check` — passed with every existing subcommand intact.
- `git diff --check` — passed directly and inside the release wrapper.

## Second re-review correction

The remaining re-review regression was a move target referenced by an immutable
tombstone. Link rewrite source exclusion preserved the tombstone bytes, but the
move still completed and left its link broken.

The move path now resolves all tombstone-sourced references before any mutation
and refuses when a target equals the move source or lies beneath a moved
directory. The error names the tombstone source and instructs the caller to keep
the source in place or choose a migration that preserves the referenced path.

The failing regression first proved that the exact linked file still moved.
After the guard, exact-file and nested-directory moves are refused, their source
bytes and the tombstone bytes remain unchanged, destinations remain absent, and
`check-links` remains green. The existing unrelated move continues to pass.
Final verification for this correction passed:

- `tests/agent-continuity-docs-smoke.sh`
- `tests/agent-continuity-init-smoke.sh`
- `tests/agent-continuity-doctor-upgrade-smoke.sh`
- `scripts/changelog-check`
- `scripts/agent-continuity docs --root session-logs check`
- `scripts/release-check`
- `git diff --check`

## Adopter smoke portability follow-up

The Place adoption consultation found that the reusable docs smoke test still
called `scripts/agent-continuity`, although adopters may vendor only the owned
`scripts/agent-continuity-docs` executable and the smoke test. A two-file
adopter fixture reproduced the dependency with exit `127`: the dispatcher was
absent even though the docs executable was present.

The smoke helpers now invoke `scripts/agent-continuity-docs` directly for both
the default docs root and the explicit `run_meta_root` retirement fixtures. A
guarded regression copies only the owned executable and smoke test into a
minimal adopter Git fixture, proves no dispatcher exists, and runs the complete
copied smoke suite from that adopter root.

The regression failed first on the missing dispatcher, then passed after the
three direct-launch substitutions and the fixture's adopter-root execution
context were in place. Final verification passed:

- `tests/agent-continuity-docs-smoke.sh`, including the dispatcher-free copied
  adopter suite;
- `tests/agent-continuity-init-smoke.sh`;
- `tests/agent-continuity-doctor-upgrade-smoke.sh` with exit `0`;
- `scripts/changelog-check`;
- `scripts/agent-continuity-docs --root session-logs check`;
- `scripts/release-check` with exit `0`; and
- `git diff --check` inside the release gate.

The first release command session yielded during the doctor suite without
retaining its session identifier, so it was treated as inconclusive rather
than as a failure or success. No matching release process remained. A second
run retained and polled the command session through every subcommand to exit
`0`; no gate was changed, weakened, or skipped.
