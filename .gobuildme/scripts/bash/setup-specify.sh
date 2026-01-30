#!/usr/bin/env bash
# Purpose : Prepare the working tree for the `/specify` command.
# Why     : Ensures spec authors land in the right feature folder with seeded
#           templates so they can focus on clarifying requirements.
# How     : Detects/creates feature branches, reuses unfinished requests, and
#           outputs paths to spec/request files for downstream tooling.
set -euo pipefail

JSON_MODE=false
ARGS=()
# Parse flags before we mutate positional arguments; supports --json for bots.
for arg in "$@"; do
  case "$arg" in
    --json) JSON_MODE=true ;;
    --help|-h) echo "Usage: $0 [--json] <feature_description>"; exit 0 ;;
    *) ARGS+=("$arg") ;;
  esac
done

FEATURE_DESCRIPTION="${ARGS[*]:-}"

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

current_branch=$(get_current_branch)

SPECS_DIR="$(get_specs_root "$REPO_ROOT")"
mkdir -p "$SPECS_DIR"

# Helper: returns 0 if spec.md is missing or only contains whitespace so
# callers know when to seed the template.
is_spec_missing_or_empty() {
  local path="$1"
  if [[ ! -f "$path" ]]; then return 0; fi
  # treat whitespace-only as empty
  if grep -q '[^[:space:]]' "$path" >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

choose_existing_feature() {
  local candidate=""
  local latest_mtime=0
  local dir=""
  # Prefer the most recently touched request-only folder that still lacks a spec.
  while IFS= read -r dir; do
    [[ -d "$dir" ]] || continue
    local request_file="$dir/request.md"
    local spec_file="$dir/spec.md"
    if [[ -f "$request_file" ]] && is_spec_missing_or_empty "$spec_file"; then
      local mtime
      mtime=$(stat -f %m "$request_file" 2>/dev/null || stat -c %Y "$request_file" 2>/dev/null || echo 0)
      if (( mtime > latest_mtime )); then
        latest_mtime=$mtime
        candidate="$dir"
      fi
    fi
  done < <(get_all_feature_dirs "$REPO_ROOT")
  [[ -n "$candidate" ]] && echo "$candidate" || true
}

# If we're already on a feature branch, prefer to use it.
BRANCH="$current_branch"
FEATURE_DIR_FROM_BRANCH="$(get_feature_dir "$REPO_ROOT" "$BRANCH")"
MODE=$(get_mode)
GBM_ROOT=$(get_gobuildme_root)
WORKSPACE_ROOT=$(get_workspace_root)
if [[ "$MODE" == "workspace" && "$BRANCH" == *"--"* && "$GBM_ROOT" == "$WORKSPACE_ROOT" ]]; then
  echo "⚠️  Workspace root + epic slice detected." >&2
  echo "    cd into the target repo and re-run /gbm.request to create slice artifacts." >&2
  exit 1
fi
if [[ ! -d "$FEATURE_DIR_FROM_BRANCH" ]]; then
  # Not on a feature branch; try to reuse latest request-only folder
  reuse_dir=$(choose_existing_feature || true)
  if [[ -n "$reuse_dir" ]]; then
    if [[ "$reuse_dir" == "$SPECS_DIR/epics/"* ]]; then
      slice=$(basename "$reuse_dir")
      epic=$(basename "$(dirname "$reuse_dir")")
      BRANCH="${epic}--${slice}"
    else
      BRANCH=$(basename "$reuse_dir")
    fi
  else
    # No reusable folder → create a new feature using the original creator
    out_json=$("$SCRIPT_DIR/create-new-feature.sh" --json "$FEATURE_DESCRIPTION") || {
      echo "Error: create-new-feature.sh failed." >&2
      exit 1
    }
    NEW_BRANCH=$(printf '%s' "$out_json" | sed -n 's/.*"BRANCH_NAME":"\([^"]*\)".*/\1/p')
    DEFER_CREATION=$(printf '%s' "$out_json" | sed -n 's/.*"DEFER_FEATURE_DIR_CREATION":"\([^"]*\)".*/\1/p')
    if [[ -z "$NEW_BRANCH" ]]; then
      echo "Error: Failed to parse new branch name from create-new-feature output." >&2
      exit 1
    fi
    if [[ "$DEFER_CREATION" == "true" ]]; then
      echo "⚠️  Workspace root + epic slice detected. Feature directory was not created." >&2
      echo "    cd into the target repo and re-run /gbm.request to create slice artifacts." >&2
      exit 1
    fi
    # Only verify/checkout if we're in a git repo
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      if ! git rev-parse --verify "$NEW_BRANCH" >/dev/null 2>&1; then
        echo "Error: New branch '$NEW_BRANCH' not found after creation." >&2
        exit 1
      fi
      if ! git checkout "$NEW_BRANCH" >/dev/null 2>&1; then
        echo "Error: Failed to switch to new branch '$NEW_BRANCH'." >&2
        exit 1
      fi
    fi
    # Pass through the JSON if caller only needs the new feature
    if $JSON_MODE; then
      printf '%s\n' "$out_json"
    else
      # also print human-friendly lines
      echo "$out_json" | sed -n 's/.*"BRANCH_NAME":"\([^"]*\)".*/BRANCH_NAME: \1/p'
      echo "$out_json" | sed -n 's/.*"SPEC_FILE":"\([^"]*\)".*/SPEC_FILE: \1/p'
      echo "$out_json" | sed -n 's/.*"REQUEST_FILE":"\([^"]*\)".*/REQUEST_FILE: \1/p'
    fi
    exit 0
  fi
fi

FEATURE_DIR="$(get_feature_dir "$REPO_ROOT" "$BRANCH")"
mkdir -p "$FEATURE_DIR"

REQUEST_FILE="$FEATURE_DIR/request.md"
SPEC_FILE="$FEATURE_DIR/spec.md"

# Ensure spec.md exists if missing/empty; seed from template for consistency.
if is_spec_missing_or_empty "$SPEC_FILE"; then
  TEMPLATE="$REPO_ROOT/.gobuildme/templates/spec-template.md"
  [[ -f "$TEMPLATE" ]] || TEMPLATE="$REPO_ROOT/templates/spec-template.md"
  if [[ -f "$TEMPLATE" ]]; then cp "$TEMPLATE" "$SPEC_FILE"; else : > "$SPEC_FILE"; fi
fi

# Run architecture analysis to support specification creation
# This ensures architectural context is available when creating specifications
if [[ -x "$SCRIPT_DIR/analyze-architecture.sh" ]]; then
  # Only run if we're on a feature branch (architecture analysis requires it)
  if [[ -d "$FEATURE_DIR" ]]; then
    # Switch to the feature branch if not already on it
    current_branch_check=$(get_current_branch)
    if [[ "$current_branch_check" != "$BRANCH" ]]; then
      git checkout "$BRANCH" >/dev/null 2>&1 || true
    fi

    # Run architecture analysis (show output for debugging)
    echo "Running architecture analysis..." >&2
    "$SCRIPT_DIR/analyze-architecture.sh" || {
      echo "Architecture analysis failed, but continuing..." >&2
    }

    # Switch back to original branch if needed
    if [[ "$current_branch_check" != "$BRANCH" ]]; then
      git checkout "$current_branch_check" >/dev/null 2>&1 || true
    fi
  else
    echo "Skipping architecture analysis (not on feature branch: $BRANCH)" >&2
  fi
else
  echo "Architecture analysis script not found or not executable" >&2
fi

if $JSON_MODE; then
  printf '{"BRANCH_NAME":"%s","SPEC_FILE":"%s","REQUEST_FILE":"%s","FEATURE_DIR":"%s"}\n' \
    "$BRANCH" "$SPEC_FILE" "$REQUEST_FILE" "$FEATURE_DIR"
else
  echo "BRANCH_NAME: $BRANCH"
  echo "SPEC_FILE: $SPEC_FILE"
  echo "REQUEST_FILE: $REQUEST_FILE"
  echo "FEATURE_DIR: $FEATURE_DIR"
fi

# Record metadata for request.md (if it exists)
# This happens after AI agent has written to request.md, allowing User Goals extraction
if command -v python3 >/dev/null 2>&1; then
  METADATA_SCRIPT="$SCRIPT_DIR/../record-metadata.py"
  if [[ -f "$METADATA_SCRIPT" ]] && [[ -f "$REQUEST_FILE" ]]; then
    python3 "$METADATA_SCRIPT" \
      --feature-name "$BRANCH" \
      --command "request" \
      --artifact-path "$REQUEST_FILE" \
      --repo-root "$REPO_ROOT" \
      >/dev/null 2>&1 || true
  fi
fi
