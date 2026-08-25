#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
installer="$repo_root/scripts/agent-continuity-init"
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

expect_failure() {
  local expected="$1"
  local output="$2"
  shift 2
  if "$@" >"$output" 2>&1; then
    echo "Expected command to fail: $*" >&2
    exit 1
  fi
  require_contains "$output" "$expected"
}

target="$tmpdir/complete-project"
"$installer" "$target" --profile complete --write >"$tmpdir/init.out"
git -C "$target" init -b main >/dev/null
git -C "$target" config user.name "Agent Continuity Smoke"
git -C "$target" config user.email "agent-continuity-smoke@example.invalid"
git -C "$target" add .
git -C "$target" commit -m "Initial fixture" >/dev/null

require_file "$target/scripts/agent-continuity-ci"
require_file "$target/tests/agent-continuity-ci-smoke.sh"
require_file "$target/.github/workflows/agent-continuity.yml"
"$target/scripts/agent-continuity-ci" >"$tmpdir/healthy.out"
require_contains "$tmpdir/healthy.out" "Agent Continuity CI passed"
"$repo_root/scripts/agent-continuity" ci "$target" >"$tmpdir/dispatched.out"
require_contains "$tmpdir/dispatched.out" "Agent Continuity CI passed"

printf '\n# checksum drift\n' >>"$target/scripts/agent-continuity-ci"
expect_failure "checksum mismatch" "$tmpdir/checksum.out" "$target/scripts/agent-continuity-ci" "$target"
git -C "$target" checkout -- scripts/agent-continuity-ci

chmod 0644 "$target/scripts/agent-continuity-ci"
expect_failure "mode mismatch" "$tmpdir/mode.out" "$repo_root/scripts/agent-continuity" ci "$target"
git -C "$target" checkout -- scripts/agent-continuity-ci

printf '\n[Missing local doc](missing-local-doc.md)\n' >>"$target/docs/orientation/CURRENT_STATE.md"
expect_failure "missing-local-doc.md" "$tmpdir/link.out" "$target/scripts/agent-continuity-ci" "$target"
git -C "$target" checkout -- docs/orientation/CURRENT_STATE.md

printf '\n- [ ] TODO-9001 [bogus] Invalid structured todo\n' >>"$target/docs/orientation/CURRENT_STATE.md"
expect_failure "invalid todo status" "$tmpdir/todo.out" "$target/scripts/agent-continuity-ci" "$target"
git -C "$target" checkout -- docs/orientation/CURRENT_STATE.md

stale_source="$("$target/scripts/agent-continuity-docs" --root "$target/docs" new idea "Stale View Fixture" --domain product)"
expect_failure "generated" "$tmpdir/generated.out" "$target/scripts/agent-continuity-ci" "$target"
mv "$stale_source" "$tmpdir/stale-source.md"

printf 'trailing whitespace   \n' >>"$target/AGENTS.md"
expect_failure "whitespace" "$tmpdir/diff-check.out" "$target/scripts/agent-continuity-ci" "$target"

echo "agent-continuity ci smoke test passed"
