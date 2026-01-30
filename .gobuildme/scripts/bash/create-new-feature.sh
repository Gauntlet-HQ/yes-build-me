#!/usr/bin/env bash
# Purpose : Create a numbered feature branch and folder scaffold from text.
# Why     : Standardizes branch naming and directory structure to feed the
#           Spec-Driven workflow.
# How     : Parses CLI flags, sanitizes the request into a slug, increments the
#           feature counter, and lays down request/spec placeholders.

set -euo pipefail

JSON_MODE=false
CUSTOM_SLUG=""
ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json)
            JSON_MODE=true
            shift
            ;;
        --slug)
            if [[ $# -lt 2 ]]; then
                echo "Error: --slug requires a value" >&2
                exit 1
            fi
            CUSTOM_SLUG="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [--json] [--slug <name>] <feature_description>"
            exit 0
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

FEATURE_DESCRIPTION="${ARGS[*]}"
if [[ -z "$FEATURE_DESCRIPTION" ]]; then
    if [[ -z "$CUSTOM_SLUG" ]]; then
        echo "Usage: $0 [--json] [--slug <name>] <feature_description>" >&2
        exit 1
    else
        FEATURE_DESCRIPTION="$CUSTOM_SLUG"
    fi
fi

# Normalize descriptive strings into safe branch-friendly slugs.
# Preserves -- (double-dash) as epic/slice separator.
sanitize_slug() {
    local raw="$1"
    local cleaned
    # Step 1: Lowercase and replace non-alphanumeric (except hyphen) with hyphen
    cleaned=$(echo "$raw" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')
    # Step 2: Preserve -- by replacing with placeholder, collapse other multiples, restore
    cleaned=$(echo "$cleaned" | sed 's/--/__DOUBLE_DASH__/g' | sed 's/-\+/-/g' | sed 's/__DOUBLE_DASH__/--/g')
    # Step 3: Trim leading/trailing hyphens
    cleaned=$(echo "$cleaned" | sed 's/^-//' | sed 's/-$//')
    if [[ -z "$cleaned" ]]; then
        echo "feature"
    else
        echo "$cleaned"
    fi
}

declare -a STOPWORDS=(
    a an and are as at be but by for from has have if in is it of on or our shall should so that the their this to we with you add adds added adding allow allows allowing allowed create creates created creating design designs designed designing ensure ensures ensured ensuring enhance enhances enhanced enhancing feature features fix fixes fixed fixing implement implements implemented implementing launch launches launched launching make makes made making need needs needed needing plan plans planned planning request requests requested requesting specify specifies specified specifying task tasks tasked tasking update updates updated updating want wants wanted wanting would
)

# Skip filler words we do not want in branch slugs.
is_filler() {
    local token="$1"
    for filler in "${STOPWORDS[@]}"; do
        if [[ "$token" == "$filler" ]]; then
            return 0
        fi
    done
    return 1
}

declare -a WORD_LIST=()
# Append unique tokens while preserving source order.
append_token() {
    local token="$1"
    if [[ -z "$token" ]]; then
        return
    fi
    for existing in "${WORD_LIST[@]-}"; do
        if [[ "$existing" == "$token" ]]; then
            return
        fi
    done
    WORD_LIST+=("$token")
}

# Gather candidate slug tokens from raw description and cleaned text.
collect_tokens() {
    local description="$1"
    local clean_desc="$2"

    # Prefer acronyms / all-caps identifiers first
    local acronyms_tmp=$(mktemp)
    echo "$description" | grep -oE '\b[A-Z0-9]{2,}\b' 2>/dev/null > "$acronyms_tmp" || true
    while IFS= read -r token; do
        [[ -z "$token" ]] && continue
        local lower=$(echo "$token" | tr '[:upper:]' '[:lower:]')
        if ! is_filler "$lower"; then
            append_token "$lower"
        fi
    done < "$acronyms_tmp"
    rm -f "$acronyms_tmp"

    # Next, longer meaningful words (>=3 chars) excluding filler
    local words_tmp=$(mktemp)
    echo "$clean_desc" | tr '[:upper:]' '[:lower:]' | grep -oE '\b[a-z0-9]{3,}\b' 2>/dev/null > "$words_tmp" || true
    while IFS= read -r token; do
        [[ -z "$token" ]] && continue
        local lower=$(echo "$token" | tr '[:upper:]' '[:lower:]')
        if ! is_filler "$lower"; then
            append_token "$lower"
        fi
    done < "$words_tmp"
    rm -f "$words_tmp"
}

# Build a hyphenated slug from up to three prioritized tokens.
generate_slug_words() {
    local description="$1"
    local clean_desc="$2"

    WORD_LIST=()
    collect_tokens "$description" "$clean_desc"

    if [[ ${#WORD_LIST[@]} -eq 0 ]]; then
        local fallback
        fallback=$(echo "$clean_desc" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//')
        if [[ -n "$fallback" ]]; then
            IFS='-' read -r -a WORD_LIST <<<"$fallback"
        fi
    fi

    if [[ ${#WORD_LIST[@]} -eq 0 ]]; then
        WORD_LIST=("feature")
    fi

    local selected=()
    for token in "${WORD_LIST[@]}"; do
        selected+=("$token")
        if [[ ${#selected[@]} -ge 3 ]]; then
            break
        fi
    done

    local slug
    IFS='-'
    slug="${selected[*]}"
    unset IFS
    echo "$slug"
}

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# =============================================================================
# MONOREPO/WORKSPACE ROOT RESOLUTION
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
MODE=$(get_mode)
WORKSPACE_ROOT=$(get_workspace_root)

# Resolve git root for branch operations (may be different from GBM_ROOT in monorepo)
GIT_ROOT=$(get_git_root)
if [[ -n "$GIT_ROOT" ]]; then
    HAS_GIT=true
    cd "$GIT_ROOT"
else
    HAS_GIT=false
    cd "$GBM_ROOT"
fi

# Legacy alias for backward compatibility
REPO_ROOT="${GIT_ROOT:-$GBM_ROOT}"

# Use workspace-aware specs root
SPECS_DIR="$GBM_ROOT/.gobuildme/specs"
mkdir -p "$SPECS_DIR"

# Try to extract a JIRA ticket like ABC-123 from the description/URL
# Preserve original casing for branch names and spec folders
TICKET=$(echo "$FEATURE_DESCRIPTION" | grep -Eo '([A-Z][A-Z0-9]+-[0-9]+)' | head -n1 || true)

# Build a clean version of the description without URLs or ticket IDs
CLEAN_DESC=$(echo "$FEATURE_DESCRIPTION" | sed -E 's|https?://[^ ]+||g' | sed -E 's/[A-Z][A-Z0-9]+-[0-9]+//g')

WORDS=""
if [[ -n "$CUSTOM_SLUG" ]]; then
    WORDS=$(sanitize_slug "$CUSTOM_SLUG")
else
    WORDS=$(generate_slug_words "$FEATURE_DESCRIPTION" "$CLEAN_DESC")
fi

if [[ -z "$WORDS" ]]; then
    WORDS="feature"
fi
WORDS=$(sanitize_slug "$WORDS")
if [[ -z "$WORDS" ]]; then
    WORDS="feature"
fi

# Apply branch prefix if set (used by quickfix workflow for "quickfix-" prefix)
# Only apply if no custom slug was provided (custom slugs are pre-prefixed by create-request.sh)
if [[ -n "${GBM_BRANCH_PREFIX:-}" ]] && [[ -z "$CUSTOM_SLUG" ]]; then
    WORDS="${GBM_BRANCH_PREFIX}${WORDS}"
fi

# Build branch name with JIRA-first approach (no artificial numbering)
if [[ -n "$TICKET" ]]; then
    # Remove any existing ticket fragment from the slug to avoid duplication
    # Use lowercase comparison but preserve original ticket casing in branch name
    ticket_lower=$(echo "$TICKET" | tr '[:upper:]' '[:lower:]')
    slug_without_ticket="$WORDS"
    slug_without_ticket="${slug_without_ticket#${ticket_lower}-}"
    slug_without_ticket="${slug_without_ticket#${ticket_lower}}"
    slug_without_ticket="${slug_without_ticket%-}"
    slug_without_ticket="${slug_without_ticket#-}"

    if [[ -n "$slug_without_ticket" ]]; then
        BRANCH_NAME="${TICKET}-${slug_without_ticket}"
    else
        BRANCH_NAME="${TICKET}"
    fi
else
    BRANCH_NAME="${WORDS}"
fi

if [ "$HAS_GIT" = true ]; then
    # Check for duplicate branch names (local and remote)
    # Fetch remote branches to ensure we have latest info
    git fetch --all --prune 2>/dev/null || true

    # Check if branch already exists locally
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
        >&2 echo "Error: Branch '$BRANCH_NAME' already exists locally."
        >&2 echo "Please use a different feature description or --slug to create a unique branch name."
        exit 1
    fi

    # Check if branch exists on remote
    if git ls-remote --heads origin "$BRANCH_NAME" 2>/dev/null | grep -q "$BRANCH_NAME"; then
        >&2 echo "Error: Branch '$BRANCH_NAME' already exists on remote."
        >&2 echo "Please use a different feature description or --slug to create a unique branch name."
        exit 1
    fi

    git checkout -b "$BRANCH_NAME"
else
    >&2 echo "[specify] Warning: Git repository not detected; skipped branch creation for $BRANCH_NAME"
fi

# Use get_feature_dir() to resolve correct path (handles epic--slice → specs/epics/<epic>/<slice>/)
# New 1-arg signature for workspace-aware resolution
FEATURE_DIR=$(get_feature_dir "$BRANCH_NAME")
DEFER_FEATURE_DIR_CREATION=false
if [[ "$MODE" == "workspace" && "$BRANCH_NAME" == *"--"* && "$GBM_ROOT" == "$WORKSPACE_ROOT" ]]; then
    epic_raw="${BRANCH_NAME%%--*}"
    epic=$(normalize_slug "$epic_raw")
    registry="$WORKSPACE_ROOT/.gobuildme/specs/epics/$epic/slice-registry.yaml"
    if [[ -f "$registry" ]]; then
        reg_mode=$(yaml_get "$registry" "mode" 2>/dev/null || true)
        if [[ "$reg_mode" == "cross_repo" || -z "$reg_mode" ]]; then
            DEFER_FEATURE_DIR_CREATION=true
        fi
    else
        # No registry yet at workspace root + epic slice -> assume cross_repo until created in repo
        DEFER_FEATURE_DIR_CREATION=true
    fi
fi

# Note: spec.md should only be created by /specify command, not during feature creation
SPEC_FILE="$FEATURE_DIR/spec.md"

# Also create request.md from template for this user request if not present
# Use GBM_ROOT for templates (workspace-aware)
REQUEST_TEMPLATE="$GBM_ROOT/.gobuildme/templates/request-template.md"
if [ ! -f "$REQUEST_TEMPLATE" ]; then
    REQUEST_TEMPLATE="$GBM_ROOT/templates/request-template.md"
fi
REQUEST_FILE="$FEATURE_DIR/request.md"
if [[ "$DEFER_FEATURE_DIR_CREATION" == "true" ]]; then
    echo "⚠️  Workspace root + epic slice detected. Skipping feature dir creation." >&2
    echo "   cd into the target repo and run /gbm.request to create slice artifacts." >&2
else
    mkdir -p "$FEATURE_DIR"
    if [ ! -f "$REQUEST_FILE" ]; then
        if [ -f "$REQUEST_TEMPLATE" ]; then cp "$REQUEST_TEMPLATE" "$REQUEST_FILE"; else echo -e "# Request\n\n> Describe the user request, context, and open questions." > "$REQUEST_FILE"; fi
    fi
fi

# Set the SPECIFY_FEATURE environment variable for the current session
export SPECIFY_FEATURE="$BRANCH_NAME"

if $JSON_MODE; then
    printf '{"BRANCH_NAME":"%s","SPEC_FILE":"%s","REQUEST_FILE":"%s","FEATURE_DIR":"%s","GBM_ROOT":"%s","WORKSPACE_ROOT":"%s","MODE":"%s","DEFER_FEATURE_DIR_CREATION":"%s"}\n' \
      "$BRANCH_NAME" "$SPEC_FILE" "$REQUEST_FILE" "$FEATURE_DIR" "$GBM_ROOT" "$WORKSPACE_ROOT" "$MODE" "$DEFER_FEATURE_DIR_CREATION"
else
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "SPEC_FILE: $SPEC_FILE"
    echo "REQUEST_FILE: $REQUEST_FILE"
    echo "FEATURE_DIR: $FEATURE_DIR"
    echo "GBM_ROOT: $GBM_ROOT"
    echo "WORKSPACE_ROOT: $WORKSPACE_ROOT"
    echo "MODE: $MODE"
    echo "DEFER_FEATURE_DIR_CREATION: $DEFER_FEATURE_DIR_CREATION"
    echo "SPECIFY_FEATURE environment variable set to: $BRANCH_NAME"
fi
