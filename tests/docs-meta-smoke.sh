#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
docs_meta="$repo_root/scripts/docs-meta"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

docs_root="$tmpdir/docs"
mkdir -p "$docs_root/architecture/areas"

run_meta() {
  "$docs_meta" --root "$docs_root" "$@"
}

require_file() {
  if [[ ! -f "$1" ]]; then
    echo "Expected file does not exist: $1" >&2
    exit 1
  fi
}

require_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -Fq "$pattern" "$file"; then
    echo "Expected $file to contain: $pattern" >&2
    exit 1
  fi
}

idea_path="$(run_meta new idea "Repo Memory Timeline" --domain product)"
spec_path="$(run_meta new spec "Shared Capture Workflow" --domain product --spec-type improvement)"
plan_path="$(run_meta new plan "Shared Capture Implementation" --domain product --spec SPEC-0001)"
impl_path="$(run_meta new impl "Persist Capture Drafts" --domain product --plan PLAN-0001 --spec SPEC-0001)"
adr_path="$(run_meta new adr "Use Append Only Journal" --domain architecture --spec SPEC-0001)"

require_file "$idea_path"
require_file "$spec_path"
require_file "$plan_path"
require_file "$impl_path"
require_file "$adr_path"

require_contains "$idea_path" "id: IDEA-0001"
require_contains "$idea_path" "status: captured"
require_contains "$spec_path" "id: SPEC-0001"
require_contains "$spec_path" "superseded_by: []"
require_contains "$plan_path" "related_prs: []"
require_contains "$impl_path" "parent_plan: PLAN-0001"
require_contains "$impl_path" "related_prs: []"
require_contains "$adr_path" "status: proposed"
require_contains "$adr_path" "related_prs: []"

cat > "$docs_root/architecture/areas/AREA-capture.md" <<'AREA'
---
type: architecture-area
id: AREA-capture
title: Capture
status: active
created_at: "2026-04-25 10:00:00 JST +0900"
updated_at: "2026-04-25 10:00:00 JST +0900"
owners: []
repo_state:
  based_on_commit:
  last_reviewed_commit:
---

# AREA-capture - Capture

- [ ] Define owner boundaries
AREA

mkdir -p "$docs_root/repo-health/audits"
cat > "$docs_root/repo-health/audits/2026-04-25-repo-health-audit.md" <<'AUDIT'
---
type: repo-health-audit
title: Repo Health Audit
status: completed
created_at: "2026-04-25 10:00:00 JST +0900"
updated_at: "2026-04-25 10:30:00 JST +0900"
audit_started_at: "2026-04-25 10:00:00 JST +0900"
audit_ended_at: "2026-04-25 10:30:00 JST +0900"
timezone: "JST +0900"
auditor: smoke-test
scope:
  - docs
  - metadata
checks:
  - scripts/docs-meta check
  - scripts/docs-meta health --write
related_issues: []
related_prs: []
repo_state:
  based_on_commit:
  last_reviewed_commit:
next_audit_due:
---

# 2026-04-25 - Repo Health Audit
AUDIT

next_idea="$(run_meta next idea)"
if [[ "$next_idea" != "IDEA-0002" ]]; then
  echo "Expected next IDEA-0002, got $next_idea" >&2
  exit 1
fi

next_adr="$(run_meta next adr)"
if [[ "$next_adr" != "ADR-0002" ]]; then
  echo "Expected next ADR-0002, got $next_adr" >&2
  exit 1
fi

run_meta set-status ADR-0001 accepted >/dev/null
require_contains "$adr_path" "status: accepted"
run_meta set-status IDEA-0001 exploring >/dev/null
require_contains "$idea_path" "status: exploring"

run_meta update
require_file "$docs_root/IDEAS.md"
require_file "$docs_root/SPECS.md"
require_file "$docs_root/DOCS-REGISTRY.md"
require_file "$docs_root/TODOS.md"
require_file "$docs_root/AREAS.md"
require_file "$docs_root/AUDITS.md"
require_file "$docs_root/ROADMAP-VIEW.md"
require_contains "$docs_root/IDEAS.md" "IDEA-0001"
require_contains "$docs_root/AREAS.md" "AREA-capture"
require_contains "$docs_root/AUDITS.md" "Repo Health Audit"
require_contains "$docs_root/ROADMAP-VIEW.md" "PLAN-0001"
require_contains "$docs_root/TODOS.md" "Define owner boundaries"

run_meta check
run_meta roadmap --json >/tmp/docs-meta-roadmap.json
require_contains /tmp/docs-meta-roadmap.json "\"id\": \"PLAN-0001\""

perl -0pi -e 's/updated_at: "[^"]+"/updated_at: "2026-01-01 00:00:00 JST +0900"/' "$docs_root/architecture/areas/AREA-capture.md"
run_meta health --stale-days 1 >/tmp/docs-meta-health.out
require_contains /tmp/docs-meta-health.out "stale-by-time"
require_contains /tmp/docs-meta-health.out "AREA-capture"
run_meta health --stale-days 1 --write >/tmp/docs-meta-health-write.out
require_file "$docs_root/HEALTH.md"
require_contains "$docs_root/HEALTH.md" "Docs Health"
run_meta health --stale-days 1 --json >/tmp/docs-meta-health.json
require_contains /tmp/docs-meta-health.json "\"code\": \"stale-by-time\""

missing_field="$docs_root/product/specs/SPEC-0002-missing-field.md"
cp "$spec_path" "$missing_field"
perl -0pi -e 's/^title: .+\n//m; s/SPEC-0001/SPEC-0002/g' "$missing_field"
if run_meta check >/tmp/docs-meta-missing-field.out 2>&1; then
  echo "Expected missing title field to fail validation" >&2
  exit 1
fi
require_contains /tmp/docs-meta-missing-field.out "Missing frontmatter field 'title'"
rm "$missing_field"

bad_area="$docs_root/architecture/areas/AREA-bad.md"
cp "$docs_root/architecture/areas/AREA-capture.md" "$bad_area"
perl -0pi -e 's/AREA-capture/AREA-other/g' "$bad_area"
if run_meta check >/tmp/docs-meta-bad-area.out 2>&1; then
  echo "Expected area ID mismatch to fail validation" >&2
  exit 1
fi
require_contains /tmp/docs-meta-bad-area.out "must match filename stem"
rm "$bad_area"

perl -0pi -e 's/status: draft/status: accepted/' "$plan_path"
if run_meta check >/tmp/docs-meta-bad-status.out 2>&1; then
  echo "Expected invalid plan status to fail validation" >&2
  exit 1
fi
require_contains /tmp/docs-meta-bad-status.out "Unknown status 'accepted' for type 'plan'"

echo "docs-meta smoke test passed"
