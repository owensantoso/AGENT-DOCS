#!/usr/bin/env bash
set -euo pipefail

repo_url="${AGENT_DOCS_REPO_URL:-https://github.com/owensantoso/AGENT-DOCS.git}"
agent_docs_home="${AGENT_DOCS_HOME:-$HOME/.agent-docs}"
bin_dir="${AGENT_DOCS_BIN_DIR:-$HOME/.local/bin}"
source_dir="${AGENT_DOCS_SOURCE:-}"
run_after_install=false
run_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run)
      run_after_install=true
      shift
      ;;
    --)
      shift
      run_args=("$@")
      break
      ;;
    *)
      run_args+=("$1")
      shift
      ;;
  esac
done

if [[ -z "$source_dir" ]]; then
  if [[ -d "$agent_docs_home/.git" ]]; then
    git -C "$agent_docs_home" pull --ff-only --quiet
  else
    rm -rf "$agent_docs_home"
    git clone --quiet "$repo_url" "$agent_docs_home"
  fi
  source_dir="$agent_docs_home"
fi

init_script="$source_dir/scripts/agent-docs-init"
if [[ ! -f "$init_script" ]]; then
  echo "Could not find scripts/agent-docs-init in $source_dir" >&2
  exit 1
fi

mkdir -p "$bin_dir"
ln -sfn "$init_script" "$bin_dir/agent-docs-init"
chmod +x "$init_script"

echo "Installed agent-docs-init -> $bin_dir/agent-docs-init"

case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *)
    echo "Note: $bin_dir is not on PATH."
    echo "Add it with: export PATH=\"$bin_dir:\$PATH\""
    ;;
esac

if [[ "$run_after_install" == true ]]; then
  if [[ -r /dev/tty && -t 1 ]]; then
    "$bin_dir/agent-docs-init" "${run_args[@]}" </dev/tty
  else
    "$bin_dir/agent-docs-init" "${run_args[@]}"
  fi
fi
