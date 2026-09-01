# Changelog

Adopter-facing Agent Continuity changes are recorded here. Internal planning notes,
session logs, and repo-private docs do not need entries unless they change how
another repository installs, runs, verifies, or reuses Agent Continuity.

## Unreleased

### For adopters

- Added named release `2026.09.01.1` for UUIDv7 session-log construction and
  automatic document-mutation preflight.
- Supported write-capable `agent-continuity docs` commands now run a silent,
  machine-stable doctor policy automatically before mutating a canonical
  manifest-backed repository. Release, owned-tooling, incompatible-shape, and
  document-format drift refuse before writes, while generated-view repair,
  UUID migration, and read-only diagnosis retain their explicit paths. Direct
  helper invocation uses a compatible installed dispatcher from `PATH` and
  fails closed when none is available.
- Added `agent-continuity docs new session` / `session-log`. Fresh session logs
  now receive UUIDv7 identity, `aliases: []`, a dated slug path, valid
  lifecycle fields, and exact local timestamps through the same deterministic
  creation path as other structured documents.
- Replaced copy-first session-log template guidance with the supported command
  and strengthened the structured-doc workflow: supported document families
  must begin through `docs new` rather than generating identity separately.
- Reframed the README architecture visual as a canonical diagram export with
  larger primary node labels and a compact bottom-left legend, without
  promotional share-card chrome.

## 2026.08.26.1

### For adopters

- Added preview-first `agent-continuity project new`. It fixes the new-project
  baseline at `complete`, initializes `main`, installs repository-local
  deterministic CI plus a least-privilege GitHub Actions caller, verifies before
  the initial commit, writes a named root README and Agent Index, records a
  bootstrap receipt, and optionally creates and
  pushes an explicitly named GitHub repository after local checks pass.
- Added `agent-continuity ci [target]` and the vendored
  `scripts/agent-continuity-ci` contract for manifest-owned checksums and modes,
  structured docs, local links, structured TODOs, generated-view freshness, and
  Git whitespace. Project-specific build and test commands remain project-owned.
- Fresh manifests and bootstrap receipts no longer embed absolute local checkout
  paths, so committing or publishing a generated repository does not disclose
  the initializer's machine-local directory layout. Stored repository provenance
  also strips URL userinfo, queries, and fragments that could contain credentials.
- Fresh project instructions and the structured-doc workflow now require a
  read-only `agent-continuity doctor .` preflight before the first Agent
  Continuity docs or tooling mutation in a task. Stale release, owned-tooling,
  or document-format state blocks new structured-doc writes until the reported
  upgrade or migration is coordinated.
- The existing-install runbook now documents the automated whole-corpus UUID
  migration: prepare and commit one immutable mapping, then apply that exact
  plan instead of rewriting documents manually.
- Added document format v2 with UUID version 7 (UUIDv7) canonical identity,
  empty aliases on fresh documents, type-plus-slug locators, UUID/alias lookup,
  and compatibility reading for v1 Markdown. Existing numeric IDs are preserved
  only as aliases during migration; fresh documents and repositories do not
  allocate numbered aliases.
- Added `agent-continuity docs format-status` and preview-first
  `migrate-uuids`. Migration plans record the base commit, known worktrees,
  preimage and postimage hashes, assigned UUIDs, and a receipt path. Write mode
  requires the exact plan to be committed, refuses divergent preimages before
  mutation, resumes partial expected postimages, and writes the receipt last.
- `doctor` now inspects the canonical UUID migration plan and full completion
  receipt, reports `ready` or `in_progress` with an exact resume command, and
  refuses invalid receipts. Completed migrations permit later content edits
  while enforcing planned UUIDs, historical aliases, and a v2-only corpus.
- Fresh aliasless audit records now validate without requiring a legacy
  `AUDT-####` alias.
- Added named release `2026.08.21.1`, manifest schema version 2, and the
  independent `document_format_target`. `doctor` reads schema 1 compatibly and
  reports manifest and document-format migrations separately; tooling-only
  upgrade does not mutate project-authored Markdown.
- Fresh complete scaffolds now omit fake numbered records, assign UUIDv7 to
  starter records, and regenerate views from the resulting corpus.
- Added preview-first `agent-continuity docs retire-id` for permanently retiring
  the current next `IMPL-*` ID of a live plan. Explicit `--write` creates a
  typed, provenance-bearing tombstone under `docs/id-retirements/`; it advances
  allocation and the global registry without becoming live work.
- Retirement tombstones are immutable through supported status and move
  commands, directory moves, and link rewrites; they reject collisions and
  unsafe path shapes, remain project-owned through init/doctor/update, and are
  ignored by live TODO and audit references. Moves that would break a resolved
  link from an immutable tombstone are refused before mutation.
- The reusable structured-docs smoke test now invokes the vendored
  `scripts/agent-continuity-docs` executable directly and verifies that the
  executable plus copied smoke test pass without the top-level dispatcher.
- Structured-document operations now live under `agent-continuity docs`. Fresh
  installs use `--docs`, install `scripts/agent-continuity-docs`, record the
  `agent-continuity-docs` optional component, and emit the
  `agent-continuity docs update` generated-view marker. Existing
  `scripts/docs-meta`, `--docs-meta`, old manifest components, and old generator
  records remain supported as legacy compatibility inputs.
- The public GitHub repository is now `owensantoso/agent-continuity`; install
  URLs and the installer default source URL now use that repository path.
- Added a dedicated package-manager distribution follow-up plan for Homebrew or
  a similar install channel after the GitHub install path settles.
- Added upgrade guidance for existing projects with older Agent Continuity installs.
- Added an agent-facing upgrade runbook and clarified that native Windows is
  not first-class yet; WSL is the closest supported Windows path.
- The primary installed command is now `agent-continuity`. Existing
  `agent-docs` and `agent-docs-init` commands remain compatibility commands.
- Public install profiles are now `core`, `standard`, `expanded`, and
  `complete`, with `standard` as the recommended default. The old `tiny`,
  `small`, `growing`, and `full` names remain compatibility aliases and new
  manifests record canonical profile keys.
- The installer still publishes `agent-docs` and `agent-docs-init` as
  compatibility commands for existing adopters.
- Explicit write installs now create `.agent-continuity/manifest.json` with schema
  version 1, profile/source metadata, optional component records, conservative
  file ownership, and checksums for Agent Continuity-owned tooling.
- Added read-only `agent-continuity doctor [target]` and `agent-continuity upgrade
  --dry-run [target]` reports for manifest health, drift, safe additions,
  candidate tooling updates, generated-view refreshes, manual-review items,
  and refused shapes.
- Added `agent-continuity upgrade --write --tooling-only [target]` for deterministic
  Agent Continuity-owned tooling updates, missing owned-file restores, executable-bit
  repairs, backups under `.agent-continuity/backups/<timestamp>/`, and manifest-last
  updates. Bare `agent-continuity upgrade` remains a read-only preview, and
  `--write` without `--tooling-only` is refused. Successful tooling-only writes
  return the post-write classification, so fully repaired targets exit `0`.
- Added explicit generated-view upgrade writes with `agent-continuity upgrade --write
  --tooling-only --generated-views [target]`. The first supported generator is
  `agent-continuity docs update`, and only manifest-tracked generated views are
  refreshed.
- Fresh installs that include `agent-continuity-docs` now generate and register recognized
  structured-document views in `.agent-continuity/manifest.json`. Legacy baseline
  installs can opt in with `agent-continuity baseline --generated-views`, which
  records existing recognized generated views without running generators.
- Added `agent-continuity baseline --dry-run|--write [target] --profile <profile>
  --docs auto|yes|no` so legacy installs without a manifest
  can preview and create a conservative manifest for matching Agent Continuity-owned
  tooling while keeping project Markdown unmodified and unchecksummed.
- Public-readiness work now favors preview-first install and init flows so first
  runs show intended changes before writing files.
- Supported platform and prerequisite guidance is clearer for macOS and Linux
  users running Bash, Git, and Python 3.10+.
- Added contribution, security, issue, and pull request guidance for public
  collaboration.
- Added release/archive guidance that prefers tracked source archives and avoids
  local caches, ignored generated artifacts, and secrets.

### For future agents

- Release checks now include a changelog gate for reusable Agent Continuity surfaces.
  Add a `CHANGELOG.md` entry when installer, scaffold, skill, reusable guide, or
  public command behavior changes.
- Use `Change-Record: not-needed` in commit or PR text only when an
  adopter-facing path changed without changing adopter behavior.
- SPEC-0003 follow-up implementation is tracked in PLAN-0005 for manifest,
  doctor, dry-run upgrade, and tooling-only write mode, and PLAN-0006 for legacy
  baseline manifests and opt-in generated-view writes.

### Tooling changes

- Added retirement validation and smoke coverage for preview/write behavior,
  current-next bounds, exact and conflicting repeats, target-path atomic
  no-overwrite publication, path containment, live-reference and TODO exclusion,
  immutable link-rewrite sources, generated registries, and byte preservation
  through init, doctor, and docs update. Repository-wide concurrent allocation
  remains governed by exclusive branch and owner discipline rather than a
  global lock.
- Added `agent-continuity init ...` as the canonical initializer; `agent-docs`
  and `agent-docs-init` remain compatibility aliases.
- Added exit-code semantics for doctor/dry-run reports: `0` healthy/current,
  `1` warnings or actionable drift, and `2` invalid usage, refused, unknown, or
  incompatible shapes.
- Added manifest assertions to init/install smoke coverage and Python compile
  coverage for the new command entry point.
- Added doctor and upgrade dry-run smoke coverage to `scripts/release-check`.
- Added tooling-only upgrade write-mode smoke coverage for preview defaulting,
  write refusal, missing owned-file restore, manifest-clean tooling update,
  executable-bit repair, local drift refusal, symlink refusal, backups, and
  project-owned Markdown non-mutation.
- Hardened tooling-only write mode to refuse unsafe backup paths, non-directory
  parent path conflicts, and exact-mode drift before writing.
- Added smoke coverage for legacy manifest baseline preview/write behavior,
  existing-manifest refusal, empty-target refusal, missing/drifted/wrong-mode
  owned tooling refusal, symlink and hardlink refusal, and project-owned Markdown
  non-mutation.
- Added generated-view upgrade write smoke coverage for dry-run/no-write
  preservation, explicit opt-in regeneration, missing view recreation,
  unsupported generator refusal, malformed record refusal, unsafe path refusal,
  hand-edited drift refusal, generator failure, backups, audits, and manifest
  checksum updates.
- Added generated-view registration smoke coverage for fresh Agent Continuity document-tooling installs
  and baseline `--generated-views`.
- Added `scripts/changelog-check` for local and CI changelog enforcement.
- Added smoke coverage for changelog-required, changelog-present, internal-only,
  and explicit-exemption cases.
- Made `scripts/changelog-check` compatible with clean trees on macOS Bash 3.2.
