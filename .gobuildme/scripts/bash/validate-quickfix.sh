#!/usr/bin/env bash
# Purpose : Validate quickfix changes against limits and patterns.
# Why     : Ensures quickfix stays trivial; gives advisory notes if exceeded.
# How     : Uses git diff to check file count, line count, new files, and patterns.
#
# Returns (exit codes):
#   0 - Valid or advisory (proceed with commit)
#   2 - Security change detected (HARD BLOCK - requires full workflow)
#   3 - Not a git repository (skipped, proceed with caution)
#
# Output format:
#   VALID                              - Within limits
#   ADVISORY:<reason>:<details>        - Exceeds soft limits (proceed anyway)
#   BLOCK:security:<files>             - Security file changed (hard block)
#   SKIPPED:no_git                     - Not a git repo
#
# Note: Only BLOCK:security exits non-zero. All ADVISORY cases exit 0.
#
# Usage:
#   validate-quickfix.sh [--base <branch>]

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Quickfix soft limits (advisory only)
MAX_FILES=2
MAX_LINES=50
MAX_NEW_FILES=0

# Advisory file patterns (note but proceed)
ADVISORY_DEPS=("package.json" "package-lock.json" "requirements.txt" "Pipfile" "Pipfile.lock" "go.mod" "go.sum" "Cargo.toml" "Cargo.lock" "pom.xml" "build.gradle" "composer.json" "composer.lock" "Gemfile" "Gemfile.lock")
ADVISORY_SCHEMA=("migrations/" "*.sql" "schema.*" "*.prisma" "*.migration.*")
ADVISORY_API=("openapi.yaml" "openapi.yml" "openapi.json" "swagger.yaml" "swagger.yml" "swagger.json" "*.proto" "routes/")
ADVISORY_CONFIG=(".env*" "config/" "settings.*" "*.config.js" "*.config.ts")

# Security patterns - HARD BLOCK (directory-scoped only, no wildcards to avoid false positives)
# Note: Only matches directories like auth/, security/, etc. - not filenames containing "auth"
# All patterns must end with / to be treated as directory patterns by check_pattern
BLOCK_SECURITY=("auth/" "security/" "middleware/auth/" "middleware/security/" "acl/" "rbac/" "permissions/")

# Parse arguments
BASE_REF="HEAD"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)
      BASE_REF="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "SKIPPED:no_git"
  exit 3
fi

# Get changed files (staged + unstaged)
CHANGED_FILES=$(git diff --name-only "$BASE_REF" 2>/dev/null || git diff --name-only HEAD 2>/dev/null || echo "")
if [[ -z "$CHANGED_FILES" ]]; then
  # Also check staged changes
  CHANGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")
fi

# Check for untracked files early (before early exit)
UNTRACKED_FILES=$(git status --porcelain 2>/dev/null | grep '^??' | wc -l | tr -d ' ' || echo "0")

# If no tracked changes AND no untracked files, nothing to validate
if [[ -z "$CHANGED_FILES" ]] && [[ "$UNTRACKED_FILES" -eq 0 ]]; then
  echo "VALID:no_changes"
  exit 0
fi

# If only untracked files exist (no tracked changes), note but proceed
if [[ -z "$CHANGED_FILES" ]] && [[ "$UNTRACKED_FILES" -gt 0 ]]; then
  # No tracked changes but untracked files exist - advisory only
  if [[ "$UNTRACKED_FILES" -gt "$MAX_NEW_FILES" ]]; then
    echo "ADVISORY:new_files:$UNTRACKED_FILES>$MAX_NEW_FILES"
    echo "📄 Note: $UNTRACKED_FILES new files exceeds quickfix limit ($MAX_NEW_FILES). Consider /gbm.lite.request for future similar changes." >&2
  fi
  echo "VALID:no_tracked_changes,untracked=$UNTRACKED_FILES"
  exit 0
fi

# Count files changed
FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')

# Count lines changed
LINE_STATS=$(git diff --stat "$BASE_REF" 2>/dev/null | tail -1 || echo "")
if [[ -z "$LINE_STATS" ]]; then
  LINE_STATS=$(git diff --cached --stat 2>/dev/null | tail -1 || echo "")
fi

# Extract insertions and deletions (handle both singular and plural forms)
# Use head -1 to ensure single value in case of unexpected multi-line output
INSERTIONS=$(echo "$LINE_STATS" | grep -oE '[0-9]+ insertions?' | grep -oE '[0-9]+' | head -1 || echo "0")
DELETIONS=$(echo "$LINE_STATS" | grep -oE '[0-9]+ deletions?' | grep -oE '[0-9]+' | head -1 || echo "0")
# Ensure numeric values (strip any whitespace/newlines)
INSERTIONS="${INSERTIONS//[^0-9]/}"
DELETIONS="${DELETIONS//[^0-9]/}"
TOTAL_LINES=$((${INSERTIONS:-0} + ${DELETIONS:-0}))

# Count new files (staged adds + untracked files)
# Note: UNTRACKED_FILES already counted earlier for early exit check
NEW_FILES_STAGED=$(git diff --name-status "$BASE_REF" 2>/dev/null | grep '^A' | wc -l | tr -d ' ' || echo "0")
if [[ "$NEW_FILES_STAGED" == "0" ]]; then
  NEW_FILES_STAGED=$(git diff --cached --name-status 2>/dev/null | grep '^A' | wc -l | tr -d ' ' || echo "0")
fi
# Ensure numeric values (strip any whitespace/newlines)
NEW_FILES_STAGED="${NEW_FILES_STAGED//[^0-9]/}"
UNTRACKED_FILES="${UNTRACKED_FILES//[^0-9]/}"
# Initialize as 0 if empty after stripping
NEW_FILES_STAGED="${NEW_FILES_STAGED:-0}"
UNTRACKED_FILES="${UNTRACKED_FILES:-0}"
NEW_FILES=$((NEW_FILES_STAGED + UNTRACKED_FILES))

# Check forbidden patterns
check_pattern() {
  local pattern="$1"
  local files="$2"

  if [[ "$pattern" == */ ]]; then
    # Directory pattern (ends with /)
    # Match at start OR after any directory separator (handles src/auth/, pkg/routes/, etc.)
    local dir_name="${pattern%/}"  # Remove trailing slash
    echo "$files" | grep -E "(^|/)${dir_name}/" 2>/dev/null || true
  elif [[ "$pattern" == *"*"* ]]; then
    # Wildcard pattern (contains *)
    # Escape dots and other regex chars, then convert * to .*
    local regex
    regex=$(printf '%s' "$pattern" | sed 's/\./\\./g; s/\*/\.\*/g')
    echo "$files" | grep -E "$regex" 2>/dev/null || true
  else
    # Exact match - match at end of path (basename) or as full path
    echo "$files" | grep -E "(^|/)${pattern}$" 2>/dev/null || true
  fi
}

# Track advisory notes (will be printed but won't block)
ADVISORIES=""

# Check for security changes - HARD BLOCK (only blocking case)
for pattern in "${BLOCK_SECURITY[@]}"; do
  MATCHES=$(check_pattern "$pattern" "$CHANGED_FILES")
  if [[ -n "$MATCHES" ]]; then
    echo "BLOCK:security:$MATCHES"
    echo "🔒 Security/auth changes require FULL workflow" >&2
    echo "   → /gbm.request" >&2
    exit 2
  fi
done

# Check for dependency changes - ADVISORY (note but proceed)
for pattern in "${ADVISORY_DEPS[@]}"; do
  MATCHES=$(check_pattern "$pattern" "$CHANGED_FILES")
  if [[ -n "$MATCHES" ]]; then
    echo "ADVISORY:dependencies:$MATCHES"
    echo "📦 Note: Dependency changes detected. Consider /gbm.lite.request for future similar changes." >&2
    ADVISORIES+="deps "
  fi
done

# Check for schema changes - ADVISORY (note but proceed)
for pattern in "${ADVISORY_SCHEMA[@]}"; do
  MATCHES=$(check_pattern "$pattern" "$CHANGED_FILES")
  if [[ -n "$MATCHES" ]]; then
    echo "ADVISORY:schema:$MATCHES"
    echo "🗄️  Note: Schema changes detected. Consider /gbm.lite.request for future similar changes." >&2
    ADVISORIES+="schema "
  fi
done

# Check for API contract changes - ADVISORY (note but proceed)
for pattern in "${ADVISORY_API[@]}"; do
  MATCHES=$(check_pattern "$pattern" "$CHANGED_FILES")
  if [[ -n "$MATCHES" ]]; then
    echo "ADVISORY:api_contracts:$MATCHES"
    echo "📡 Note: API contract changes detected. Consider /gbm.lite.request for future similar changes." >&2
    ADVISORIES+="api "
  fi
done

# Check for config changes - ADVISORY (note but proceed)
for pattern in "${ADVISORY_CONFIG[@]}"; do
  MATCHES=$(check_pattern "$pattern" "$CHANGED_FILES")
  if [[ -n "$MATCHES" ]]; then
    echo "ADVISORY:config:$MATCHES"
    echo "⚙️  Note: Config file changes detected. Proceeding with quickfix." >&2
    ADVISORIES+="config "
  fi
done

# Check file count limit - ADVISORY (note but proceed)
if [[ "$FILE_COUNT" -gt "$MAX_FILES" ]]; then
  echo "ADVISORY:files:$FILE_COUNT>$MAX_FILES"
  echo "📁 Note: $FILE_COUNT files exceeds quickfix limit ($MAX_FILES). Consider /gbm.lite.request for future similar changes." >&2
  ADVISORIES+="files "
fi

# Check line count limit - ADVISORY (note but proceed)
if [[ "$TOTAL_LINES" -gt "$MAX_LINES" ]]; then
  echo "ADVISORY:lines:$TOTAL_LINES>$MAX_LINES"
  echo "📏 Note: $TOTAL_LINES lines exceeds quickfix limit ($MAX_LINES). Consider /gbm.lite.request for future similar changes." >&2
  ADVISORIES+="lines "
fi

# Check new file limit - ADVISORY (note but proceed)
if [[ "$NEW_FILES" -gt "$MAX_NEW_FILES" ]]; then
  echo "ADVISORY:new_files:$NEW_FILES>$MAX_NEW_FILES"
  echo "📄 Note: $NEW_FILES new files exceeds quickfix limit ($MAX_NEW_FILES). Consider /gbm.lite.request for future similar changes." >&2
  ADVISORIES+="new_files "
fi

# Get GBM version from manifest for debugging (optional, silent if missing)
GBM_VERSION=$(cat .gobuildme/manifest.json 2>/dev/null | grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | grep -o '"[^"]*"$' | tr -d '"' || echo "unknown")

# All checks passed (or only advisory notes) - exit 0 to proceed
if [[ -n "$ADVISORIES" ]]; then
  echo "VALID:files=$FILE_COUNT,lines=$TOTAL_LINES,new=$NEW_FILES,advisories=$ADVISORIES (gbm $GBM_VERSION)"
else
  echo "VALID:files=$FILE_COUNT,lines=$TOTAL_LINES,new=$NEW_FILES (gbm $GBM_VERSION)"
fi
exit 0
