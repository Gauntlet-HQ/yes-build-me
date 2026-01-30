#!/usr/bin/env bash
# Purpose: Upload specification files to S3 with presigned URLs
# Why: Enables centralized spec storage and analysis across projects
# How: Generates presigned URLs, uploads files in parallel, handles errors gracefully
#
# Usage:
#   ./upload-spec.sh                    # Auto-detect current spec directory
#   ./upload-spec.sh /path/to/spec      # Upload specific spec directory
#   ./upload-spec.sh --dry-run          # Validate without uploading
#   ./upload-spec.sh --help             # Show help
#
# Requirements:
#   - Python 3.8+ with boto3 and requests libraries
#   - AWS credentials configured (via ~/.aws/credentials, SSO, or environment)
#   - S3 bucket write permissions
#
# Configuration (priority: env vars > config file > defaults):
#   Config file: .gobuildme/config.yaml
#     upload_spec:
#       s3_bucket: "my-custom-bucket"
#       url_expiration: 7200
#
# Environment Variables:
#   GBM_S3_BUCKET    - Override S3 bucket (highest priority)
#   AWS_PROFILE      - AWS profile to use for credentials
#   AWS_REGION       - AWS region (default: us-west-2)

set -euo pipefail

# Choose Python interpreter (prefer active virtualenv, allow override)
if [[ -n "${GBM_PYTHON:-}" ]]; then
    PYTHON_BIN="$GBM_PYTHON"
elif [[ -n "${VIRTUAL_ENV:-}" && -x "$VIRTUAL_ENV/bin/python" ]]; then
    PYTHON_BIN="$VIRTUAL_ENV/bin/python"
elif command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
    PYTHON_BIN="$(command -v python)"
else
    echo "[upload-spec] Python 3 is required but not found." >&2
    exit 1
fi

# Get script directory and repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
REPO_ROOT=$(get_repo_root)

# Prefer project-local virtualenv if present
if [[ -x "$REPO_ROOT/.venv/bin/python" ]]; then
    PYTHON_BIN="$REPO_ROOT/.venv/bin/python"
fi

# Default configuration
DEFAULT_S3_BUCKET="tools-ai-agents-spec-driven-development-gfm"
CONFIG_FILE_PATH=".gobuildme/config.yaml"

# Function to read config value from .gobuildme/config.yaml
# Uses yq if available, falls back to Python, or returns empty string
read_config_value() {
    local key="$1"
    local config_file=""

    # Find config file (check current dir and parent directories)
    if [[ -f "$CONFIG_FILE_PATH" ]]; then
        config_file="$CONFIG_FILE_PATH"
    elif [[ -f "$REPO_ROOT/$CONFIG_FILE_PATH" ]]; then
        config_file="$REPO_ROOT/$CONFIG_FILE_PATH"
    else
        # Config file not found, return empty
        return
    fi

    # Try yq first (most reliable)
    if command -v yq >/dev/null 2>&1; then
        local value
        value=$(yq -r ".upload_spec.$key // empty" "$config_file" 2>/dev/null)
        if [[ -n "$value" && "$value" != "null" ]]; then
            echo "$value"
            return
        fi
    fi

    # Fallback to Python (usually available)
    if [[ -x "$PYTHON_BIN" ]]; then
        local value
        value=$($PYTHON_BIN -c "
import sys
try:
    import yaml
    with open('$config_file', 'r') as f:
        config = yaml.safe_load(f)
    if config and 'upload_spec' in config and '$key' in config['upload_spec']:
        print(config['upload_spec']['$key'])
except:
    pass
" 2>/dev/null)
        if [[ -n "$value" ]]; then
            echo "$value"
            return
        fi

        # Fallback: simple grep-based parsing (last resort)
        value=$($PYTHON_BIN -c "
import re
try:
    with open('$config_file', 'r') as f:
        content = f.read()
    # Find upload_spec section and extract key
    match = re.search(r'upload_spec:.*?$key:\s*[\"'\''']?([^\"'\''\n#]+)', content, re.DOTALL)
    if match:
        print(match.group(1).strip().strip('\"').strip(\"'\"))
except:
    pass
" 2>/dev/null)
        if [[ -n "$value" ]]; then
            echo "$value"
        fi
    fi
}

# Get S3 bucket with priority: env var > config file > default
get_s3_bucket() {
    # Priority 1: Environment variable
    if [[ -n "${GBM_S3_BUCKET:-}" ]]; then
        echo "$GBM_S3_BUCKET"
        return
    fi

    # Priority 2: Config file
    local config_value
    config_value=$(read_config_value "s3_bucket")
    if [[ -n "$config_value" ]]; then
        echo "$config_value"
        return
    fi

    # Priority 3: Default
    echo "$DEFAULT_S3_BUCKET"
}

# Configuration (priority: env var > config file > default)
S3_BUCKET=$(get_s3_bucket)

# Python scripts paths (in .gobuildme/scripts/ for target projects)
GENERATE_URLS_SCRIPT="$SCRIPT_DIR/../generate-spec-presigned-urls.py"
UPLOAD_SCRIPT="$SCRIPT_DIR/../upload-presigned-urls.py"
PRESIGNED_URLS_JSON="$SCRIPT_DIR/../presigned_urls_output.json"

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
DRY_RUN=false
VERBOSE=false
QUIET=false

info() {
    if [[ "$QUIET" != "true" ]]; then
        echo -e "${GREEN}[upload-spec]${NC} $*"
    fi
}

debug() {
    if [[ "$VERBOSE" == "true" && "$QUIET" != "true" ]]; then
        echo -e "${BLUE}[upload-spec]${NC} $*"
    fi
}

warn() {
    if [[ "$QUIET" != "true" ]]; then
        echo -e "${YELLOW}[upload-spec]${NC} $*" >&2
    fi
}

error() {
    echo -e "${RED}[upload-spec]${NC} $*" >&2
}

die() {
    error "$*"
    cleanup
    exit 1
}

# Cleanup temporary files on exit
cleanup() {
    if [[ -f "$PRESIGNED_URLS_JSON" ]]; then
        rm -f "$PRESIGNED_URLS_JSON" 2>/dev/null || true
    fi
}

# Set trap for cleanup on exit
trap cleanup EXIT

show_help() {
    cat << EOF
Upload specification files to S3 for centralized storage and analysis.

Usage:
    $0 [OPTIONS] [SPEC_DIR]

Arguments:
    SPEC_DIR            Path to spec directory (auto-detected if not provided)

Options:
    --dry-run           Validate credentials and list files without uploading
    --verbose, -v       Show detailed progress information
    --quiet, -q         Suppress all output except errors
    --help, -h          Show this help message

Examples:
    # Upload current feature spec (auto-detect from git branch)
    $0

    # Upload specific spec directory
    $0 .gobuildme/specs/AT-201

    # Validate without uploading
    $0 --dry-run

    # Verbose output
    $0 --verbose .gobuildme/specs/my-feature

Requirements:
    - Python 3.8+ with boto3 and requests libraries
      Install: pip install boto3 requests
    - AWS credentials configured:
      - ~/.aws/credentials file
      - AWS SSO: aws sso login --profile <profile>
      - Environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
    - S3 bucket write permissions

Configuration:
    Settings can be configured via environment variables or .gobuildme/config.yaml.
    Priority order: environment variables > config file > defaults

    Config file format (.gobuildme/config.yaml):
        upload_spec:
          s3_bucket: "my-custom-bucket"
          url_expiration: 7200  # 2 hours in seconds

Environment Variables:
    GBM_S3_BUCKET    Override default S3 bucket (highest priority)
    AWS_PROFILE      AWS profile to use
    AWS_REGION       AWS region (default: us-west-2)

Exit Codes:
    0 - Success (all files uploaded)
    1 - Failure (validation failed or no files uploaded)
    2 - Partial success (some files uploaded, some failed)

Troubleshooting:
    AWS SSO expired:     aws sso login --profile <your-profile>
    Missing boto3:       pip install boto3 requests
    Permission denied:   Check IAM policy for s3:PutObject permission
EOF
}

# Parse arguments
SPEC_DIR=""
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --quiet|-q)
            QUIET=true
            shift
            ;;
        -*)
            die "Unknown option: $1. Use --help for usage."
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Get spec directory from positional args or auto-detect
if [[ ${#POSITIONAL_ARGS[@]} -gt 0 ]]; then
    SPEC_DIR="${POSITIONAL_ARGS[0]}"
else
    # Auto-detect spec directory from current branch using common.sh functions
    info "Auto-detecting spec directory from current branch..."

    # Capture get_feature_paths output and check for success
    feature_paths_output=$(get_feature_paths 2>&1) || {
        die "Could not auto-detect spec directory: $feature_paths_output"
    }

    # Eval the output to set FEATURE_DIR
    eval "$feature_paths_output"
    SPEC_DIR="${FEATURE_DIR:-}"

    if [[ -z "$SPEC_DIR" ]]; then
        die "Could not auto-detect spec directory. Please provide path as argument."
    fi
fi

# Step 0: Validate prerequisites
debug "Checking prerequisites..."

# Check Python 3 is available
if [[ ! -x "$PYTHON_BIN" ]]; then
    die "Python 3 is required but not found. Please install Python 3.8+."
fi

# Check required Python packages
if ! "$PYTHON_BIN" -c "import boto3" 2>/dev/null; then
    die "Python package 'boto3' is required. Install with: pip install boto3"
fi

if ! "$PYTHON_BIN" -c "import requests" 2>/dev/null; then
    die "Python package 'requests' is required. Install with: pip install requests"
fi

# Check Python scripts exist
if [[ ! -f "$GENERATE_URLS_SCRIPT" ]]; then
    die "Generate URLs script not found: $GENERATE_URLS_SCRIPT"
fi

if [[ ! -f "$UPLOAD_SCRIPT" ]]; then
    die "Upload script not found: $UPLOAD_SCRIPT"
fi

# Validate spec directory
if [[ ! -d "$SPEC_DIR" ]]; then
    die "Spec directory does not exist: $SPEC_DIR"
fi

SPEC_DIR=$(cd "$SPEC_DIR" && pwd)  # Get absolute path
SPEC_NAME=$(basename "$SPEC_DIR")

# Check spec directory has files
FILE_COUNT=$(find "$SPEC_DIR" -type f | wc -l | tr -d ' ')
if [[ "$FILE_COUNT" -eq 0 ]]; then
    warn "Spec directory is empty: $SPEC_DIR"
    exit 0
fi

info "Uploading spec directory: $SPEC_DIR"
info "Spec name: $SPEC_NAME"
info "Files found: $FILE_COUNT"
debug "S3 bucket: $S3_BUCKET"

# Step 1: Validate AWS credentials and connectivity (dry-run)
info "Validating AWS credentials and S3 access..."
if [[ "$QUIET" == "true" ]]; then
    if ! "$PYTHON_BIN" "$GENERATE_URLS_SCRIPT" "$SPEC_DIR" --dry-run >/dev/null 2>&1; then
        die "AWS validation failed. Check credentials and S3 bucket access."
    fi
else
    if ! "$PYTHON_BIN" "$GENERATE_URLS_SCRIPT" "$SPEC_DIR" --dry-run 2>&1; then
        die "AWS validation failed. Check credentials and S3 bucket access."
    fi
fi

info "AWS validation successful ✓"

# If dry-run mode, exit here
if [[ "$DRY_RUN" == "true" ]]; then
    info "Dry-run mode: validation passed, no files uploaded"
    info "Would upload $FILE_COUNT files to s3://$S3_BUCKET/spec-repository/$SPEC_NAME/"
    exit 0
fi

# Step 2: Generate presigned URLs
info "Generating presigned URLs for spec files..."
VERBOSE_FLAG=""
[[ "$VERBOSE" == "true" ]] && VERBOSE_FLAG="--debug"
if [[ "$QUIET" == "true" ]]; then
    if ! "$PYTHON_BIN" "$GENERATE_URLS_SCRIPT" "$SPEC_DIR" $VERBOSE_FLAG >/dev/null 2>&1; then
        die "Failed to generate presigned URLs"
    fi
else
    if ! "$PYTHON_BIN" "$GENERATE_URLS_SCRIPT" "$SPEC_DIR" $VERBOSE_FLAG > /dev/null; then
        die "Failed to generate presigned URLs"
    fi
fi

# Count files from JSON
TOTAL_FILES=$($PYTHON_BIN -c "import json; data = json.load(open('$PRESIGNED_URLS_JSON')); print(len(data))" 2>/dev/null || echo "0")
info "Generated presigned URLs for $TOTAL_FILES files ✓"

# Step 3: Upload files to S3
info "Uploading files to S3..."
UPLOAD_EXIT_CODE=0
if [[ "$QUIET" == "true" ]]; then
    "$PYTHON_BIN" "$UPLOAD_SCRIPT" "$PRESIGNED_URLS_JSON" --spec-dir "$SPEC_DIR" $VERBOSE_FLAG >/dev/null 2>&1 || UPLOAD_EXIT_CODE=$?
else
    "$PYTHON_BIN" "$UPLOAD_SCRIPT" "$PRESIGNED_URLS_JSON" --spec-dir "$SPEC_DIR" $VERBOSE_FLAG || UPLOAD_EXIT_CODE=$?
fi

# Step 4: Report results and exit with appropriate code
if [[ $UPLOAD_EXIT_CODE -eq 0 ]]; then
    info "✅ All files uploaded successfully"
    info "S3 location: s3://$S3_BUCKET/spec-repository/$SPEC_NAME/"
    exit 0
elif [[ $UPLOAD_EXIT_CODE -eq 2 ]]; then
    warn "⚠️  Partial success - some files were skipped"
    warn "S3 location: s3://$S3_BUCKET/spec-repository/$SPEC_NAME/"
    exit 2
else
    error "❌ Upload failed"
    exit 1
fi
