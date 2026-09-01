#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
installer="$repo_root/scripts/agent-continuity-init"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

require_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -Fq -- "$pattern" "$file"; then
    echo "Expected $file to contain: $pattern" >&2
    exit 1
  fi
}

require_not_contains() {
  local file="$1"
  local pattern="$2"
  if grep -Fq -- "$pattern" "$file"; then
    echo "Expected $file not to contain: $pattern" >&2
    exit 1
  fi
}

require_exit() {
  local expected="$1"
  local label="$2"
  shift 2
  local stdout="$tmpdir/$label.stdout"
  local stderr="$tmpdir/$label.stderr"
  set +e
  "$@" >"$stdout" 2>"$stderr"
  local actual="$?"
  set -e
  if [[ "$actual" != "$expected" ]]; then
    echo "Expected exit $expected, got $actual: $*" >&2
    cat "$stdout" >&2
    cat "$stderr" >&2
    exit 1
  fi
}

snapshot_tree() {
  local target="$1"
  local output="$2"
  (
    cd "$target"
    find . -path ./.git -prune -o -type f -print |
      LC_ALL=C sort |
      while IFS= read -r path; do
        shasum -a 256 "$path"
      done
  ) >"$output"
}

assert_unchanged() {
  local target="$1"
  local label="$2"
  snapshot_tree "$target" "$tmpdir/$label.after"
  if ! cmp "$tmpdir/$label.before" "$tmpdir/$label.after"; then
    echo "Expected refused mutation to preserve every repository file: $label" >&2
    diff -u "$tmpdir/$label.before" "$tmpdir/$label.after" >&2 || true
    exit 1
  fi
}

commit_fixture() {
  local target="$1"
  local message="$2"
  git -C "$target" add .
  git -C "$target" \
    -c user.name="Agent Continuity Smoke" \
    -c user.email="smoke@example.invalid" \
    commit -qm "$message"
}

make_healthy_fixture() {
  local target="$1"
  "$installer" "$target" --profile complete --write >"$tmpdir/install-$(basename "$target").out"
  git -C "$target" init -q
  commit_fixture "$target" "Create automatic document preflight fixture"
}

copy_fixture() {
  local source="$1"
  local target="$2"
  cp -R "$source" "$target"
}

write_v1_spec_root() {
  local root="$1"
  mkdir -p "$root/product/specs"
  printf '%s\n' \
    '---' \
    'type: spec' \
    'id: SPEC-0001' \
    'title: Legacy Preflight Fixture' \
    'spec_type: feature' \
    'domain: product' \
    'status: draft' \
    'created_at: "2026-09-01 00:00:00 JST +0900"' \
    'updated_at: "2026-09-01 00:00:00 JST +0900"' \
    'source:' \
    '  type: test' \
    '  link: ""' \
    'repo_state:' \
    '  based_on_commit: fixture' \
    '  last_reviewed_commit: fixture' \
    '---' \
    '' \
    '# Legacy Preflight Fixture' \
    >"$root/product/specs/SPEC-0001-legacy-preflight-fixture.md"
}

write_v1_spec() {
  local target="$1"
  write_v1_spec_root "$target/docs"
}

set_release_drift() {
  local target="$1"
  python3 - "$target/.agent-continuity/manifest.json" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
manifest["agent_continuity_release"] = "0.0.0-preflight-fixture"
path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
}

python3 - "$repo_root/scripts/agent-continuity-docs" <<'PY'
import ast
import argparse
import importlib.machinery
import importlib.util
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
loader = importlib.machinery.SourceFileLoader("agent_continuity_docs_preflight", str(path))
spec = importlib.util.spec_from_loader(loader.name, loader)
module = importlib.util.module_from_spec(spec)
sys.modules[loader.name] = module
previous_dont_write_bytecode = sys.dont_write_bytecode
sys.dont_write_bytecode = True
try:
    loader.exec_module(module)
finally:
    sys.dont_write_bytecode = previous_dont_write_bytecode

always_write = {"new", "set-status", "update", "view"}
conditional_write = {"retire-id", "normalize-links", "move", "health", "roadmap"}
migration_write = {"migrate-uuids"}
read_only = {
    "next",
    "format-status",
    "status",
    "show",
    "todos",
    "check",
    "check-todos",
    "review",
    "links",
    "backlinks",
    "check-links",
    "orphans",
}
expected = always_write | conditional_write | migration_write | read_only

tree = ast.parse(path.read_text(encoding="utf-8"))
parsed = {
    node.args[0].value
    for node in ast.walk(tree)
    if isinstance(node, ast.Call)
    and isinstance(node.func, ast.Attribute)
    and node.func.attr == "add_parser"
    and node.args
    and isinstance(node.args[0], ast.Constant)
    and isinstance(node.args[0].value, str)
}
if parsed != expected:
    raise SystemExit(
        f"Document command classification fixture is stale: missing={sorted(parsed - expected)} extra={sorted(expected - parsed)}"
    )

for command in sorted(always_write):
    for write in (False, True):
        actual = module.document_mutation_policy(argparse.Namespace(command=command, write=write))
        assert actual == "docs-write", (command, write, actual)
for command in sorted(conditional_write):
    assert module.document_mutation_policy(argparse.Namespace(command=command, write=False)) is None
    assert module.document_mutation_policy(argparse.Namespace(command=command, write=True)) == "docs-write"
for command in sorted(migration_write):
    assert module.document_mutation_policy(argparse.Namespace(command=command, write=False)) is None
    assert module.document_mutation_policy(argparse.Namespace(command=command, write=True)) == "docs-migration-write"
for command in sorted(read_only):
    for write in (False, True):
        assert module.document_mutation_policy(argparse.Namespace(command=command, write=write)) is None
assert module.document_mutation_policy(argparse.Namespace(command="future-write", write=False)) == "docs-write"
PY

base="$tmpdir/base"
make_healthy_fixture "$base"
base_dispatcher="$repo_root/scripts/agent-continuity"
base_helper="$repo_root/scripts/agent-continuity-docs"
base_docs="$base/docs"

require_exit 0 healthy-policy \
  "$base_dispatcher" doctor --policy docs-write --policy-root "$base_docs" "$base"
if [[ -s "$tmpdir/healthy-policy.stdout" || -s "$tmpdir/healthy-policy.stderr" ]]; then
  echo "Expected successful doctor policy to be silent" >&2
  cat "$tmpdir/healthy-policy.stdout" >&2
  cat "$tmpdir/healthy-policy.stderr" >&2
  exit 1
fi

require_exit 2 outside-policy-root \
  "$base_dispatcher" doctor --policy docs-write --policy-root "$tmpdir/outside-root" "$base"
require_contains "$tmpdir/outside-policy-root.stderr" "policy root resolves outside target"

require_exit 0 healthy-top-level "$base_dispatcher" docs --root "$base_docs" new spec "Healthy Top Level Mutation" --domain product
if [[ "$(wc -l <"$tmpdir/healthy-top-level.stdout" | tr -d ' ')" != "1" ]]; then
  echo "Expected successful docs new stdout to remain one path line" >&2
  cat "$tmpdir/healthy-top-level.stdout" >&2
  exit 1
fi
require_not_contains "$tmpdir/healthy-top-level.stdout" "policy"
if [[ -s "$tmpdir/healthy-top-level.stderr" ]]; then
  echo "Expected healthy mutation to add no stderr" >&2
  cat "$tmpdir/healthy-top-level.stderr" >&2
  exit 1
fi

require_exit 0 healthy-direct "$base_helper" --root "$base_docs" new spec "Healthy Direct Mutation" --domain product
if [[ "$(wc -l <"$tmpdir/healthy-direct.stdout" | tr -d ' ')" != "1" ]]; then
  echo "Expected direct helper stdout to remain one path line" >&2
  cat "$tmpdir/healthy-direct.stdout" >&2
  exit 1
fi
if [[ -s "$tmpdir/healthy-direct.stderr" ]]; then
  echo "Expected healthy direct mutation to add no stderr" >&2
  cat "$tmpdir/healthy-direct.stderr" >&2
  exit 1
fi

installed_bin="$tmpdir/installed-bin"
mkdir -p "$installed_bin"
ln -s "$base_dispatcher" "$installed_bin/agent-continuity"
require_exit 0 healthy-installed-direct \
  /usr/bin/env PATH="$installed_bin:$PATH" \
  "$base/scripts/agent-continuity-docs" --root "$base_docs" new spec "Healthy Installed Direct Mutation" --domain product
if [[ "$(wc -l <"$tmpdir/healthy-installed-direct.stdout" | tr -d ' ')" != "1" ]]; then
  echo "Expected installed direct helper stdout to remain one path line" >&2
  cat "$tmpdir/healthy-installed-direct.stdout" >&2
  exit 1
fi
if [[ -s "$tmpdir/healthy-installed-direct.stderr" ]]; then
  echo "Expected installed direct helper to use the compatible PATH dispatcher silently" >&2
  cat "$tmpdir/healthy-installed-direct.stderr" >&2
  exit 1
fi

release_drift="$tmpdir/release-drift"
copy_fixture "$base" "$release_drift"
set_release_drift "$release_drift"
snapshot_tree "$release_drift" "$tmpdir/release-drift.before"
require_exit 1 release-drift \
  "$base_dispatcher" docs --root "$release_drift/docs" new spec "Blocked Release Drift" --domain product
assert_unchanged "$release_drift" release-drift
require_contains "$tmpdir/release-drift.stderr" "docs-write"
require_contains "$tmpdir/release-drift.stderr" "candidate tooling updates available"

noncanonical_root="$tmpdir/noncanonical-root"
copy_fixture "$base" "$noncanonical_root"
noncanonical_docs="$noncanonical_root/knowledge"
write_v1_spec_root "$noncanonical_docs"
commit_fixture "$noncanonical_root" "Add noncanonical v1 document fixture"
snapshot_tree "$noncanonical_root" "$tmpdir/noncanonical-root.before"
require_exit 1 noncanonical-root \
  "$base_dispatcher" docs --root "$noncanonical_docs" new spec "Blocked Noncanonical Root" --domain product
assert_unchanged "$noncanonical_root" noncanonical-root
require_contains "$tmpdir/noncanonical-root.stderr" "document format migration"
require_contains "$tmpdir/noncanonical-root.stderr" "knowledge"

owned_drift="$tmpdir/owned-drift"
copy_fixture "$base" "$owned_drift"
printf '\n# owned drift fixture\n' >>"$owned_drift/scripts/agent-continuity-docs"
snapshot_tree "$owned_drift" "$tmpdir/owned-drift.before"
require_exit 1 owned-drift \
  "$base_helper" --root "$owned_drift/docs" new spec "Blocked Owned Drift" --domain product
assert_unchanged "$owned_drift" owned-drift
require_contains "$tmpdir/owned-drift.stderr" "docs-write"
require_contains "$tmpdir/owned-drift.stderr" "checksum drift/local modification"

generated_drift="$tmpdir/generated-drift"
copy_fixture "$base" "$generated_drift"
printf '\ncorrupted generated view fixture\n' >>"$generated_drift/docs/TODOS.md"
require_exit 0 generated-repair \
  "$base_dispatcher" docs --root "$generated_drift/docs" update
require_not_contains "$generated_drift/docs/TODOS.md" "corrupted generated view fixture"

migration="$tmpdir/migration"
copy_fixture "$base" "$migration"
write_v1_spec "$migration"
commit_fixture "$migration" "Add v1 document fixture"
snapshot_tree "$migration" "$tmpdir/migration-ordinary.before"
require_exit 1 migration-ordinary \
  "$base_dispatcher" docs --root "$migration/docs" new spec "Blocked During Migration" --domain product
assert_unchanged "$migration" migration-ordinary
require_contains "$tmpdir/migration-ordinary.stderr" "document format migration"
require_exit 0 migration-format-status \
  "$base_dispatcher" docs --root "$migration/docs" format-status --json
require_contains "$tmpdir/migration-format-status.stdout" '"v1": 1'

migration_plan=".agent-continuity/migrations/document-format-v2.json"
require_exit 0 migration-prepare \
  "$base_dispatcher" docs --root "$migration/docs" migrate-uuids --prepare-plan "$migration_plan" --write
commit_fixture "$migration" "Commit automatic preflight migration plan"
require_exit 0 migration-apply \
  "$base_dispatcher" docs --root "$migration/docs" migrate-uuids --plan "$migration_plan" --write --json
require_contains "$tmpdir/migration-apply.stdout" '"state": "completed"'

migration_owned_drift="$tmpdir/migration-owned-drift"
copy_fixture "$base" "$migration_owned_drift"
write_v1_spec "$migration_owned_drift"
commit_fixture "$migration_owned_drift" "Add v1 owned drift fixture"
printf '\n# migration owned drift fixture\n' >>"$migration_owned_drift/scripts/agent-continuity-docs"
snapshot_tree "$migration_owned_drift" "$tmpdir/migration-owned-drift.before"
require_exit 1 migration-owned-drift \
  "$base_helper" --root "$migration_owned_drift/docs" \
  migrate-uuids --prepare-plan "$migration_plan" --write
assert_unchanged "$migration_owned_drift" migration-owned-drift
require_contains "$tmpdir/migration-owned-drift.stderr" "docs-migration-write"
require_contains "$tmpdir/migration-owned-drift.stderr" "checksum drift/local modification"

require_exit 1 drift-doctor "$base_dispatcher" doctor "$migration_owned_drift"
require_contains "$tmpdir/drift-doctor.stdout" "checksum drift/local modification"
require_exit 0 drift-format-status \
  "$base_helper" --root "$migration_owned_drift/docs" format-status --json
require_contains "$tmpdir/drift-format-status.stdout" '"v1": 1'

nested_non_git="$tmpdir/nested-non-git"
copy_fixture "$base" "$nested_non_git"
rm -rf "$nested_non_git/.git"
nested_non_git_docs="$nested_non_git/knowledge/deep/docs"
mkdir -p "$nested_non_git_docs"
set_release_drift "$nested_non_git"
snapshot_tree "$nested_non_git" "$tmpdir/nested-non-git.before"
require_exit 1 nested-non-git \
  "$base_helper" --root "$nested_non_git_docs" new spec "Blocked Nested Non Git Root" --domain product
assert_unchanged "$nested_non_git" nested-non-git
require_contains "$tmpdir/nested-non-git.stderr" "candidate tooling updates available"

nested_no_manifest="$tmpdir/nested-no-manifest/knowledge/deep/docs"
mkdir -p "$nested_no_manifest"
require_exit 0 nested-no-manifest \
  "$base_helper" --root "$nested_no_manifest" new spec "Allowed No Manifest Root" --domain product
if [[ -s "$tmpdir/nested-no-manifest.stderr" ]]; then
  echo "Expected a no-manifest root to retain the existing unguarded compatibility path" >&2
  cat "$tmpdir/nested-no-manifest.stderr" >&2
  exit 1
fi

missing_dispatcher="$tmpdir/missing-dispatcher"
copy_fixture "$base" "$missing_dispatcher"
snapshot_tree "$missing_dispatcher" "$tmpdir/missing-dispatcher.before"
no_dispatcher_bin="$tmpdir/no-dispatcher-bin"
mkdir -p "$no_dispatcher_bin"
ln -s "$(command -v python3)" "$no_dispatcher_bin/python3"
ln -s "$(command -v git)" "$no_dispatcher_bin/git"
require_exit 2 missing-dispatcher-direct \
  /usr/bin/env PATH="$no_dispatcher_bin" \
  "$missing_dispatcher/scripts/agent-continuity-docs" --root "$missing_dispatcher/docs" new spec "No Dispatcher" --domain product
assert_unchanged "$missing_dispatcher" missing-dispatcher
require_contains "$tmpdir/missing-dispatcher-direct.stderr" "compatible Agent Continuity dispatcher"

echo "agent-continuity docs preflight smoke test passed"
