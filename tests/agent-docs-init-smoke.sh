#!/usr/bin/env bash
set -euo pipefail

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$test_dir/agent-continuity-init-smoke.sh" "$@"
