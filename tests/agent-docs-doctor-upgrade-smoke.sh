#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
agent_docs="$repo_root/scripts/agent-docs"
installer="$repo_root/scripts/agent-docs-init"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

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
  if ! grep -Fq -- "$pattern" "$file"; then
    echo "Expected $file to contain: $pattern" >&2
    exit 1
  fi
}

require_exit() {
  local expected="$1"
  local output="$2"
  shift 2
  set +e
  "$@" >"$output" 2>&1
  local actual="$?"
  set -e
  if [[ "$actual" != "$expected" ]]; then
    echo "Expected exit $expected, got $actual: $*" >&2
    cat "$output" >&2
    exit 1
  fi
}

snapshot_tree() {
  local target="$1"
  local output="$2"
  (cd "$target" && find . -type f -print | sort | xargs shasum -a 256) >"$output"
}

healthy_target="$tmpdir/healthy"
"$installer" "$healthy_target" --profile small --docs-meta yes --write >"$tmpdir/healthy-install.out"
healthy_target_resolved="$(cd "$healthy_target" && pwd -P)"
require_exit 0 "$tmpdir/healthy-doctor.out" "$agent_docs" doctor "$healthy_target"
require_contains "$tmpdir/healthy-doctor.out" "AGENT-DOCS doctor"
require_contains "$tmpdir/healthy-doctor.out" "Status: healthy/current"
require_contains "$tmpdir/healthy-doctor.out" "Profile: small"
require_contains "$tmpdir/healthy-doctor.out" "healthy/current"
require_contains "$tmpdir/healthy-doctor.out" "Recommended next commands:"
require_contains "$tmpdir/healthy-doctor.out" "agent-docs doctor $healthy_target_resolved"
require_exit 0 "$tmpdir/healthy-upgrade.out" "$agent_docs" upgrade --dry-run "$healthy_target"
require_contains "$tmpdir/healthy-upgrade.out" "AGENT-DOCS upgrade dry-run"
require_contains "$tmpdir/healthy-upgrade.out" "Status: healthy/current"

missing_project_owned_target="$tmpdir/missing-project-owned"
"$installer" "$missing_project_owned_target" --profile small --docs-meta yes --write >"$tmpdir/missing-project-owned-install.out"
rm "$missing_project_owned_target/AGENTS.md"
require_exit 1 "$tmpdir/missing-project-owned-doctor.out" "$agent_docs" doctor "$missing_project_owned_target"
require_contains "$tmpdir/missing-project-owned-doctor.out" "missing project-owned manifest records"
require_contains "$tmpdir/missing-project-owned-doctor.out" "AGENTS.md"

directory_project_owned_target="$tmpdir/directory-project-owned"
"$installer" "$directory_project_owned_target" --profile small --docs-meta yes --write >"$tmpdir/directory-project-owned-install.out"
rm "$directory_project_owned_target/AGENTS.md"
mkdir "$directory_project_owned_target/AGENTS.md"
require_exit 2 "$tmpdir/directory-project-owned-doctor.out" "$agent_docs" doctor "$directory_project_owned_target"
require_contains "$tmpdir/directory-project-owned-doctor.out" "project-owned path is not a regular file"
require_contains "$tmpdir/directory-project-owned-doctor.out" "AGENTS.md"

dot_manifest_path_target="$tmpdir/dot-manifest-path"
"$installer" "$dot_manifest_path_target" --profile small --docs-meta yes --write >"$tmpdir/dot-manifest-path-install.out"
python3 - "$dot_manifest_path_target" <<'PY'
import json
import pathlib
import sys

manifest_path = pathlib.Path(sys.argv[1]) / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest["files"].append({
    "path": ".",
    "ownership": "project-owned-after-install",
})
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
require_exit 2 "$tmpdir/dot-manifest-path-doctor.out" "$agent_docs" doctor "$dot_manifest_path_target"
require_contains "$tmpdir/dot-manifest-path-doctor.out" "manifest path must be a non-empty relative path inside the target repo"

missing_target="$tmpdir/does-not-exist"
require_exit 2 "$tmpdir/missing-target-doctor.out" "$agent_docs" doctor "$missing_target"
require_contains "$tmpdir/missing-target-doctor.out" "target path does not exist"
require_exit 2 "$tmpdir/missing-target-upgrade.out" "$agent_docs" upgrade --dry-run "$missing_target"
require_contains "$tmpdir/missing-target-upgrade.out" "target path does not exist"

file_target="$tmpdir/file-target"
printf 'not a directory\n' >"$file_target"
require_exit 2 "$tmpdir/file-target-doctor.out" "$agent_docs" doctor "$file_target"
require_contains "$tmpdir/file-target-doctor.out" "target path is not a directory"
require_exit 2 "$tmpdir/file-target-upgrade.out" "$agent_docs" upgrade --dry-run "$file_target"
require_contains "$tmpdir/file-target-upgrade.out" "target path is not a directory"

legacy_target="$tmpdir/legacy"
mkdir -p "$legacy_target/docs"
echo "# Legacy" >"$legacy_target/AGENTS.md"
echo "# Current State" >"$legacy_target/docs/CURRENT_STATE.md"
legacy_target_resolved="$(cd "$legacy_target" && pwd -P)"
require_exit 1 "$tmpdir/legacy-doctor.out" "$agent_docs" doctor "$legacy_target"
require_contains "$tmpdir/legacy-doctor.out" "missing manifest/legacy/manual review"
require_contains "$tmpdir/legacy-doctor.out" ".agent-docs/manifest.json"
require_contains "$tmpdir/legacy-doctor.out" "agent-docs init $legacy_target_resolved --profile small --dry-run"

list_manifest_target="$tmpdir/list-manifest"
mkdir -p "$list_manifest_target/.agent-docs"
printf '[]\n' >"$list_manifest_target/.agent-docs/manifest.json"
require_exit 2 "$tmpdir/list-manifest-doctor.out" "$agent_docs" doctor "$list_manifest_target"
require_contains "$tmpdir/list-manifest-doctor.out" "refused/unknown/incompatible shapes"
require_contains "$tmpdir/list-manifest-doctor.out" ".agent-docs/manifest.json"
require_contains "$tmpdir/list-manifest-doctor.out" "manifest root must be a JSON object"

string_manifest_target="$tmpdir/string-manifest"
mkdir -p "$string_manifest_target/.agent-docs"
printf '"not an object"\n' >"$string_manifest_target/.agent-docs/manifest.json"
require_exit 2 "$tmpdir/string-manifest-doctor.out" "$agent_docs" doctor "$string_manifest_target"
require_contains "$tmpdir/string-manifest-doctor.out" "manifest root must be a JSON object"

null_manifest_target="$tmpdir/null-manifest"
mkdir -p "$null_manifest_target/.agent-docs"
printf 'null\n' >"$null_manifest_target/.agent-docs/manifest.json"
require_exit 2 "$tmpdir/null-manifest-doctor.out" "$agent_docs" doctor "$null_manifest_target"
require_contains "$tmpdir/null-manifest-doctor.out" "manifest root must be a JSON object"

bad_optional_shape_target="$tmpdir/bad-optional-shape"
"$installer" "$bad_optional_shape_target" --profile small --docs-meta yes --write >"$tmpdir/bad-optional-shape-install.out"
python3 - "$bad_optional_shape_target" <<'PY'
import json
import pathlib
import sys

manifest_path = pathlib.Path(sys.argv[1]) / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest["optional_components"] = {"docs-meta": True}
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
require_exit 2 "$tmpdir/bad-optional-shape-doctor.out" "$agent_docs" doctor "$bad_optional_shape_target"
require_contains "$tmpdir/bad-optional-shape-doctor.out" "manifest optional_components field is not a list"

unknown_optional_target="$tmpdir/unknown-optional"
"$installer" "$unknown_optional_target" --profile small --docs-meta yes --write >"$tmpdir/unknown-optional-install.out"
python3 - "$unknown_optional_target" <<'PY'
import json
import pathlib
import sys

manifest_path = pathlib.Path(sys.argv[1]) / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest["optional_components"] = ["docs-meta", "future-tooling"]
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
require_exit 2 "$tmpdir/unknown-optional-doctor.out" "$agent_docs" doctor "$unknown_optional_target"
require_contains "$tmpdir/unknown-optional-doctor.out" "unknown optional component"
require_contains "$tmpdir/unknown-optional-doctor.out" "future-tooling"

symlink_manifest_dir_target="$tmpdir/symlink-manifest-dir"
mkdir -p "$symlink_manifest_dir_target" "$tmpdir/outside-agent-docs-dir"
printf '{"schema_version": 1, "profile": "small", "optional_components": [], "files": [], "generated_views": []}\n' >"$tmpdir/outside-agent-docs-dir/manifest.json"
ln -s "$tmpdir/outside-agent-docs-dir" "$symlink_manifest_dir_target/.agent-docs"
require_exit 2 "$tmpdir/symlink-manifest-dir-doctor.out" "$agent_docs" doctor "$symlink_manifest_dir_target"
require_contains "$tmpdir/symlink-manifest-dir-doctor.out" "refused/unknown/incompatible shapes"
require_contains "$tmpdir/symlink-manifest-dir-doctor.out" ".agent-docs/manifest.json"
require_contains "$tmpdir/symlink-manifest-dir-doctor.out" "existing symlink inside target"

symlink_manifest_file_target="$tmpdir/symlink-manifest-file"
mkdir -p "$symlink_manifest_file_target/.agent-docs"
printf '{"schema_version": 1, "profile": "small", "optional_components": [], "files": [], "generated_views": []}\n' >"$tmpdir/outside-manifest.json"
ln -s "$tmpdir/outside-manifest.json" "$symlink_manifest_file_target/.agent-docs/manifest.json"
require_exit 2 "$tmpdir/symlink-manifest-file-doctor.out" "$agent_docs" doctor "$symlink_manifest_file_target"
require_contains "$tmpdir/symlink-manifest-file-doctor.out" "refused/unknown/incompatible shapes"
require_contains "$tmpdir/symlink-manifest-file-doctor.out" ".agent-docs/manifest.json"
require_contains "$tmpdir/symlink-manifest-file-doctor.out" "existing symlink inside target"

missing_tool_target="$tmpdir/missing-tool"
"$installer" "$missing_tool_target" --profile small --docs-meta yes --write >"$tmpdir/missing-tool-install.out"
rm "$missing_tool_target/scripts/docs-meta"
require_exit 1 "$tmpdir/missing-tool-doctor.out" "$agent_docs" doctor "$missing_tool_target"
require_contains "$tmpdir/missing-tool-doctor.out" "missing AGENT-DOCS-owned tooling"
require_contains "$tmpdir/missing-tool-doctor.out" "scripts/docs-meta"
require_contains "$tmpdir/missing-tool-doctor.out" "safe automatic additions"

missing_executable_target="$tmpdir/missing-executable"
"$installer" "$missing_executable_target" --profile small --docs-meta yes --write >"$tmpdir/missing-executable-install.out"
chmod -x "$missing_executable_target/scripts/docs-meta"
require_exit 1 "$tmpdir/missing-executable-doctor.out" "$agent_docs" doctor "$missing_executable_target"
require_contains "$tmpdir/missing-executable-doctor.out" "checksum drift/local modification"
require_contains "$tmpdir/missing-executable-doctor.out" "scripts/docs-meta"
require_contains "$tmpdir/missing-executable-doctor.out" "missing executable bit"

drift_target="$tmpdir/drift"
"$installer" "$drift_target" --profile small --docs-meta yes --write >"$tmpdir/drift-install.out"
echo "# local change" >>"$drift_target/tests/docs-meta-smoke.sh"
require_exit 1 "$tmpdir/drift-doctor.out" "$agent_docs" doctor "$drift_target"
require_contains "$tmpdir/drift-doctor.out" "checksum drift/local modification"
require_contains "$tmpdir/drift-doctor.out" "tests/docs-meta-smoke.sh"
require_contains "$tmpdir/drift-doctor.out" "current checksum differs from manifest"

dry_run_target="$tmpdir/dry-run-no-write"
"$installer" "$dry_run_target" --profile small --docs-meta yes --write >"$tmpdir/dry-run-install.out"
rm "$dry_run_target/scripts/docs-meta"
snapshot_tree "$dry_run_target" "$tmpdir/dry-run-before.sha"
require_exit 1 "$tmpdir/dry-run-upgrade.out" "$agent_docs" upgrade --dry-run "$dry_run_target"
snapshot_tree "$dry_run_target" "$tmpdir/dry-run-after.sha"
cmp "$tmpdir/dry-run-before.sha" "$tmpdir/dry-run-after.sha"
require_absent "$dry_run_target/scripts/docs-meta"
require_contains "$tmpdir/dry-run-upgrade.out" "safe automatic additions"
require_contains "$tmpdir/dry-run-upgrade.out" "scripts/docs-meta"

symlink_parent_target="$tmpdir/symlink-parent"
"$installer" "$symlink_parent_target" --profile small --docs-meta yes --write >"$tmpdir/symlink-parent-install.out"
outside_scripts="$tmpdir/outside-scripts"
mkdir -p "$outside_scripts"
rm -rf "$symlink_parent_target/scripts"
ln -s "$outside_scripts" "$symlink_parent_target/scripts"
require_exit 2 "$tmpdir/symlink-parent-doctor.out" "$agent_docs" doctor "$symlink_parent_target"
require_contains "$tmpdir/symlink-parent-doctor.out" "refused/unknown/incompatible shapes"
require_contains "$tmpdir/symlink-parent-doctor.out" "scripts/docs-meta"
require_contains "$tmpdir/symlink-parent-doctor.out" "existing symlink inside target"
if grep -Fq -- "safe automatic additions" "$tmpdir/symlink-parent-doctor.out"; then
  echo "Expected doctor to refuse symlinked parent paths instead of reporting safe additions" >&2
  exit 1
fi
snapshot_tree "$symlink_parent_target" "$tmpdir/symlink-parent-before.sha"
require_exit 2 "$tmpdir/symlink-parent-upgrade.out" "$agent_docs" upgrade --dry-run "$symlink_parent_target"
snapshot_tree "$symlink_parent_target" "$tmpdir/symlink-parent-after.sha"
cmp "$tmpdir/symlink-parent-before.sha" "$tmpdir/symlink-parent-after.sha"
require_contains "$tmpdir/symlink-parent-upgrade.out" "refused/unknown/incompatible shapes"
require_contains "$tmpdir/symlink-parent-upgrade.out" "scripts/docs-meta"
require_contains "$tmpdir/symlink-parent-upgrade.out" "existing symlink inside target"
if grep -Fq -- "safe automatic additions" "$tmpdir/symlink-parent-upgrade.out"; then
  echo "Expected upgrade dry-run to refuse symlinked parent paths instead of reporting safe additions" >&2
  exit 1
fi
require_absent "$outside_scripts/docs-meta"

unknown_owned_target="$tmpdir/unknown-owned"
"$installer" "$unknown_owned_target" --profile small --docs-meta yes --write >"$tmpdir/unknown-owned-install.out"
python3 - "$unknown_owned_target" <<'PY'
import hashlib
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
unknown_path = target / "tools/agent-docs-extra"
unknown_path.parent.mkdir(parents=True, exist_ok=True)
unknown_path.write_text("unknown owned content\n", encoding="utf-8")
manifest_path = target / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest["files"].append({
    "path": "tools/agent-docs-extra",
    "ownership": "agent-docs-owned",
    "checksum_sha256": hashlib.sha256(unknown_path.read_bytes()).hexdigest(),
})
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
require_exit 2 "$tmpdir/unknown-owned-doctor.out" "$agent_docs" doctor "$unknown_owned_target"
require_contains "$tmpdir/unknown-owned-doctor.out" "refused/unknown/incompatible shapes"
require_contains "$tmpdir/unknown-owned-doctor.out" "tools/agent-docs-extra"
require_contains "$tmpdir/unknown-owned-doctor.out" "not known in this AGENT-DOCS version"
if grep -Fq -- "tools/agent-docs-extra: owned file exists and matches manifest checksum" "$tmpdir/unknown-owned-doctor.out"; then
  echo "Expected doctor to refuse unknown owned files instead of reporting healthy" >&2
  exit 1
fi
require_exit 2 "$tmpdir/unknown-owned-upgrade.out" "$agent_docs" upgrade --dry-run "$unknown_owned_target"
require_contains "$tmpdir/unknown-owned-upgrade.out" "refused/unknown/incompatible shapes"
require_contains "$tmpdir/unknown-owned-upgrade.out" "tools/agent-docs-extra"
require_contains "$tmpdir/unknown-owned-upgrade.out" "not known in this AGENT-DOCS version"
if grep -Fq -- "tools/agent-docs-extra: owned file exists and matches manifest checksum" "$tmpdir/unknown-owned-upgrade.out"; then
  echo "Expected upgrade dry-run to refuse unknown owned files instead of reporting healthy" >&2
  exit 1
fi

invalid_owned_checksum_target="$tmpdir/invalid-owned-checksum"
"$installer" "$invalid_owned_checksum_target" --profile small --docs-meta yes --write >"$tmpdir/invalid-owned-checksum-install.out"
python3 - "$invalid_owned_checksum_target" <<'PY'
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
manifest_path = target / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
for record in manifest["files"]:
    if record["path"] == "scripts/docs-meta":
        record["checksum_sha256"] = "not-a-sha256"
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
require_exit 2 "$tmpdir/invalid-owned-checksum-doctor.out" "$agent_docs" doctor "$invalid_owned_checksum_target"
require_contains "$tmpdir/invalid-owned-checksum-doctor.out" "refused/unknown/incompatible shapes"
require_contains "$tmpdir/invalid-owned-checksum-doctor.out" "scripts/docs-meta"
require_contains "$tmpdir/invalid-owned-checksum-doctor.out" "checksum_sha256 must be 64 lowercase hex characters"
if grep -Fq -- "checksum drift/local modification" "$tmpdir/invalid-owned-checksum-doctor.out"; then
  echo "Expected malformed owned checksum to be refused, not drift" >&2
  exit 1
fi

duplicate_file_record_target="$tmpdir/duplicate-file-record"
"$installer" "$duplicate_file_record_target" --profile small --docs-meta yes --write >"$tmpdir/duplicate-file-record-install.out"
python3 - "$duplicate_file_record_target" <<'PY'
import json
import pathlib
import sys

manifest_path = pathlib.Path(sys.argv[1]) / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest["files"].append(dict(manifest["files"][0]))
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
require_exit 2 "$tmpdir/duplicate-file-record-doctor.out" "$agent_docs" doctor "$duplicate_file_record_target"
require_contains "$tmpdir/duplicate-file-record-doctor.out" "duplicate manifest file record"

invalid_generated_checksum_target="$tmpdir/invalid-generated-checksum"
"$installer" "$invalid_generated_checksum_target" --profile small --docs-meta yes --write >"$tmpdir/invalid-generated-checksum-install.out"
python3 - "$invalid_generated_checksum_target" <<'PY'
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
manifest_path = target / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest["generated_views"] = [{
    "path": "docs/TODOS.md",
    "generator": "scripts/docs-meta update",
    "checksum_sha256": "not-a-sha256",
}]
(target / "docs/TODOS.md").write_text("# Todos\n", encoding="utf-8")
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
require_exit 2 "$tmpdir/invalid-generated-checksum-doctor.out" "$agent_docs" doctor "$invalid_generated_checksum_target"
require_contains "$tmpdir/invalid-generated-checksum-doctor.out" "refused/unknown/incompatible shapes"
require_contains "$tmpdir/invalid-generated-checksum-doctor.out" "docs/TODOS.md"
require_contains "$tmpdir/invalid-generated-checksum-doctor.out" "checksum_sha256 must be 64 lowercase hex characters"
if grep -Fq -- "generated view refreshes" "$tmpdir/invalid-generated-checksum-doctor.out"; then
  echo "Expected malformed generated checksum to be refused, not refresh" >&2
  exit 1
fi

missing_generated_checksum_target="$tmpdir/missing-generated-checksum"
"$installer" "$missing_generated_checksum_target" --profile small --docs-meta yes --write >"$tmpdir/missing-generated-checksum-install.out"
python3 - "$missing_generated_checksum_target" <<'PY'
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
manifest_path = target / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest["generated_views"] = [{
    "path": "docs/TODOS.md",
    "generator": "scripts/docs-meta update",
}]
(target / "docs/TODOS.md").write_text("# Todos\n", encoding="utf-8")
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
require_exit 2 "$tmpdir/missing-generated-checksum-doctor.out" "$agent_docs" doctor "$missing_generated_checksum_target"
require_contains "$tmpdir/missing-generated-checksum-doctor.out" "generated view checksum_sha256 must be present"

directory_owned_target="$tmpdir/directory-owned"
"$installer" "$directory_owned_target" --profile small --docs-meta yes --write >"$tmpdir/directory-owned-install.out"
rm "$directory_owned_target/scripts/docs-meta"
mkdir "$directory_owned_target/scripts/docs-meta"
require_exit 2 "$tmpdir/directory-owned-doctor.out" "$agent_docs" doctor "$directory_owned_target"
require_contains "$tmpdir/directory-owned-doctor.out" "owned path is not a regular file"
require_contains "$tmpdir/directory-owned-doctor.out" "scripts/docs-meta"

directory_generated_target="$tmpdir/directory-generated"
"$installer" "$directory_generated_target" --profile small --docs-meta yes --write >"$tmpdir/directory-generated-install.out"
python3 - "$directory_generated_target" <<'PY'
import hashlib
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
manifest_path = target / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest["generated_views"] = [{
    "path": "docs/TODOS.md",
    "generator": "scripts/docs-meta update",
    "checksum_sha256": hashlib.sha256(b"# Todos\n").hexdigest(),
}]
todos = target / "docs/TODOS.md"
if todos.exists():
    todos.unlink()
todos.mkdir()
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
require_exit 2 "$tmpdir/directory-generated-doctor.out" "$agent_docs" doctor "$directory_generated_target"
require_contains "$tmpdir/directory-generated-doctor.out" "generated view path is not a regular file"
require_contains "$tmpdir/directory-generated-doctor.out" "docs/TODOS.md"

control_output_target="$tmpdir/control-output"
"$installer" "$control_output_target" --profile small --docs-meta yes --write >"$tmpdir/control-output-install.out"
python3 - "$control_output_target" <<'PY'
import hashlib
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
manifest_path = target / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest["source"]["commit"] = "\u001b[31mcommit\u001b[0m"
manifest["optional_components"] = ["docs-meta\u001b]8;;https://example.invalid\u0007bad"]
manifest["generated_views"] = [{
    "path": "docs/TODOS.md",
    "generator": "scripts/docs-meta update \u001b[31mred\u001b[0m",
    "checksum_sha256": hashlib.sha256(b"base").hexdigest(),
}]
(target / "docs/TODOS.md").write_text("changed\n", encoding="utf-8")
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
require_exit 2 "$tmpdir/control-output-doctor.out" "$agent_docs" doctor "$control_output_target"
if LC_ALL=C grep "$(printf '\033')" "$tmpdir/control-output-doctor.out" >/dev/null; then
  echo "Expected manifest-derived output to escape raw ESC characters" >&2
  cat "$tmpdir/control-output-doctor.out" >&2
  exit 1
fi
require_contains "$tmpdir/control-output-doctor.out" "\\x1b"

mixed_target="$tmpdir/mixed"
"$installer" "$mixed_target" --profile small --docs-meta yes --write >"$tmpdir/mixed-install.out"
python3 - "$mixed_target" <<'PY'
import hashlib
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
manifest_path = target / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

old_tool = target / "scripts/docs-meta"
old_tool.write_text("#!/usr/bin/env python3\nprint('old docs-meta')\n", encoding="utf-8")
old_tool.chmod(old_tool.stat().st_mode | 0o111)
old_checksum = hashlib.sha256(old_tool.read_bytes()).hexdigest()

for record in manifest["files"]:
    if record["path"] == "scripts/docs-meta":
        record["checksum_sha256"] = old_checksum
    if record["path"] == "tests/docs-meta-smoke.sh":
        pathlib.Path(target / record["path"]).write_text("local drift\n", encoding="utf-8")

manifest["files"].append({
    "path": "docs/manual.md",
    "ownership": "project-owned-after-install",
})
manifest["files"].append({
    "path": "outside.txt",
    "ownership": "agent-docs-owned",
    "checksum_sha256": hashlib.sha256(b"outside").hexdigest(),
})
manifest["files"].append({
    "path": "../escape.txt",
    "ownership": "agent-docs-owned",
    "checksum_sha256": hashlib.sha256(b"escape").hexdigest(),
})
manifest["generated_views"] = [{
    "path": "docs/TODOS.md",
    "generator": "scripts/docs-meta update",
    "checksum_sha256": hashlib.sha256(b"base").hexdigest(),
}]
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
(target / "docs/manual.md").write_text("# Manual\n", encoding="utf-8")
(target / "outside.txt").write_text("outside", encoding="utf-8")
(target / "docs/TODOS.md").write_text("changed generated view\n", encoding="utf-8")
PY
require_exit 2 "$tmpdir/mixed-upgrade.out" "$agent_docs" upgrade --dry-run "$mixed_target"
require_contains "$tmpdir/mixed-upgrade.out" "candidate tooling updates available"
require_contains "$tmpdir/mixed-upgrade.out" "scripts/docs-meta"
require_contains "$tmpdir/mixed-upgrade.out" "checksum drift/local modification"
require_contains "$tmpdir/mixed-upgrade.out" "tests/docs-meta-smoke.sh"
require_contains "$tmpdir/mixed-upgrade.out" "generated view refreshes"
require_contains "$tmpdir/mixed-upgrade.out" "docs/TODOS.md"
require_contains "$tmpdir/mixed-upgrade.out" "project-owned/manual-review items"
require_contains "$tmpdir/mixed-upgrade.out" "docs/manual.md"
require_contains "$tmpdir/mixed-upgrade.out" "refused/unknown/incompatible shapes"
require_contains "$tmpdir/mixed-upgrade.out" "../escape.txt"

require_exit 2 "$tmpdir/write-refused.out" "$agent_docs" upgrade --write "$healthy_target"
require_contains "$tmpdir/write-refused.out" 'Only `agent-docs upgrade --dry-run [target]` is supported'
