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

repo_url_matches() {
  local expected="$1"
  local actual="$2"
  local expected_repo
  local actual_repo

  expected_repo="$(github_repo_from_url "$expected")"
  actual_repo="$(github_repo_from_url "$actual")"
  if [[ -n "$expected_repo" && -n "$actual_repo" ]]; then
    [[ "$expected_repo" == "$actual_repo" ]]
    return
  fi

  expected="${expected%.git}"
  actual="${actual%.git}"
  [[ "$expected" == "$actual" ]]
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

require_python() {
  if ! command -v python3 >/dev/null 2>&1; then
    echo "agent-docs-init requires Python 3.10 or newer, but python3 was not found." >&2
    exit 1
  fi
  if ! python3 - <<'PY' >/dev/null 2>&1
import sys
raise SystemExit(0 if sys.version_info >= (3, 10) else 1)
PY
  then
    echo "agent-docs-init requires Python 3.10 or newer." >&2
    exit 1
  fi
}

require_git() {
  if ! command -v git >/dev/null 2>&1 || ! git --version >/dev/null 2>&1; then
    echo "agent-docs-init installer requires git, but git was not found." >&2
    echo "Install git or set AGENT_DOCS_SOURCE to a local AGENT-DOCS checkout." >&2
    exit 1
  fi
}

run_args_include_mode() {
  local arg
  if [[ "${#run_args[@]}" -eq 0 ]]; then
    return 1
  fi
  for arg in "${run_args[@]}"; do
    case "$arg" in
      --dry-run|--write|-h|--help)
        return 0
        ;;
    esac
  done
  return 1
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

require_python

if [[ "$run_after_install" == true ]] && ! run_args_include_mode; then
  run_args+=("--dry-run")
fi

if [[ -z "$source_dir" ]]; then
  require_git
  if [[ -d "$agent_docs_home/.git" ]]; then
    origin_url="$(git -C "$agent_docs_home" config --get remote.origin.url || true)"
    if [[ -z "$origin_url" ]] || ! repo_url_matches "$repo_url" "$origin_url"; then
      echo "Refusing to update existing checkout with unexpected origin: $agent_docs_home" >&2
      echo "Expected: $repo_url" >&2
      echo "Actual: ${origin_url:-<none>}" >&2
      echo "Move it aside, remove it manually, or set AGENT_DOCS_HOME to another path." >&2
      exit 1
    fi
    git -C "$agent_docs_home" pull --ff-only --quiet
  else
    if [[ -e "$agent_docs_home" ]]; then
      echo "Refusing to replace existing non-git directory: $agent_docs_home" >&2
      echo "Move it aside, remove it manually, or set AGENT_DOCS_HOME to another path." >&2
      exit 1
    fi
    clone_repo
  fi
  source_dir="$agent_docs_home"
fi
source_dir="$(cd "$source_dir" && pwd -P)"

init_script="$source_dir/scripts/agent-docs-init"
command_script="$source_dir/scripts/agent-docs"
if [[ ! -f "$init_script" ]]; then
  echo "Could not find scripts/agent-docs-init in $source_dir" >&2
  exit 1
fi

preflight_command() {
  local name="$1"
  local source_path="$2"
  local installed_path="$bin_dir/$name"

  if [[ ( -e "$installed_path" || -L "$installed_path" ) ]] &&
    ! [[ -L "$installed_path" && "$(readlink "$installed_path")" == "$source_path" ]]; then
    echo "Refusing to replace existing command: $installed_path" >&2
    echo "Move it aside, remove it manually, or set AGENT_DOCS_BIN_DIR to another path." >&2
    exit 1
  fi
}

install_command() {
  local name="$1"
  local source_path="$2"
  local installed_path="$bin_dir/$name"
  local already_installed

  if [[ -L "$installed_path" && "$(readlink "$installed_path")" == "$source_path" ]]; then
    already_installed=true
  else
    already_installed=false
  fi

  ln -sfn "$source_path" "$installed_path"
  chmod +x "$source_path"

  if [[ "$already_installed" == true ]]; then
    echo "$name already installed -> $installed_path"
  else
    echo "Installed $name -> $installed_path"
  fi
}

mkdir -p "$bin_dir"
preflight_command "agent-docs-init" "$init_script"
if [[ -f "$command_script" ]]; then
  preflight_command "agent-continuity" "$command_script"
  preflight_command "agent-docs" "$command_script"
fi
install_command "agent-docs-init" "$init_script"
if [[ -f "$command_script" ]]; then
  install_command "agent-continuity" "$command_script"
  install_command "agent-docs" "$command_script"
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
    if [[ "${#run_args[@]}" -gt 0 ]]; then
      "$bin_dir/agent-docs-init" "${run_args[@]}" </dev/tty
    else
      "$bin_dir/agent-docs-init" </dev/tty
    fi
  else
    if [[ "${#run_args[@]}" -gt 0 ]]; then
      "$bin_dir/agent-docs-init" "${run_args[@]}"
    else
      "$bin_dir/agent-docs-init"
    fi
  fi
fi
