#!/usr/bin/env bash
set -euo pipefail

# fact-check.sh - Extract fact-checking context from project
# This script outputs JSON with paths needed for fact-checking workflow

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Default values
OUTPUT_JSON=false
FEATURE_DIR_OVERRIDE=""
SOURCE_FILE_OVERRIDE=""
PERSONA_ID_OVERRIDE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --json)
      OUTPUT_JSON=true
      shift
      ;;
    --feature-dir)
      FEATURE_DIR_OVERRIDE="$2"
      shift 2
      ;;
    --source-file)
      SOURCE_FILE_OVERRIDE="$2"
      shift 2
      ;;
    --persona-id)
      PERSONA_ID_OVERRIDE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Determine feature directory
FEATURE_DIR=""
if [ -n "$FEATURE_DIR_OVERRIDE" ]; then
  FEATURE_DIR="$FEATURE_DIR_OVERRIDE"
else
  # Find most recent feature directory if not specified
  if [ -d "$PROJECT_ROOT/.gobuildme/specs" ]; then
    FEATURE_DIR=$(find "$PROJECT_ROOT/.gobuildme/specs" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -r | head -n 1 || echo "")
  fi
fi

# Determine source file (if not specified, look for common research files)
SOURCE_FILE=""
if [ -n "$SOURCE_FILE_OVERRIDE" ]; then
  SOURCE_FILE="$SOURCE_FILE_OVERRIDE"
elif [ -n "$FEATURE_DIR" ]; then
  # Check for common research files
  for file in research.md architecture.md prd.md security-audit.md test-plan.md; do
    if [ -f "$FEATURE_DIR/$file" ]; then
      SOURCE_FILE="$FEATURE_DIR/$file"
      break
    fi
  done
fi

# Determine persona ID
PERSONA_ID=""
if [ -n "$PERSONA_ID_OVERRIDE" ]; then
  PERSONA_ID="$PERSONA_ID_OVERRIDE"
elif [ -f "$PROJECT_ROOT/.gobuildme/config/personas.yaml" ]; then
  # Extract default_persona from personas.yaml
  PERSONA_ID=$(grep -E "^default_persona:" "$PROJECT_ROOT/.gobuildme/config/personas.yaml" 2>/dev/null | awk '{print $2}' | tr -d '"' || echo "")
fi

# Constitution path
CONSTITUTION_PATH="$PROJECT_ROOT/.gobuildme/memory/constitution.md"

# Output
if [ "$OUTPUT_JSON" = true ]; then
  cat <<EOF
{
  "feature_dir": "$FEATURE_DIR",
  "source_file": "$SOURCE_FILE",
  "persona_id": "$PERSONA_ID",
  "constitution_path": "$CONSTITUTION_PATH",
  "project_root": "$PROJECT_ROOT"
}
EOF
else
  echo "FEATURE_DIR=$FEATURE_DIR"
  echo "SOURCE_FILE=$SOURCE_FILE"
  echo "PERSONA_ID=$PERSONA_ID"
  echo "CONSTITUTION_PATH=$CONSTITUTION_PATH"
  echo "PROJECT_ROOT=$PROJECT_ROOT"
fi
