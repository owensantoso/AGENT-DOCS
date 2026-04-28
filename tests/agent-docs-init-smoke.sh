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

mkdir -p "$small_target/docs"
echo "# existing docs" >"$small_target/docs/README.md"
"$installer" "$small_target" --profile small --dry-run >"$tmpdir/small-existing-dry-run.out"
require_contains "$tmpdir/small-existing-dry-run.out" "Existing target files found"
require_contains "$tmpdir/small-existing-dry-run.out" "docs/README.md"
require_contains "$tmpdir/small-existing-dry-run.out" "Write mode will refuse"

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

symlink_target="$tmpdir/symlink-app"
outside_target="$tmpdir/outside"
mkdir -p "$symlink_target" "$outside_target"
ln -s "$outside_target" "$symlink_target/docs"
if "$installer" "$symlink_target" --profile tiny --write >"$tmpdir/symlink-write.out" 2>&1; then
  echo "Expected installer to refuse writing through symlinked target paths" >&2
  exit 1
fi
require_contains "$tmpdir/symlink-write.out" "Refusing to write through symlinked target path"
require_absent "$outside_target/CURRENT_STATE.md"

meta_target="$tmpdir/meta-app"
"$installer" "$meta_target" --profile small --docs-meta yes --write >"$tmpdir/meta-write.out"
require_file "$meta_target/scripts/docs-meta"
require_file "$meta_target/tests/docs-meta-smoke.sh"
require_contains "$tmpdir/meta-write.out" "scripts/docs-meta"

"$installer" "$tmpdir/meta-preview-app" --profile small --docs-meta yes --dry-run >"$tmpdir/meta-preview.out"
python3 - "$tmpdir/meta-preview.out" <<'PY'
import sys

text = open(sys.argv[1], encoding="utf-8").read()
preview = text.split("Structure preview:", 1)[1].split("\n\nTarget:", 1)[0]
if "scripts/" not in preview or "docs-meta" not in preview:
    raise SystemExit("Expected explicit docs-meta choice to appear in structure preview")
PY

growing_target="$tmpdir/growing-app"
"$installer" "$growing_target" --profile growing --write >"$tmpdir/growing-write.out"
require_file "$growing_target/docs/repo-health/audits/README.md"
require_file "$growing_target/docs/repo-health/audits/audit-profile.md"
require_file "$growing_target/docs/repo-health/audits/guides/architecture.md"
require_file "$growing_target/docs/repo-health/audits/guides/test-coverage.md"
require_file "$growing_target/docs/repo-health/audits/guides/docs-health.md"
require_file "$growing_target/scripts/docs-meta"
require_contains "$tmpdir/growing-write.out" "docs/repo-health/audits/README.md"
require_contains "$tmpdir/growing-write.out" "docs/repo-health/audits/guides/architecture.md"

cwd_target="$tmpdir/cwd-app"
mkdir -p "$cwd_target"
resolved_cwd_target="$(cd "$cwd_target" && pwd -P)"
(cd "$cwd_target" && "$installer" --profile small --dry-run >"$tmpdir/cwd-dry-run.out")
require_contains "$tmpdir/cwd-dry-run.out" "Target: $resolved_cwd_target"
require_contains "$tmpdir/cwd-dry-run.out" "Would create: docs/CURRENT_STATE.md"

full_target="$tmpdir/full-app"
"$installer" "$full_target" --profile full --dry-run >"$tmpdir/full-dry-run.out"
require_contains "$tmpdir/full-dry-run.out" "├── docs/"
require_contains "$tmpdir/full-dry-run.out" "│   ├── architecture/"
require_contains "$tmpdir/full-dry-run.out" "│   ├── decisions/"
require_contains "$tmpdir/full-dry-run.out" "│   ├── marketing/"
require_contains "$tmpdir/full-dry-run.out" "│   ├── operations/"
require_contains "$tmpdir/full-dry-run.out" "│   ├── orientation/"
require_contains "$tmpdir/full-dry-run.out" "│   ├── product/"
require_contains "$tmpdir/full-dry-run.out" "│   ├── repo-health/"
require_contains "$tmpdir/full-dry-run.out" "│   └── research/"
require_contains "$tmpdir/full-dry-run.out" "├── scripts/"
require_contains "$tmpdir/full-dry-run.out" "│   └── docs-meta"
if grep -Fq -- "areas:" "$tmpdir/full-dry-run.out"; then
  echo "Expected full profile preview to show docs areas as tree rows, not an inline areas list" >&2
  exit 1
fi
require_contains "$tmpdir/full-dry-run.out" "Would create: docs/orientation/CURRENT_STATE.md"
require_contains "$tmpdir/full-dry-run.out" "Would create: docs/marketing/plans/marketing-plan.md"
require_contains "$tmpdir/full-dry-run.out" "Would create: docs/operations/checklists/release-checklist.md"
docs_meta_action_count="$(grep -Fc -- "Would create: scripts/docs-meta" "$tmpdir/full-dry-run.out")"
if [[ "$docs_meta_action_count" != "1" ]]; then
  echo "Expected full profile dry run to create scripts/docs-meta once, got $docs_meta_action_count" >&2
  exit 1
fi

"$installer" "$tmpdir/full-no-meta-app" --profile full --docs-meta no --dry-run >"$tmpdir/full-no-meta-dry-run.out"
require_contains "$tmpdir/full-no-meta-dry-run.out" "└── docs/"
if grep -Fq -- "tooling: scripts/docs-meta" "$tmpdir/full-no-meta-dry-run.out"; then
  echo "Expected full profile without docs-meta to hide tooling row" >&2
  exit 1
fi

python3 - "$installer" "$tmpdir/interactive-app" >"$tmpdir/interactive-picker.out" <<'PY'
import os
import select
import subprocess
import sys
import time

installer = sys.argv[1]
target = sys.argv[2]
master, slave = os.openpty()
env = dict(os.environ)
env["COLUMNS"] = "132"
env["LINES"] = "24"
process = subprocess.Popen(
    [installer, target],
    stdin=slave,
    stdout=slave,
    stderr=slave,
    close_fds=True,
    env=env,
)
os.close(slave)

output = bytearray()
sent = False
deadline = time.time() + 5
try:
    while time.time() < deadline:
        ready, _, _ = select.select([master], [], [], 0.1)
        if ready:
            try:
                chunk = os.read(master, 4096)
            except OSError:
                break
            if not chunk:
                break
            output.extend(chunk)
            if not sent and b"Use arrow keys" in output:
                os.write(master, b"\x1b[B\r")
                sent = True
        if process.poll() is not None:
            break
finally:
    try:
        os.close(master)
    except OSError:
        pass

try:
    process.wait(timeout=1)
except subprocess.TimeoutExpired:
    process.kill()
    process.wait()

text = output.decode("utf-8", errors="replace")
print(text)
if process.returncode != 0:
    raise SystemExit(process.returncode)
if "Profile: growing" not in text:
    raise SystemExit("Expected down-arrow interactive picker to choose growing")
if "Use arrow keys or j/k" not in text:
    raise SystemExit("Expected picker to advertise vertical navigation")
if "\x1b[1;7m> growing" not in text:
    raise SystemExit("Expected selected profile row to be styled")
if "Structure" not in text or "Template/doc types" not in text:
    raise SystemExit("Expected selected profile details to use two columns")
if "Planning" not in text or "PLAN-* - parent plan" not in text:
    raise SystemExit("Expected template list to be grouped with explanations")
if "AGENTS.md - agent entry notes" in text or "CURRENT_STATE.md - what is true now" in text:
    raise SystemExit("Expected template list to avoid explaining one-off core files")
detail_lines = [line for line in text.splitlines() if "Template/doc types" in line]
if not detail_lines:
    raise SystemExit("Expected template column header")
template_col = detail_lines[-1].index("Template/doc types")
if template_col > 64:
    raise SystemExit(f"Expected fixed template column near the tree, got column {template_col}")
if "├── docs/" not in text:
    raise SystemExit("Expected interactive preview to render a tree")
if "Legend: \x1b[36mstart here\x1b[0m, \x1b[2mtooling\x1b[0m" not in text:
    raise SystemExit("Expected preview to label visual categories")
if "\x1b[36morientation/\x1b[0m" not in text:
    raise SystemExit("Expected interactive tree to include nested folders")
if "\x1b[36mROADMAP.md\x1b[0m" not in text:
    raise SystemExit("Expected interactive tree to include the growing roadmap")
if "\x1b[1mROADMAP.md" in text:
    raise SystemExit("Expected preview to avoid bold-only start-here styling")
if ".gitkeep" in text:
    raise SystemExit("Expected interactive preview to hide .gitkeep placeholders")
if "── README.md" in text:
    raise SystemExit("Expected scaffold preview to hide nested README placeholders")
if text.count("\x1b[2J") > 1:
    raise SystemExit("Expected interactive picker to avoid full-screen clear on every redraw")
PY
require_contains "$tmpdir/interactive-picker.out" "Profile: growing"
require_contains "$tmpdir/interactive-picker.out" "├── docs/"
require_contains "$tmpdir/interactive-picker.out" $'\033[36mROADMAP.md\033[0m'

python3 - "$installer" "$tmpdir/small-terminal-app" >"$tmpdir/small-terminal-picker.out" <<'PY'
import os
import select
import subprocess
import sys
import time

installer = sys.argv[1]
target = sys.argv[2]
master, slave = os.openpty()
env = dict(os.environ)
env["COLUMNS"] = "80"
env["LINES"] = "16"
process = subprocess.Popen(
    [installer, target],
    stdin=slave,
    stdout=slave,
    stderr=slave,
    close_fds=True,
    env=env,
)
os.close(slave)

output = bytearray()
sent = False
deadline = time.time() + 5
try:
    while time.time() < deadline:
        ready, _, _ = select.select([master], [], [], 0.1)
        if ready:
            try:
                chunk = os.read(master, 4096)
            except OSError:
                break
            if not chunk:
                break
            output.extend(chunk)
            if not sent and b"Use arrow keys" in output:
                os.write(master, b"\x1b[B\x1b[B\r")
                sent = True
        if process.poll() is not None:
            break
finally:
    try:
        os.close(master)
    except OSError:
        pass

try:
    process.wait(timeout=1)
except subprocess.TimeoutExpired:
    process.kill()
    process.wait()

text = output.decode("utf-8", errors="replace")
print(text)
if process.returncode != 0:
    raise SystemExit(process.returncode)
screen = text.split("\x1b[H\x1b[J")[-1].split("\x1b[?25hProfile:", 1)[0]
screen_lines = [line for line in screen.splitlines() if line]
if len(screen_lines) > 16:
    raise SystemExit(f"Expected small terminal screen to fit in 16 lines, got {len(screen_lines)}")
if "\x1b[1;7m> full" not in screen:
    raise SystemExit("Expected full profile selection to remain visible in small terminal")
if "… " not in screen:
    raise SystemExit("Expected oversized selected profile details to be summarized in a small terminal")
if "Template/doc types" not in screen:
    raise SystemExit("Expected template column to stay visible in a small terminal")
if "Structure summary" not in screen or "exact file list after Enter" not in screen:
    raise SystemExit("Expected full picker to describe the structure as a summary")
if "ADR-0000" in screen or "AREA-EXAMPLE.md" in screen:
    raise SystemExit("Expected full picker summary to hide example leaf files")
if "areas:" in screen:
    raise SystemExit("Expected full picker summary to show doc areas as tree rows")
if "architecture/" not in screen or "decisions/" not in screen:
    raise SystemExit("Expected full picker summary to start listing major doc areas")
if "\x1b[36mProduct work" in screen or "\x1b[36mPlanning" in screen:
    raise SystemExit("Expected template group headers not to reuse start-here color")
PY

python3 - "$installer" "$tmpdir/target-picker-app" >"$tmpdir/target-picker.out" <<'PY'
import os
import select
import subprocess
import sys
import time

installer = sys.argv[1]
target = sys.argv[2]
os.makedirs(target, exist_ok=True)
master, slave = os.openpty()
env = dict(os.environ)
env["COLUMNS"] = "100"
env["LINES"] = "18"
process = subprocess.Popen(
    [installer, "--profile", "small"],
    cwd=target,
    stdin=slave,
    stdout=slave,
    stderr=slave,
    close_fds=True,
    env=env,
)
os.close(slave)

output = bytearray()
sent = False
deadline = time.time() + 5
try:
    while time.time() < deadline:
        ready, _, _ = select.select([master], [], [], 0.1)
        if ready:
            try:
                chunk = os.read(master, 4096)
            except OSError:
                break
            if not chunk:
                break
            output.extend(chunk)
            if not sent and b"Choose target folder" in output:
                os.write(master, b"\r")
                sent = True
        if process.poll() is not None:
            break
finally:
    try:
        os.close(master)
    except OSError:
        pass

try:
    process.wait(timeout=1)
except subprocess.TimeoutExpired:
    process.kill()
    process.wait()

text = output.decode("utf-8", errors="replace")
print(text)
if process.returncode != 0:
    raise SystemExit(process.returncode)
if "Choose target folder" not in text:
    raise SystemExit("Expected target selection to use the target picker")
if "\x1b[1;7m> current" not in text:
    raise SystemExit("Expected current folder target row to be selected by default")
if "╭" in text or "Install into this folder" in text:
    raise SystemExit("Expected target picker to use list rows instead of cards")
if f"Target: {os.path.realpath(target)}" not in text:
    raise SystemExit("Expected target picker to select the current folder")
PY

python3 - "$installer" "$tmpdir/target-picker-source" "$tmpdir/target-picker-other" >"$tmpdir/target-picker-other.out" <<'PY'
import os
import select
import subprocess
import sys
import time

installer = sys.argv[1]
source = sys.argv[2]
other = sys.argv[3]
os.makedirs(source, exist_ok=True)
master, slave = os.openpty()
env = dict(os.environ)
env["COLUMNS"] = "100"
env["LINES"] = "18"
process = subprocess.Popen(
    [installer, "--profile", "small"],
    cwd=source,
    stdin=slave,
    stdout=slave,
    stderr=slave,
    close_fds=True,
    env=env,
)
os.close(slave)

output = bytearray()
selected_other = False
typed_path = False
deadline = time.time() + 5
try:
    while time.time() < deadline:
        ready, _, _ = select.select([master], [], [], 0.1)
        if ready:
            try:
                chunk = os.read(master, 4096)
            except OSError:
                break
            if not chunk:
                break
            output.extend(chunk)
            if not selected_other and b"Choose target folder" in output:
                os.write(master, b"\x1b[B\r")
                selected_other = True
            if selected_other and not typed_path and b"Target folder path:" in output:
                os.write(master, other.encode("utf-8") + b"\r")
                typed_path = True
        if process.poll() is not None:
            break
finally:
    try:
        os.close(master)
    except OSError:
        pass

try:
    process.wait(timeout=1)
except subprocess.TimeoutExpired:
    process.kill()
    process.wait()

text = output.decode("utf-8", errors="replace")
print(text)
if process.returncode != 0:
    raise SystemExit(process.returncode)
if "\x1b[1;7m> other" not in text:
    raise SystemExit("Expected other target row to be selectable")
if f"Target: {os.path.realpath(other)}" not in text:
    raise SystemExit("Expected target picker to use the typed folder")
PY

if "$installer" >"$tmpdir/no-profile.out" 2>&1; then
  echo "Expected non-interactive run without profile to fail" >&2
  exit 1
fi
require_contains "$tmpdir/no-profile.out" "--profile is required"

echo "agent-docs-init smoke test passed"
