#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command="$repo_root/scripts/agent-continuity"
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

git_env=(
  env
  GIT_AUTHOR_NAME="Agent Continuity Smoke"
  GIT_AUTHOR_EMAIL="agent-continuity-smoke@example.invalid"
  GIT_COMMITTER_NAME="Agent Continuity Smoke"
  GIT_COMMITTER_EMAIL="agent-continuity-smoke@example.invalid"
)

dry_target="$tmpdir/dry-project"
"$command" project new dry-project --path "$dry_target" >"$tmpdir/dry-run.out"
require_absent "$dry_target"
require_contains "$tmpdir/dry-run.out" "Profile: complete (fixed)"
require_contains "$tmpdir/dry-run.out" "git init --initial-branch main"
require_contains "$tmpdir/dry-run.out" "local deterministic verification"
require_contains "$tmpdir/dry-run.out" "Dry run only"

if "$command" project new invalid-project --path "$tmpdir/invalid-project" --github owner/invalid >"$tmpdir/github-pair.out" 2>&1; then
  echo "Expected --github without --visibility to fail" >&2
  exit 1
fi
require_contains "$tmpdir/github-pair.out" "--github and --visibility must be provided together"
require_absent "$tmpdir/invalid-project"

mkdir -p "$tmpdir/default-path-parent/child"
if (cd "$tmpdir/default-path-parent/child" && "$command" project new ../escape >"$tmpdir/default-path.out" 2>&1); then
  echo "Expected a default-path project name to remain one path component" >&2
  exit 1
fi
require_contains "$tmpdir/default-path.out" "project name must be one path component"
require_absent "$tmpdir/default-path-parent/escape"

local_target="$tmpdir/local-project"
mkdir -p "$local_target"
"${git_env[@]}" "$command" project new local-project --path "$local_target" --write >"$tmpdir/local-write.out"
require_file "$local_target/.agent-continuity/manifest.json"
require_file "$local_target/.agent-continuity/bootstrap-receipt.json"
require_file "$local_target/README.md"
require_file "$local_target/.github/workflows/agent-continuity.yml"
require_file "$local_target/scripts/agent-continuity-docs"
require_file "$local_target/scripts/agent-continuity-ci"
require_contains "$local_target/.github/workflows/agent-continuity.yml" "contents: read"
require_contains "$local_target/.github/workflows/agent-continuity.yml" "scripts/agent-continuity-ci"
require_contains "$local_target/README.md" "# local-project"
require_contains "$local_target/README.md" "scripts/agent-continuity-ci"
require_contains "$local_target/AGENTS.md" "# local-project - Agent Index"
if grep -Fq -- "<Repo Name>" "$local_target/AGENTS.md"; then
  echo "Expected project bootstrap to replace the known repository-name placeholder" >&2
  exit 1
fi
require_contains "$tmpdir/local-write.out" "Created complete project"

if [[ "$(git -C "$local_target" branch --show-current)" != "main" ]]; then
  echo "Expected bootstrap branch to be main" >&2
  exit 1
fi
if [[ "$(git -C "$local_target" rev-list --count HEAD)" != "1" ]]; then
  echo "Expected local bootstrap to create one initial commit" >&2
  exit 1
fi
if [[ -n "$(git -C "$local_target" status --porcelain=v1)" ]]; then
  echo "Expected local bootstrap repository to be clean" >&2
  git -C "$local_target" status --short >&2
  exit 1
fi

python3 - "$local_target/.agent-continuity/manifest.json" "$local_target/.agent-continuity/bootstrap-receipt.json" <<'PY'
import json
import sys

manifest = json.load(open(sys.argv[1], encoding="utf-8"))
if manifest.get("profile") != "complete":
    raise SystemExit("Expected project bootstrap to fix profile complete")
if "path" in manifest.get("source", {}):
    raise SystemExit("Fresh manifests must not publish the installer's absolute local source path")
records = {record["path"]: record for record in manifest.get("files", [])}
for path in (
    "scripts/agent-continuity-ci",
    "tests/agent-continuity-ci-smoke.sh",
    ".github/workflows/agent-continuity.yml",
):
    record = records.get(path)
    if not record or record.get("ownership") != "agent-continuity-owned":
        raise SystemExit(f"Expected owned manifest record for {path}")
    if not record.get("checksum_sha256") or not record.get("mode"):
        raise SystemExit(f"Expected checksum and mode for {path}")

receipt = json.load(open(sys.argv[2], encoding="utf-8"))
if receipt.get("project", {}).get("name") != "local-project":
    raise SystemExit("Expected receipt project name")
if receipt.get("project", {}).get("path") != ".":
    raise SystemExit("Expected portable receipt project path")
if receipt.get("requested", {}).get("profile") != "complete":
    raise SystemExit("Expected receipt profile complete")
if receipt.get("completed", {}).get("local_verification") is not True:
    raise SystemExit("Expected completed local verification")
if receipt.get("completed", {}).get("initial_commit") is not True:
    raise SystemExit("Expected completed initial commit")
if receipt.get("requested", {}).get("github") is not None:
    raise SystemExit("Expected local receipt to record no GitHub request")
PY

"$command" ci "$local_target" >"$tmpdir/local-ci.out"
"$local_target/scripts/agent-continuity-ci" >"$tmpdir/local-vendored-ci.out"

before_head="$(git -C "$local_target" rev-parse HEAD)"
if "${git_env[@]}" "$command" project new local-project --path "$local_target" --write >"$tmpdir/repeat.out" 2>&1; then
  echo "Expected bootstrap to refuse an existing non-empty target" >&2
  exit 1
fi
require_contains "$tmpdir/repeat.out" "target must be absent or empty"
if [[ "$(git -C "$local_target" rev-parse HEAD)" != "$before_head" ]]; then
  echo "Expected refused rerun to preserve HEAD" >&2
  exit 1
fi

stub_bin="$tmpdir/stub-bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/gh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$GH_STUB_LOG"
if [[ "$1" != "repo" || "$2" != "create" ]]; then
  echo "Unexpected gh invocation: $*" >&2
  exit 91
fi
source_path=""
visibility_seen=""
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --source)
      source_path="$2"
      shift 2
      ;;
    --private|--public|--internal)
      visibility_seen="$1"
      shift
      ;;
    *)
      shift
      ;;
  esac
done
if [[ "$visibility_seen" != "--private" ]]; then
  echo "Expected private visibility, got $visibility_seen" >&2
  exit 92
fi
if [[ -z "$source_path" || ! -d "$source_path/.git" ]]; then
  echo "Expected --source to name initialized local repo" >&2
  exit 93
fi
"$source_path/scripts/agent-continuity-ci" "$source_path" >"$GH_STUB_LOCAL_CI_LOG"
git -C "$source_path" rev-parse HEAD >>"$GH_STUB_LOG"
git init --bare --initial-branch main "$GH_STUB_REMOTE" >/dev/null
git -C "$source_path" remote add origin "$GH_STUB_REMOTE"
SH
chmod +x "$stub_bin/gh"

remote_target="$tmpdir/remote-project"
GH_STUB_LOG="$tmpdir/gh.log" \
GH_STUB_LOCAL_CI_LOG="$tmpdir/gh-local-ci.log" \
GH_STUB_REMOTE="$tmpdir/remote.git" \
PATH="$stub_bin:$PATH" \
"${git_env[@]}" "$command" project new remote-project \
  --path "$remote_target" \
  --github owner/remote-project \
  --visibility private \
  --write >"$tmpdir/remote-write.out"

require_contains "$tmpdir/gh.log" "repo create owner/remote-project"
require_contains "$tmpdir/gh.log" "--private"
require_contains "$tmpdir/gh-local-ci.log" "Agent Continuity CI passed"
local_head="$(git -C "$remote_target" rev-parse HEAD)"
remote_head="$(git --git-dir "$tmpdir/remote.git" rev-parse refs/heads/main)"
if [[ "$local_head" != "$remote_head" ]]; then
  echo "Expected exact local main commit at origin/main" >&2
  exit 1
fi
python3 - "$remote_target/.agent-continuity/bootstrap-receipt.json" "$local_head" <<'PY'
import json
import sys

receipt = json.load(open(sys.argv[1], encoding="utf-8"))
if receipt.get("requested", {}).get("github") != "owner/remote-project":
    raise SystemExit("Expected requested GitHub repository")
if receipt.get("requested", {}).get("visibility") != "private":
    raise SystemExit("Expected requested private visibility")
completed = receipt.get("completed", {})
if completed.get("github_created") is not True or completed.get("remote_verified") is not True:
    raise SystemExit("Expected completed and verified remote phases")
if not receipt.get("result", {}).get("initial_commit"):
    raise SystemExit("Expected receipt to name the verified initial commit")
if receipt.get("result", {}).get("remote_verified_commit") != receipt.get("result", {}).get("initial_commit"):
    raise SystemExit("Expected receipt to scope remote verification to the verified initial commit")
PY
if [[ -n "$(git -C "$remote_target" status --porcelain=v1)" ]]; then
  echo "Expected remote bootstrap repository to be clean" >&2
  exit 1
fi

echo "agent-continuity project smoke test passed"
