---
type: plan
document_format_version: 2
id: 01a02039-7a65-7639-9a50-fa737028f351
aliases:
  - "PLAN-0012"
title: Versioned UUID Document Identity
domain: agent-continuity
status: completed
created_at: "2026-08-21 01:46:46 JST +0900"
updated_at: "2026-08-21 02:41:52 JST +0900"
owner: Codex main agent
sequence:
  roadmap:
  sort_key:
  lane: agent-continuity
  after: []
  before: []
areas: []
related_ideas:
  - ../../ideas/IDEA-0003-federated-document-library-and-relationship-graph.md
related_specs: []
related_adrs: []
related_sessions:
  - ../../../session-logs/2026-08-20-spec-systems-and-ceremony-evaluation.md
related_issues: []
related_prs: []
linked_paths: []
repo_state:
  based_on_commit: d87ea088b643fce77d23d559c57b81a94344dec0
  last_reviewed_commit: 663934fe4f03b703db210fb6023b99cbe3619684
---

# PLAN-0012 - Versioned UUID Document Identity

## Goal

Move Agent Continuity documents from branch-conflicting numeric identity to a
versioned UUIDv7 document format without breaking existing repositories or
turning migration into an unreviewable bulk rewrite.

Fresh work must be UUID-native. New documents and freshly initialized
repositories receive a UUIDv7 canonical `id`, `aliases: []`, and a mutable
type-plus-slug filename. Numeric aliases exist only where migration or an
explicit legacy retirement record has historical identity to preserve.

## Architecture

Document format v2 separates four concerns:

- `id` is an immutable RFC UUIDv7 canonical identity.
- `aliases` contains old lookup handles preserved during migration; it is empty
  for fresh documents.
- the filename is a human locator such as `PLAN-versioned-document-identity.md`
  and can be renamed without changing identity.
- relationship and lifecycle fields remain in the Markdown frontmatter for this
  migration; graph normalization is separate work.

The reusable release, install-manifest schema, document format, and one-repo
migration receipt are independently versioned. The CLI reads document formats
v1 and v2 during the compatibility window. Generated registries resolve UUIDs
and aliases but display a migrated record's legacy alias where useful.

Migration is deliberately two-phase. A prepared JSON plan assigns UUIDs to
exact preimage hashes and inventories known worktrees. The plan must be
committed before apply. Apply accepts only the planned preimage or its exact
postimage, validates the whole result, and writes a receipt last.

## Task Dependencies / Parallelization

```text
dual-format reader + validator
            |
            +--> UUID-native new/init behavior
            |
            +--> committed migration plan/apply/receipt
            |
            +--> manifest v2 + doctor reporting
                         |
                         v
             self-migrate this repository
```

The reader and validator are the shared prerequisite. Generator, initializer,
migration, and doctor coverage can then be developed independently, but the
repository self-migration waits for all of them to pass.

## Implementation Tasks

- [x] Add document-format-v2 parsing, UUIDv7 validation, alias lookup, and
  ambiguity checks while retaining v1 reads.
- [x] Make every `docs new` family use UUIDv7 identity, `aliases: []`, and a
  type-plus-slug locator without allocating a numeric alias.
- [x] Make fresh repository initialization omit numbered example records and
  generated views, then UUID-bind any real starter records without aliases.
- [x] Add `format-status` and committed-plan `migrate-uuids` prepare/apply
  commands with hashes, worktree inventory, idempotence, and receipt-last
  semantics.
- [x] Add release `2026.08.21.1`, manifest schema v2, document-format target,
  and separate `doctor` findings for install metadata and project documents.
- [x] Commit the migration plan, self-migrate the existing corpus, regenerate
  views, and record completion evidence.

## Validation

- The structured-doc smoke test must prove that every fresh family is v2,
  UUIDv7, aliasless, and slug-named before adding fixture-only legacy aliases.
- The initializer smoke test must prove a complete fresh repository contains no
  numbered placeholder paths or aliases and reports zero v1/invalid documents.
- Migration tests must prove uncommitted-plan refusal, committed application,
  alias preservation, relationship preservation, idempotence, resumability,
  and byte preservation on preimage conflict.
- Doctor/upgrade tests must cover schema-v1 compatibility and independent
  document-format reporting.
- The repository-wide docs check, release check, and shell smoke suites must
  pass after self-migration and regenerated views.

## Completion Criteria

- Fresh documents and repositories never manufacture number-based aliases.
- Existing numeric identities remain resolvable after a deterministic,
  reviewable migration.
- A cold agent can distinguish release, manifest, document-format, and
  migration state without relying on this conversation.
- The Agent Continuity repository is itself migrated and all relevant checks
  pass from committed source.

## Completion Evidence

- Tooling foundation commit: `d87ea088b643fce77d23d559c57b81a94344dec0`
- Canonical migration-plan commit: `663934fe4f03b703db210fb6023b99cbe3619684`
- Migration ID: `01a02039-7a6a-78c6-ab78-480b3b5759b0`
- Migration-plan digest:
  `sha256:227b1b476ab9d4eeecffab8fe29f7b6b8301bd993f70ab1c4c3b6d927512cbc7`
- Result: 75 planned preimages became 75 exact postimages; 51 historical
  identities were retained as aliases and 24 formerly ID-less records remained
  aliasless.
- Post-migration format status: `v1: 0`, `v2: 75`, `invalid: 0`.
- Receipt:
  `.agent-continuity/migrations/document-format-v2.json.receipt.json`
- Generated views under `docs/` were regenerated after the corpus write.
- `doctor` now distinguishes `ready`, `in_progress`, and `completed` migration
  state from the canonical plan and full receipt; completion enforces v2-only
  authored records while permitting later content edits that preserve the
  planned UUID and historical aliases.
