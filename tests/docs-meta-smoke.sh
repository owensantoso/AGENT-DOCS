#!/usr/bin/env bash
set -euo pipefail

# Legacy compatibility smoke entry point.
test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$test_dir/agent-continuity-docs-smoke.sh" "$@"
