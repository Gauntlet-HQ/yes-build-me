#!/usr/bin/env bash
# Purpose: Get telemetry context for GoBuildMe command instrumentation (v3 - REST API)
# Why: Provides git context, session tracking, timestamps, command IDs, version info, and other metadata for telemetry
# How: Detects git branch/commit, manages session ID, generates timestamps and UUIDs, detects versions, calls REST API
#
# VERSION 3 CHANGES:
# - Uses REST API endpoints instead of MCP tools for telemetry tracking
# - Calls POST /api/v1/commands/start and POST /api/v1/commands/complete
# - Handles all telemetry logic internally (no MCP tool calls needed in .md files)
# - Configurable API endpoint via TELEMETRY_API_URL environment variable
#
# TELEMETRY API ENVIRONMENTS:
# The telemetry API URL can be configured via the TELEMETRY_API_URL environment variable.
#
# Available environments:
#   - Internal (default):   https://ai-cli-telemetry.classy-test.org
#   - Local development:    http://localhost:8080
#
# To change the environment, set TELEMETRY_API_URL before running commands:
#   export TELEMETRY_API_URL="http://localhost:8080"  # Local dev
#
# Default: Internal environment (https://ai-cli-telemetry.classy-test.org)
# - INSERT-UPDATE pattern support (v3.1):
#   * /api/v1/commands/start uses INSERT pattern (creates record with start_timestamp)
#   * /api/v1/commands/complete uses UPDATE pattern (updates record with complete_timestamp)
#   * Handles 409 Conflict (duplicate command_id on INSERT)
#   * Handles 404 Not Found (missing command_id on UPDATE)
#   * Duration computed from timestamps (no duration_ms in payload)
#
# Enhanced Features:
# - Duration calculation between two timestamps (--command-start-time)
# - Spec ID extraction from feature directory (--feature-dir)
# - Spec ID auto-detection from check-prerequisites.sh when --feature-dir not provided
# - Agent version auto-detection (dynamically queries agent CLI, e.g., auggie --version)
# - Model name auto-detection (reads from settings.json or environment variables)
# - Username auto-detection (from git config, or --username override, or GIT_USER_NAME env var)
# - Optional command ID generation (--generate-command-id, enabled by default)
# - REST API telemetry tracking (--track-start and --track-complete modes)
# - Quiet mode (--quiet) to suppress non-essential warnings
#
# Auto-Detection:
# - Spec ID: Automatically detects from check-prerequisites.sh output when --feature-dir not provided
#   Supports both uppercase FEATURE_DIR (current) and lowercase feature_dir (legacy)
# - Agent Version: Dynamically queries agent CLI (e.g., auggie --version) and extracts version number
#   For Augment Agent: Runs "auggie --version" and extracts version (e.g., "0.7.0" from "0.7.0 (commit 9a05382c)")
#   Priority: AGENT_VERSION env > agent CLI query > default "0.6.1"
# - Model: Detects based on agent name and configuration files
#   Priority: --model param > MODEL_NAME env > AUGMENT_MODEL env > .augment/settings.json (local) > ~/.augment/settings.json (home) > default
#   For Augment Agent: Reads "model" field from settings.json as-is (no conversion)
#   Example: "haiku4.5" or "claude-haiku-4-5" are reported as-is
# - Username: Detects from git config user.email (preferred), user.name, or whoami
#   Priority: --username param > GIT_USER_NAME env > git config user.email > git config user.name > whoami
#
# Usage:
#   Basic context: ./get-telemetry-context.sh --no-command-id [--quiet]
#   Track start (INSERT): ./get-telemetry-context.sh --track-start --command-name "gbm.analyze" [--feature-dir /path] [--parameters '{"key":"value"}'] [--quiet]
#   Track complete (UPDATE): ./get-telemetry-context.sh --track-complete --command-id UUID --status success --results '{"key":"value"}' [--error "error message"] [--quiet]
#
# INSERT-UPDATE Pattern:
#   - Track start creates a single record with start_timestamp (INSERT)
#   - Track complete updates the same record with complete_timestamp, status, results, error (UPDATE)
#   - Duration is computed from timestamps (no duration_ms in payload)
#   - Returns 409 Conflict if command_id already exists (duplicate INSERT)
#   - Returns 404 Not Found if command_id doesn't exist (UPDATE without INSERT)
#
# Quiet Mode:
#   Use --quiet to suppress non-essential warnings (e.g., API failures). The script will still output JSON results.
#   Useful for cleaner logs when telemetry failures are expected or acceptable.

set -euo pipefail

# Configuration
TELEMETRY_API_URL="${TELEMETRY_API_URL:-https://ai-cli-telemetry.classy-test.org}"
TELEMETRY_TIMEOUT="${TELEMETRY_TIMEOUT:-5}"

# Parse command-line arguments
COMMAND_START_TIME=""
FEATURE_DIR=""
MODEL_NAME="${MODEL_NAME:-}"
USERNAME="${GIT_USER_NAME:-}"
AGENT_NAME="${AGENT_NAME:-}"
AGENT_VERSION="${AGENT_VERSION:-}"
GENERATE_COMMAND_ID=true
TRACK_START_MODE=false
TRACK_COMPLETE_MODE=false
COMMAND_NAME=""
COMMAND_ID=""
COMMAND_PARAMETERS=""
COMPLETION_STATUS=""
COMPLETION_RESULTS=""
COMPLETION_ERROR=""
QUIET_MODE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --command-start-time)
      COMMAND_START_TIME="$2"
      shift 2
      ;;
    --feature-dir)
      FEATURE_DIR="$2"
      shift 2
      ;;
    --model)
      MODEL_NAME="$2"
      shift 2
      ;;
    --username)
      USERNAME="$2"
      shift 2
      ;;
    --generate-command-id)
      GENERATE_COMMAND_ID=true
      shift
      ;;
    --no-command-id)
      GENERATE_COMMAND_ID=false
      shift
      ;;
    --track-start)
      TRACK_START_MODE=true
      shift
      ;;
    --track-complete)
      TRACK_COMPLETE_MODE=true
      shift
      ;;
    --command-name)
      COMMAND_NAME="$2"
      shift 2
      ;;
    --command-id)
      COMMAND_ID="$2"
      shift 2
      ;;
    --parameters)
      COMMAND_PARAMETERS="$2"
      shift 2
      ;;
    --status)
      COMPLETION_STATUS="$2"
      shift 2
      ;;
    --results)
      COMPLETION_RESULTS="$2"
      shift 2
      ;;
    --error)
      COMPLETION_ERROR="$2"
      shift 2
      ;;
    --quiet)
      QUIET_MODE=true
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--command-start-time MS] [--feature-dir PATH] [--model NAME] [--username NAME] [--generate-command-id|--no-command-id] [--quiet]" >&2
      echo "   or: $0 --track-start --command-name NAME [--feature-dir PATH] [--parameters JSON] [--quiet]" >&2
      echo "   or: $0 --track-complete --command-id UUID --status STATUS --results JSON [--error MESSAGE] [--quiet]" >&2
      exit 1
      ;;
  esac
done

# ============================================================================
# TELEMETRY OPT-OUT CHECK (EARLY EXIT)
# ============================================================================
# Check if telemetry is enabled BEFORE doing any processing
# This ensures zero overhead when telemetry is disabled
# Priority: env var > manifest > default

# Check if TELEMETRY_ENABLED env var is explicitly set (even if empty)
if [ -z "${TELEMETRY_ENABLED+x}" ]; then
  # Env var NOT set - check manifest
  MANIFEST_FILE=".gobuildme/manifest.json"
  if [ -f "$MANIFEST_FILE" ]; then
    # Read telemetry.enabled from manifest (default to true if not present)
    # Use Python instead of jq for better portability
    TELEMETRY_ENABLED=$(python3 -c "
import json
import sys
try:
    with open('$MANIFEST_FILE', 'r') as f:
        data = json.load(f)
        enabled = data.get('telemetry', {}).get('enabled', True)
        print('true' if enabled else 'false')
except:
    print('true')
" 2>/dev/null || echo "true")
  else
    # No manifest - default to enabled
    TELEMETRY_ENABLED="true"
  fi
else
  # Env var IS set - use it (respects env var > manifest priority)
  # Normalize to lowercase for consistency (bash 3.2 compatible)
  TELEMETRY_ENABLED=$(echo "$TELEMETRY_ENABLED" | tr '[:upper:]' '[:lower:]')
fi

# Early exit if telemetry is disabled - NO processing, NO output, NO API calls
if [ "$TELEMETRY_ENABLED" != "true" ]; then
  # Silent exit - don't even output JSON
  # Commands should handle missing telemetry gracefully
  exit 0
fi

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Function to call REST API endpoint
call_telemetry_api() {
  local endpoint="$1"
  local payload="$2"
  local response
  local http_code
  local temp_file

  # Create temp file for response
  temp_file=$(mktemp)

  # Call API with timeout and capture HTTP status code
  # Redirect stderr to /dev/null in quiet mode to suppress curl errors
  # X-Correlation-ID: Used for distributed tracing and grouping related commands
  #   Currently generates random UUID per API call
  #   Future: Could use session_id for tracking complete workflows
  if [ "$QUIET_MODE" = true ]; then
    http_code=$(curl -s -w "%{http_code}" -o "$temp_file" -X POST \
      -H "Content-Type: application/json" \
      -H "X-Correlation-ID: $(uuidgen 2>/dev/null || echo 'unknown')" \
      --max-time "$TELEMETRY_TIMEOUT" \
      -d "$payload" \
      "${TELEMETRY_API_URL}${endpoint}" 2>/dev/null) || {
      rm -f "$temp_file"
      echo "{\"status\": \"error\", \"message\": \"API unavailable\", \"http_code\": 0}"
      return 0
    }
  else
    # X-Correlation-ID: Used for distributed tracing and grouping related commands
    http_code=$(curl -s -w "%{http_code}" -o "$temp_file" -X POST \
      -H "Content-Type: application/json" \
      -H "X-Correlation-ID: $(uuidgen 2>/dev/null || echo 'unknown')" \
      --max-time "$TELEMETRY_TIMEOUT" \
      -d "$payload" \
      "${TELEMETRY_API_URL}${endpoint}" 2>&1) || {
      echo "Warning: Telemetry API call failed (non-blocking): $endpoint" >&2
      rm -f "$temp_file"
      echo "{\"status\": \"error\", \"message\": \"API unavailable\", \"http_code\": 0}"
      return 0
    }
  fi

  # Read response body
  response=$(cat "$temp_file")
  rm -f "$temp_file"

  # Handle HTTP status codes
  case "$http_code" in
    200|201)
      # Success - return response as-is
      # 200 OK: Standard success response
      # 201 Created: Resource created successfully (used by /commands/start)
      echo "$response"
      ;;
    302|301|303|307|308)
      # Redirect - treat as error (API should not redirect)
      if [ "$QUIET_MODE" != true ]; then
        echo "Warning: Telemetry API returned redirect (HTTP $http_code): $endpoint" >&2
      fi
      echo "{\"status\": \"error\", \"message\": \"Unexpected redirect (HTTP $http_code)\", \"http_code\": $http_code}"
      ;;
    409)
      # Conflict (duplicate command_id on INSERT)
      if [ "$QUIET_MODE" != true ]; then
        echo "Warning: Command ID already exists (409 Conflict)" >&2
      fi
      echo "{\"status\": \"conflict\", \"message\": \"Command ID already exists\", \"http_code\": 409, \"detail\": $response}"
      ;;
    404)
      # Not Found (missing command_id on UPDATE)
      if [ "$QUIET_MODE" != true ]; then
        echo "Warning: Command ID not found (404 Not Found)" >&2
      fi
      echo "{\"status\": \"not_found\", \"message\": \"Command ID not found\", \"http_code\": 404, \"detail\": $response}"
      ;;
    *)
      # Other errors
      if [ "$QUIET_MODE" != true ]; then
        echo "Warning: Telemetry API returned HTTP $http_code: $endpoint" >&2
      fi
      echo "{\"status\": \"error\", \"message\": \"HTTP $http_code\", \"http_code\": $http_code, \"detail\": $response}"
      ;;
  esac
}



# Function to detect agent version and name
detect_agent_version() {
  local detected_agent_name="$1"
  local detected_agent_version=""

  # Convert to lowercase for case-insensitive matching
  local agent_lower=$(echo "$detected_agent_name" | tr '[:upper:]' '[:lower:]')

  case "$agent_lower" in
    *augment*)
      # Augment Agent - use auggie --version command
      if command -v auggie >/dev/null 2>&1; then
        local version_output=$(auggie --version 2>/dev/null || echo "")
        # Extract version number (e.g., "0.7.0" from "0.7.0 (commit 9a05382c)")
        detected_agent_version=$(echo "$version_output" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
      fi
      ;;
    *copilot*)
      # GitHub Copilot CLI - use gh copilot --version command
      if command -v gh >/dev/null 2>&1; then
        local version_output=$(gh copilot --version 2>/dev/null || echo "")
        # Extract version number (e.g., "1.1.1" from "version 1.1.1 (2025-06-17)")
        detected_agent_version=$(echo "$version_output" | sed -E 's/^version[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
      fi
      # Fallback to environment variable if command failed
      if [ -z "$detected_agent_version" ]; then
        detected_agent_version="${COPILOT_VERSION:-}"
      fi
      ;;
    *claude*)
      if command -v claude >/dev/null 2>&1; then
        detected_agent_version=$(claude --version 2>/dev/null || echo "")
      fi
      ;;
    *cursor*)
      # Cursor Editor - use cursor --version command
      if command -v cursor >/dev/null 2>&1; then
        local version_output=$(cursor --version 2>/dev/null || echo "")
        # Extract version number (first line, similar to VS Code format)
        detected_agent_version=$(echo "$version_output" | head -n1 | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
      fi
      # Fallback to environment variable if command failed
      if [ -z "$detected_agent_version" ]; then
        detected_agent_version="${CURSOR_VERSION:-}"
      fi
      ;;
    *cline*)
      # Cline (VS Code extension) - use code --list-extensions --show-versions
      if command -v code >/dev/null 2>&1; then
        local extension_info=$(code --list-extensions --show-versions 2>/dev/null | grep -i "saoudrizwan.claude-dev" || echo "")
        # Extract version number (e.g., "2.1.0" from "saoudrizwan.claude-dev@2.1.0")
        detected_agent_version=$(echo "$extension_info" | sed -E 's/.*@([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
      fi
      # Fallback to environment variable if command failed
      if [ -z "$detected_agent_version" ]; then
        detected_agent_version="${CLINE_VERSION:-}"
      fi
      ;;
    *aider*)
      # Aider - use aider --version command
      if command -v aider >/dev/null 2>&1; then
        local version_output=$(aider --version 2>/dev/null || echo "")
        # Extract version number from first line (e.g., "0.45.0")
        detected_agent_version=$(echo "$version_output" | head -n1 | sed -E 's/^aider[[:space:]]+//; s/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
      fi
      # Fallback to environment variable if command failed
      if [ -z "$detected_agent_version" ]; then
        detected_agent_version="${AIDER_VERSION:-}"
      fi
      ;;
    *continue*)
      detected_agent_version="${CONTINUE_VERSION:-}"
      ;;
  esac

  echo "$detected_agent_version"
}

# Function to detect model name from settings.json
detect_model_from_settings() {
  local agent_name="$1"
  local detected_model=""

  # Convert to lowercase for case-insensitive matching
  local agent_lower=$(echo "$agent_name" | tr '[:upper:]' '[:lower:]')

  case "$agent_lower" in
    *augment*)
      # Augment Agent - try to detect from settings.json
      # Priority: AUGMENT_MODEL env > .augment/settings.json (local) > ~/.augment/settings.json (home)

      # Check environment variable first
      if [ -n "${AUGMENT_MODEL:-}" ]; then
        detected_model="$AUGMENT_MODEL"
      # Check local project settings
      elif [ -f ".augment/settings.json" ]; then
        local model_id=$(grep -o '"model"[[:space:]]*:[[:space:]]*"[^"]*"' ".augment/settings.json" 2>/dev/null | sed 's/.*"model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        if [ -n "$model_id" ]; then
          detected_model="$model_id"
        fi
      # Check home directory settings
      elif [ -f "$HOME/.augment/settings.json" ]; then
        local model_id=$(grep -o '"model"[[:space:]]*:[[:space:]]*"[^"]*"' "$HOME/.augment/settings.json" 2>/dev/null | sed 's/.*"model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        if [ -n "$model_id" ]; then
          detected_model="$model_id"
        fi
      fi
      ;;
  esac

  echo "$detected_model"
}

# Function to detect all context (git, versions, etc.)
detect_all_context() {
  # Detect username if not provided
  if [ -z "$USERNAME" ]; then
    GIT_EMAIL=$(git config user.email 2>/dev/null || echo "")
    if [ -n "$GIT_EMAIL" ]; then
      USERNAME=$(echo "$GIT_EMAIL" | cut -d'@' -f1)
    else
      USERNAME=$(git config user.name 2>/dev/null || whoami 2>/dev/null || echo "")
    fi
  fi

  # Detect git context
  GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  GIT_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "")
  GIT_REMOTE=$(git config --get remote.origin.url 2>/dev/null || echo "")
  if [ -n "$GIT_REMOTE" ]; then
    GIT_REPO=$(echo "$GIT_REMOTE" | sed -E 's#^(https?://|git@)##' | sed -E 's#^[^:/]+[:/]##' | sed 's/\.git$//')
  else
    GIT_REPO=""
  fi

  # Detect versions
  GOBUILDME_VERSION=$(gobuildme --version 2>/dev/null | sed -E 's/^GoBuildMe CLI Version: //; s/^[^0-9]*([0-9]+\.[0-9]+\.[0-9]+).*$/\1/' || echo "")

  # Detect agent name and version
  AGENT_NAME="${AGENT_NAME:-Augment Agent}"
  if [ -z "$AGENT_VERSION" ]; then
    AGENT_VERSION=$(detect_agent_version "$AGENT_NAME")
    # Fallback to default if detection failed
    if [ -z "$AGENT_VERSION" ]; then
      AGENT_VERSION="0.6.1"
    fi
  fi

  # Detect model name
  if [ -z "$MODEL_NAME" ]; then
    MODEL_NAME=$(detect_model_from_settings "$AGENT_NAME")
    # Fallback to default if detection failed
    if [ -z "$MODEL_NAME" ]; then
      MODEL_NAME="Claude Sonnet 4.5"
    fi
  fi

  # Extract spec_id from feature directory
  SPEC_ID=""
  if [ -n "$FEATURE_DIR" ]; then
    SPEC_ID=$(basename "$FEATURE_DIR")
  else
    # Auto-detect feature directory if not provided
    # Try to find it from current directory or check-prerequisites.sh
    if command -v check-prerequisites.sh &> /dev/null || [ -f ".gobuildme/scripts/bash/check-prerequisites.sh" ]; then
      PREREQ_SCRIPT="${PREREQ_SCRIPT:-.gobuildme/scripts/bash/check-prerequisites.sh}"
      if [ -f "$PREREQ_SCRIPT" ]; then
        PREREQ_JSON=$("$PREREQ_SCRIPT" --json 2>/dev/null || echo "{}")
        # Try uppercase FEATURE_DIR first (current format), then lowercase (legacy)
        AUTO_FEATURE_DIR=$(echo "$PREREQ_JSON" | python3 -c "import json, sys; data = json.load(sys.stdin); print(data.get('FEATURE_DIR', data.get('feature_dir', '')))" 2>/dev/null || echo "")
        if [ -n "$AUTO_FEATURE_DIR" ]; then
          FEATURE_DIR="$AUTO_FEATURE_DIR"
          SPEC_ID=$(basename "$FEATURE_DIR")
        fi
      fi
    fi
  fi

  # Get session ID (persistent across commands in same session)
  SESSION_FILE="${HOME}/.gobuildme/session_id"
  if [ -f "$SESSION_FILE" ]; then
    SESSION_ID=$(cat "$SESSION_FILE")
  else
    SESSION_ID=$(python3 -c "import uuid; print(str(uuid.uuid4()))" 2>/dev/null || echo "")
    mkdir -p "$(dirname "$SESSION_FILE")"
    echo "$SESSION_ID" > "$SESSION_FILE"
  fi
}

# ============================================================================
# TRACK START MODE
# ============================================================================

if [ "$TRACK_START_MODE" = true ]; then
  # Validate required parameters
  if [ -z "$COMMAND_NAME" ]; then
    echo "Error: --command-name is required in --track-start mode" >&2
    exit 1
  fi

  # Generate command ID if not provided
  if [ -z "$COMMAND_ID" ]; then
    COMMAND_ID=$(python3 -c "import uuid; print(str(uuid.uuid4()))" 2>/dev/null || echo "")
  fi

  # Detect all context
  detect_all_context

  # Build payload for POST /api/v1/commands/start
  # Use environment variables to avoid escaping issues
  PAYLOAD=$(COMMAND_NAME="$COMMAND_NAME" \
    COMMAND_ID="$COMMAND_ID" \
    SPEC_ID="$SPEC_ID" \
    AGENT_NAME="$AGENT_NAME" \
    MODEL_NAME="$MODEL_NAME" \
    USERNAME="$USERNAME" \
    AGENT_VERSION="$AGENT_VERSION" \
    GOBUILDME_VERSION="$GOBUILDME_VERSION" \
    SESSION_ID="$SESSION_ID" \
    GIT_BRANCH="$GIT_BRANCH" \
    GIT_COMMIT="$GIT_COMMIT" \
    GIT_REPO="$GIT_REPO" \
    COMMAND_PARAMETERS="$COMMAND_PARAMETERS" \
    python3 -c '
import json
import sys
import os

payload = {
    "command_name": os.environ.get("COMMAND_NAME"),
    "command_id": os.environ.get("COMMAND_ID"),
    "spec_id": os.environ.get("SPEC_ID") or None,
    "agent": os.environ.get("AGENT_NAME") or None,
    "model": os.environ.get("MODEL_NAME") or None,
    "username": os.environ.get("USERNAME") or None,
    "agent_version": os.environ.get("AGENT_VERSION") or None,
    "gobuildme_version": os.environ.get("GOBUILDME_VERSION") or None,
    "session_id": os.environ.get("SESSION_ID") or None,
    "git_branch": os.environ.get("GIT_BRANCH") or None,
    "git_commit_sha": os.environ.get("GIT_COMMIT") or None,
    "git_repo": os.environ.get("GIT_REPO") or None,
}

# Add parameters if provided
params_str = os.environ.get("COMMAND_PARAMETERS", "")
if params_str:
    try:
        payload["parameters"] = json.loads(params_str)
    except:
        pass

# Remove None values
payload = {k: v for k, v in payload.items() if v is not None}

print(json.dumps(payload))
')

  # Call REST API
  RESPONSE=$(call_telemetry_api "/api/v1/commands/start" "$PAYLOAD")

  # Output JSON with command_id for caller to use
  TIMESTAMP_MS=$(python3 -c "import time; print(int(time.time() * 1000))")
  RESPONSE="$RESPONSE" \
    COMMAND_ID="$COMMAND_ID" \
    SPEC_ID="$SPEC_ID" \
    TIMESTAMP_MS="$TIMESTAMP_MS" \
    python3 -c '
import json
import sys
import os

try:
    response_str = os.environ.get("RESPONSE", "{}")
    response = json.loads(response_str)
    output = {
        "command_id": os.environ.get("COMMAND_ID"),
        "timestamp_ms": int(os.environ.get("TIMESTAMP_MS", "0")),
        "spec_id": os.environ.get("SPEC_ID") or None,
        "api_response": response
    }
    print(json.dumps(output, indent=2))

    # Exit with error code if API returned error
    if response.get("status") == "error":
        sys.exit(1)
    sys.exit(0)
except Exception as e:
    error_output = {
        "error": str(e),
        "command_id": os.environ.get("COMMAND_ID", "")
    }
    print(json.dumps(error_output), file=sys.stderr)
    sys.exit(1)
'
  EXIT_CODE=$?

  exit $EXIT_CODE
fi

# ============================================================================
# TRACK COMPLETE MODE
# ============================================================================

if [ "$TRACK_COMPLETE_MODE" = true ]; then
  # Validate required parameters
  if [ -z "$COMMAND_ID" ]; then
    echo "Error: --command-id is required in --track-complete mode" >&2
    exit 1
  fi
  if [ -z "$COMPLETION_STATUS" ]; then
    echo "Error: --status is required in --track-complete mode" >&2
    exit 1
  fi
  if [ -z "$COMPLETION_RESULTS" ]; then
    echo "Error: --results is required in --track-complete mode" >&2
    exit 1
  fi

  # Build payload for POST /api/v1/commands/complete
  PAYLOAD=$(COMMAND_ID="$COMMAND_ID" \
    COMPLETION_STATUS="$COMPLETION_STATUS" \
    COMPLETION_RESULTS="$COMPLETION_RESULTS" \
    COMPLETION_ERROR="$COMPLETION_ERROR" \
    python3 -c '
import json
import sys
import os

payload = {
    "command_id": os.environ.get("COMMAND_ID"),
    "status": os.environ.get("COMPLETION_STATUS"),
}

# Add results
results_str = os.environ.get("COMPLETION_RESULTS", "")
try:
    payload["results"] = json.loads(results_str)
except Exception as e:
    print(f"Error parsing results JSON: {e}", file=sys.stderr)
    sys.exit(1)

# Add error if provided
error_str = os.environ.get("COMPLETION_ERROR", "")
if error_str:
    payload["error"] = error_str

print(json.dumps(payload))
')

  # Call REST API
  RESPONSE=$(call_telemetry_api "/api/v1/commands/complete" "$PAYLOAD")

  # Output JSON with duration and response
  RESPONSE="$RESPONSE" \
    COMMAND_ID="$COMMAND_ID" \
    COMPLETION_STATUS="$COMPLETION_STATUS" \
    python3 -c '
import json
import sys
import os

try:
    response_str = os.environ.get("RESPONSE", "{}")
    response = json.loads(response_str)
    output = {
        "command_id": os.environ.get("COMMAND_ID"),
        "status": os.environ.get("COMPLETION_STATUS"),
        "api_response": response
    }
    print(json.dumps(output, indent=2))

    # Exit with error code if API returned error or not_found
    if response.get("status") in ["error", "not_found"]:
        sys.exit(1)
    sys.exit(0)
except Exception as e:
    error_output = {
        "error": str(e),
        "command_id": os.environ.get("COMMAND_ID", "")
    }
    print(json.dumps(error_output), file=sys.stderr)
    sys.exit(1)
'
  EXIT_CODE=$?

  exit $EXIT_CODE
fi

# ============================================================================
# NORMAL CONTEXT MODE (for backward compatibility)
# ============================================================================

# Get current timestamp in milliseconds
TIMESTAMP_MS=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || echo "")

# Generate a new command ID (UUID v4) for this invocation (if requested)
if [ "$GENERATE_COMMAND_ID" = true ]; then
  COMMAND_ID=$(python3 -c "import uuid; print(str(uuid.uuid4()))" 2>/dev/null || echo "")
fi

# Calculate duration if command start time provided
DURATION_MS=""
if [ -n "$COMMAND_START_TIME" ] && [ -n "$TIMESTAMP_MS" ]; then
  DURATION_MS=$((TIMESTAMP_MS - COMMAND_START_TIME))
fi

# Detect all context
detect_all_context

# Output JSON (for backward compatibility with existing scripts)
TIMESTAMP_MS="$TIMESTAMP_MS" \
  COMMAND_ID="$COMMAND_ID" \
  DURATION_MS="$DURATION_MS" \
  SPEC_ID="$SPEC_ID" \
  AGENT_NAME="$AGENT_NAME" \
  MODEL_NAME="$MODEL_NAME" \
  USERNAME="$USERNAME" \
  AGENT_VERSION="$AGENT_VERSION" \
  GOBUILDME_VERSION="$GOBUILDME_VERSION" \
  SESSION_ID="$SESSION_ID" \
  GIT_BRANCH="$GIT_BRANCH" \
  GIT_COMMIT="$GIT_COMMIT" \
  GIT_REPO="$GIT_REPO" \
  python3 -c '
import json
import os

def get_int_or_none(key):
    val = os.environ.get(key, "")
    return int(val) if val else None

output = {
    "timestamp_ms": get_int_or_none("TIMESTAMP_MS"),
    "command_id": os.environ.get("COMMAND_ID") or None,
    "duration_ms": get_int_or_none("DURATION_MS"),
    "spec_id": os.environ.get("SPEC_ID") or None,
    "agent": os.environ.get("AGENT_NAME") or None,
    "model": os.environ.get("MODEL_NAME") or None,
    "username": os.environ.get("USERNAME") or None,
    "agent_version": os.environ.get("AGENT_VERSION") or None,
    "gobuildme_version": os.environ.get("GOBUILDME_VERSION") or None,
    "session_id": os.environ.get("SESSION_ID") or None,
    "git_branch": os.environ.get("GIT_BRANCH") or None,
    "git_commit_sha": os.environ.get("GIT_COMMIT") or None,
    "git_repo": os.environ.get("GIT_REPO") or None,
}

# Remove None values
output = {k: v for k, v in output.items() if v is not None}

print(json.dumps(output, indent=2))
'

exit 0

