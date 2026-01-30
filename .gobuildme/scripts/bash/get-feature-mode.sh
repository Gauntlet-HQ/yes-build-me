#!/usr/bin/env bash
# Purpose : Get the workflow mode and feature paths for a feature.
# Why     : Supports lite workflow by reading mode from mode.yaml and resolving paths correctly.
# How     : Reads mode.yaml from feature directory, defaults to "full" if missing.
#           Outputs JSON with mode and all relevant paths when --json is specified.
#
# Returns (plain mode):
#   lite     - Lite workflow (3-5 files, ≤100 LoC)
#   full     - Full SDD workflow (default)
#   quickfix - Quickfix workflow (1-2 files, ≤50 LoC)
#
# Returns (JSON mode):
#   {"mode":"lite","feature_dir":"/path/to/feature","branch":"branch-name","gbm_root":"/path/to/gbm"}
#
# Usage:
#   get-feature-mode.sh                    # Returns mode only
#   get-feature-mode.sh --json             # Returns JSON with mode and paths
#   get-feature-mode.sh --feature-dir <path>  # Uses specified feature dir

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

FEATURE_DIR=""
JSON_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --feature-dir)
      FEATURE_DIR="$2"
      shift 2
      ;;
    --json)
      JSON_MODE=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# Get GBM root and workspace root
GBM_ROOT=$(get_gobuildme_root)
WORKSPACE_ROOT=$(get_workspace_root)

# Get current branch
BRANCH=$(get_current_branch)

# Resolve feature directory if not specified
if [[ -z "$FEATURE_DIR" ]]; then
  FEATURE_DIR=$(get_feature_dir "$BRANCH")
fi

# Default mode
MODE="full"

# Check if feature directory exists
if [[ -d "$FEATURE_DIR" ]]; then
  # Read mode from mode.yaml if it exists
  MODE_FILE="$FEATURE_DIR/mode.yaml"
  if [[ -f "$MODE_FILE" ]]; then
    DETECTED_MODE=$(yaml_get "$MODE_FILE" "mode" 2>/dev/null || echo "")
    # Validate mode value
    case "$DETECTED_MODE" in
      lite|full|quickfix)
        MODE="$DETECTED_MODE"
        ;;
    esac
  fi
fi

# Get architecture directories
ARCH_DIRS=$(get_architecture_dirs 2>/dev/null | tr '\n' ':' | sed 's/:$//' || echo "")

# Output based on mode
if [[ "$JSON_MODE" == "true" ]]; then
  printf '{"mode":"%s","feature_dir":"%s","branch":"%s","gbm_root":"%s","workspace_root":"%s","architecture_dirs":"%s"}\n' \
    "$MODE" "$FEATURE_DIR" "$BRANCH" "$GBM_ROOT" "$WORKSPACE_ROOT" "$ARCH_DIRS"
else
  echo "$MODE"
fi
