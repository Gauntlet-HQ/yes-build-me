#!/usr/bin/env bash
# Purpose : Check if architecture documentation is stale based on git changes.
# Why     : Supports lite/quickfix workflow by detecting when architecture needs refresh.
# How     : Compares current HEAD with commit recorded in .architecture-meta.yaml,
#           counts changed files in key directories.
#
# Returns:
#   CURRENT:<changed_files>            - Architecture is current (exit 0)
#   STALE:<changed_files>              - Architecture needs refresh (exit 1)
#   UNKNOWN:<reason>                   - Cannot determine freshness (exit 0 by default)
#
# Flags:
#   --ci                   - Exit 1 for UNKNOWN status (strict mode for CI)
#   --arch-dir <path>      - Specific architecture directory to check
#   --threshold <N>        - Override staleness threshold (default: 20)
#
# Usage:
#   check-architecture-freshness.sh [--ci] [--arch-dir <path>] [--threshold <N>]

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Defaults
CI_MODE=false
ARCH_DIR=""
THRESHOLD="${ARCH_STALENESS_FILES:-20}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ci)
      CI_MODE=true
      shift
      ;;
    --arch-dir)
      ARCH_DIR="$2"
      shift 2
      ;;
    --threshold)
      THRESHOLD="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

summarize_status() {
  local status="$1"
  local changed="$2"
  local reason="$3"
  local layout_hint="$4"

  case "$status" in
    STALE)
      if [[ -n "$layout_hint" ]]; then
        echo "STALE:${changed}:${layout_hint}"
      else
        echo "STALE:${changed}"
      fi
      ;;
    UNKNOWN)
      if [[ -n "$reason" ]]; then
        echo "UNKNOWN:${reason}"
      else
        echo "UNKNOWN:unknown"
      fi
      ;;
    *)
      if [[ -n "$layout_hint" ]]; then
        echo "CURRENT:${changed}:${layout_hint}"
      else
        echo "CURRENT:${changed}"
      fi
      ;;
  esac
}

extract_changed() {
  local result="$1"
  if [[ "$result" =~ ^(CURRENT|STALE):([0-9]+) ]]; then
    echo "${BASH_REMATCH[2]}"
  else
    echo "0"
  fi
}

extract_layout_hint() {
  local result="$1"
  if [[ "$result" =~ :nonstandard_layout$ ]]; then
    echo "nonstandard_layout"
  else
    echo ""
  fi
}

check_one_dir() {
  local arch_dir="$1"
  local threshold="$2"
  local meta_file="$arch_dir/.architecture-meta.yaml"

  if [[ ! -f "$meta_file" ]]; then
    echo "UNKNOWN:no_meta_file"
    return 0
  fi

  local git_root
  git_root=$(yaml_get "$meta_file" "git_repo_root")
  if [[ -z "$git_root" ]]; then
    echo "UNKNOWN:empty_git_root"
    return 0
  fi
  if [[ ! -d "$git_root/.git" ]]; then
    echo "UNKNOWN:invalid_git_root"
    return 0
  fi

  local git_commit
  git_commit=$(yaml_get "$meta_file" "git_commit")
  if [[ -z "$git_commit" ]]; then
    echo "UNKNOWN:no_commit_recorded"
    return 0
  fi
  if ! git -C "$git_root" cat-file -e "$git_commit" 2>/dev/null; then
    echo "UNKNOWN:commit_not_found"
    return 0
  fi

  local scope_root
  scope_root=$(yaml_get "$meta_file" "scope_root")
  if [[ -z "$scope_root" ]]; then
    # Fallback: derive scope root from architecture directory path
    if [[ "$arch_dir" == *"/.gobuildme/docs/technical/architecture" ]]; then
      scope_root="$(cd "$arch_dir/../../../.." && pwd)"
    fi
  fi

  local scope_rel=""
  if [[ -n "$scope_root" ]]; then
    if [[ "$scope_root" == "$git_root" ]]; then
      scope_rel=""
    elif [[ "$scope_root" == "$git_root/"* ]]; then
      scope_rel="${scope_root#$git_root/}"
    else
      echo "UNKNOWN:scope_outside_git"
      return 0
    fi
  fi

  # Default source directories to track changes within
  local default_dirs=("src/" "lib/" "app/" "services/" "pkg/" "internal/" "cmd/" "handlers/" "api/" "core/")
  local scoped_dirs=()
  local d=""

  if [[ -n "$scope_rel" ]]; then
    for d in "${default_dirs[@]}"; do
      scoped_dirs+=("$scope_rel/$d")
    done
  else
    scoped_dirs=("${default_dirs[@]}")
  fi

  local changed
  changed=$(git -C "$git_root" diff --name-only "$git_commit"..HEAD -- "${scoped_dirs[@]}" 2>/dev/null | wc -l | tr -d ' ')

  if [[ "$changed" -eq 0 ]]; then
    # Fallback: check for any code changes in scope, excluding docs/config
    local scope_path=""
    if [[ -n "$scope_rel" ]]; then
      scope_path="$scope_rel/"
    fi

    local diff_files
    if [[ -n "$scope_path" ]]; then
      diff_files=$(git -C "$git_root" diff --name-only "$git_commit"..HEAD -- "$scope_path" 2>/dev/null)
    else
      diff_files=$(git -C "$git_root" diff --name-only "$git_commit"..HEAD 2>/dev/null)
    fi

    local total_changed
    total_changed=$(printf '%s\n' "$diff_files" | \
      grep -Ev '(^|/)(docs|.github)/' | \
      grep -Ev '\.(md|txt|rst|lock|json|ya?ml)$' | \
      wc -l | tr -d ' ')

    if [[ "$total_changed" -gt "$threshold" ]]; then
      echo "STALE:${total_changed}:nonstandard_layout"
      return 0
    elif [[ "$total_changed" -gt 0 ]]; then
      echo "CURRENT:${total_changed}:nonstandard_layout"
      return 0
    fi
  fi

  if [[ "$changed" -gt "$threshold" ]]; then
    echo "STALE:${changed}"
    return 0
  fi

  echo "CURRENT:${changed}"
}

# Find architecture directory if not specified (multi-dir support)
# Note: Using bash 3.2 compatible approach (no mapfile/readarray)
ARCH_DIRS=()
if [[ -n "$ARCH_DIR" ]]; then
  ARCH_DIRS=("$ARCH_DIR")
else
  # Bash 3.2 compatible: read into array using while loop
  while IFS= read -r dir; do
    [[ -n "$dir" ]] && ARCH_DIRS+=("$dir")
  done < <(get_architecture_dirs)

  if [[ ${#ARCH_DIRS[@]} -eq 0 ]]; then
    echo "UNKNOWN:no_architecture_dir"
    if [[ "$CI_MODE" == "true" ]]; then
      exit 1
    fi
    exit 0
  fi
fi

overall_status="CURRENT"
overall_changed=0
unknown_reason=""
overall_layout_hint=""
details=()

for arch_dir in "${ARCH_DIRS[@]}"; do
  result=$(check_one_dir "$arch_dir" "$THRESHOLD")
  details+=("DIR:${arch_dir}:${result}")

  status="${result%%:*}"
  changed=$(extract_changed "$result")
  layout_hint=$(extract_layout_hint "$result")

  if [[ "$status" == "STALE" ]]; then
    overall_status="STALE"
    if [[ "$changed" -gt "$overall_changed" ]]; then
      overall_changed="$changed"
    fi
    # Propagate layout hint if present
    if [[ -n "$layout_hint" ]]; then
      overall_layout_hint="$layout_hint"
    fi
  elif [[ "$status" == "UNKNOWN" ]]; then
    if [[ "$overall_status" != "STALE" ]]; then
      overall_status="UNKNOWN"
      if [[ -z "$unknown_reason" ]]; then
        unknown_reason="${result#UNKNOWN:}"
      fi
    fi
  else
    if [[ "$overall_status" == "CURRENT" && "$changed" -gt "$overall_changed" ]]; then
      overall_changed="$changed"
    fi
    # Propagate layout hint if present (for CURRENT status)
    if [[ -n "$layout_hint" && -z "$overall_layout_hint" ]]; then
      overall_layout_hint="$layout_hint"
    fi
  fi
done

# Summary line first (backwards compatible for parsers)
summarize_status "$overall_status" "$overall_changed" "$unknown_reason" "$overall_layout_hint"

# Emit per-directory details (optional consumers)
for line in "${details[@]}"; do
  echo "$line"
done

if [[ "$overall_status" == "STALE" ]]; then
  exit 1
fi
if [[ "$overall_status" == "UNKNOWN" && "$CI_MODE" == "true" ]]; then
  exit 1
fi
exit 0
