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
lrn_path="$(run_meta new learning "Specs And Plans Stay Separate" --domain repo-health)"
expl_path="$(run_meta new explainer "Specs Plans And Briefs" --domain orientation)"
qst_path="$(run_meta new question "Should Specs And Plans Be One To One" --domain repo-health)"

require_file "$idea_path"
require_file "$spec_path"
require_file "$plan_path"
require_file "$impl_path"
require_file "$adr_path"
require_file "$lrn_path"
require_file "$expl_path"
require_file "$qst_path"

require_contains "$idea_path" "id: IDEA-0001"
require_contains "$idea_path" "status: captured"
require_contains "$spec_path" "id: SPEC-0001"
require_contains "$spec_path" "superseded_by: []"
require_contains "$plan_path" "related_prs: []"
require_contains "$impl_path" "parent_plan: PLAN-0001"
require_contains "$impl_path" "related_prs: []"
require_contains "$adr_path" "status: proposed"
require_contains "$adr_path" "related_prs: []"
require_contains "$lrn_path" "id: LRN-0001"
require_contains "$lrn_path" "status: active"
require_contains "$lrn_path" "learning_type: lesson"
require_contains "$expl_path" "id: EXPL-0001"
require_contains "$expl_path" "type: explainer"
require_contains "$expl_path" "explainer_type: concept"
require_contains "$qst_path" "id: QST-0001"
require_contains "$qst_path" "status: open"
require_contains "$qst_path" "question_type: product"

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

cat >> "$plan_path" <<'TODOS'

## Structured Todo Smoke

- [ ] TODO-0001 [ready] [owner:main-agent] [skill:docs-writer] [plan:PLAN-0001] Define stable todo model
- [ ] TODO-0002 [blocked] [owner:main-agent] [skill:docs-writer] [plan:PLAN-0001] [brief:IMPL-0001-01] [blocker:TODO-0001] Wire todo checks
- [x] TODO-0003 [done] [owner:main-agent] [skill:docs-writer] [plan:PLAN-0001] [verification:tests/docs-meta-smoke.sh] Document todo workflow
- [ ] TODO-0004 [in_progress] [owner:main-agent] [agent:smoke-agent] [updated:2026-04-25 10:20:00 JST +0900] [skill:docs-writer] [plan:PLAN-0001] Claim todo work
- [ ] Follow up on TODO-0001 in review notes
- [ ] Local task with a | pipe

```text
- [ ] TODO-9999 [bogus] This example should not be parsed.
```
TODOS

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

next_lrn="$(run_meta next lrn)"
if [[ "$next_lrn" != "LRN-0002" ]]; then
  echo "Expected next LRN-0002, got $next_lrn" >&2
  exit 1
fi

next_expl="$(run_meta next expl)"
if [[ "$next_expl" != "EXPL-0002" ]]; then
  echo "Expected next EXPL-0002, got $next_expl" >&2
  exit 1
fi

next_qst="$(run_meta next qst)"
if [[ "$next_qst" != "QST-0002" ]]; then
  echo "Expected next QST-0002, got $next_qst" >&2
  exit 1
fi

next_todo="$(run_meta next todo)"
if [[ "$next_todo" != "TODO-0005" ]]; then
  echo "Expected next TODO-0005, got $next_todo" >&2
  exit 1
fi

run_meta set-status ADR-0001 accepted >/dev/null
require_contains "$adr_path" "status: accepted"
run_meta set-status IDEA-0001 exploring >/dev/null
require_contains "$idea_path" "status: exploring"
run_meta set-status LRN-0001 draft >/dev/null
require_contains "$lrn_path" "status: draft"

run_meta update
require_file "$docs_root/IDEAS.md"
require_file "$docs_root/SPECS.md"
require_file "$docs_root/LEARNINGS.md"
require_file "$docs_root/EXPLAINERS.md"
require_file "$docs_root/QUESTIONS.md"
require_file "$docs_root/DOCS-REGISTRY.md"
require_file "$docs_root/TODOS.md"
require_file "$docs_root/AREAS.md"
require_file "$docs_root/AUDITS.md"
require_file "$docs_root/ROADMAP-VIEW.md"
require_contains "$docs_root/IDEAS.md" "IDEA-0001"
require_contains "$docs_root/AREAS.md" "AREA-capture"
require_contains "$docs_root/AUDITS.md" "Repo Health Audit"
require_contains "$docs_root/LEARNINGS.md" "LRN-0001"
require_contains "$docs_root/LEARNINGS.md" "Specs And Plans Stay Separate"
require_contains "$docs_root/EXPLAINERS.md" "EXPL-0001"
require_contains "$docs_root/EXPLAINERS.md" "Specs Plans And Briefs"
require_contains "$docs_root/QUESTIONS.md" "QST-0001"
require_contains "$docs_root/QUESTIONS.md" "Should Specs And Plans Be One To One"
require_contains "$docs_root/ROADMAP-VIEW.md" "PLAN-0001"
require_contains "$docs_root/ROADMAP-VIEW.md" "PLAN-0001-shared-capture-implementation"
require_contains "$docs_root/ROADMAP-VIEW.md" "type: generated-view"
require_contains "$docs_root/ROADMAP-VIEW.md" "updated_at:"
require_contains "$docs_root/TODOS.md" "Define owner boundaries"
require_contains "$docs_root/TODOS.md" "Structured Todos"
require_contains "$docs_root/TODOS.md" "TODO-0001"
require_contains "$docs_root/TODOS.md" "Local task with a \\| pipe"

run_meta check
run_meta check-todos >/tmp/docs-meta-check-todos.out 2>&1
require_contains /tmp/docs-meta-check-todos.out "No todo issues found."
run_meta check-todos --strict >/tmp/docs-meta-check-todos-strict.out 2>&1
require_contains /tmp/docs-meta-check-todos-strict.out "WARN:"
run_meta todos --status ready >/tmp/docs-meta-todos-ready.out
require_contains /tmp/docs-meta-todos-ready.out "TODO-0001"
run_meta todos --owner main-agent --structured-only >/tmp/docs-meta-todos-owner.out
require_contains /tmp/docs-meta-todos-owner.out "TODO-0002"
run_meta todos --agent smoke-agent --structured-only >/tmp/docs-meta-todos-agent.out
require_contains /tmp/docs-meta-todos-agent.out "TODO-0004"
run_meta todos --plan PLAN-0001 --json >/tmp/docs-meta-todos.json
require_contains /tmp/docs-meta-todos.json "\"id\": \"TODO-0001\""
require_contains /tmp/docs-meta-todos.json "\"agent\": \"smoke-agent\""
run_meta todos TODO-0003 --all >/tmp/docs-meta-todos-id.out
require_contains /tmp/docs-meta-todos-id.out "TODO-0003"
run_meta todos --structured-only --all >/tmp/docs-meta-todos-structured.out
if grep -Fq "Follow up on TODO-0001" /tmp/docs-meta-todos-structured.out; then
  echo "Expected non-leading TODO reference to remain a local checkbox" >&2
  exit 1
fi
run_meta roadmap --json >/tmp/docs-meta-roadmap.json
require_contains /tmp/docs-meta-roadmap.json "\"id\": \"PLAN-0001\""
require_contains /tmp/docs-meta-roadmap.json "\"plan_name\": \"PLAN-0001-shared-capture-implementation\""
require_file "$docs_root/ROADMAP-VIEW.md"
run_meta view todos >/tmp/docs-meta-view-todos.md
require_contains /tmp/docs-meta-view-todos.md "Docs Todos"
require_contains "$docs_root/TODOS.md" "updated_at:"

cat >> "$plan_path" <<'BADTODO'

- [ ] TODO-0001 [ready] Duplicate todo ID
- [x] TODO-0005 [in_progress] [owner:main-agent] Checked but active
- [ ] TODO-0006 [done] Open but done
- [ ] TODO-0007 [nonsense] Invalid status
- [ ] TODO-0008 [in_progress] Missing owner
- [ ] TODO-0009 [in_progress] [owner:main-agent] Missing agent and timestamp
- [ ] TODO-0010 [blocked] Missing blocker reason
- [x] TODO-0011 [done] Missing done evidence
- [ ] TODO-0012 [ready] [plan:PLAN-9999] Missing plan
BADTODO
if run_meta check-todos >/tmp/docs-meta-bad-todos.out 2>&1; then
  echo "Expected invalid structured todos to fail validation" >&2
  exit 1
fi
require_contains /tmp/docs-meta-bad-todos.out "Duplicate todo ID TODO-0001"
require_contains /tmp/docs-meta-bad-todos.out "invalid todo status"
require_contains /tmp/docs-meta-bad-todos.out "in_progress status without owner"
require_contains /tmp/docs-meta-bad-todos.out "in_progress status without agent"
require_contains /tmp/docs-meta-bad-todos.out "in_progress status without updated timestamp"
require_contains /tmp/docs-meta-bad-todos.out "blocked status without blocker"
require_contains /tmp/docs-meta-bad-todos.out "done status without verification"
require_contains /tmp/docs-meta-bad-todos.out "references missing plan PLAN-9999"
perl -0pi -e 's/\n- \[ \] TODO-0001 \[ready\] Duplicate todo ID\n- \[x\] TODO-0005 \[in_progress\] \[owner:main-agent\] Checked but active\n- \[ \] TODO-0006 \[done\] Open but done\n- \[ \] TODO-0007 \[nonsense\] Invalid status\n- \[ \] TODO-0008 \[in_progress\] Missing owner\n- \[ \] TODO-0009 \[in_progress\] \[owner:main-agent\] Missing agent and timestamp\n- \[ \] TODO-0010 \[blocked\] Missing blocker reason\n- \[x\] TODO-0011 \[done\] Missing done evidence\n- \[ \] TODO-0012 \[ready\] \[plan:PLAN-9999\] Missing plan\n//' "$plan_path"

mkdir -p "$docs_root/link-fixtures"
cat > "$docs_root/link-fixtures/target.md" <<'TARGET'
# Target
TARGET
cat > "$docs_root/link-fixtures/source.md" <<'SOURCE'
# Source

- [Target](target.md)
- [Spec](/product/specs/SPEC-0001-shared-capture-workflow.md)
- [Missing](missing.md)
- [[target.md]]
- `<not-a-link>`

```text
[also-not-a-link](missing-in-code.md)
```
SOURCE

run_meta links link-fixtures/source.md >/tmp/docs-meta-links.out
require_contains /tmp/docs-meta-links.out "target.md"
require_contains /tmp/docs-meta-links.out "wiki-link"
run_meta backlinks link-fixtures/target.md >/tmp/docs-meta-backlinks.out
require_contains /tmp/docs-meta-backlinks.out "link-fixtures/source.md"
if run_meta check-links >/tmp/docs-meta-check-links.out 2>&1; then
  echo "Expected missing link to fail check-links" >&2
  exit 1
fi
require_contains /tmp/docs-meta-check-links.out "missing.md"
if grep -Fq "not-a-link" /tmp/docs-meta-check-links.out || grep -Fq "missing-in-code" /tmp/docs-meta-check-links.out; then
  echo "Expected check-links to ignore links inside inline and fenced code" >&2
  exit 1
fi
perl -0pi -e 's/^- \[Missing\]\(missing\.md\)\n//m' "$docs_root/link-fixtures/source.md"
if ! run_meta check-links >/tmp/docs-meta-check-links-clean.out 2>&1; then
  cat /tmp/docs-meta-check-links-clean.out >&2
  echo "Expected check-links to pass after removing missing link" >&2
  exit 1
fi
run_meta normalize-links --style relative --dry-run >/tmp/docs-meta-normalize-dry-run.out
require_contains /tmp/docs-meta-normalize-dry-run.out "/product/specs/SPEC-0001-shared-capture-workflow.md -> ../product/specs/SPEC-0001-shared-capture-workflow.md"
run_meta normalize-links --style relative --write >/tmp/docs-meta-normalize-write.out
require_contains "$docs_root/link-fixtures/source.md" "../product/specs/SPEC-0001-shared-capture-workflow.md"
run_meta move link-fixtures/target.md link-fixtures/moved/target-new.md --dry-run >/tmp/docs-meta-move-dry-run.out
require_contains /tmp/docs-meta-move-dry-run.out "target.md -> moved/target-new.md"
run_meta move link-fixtures/target.md link-fixtures/moved/target-new.md --write >/tmp/docs-meta-move-write.out
require_file "$docs_root/link-fixtures/moved/target-new.md"
require_contains "$docs_root/link-fixtures/source.md" "moved/target-new.md"
run_meta backlinks link-fixtures/moved/target-new.md >/tmp/docs-meta-backlinks-moved.out
require_contains /tmp/docs-meta-backlinks-moved.out "link-fixtures/source.md"
run_meta orphans --exclude 'link-fixtures/*' >/tmp/docs-meta-orphans.out
if grep -Fq "link-fixtures/target.md" /tmp/docs-meta-orphans.out; then
  echo "Expected orphan exclude pattern to suppress link-fixtures docs" >&2
  exit 1
fi

perl -0pi -e 's/updated_at: "[^"]+"/updated_at: "2026-01-01 00:00:00 JST +0900"/' "$docs_root/architecture/areas/AREA-capture.md"
run_meta health --stale-days 1 >/tmp/docs-meta-health.out
require_contains /tmp/docs-meta-health.out "stale-by-time"
require_contains /tmp/docs-meta-health.out "AREA-capture"
require_contains "$docs_root/HEALTH.md" "updated_at:"
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
