#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
agent_continuity_docs="$repo_root/scripts/agent-continuity-docs"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

docs_root="$tmpdir/docs"
repo_commit="$(git -C "$repo_root" rev-parse HEAD)"
mkdir -p "$docs_root/architecture/areas"

run_meta() {
  "$agent_continuity_docs" --root "$docs_root" "$@"
}

run_meta_root() {
  local root="$1"
  shift
  "$agent_continuity_docs" --root "$root" "$@"
}

require_file() {
  if [[ ! -f "$1" ]]; then
    echo "Expected file does not exist: $1" >&2
    exit 1
  fi
}

require_absent() {
  if [[ -e "$1" ]]; then
    echo "Expected path to be absent: $1" >&2
    exit 1
  fi
}

require_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -Fq "$pattern" "$file"; then
    echo "Expected $file to contain: $pattern" >&2
    exit 1
  fi
}

require_not_contains() {
  local file="$1"
  local pattern="$2"
  if grep -Fq "$pattern" "$file"; then
    echo "Expected $file not to contain: $pattern" >&2
    exit 1
  fi
}

frontmatter_id() {
  awk '$1 == "id:" { print $2; exit }' "$1"
}

require_uuid7() {
  python3 - "$1" <<'PY'
import sys
import uuid

value = sys.argv[1]
try:
    parsed = uuid.UUID(value)
except ValueError as exc:
    raise SystemExit(f"Expected UUID, got {value!r}: {exc}")
if parsed.version != 7 or parsed.variant != uuid.RFC_4122:
    raise SystemExit(f"Expected RFC UUIDv7, got {value!r}")
PY
}

add_legacy_alias() {
  local path="$1"
  local alias="$2"
  perl -0pi -e 's/aliases: \[\]/aliases:\n  - '"$alias"'/' "$path"
}

idea_path="$(run_meta new idea "Repo Memory Timeline" --domain product)"
rsch_path="$(run_meta new research "Embedding Options Survey" --domain research)"
eval_path="$(run_meta new eval "Embedding Model Bakeoff" --domain repo-health)"
diag_path="$(run_meta new diag "Simulator Freeze Investigation" --domain repo-health)"
spec_path="$(run_meta new spec "Shared Capture Workflow" --domain product --spec-type improvement)"
plan_path="$(run_meta new plan "Shared Capture Implementation" --domain product --spec SPEC-0001)"

for fresh_path in "$idea_path" "$rsch_path" "$eval_path" "$diag_path" "$spec_path" "$plan_path"; do
  require_contains "$fresh_path" "document_format_version: 2"
  require_contains "$fresh_path" "aliases: []"
done
plan_uuid="$(frontmatter_id "$plan_path")"
require_uuid7 "$plan_uuid"
add_legacy_alias "$idea_path" IDEA-0001
add_legacy_alias "$rsch_path" RSCH-0001
add_legacy_alias "$eval_path" EVAL-0001
add_legacy_alias "$diag_path" DIAG-0001
add_legacy_alias "$spec_path" SPEC-0001
add_legacy_alias "$plan_path" PLAN-0001

impl_path="$(run_meta new impl "Persist Capture Drafts" --domain product --plan PLAN-0001 --spec SPEC-0001)"
adr_path="$(run_meta new adr "Use Append Only Journal" --domain architecture --spec SPEC-0001)"
lrn_path="$(run_meta new learning "Specs And Plans Stay Separate" --domain repo-health)"
expl_path="$(run_meta new explainer "Specs Plans And Briefs" --domain orientation)"
qst_path="$(run_meta new question "Should Specs And Plans Be One To One" --domain repo-health)"
conc_path="$(run_meta new concept "Selections Snapshots And Dynamic Sections" --domain product)"
audit_path="$(run_meta new audit "Docs System Migration Baseline Audit" --kind docs-health --domain repo-health)"
completed_audit_path="$(run_meta new audit "Completed Roadmap Alignment Audit" --kind roadmap-alignment --status completed --domain repo-health)"

for fresh_path in "$impl_path" "$adr_path" "$lrn_path" "$expl_path" "$qst_path" "$conc_path" "$audit_path" "$completed_audit_path"; do
  require_contains "$fresh_path" "document_format_version: 2"
  require_contains "$fresh_path" "aliases: []"
done
add_legacy_alias "$impl_path" IMPL-0001-01
add_legacy_alias "$adr_path" ADR-0001
add_legacy_alias "$lrn_path" LRN-0001
add_legacy_alias "$expl_path" EXPL-0001
add_legacy_alias "$qst_path" QST-0001
add_legacy_alias "$conc_path" CONC-0001
add_legacy_alias "$audit_path" AUDT-0001
add_legacy_alias "$completed_audit_path" AUDT-0002

if run_meta new audit "Audit Without CLI Kind" --domain repo-health >$tmpdir/docs-meta-new-audit-without-kind.out 2>&1; then
  echo "Expected agent-continuity docs new audit without --kind to fail" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-new-audit-without-kind.out "required for audit docs"

require_file "$idea_path"
require_file "$rsch_path"
require_file "$eval_path"
require_file "$diag_path"
require_file "$spec_path"
require_file "$plan_path"
require_file "$impl_path"
require_file "$adr_path"
require_file "$lrn_path"
require_file "$expl_path"
require_file "$qst_path"
require_file "$conc_path"
require_file "$audit_path"
require_file "$completed_audit_path"

if [[ "$audit_path" != *"/AUDT-docs-system-migration-baseline-audit.md" ]]; then
  echo "Expected new audit path to use a type-plus-slug locator, got $audit_path" >&2
  exit 1
fi

idea_uuid="$(frontmatter_id "$idea_path")"
require_uuid7 "$idea_uuid"
require_uuid7 "$plan_uuid"
require_contains "$idea_path" "document_format_version: 2"
require_contains "$idea_path" "  - IDEA-0001"
require_contains "$idea_path" "status: captured"
require_contains "$rsch_path" "  - RSCH-0001"
require_contains "$rsch_path" "type: research-survey"
require_contains "$rsch_path" "based_on_commit: $repo_commit"
require_contains "$eval_path" "  - EVAL-0001"
eval_uuid="$(frontmatter_id "$eval_path")"
require_contains "$eval_path" "artifact_root: artifacts/evaluations/$eval_uuid/"
require_contains "$eval_path" "based_on_commit: $repo_commit"
require_contains "$diag_path" "  - DIAG-0001"
require_contains "$diag_path" "status: investigating"
diag_uuid="$(frontmatter_id "$diag_path")"
require_contains "$diag_path" "artifact_root: artifacts/diagnostics/$diag_uuid/"
require_contains "$diag_path" "safe_to_commit: false"
require_contains "$diag_path" "raw_artifacts_local_only: []"
require_contains "$diag_path" "based_on_commit: $repo_commit"
require_contains "$spec_path" "  - SPEC-0001"
require_contains "$spec_path" "superseded_by: []"
require_contains "$plan_path" "related_prs: []"
require_contains "$impl_path" "parent_plan: PLAN-0001"
require_contains "$impl_path" "related_prs: []"
require_contains "$adr_path" "status: proposed"
require_contains "$adr_path" "related_prs: []"
require_contains "$lrn_path" "  - LRN-0001"
require_contains "$lrn_path" "status: active"
require_contains "$lrn_path" "learning_type: lesson"
require_contains "$expl_path" "  - EXPL-0001"
require_contains "$expl_path" "type: explainer"
require_contains "$expl_path" "explainer_type: concept"
require_contains "$qst_path" "  - QST-0001"
require_contains "$qst_path" "status: open"
require_contains "$qst_path" "question_type: product"
require_contains "$conc_path" "  - CONC-0001"
require_contains "$conc_path" "type: concept"
require_contains "$conc_path" "concept_type: domain-model"
require_contains "$audit_path" "  - AUDT-0001"
require_contains "$audit_path" "type: repo-health-audit"
require_contains "$audit_path" "audit_kind: docs-health"
require_contains "$audit_path" "status: planned"
require_contains "$completed_audit_path" "  - AUDT-0002"
require_contains "$completed_audit_path" "status: completed"
require_contains "$completed_audit_path" "audit_started_at: \""
require_contains "$completed_audit_path" "audit_ended_at: \""

retirement_id="IMPL-0001-02"
retirement_path="$docs_root/id-retirements/$retirement_id.md"
retirement_reason="The implementation slice was withdrawn before creation."
retirement_source_type="codex-task"
retirement_source_link="codex://threads/retirement-smoke"

if run_meta retire-id IMPL-0001-03 --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" \
  >$tmpdir/docs-meta-retire-future.out 2>&1; then
  echo "Expected retirement beyond the current next IMPL ID to fail" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-future.out "current next IMPL ID"
require_absent "$retirement_path"

for missing_case in reason source-type provenance; do
  case "$missing_case" in
    reason)
      retire_args=(--plan PLAN-0001 --source-type "$retirement_source_type" --source-link "$retirement_source_link")
      ;;
    source-type)
      retire_args=(--plan PLAN-0001 --reason "$retirement_reason" --source-link "$retirement_source_link")
      ;;
    provenance)
      retire_args=(--plan PLAN-0001 --reason "$retirement_reason" --source-type "$retirement_source_type")
      ;;
  esac
  if run_meta retire-id "$retirement_id" "${retire_args[@]}" >"$tmpdir/docs-meta-retire-missing-$missing_case.out" 2>&1; then
    echo "Expected retirement without $missing_case to fail" >&2
    exit 1
  fi
done
require_absent "$retirement_path"

if run_meta retire-id "$retirement_id" --plan PLAN-9999 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" \
  >$tmpdir/docs-meta-retire-missing-plan.out 2>&1; then
  echo "Expected retirement with a missing parent plan to fail" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-missing-plan.out "live primary plan"

if run_meta retire-id IMPL-0002-01 --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" \
  >$tmpdir/docs-meta-retire-plan-number.out 2>&1; then
  echo "Expected retirement with a mismatched plan number to fail" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-plan-number.out "does not match"

collision_path="$docs_root/collision-$retirement_id.md"
printf '# scanner collision\n' >"$collision_path"
if run_meta retire-id "$retirement_id" --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" \
  >$tmpdir/docs-meta-retire-collision.out 2>&1; then
  echo "Expected scanner-recognized retirement collision to fail" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-collision.out "collision"
require_absent "$retirement_path"
rm "$collision_path"

run_meta retire-id "$retirement_id" --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" \
  >$tmpdir/docs-meta-retire-preview.out
require_contains $tmpdir/docs-meta-retire-preview.out "PREVIEW"
require_contains $tmpdir/docs-meta-retire-preview.out "$retirement_path"
require_absent "$retirement_path"

run_meta retire-id "$retirement_id" --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" --write \
  >$tmpdir/docs-meta-retire-write.out
require_file "$retirement_path"
require_contains "$retirement_path" "type: id-retirement"
require_contains "$retirement_path" "document_format_version: 2"
require_uuid7 "$(frontmatter_id "$retirement_path")"
require_contains "$retirement_path" "  - $retirement_id"
require_contains "$retirement_path" "status: retired"
require_contains "$retirement_path" "parent_plan: PLAN-0001"
require_contains "$retirement_path" "reason: \"$retirement_reason\""
require_contains "$retirement_path" "type: \"$retirement_source_type\""
require_contains "$retirement_path" "link: \"$retirement_source_link\""

perl -0pi -e 's/created_at: "[^"]+"/created_at: "2025-01-01 00:00:00 JST +0900"/' "$retirement_path"
retirement_hash_before="$(shasum -a 256 "$retirement_path")"
run_meta retire-id "$retirement_id" --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" --write \
  >$tmpdir/docs-meta-retire-idempotent.out
retirement_hash_after="$(shasum -a 256 "$retirement_path")"
if [[ "$retirement_hash_before" != "$retirement_hash_after" ]]; then
  echo "Expected exact retirement repeat to preserve bytes" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-idempotent.out "ALREADY RETIRED"

if run_meta retire-id "$retirement_id" --plan PLAN-0001 --reason "Different reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" --write \
  >$tmpdir/docs-meta-retire-conflict.out 2>&1; then
  echo "Expected conflicting retirement repeat to fail" >&2
  exit 1
fi
if [[ "$retirement_hash_before" != "$(shasum -a 256 "$retirement_path")" ]]; then
  echo "Expected conflicting retirement repeat to preserve bytes" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-conflict.out "conflicts"

cat >>"$retirement_path" <<'RETIREMENT_FIXTURES'

## Immutable fixture content

- [ ] TODO-9998 [blocked] Tombstone-only todo must never enter live work surfaces
- [Spec](/product/specs/SPEC-shared-capture-workflow.md)
- [Exact immutable target](../link-fixtures/immutable-target.md)
- [Nested immutable target](../link-fixtures/immutable-dir/nested.md)
RETIREMENT_FIXTURES

run_meta show "$retirement_id" >$tmpdir/docs-meta-retire-show.out
require_contains $tmpdir/docs-meta-retire-show.out "Tombstone-only todo"
run_meta status "$retirement_id" >$tmpdir/docs-meta-retire-status.out
require_contains $tmpdir/docs-meta-retire-status.out "$retirement_id"

next_todo_without_tombstone="$(run_meta next todo)"
if [[ "$next_todo_without_tombstone" != "TODO-0001" ]]; then
  echo "Expected tombstone TODO to leave next TODO at TODO-0001, got $next_todo_without_tombstone" >&2
  exit 1
fi
run_meta todos --all >$tmpdir/docs-meta-retire-global-todos.out
require_not_contains $tmpdir/docs-meta-retire-global-todos.out "Tombstone-only todo"
if ! run_meta check-todos >$tmpdir/docs-meta-retire-check-todos.out 2>&1; then
  cat $tmpdir/docs-meta-retire-check-todos.out >&2
  echo "Expected check-todos to ignore tombstone TODOs" >&2
  exit 1
fi
run_meta review >$tmpdir/docs-meta-retire-review.out
require_not_contains $tmpdir/docs-meta-retire-review.out "Tombstone-only todo"

next_impl="$(run_meta next impl --plan PLAN-0001)"
if [[ "$next_impl" != "IMPL-0001-03" ]]; then
  echo "Expected tombstone to advance next IMPL ID to IMPL-0001-03, got $next_impl" >&2
  exit 1
fi
impl_after_retirement="$(run_meta new impl "Continue Capture Work" --domain product --plan PLAN-0001)"
if [[ "$impl_after_retirement" != *"/IMPL-continue-capture-work.md" ]]; then
  echo "Expected new impl after retirement to use a type-plus-slug locator, got $impl_after_retirement" >&2
  exit 1
fi
require_contains "$impl_after_retirement" "aliases: []"
require_uuid7 "$(frontmatter_id "$impl_after_retirement")"

retired_reference_fixture="$docs_root/retired-reference-fixture.md"
cat >"$retired_reference_fixture" <<EOF
- [ ] TODO-9001 [ready] [skill:docs-writer] [plan:PLAN-0001] [brief:$retirement_id] Retired brief must not satisfy a live reference
EOF
if run_meta check-todos >$tmpdir/docs-meta-retired-reference.out 2>&1; then
  echo "Expected a tombstone not to satisfy a live brief reference" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retired-reference.out "references missing brief $retirement_id"
rm "$retired_reference_fixture"

if run_meta set-status "$retirement_id" archived >$tmpdir/docs-meta-retire-set-status.out 2>&1; then
  echo "Expected set-status to refuse id-retirement tombstones" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-set-status.out "immutable"
if run_meta move "id-retirements/$retirement_id.md" "id-retirements/$retirement_id-moved.md" --write \
  >$tmpdir/docs-meta-retire-move.out 2>&1; then
  echo "Expected docs move --write to refuse an id-retirement source" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-move.out "immutable"
require_file "$retirement_path"

retirement_hash_before_directory_move="$(shasum -a 256 "$retirement_path")"
if run_meta move id-retirements relocated-retirements --write \
  >$tmpdir/docs-meta-retire-directory-move.out 2>&1; then
  echo "Expected docs move --write to refuse a directory containing an id-retirement tombstone" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-directory-move.out "immutable"
if [[ "$retirement_hash_before_directory_move" != "$(shasum -a 256 "$retirement_path")" ]]; then
  echo "Expected refused retirement directory move to preserve tombstone bytes" >&2
  exit 1
fi

collision_path="$docs_root/another-$retirement_id.md"
printf '# scanner collision\n' >"$collision_path"
if run_meta check >$tmpdir/docs-meta-retire-check-collision.out 2>&1; then
  echo "Expected docs check to reject scanner-recognized retirement collision" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-check-collision.out "collision"
rm "$collision_path"

attack_plan_rel="product/plans/PLAN-0001-attack/PLAN-0001-attack.md"
make_attack_root() {
  local root="$1"
  mkdir -p "$root/$(dirname "$attack_plan_rel")"
  cp "$plan_path" "$root/$attack_plan_rel"
  cp "$impl_path" "$root/$(dirname "$attack_plan_rel")/$(basename "$impl_path")"
}

malformed_repeat_root="$tmpdir/malformed-repeat-root"
make_attack_root "$malformed_repeat_root"
mkdir -p "$malformed_repeat_root/id-retirements"
malformed_repeat_path="$malformed_repeat_root/id-retirements/$retirement_id.md"
cat >"$malformed_repeat_path" <<EOF
---
type: id-retirement
title: Retired ID $retirement_id
status: retired
parent_plan: PLAN-0001
reason: "$retirement_reason"
source:
  type: "$retirement_source_type"
  link: "$retirement_source_link"
  notes: ""
created_at: "2026-08-16 00:00:00 JST +0900"
updated_at: "2026-08-16 00:00:00 JST +0900"
repo_state:
  based_on_commit:
  last_reviewed_commit:
---

# Retired ID $retirement_id
EOF
malformed_repeat_hash="$(shasum -a 256 "$malformed_repeat_path")"
if run_meta_root "$malformed_repeat_root" retire-id "$retirement_id" --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" --write \
  >$tmpdir/docs-meta-retire-malformed-repeat.out 2>&1; then
  echo "Expected malformed existing tombstone to fail instead of returning ALREADY RETIRED" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-malformed-repeat.out "invalid"
if [[ "$malformed_repeat_hash" != "$(shasum -a 256 "$malformed_repeat_path")" ]]; then
  echo "Expected malformed existing tombstone bytes to remain unchanged" >&2
  exit 1
fi

symlink_root_real="$tmpdir/symlink-root-real"
make_attack_root "$symlink_root_real"
ln -s "$symlink_root_real" "$tmpdir/symlink-docs-root"
if run_meta_root "$tmpdir/symlink-docs-root" retire-id "$retirement_id" --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" --write \
  >$tmpdir/docs-meta-retire-symlink-root.out 2>&1; then
  echo "Expected a symlinked docs root to be refused" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-symlink-root.out "symlinked docs root"
require_absent "$symlink_root_real/id-retirements/$retirement_id.md"

symlink_parent_root="$tmpdir/symlink-parent-root"
make_attack_root "$symlink_parent_root"
mkdir -p "$tmpdir/outside-retirements"
ln -s "$tmpdir/outside-retirements" "$symlink_parent_root/id-retirements"
if run_meta_root "$symlink_parent_root" retire-id "$retirement_id" --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" --write \
  >$tmpdir/docs-meta-retire-symlink-parent.out 2>&1; then
  echo "Expected a symlinked id-retirements component to be refused" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-symlink-parent.out "symlinked id-retirements"
require_absent "$tmpdir/outside-retirements/$retirement_id.md"

non_directory_root="$tmpdir/non-directory-root"
make_attack_root "$non_directory_root"
printf 'not a directory\n' >"$non_directory_root/id-retirements"
if run_meta_root "$non_directory_root" retire-id "$retirement_id" --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" --write \
  >$tmpdir/docs-meta-retire-non-directory.out 2>&1; then
  echo "Expected a non-directory id-retirements parent to be refused" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-non-directory.out "not a directory"

target_symlink_root="$tmpdir/target-symlink-root"
make_attack_root "$target_symlink_root"
mkdir -p "$target_symlink_root/id-retirements"
printf 'outside sentinel\n' >"$tmpdir/outside-target"
ln -s "$tmpdir/outside-target" "$target_symlink_root/id-retirements/$retirement_id.md"
if run_meta_root "$target_symlink_root" retire-id "$retirement_id" --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" --write \
  >$tmpdir/docs-meta-retire-target-symlink.out 2>&1; then
  echo "Expected a symlink tombstone target to be refused" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-target-symlink.out "target symlink"
require_contains "$tmpdir/outside-target" "outside sentinel"

target_fifo_root="$tmpdir/target-fifo-root"
make_attack_root "$target_fifo_root"
mkdir -p "$target_fifo_root/id-retirements"
mkfifo "$target_fifo_root/id-retirements/$retirement_id.md"
if run_meta_root "$target_fifo_root" retire-id "$retirement_id" --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" --write \
  >$tmpdir/docs-meta-retire-target-fifo.out 2>&1; then
  echo "Expected a non-regular tombstone target to be refused" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-target-fifo.out "not a regular file"

target_regular_root="$tmpdir/target-regular-root"
make_attack_root "$target_regular_root"
mkdir -p "$target_regular_root/id-retirements"
printf 'project-authored content\n' >"$target_regular_root/id-retirements/$retirement_id.md"
target_regular_hash="$(shasum -a 256 "$target_regular_root/id-retirements/$retirement_id.md")"
if run_meta_root "$target_regular_root" retire-id "$retirement_id" --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-link "$retirement_source_link" --write \
  >$tmpdir/docs-meta-retire-target-regular.out 2>&1; then
  echo "Expected a conflicting regular tombstone target to be refused" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-target-regular.out "conflicts"
if [[ "$target_regular_hash" != "$(shasum -a 256 "$target_regular_root/id-retirements/$retirement_id.md")" ]]; then
  echo "Expected conflicting regular target bytes to remain unchanged" >&2
  exit 1
fi

atomic_publish_root="$tmpdir/atomic-publish-root"
mkdir -p "$atomic_publish_root/id-retirements"
python3 - "$repo_root/scripts/agent-continuity-docs" "$atomic_publish_root/id-retirements" "$retirement_id" <<'PY'
import pathlib
import runpy
import sys

api = runpy.run_path(sys.argv[1])
retirements_dir = pathlib.Path(sys.argv[2])
target = retirements_dir / f"{sys.argv[3]}.md"
concurrent_content = b"concurrent complete tombstone\n"

def publish_competitor() -> None:
    target.write_bytes(concurrent_content)

try:
    api["exclusive_publish_retirement"](
        retirements_dir,
        target,
        b"staged complete tombstone\n",
        publish_competitor,
    )
except SystemExit as exc:
    if "appeared during publication" not in str(exc):
        raise
else:
    raise SystemExit("Expected exclusive publication to refuse a concurrent target")

if target.read_bytes() != concurrent_content:
    raise SystemExit("Exclusive publication overwrote the concurrent target")
if list(retirements_dir.glob(".*.tmp")):
    raise SystemExit("Exclusive publication left a staging file after refusal")
PY

notes_only_root="$tmpdir/notes-only-root"
make_attack_root "$notes_only_root"
run_meta_root "$notes_only_root" retire-id "$retirement_id" --plan PLAN-0001 --reason "$retirement_reason" \
  --source-type "$retirement_source_type" --source-notes "Reviewed retirement evidence" --write \
  >$tmpdir/docs-meta-retire-notes-only.out
require_file "$notes_only_root/id-retirements/$retirement_id.md"
require_contains "$notes_only_root/id-retirements/$retirement_id.md" "notes: \"Reviewed retirement evidence\""

mkdir -p "$tmpdir/app/src"
touch "$tmpdir/app/src/todo.ts"

perl -0pi -e 's/linked_paths: \[\]/linked_paths:\n  - app\/src\/todo.ts/' "$plan_path"

cat > "$docs_root/architecture/areas/AREA-capture.md" <<'AREA'
---
type: architecture-area
id: AREA-capture
title: Capture
status: active
created_at: "2026-04-25 10:00:00 JST +0900"
updated_at: "2026-04-25 10:00:00 JST +0900"
owners: []
repo_state:
  based_on_commit:
  last_reviewed_commit:
---

# AREA-capture - Capture

- [ ] Define owner boundaries
AREA

cat >> "$plan_path" <<'TODOS'

## Structured Todo Smoke

- [ ] TODO-0001 [ready] [owner:main-agent] [skill:docs-writer] [plan:PLAN-0001] Define stable todo model
- [ ] TODO-0002 [blocked] [owner:main-agent] [skill:docs-writer] [plan:PLAN-0001] [brief:IMPL-0001-01] [blocker:TODO-0001] Wire todo checks
- [x] TODO-0003 [done] [owner:main-agent] [skill:docs-writer] [plan:PLAN-0001] [verification:tests/agent-continuity-docs-smoke.sh] Document todo workflow
- [ ] TODO-0004 [in_progress] [owner:main-agent] [agent:smoke-agent] [updated:2026-04-25 10:20:00 JST +0900] [skill:docs-writer] [plan:PLAN-0001] Claim todo work
- [ ] Follow up on TODO-0001 in review notes
- [ ] Local task with a | pipe

```text
- [ ] TODO-9999 [bogus] This example should not be parsed.
```
TODOS

mkdir -p "$docs_root/repo-health/audits"
cat > "$docs_root/repo-health/audits/AUDT-0003-repo-health-audit.md" <<'AUDIT'
---
type: repo-health-audit
id: AUDT-0003
title: Repo Health Audit
status: completed
audit_kind: docs-health
created_at: "2026-04-25 10:00:00 JST +0900"
updated_at: "2026-04-25 10:30:00 JST +0900"
audit_started_at: "2026-04-25 10:00:00 JST +0900"
audit_ended_at: "2026-04-25 10:30:00 JST +0900"
timezone: "JST +0900"
auditor: smoke-test
scope:
  - docs
  - metadata
checks:
  - agent-continuity docs check
  - agent-continuity docs health --write
related_issues: []
related_prs: []
repo_state:
  based_on_commit:
  last_reviewed_commit:
next_audit_due:
---

# 2026-04-25 - Repo Health Audit

## Findings

| ID | Severity | Status | Finding | Route | Follow-up | Resolution |
|---|---|---|---|---|---|---|
| FINDING-001 | high | open | Review queue is not generated yet | PLAN | PLAN-0001 |  |
| FINDING-002 | medium | routed | Diagnostic follow-up is missing | DIAG | DIAG-9999 |  |
| FINDING-003 | low | accepted-risk | Legacy naming remains inconsistent | none |  | Accepted by owner:docs because migration churn is not worth it |
| FINDING-004 | info | resolved | Generated docs were refreshed | none |  | Verified with agent-continuity docs update |
| FINDING-005 | low | routed | Blocked todo should stay visible | TODO | TODO-0002 |  |
| FINDING-006 | medium | routed | Stale plan should stay visible | PLAN | PLAN-0001 |  |
| FINDING-007 | low | deferred | Deferred finding should be reviewed later | none |  | Deferred because this is low risk; revisit after next planning pass |
| FINDING-008 | medium | routed | Markdown follow-up fragment is missing | PLAN | [Plan](../../product/plans/PLAN-shared-capture-implementation/PLAN-shared-capture-implementation.md#missing-anchor) |  |
| FINDING-009 | medium | open | Medium finding should not be grouped as high priority | PLAN | PLAN-0001 |  |
| FINDING-010 | medium | routed | Freeform routed follow-up should stay visible | PLAN | Someone should look into this |  |
| FINDING-011 | medium | routed | Markdown follow-up title should still resolve | PLAN | [Plan](../../product/plans/PLAN-shared-capture-implementation/PLAN-shared-capture-implementation.md#shared-capture-implementation "Open plan") |  |
| FINDING-012 | low | routed | External Markdown issue link should be accepted | PLAN | [Issue](https://github.com/owensantoso/agent-continuity/issues/1 "Issue") |  |
| FINDING-013 | medium | routed | Route mismatch should stay visible | DIAG | PLAN-0001 |  |
| FINDING-014 | medium | routed | Retired brief must not resolve as live work | IMPL | IMPL-0001-02 |  |

```md
| ID | Severity | Status | Finding | Route | Follow-up | Resolution |
|---|---|---|---|---|---|---|
| FINDING-999 | high | open | Fenced examples must not parse | PLAN | PLAN-9999 |  |
```
AUDIT

cat > "$docs_root/repo-health/audits/AUDT-0004-invalid-audit.md" <<'BADAUDIT'
---
type: repo-health-audit
id: AUDT-0004
title: Invalid Audit
status: completed
audit_kind: docs-health
created_at: "2026-04-26 10:00:00 JST +0900"
updated_at: "2026-04-26 10:30:00 JST +0900"
audit_started_at: "2026-04-26 10:00:00 JST +0900"
audit_ended_at: "2026-04-26 10:30:00 JST +0900"
timezone: "JST +0900"
auditor: smoke-test
scope:
  - docs
checks:
  - agent-continuity docs review
repo_state:
  based_on_commit:
  last_reviewed_commit:
---

# 2026-04-26 - Invalid Audit

| ID | Severity | Status | Finding | Route | Follow-up | Resolution |
|---|---|---|---|---|---|---|
| FINDING-001 | urgent | open | Invalid severity should be reported | PLAN | PLAN-0001 |  |
| FINDING-001 | low | archived | Duplicate and archived without reason | none |  |  |
| FINDING-002 | medium | nonsense | Invalid status should be grouped before open findings | none |  |  |
| FINDING-003 | low | accepted-risk | Accepted risk with route is invalid | PLAN | PLAN-0001 | Accepted by owner:docs for now |
| FINDING-004 | low | deferred | Deferred risk lacks a revisit trigger | none |  | Deferred for later |
| FINDING-005 | low | accepted-risk | Accepted risk lacks rationale | none |  | owner:docs |
| FINDING-006 | low | open | Malformed row has SECRET-AUDIT-PAYLOAD and an unescaped | pipe | PLAN | PLAN-0001 |  |
| FINDING-007 | high | open | Row after malformed row should still parse | PLAN | PLAN-0001 |  |
BADAUDIT

next_idea="$(run_meta next idea)"
if [[ "$next_idea" != "IDEA-0002" ]]; then
  echo "Expected next IDEA-0002, got $next_idea" >&2
  exit 1
fi

next_adr="$(run_meta next adr)"
if [[ "$next_adr" != "ADR-0002" ]]; then
  echo "Expected next ADR-0002, got $next_adr" >&2
  exit 1
fi

next_rsch="$(run_meta next rsch)"
if [[ "$next_rsch" != "RSCH-0002" ]]; then
  echo "Expected next RSCH-0002, got $next_rsch" >&2
  exit 1
fi

next_eval="$(run_meta next eval)"
if [[ "$next_eval" != "EVAL-0002" ]]; then
  echo "Expected next EVAL-0002, got $next_eval" >&2
  exit 1
fi

next_diag="$(run_meta next diag)"
if [[ "$next_diag" != "DIAG-0002" ]]; then
  echo "Expected next DIAG-0002, got $next_diag" >&2
  exit 1
fi

next_lrn="$(run_meta next lrn)"
if [[ "$next_lrn" != "LRN-0002" ]]; then
  echo "Expected next LRN-0002, got $next_lrn" >&2
  exit 1
fi

next_expl="$(run_meta next expl)"
if [[ "$next_expl" != "EXPL-0002" ]]; then
  echo "Expected next EXPL-0002, got $next_expl" >&2
  exit 1
fi

next_qst="$(run_meta next qst)"
if [[ "$next_qst" != "QST-0002" ]]; then
  echo "Expected next QST-0002, got $next_qst" >&2
  exit 1
fi

next_conc="$(run_meta next conc)"
if [[ "$next_conc" != "CONC-0002" ]]; then
  echo "Expected next CONC-0002, got $next_conc" >&2
  exit 1
fi

next_audt="$(run_meta next audt)"
if [[ "$next_audt" != "AUDT-0005" ]]; then
  echo "Expected next AUDT-0005, got $next_audt" >&2
  exit 1
fi

next_todo="$(run_meta next todo)"
if [[ "$next_todo" != "TODO-0005" ]]; then
  echo "Expected next TODO-0005, got $next_todo" >&2
  exit 1
fi

run_meta set-status ADR-0001 accepted >/dev/null
require_contains "$adr_path" "status: accepted"
run_meta set-status IDEA-0001 exploring >/dev/null
require_contains "$idea_path" "status: exploring"
run_meta set-status LRN-0001 draft >/dev/null
require_contains "$lrn_path" "status: draft"
run_meta set-status DIAG-0001 resolved >/dev/null
require_contains "$diag_path" "status: resolved"
run_meta set-status PLAN-0001 ready >/dev/null
perl -0pi -e 's/updated_at: "[^"]+"/updated_at: "2026-01-01 00:00:00 JST +0900"/' "$plan_path" "$qst_path"

run_meta review >$tmpdir/docs-meta-review.out
expected_finding_line="$(grep -n '^| FINDING-001 | high | open' "$docs_root/repo-health/audits/AUDT-0003-repo-health-audit.md" | cut -d: -f1)"
require_contains $tmpdir/docs-meta-review.out "FINDING-001"
require_contains $tmpdir/docs-meta-review.out "FINDING-007"
require_contains $tmpdir/docs-meta-review.out "Review queue is not generated yet"
require_contains $tmpdir/docs-meta-review.out "missing-follow-up"
require_contains $tmpdir/docs-meta-review.out "DIAG-9999"
require_contains $tmpdir/docs-meta-review.out "TODO-0002"
require_contains $tmpdir/docs-meta-review.out "PLAN-0001"
require_contains $tmpdir/docs-meta-review.out "QST-0001"
require_contains $tmpdir/docs-meta-review.out "blocked-follow-up"
require_contains $tmpdir/docs-meta-review.out "stale-follow-up"
require_contains $tmpdir/docs-meta-review.out "invalid-follow-up"
require_contains $tmpdir/docs-meta-review.out "missing-anchor"
require_contains $tmpdir/docs-meta-review.out "Someone should look into this"
require_contains $tmpdir/docs-meta-review.out "Route DIAG does not match follow-up PLAN-0001"
require_contains $tmpdir/docs-meta-review.out "Missing follow-up IMPL-0001-02"
require_contains $tmpdir/docs-meta-review.out "Other open audit findings"
if grep -Fq "Other review items" $tmpdir/docs-meta-review.out; then
  echo "Expected every smoke review item to be grouped into a known urgency bucket" >&2
  exit 1
fi
if grep -Fq "FINDING-999" $tmpdir/docs-meta-review.out; then
  echo "Expected review parser to ignore fenced audit table examples" >&2
  exit 1
fi
run_meta review --stale-days 1 >$tmpdir/docs-meta-review-due.out
require_contains $tmpdir/docs-meta-review-due.out "due-review"
require_contains $tmpdir/docs-meta-review-due.out "FINDING-003"
require_contains $tmpdir/docs-meta-review-due.out "FINDING-007"
first_review_line="$(awk 'NF { print; exit }' "$tmpdir/docs-meta-review.out")"
if [[ "$first_review_line" != "Invalid audit finding rows" ]]; then
  echo "Expected review output to group invalid findings first, got: $first_review_line" >&2
  exit 1
fi
run_meta review --type audit-findings --severity high >$tmpdir/docs-meta-review-high.out
require_contains $tmpdir/docs-meta-review-high.out "FINDING-001"
if grep -Fq "FINDING-002" $tmpdir/docs-meta-review-high.out; then
  echo "Expected high severity review filter to exclude medium findings" >&2
  exit 1
fi
run_meta review --json >$tmpdir/docs-meta-review.json
require_contains $tmpdir/docs-meta-review.json "\"reference\": \"repo-health/audits/AUDT-0003-repo-health-audit.md#FINDING-001\""
require_contains $tmpdir/docs-meta-review.json "\"source\": \"repo-health/audits/AUDT-0003-repo-health-audit.md:$expected_finding_line\""
require_contains $tmpdir/docs-meta-review.json "\"code\": \"invalid-audit-finding\""
require_contains $tmpdir/docs-meta-review.json "\"message\": \"Invalid severity 'urgent'\""
require_contains $tmpdir/docs-meta-review.json "\"message\": \"Malformed audit finding row\""
if grep -Fq "SECRET-AUDIT-PAYLOAD" $tmpdir/docs-meta-review.json; then
  echo "Expected malformed audit row detail to avoid raw sensitive payloads" >&2
  exit 1
fi
if grep -Fq "\"route\": \"pipe\"" $tmpdir/docs-meta-review.json || grep -Fq "\"follow_up\": \"PLAN\"" $tmpdir/docs-meta-review.json; then
  echo "Expected malformed audit row shifted cells not to leak via route or follow_up" >&2
  exit 1
fi
if grep -Fq "Invalid route 'pipe'" $tmpdir/docs-meta-review.json; then
  echo "Expected malformed audit rows not to emit shifted validation noise" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-review.json "\"code\": \"duplicate-audit-finding\""
require_contains $tmpdir/docs-meta-review.json "\"code\": \"stale-doc\""
require_contains $tmpdir/docs-meta-review.json "\"code\": \"blocked-follow-up\""
require_contains $tmpdir/docs-meta-review.json "\"message\": \"Accepted risk must use Route = none\""
require_contains $tmpdir/docs-meta-review.json "\"message\": \"Deferred finding needs reason and revisit trigger\""
require_contains $tmpdir/docs-meta-review.json "\"message\": \"Accepted risk needs rationale and owner\""
require_contains $tmpdir/docs-meta-review.json "\"message\": \"Invalid follow-up fragment #missing-anchor\""
require_contains $tmpdir/docs-meta-review.json "\"message\": \"Invalid follow-up target Someone should look into this\""
require_contains $tmpdir/docs-meta-review.json "\"message\": \"Route DIAG does not match follow-up PLAN-0001\""
if grep -Fq "Invalid follow-up fragment #plan-0001-shared-capture-implementation" $tmpdir/docs-meta-review.json; then
  echo "Expected Markdown follow-up links with optional titles to resolve" >&2
  exit 1
fi
if grep -Fq "Missing follow-up [Issue](https://github.com/owensantoso/agent-continuity/issues/1" $tmpdir/docs-meta-review.json; then
  echo "Expected external Markdown issue links to be accepted" >&2
  exit 1
fi
run_meta set-status PLAN-0001 draft >/dev/null

retirement_hash_before_update="$(shasum -a 256 "$retirement_path")"
run_meta update
if [[ "$retirement_hash_before_update" != "$(shasum -a 256 "$retirement_path")" ]]; then
  echo "Expected docs update to preserve project-owned tombstone bytes" >&2
  exit 1
fi
require_file "$docs_root/IDEAS.md"
require_file "$docs_root/SPECS.md"
require_file "$docs_root/LEARNINGS.md"
require_file "$docs_root/EXPLAINERS.md"
require_file "$docs_root/QUESTIONS.md"
require_file "$docs_root/CONCEPTS.md"
require_file "$docs_root/DOCS-REGISTRY.md"
require_file "$docs_root/TODOS.md"
require_file "$docs_root/AREAS.md"
require_file "$docs_root/AUDITS.md"
require_file "$docs_root/ROADMAP-VIEW.md"
require_contains "$docs_root/IDEAS.md" "IDEA-0001"
require_contains "$docs_root/AREAS.md" "AREA-capture"
require_contains "$docs_root/AUDITS.md" "AUDT-0001"
require_contains "$docs_root/AUDITS.md" "AUDT-0003"
require_contains "$docs_root/AUDITS.md" "Repo Health Audit"
require_contains "$docs_root/LEARNINGS.md" "LRN-0001"
require_contains "$docs_root/LEARNINGS.md" "Specs And Plans Stay Separate"
require_contains "$docs_root/EXPLAINERS.md" "EXPL-0001"
require_contains "$docs_root/EXPLAINERS.md" "Specs Plans And Briefs"
require_contains "$docs_root/QUESTIONS.md" "QST-0001"
require_contains "$docs_root/QUESTIONS.md" "Should Specs And Plans Be One To One"
require_contains "$docs_root/CONCEPTS.md" "CONC-0001"
require_contains "$docs_root/CONCEPTS.md" "Selections Snapshots And Dynamic Sections"
require_contains "$docs_root/DOCS-REGISTRY.md" "RSCH-0001"
require_contains "$docs_root/DOCS-REGISTRY.md" "EVAL-0001"
require_contains "$docs_root/DOCS-REGISTRY.md" "DIAG-0001"
require_contains "$docs_root/DOCS-REGISTRY.md" "$retirement_id"
require_contains "$docs_root/DOCS-REGISTRY.md" "id-retirement"
require_not_contains "$docs_root/TODOS.md" "Tombstone-only todo"
for type_registry in IDEAS.md SPECS.md LEARNINGS.md EXPLAINERS.md QUESTIONS.md CONCEPTS.md AREAS.md AUDITS.md ROADMAP-VIEW.md; do
  require_not_contains "$docs_root/$type_registry" "$retirement_id"
done
require_contains "$docs_root/ROADMAP-VIEW.md" "PLAN-0001"
require_contains "$docs_root/ROADMAP-VIEW.md" "PLAN-shared-capture-implementation"
require_contains "$docs_root/ROADMAP-VIEW.md" "type: generated-view"
require_contains "$docs_root/ROADMAP-VIEW.md" "updated_at:"
require_contains "$docs_root/TODOS.md" "Define owner boundaries"
require_contains "$docs_root/TODOS.md" "Structured Todos"
require_contains "$docs_root/TODOS.md" "TODO-0001"
require_contains "$docs_root/TODOS.md" "Local task with a \\| pipe"

valid_retirement_frontmatter() {
  local target_id="$1"
  local parent_plan="$2"
  cat <<EOF
---
type: id-retirement
id: $target_id
title: Retired ID $target_id
status: retired
parent_plan: $parent_plan
reason: "Retired by validation fixture."
source:
  type: "test"
  link: "test://retirement"
  notes: ""
created_at: "2026-08-16 00:00:00 JST +0900"
updated_at: "2026-08-16 00:00:00 JST +0900"
repo_state:
  based_on_commit:
  last_reviewed_commit:
---

# Retired ID $target_id
EOF
}

invalid_retirement="$docs_root/id-retirements/IMPL-0001-90.md"
cat >"$invalid_retirement" <<'EOF'
---
type: id-retirement
title: Missing ID
status: retired
parent_plan: PLAN-0001
reason: "Missing the frontmatter ID."
source:
  type: "test"
  link: "test://retirement"
  notes: ""
created_at: "2026-08-16 00:00:00 JST +0900"
updated_at: "2026-08-16 00:00:00 JST +0900"
repo_state:
  based_on_commit:
  last_reviewed_commit:
---
EOF
if run_meta check >$tmpdir/docs-meta-retire-check-missing-id.out 2>&1; then
  echo "Expected docs check to reject a tombstone without frontmatter id" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-check-missing-id.out "Missing frontmatter field 'id'"
rm "$invalid_retirement"

mkdir -p "$docs_root/misplaced"
invalid_retirement="$docs_root/misplaced/IMPL-0001-91.md"
valid_retirement_frontmatter IMPL-0001-91 PLAN-0001 >"$invalid_retirement"
if run_meta check >$tmpdir/docs-meta-retire-check-path.out 2>&1; then
  echo "Expected docs check to reject a tombstone outside the fixed path" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-check-path.out "must live at id-retirements/IMPL-0001-91.md"
rm "$invalid_retirement"

invalid_retirement="$docs_root/id-retirements/IMPL-0002-01.md"
valid_retirement_frontmatter IMPL-0002-01 PLAN-0001 >"$invalid_retirement"
if run_meta check >$tmpdir/docs-meta-retire-check-plan-number.out 2>&1; then
  echo "Expected docs check to reject a tombstone whose plan number differs" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-check-plan-number.out "does not match parent_plan PLAN-0001"
rm "$invalid_retirement"

invalid_retirement="$docs_root/id-retirements/IMPL-9999-01.md"
valid_retirement_frontmatter IMPL-9999-01 PLAN-9999 >"$invalid_retirement"
if run_meta check >$tmpdir/docs-meta-retire-check-missing-parent.out 2>&1; then
  echo "Expected docs check to reject a tombstone with a missing live parent" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-check-missing-parent.out "must reference a live primary plan"
rm "$invalid_retirement"

invalid_retirement="$docs_root/id-retirements/IMPL-0001-92.md"
valid_retirement_frontmatter IMPL-0001-92 PLAN-0001 >"$invalid_retirement"
perl -0pi -e 's/reason: "Retired by validation fixture\."/reason: ""/' "$invalid_retirement"
if run_meta check >$tmpdir/docs-meta-retire-check-reason.out 2>&1; then
  echo "Expected docs check to reject an empty retirement reason" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-check-reason.out "must include a non-empty reason"
rm "$invalid_retirement"

invalid_retirement="$docs_root/id-retirements/IMPL-0001-93.md"
valid_retirement_frontmatter IMPL-0001-93 PLAN-0001 >"$invalid_retirement"
perl -0pi -e 's/type: "test"/type: ""/; s/link: "test:\/\/retirement"/link: ""/' "$invalid_retirement"
if run_meta check >$tmpdir/docs-meta-retire-check-provenance.out 2>&1; then
  echo "Expected docs check to reject missing retirement provenance" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-check-provenance.out "source.type"
require_contains $tmpdir/docs-meta-retire-check-provenance.out "source.link or source.notes"
rm "$invalid_retirement"

invalid_retirement="$docs_root/id-retirements/IMPL-0001-94.md"
valid_retirement_frontmatter IMPL-0001-94 PLAN-0001 >"$invalid_retirement"
perl -0pi -e 's/status: retired/status: active/' "$invalid_retirement"
if run_meta check >$tmpdir/docs-meta-retire-check-status.out 2>&1; then
  echo "Expected docs check to reject an invalid retirement status" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-check-status.out "Unknown status 'active' for type 'id-retirement'"
rm "$invalid_retirement"

invalid_retirement="$docs_root/id-retirements/IMPL-0001-96.md"
valid_retirement_frontmatter IMPL-0001-96 PLAN-0001 >"$invalid_retirement"
perl -0pi -e 's/status: retired/status: ""/' "$invalid_retirement"
if run_meta check >$tmpdir/docs-meta-retire-check-empty-status.out 2>&1; then
  echo "Expected docs check to reject an empty retirement status" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-check-empty-status.out "must use status retired"
rm "$invalid_retirement"

invalid_retirement="$docs_root/id-retirements/IMPL-0001-95.md"
valid_retirement_frontmatter IMPL-0001-95 PLAN-0001 >"$invalid_retirement"
perl -0pi -e 's/type: id-retirement/type: plan/' "$invalid_retirement"
if run_meta check >$tmpdir/docs-meta-retire-check-type.out 2>&1; then
  echo "Expected docs check to reject the wrong type in id-retirements" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-check-type.out "must use type 'id-retirement'"
rm "$invalid_retirement"

wrong_type_parent="$docs_root/product/specs/PLAN-0099-wrong-type.md"
cat >"$wrong_type_parent" <<'EOF'
---
type: spec
id: PLAN-0099
title: Wrong Type Parent
status: draft
---
EOF
invalid_retirement="$docs_root/id-retirements/IMPL-0099-01.md"
valid_retirement_frontmatter IMPL-0099-01 PLAN-0099 >"$invalid_retirement"
if run_meta check >$tmpdir/docs-meta-retire-check-parent-type.out 2>&1; then
  echo "Expected docs check to require a parent of type plan" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-check-parent-type.out "must reference a live primary plan"
rm "$invalid_retirement" "$wrong_type_parent"

frontmatter_collision="$docs_root/frontmatter-retirement-collision.md"
cat >"$frontmatter_collision" <<EOF
---
id: $retirement_id
---
EOF
if run_meta check >$tmpdir/docs-meta-retire-check-frontmatter-collision.out 2>&1; then
  echo "Expected docs check to reject a frontmatter retirement collision" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-retire-check-frontmatter-collision.out "collision"
rm "$frontmatter_collision"

mkdir -p "$docs_root/research"
cat > "$docs_root/research/bad-research-without-id.md" <<'BADRESEARCH'
---
type: research-survey
title: Bad Research Without ID
domain: research
status: draft
created_at: "2026-04-25 10:00:00 JST +0900"
updated_at: "2026-04-25 10:00:00 JST +0900"
owner:
question:
source:
  type: conversation
  link:
  notes:
repo_state:
  based_on_commit:
  last_reviewed_commit:
---

# Bad Research Without ID
BADRESEARCH
if run_meta check >$tmpdir/docs-meta-bad-research.out 2>&1; then
  echo "Expected typed RSCH-style doc without id to fail validation" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-bad-research.out "Missing frontmatter field 'id'"
rm "$docs_root/research/bad-research-without-id.md"

cat > "$docs_root/repo-health/audits/bad-audit-without-id.md" <<'BADAUDITID'
---
type: repo-health-audit
title: Bad Audit Without ID
status: completed
audit_kind: docs-health
created_at: "2026-04-25 10:00:00 JST +0900"
updated_at: "2026-04-25 10:30:00 JST +0900"
audit_started_at: "2026-04-25 10:00:00 JST +0900"
audit_ended_at: "2026-04-25 10:30:00 JST +0900"
scope:
  - docs
checks:
  - agent-continuity docs check
repo_state:
  based_on_commit:
  last_reviewed_commit:
---

# Bad Audit Without ID
BADAUDITID

if run_meta check >$tmpdir/docs-meta-bad-audit-id.out 2>&1; then
  echo "Expected typed repo-health-audit without id to fail validation" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-bad-audit-id.out "Missing frontmatter field 'id'"
rm "$docs_root/repo-health/audits/bad-audit-without-id.md"

run_meta check
run_meta check-todos >$tmpdir/docs-meta-check-todos.out 2>&1
require_contains $tmpdir/docs-meta-check-todos.out "No todo issues found."
run_meta check-todos --strict >$tmpdir/docs-meta-check-todos-strict.out 2>&1
require_contains $tmpdir/docs-meta-check-todos-strict.out "WARN:"
run_meta todos --status ready >$tmpdir/docs-meta-todos-ready.out
require_contains $tmpdir/docs-meta-todos-ready.out "TODO-0001"
run_meta todos --owner main-agent --structured-only >$tmpdir/docs-meta-todos-owner.out
require_contains $tmpdir/docs-meta-todos-owner.out "TODO-0002"
run_meta todos --agent smoke-agent --structured-only >$tmpdir/docs-meta-todos-agent.out
require_contains $tmpdir/docs-meta-todos-agent.out "TODO-0004"
run_meta todos --plan PLAN-0001 --json >$tmpdir/docs-meta-todos.json
require_contains $tmpdir/docs-meta-todos.json "\"id\": \"TODO-0001\""
require_contains $tmpdir/docs-meta-todos.json "\"agent\": \"smoke-agent\""
run_meta todos TODO-0003 --all >$tmpdir/docs-meta-todos-id.out
require_contains $tmpdir/docs-meta-todos-id.out "TODO-0003"
run_meta todos --structured-only --all >$tmpdir/docs-meta-todos-structured.out
if grep -Fq "Follow up on TODO-0001" $tmpdir/docs-meta-todos-structured.out; then
  echo "Expected non-leading TODO reference to remain a local checkbox" >&2
  exit 1
fi
rm "$docs_root/ROADMAP-VIEW.md"
run_meta roadmap --json >$tmpdir/docs-meta-roadmap.json
require_contains $tmpdir/docs-meta-roadmap.json "\"id\": \"PLAN-0001\""
require_contains $tmpdir/docs-meta-roadmap.json "\"plan_name\": \"PLAN-shared-capture-implementation\""
require_absent "$docs_root/ROADMAP-VIEW.md"
run_meta roadmap --write >$tmpdir/docs-meta-roadmap-write.out
require_file "$docs_root/ROADMAP-VIEW.md"
run_meta show PLAN-0001 >$tmpdir/docs-meta-show-plan.out
require_contains $tmpdir/docs-meta-show-plan.out $'Linked Paths:'
require_contains $tmpdir/docs-meta-show-plan.out "app/src/todo.ts: ok -> app/src/todo.ts"
run_meta show PLAN-0001 --json >$tmpdir/docs-meta-show-plan.json
require_contains $tmpdir/docs-meta-show-plan.json "\"linked_paths\""
require_contains $tmpdir/docs-meta-show-plan.json "\"status\": \"ok\""
require_contains $tmpdir/docs-meta-show-plan.json "\"id\": \"$plan_uuid\""
require_contains $tmpdir/docs-meta-show-plan.json "\"aliases\""
run_meta show "$plan_uuid" --json >$tmpdir/docs-meta-show-plan-by-uuid.json
require_contains $tmpdir/docs-meta-show-plan-by-uuid.json "\"display_id\": \"PLAN-0001\""
run_meta view todos >$tmpdir/docs-meta-view-todos.md
require_contains $tmpdir/docs-meta-view-todos.md "Docs Todos"
require_contains "$docs_root/TODOS.md" "updated_at:"

cat >> "$plan_path" <<'BADTODO'

- [ ] TODO-0001 [ready] Duplicate todo ID
- [x] TODO-0005 [in_progress] [owner:main-agent] Checked but active
- [ ] TODO-0006 [done] Open but done
- [ ] TODO-0007 [nonsense] Invalid status
- [ ] TODO-0008 [in_progress] Missing owner
- [ ] TODO-0009 [in_progress] [owner:main-agent] Missing agent and timestamp
- [ ] TODO-0010 [blocked] Missing blocker reason
- [x] TODO-0011 [done] Missing done evidence
- [ ] TODO-0012 [ready] [plan:PLAN-9999] Missing plan
BADTODO
if run_meta check-todos >$tmpdir/docs-meta-bad-todos.out 2>&1; then
  echo "Expected invalid structured todos to fail validation" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-bad-todos.out "Duplicate todo ID TODO-0001"
require_contains $tmpdir/docs-meta-bad-todos.out "invalid todo status"
require_contains $tmpdir/docs-meta-bad-todos.out "in_progress status without owner"
require_contains $tmpdir/docs-meta-bad-todos.out "in_progress status without agent"
require_contains $tmpdir/docs-meta-bad-todos.out "in_progress status without updated timestamp"
require_contains $tmpdir/docs-meta-bad-todos.out "blocked status without blocker"
require_contains $tmpdir/docs-meta-bad-todos.out "done status without verification"
require_contains $tmpdir/docs-meta-bad-todos.out "references missing plan PLAN-9999"
perl -0pi -e 's/\n- \[ \] TODO-0001 \[ready\] Duplicate todo ID\n- \[x\] TODO-0005 \[in_progress\] \[owner:main-agent\] Checked but active\n- \[ \] TODO-0006 \[done\] Open but done\n- \[ \] TODO-0007 \[nonsense\] Invalid status\n- \[ \] TODO-0008 \[in_progress\] Missing owner\n- \[ \] TODO-0009 \[in_progress\] \[owner:main-agent\] Missing agent and timestamp\n- \[ \] TODO-0010 \[blocked\] Missing blocker reason\n- \[x\] TODO-0011 \[done\] Missing done evidence\n- \[ \] TODO-0012 \[ready\] \[plan:PLAN-9999\] Missing plan\n//' "$plan_path"

perl -0pi -e 's/linked_paths:\n  - app\/src\/todo.ts\n/linked_paths:\n  - app\/src\/missing.ts\n/' "$plan_path"
if run_meta check >$tmpdir/docs-meta-bad-linked-paths.out 2>&1; then
  echo "Expected missing linked_paths target to fail validation" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-bad-linked-paths.out "linked_paths entry 'app/src/missing.ts' is missing"
perl -0pi -e 's/linked_paths:\n  - app\/src\/missing.ts\n/linked_paths:\n  - app\/src\/todo.ts\n/' "$plan_path"

mkdir -p "$docs_root/link-fixtures"
cat > "$docs_root/link-fixtures/target.md" <<'TARGET'
# Target
TARGET
cat > "$docs_root/link-fixtures/immutable-target.md" <<'IMMUTABLE_TARGET'
# Immutable Target
IMMUTABLE_TARGET
mkdir -p "$docs_root/link-fixtures/immutable-dir"
cat > "$docs_root/link-fixtures/immutable-dir/nested.md" <<'IMMUTABLE_NESTED_TARGET'
# Immutable Nested Target
IMMUTABLE_NESTED_TARGET
cat > "$docs_root/link-fixtures/source.md" <<'SOURCE'
# Source

- [Target](target.md)
- [Spec](/product/specs/SPEC-shared-capture-workflow.md)
- [Missing](missing.md)
- [[target.md]]
- `<not-a-link>`

```text
[also-not-a-link](missing-in-code.md)
```
SOURCE

run_meta links link-fixtures/source.md >$tmpdir/docs-meta-links.out
require_contains $tmpdir/docs-meta-links.out "target.md"
require_contains $tmpdir/docs-meta-links.out "wiki-link"
run_meta backlinks link-fixtures/target.md >$tmpdir/docs-meta-backlinks.out
require_contains $tmpdir/docs-meta-backlinks.out "link-fixtures/source.md"
if run_meta check-links >$tmpdir/docs-meta-check-links.out 2>&1; then
  echo "Expected missing link to fail check-links" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-check-links.out "missing.md"
if grep -Fq "not-a-link" $tmpdir/docs-meta-check-links.out || grep -Fq "missing-in-code" $tmpdir/docs-meta-check-links.out; then
  echo "Expected check-links to ignore links inside inline and fenced code" >&2
  exit 1
fi
perl -0pi -e 's/^- \[Missing\]\(missing\.md\)\n//m' "$docs_root/link-fixtures/source.md"
if ! run_meta check-links >$tmpdir/docs-meta-check-links-clean.out 2>&1; then
  cat $tmpdir/docs-meta-check-links-clean.out >&2
  echo "Expected check-links to pass after removing missing link" >&2
  exit 1
fi

retirement_hash_before_targeted_moves="$(shasum -a 256 "$retirement_path")"
immutable_target_hash="$(shasum -a 256 "$docs_root/link-fixtures/immutable-target.md")"
if run_meta move link-fixtures/immutable-target.md link-fixtures/moved/immutable-target-new.md --write \
  >$tmpdir/docs-meta-move-immutable-target.out 2>&1; then
  echo "Expected move to refuse a source linked from an immutable tombstone" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-move-immutable-target.out "immutable id-retirement"
require_contains $tmpdir/docs-meta-move-immutable-target.out "links to the move source"
require_file "$docs_root/link-fixtures/immutable-target.md"
require_absent "$docs_root/link-fixtures/moved/immutable-target-new.md"
if [[ "$immutable_target_hash" != "$(shasum -a 256 "$docs_root/link-fixtures/immutable-target.md")" ]]; then
  echo "Expected refused exact-target move to preserve source bytes" >&2
  exit 1
fi

immutable_nested_hash="$(shasum -a 256 "$docs_root/link-fixtures/immutable-dir/nested.md")"
if run_meta move link-fixtures/immutable-dir link-fixtures/moved/immutable-dir --write \
  >$tmpdir/docs-meta-move-immutable-directory-target.out 2>&1; then
  echo "Expected directory move to refuse a nested target linked from an immutable tombstone" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-move-immutable-directory-target.out "immutable id-retirement"
require_contains $tmpdir/docs-meta-move-immutable-directory-target.out "beneath the move source"
require_file "$docs_root/link-fixtures/immutable-dir/nested.md"
require_absent "$docs_root/link-fixtures/moved/immutable-dir"
if [[ "$immutable_nested_hash" != "$(shasum -a 256 "$docs_root/link-fixtures/immutable-dir/nested.md")" ]]; then
  echo "Expected refused directory-target move to preserve source bytes" >&2
  exit 1
fi
if [[ "$retirement_hash_before_targeted_moves" != "$(shasum -a 256 "$retirement_path")" ]]; then
  echo "Expected refused targeted moves to preserve tombstone bytes" >&2
  exit 1
fi
if ! run_meta check-links >$tmpdir/docs-meta-check-links-after-refused-moves.out 2>&1; then
  cat $tmpdir/docs-meta-check-links-after-refused-moves.out >&2
  echo "Expected check-links to remain green after refused targeted moves" >&2
  exit 1
fi

run_meta normalize-links --style relative --dry-run >$tmpdir/docs-meta-normalize-dry-run.out
require_contains $tmpdir/docs-meta-normalize-dry-run.out "/product/specs/SPEC-shared-capture-workflow.md -> ../product/specs/SPEC-shared-capture-workflow.md"
retirement_hash_before_normalize="$(shasum -a 256 "$retirement_path")"
run_meta normalize-links --style relative --write >$tmpdir/docs-meta-normalize-write.out
require_contains "$docs_root/link-fixtures/source.md" "../product/specs/SPEC-shared-capture-workflow.md"
if [[ "$retirement_hash_before_normalize" != "$(shasum -a 256 "$retirement_path")" ]]; then
  echo "Expected normalize-links --write to preserve tombstone bytes" >&2
  exit 1
fi
run_meta move link-fixtures/target.md link-fixtures/moved/target-new.md --dry-run >$tmpdir/docs-meta-move-dry-run.out
require_contains $tmpdir/docs-meta-move-dry-run.out "target.md -> moved/target-new.md"
retirement_hash_before_other_move="$(shasum -a 256 "$retirement_path")"
run_meta move link-fixtures/target.md link-fixtures/moved/target-new.md --write >$tmpdir/docs-meta-move-write.out
require_file "$docs_root/link-fixtures/moved/target-new.md"
require_contains "$docs_root/link-fixtures/source.md" "moved/target-new.md"
if [[ "$retirement_hash_before_other_move" != "$(shasum -a 256 "$retirement_path")" ]]; then
  echo "Expected moving another doc to preserve tombstone bytes" >&2
  exit 1
fi
run_meta backlinks link-fixtures/moved/target-new.md >$tmpdir/docs-meta-backlinks-moved.out
require_contains $tmpdir/docs-meta-backlinks-moved.out "link-fixtures/source.md"
run_meta orphans --exclude 'link-fixtures/*' >$tmpdir/docs-meta-orphans.out
if grep -Fq "link-fixtures/target.md" $tmpdir/docs-meta-orphans.out; then
  echo "Expected orphan exclude pattern to suppress link-fixtures docs" >&2
  exit 1
fi

perl -0pi -e 's/updated_at: "[^"]+"/updated_at: "2026-01-01 00:00:00 JST +0900"/' "$docs_root/architecture/areas/AREA-capture.md"
run_meta health --stale-days 1 >$tmpdir/docs-meta-health.out
require_contains $tmpdir/docs-meta-health.out "stale-by-time"
require_contains $tmpdir/docs-meta-health.out "AREA-capture"
require_absent "$docs_root/HEALTH.md"
run_meta health --stale-days 1 --write >$tmpdir/docs-meta-health-write.out
require_file "$docs_root/HEALTH.md"
require_contains "$docs_root/HEALTH.md" "Docs Health"
run_meta health --stale-days 1 --json >$tmpdir/docs-meta-health.json
require_contains $tmpdir/docs-meta-health.json "\"code\": \"stale-by-time\""

missing_field="$docs_root/product/specs/SPEC-0002-missing-field.md"
cp "$spec_path" "$missing_field"
perl -0pi -e 's/^title: .+\n//m; s/SPEC-0001/SPEC-0002/g' "$missing_field"
if run_meta check >$tmpdir/docs-meta-missing-field.out 2>&1; then
  echo "Expected missing title field to fail validation" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-missing-field.out "Missing frontmatter field 'title'"
rm "$missing_field"

bad_area="$docs_root/architecture/areas/AREA-bad.md"
cp "$docs_root/architecture/areas/AREA-capture.md" "$bad_area"
perl -0pi -e 's/AREA-capture/AREA-other/g' "$bad_area"
if run_meta check >$tmpdir/docs-meta-bad-area.out 2>&1; then
  echo "Expected area ID mismatch to fail validation" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-bad-area.out "must match filename stem"
rm "$bad_area"

migration_repo="$tmpdir/uuid-migration-repo"
migration_docs="$migration_repo/docs"
mkdir -p "$migration_docs/product/plans/PLAN-0001-legacy/implementation-briefs"
cat >"$migration_docs/product/plans/PLAN-0001-legacy/PLAN-0001-legacy.md" <<'LEGACYPLAN'
---
type: plan
id: PLAN-0001
title: Legacy Plan
domain: product
status: ready
created_at: "2026-08-20 10:00:00 JST +0900"
updated_at: "2026-08-20 10:00:00 JST +0900"
areas: []
related_specs: []
repo_state:
  based_on_commit: fixture
  last_reviewed_commit: fixture
---

# PLAN-0001 - Legacy Plan
LEGACYPLAN
cat >"$migration_docs/product/plans/PLAN-0001-legacy/implementation-briefs/IMPL-0001-01-legacy.md" <<'LEGACYIMPL'
---
type: implementation-brief
id: IMPL-0001-01
title: Legacy Brief
domain: product
status: ready
created_at: "2026-08-20 10:00:00 JST +0900"
updated_at: "2026-08-20 10:00:00 JST +0900"
parent_plan: PLAN-0001
task_refs: []
repo_state:
  based_on_commit: fixture
  last_reviewed_commit: fixture
---

# IMPL-0001-01 - Legacy Brief
LEGACYIMPL
git -C "$migration_repo" init -q
git -C "$migration_repo" add docs
git -C "$migration_repo" \
  -c user.name="Agent Continuity Smoke" \
  -c user.email="smoke@example.invalid" \
  commit -qm "Create legacy document fixture"

run_meta_root "$migration_docs" check
run_meta_root "$migration_docs" format-status --json >"$tmpdir/uuid-format-before.json"
require_contains "$tmpdir/uuid-format-before.json" '"v1": 2'
require_contains "$tmpdir/uuid-format-before.json" '"migration_required": true'

conflict_repo="$tmpdir/uuid-migration-conflict-repo"
git clone -q "$migration_repo" "$conflict_repo"

migration_plan_rel=".agent-continuity/migrations/document-format-v2.json"
(
  cd "$migration_repo"
  "$agent_continuity_docs" --root docs migrate-uuids --prepare-plan "$migration_plan_rel" --write
)
if (
  cd "$migration_repo"
  "$agent_continuity_docs" --root docs migrate-uuids --plan "$migration_plan_rel" --write
) >"$tmpdir/uuid-uncommitted-plan.out" 2>&1; then
  echo "Expected UUID migration to refuse an uncommitted plan" >&2
  exit 1
fi
require_contains "$tmpdir/uuid-uncommitted-plan.out" "Migration plan must be committed"
git -C "$migration_repo" add "$migration_plan_rel"
git -C "$migration_repo" \
  -c user.name="Agent Continuity Smoke" \
  -c user.email="smoke@example.invalid" \
  commit -qm "Commit UUID migration plan"

resume_repo="$tmpdir/uuid-migration-resume-repo"
git clone -q "$migration_repo" "$resume_repo"
(
  cd "$resume_repo"
  "$agent_continuity_docs" --root docs migrate-uuids --plan "$migration_plan_rel" --write --json
) >"$tmpdir/uuid-migration-resume-initial.json"
rm "$resume_repo/$migration_plan_rel.receipt.json"
resume_first_path="docs/product/plans/PLAN-0001-legacy/PLAN-0001-legacy.md"
git -C "$resume_repo" show "HEAD:$resume_first_path" >"$resume_repo/$resume_first_path"
(
  cd "$resume_repo"
  "$agent_continuity_docs" --root docs migrate-uuids --plan "$migration_plan_rel" --json
) >"$tmpdir/uuid-migration-resume-preview.json"
require_contains "$tmpdir/uuid-migration-resume-preview.json" '"state": "in_progress"'
(
  cd "$resume_repo"
  "$agent_continuity_docs" --root docs migrate-uuids --plan "$migration_plan_rel" --write --json
) >"$tmpdir/uuid-migration-resume-apply.json"
require_contains "$tmpdir/uuid-migration-resume-apply.json" '"state": "completed"'
require_file "$resume_repo/$migration_plan_rel.receipt.json"

unplanned_repo="$tmpdir/uuid-migration-unplanned-repo"
git clone -q "$migration_repo" "$unplanned_repo"
mkdir -p "$unplanned_repo/docs/product/specs"
cat >"$unplanned_repo/docs/product/specs/SPEC-unplanned-v1.md" <<'UNPLANNED'
---
type: spec
id: SPEC-0002
title: Unplanned V1 Document
domain: product
status: draft
created_at: "2026-08-20 10:00:00 JST +0900"
updated_at: "2026-08-20 10:00:00 JST +0900"
spec_type: feature
source:
  type: test
  link: ""
areas: []
related_plans: []
repo_state:
  based_on_commit: fixture
  last_reviewed_commit: fixture
---

# Unplanned V1 Document
UNPLANNED
unplanned_existing="$unplanned_repo/$resume_first_path"
unplanned_hash_before="$(shasum -a 256 "$unplanned_existing")"
if (
  cd "$unplanned_repo"
  "$agent_continuity_docs" --root docs migrate-uuids --plan "$migration_plan_rel" --write
) >"$tmpdir/uuid-migration-unplanned.out" 2>&1; then
  echo "Expected UUID migration to refuse a v1 document absent from the committed plan" >&2
  exit 1
fi
require_contains "$tmpdir/uuid-migration-unplanned.out" "does not cover v1 document added after preparation"
if [[ "$unplanned_hash_before" != "$(shasum -a 256 "$unplanned_existing")" ]]; then
  echo "Expected unplanned-document refusal before any planned document mutation" >&2
  exit 1
fi
require_absent "$unplanned_repo/$migration_plan_rel.receipt.json"

(
  cd "$migration_repo"
  "$agent_continuity_docs" --root docs migrate-uuids --plan "$migration_plan_rel" --json
) >"$tmpdir/uuid-migration-preview.json"
require_contains "$tmpdir/uuid-migration-preview.json" '"state": "ready"'
(
  cd "$migration_repo"
  "$agent_continuity_docs" --root docs migrate-uuids --plan "$migration_plan_rel" --write --json
) >"$tmpdir/uuid-migration-apply.json"
require_contains "$tmpdir/uuid-migration-apply.json" '"state": "completed"'
require_file "$migration_repo/$migration_plan_rel.receipt.json"

migrated_plan="$migration_docs/product/plans/PLAN-0001-legacy/PLAN-0001-legacy.md"
migrated_impl="$migration_docs/product/plans/PLAN-0001-legacy/implementation-briefs/IMPL-0001-01-legacy.md"
migrated_plan_uuid="$(frontmatter_id "$migrated_plan")"
migrated_impl_uuid="$(frontmatter_id "$migrated_impl")"
require_uuid7 "$migrated_plan_uuid"
require_uuid7 "$migrated_impl_uuid"
require_contains "$migrated_plan" "document_format_version: 2"
require_contains "$migrated_plan" '  - "PLAN-0001"'
require_contains "$migrated_impl" '  - "IMPL-0001-01"'
require_contains "$migrated_impl" "parent_plan: PLAN-0001"
run_meta_root "$migration_docs" show "$migrated_plan_uuid" --json >"$tmpdir/uuid-migrated-show.json"
require_contains "$tmpdir/uuid-migrated-show.json" '"display_id": "PLAN-0001"'
run_meta_root "$migration_docs" check
run_meta_root "$migration_docs" format-status --json >"$tmpdir/uuid-format-after.json"
require_contains "$tmpdir/uuid-format-after.json" '"v2": 2'
require_contains "$tmpdir/uuid-format-after.json" '"migration_required": false'
(
  cd "$migration_repo"
  "$agent_continuity_docs" --root docs migrate-uuids --plan "$migration_plan_rel" --write --json
) >"$tmpdir/uuid-migration-idempotent.json"
require_contains "$tmpdir/uuid-migration-idempotent.json" '"state": "completed"'

(
  cd "$conflict_repo"
  "$agent_continuity_docs" --root docs migrate-uuids --prepare-plan "$migration_plan_rel" --write
)
git -C "$conflict_repo" add "$migration_plan_rel"
git -C "$conflict_repo" \
  -c user.name="Agent Continuity Smoke" \
  -c user.email="smoke@example.invalid" \
  commit -qm "Commit conflicting UUID migration plan"
conflict_plan="$conflict_repo/docs/product/plans/PLAN-0001-legacy/PLAN-0001-legacy.md"
perl -0pi -e 's/title: Legacy Plan/title: Diverged Legacy Plan/' "$conflict_plan"
conflict_hash_before="$(shasum -a 256 "$conflict_plan")"
if (
  cd "$conflict_repo"
  "$agent_continuity_docs" --root docs migrate-uuids --plan "$migration_plan_rel" --write
) >"$tmpdir/uuid-migration-conflict.out" 2>&1; then
  echo "Expected UUID migration to refuse a preimage conflict" >&2
  exit 1
fi
require_contains "$tmpdir/uuid-migration-conflict.out" "preimage conflict"
conflict_hash_after="$(shasum -a 256 "$conflict_plan")"
if [[ "$conflict_hash_before" != "$conflict_hash_after" ]]; then
  echo "Expected UUID migration conflict refusal to preserve source bytes" >&2
  exit 1
fi

perl -0pi -e 's/status: draft/status: accepted/' "$plan_path"
if run_meta check >$tmpdir/docs-meta-bad-status.out 2>&1; then
  echo "Expected invalid plan status to fail validation" >&2
  exit 1
fi
require_contains $tmpdir/docs-meta-bad-status.out "Unknown status 'accepted' for type 'plan'"

if [[ "${AGENT_CONTINUITY_DOCS_SKIP_ADOPTER_PORTABILITY_CHECK:-}" != "1" ]]; then
  adopter_root="$tmpdir/adopter-fixture"
  mkdir -p "$adopter_root/scripts" "$adopter_root/tests"
  cp "$repo_root/scripts/agent-continuity-docs" "$adopter_root/scripts/agent-continuity-docs"
  cp "$repo_root/tests/agent-continuity-docs-smoke.sh" "$adopter_root/tests/agent-continuity-docs-smoke.sh"
  require_absent "$adopter_root/scripts/agent-continuity"
  git -C "$adopter_root" init -q
  git -C "$adopter_root" add scripts/agent-continuity-docs tests/agent-continuity-docs-smoke.sh
  git -C "$adopter_root" \
    -c user.name="Agent Continuity Smoke" \
    -c user.email="smoke@example.invalid" \
    commit -qm "Create adopter smoke fixture"
  if ! (
    cd "$adopter_root"
    AGENT_CONTINUITY_DOCS_SKIP_ADOPTER_PORTABILITY_CHECK=1 \
      tests/agent-continuity-docs-smoke.sh
  ) >$tmpdir/docs-meta-adopter-portability.out 2>&1; then
    cat $tmpdir/docs-meta-adopter-portability.out >&2
    echo "Expected vendored docs smoke test to pass without the agent-continuity dispatcher" >&2
    exit 1
  fi
  require_contains $tmpdir/docs-meta-adopter-portability.out "agent-continuity docs smoke test passed"
fi

echo "agent-continuity docs smoke test passed"
