#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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

small_target="$tmpdir/small-app"
"$installer" "$small_target" --profile small --dry-run >"$tmpdir/small-dry-run.out"
require_contains "$tmpdir/small-dry-run.out" "Profile: small"
require_contains "$tmpdir/small-dry-run.out" "real app with a few features"
require_contains "$tmpdir/small-dry-run.out" "docs/ROADMAP.md"
require_contains "$tmpdir/small-dry-run.out" "Would create"
require_absent "$small_target/AGENTS.md"

tiny_target="$tmpdir/tiny-app"
"$installer" "$tiny_target" --profile tiny --write >"$tmpdir/tiny-write.out"
require_contains "$tmpdir/tiny-write.out" "Profile: tiny"
require_contains "$tmpdir/tiny-write.out" "Created"
require_file "$tiny_target/AGENTS.md"
require_file "$tiny_target/docs/CURRENT_STATE.md"
require_file "$tiny_target/docs/ARCHITECTURE.md"
require_contains "$tiny_target/AGENTS.md" "Tiny Project"

echo "# existing" >"$tiny_target/AGENTS.md"
if "$installer" "$tiny_target" --profile tiny --write >"$tmpdir/overwrite.out" 2>&1; then
  echo "Expected installer to refuse overwriting existing files" >&2
  exit 1
fi
require_contains "$tmpdir/overwrite.out" "Refusing to overwrite"

meta_target="$tmpdir/meta-app"
"$installer" "$meta_target" --profile small --docs-meta yes --write >"$tmpdir/meta-write.out"
require_file "$meta_target/scripts/docs-meta"
require_file "$meta_target/tests/docs-meta-smoke.sh"
require_contains "$tmpdir/meta-write.out" "scripts/docs-meta"

cwd_target="$tmpdir/cwd-app"
mkdir -p "$cwd_target"
resolved_cwd_target="$(cd "$cwd_target" && pwd -P)"
(cd "$cwd_target" && "$installer" --profile small --dry-run >"$tmpdir/cwd-dry-run.out")
require_contains "$tmpdir/cwd-dry-run.out" "Target: $resolved_cwd_target"
require_contains "$tmpdir/cwd-dry-run.out" "Would create: docs/CURRENT_STATE.md"

if "$installer" >"$tmpdir/no-profile.out" 2>&1; then
  echo "Expected non-interactive run without profile to fail" >&2
  exit 1
fi
require_contains "$tmpdir/no-profile.out" "--profile is required"

echo "agent-docs-init smoke test passed"
