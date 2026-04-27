#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

require_file() {
  if [[ ! -f "$1" ]]; then
    echo "Expected file does not exist: $1" >&2
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

bin_dir="$tmpdir/bin"
home_dir="$tmpdir/home"

AGENT_DOCS_SOURCE="$repo_root" \
AGENT_DOCS_HOME="$home_dir" \
AGENT_DOCS_BIN_DIR="$bin_dir" \
  "$repo_root/install.sh" --no-run >"$tmpdir/install.out"

require_file "$bin_dir/agent-docs-init"
require_contains "$tmpdir/install.out" "agent-docs-init"

AGENT_DOCS_SOURCE="$repo_root" \
AGENT_DOCS_HOME="$home_dir" \
AGENT_DOCS_BIN_DIR="$bin_dir" \
  "$repo_root/install.sh" --no-run >"$tmpdir/install-again.out"
require_contains "$tmpdir/install-again.out" "already installed"

target="$tmpdir/project"
"$bin_dir/agent-docs-init" "$target" --profile tiny --write >"$tmpdir/init.out"
require_file "$target/AGENTS.md"
require_file "$target/docs/CURRENT_STATE.md"

run_target="$tmpdir/run-project"
resolved_run_target="$(mkdir -p "$run_target" && cd "$run_target" && pwd -P)"
AGENT_DOCS_SOURCE="$repo_root" \
AGENT_DOCS_HOME="$home_dir" \
AGENT_DOCS_BIN_DIR="$bin_dir" \
  "$repo_root/install.sh" -- "$run_target" --profile small --dry-run >"$tmpdir/run.out"

require_contains "$tmpdir/run.out" "Profile: small"
require_contains "$tmpdir/run.out" "Target: $resolved_run_target"
require_contains "$tmpdir/run.out" "Would create: docs/CURRENT_STATE.md"

fakebin="$tmpdir/fakebin"
fake_home="$tmpdir/private-home"
mkdir -p "$fakebin"
cat >"$fakebin/gh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1 $2" != "repo clone" ]]; then
  exit 2
fi
echo "$3 -> $4" >>"$GH_FAKE_LOG"
mkdir -p "$4/scripts"
cat >"$4/scripts/agent-docs-init" <<'PY'
#!/usr/bin/env python3
print("fake init")
PY
chmod +x "$4/scripts/agent-docs-init"
SH
chmod +x "$fakebin/gh"

PATH="$fakebin:$PATH" \
GH_FAKE_LOG="$tmpdir/gh.log" \
AGENT_DOCS_REPO_URL="https://github.com/example/private-docs.git" \
AGENT_DOCS_HOME="$fake_home" \
AGENT_DOCS_BIN_DIR="$tmpdir/private-bin" \
  "$repo_root/install.sh" --no-run >"$tmpdir/private-install.out"

require_contains "$tmpdir/gh.log" "example/private-docs -> $fake_home"
require_contains "$tmpdir/private-install.out" "Installed agent-docs-init"

echo "install smoke test passed"
