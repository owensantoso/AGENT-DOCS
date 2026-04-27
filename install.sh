#!/usr/bin/env bash
set -euo pipefail

repo_url="${AGENT_DOCS_REPO_URL:-https://github.com/owensantoso/AGENT-DOCS.git}"
agent_docs_home="${AGENT_DOCS_HOME:-$HOME/.agent-docs}"
bin_dir="${AGENT_DOCS_BIN_DIR:-$HOME/.local/bin}"
source_dir="${AGENT_DOCS_SOURCE:-}"
run_after_install=true
run_args=()

github_repo_from_url() {
  local url="$1"
  local repo=""
  case "$url" in
    https://github.com/*)
      repo="${url#https://github.com/}"
      repo="${repo%.git}"
      ;;
    git@github.com:*)
      repo="${url#git@github.com:}"
      repo="${repo%.git}"
      ;;
  esac
  if [[ "$repo" == */* ]]; then
    printf '%s\n' "$repo"
  fi
}

clone_repo() {
  local github_repo
  github_repo="$(github_repo_from_url "$repo_url")"
  if [[ -n "$github_repo" ]] && command -v gh >/dev/null 2>&1; then
    if gh repo clone "$github_repo" "$agent_docs_home" -- --quiet; then
      return
    fi
    echo "gh repo clone failed; falling back to git clone" >&2
  fi
  git clone --quiet "$repo_url" "$agent_docs_home"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run)
      run_after_install=true
      shift
      ;;
    --no-run)
      run_after_install=false
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
    clone_repo
  fi
  source_dir="$agent_docs_home"
fi

init_script="$source_dir/scripts/agent-docs-init"
if [[ ! -f "$init_script" ]]; then
  echo "Could not find scripts/agent-docs-init in $source_dir" >&2
  exit 1
fi

mkdir -p "$bin_dir"
installed_bin="$bin_dir/agent-docs-init"
if [[ -L "$installed_bin" && "$(readlink "$installed_bin")" == "$init_script" ]]; then
  already_installed=true
else
  already_installed=false
fi

ln -sfn "$init_script" "$installed_bin"
chmod +x "$init_script"

if [[ "$already_installed" == true ]]; then
  echo "agent-docs-init already installed -> $installed_bin"
else
  echo "Installed agent-docs-init -> $installed_bin"
fi

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
