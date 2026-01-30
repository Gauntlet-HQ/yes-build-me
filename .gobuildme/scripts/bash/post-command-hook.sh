#!/usr/bin/env bash
# ============================================================================
# post-command-hook.sh - Orchestrate post-command actions
# ============================================================================
#
# This script is called after GoBuildMe commands complete. It orchestrates
# all post-command actions with proper separation of concerns:
#   1. Telemetry tracking (if enabled)
#   2. Auto-upload to S3 (if enabled)
#   3. Future hooks can be added here
#
# Usage:
#   post-command-hook.sh --command <name> --status <success|failure> [OPTIONS]
#
# Options:
#   --command <name>      Command name (e.g., gbm.specify)
#   --status <status>     Command status (success or failure)
#   --feature-dir <path>  Path to feature spec directory
#   --command-id <uuid>   Unique command execution ID
#   --start-time <ms>     Command start time in milliseconds
#
# Environment Variables:
#   GBM_SKIP_TELEMETRY=true     Skip telemetry for this command
#   GBM_SKIP_AUTO_UPLOAD=true   Skip auto-upload for this command
#
# ============================================================================

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

# Logging setup
LOG_FILE="${GBM_HOOK_LOG:-}"
DEBUG="${GBM_HOOK_DEBUG:-false}"

log() {
  local level="$1"
  shift
  local message="$*"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local log_line="[$timestamp] [$level] $message"

  # Always log to file if LOG_FILE is set
  if [ -n "$LOG_FILE" ]; then
    echo "$log_line" >> "$LOG_FILE"
  fi

  # Log to stderr if DEBUG is true
  if [ "$DEBUG" = "true" ]; then
    echo "$log_line" >&2
  fi
}

log "INFO" "post-command-hook.sh started with args: $*"

COMMAND_NAME=""
STATUS=""
FEATURE_DIR=""
COMMAND_ID=""
START_TIME=""
RESULTS=""
ERROR=""
QUIET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --command)
      COMMAND_NAME="$2"
      shift 2
      ;;
    --status)
      STATUS="$2"
      shift 2
      ;;
    --feature-dir)
      FEATURE_DIR="$2"
      shift 2
      ;;
    --command-id)
      COMMAND_ID="$2"
      shift 2
      ;;
    --start-time)
      START_TIME="$2"
      shift 2
      ;;
    --results)
      RESULTS="$2"
      shift 2
      ;;
    --error)
      ERROR="$2"
      shift 2
      ;;
    --quiet)
      QUIET="true"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Check if a command generates artifacts that should trigger auto-upload
is_artifact_generating_command() {
  local cmd_name="$1"
  case "$cmd_name" in
    # Core SDD workflow commands
    gbm.request|gbm.specify|gbm.clarify|gbm.plan|gbm.tasks|\
    gbm.architecture|gbm.implement|gbm.tests|gbm.review|\
    # Lite workflow commands
    gbm.lite.request|gbm.lite.plan|gbm.lite.implement|gbm.lite.push|\
    # Quickfix command
    gbm.quickfix|\
    # Setup command
    gbm.setup)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Read auto-upload settings from manifest
get_auto_upload_config() {
  local manifest_file=".gobuildme/manifest.json"
  
  if [ -f "$manifest_file" ]; then
    python3 -c "
import json
try:
    with open('$manifest_file', 'r') as f:
        data = json.load(f)
        upload_spec = data.get('upload_spec', {})
        enabled = 'true' if upload_spec.get('auto_upload', False) else 'false'
        bucket = upload_spec.get('s3_bucket', 'tools-ai-agents-spec-driven-development-gfm')
        print(f'{enabled}|{bucket}')
except:
    print('false|tools-ai-agents-spec-driven-development-gfm')
" 2>/dev/null || echo "false|tools-ai-agents-spec-driven-development-gfm"
  else
    echo "false|tools-ai-agents-spec-driven-development-gfm"
  fi
}

# Trigger async upload of spec directory
trigger_auto_upload() {
  local feature_dir="$1"
  local bucket="$2"
  
  local upload_script="$SCRIPT_DIR/upload-spec.sh"
  
  if [ -f "$upload_script" ]; then
    # Run upload asynchronously in background
    # Use nohup to prevent hangup, redirect output to /dev/null
    (
      GBM_S3_BUCKET="$bucket" \
      nohup "$upload_script" "$feature_dir" --quiet >/dev/null 2>&1 &
    ) &
    disown 2>/dev/null || true
  fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

log "INFO" "Parsed args: command=$COMMAND_NAME status=$STATUS feature_dir=$FEATURE_DIR command_id=$COMMAND_ID"

# Validate required arguments
if [ -z "$COMMAND_NAME" ]; then
  log "WARN" "No --command specified"
fi
if [ -z "$STATUS" ]; then
  log "WARN" "No --status specified"
fi

# 1. TELEMETRY HOOK
# ----------------------------------------------------------------------------
log "INFO" "=== Phase 1: Telemetry ==="
if [ "${GBM_SKIP_TELEMETRY:-}" != "true" ]; then
  telemetry_script="$SCRIPT_DIR/get-telemetry-context.sh"
  log "INFO" "Looking for telemetry script at: $telemetry_script"
  if [ -f "$telemetry_script" ]; then
    log "INFO" "Telemetry script found, calling it..."
    # Build telemetry args
    # Note: get-telemetry-context.sh expects specific option names:
    #   --command-name (not --command)
    #   --command-start-time (not --start-time)
    telemetry_args=(--track-complete)
    [ -n "$COMMAND_NAME" ] && telemetry_args+=(--command-name "$COMMAND_NAME")
    [ -n "$STATUS" ] && telemetry_args+=(--status "$STATUS")
    [ -n "$COMMAND_ID" ] && telemetry_args+=(--command-id "$COMMAND_ID")
    [ -n "$START_TIME" ] && telemetry_args+=(--command-start-time "$START_TIME")
    [ -n "$RESULTS" ] && telemetry_args+=(--results "$RESULTS")
    [ -n "$ERROR" ] && telemetry_args+=(--error "$ERROR")
    [ -n "$QUIET" ] && telemetry_args+=(--quiet)

    # Pass through to telemetry script
    "$telemetry_script" "${telemetry_args[@]}" 2>/dev/null || true
  fi
fi

# 2. AUTO-UPLOAD HOOK
# ----------------------------------------------------------------------------
log "INFO" "=== Phase 2: Auto-Upload ==="
log "INFO" "GBM_SKIP_AUTO_UPLOAD=${GBM_SKIP_AUTO_UPLOAD:-not set}, STATUS=$STATUS"

if [ "${GBM_SKIP_AUTO_UPLOAD:-}" != "true" ] && [ "$STATUS" = "success" ]; then
  log "INFO" "Auto-upload check passed (not skipped and status=success)"

  # Check if auto-upload is enabled
  config=$(get_auto_upload_config)
  auto_upload_enabled="${config%%|*}"
  upload_bucket="${config#*|}"
  log "INFO" "Config from manifest: auto_upload_enabled=$auto_upload_enabled, bucket=$upload_bucket"

  # Override with environment variable if set
  if [ -n "${GBM_AUTO_UPLOAD:-}" ]; then
    auto_upload_enabled=$(echo "$GBM_AUTO_UPLOAD" | tr '[:upper:]' '[:lower:]')
    log "INFO" "Overridden by GBM_AUTO_UPLOAD env var: $auto_upload_enabled"
  fi

  if [ "$auto_upload_enabled" = "true" ]; then
    log "INFO" "Auto-upload is enabled"
    if is_artifact_generating_command "$COMMAND_NAME"; then
      log "INFO" "Command '$COMMAND_NAME' is artifact-generating"
      if [ -n "$FEATURE_DIR" ] && [ -d "$FEATURE_DIR" ]; then
        log "INFO" "Feature dir exists: $FEATURE_DIR - triggering upload"
        trigger_auto_upload "$FEATURE_DIR" "$upload_bucket"
        log "INFO" "Upload triggered in background"
      else
        log "WARN" "Feature dir missing or not a directory: '$FEATURE_DIR'"
      fi
    else
      log "INFO" "Command '$COMMAND_NAME' is not artifact-generating, skipping upload"
    fi
  else
    log "INFO" "Auto-upload is disabled in config"
  fi
else
  log "INFO" "Auto-upload skipped (GBM_SKIP_AUTO_UPLOAD=$GBM_SKIP_AUTO_UPLOAD or status=$STATUS)"
fi

# 3. FUTURE HOOKS CAN BE ADDED HERE
# ----------------------------------------------------------------------------
# Example: notifications, metrics, cleanup, etc.

log "INFO" "post-command-hook.sh completed successfully"
exit 0

