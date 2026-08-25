#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$repo_root/scripts/agent-continuity-ci" "$repo_root"

echo "vendored agent-continuity ci smoke test passed"
