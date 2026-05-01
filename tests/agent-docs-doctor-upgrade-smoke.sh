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
snapshot_tree "$healthy_target" "$tmpdir/healthy-before-bare-upgrade.sha"
require_exit 0 "$tmpdir/healthy-bare-upgrade.out" "$agent_docs" upgrade "$healthy_target"
snapshot_tree "$healthy_target" "$tmpdir/healthy-after-bare-upgrade.sha"
cmp "$tmpdir/healthy-before-bare-upgrade.sha" "$tmpdir/healthy-after-bare-upgrade.sha"
require_contains "$tmpdir/healthy-bare-upgrade.out" "AGENT-DOCS upgrade dry-run"
require_contains "$tmpdir/healthy-bare-upgrade.out" "Status: healthy/current"

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
require_contains "$tmpdir/write-refused.out" '`agent-docs upgrade --write` requires `--tooling-only`'

write_missing_target="$tmpdir/write-missing-tool"
"$installer" "$write_missing_target" --profile small --docs-meta yes --write >"$tmpdir/write-missing-tool-install.out"
rm "$write_missing_target/scripts/docs-meta"
require_exit 0 "$tmpdir/write-missing-tool.out" "$agent_docs" upgrade --write --tooling-only "$write_missing_target"
require_file "$write_missing_target/scripts/docs-meta"
require_contains "$tmpdir/write-missing-tool.out" "AGENT-DOCS upgrade write tooling-only"
require_contains "$tmpdir/write-missing-tool.out" "Restored: scripts/docs-meta"
python3 - "$write_missing_target" "$repo_root/scripts/docs-meta" <<'PY'
import hashlib
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
upstream = pathlib.Path(sys.argv[2])
manifest = json.loads((target / ".agent-docs/manifest.json").read_text(encoding="utf-8"))
records = {record["path"]: record for record in manifest["files"]}
record = records["scripts/docs-meta"]
expected = hashlib.sha256(upstream.read_bytes()).hexdigest()
assert record["checksum_sha256"] == expected
assert record["source"]["path"] == "scripts/docs-meta"
assert record["source"]["type"] == "agent-docs-action"
assert manifest["source"]["commit"]
assert manifest["updated_at"]
PY

write_update_target="$tmpdir/write-update-tool"
"$installer" "$write_update_target" --profile small --docs-meta yes --write >"$tmpdir/write-update-tool-install.out"
python3 - "$write_update_target" <<'PY'
import hashlib
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
tool = target / "scripts/docs-meta"
tool.write_text("#!/usr/bin/env python3\nprint('old docs-meta')\n", encoding="utf-8")
tool.chmod(tool.stat().st_mode | 0o111)
old_checksum = hashlib.sha256(tool.read_bytes()).hexdigest()
manifest_path = target / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest["source"]["commit"] = "old-commit"
for record in manifest["files"]:
    if record["path"] == "scripts/docs-meta":
        record["checksum_sha256"] = old_checksum
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
require_exit 0 "$tmpdir/write-update-tool.out" "$agent_docs" upgrade --write --tooling-only "$write_update_target"
require_contains "$tmpdir/write-update-tool.out" "Updated: scripts/docs-meta"
require_contains "$tmpdir/write-update-tool.out" "Backup: .agent-docs/backups/"
python3 - "$write_update_target" "$repo_root/scripts/docs-meta" <<'PY'
import hashlib
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
upstream = pathlib.Path(sys.argv[2])
manifest = json.loads((target / ".agent-docs/manifest.json").read_text(encoding="utf-8"))
records = {record["path"]: record for record in manifest["files"]}
expected = hashlib.sha256(upstream.read_bytes()).hexdigest()
assert hashlib.sha256((target / "scripts/docs-meta").read_bytes()).hexdigest() == expected
assert records["scripts/docs-meta"]["checksum_sha256"] == expected
assert records["scripts/docs-meta"]["source"]["path"] == "scripts/docs-meta"
assert records["scripts/docs-meta"]["mode"] == "755"
assert manifest["source"]["commit"] != "old-commit"
backups = list((target / ".agent-docs/backups").glob("*/scripts/docs-meta"))
assert backups, "expected replaced file backup"
assert any(path.read_text(encoding="utf-8") == "#!/usr/bin/env python3\nprint('old docs-meta')\n" for path in backups)
PY

write_mode_target="$tmpdir/write-mode-repair"
"$installer" "$write_mode_target" --profile small --docs-meta yes --write >"$tmpdir/write-mode-repair-install.out"
chmod 644 "$write_mode_target/scripts/docs-meta"
require_exit 0 "$tmpdir/write-mode-repair.out" "$agent_docs" upgrade --write --tooling-only "$write_mode_target"
require_contains "$tmpdir/write-mode-repair.out" "Repaired executable bit: scripts/docs-meta"
test -x "$write_mode_target/scripts/docs-meta"
python3 - "$write_mode_target/scripts/docs-meta" <<'PY'
import pathlib
import stat
import sys

mode = stat.S_IMODE(pathlib.Path(sys.argv[1]).stat().st_mode)
assert mode == 0o755, oct(mode)
PY
find "$write_mode_target/.agent-docs/backups" -type f -path "*/scripts/docs-meta" | grep -q .

write_mode_drift_target="$tmpdir/write-mode-drift-refused"
"$installer" "$write_mode_drift_target" --profile small --docs-meta yes --write >"$tmpdir/write-mode-drift-install.out"
chmod 777 "$write_mode_drift_target/scripts/docs-meta"
snapshot_tree "$write_mode_drift_target" "$tmpdir/write-mode-drift-before.sha"
require_exit 2 "$tmpdir/write-mode-drift.out" "$agent_docs" upgrade --write --tooling-only "$write_mode_drift_target"
snapshot_tree "$write_mode_drift_target" "$tmpdir/write-mode-drift-after.sha"
cmp "$tmpdir/write-mode-drift-before.sha" "$tmpdir/write-mode-drift-after.sha"
require_contains "$tmpdir/write-mode-drift.out" "current mode 777 differs from manifest mode 755"
require_contains "$tmpdir/write-mode-drift.out" "refusing tooling-only write"

write_missing_mode_target="$tmpdir/write-missing-mode-refused"
"$installer" "$write_missing_mode_target" --profile small --docs-meta yes --write >"$tmpdir/write-missing-mode-install.out"
python3 - "$write_missing_mode_target" <<'PY'
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
manifest_path = target / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
for record in manifest["files"]:
    if record["path"] == "scripts/docs-meta":
        record.pop("mode", None)
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
chmod 777 "$write_missing_mode_target/scripts/docs-meta"
snapshot_tree "$write_missing_mode_target" "$tmpdir/write-missing-mode-before.sha"
require_exit 2 "$tmpdir/write-missing-mode.out" "$agent_docs" upgrade --write --tooling-only "$write_missing_mode_target"
snapshot_tree "$write_missing_mode_target" "$tmpdir/write-missing-mode-after.sha"
cmp "$tmpdir/write-missing-mode-before.sha" "$tmpdir/write-missing-mode-after.sha"
require_contains "$tmpdir/write-missing-mode.out" "agent-docs-owned mode must be recorded as a string"
require_contains "$tmpdir/write-missing-mode.out" "refusing tooling-only write"

write_missing_mode_missing_file_target="$tmpdir/write-missing-mode-missing-file-refused"
"$installer" "$write_missing_mode_missing_file_target" --profile small --docs-meta yes --write >"$tmpdir/write-missing-mode-missing-file-install.out"
python3 - "$write_missing_mode_missing_file_target" <<'PY'
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
manifest_path = target / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
for record in manifest["files"]:
    if record["path"] == "scripts/docs-meta":
        record.pop("mode", None)
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
rm "$write_missing_mode_missing_file_target/scripts/docs-meta"
snapshot_tree "$write_missing_mode_missing_file_target" "$tmpdir/write-missing-mode-missing-file-before.sha"
require_exit 2 "$tmpdir/write-missing-mode-missing-file.out" "$agent_docs" upgrade --write --tooling-only "$write_missing_mode_missing_file_target"
snapshot_tree "$write_missing_mode_missing_file_target" "$tmpdir/write-missing-mode-missing-file-after.sha"
cmp "$tmpdir/write-missing-mode-missing-file-before.sha" "$tmpdir/write-missing-mode-missing-file-after.sha"
require_absent "$write_missing_mode_missing_file_target/scripts/docs-meta"
require_contains "$tmpdir/write-missing-mode-missing-file.out" "agent-docs-owned mode must be recorded as a string"
require_contains "$tmpdir/write-missing-mode-missing-file.out" "refusing tooling-only write"

write_hardlink_target="$tmpdir/write-hardlink-repair"
"$installer" "$write_hardlink_target" --profile small --docs-meta yes --write >"$tmpdir/write-hardlink-install.out"
write_outside_hardlink="$tmpdir/write-outside-hardlink-docs-meta"
rm "$write_hardlink_target/scripts/docs-meta"
cp "$repo_root/scripts/docs-meta" "$write_outside_hardlink"
chmod 644 "$write_outside_hardlink"
ln "$write_outside_hardlink" "$write_hardlink_target/scripts/docs-meta"
outside_hardlink_before="$(shasum -a 256 "$write_outside_hardlink")"
outside_hardlink_mode_before="$(stat -f '%Lp' "$write_outside_hardlink")"
require_exit 0 "$tmpdir/write-hardlink.out" "$agent_docs" upgrade --write --tooling-only "$write_hardlink_target"
outside_hardlink_after="$(shasum -a 256 "$write_outside_hardlink")"
outside_hardlink_mode_after="$(stat -f '%Lp' "$write_outside_hardlink")"
test "$outside_hardlink_before" = "$outside_hardlink_after"
test "$outside_hardlink_mode_before" = "$outside_hardlink_mode_after"
test -x "$write_hardlink_target/scripts/docs-meta"
require_contains "$tmpdir/write-hardlink.out" "Repaired executable bit: scripts/docs-meta"

write_drift_target="$tmpdir/write-drift-refused"
"$installer" "$write_drift_target" --profile small --docs-meta yes --write >"$tmpdir/write-drift-install.out"
printf '\n# local drift\n' >>"$write_drift_target/scripts/docs-meta"
snapshot_tree "$write_drift_target" "$tmpdir/write-drift-before.sha"
require_exit 2 "$tmpdir/write-drift.out" "$agent_docs" upgrade --write --tooling-only "$write_drift_target"
snapshot_tree "$write_drift_target" "$tmpdir/write-drift-after.sha"
cmp "$tmpdir/write-drift-before.sha" "$tmpdir/write-drift-after.sha"
require_contains "$tmpdir/write-drift.out" "checksum drift/local modification"
require_contains "$tmpdir/write-drift.out" "refusing tooling-only write"

write_symlink_target="$tmpdir/write-symlink-refused"
"$installer" "$write_symlink_target" --profile small --docs-meta yes --write >"$tmpdir/write-symlink-install.out"
write_outside_scripts="$tmpdir/write-outside-scripts"
mkdir -p "$write_outside_scripts"
rm -rf "$write_symlink_target/scripts"
ln -s "$write_outside_scripts" "$write_symlink_target/scripts"
printf 'outside stays put\n' >"$write_outside_scripts/docs-meta"
snapshot_tree "$write_symlink_target" "$tmpdir/write-symlink-before.sha"
outside_before="$(shasum -a 256 "$write_outside_scripts/docs-meta")"
require_exit 2 "$tmpdir/write-symlink.out" "$agent_docs" upgrade --write --tooling-only "$write_symlink_target"
snapshot_tree "$write_symlink_target" "$tmpdir/write-symlink-after.sha"
outside_after="$(shasum -a 256 "$write_outside_scripts/docs-meta")"
cmp "$tmpdir/write-symlink-before.sha" "$tmpdir/write-symlink-after.sha"
test "$outside_before" = "$outside_after"
require_contains "$tmpdir/write-symlink.out" "existing symlink inside target"
require_contains "$tmpdir/write-symlink.out" "refusing tooling-only write"

write_backup_symlink_target="$tmpdir/write-backup-symlink-refused"
"$installer" "$write_backup_symlink_target" --profile small --docs-meta yes --write >"$tmpdir/write-backup-symlink-install.out"
python3 - "$write_backup_symlink_target" <<'PY'
import hashlib
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
tool = target / "scripts/docs-meta"
tool.write_text("#!/usr/bin/env python3\nprint('old docs-meta')\n", encoding="utf-8")
tool.chmod(tool.stat().st_mode | 0o111)
old_checksum = hashlib.sha256(tool.read_bytes()).hexdigest()
manifest_path = target / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
for record in manifest["files"]:
    if record["path"] == "scripts/docs-meta":
        record["checksum_sha256"] = old_checksum
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
write_outside_backups="$tmpdir/write-outside-backups"
mkdir -p "$write_outside_backups"
ln -s "$write_outside_backups" "$write_backup_symlink_target/.agent-docs/backups"
snapshot_tree "$write_backup_symlink_target" "$tmpdir/write-backup-symlink-before.sha"
require_exit 2 "$tmpdir/write-backup-symlink.out" "$agent_docs" upgrade --write --tooling-only "$write_backup_symlink_target"
snapshot_tree "$write_backup_symlink_target" "$tmpdir/write-backup-symlink-after.sha"
cmp "$tmpdir/write-backup-symlink-before.sha" "$tmpdir/write-backup-symlink-after.sha"
if find "$write_outside_backups" -mindepth 1 -print | grep -q .; then
  echo "Expected backup symlink refusal to leave outside backup directory untouched" >&2
  find "$write_outside_backups" -mindepth 1 -print >&2
  exit 1
fi
require_contains "$tmpdir/write-backup-symlink.out" "backup path would traverse existing symlink inside target"
require_contains "$tmpdir/write-backup-symlink.out" "refusing tooling-only write"

write_backup_nested_symlink_target="$tmpdir/write-backup-nested-symlink-refused"
"$installer" "$write_backup_nested_symlink_target" --profile small --docs-meta yes --write >"$tmpdir/write-backup-nested-symlink-install.out"
python3 - "$write_backup_nested_symlink_target" <<'PY'
import hashlib
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
tool = target / "scripts/docs-meta"
tool.write_text("#!/usr/bin/env python3\nprint('old docs-meta')\n", encoding="utf-8")
tool.chmod(tool.stat().st_mode | 0o111)
old_checksum = hashlib.sha256(tool.read_bytes()).hexdigest()
manifest_path = target / ".agent-docs/manifest.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
for record in manifest["files"]:
    if record["path"] == "scripts/docs-meta":
        record["checksum_sha256"] = old_checksum
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
write_outside_nested_backups="$tmpdir/write-outside-nested-backups"
mkdir -p "$write_outside_nested_backups"
python3 - "$write_backup_nested_symlink_target" "$write_outside_nested_backups" <<'PY'
import datetime
import os
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
outside = pathlib.Path(sys.argv[2])
backup_parent = target / ".agent-docs/backups"
backup_parent.mkdir(parents=True, exist_ok=True)
now = datetime.datetime.now(datetime.timezone.utc)
for offset in range(-1, 5):
    root = backup_parent / (now + datetime.timedelta(seconds=offset)).strftime("%Y%m%dT%H%M%SZ")
    root.mkdir(parents=True, exist_ok=True)
    symlink = root / "scripts"
    if not symlink.exists():
        os.symlink(outside, symlink)
PY
require_exit 2 "$tmpdir/write-backup-nested-symlink.out" "$agent_docs" upgrade --write --tooling-only "$write_backup_nested_symlink_target"
if find "$write_outside_nested_backups" -mindepth 1 -print | grep -q .; then
  echo "Expected nested backup symlink refusal to leave outside backup directory untouched" >&2
  find "$write_outside_nested_backups" -mindepth 1 -print >&2
  exit 1
fi
require_contains "$tmpdir/write-backup-nested-symlink.out" "backup destination would traverse existing symlink inside target"
require_contains "$tmpdir/write-backup-nested-symlink.out" "refusing tooling-only write"

write_parent_file_target="$tmpdir/write-parent-file-refused"
"$installer" "$write_parent_file_target" --profile small --docs-meta yes --write >"$tmpdir/write-parent-file-install.out"
rm -rf "$write_parent_file_target/scripts"
printf 'not a directory\n' >"$write_parent_file_target/scripts"
require_exit 2 "$tmpdir/write-parent-file.out" "$agent_docs" upgrade --write --tooling-only "$write_parent_file_target"
require_absent "$write_parent_file_target/.agent-docs/backups"
require_contains "$tmpdir/write-parent-file.out" "path parent is not a directory"
require_contains "$tmpdir/write-parent-file.out" "refusing tooling-only write"
if grep -Fq -- "Traceback" "$tmpdir/write-parent-file.out"; then
  echo "Expected parent file conflict refusal without traceback" >&2
  cat "$tmpdir/write-parent-file.out" >&2
  exit 1
fi

write_project_owned_target="$tmpdir/write-project-owned"
"$installer" "$write_project_owned_target" --profile small --docs-meta yes --write >"$tmpdir/write-project-owned-install.out"
printf '# Local Agents\n\nLocal truth.\n' >"$write_project_owned_target/AGENTS.md"
project_owned_before="$(shasum -a 256 "$write_project_owned_target/AGENTS.md")"
require_exit 0 "$tmpdir/write-project-owned.out" "$agent_docs" upgrade --write --tooling-only "$write_project_owned_target"
project_owned_after="$(shasum -a 256 "$write_project_owned_target/AGENTS.md")"
test "$project_owned_before" = "$project_owned_after"
require_contains "$tmpdir/write-project-owned.out" "project-owned/manual-review items"
