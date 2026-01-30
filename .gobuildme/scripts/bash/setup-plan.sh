#!/usr/bin/env bash
# Purpose : Prime the `/plan` phase with the correct directory and template.
# Why     : Guarantees planners operate in the feature context determined by
#           earlier steps, keeping architecture artifacts organized.
# How     : Loads shared helpers, verifies branch naming, seeds plan templates,
#           and returns canonical paths via JSON or human-readable output.

set -e

# Parse command line arguments
JSON_MODE=false
ARGS=()

for arg in "$@"; do
    case "$arg" in
        --json) 
            JSON_MODE=true 
            ;;
        --help|-h) 
            echo "Usage: $0 [--json]"
            echo "  --json    Output results in JSON format"
            echo "  --help    Show this help message"
            exit 0 
            ;;
        *) 
            ARGS+=("$arg") 
            ;;
    esac
done

# Get script directory and load common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get all paths and variables from common functions
eval $(get_feature_paths)

# Check if we're on a proper feature branch (only for git repos)
check_feature_branch "$CURRENT_BRANCH" "$HAS_GIT" || exit 1

# Ensure the feature directory exists
mkdir -p "$FEATURE_DIR"

# Copy plan template if it exists (use GBM_ROOT for workspace-aware templates)
TEMPLATE="$GBM_ROOT/.gobuildme/templates/plan-template.md"
if [[ -f "$TEMPLATE" ]]; then
    cp "$TEMPLATE" "$IMPL_PLAN"
    echo "Copied plan template to $IMPL_PLAN"
else
    echo "Warning: Plan template not found at $TEMPLATE"
    # Create a basic plan file if template doesn't exist
    touch "$IMPL_PLAN"
fi

# Output results (include workspace-aware paths for templates)
if $JSON_MODE; then
    printf '{"FEATURE_SPEC":"%s","IMPL_PLAN":"%s","FEATURE_DIR":"%s","BRANCH":"%s","HAS_GIT":"%s","GBM_ROOT":"%s","WORKSPACE_ROOT":"%s","CONSTITUTION_PATH":"%s","ARCHITECTURE_DIRS":"%s","MODE":"%s"}\n' \
        "$FEATURE_SPEC" "$IMPL_PLAN" "$FEATURE_DIR" "$CURRENT_BRANCH" "$HAS_GIT" "$GBM_ROOT" "$WORKSPACE_ROOT" "$CONSTITUTION_PATH" "$ARCHITECTURE_DIRS" "$MODE"
else
    echo "FEATURE_SPEC: $FEATURE_SPEC"
    echo "IMPL_PLAN: $IMPL_PLAN"
    echo "FEATURE_DIR: $FEATURE_DIR"
    echo "BRANCH: $CURRENT_BRANCH"
    echo "HAS_GIT: $HAS_GIT"
    echo "GBM_ROOT: $GBM_ROOT"
    echo "WORKSPACE_ROOT: $WORKSPACE_ROOT"
    echo "CONSTITUTION_PATH: $CONSTITUTION_PATH"
    echo "ARCHITECTURE_DIRS: $ARCHITECTURE_DIRS"
    echo "MODE: $MODE"
fi

# Record metadata for spec.md (if it exists)
# This happens after AI agent has written to spec.md from /specify command
if command -v python3 >/dev/null 2>&1; then
  METADATA_SCRIPT="$SCRIPT_DIR/../record-metadata.py"
  if [[ -f "$METADATA_SCRIPT" ]] && [[ -f "$FEATURE_SPEC" ]]; then
    python3 "$METADATA_SCRIPT" \
      --feature-name "$CURRENT_BRANCH" \
      --command "specify" \
      --artifact-path "$FEATURE_SPEC" \
      --repo-root "$GBM_ROOT" \
      >/dev/null 2>&1 || true
  fi
fi
