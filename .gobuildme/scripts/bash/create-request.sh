#!/usr/bin/env bash
# Purpose : Drive the `/request` command by preparing branch context and files.
# Why     : Keeps Spec-Driven requests consistent—establishing feature folders,
#           templated request docs, and machine-friendly output consumed by
#           downstream commands.
# How     : Parses overrides, normalizes the request narrative, ensures the
#           feature workspace exists, and emits structured metadata JSON/text.
set -euo pipefail

JSON_MODE=false
ARGS=()
CLI_TEMPLATE=""
CLI_BRANCH_PREFIX=""
CLI_NO_BRANCH=false

# Parse CLI arguments to decide between JSON output and positional text payload.
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      JSON_MODE=true
      shift
      ;;
    --template)
      CLI_TEMPLATE="$2"
      shift 2
      ;;
    --branch-prefix)
      CLI_BRANCH_PREFIX="$2"
      shift 2
      ;;
    --no-branch)
      CLI_NO_BRANCH=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--json] [--template <template.md>] [--branch-prefix <prefix>] [--no-branch] <request_description>"
      exit 0
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

# CLI arguments override environment variables (used by lite/quickfix workflows)
# Note: Template path resolution is deferred until after GBM_ROOT is determined
# to correctly handle relative paths in monorepo setups (see below)
if [[ -n "$CLI_BRANCH_PREFIX" ]]; then
  export GBM_BRANCH_PREFIX="$CLI_BRANCH_PREFIX"
fi

# Honor --no-branch flag or GBM_SKIP_BRANCH env var (used by quickfix Option C)
if [[ "$CLI_NO_BRANCH" == "true" ]] || [[ "${GBM_SKIP_BRANCH:-}" == "true" ]]; then
  export GBM_SKIP_BRANCH="true"
fi

RAW_REQUEST="${ARGS[*]:-}"
if [[ -z "$RAW_REQUEST" ]]; then
  echo "Usage: $0 [--json] <request_description>" >&2
  exit 1
fi

# Support inline slug/branch overrides while preserving the human narrative.
CUSTOM_SLUG=""
TRIMMED_LINES=()
while IFS= read -r line; do
  if [[ $line =~ ^[[:space:]]*(slug|branch)[[:space:]]*[:=][[:space:]]*(.+)$ ]]; then
    CUSTOM_SLUG="${BASH_REMATCH[2]}"
    CUSTOM_SLUG="${CUSTOM_SLUG%\"}"
    CUSTOM_SLUG="${CUSTOM_SLUG#\"}"
    CUSTOM_SLUG="${CUSTOM_SLUG%\'}"
    CUSTOM_SLUG="${CUSTOM_SLUG#\'}"
    continue
  fi
  TRIMMED_LINES+=("$line")
done <<< "${RAW_REQUEST//$'\r'/}"  # normalize CRLF if present

REQUEST_DESCRIPTION=$(printf '%s\n' "${TRIMMED_LINES[@]}" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | sed 's/^ //; s/ $//')

if [[ -z "$REQUEST_DESCRIPTION" ]]; then
  REQUEST_DESCRIPTION="$RAW_REQUEST"
fi

CUSTOM_SLUG=$(echo "$CUSTOM_SLUG" | sed 's/^ *//; s/ *$//')

# Normalize / to -- for epic/slice format (backward compatibility)
if [[ "$CUSTOM_SLUG" == *"/"* ]]; then
  ORIGINAL_SLUG="$CUSTOM_SLUG"
  CUSTOM_SLUG=$(echo "$CUSTOM_SLUG" | sed 's|/|--|g')
  echo "📝 Slug normalized: $ORIGINAL_SLUG → $CUSTOM_SLUG" >&2
fi

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# =============================================================================
# MONOREPO/WORKSPACE ROOT RESOLUTION
# =============================================================================
# Use new workspace-aware root resolution functions:
# - get_gobuildme_root(): Find nearest .gobuildme/ for feature artifacts
# - get_git_root(): Find git repo for branch operations
# - get_workspace_root(): Find workspace/monorepo root for constitution
# =============================================================================

# Resolve GoBuildMe root for feature artifact creation
GBM_ROOT=$(get_gobuildme_root)
if [[ -z "$GBM_ROOT" ]]; then
  MODE=$(get_mode)
  if [[ "$MODE" == "workspace" ]]; then
    echo "ERROR: This repository has not been initialized with GoBuildMe." >&2
    echo "       Run 'gobuildme init .' in this repo first." >&2
    echo "       (Workspace root detected, but current repo lacks .gobuildme/)" >&2
  else
    echo "ERROR: GoBuildMe not initialized." >&2
    echo "       Run 'gobuildme init .' first." >&2
  fi
  exit 1
fi

# Resolve CLI_TEMPLATE relative to GBM_ROOT for monorepo compatibility
# (Must be done before cd to GIT_ROOT changes working directory)
if [[ -n "$CLI_TEMPLATE" ]]; then
  if [[ "$CLI_TEMPLATE" == .gobuildme/* ]]; then
    # Relative path starting with .gobuildme/ - resolve relative to GBM_ROOT
    export GBM_REQUEST_TEMPLATE="$GBM_ROOT/$CLI_TEMPLATE"
  elif [[ "$CLI_TEMPLATE" == /* ]]; then
    # Absolute path - use as-is
    export GBM_REQUEST_TEMPLATE="$CLI_TEMPLATE"
  else
    # Other relative path - resolve relative to GBM_ROOT
    export GBM_REQUEST_TEMPLATE="$GBM_ROOT/$CLI_TEMPLATE"
  fi
fi

# Resolve git root for branch operations (may be different from GBM_ROOT in monorepo)
GIT_ROOT=$(get_git_root)
if [[ -n "$GIT_ROOT" ]]; then
  cd "$GIT_ROOT"
fi

# Resolve workspace root for constitution/persona paths
WORKSPACE_ROOT=$(get_workspace_root)

# Legacy alias for backward compatibility
REPO_ROOT="${GIT_ROOT:-$GBM_ROOT}"

# Determine current branch and whether we need to create/switch to a new feature branch.
BRANCH=$(get_current_branch)
NEEDS_NEW_BRANCH=false

# Always branch off protected branches.
if [[ "$BRANCH" =~ ^(main|master|develop|dev|staging|production|prod)$ ]]; then
  NEEDS_NEW_BRANCH=true
fi

# If branch prefix is specified (e.g., quickfix-), always create a new branch
# unless we're already on a branch with that prefix
if [[ -n "${GBM_BRANCH_PREFIX:-}" ]]; then
  if [[ ! "$BRANCH" =~ ^${GBM_BRANCH_PREFIX} ]]; then
    NEEDS_NEW_BRANCH=true
  fi
fi

# If user explicitly provided a slug, honor it by creating/switching unless already on it.
# Normalize both to lowercase for comparison (create-new-feature normalizes slugs)
if [[ -n "$CUSTOM_SLUG" ]]; then
  CUSTOM_SLUG_LOWER=$(echo "$CUSTOM_SLUG" | tr '[:upper:]' '[:lower:]')
  BRANCH_LOWER=$(echo "$BRANCH" | tr '[:upper:]' '[:lower:]')
  if [[ "$BRANCH_LOWER" != "$CUSTOM_SLUG_LOWER" ]]; then
    NEEDS_NEW_BRANCH=true
  fi
fi

# If current branch already has a request.md, create a new branch unless user explicitly reuses it.
if [[ "$NEEDS_NEW_BRANCH" == "false" ]] && [[ -z "$CUSTOM_SLUG" ]]; then
  # Use new 1-arg signature (reads from GBM_ROOT internally)
  CURRENT_FEATURE_DIR=$(get_feature_dir "$BRANCH")
  if [[ -f "$CURRENT_FEATURE_DIR/request.md" ]]; then
    echo "⚠️  Existing request.md found for branch '$BRANCH' - creating a new feature branch to avoid mixing requests." >&2
    echo "ℹ️  If you intended to reuse this branch, re-run with: slug: $BRANCH" >&2
    NEEDS_NEW_BRANCH=true
  fi
fi

# Skip branch creation if --no-branch flag or GBM_SKIP_BRANCH env var is set
# BUT ignore on protected branches - always create a new branch for safety
if [[ "${GBM_SKIP_BRANCH:-}" == "true" ]]; then
  if [[ "$BRANCH" =~ ^(main|master|develop|dev|staging|production|prod)$ ]]; then
    echo "⚠️  Ignoring --no-branch flag on protected branch '$BRANCH' - creating new branch for safety" >&2
    # Don't override NEEDS_NEW_BRANCH - let it create a new branch
  else
    echo "ℹ️  Skipping branch creation (--no-branch flag set), working on '$BRANCH'..." >&2
    NEEDS_NEW_BRANCH=false
  fi
fi

if [[ "$NEEDS_NEW_BRANCH" == "true" ]]; then
  echo "ℹ️  Creating feature branch from '$BRANCH'..." >&2

  # Apply branch prefix if set (used by quickfix workflow for "quickfix-" prefix)
  EFFECTIVE_SLUG="$CUSTOM_SLUG"
  if [[ -n "${GBM_BRANCH_PREFIX:-}" ]]; then
    if [[ -n "$CUSTOM_SLUG" ]]; then
      EFFECTIVE_SLUG="${GBM_BRANCH_PREFIX}${CUSTOM_SLUG}"
    fi
    # If no custom slug, prefix will be applied to generated slug by create-new-feature.sh
    # We pass it via environment so create-new-feature.sh can use it
    export GBM_BRANCH_PREFIX
  fi

  if [[ -n "$EFFECTIVE_SLUG" ]]; then
    out_json=$("$SCRIPT_DIR/create-new-feature.sh" --json --slug "$EFFECTIVE_SLUG" "$REQUEST_DESCRIPTION") || {
      echo "Error: create-new-feature.sh failed." >&2
      exit 1
    }
  else
    out_json=$("$SCRIPT_DIR/create-new-feature.sh" --json "$REQUEST_DESCRIPTION") || {
      echo "Error: create-new-feature.sh failed." >&2
      exit 1
    }
  fi
  NEW_BRANCH=$(printf '%s' "$out_json" | sed -n 's/.*"BRANCH_NAME":"\([^"]*\)".*/\1/p')

  if [[ -z "$NEW_BRANCH" ]]; then
    echo "Error: Failed to parse new branch name from create-new-feature output." >&2
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
    echo "✅ Switched to feature branch: $NEW_BRANCH" >&2
  else
    echo "ℹ️  Non-git mode: using feature name '$NEW_BRANCH'" >&2
  fi

  BRANCH="$NEW_BRANCH"
fi

# Use new 1-arg signature for workspace-aware feature directory resolution
FEATURE_DIR=$(get_feature_dir "$BRANCH")
REQUEST_FILE="$FEATURE_DIR/request.md"
# Note: spec.md should only be created by /specify command, not /request
SPEC_FILE="$FEATURE_DIR/spec.md"

# Guard: Defer artifact creation for cross-repo epics at workspace root
DEFER_FEATURE_DIR_CREATION=false
CURRENT_MODE=$(get_mode)
if [[ "$CURRENT_MODE" == "workspace" && "$BRANCH" == *"--"* && "$GBM_ROOT" == "$WORKSPACE_ROOT" ]]; then
  epic="${BRANCH%%--*}"
  epic=$(normalize_slug "$epic")
  registry="$WORKSPACE_ROOT/.gobuildme/specs/epics/$epic/slice-registry.yaml"
  if [[ -f "$registry" ]]; then
    reg_mode=$(yaml_get "$registry" "mode")
    if [[ "$reg_mode" == "cross_repo" || -z "$reg_mode" ]]; then
      DEFER_FEATURE_DIR_CREATION=true
    fi
  else
    # No registry yet at workspace root + epic slice -> assume cross_repo until created in repo
    DEFER_FEATURE_DIR_CREATION=true
  fi
fi

if [[ "$DEFER_FEATURE_DIR_CREATION" == "true" ]]; then
  echo "⚠️  Cross-repo epic detected at workspace root; skipping feature dir creation." >&2
  echo "    Run /gbm.request from the target repo to create artifacts." >&2
else
  mkdir -p "$FEATURE_DIR"
  # Seed the request document from templates when needed.
  if [[ ! -f "$REQUEST_FILE" ]]; then
    # Check for template override via environment variable (used by lite/quickfix workflows)
    if [[ -n "${GBM_REQUEST_TEMPLATE:-}" ]] && [[ -f "$GBM_REQUEST_TEMPLATE" ]]; then
      TPL="$GBM_REQUEST_TEMPLATE"
    else
      # Use GBM_ROOT for templates (workspace-aware)
      TPL="$GBM_ROOT/.gobuildme/templates/request-template.md"
      [[ -f "$TPL" ]] || TPL="$GBM_ROOT/templates/request-template.md"
    fi
    if [[ -f "$TPL" ]]; then cp "$TPL" "$REQUEST_FILE"; else echo -e "# Request\n\n> Describe the user request, context, and open questions." > "$REQUEST_FILE"; fi
  fi
fi

# Resolve workspace-aware paths for templates to use
CONSTITUTION_PATH=$(get_constitution_path)
ARCHITECTURE_DIRS=$(get_architecture_dirs | tr '\n' ':' | sed 's/:$//')
DEPLOYMENT_MODE=$(get_mode)

if $JSON_MODE; then
  # Downstream commands prefer JSON so they can fetch absolute paths quickly.
  # Include workspace-aware paths for templates
  printf '{"BRANCH_NAME":"%s","REQUEST_FILE":"%s","SPEC_FILE":"%s","FEATURE_DIR":"%s","GBM_ROOT":"%s","WORKSPACE_ROOT":"%s","CONSTITUTION_PATH":"%s","ARCHITECTURE_DIRS":"%s","MODE":"%s","DEFER_FEATURE_DIR_CREATION":"%s"}\n' \
    "$BRANCH" "$REQUEST_FILE" "$SPEC_FILE" "$FEATURE_DIR" "$GBM_ROOT" "$WORKSPACE_ROOT" "$CONSTITUTION_PATH" "$ARCHITECTURE_DIRS" "$DEPLOYMENT_MODE" "$DEFER_FEATURE_DIR_CREATION"
else
  # Human-friendly output keeps shell users aware of generated resources.
  echo "BRANCH_NAME: $BRANCH"
  echo "REQUEST_FILE: $REQUEST_FILE"
  echo "SPEC_FILE: $SPEC_FILE"
  echo "FEATURE_DIR: $FEATURE_DIR"
  echo "GBM_ROOT: $GBM_ROOT"
  echo "WORKSPACE_ROOT: $WORKSPACE_ROOT"
  echo "CONSTITUTION_PATH: $CONSTITUTION_PATH"
  echo "ARCHITECTURE_DIRS: $ARCHITECTURE_DIRS"
  echo "MODE: $DEPLOYMENT_MODE"
  echo "DEFER_FEATURE_DIR_CREATION: $DEFER_FEATURE_DIR_CREATION"
fi

# Record metadata for this artifact (optional, non-blocking)
# Note: User Goals extraction will happen after AI agent writes request content
if command -v python3 >/dev/null 2>&1; then
  METADATA_SCRIPT="$SCRIPT_DIR/../record-metadata.py"
  if [[ -f "$METADATA_SCRIPT" ]]; then
    python3 "$METADATA_SCRIPT" \
      --feature-name "$BRANCH" \
      --command "request" \
      --artifact-path "$REQUEST_FILE" \
      --repo-root "$GBM_ROOT" \
      >/dev/null 2>&1 || true
  fi
fi
