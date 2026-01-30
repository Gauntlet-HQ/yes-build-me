#!/usr/bin/env bash
# Purpose : Confirm prerequisites for later SDD stages and expose feature paths.
# Why     : Prevents commands like `/implement` or `/review` from running before
#           required artifacts exist.
# How     : Leverages shared helpers to locate feature docs, validates required
#           files, and reports results in text or JSON.

# Consolidated prerequisite checking script
#
# This script provides unified prerequisite checking for Spec-Driven Development workflow.

set -e

# Parse command line arguments
JSON_MODE=false
REQUIRE_TASKS=false
INCLUDE_TASKS=false
PATHS_ONLY=false
SKIP_BRANCH_CHECK=false

for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --require-tasks)
            REQUIRE_TASKS=true
            ;;
        --include-tasks)
            INCLUDE_TASKS=true
            ;;
        --paths-only)
            PATHS_ONLY=true
            ;;
        --skip-branch-check)
            SKIP_BRANCH_CHECK=true
            ;;
        --help|-h)
            cat << 'EOF'
Usage: check-prerequisites.sh [OPTIONS]

Consolidated prerequisite checking for Spec-Driven Development workflow.

OPTIONS:
  --json              Output in JSON format
  --require-tasks     Require tasks.md to exist (for implementation phase)
  --include-tasks     Include tasks.md in AVAILABLE_DOCS list
  --paths-only        Only output path variables (no prerequisite validation)
  --skip-branch-check Skip feature branch validation (for project-level operations)
  --help, -h          Show this help message

EXAMPLES:
  # Check task prerequisites (plan.md required)
  ./check-prerequisites.sh --json
  
  # Check implementation prerequisites (plan.md + tasks.md required)
  ./check-prerequisites.sh --json --require-tasks --include-tasks
  
  # Get feature paths only (no validation)
  ./check-prerequisites.sh --paths-only
  
EOF
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$arg'. Use --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Source common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get feature paths and validate branch
eval $(get_feature_paths)

# Only check feature branch if not explicitly skipped
if ! $SKIP_BRANCH_CHECK; then
    check_feature_branch "$CURRENT_BRANCH" "$HAS_GIT" || exit 1
fi

# If paths-only mode, output paths and exit (support JSON + paths-only combined)
if $PATHS_ONLY; then
    if $JSON_MODE; then
        # Full JSON paths payload (no validation performed) - includes workspace-aware paths
        printf '{"REPO_ROOT":"%s","BRANCH":"%s","FEATURE_DIR":"%s","FEATURE_SPEC":"%s","IMPL_PLAN":"%s","TASKS":"%s","GBM_ROOT":"%s","WORKSPACE_ROOT":"%s","CONSTITUTION_PATH":"%s","ARCHITECTURE_DIRS":"%s","MODE":"%s"}\n' \
            "$REPO_ROOT" "$CURRENT_BRANCH" "$FEATURE_DIR" "$FEATURE_SPEC" "$IMPL_PLAN" "$TASKS" "$GBM_ROOT" "$WORKSPACE_ROOT" "$CONSTITUTION_PATH" "$ARCHITECTURE_DIRS" "$MODE"
    else
        echo "REPO_ROOT: $REPO_ROOT"
        echo "BRANCH: $CURRENT_BRANCH"
        echo "FEATURE_DIR: $FEATURE_DIR"
        echo "FEATURE_SPEC: $FEATURE_SPEC"
        echo "IMPL_PLAN: $IMPL_PLAN"
        echo "TASKS: $TASKS"
        echo "GBM_ROOT: $GBM_ROOT"
        echo "WORKSPACE_ROOT: $WORKSPACE_ROOT"
        echo "CONSTITUTION_PATH: $CONSTITUTION_PATH"
        echo "ARCHITECTURE_DIRS: $ARCHITECTURE_DIRS"
        echo "MODE: $MODE"
    fi
    exit 0
fi

# Validate required directories and files
if [[ ! -d "$FEATURE_DIR" ]]; then
    echo "ERROR: Feature directory not found: $FEATURE_DIR" >&2
    echo "Run /specify first to create the feature structure." >&2
    exit 1
fi

if [[ ! -f "$IMPL_PLAN" ]]; then
    echo "ERROR: plan.md not found in $FEATURE_DIR" >&2
    echo "Run /plan first to create the implementation plan." >&2
    exit 1
fi

# Check for tasks.md if required
if $REQUIRE_TASKS && [[ ! -f "$TASKS" ]]; then
    echo "ERROR: tasks.md not found in $FEATURE_DIR" >&2
    echo "Run /tasks first to create the task list." >&2
    exit 1
fi

# Build list of available documents
docs=()

# Always check these optional docs
[[ -f "$RESEARCH" ]] && docs+=("research.md")
[[ -f "$DATA_MODEL" ]] && docs+=("data-model.md")

# Check contracts directory (only if it exists and has files)
if [[ -d "$CONTRACTS_DIR" ]] && [[ -n "$(ls -A "$CONTRACTS_DIR" 2>/dev/null)" ]]; then
    docs+=("contracts/")
fi

[[ -f "$QUICKSTART" ]] && docs+=("quickstart.md")

# Include tasks.md if requested and it exists
if $INCLUDE_TASKS && [[ -f "$TASKS" ]]; then
    docs+=("tasks.md")
fi

# Output results
if $JSON_MODE; then
    # Build JSON array of documents
    if [[ ${#docs[@]} -eq 0 ]]; then
        json_docs="[]"
    else
        json_docs=$(printf '"%s",' "${docs[@]}")
        json_docs="[${json_docs%,}]"
    fi
    
    printf '{"FEATURE_DIR":"%s","AVAILABLE_DOCS":%s,"GBM_ROOT":"%s","WORKSPACE_ROOT":"%s","CONSTITUTION_PATH":"%s","ARCHITECTURE_DIRS":"%s","MODE":"%s","BRANCH":"%s"}\n' \
        "$FEATURE_DIR" "$json_docs" "$GBM_ROOT" "$WORKSPACE_ROOT" "$CONSTITUTION_PATH" "$ARCHITECTURE_DIRS" "$MODE" "$CURRENT_BRANCH"
else
    # Text output
    echo "FEATURE_DIR:$FEATURE_DIR"
    echo "AVAILABLE_DOCS:"
    
    # Show status of each potential document
    check_file "$RESEARCH" "research.md"
    check_file "$DATA_MODEL" "data-model.md"
    check_dir "$CONTRACTS_DIR" "contracts/"
    check_file "$QUICKSTART" "quickstart.md"
    
    if $INCLUDE_TASKS; then
        check_file "$TASKS" "tasks.md"
    fi
fi

# Record metadata for plan.md (if it exists)
# This happens after AI agent has written to plan.md from /plan command
if command -v python3 >/dev/null 2>&1; then
  METADATA_SCRIPT="$SCRIPT_DIR/../record-metadata.py"
  if [[ -f "$METADATA_SCRIPT" ]] && [[ -f "$IMPL_PLAN" ]]; then
    python3 "$METADATA_SCRIPT" \
      --feature-name "$CURRENT_BRANCH" \
      --command "plan" \
      --artifact-path "$IMPL_PLAN" \
      --repo-root "$REPO_ROOT" \
      >/dev/null 2>&1 || true
  fi
fi
