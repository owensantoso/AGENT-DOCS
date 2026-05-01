#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
check="$repo_root/scripts/changelog-check"
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

make_repo() {
  local target="$1"
  mkdir -p "$target"
  git -C "$target" init --quiet
  git -C "$target" config user.email "test@example.com"
  git -C "$target" config user.name "Test User"
  cat >"$target/README.md" <<'MD'
# Test Docs
MD
  cat >"$target/CHANGELOG.md" <<'MD'
# Changelog

## Unreleased

- Initial entry.
MD
  mkdir -p "$target/plans"
  cat >"$target/plans/internal.md" <<'MD'
# Internal Plan
MD
  git -C "$target" add .
  git -C "$target" commit --quiet -m "Initial state"
}

commit_change() {
  local target="$1"
  local message="$2"
  git -C "$target" add .
  git -C "$target" commit --quiet -m "$message"
}

fail_repo="$tmpdir/fail"
make_repo "$fail_repo"
printf '\nPublic setup details.\n' >>"$fail_repo/README.md"
commit_change "$fail_repo" "Update public setup docs"
if "$check" --repo "$fail_repo" --base HEAD~1 --head HEAD >"$tmpdir/fail.out" 2>&1; then
  echo "Expected adopter-facing README change without changelog to fail" >&2
  exit 1
fi
require_contains "$tmpdir/fail.out" "CHANGELOG.md"
require_contains "$tmpdir/fail.out" "README.md"

script_repo="$tmpdir/script"
make_repo "$script_repo"
mkdir -p "$script_repo/scripts"
printf '#!/usr/bin/env bash\n' >"$script_repo/scripts/changelog-check"
commit_change "$script_repo" "Update changelog checker"
if "$check" --repo "$script_repo" --base HEAD~1 --head HEAD >"$tmpdir/script.out" 2>&1; then
  echo "Expected changelog checker change without changelog to fail" >&2
  exit 1
fi
require_contains "$tmpdir/script.out" "scripts/changelog-check"

changelog_repo="$tmpdir/changelog"
make_repo "$changelog_repo"
printf '\nPublic setup details.\n' >>"$changelog_repo/README.md"
printf '\n- Documented public setup change.\n' >>"$changelog_repo/CHANGELOG.md"
commit_change "$changelog_repo" "Update public setup docs with changelog"
"$check" --repo "$changelog_repo" --base HEAD~1 --head HEAD >"$tmpdir/changelog.out"

internal_repo="$tmpdir/internal"
make_repo "$internal_repo"
printf '\nPrivate planning details.\n' >>"$internal_repo/plans/internal.md"
commit_change "$internal_repo" "Update internal plan"
"$check" --repo "$internal_repo" --base HEAD~1 --head HEAD >"$tmpdir/internal.out"

exempt_repo="$tmpdir/exempt"
make_repo "$exempt_repo"
cat >"$exempt_repo/install.sh" <<'SH'
#!/usr/bin/env bash
echo install
SH
commit_change "$exempt_repo" $'Update installer comment\n\nChange-Record: not-needed'
"$check" --repo "$exempt_repo" --base HEAD~1 --head HEAD >"$tmpdir/exempt.out"
require_contains "$tmpdir/exempt.out" "Change-Record: not-needed"

ci_exempt_repo="$tmpdir/ci-exempt"
make_repo "$ci_exempt_repo"
git -C "$ci_exempt_repo" update-ref refs/remotes/origin/main HEAD
cat >"$ci_exempt_repo/install.sh" <<'SH'
#!/usr/bin/env bash
echo install
SH
commit_change "$ci_exempt_repo" $'Update installer comment\n\nChange-Record: not-needed'
GITHUB_BASE_REF=main "$check" --repo "$ci_exempt_repo" >"$tmpdir/ci-exempt.out"
require_contains "$tmpdir/ci-exempt.out" "Change-Record: not-needed"

message_file_repo="$tmpdir/message-file"
make_repo "$message_file_repo"
mkdir -p "$message_file_repo/scaffold"
printf 'Reusable template.\n' >"$message_file_repo/scaffold/AGENTS.md"
commit_change "$message_file_repo" "Update scaffold"
printf 'Change-Record: not-needed\n' >"$tmpdir/message.txt"
"$check" --repo "$message_file_repo" --base HEAD~1 --head HEAD --message-file "$tmpdir/message.txt" >"$tmpdir/message-file.out"

echo "changelog check smoke test passed"
