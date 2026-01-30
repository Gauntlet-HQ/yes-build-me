#!/usr/bin/env bash
# Purpose : Share reusable helpers across all GoBuildMe Bash scripts.
# Why     : Centralizes branch detection, repo discovery, and file helpers so
#           command wrappers stay focused on their single responsibility.
# How     : Defines utility functions that infer project state (git, features,
#           specs) and provide consistent output to callers.

# =============================================================================
# MONOREPO/WORKSPACE ROOT RESOLUTION
# =============================================================================
# These functions support three deployment models:
#   - SINGLE REPO: Traditional single-project setup (default)
#   - MONOREPO: Single git repo with multiple apps/modules
#   - WORKSPACE: Multiple git repos under a common workspace directory
#
# Key environment variables:
#   - GOBUILDME_TARGET_ROOT: Override nearest .gobuildme/ (for feature artifacts)
#   - GOBUILDME_WORKSPACE_ROOT: Override workspace root (for constitution, globals)
#   - GOBUILDME_MODE: Force deployment mode ("single", "monorepo", "workspace")
#   - GOBUILDME_SCOPE: Force epic scope in automation ("cross", "local")
# =============================================================================

# Read mode from manifest.json without jq dependency.
# Uses grep/sed for portable JSON parsing.
#
# LIMITATIONS (best-effort parsing):
# - Only handles standard JSON formatting (no comments, no trailing commas)
# - Expects "mode" key at top level
# - On parse failure, returns empty string (treated as "single" mode)
# - Does NOT validate JSON syntax - only extracts "mode" value
#
# Usage: mode=$(_read_manifest_mode "/path/to/manifest.json")
_read_manifest_mode() {
    local manifest="$1"
    if [[ -f "$manifest" ]]; then
        # Extract "mode" value from JSON without jq
        # Handles: "mode": "workspace" or "mode":"monorepo"
        # Returns empty on any parse failure (defaults to "single" mode)
        grep -o '"mode"[[:space:]]*:[[:space:]]*"[^"]*"' "$manifest" 2>/dev/null | \
            sed 's/.*"mode"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | head -1
    fi
    # Returns empty string if file doesn't exist or parsing fails
    # Caller should treat empty as "single" mode
}

# Internal helper to check workspace mode without recursion.
# Used by get_gobuildme_root() to determine fallback behavior.
_get_workspace_root_internal() {
    if [[ -n "${GOBUILDME_WORKSPACE_ROOT:-}" ]]; then
        echo "$GOBUILDME_WORKSPACE_ROOT"
        return 0
    fi
    local dir="$(pwd)"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.gobuildme" ]]; then
            local manifest="$dir/.gobuildme/manifest.json"
            local mode=$(_read_manifest_mode "$manifest")
            if [[ "$mode" == "workspace" || "$mode" == "monorepo" ]]; then
                echo "$dir"
                return 0
            fi
        fi
        dir="$(dirname "$dir")"
    done
}

# Returns nearest .gobuildme/ from CWD (for feature artifacts, specs).
# NOTE: Does NOT honor GOBUILDME_WORKSPACE_ROOT - only GOBUILDME_TARGET_ROOT.
# This prevents feature artifacts from accidentally being written to workspace root.
#
# FALLBACK BEHAVIOR differs by mode:
# - Monorepo: Falls back to monorepo root (modules share same git repo)
# - Workspace: Returns empty if repo not initialized (repos are separate)
# - Single: Falls back to git root (backward compat)
#
# Usage: GOBUILDME_ROOT=$(get_gobuildme_root)
get_gobuildme_root() {
    # 1. Honor explicit override (ONLY TARGET_ROOT, not WORKSPACE_ROOT)
    if [[ -n "${GOBUILDME_TARGET_ROOT:-}" ]]; then
        echo "$GOBUILDME_TARGET_ROOT"
        return 0
    fi

    # 2. Walk up from CWD to find nearest .gobuildme/
    local dir="$(pwd)"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.gobuildme" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done

    # 3. Check mode to determine fallback behavior
    local workspace_root=$(_get_workspace_root_internal)
    if [[ -n "$workspace_root" ]]; then
        local mode=$(_read_manifest_mode "$workspace_root/.gobuildme/manifest.json")

        # MONOREPO mode: Fall back to monorepo root (modules share same repo)
        if [[ "$mode" == "monorepo" ]]; then
            echo "$workspace_root"
            return 0
        fi

        # WORKSPACE mode: Require explicit init (repos are separate)
        # Return empty - caller must handle with require_repo_gobuildme()
        return 1
    fi

    # 4. SINGLE-REPO mode: Fall back to git root (backward compat)
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$git_root" ]]; then
        echo "$git_root"
    fi
}

# Returns workspace/monorepo root (for constitution, global settings).
# REQUIRES explicit mode: workspace or monorepo in manifest.json.
# No manifest = not a workspace root (falls back to nearest .gobuildme/).
#
# Usage: WORKSPACE_ROOT=$(get_workspace_root)
get_workspace_root() {
    # 1. Honor explicit override (highest priority)
    if [[ -n "${GOBUILDME_WORKSPACE_ROOT:-}" ]]; then
        echo "$GOBUILDME_WORKSPACE_ROOT"
        return 0
    fi

    # 2. Find outermost .gobuildme/ with EXPLICIT mode: workspace or monorepo
    #    IMPORTANT: No manifest or mode != workspace/monorepo → NOT a workspace root
    local dir="$(pwd)"
    local workspace_candidate=""

    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.gobuildme" ]]; then
            local manifest="$dir/.gobuildme/manifest.json"
            local mode=$(_read_manifest_mode "$manifest")
            # Only directories with explicit workspace/monorepo mode qualify
            if [[ "$mode" == "workspace" || "$mode" == "monorepo" ]]; then
                workspace_candidate="$dir"
                # Continue walking up to find outermost (don't break)
            fi
        fi
        dir="$(dirname "$dir")"
    done

    # 3. Return workspace root if found, else nearest .gobuildme/ (single repo)
    #    Single repos without manifest are NOT workspace roots
    if [[ -n "$workspace_candidate" ]]; then
        echo "$workspace_candidate"
    else
        get_gobuildme_root
    fi
}

# Returns deployment mode: "single" | "monorepo" | "workspace".
# Walks UP to find outermost manifest with mode (not nearest).
#
# Usage: MODE=$(get_mode)
get_mode() {
    # Check env override first
    if [[ -n "${GOBUILDME_MODE:-}" ]]; then
        echo "$GOBUILDME_MODE"
        return 0
    fi

    # Walk up to find outermost .gobuildme/ with mode in manifest
    local dir="$(pwd)"
    local found_mode="single"  # Default if no manifest found

    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.gobuildme" ]]; then
            local manifest="$dir/.gobuildme/manifest.json"
            local mode=$(_read_manifest_mode "$manifest")
            if [[ -n "$mode" ]]; then
                found_mode="$mode"
                # Continue walking up to find outermost (don't break)
            fi
        fi
        dir="$(dirname "$dir")"
    done

    echo "$found_mode"
}

# Check if currently inside a git repository.
# Usage: if is_in_git_repo; then ...; fi
is_in_git_repo() {
    git rev-parse --show-toplevel &>/dev/null
}

# Check if CWD is at workspace root.
# NOTE: Does NOT use get_gobuildme_root() - only compares CWD with workspace root.
#
# POLICY: Git repos at workspace root ARE SUPPORTED (meta/infra repos).
# Detection is based on manifest mode, NOT git presence.
#
# Usage: if is_at_workspace_root; then ...; fi
is_at_workspace_root() {
    local workspace_root=$(get_workspace_root)
    local mode=$(get_mode)
    # At workspace root if:
    # 1. CWD equals workspace root path, AND
    # 2. Mode is explicitly "workspace" (not monorepo or single)
    [[ "$workspace_root" == "$(pwd)" ]] && [[ "$mode" == "workspace" ]]
}

# Check if CWD is at monorepo root.
# Usage: if is_at_monorepo_root; then ...; fi
is_at_monorepo_root() {
    local workspace_root=$(get_workspace_root)
    local mode=$(get_mode)
    [[ "$workspace_root" == "$(pwd)" ]] && [[ "$mode" == "monorepo" ]]
}

# Check if repo has its own .gobuildme/ initialized.
# Usage: if repo_has_gobuildme; then ...; fi
repo_has_gobuildme() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    [[ -n "$repo_root" && -d "$repo_root/.gobuildme" ]]
}

# Require repo to have .gobuildme/ - exits with error if not.
# Use this in feature commands that need repo-level initialization.
#
# Usage: require_repo_gobuildme || exit 1
require_repo_gobuildme() {
    if ! repo_has_gobuildme; then
        local repo_root
        repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
        local workspace_root=$(get_workspace_root)
        echo "ERROR: This repository has not been initialized with GoBuildMe." >&2
        echo "       Run 'gobuildme init .' in this repo first, or use workspace root for cross-repo epics." >&2
        if [[ -n "$workspace_root" ]]; then
            echo "       Workspace root: $workspace_root" >&2
        fi
        return 1
    fi
}

# Require workspace root to be valid - exits with error if not resolvable.
# Use this for commands that need workspace root (constitution, persona registry).
#
# Usage: WORKSPACE_ROOT=$(require_workspace_root) || exit 1
require_workspace_root() {
    local workspace_root=$(get_workspace_root)
    if [[ -z "$workspace_root" ]]; then
        echo "ERROR: Cannot determine workspace root." >&2
        echo "       Either:" >&2
        echo "       1. Run 'gobuildme init . --workspace' to create a workspace, or" >&2
        echo "       2. Run 'gobuildme init .' in a repo to create a single-repo setup, or" >&2
        echo "       3. Set GOBUILDME_WORKSPACE_ROOT environment variable" >&2
        return 1
    fi
    # Verify .gobuildme/ exists
    if [[ ! -d "$workspace_root/.gobuildme" ]]; then
        echo "ERROR: GoBuildMe not initialized at $workspace_root" >&2
        echo "       Run 'gobuildme init .' first." >&2
        return 1
    fi
    # Only require manifest for workspace/monorepo mode
    # Single-repo mode works without manifest (backward compat)
    local mode=$(get_mode)
    if [[ "$mode" == "workspace" || "$mode" == "monorepo" ]]; then
        local manifest="$workspace_root/.gobuildme/manifest.json"
        if [[ ! -f "$manifest" ]]; then
            echo "ERROR: Workspace manifest missing at $manifest" >&2
            echo "       Run 'gobuildme init . --workspace' to initialize properly." >&2
            return 1
        fi
    fi
    echo "$workspace_root"
}

# Require to be inside a git repo - exits with error if not.
# Use this for commands with git side effects (commit, push, PR).
#
# Usage: require_git_repo || exit 1
require_git_repo() {
    if ! git rev-parse --show-toplevel &>/dev/null; then
        echo "ERROR: Not inside a git repository." >&2
        echo "       cd into a repo directory to run git operations." >&2
        return 1
    fi
}

# Returns git root (ONLY for git operations).
# Returns empty string if not in a git repo.
#
# Usage: REPO_ROOT=$(get_git_root)
get_git_root() {
    git rev-parse --show-toplevel 2>/dev/null
}

# Returns constitution path (always from workspace root).
#
# Usage: CONSTITUTION=$(get_constitution_path)
get_constitution_path() {
    local root=$(get_workspace_root)
    echo "$root/.gobuildme/memory/constitution.md"
}

# Returns architecture directories in search order: module → root.
# Guards against empty get_gobuildme_root() results.
#
# Usage: for dir in $(get_architecture_dirs); do ...; done
get_architecture_dirs() {
    local dirs=()
    local current=$(get_gobuildme_root)

    # Guard: If no gobuildme root, return empty (caller should handle)
    if [[ -z "$current" ]]; then
        return 0
    fi

    # 1. Module/repo level (nearest .gobuildme/)
    if [[ -d "$current/.gobuildme/docs/technical/architecture" ]]; then
        dirs+=("$current/.gobuildme/docs/technical/architecture")
    fi

    # 2. Workspace/monorepo root level (if different)
    local workspace_root=$(get_workspace_root)
    if [[ "$workspace_root" != "$current" && -d "$workspace_root/.gobuildme/docs/technical/architecture" ]]; then
        dirs+=("$workspace_root/.gobuildme/docs/technical/architecture")
    fi

    printf '%s\n' "${dirs[@]}"
}

# Returns epic scope based on context and environment.
# Used by /gbm.request to determine where to create epic registry.
#
# Returns: "local" | "cross_repo" | "cross_module"
#
# Usage: SCOPE=$(get_epic_scope)
get_epic_scope() {
    local mode=$(get_mode)

    # 1. Check environment variable override first
    if [[ -n "${GOBUILDME_SCOPE:-}" ]]; then
        case "$GOBUILDME_SCOPE" in
            cross)
                # Map "cross" to specific mode based on workspace type
                if [[ "$mode" == "workspace" ]]; then
                    echo "cross_repo"
                elif [[ "$mode" == "monorepo" ]]; then
                    echo "cross_module"
                else
                    echo "local"  # Single repo - cross makes no sense, fallback to local
                fi
                return 0
                ;;
            local)
                echo "local"
                return 0
                ;;
            *)
                echo "WARNING: Invalid GOBUILDME_SCOPE='$GOBUILDME_SCOPE', using default" >&2
                ;;
        esac
    fi

    # 2. Deterministic defaults based on location
    if is_at_workspace_root; then
        echo "cross_repo"  # Always cross-repo at workspace root
        return 0
    fi

    if is_at_monorepo_root; then
        # At monorepo root, default to local but could be cross_module
        # (templates may prompt interactively)
        echo "local"
        return 0
    fi

    # 3. In repo/module - default to local (templates may prompt interactively)
    echo "local"
}

# Populate repo identifiers for slice registry (cross-repo slices ONLY).
# Returns error if repo is not under workspace root (invalid configuration).
#
# Usage: eval "$(get_repo_identifiers)" || exit 1
#        # Now repo_slug, repo_git_url, repo_path are set
get_repo_identifiers() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    local workspace_root=$(get_workspace_root)

    # Normalize paths to handle symlinks and ..
    if [[ -n "$repo_root" ]]; then
        repo_root=$(cd "$repo_root" && pwd -P)
    fi
    if [[ -n "$workspace_root" ]]; then
        workspace_root=$(cd "$workspace_root" && pwd -P)
    fi

    # repo_slug: folder name
    local repo_slug=""
    if [[ -n "$repo_root" ]]; then
        repo_slug=$(basename "$repo_root")
    fi

    # repo_git_url: git remote origin (OPTIONAL - don't block if missing)
    local repo_git_url=""
    if is_in_git_repo; then
        repo_git_url=$(git remote get-url origin 2>/dev/null || echo "")
        # Note: Empty is OK (detached remotes, local-only repos)
    fi

    # repo_path: relative path from workspace root
    # VALIDATION: repo must be under workspace root for cross-repo mode
    local repo_path=""
    if [[ -n "$workspace_root" && -n "$repo_root" && "$workspace_root" != "$repo_root" ]]; then
        # Check that repo_root starts with workspace_root (is nested under it)
        if [[ "$repo_root" != "$workspace_root"* ]]; then
            echo "ERROR: Repository '$repo_root' is not under workspace '$workspace_root'" >&2
            echo "       Cross-repo mode requires all repos to be nested under the workspace directory." >&2
            echo "       Move the repo under the workspace, or use local mode instead." >&2
            return 1
        fi
        # Compute relative path (using normalized paths)
        repo_path="${repo_root#$workspace_root/}"
    fi

    echo "repo_slug=$repo_slug"
    echo "repo_git_url=$repo_git_url"
    echo "repo_path=$repo_path"
}

# =============================================================================
# LEGACY REPOSITORY CONTEXT HELPERS
# =============================================================================
# These functions are maintained for backward compatibility.
# New code should prefer the monorepo/workspace-aware functions above.
# =============================================================================

# Get repository root, with fallback for non-git repositories.
# NOTE: For monorepo/workspace support, prefer get_gobuildme_root() or get_git_root().
get_repo_root() {
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
        return
    fi

    # Fall back to walking up from the script location until we find a marker
    local script_dir="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dir="$script_dir"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" || -f "$dir/pyproject.toml" || -d "$dir/.gobuildme" ]]; then
            echo "$dir"
            return
        fi
        dir="$(dirname "$dir")"
    done

    # Last resort: script directory
    echo "$script_dir"
}

# Get current branch, with fallback for non-git repositories.
# IMPORTANT: This function should NEVER return "main" as a silent fallback.
# If no branch can be determined, it returns "__NO_BRANCH__" which will trigger
# downstream guards to prevent accidental commits to protected branches.
get_current_branch() {
    # First check if SPECIFY_FEATURE environment variable is set
    if [[ -n "${SPECIFY_FEATURE:-}" ]]; then
        echo "$SPECIFY_FEATURE"
        return
    fi

    # Then check git if available
    if git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
        git rev-parse --abbrev-ref HEAD
        return
    fi

    # For non-git repos, try to find the most recently modified feature directory
    local repo_root=$(get_repo_root)
    # Use hidden .gobuildme/specs exclusively because public specs are legacy.
    local specs_dir="$repo_root/.gobuildme/specs"

    if [[ -d "$specs_dir" ]]; then
        # Find the most recently modified directory (no numbering assumption)
        local latest_feature=""
        local latest_time=0

        # Check if there are any subdirectories first
        local has_dirs=false
        for dir in "$specs_dir"/*; do
            if [[ -d "$dir" ]]; then
                has_dirs=true
                break
            fi
        done 2>/dev/null

        if [[ "$has_dirs" == "true" ]]; then
            for dir in "$specs_dir"/*; do
                if [[ -d "$dir" ]]; then
                    local dirname=$(basename "$dir")
                    # Skip system directories and protected branch names
                    if [[ "$dirname" != ".*" ]] && [[ ! "$dirname" =~ ^(main|master|develop|dev|staging|production|prod)$ ]]; then
                        # Get modification time (seconds since epoch)
                        local mod_time
                        if command -v stat >/dev/null 2>&1; then
                            # macOS/BSD stat
                            mod_time=$(stat -f "%m" "$dir" 2>/dev/null || echo "0")
                        else
                            # GNU stat (Linux)
                            mod_time=$(stat -c "%Y" "$dir" 2>/dev/null || echo "0")
                        fi

                        if [[ "$mod_time" -gt "$latest_time" ]]; then
                            latest_time=$mod_time
                            latest_feature=$dirname
                        fi
                    fi
                fi
            done

            if [[ -n "$latest_feature" ]]; then
                echo "$latest_feature"
                return
            fi
        fi
    fi

    # CRITICAL FIX: Do NOT return "main" as fallback - this caused commits to main branch.
    # Return a sentinel value that will fail downstream branch checks.
    echo "__NO_BRANCH__"
    echo "WARNING: Could not determine feature branch. Set SPECIFY_FEATURE or create a feature branch." >&2
}

# Check if we have git available.
has_git() {
    git rev-parse --show-toplevel >/dev/null 2>&1
}

check_feature_branch() {
    local branch="$1"
    local has_git_repo="$2"

    # For non-git repos, we can't enforce branch naming but still provide output.
    if [[ "$has_git_repo" != "true" ]]; then
        echo "[specify] Warning: Git repository not detected; skipped branch validation" >&2
        return 0
    fi

    # Check for sentinel value indicating branch detection failed
    if [[ "$branch" == "__NO_BRANCH__" ]]; then
        echo "ERROR: Could not determine current branch." >&2
        echo "Please create a feature branch: git checkout -b <feature-name>" >&2
        echo "Or set SPECIFY_FEATURE environment variable to the feature name." >&2
        return 1
    fi

    # Check if it's a meaningful feature branch (not main, master, develop, etc.)
    if [[ "$branch" =~ ^(main|master|develop|dev|staging|production|prod)$ ]]; then
        echo "ERROR: Not on a feature branch. Current branch: $branch" >&2
        echo "Feature branches should be named descriptively, like: feature-name or jira-123-feature-name" >&2
        return 1
    fi

    return 0
}

# Determine the specs root directory (hidden by default).
get_specs_root() { echo "$1/.gobuildme/specs"; }

# Normalize a slug to kebab-case lowercase.
# Converts underscores/spaces to hyphens, lowercases, preserves -- separator.
# Example: "MyEpic" → "myepic", "FrontEnd_UI" → "frontend-ui", "My Epic" → "my-epic"
normalize_slug() {
    local input="$1"
    local result
    # Step 1: Lowercase
    result=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    # Step 2: Preserve -- by replacing with placeholder
    result=$(echo "$result" | sed 's/--/__DOUBLE_DASH__/g')
    # Step 3: Replace underscores, spaces, and other non-alphanumeric with hyphens
    result=$(echo "$result" | sed 's/[^a-z0-9-]/-/g')
    # Step 4: Collapse multiple hyphens to single
    result=$(echo "$result" | sed 's/-\+/-/g')
    # Step 5: Restore -- separator
    result=$(echo "$result" | sed 's/__DOUBLE_DASH__/--/g')
    # Step 6: Trim leading/trailing hyphens
    result=$(echo "$result" | sed 's/^-//' | sed 's/-$//')
    echo "$result"
}

# Get feature directory, supporting both standalone and sliced epics.
# For sliced epics (feature_name contains "--"), resolves to specs/epics/<epic>/<slice>/
# For standalone features, resolves to specs/<feature>/
#
# SIGNATURES (backward compatible):
#   get_feature_dir                    # Uses $FEATURE_NAME env var and get_gobuildme_root()
#   get_feature_dir "feature-name"     # Uses specified feature name and get_gobuildme_root()
#   get_feature_dir "$repo_root" "$branch"  # LEGACY: Uses specified repo_root (for backward compat)
#
# RETURNS:
#   - Feature directory path (may not exist yet for new features)
#   - Exit 1 with error if GoBuildMe not initialized (new signature only)
#   - For epic slices (feature_name contains "--"): returns expected path even if not in registry yet
#
# NOTE: If feature_name contains "--", it's an epic slice (<epic>--<slice> format).
#       The function will look in specs/epics/<epic>/<slice>/.
get_feature_dir() {
    local root=""
    local feature_name=""
    local specs_root=""

    # Detect signature: 2 args = legacy, 0-1 args = new
    if [[ $# -eq 2 ]]; then
        # LEGACY signature: get_feature_dir "$repo_root" "$branch"
        root="$1"
        feature_name="$2"
        specs_root=$(get_specs_root "$root")
    else
        # NEW signature: get_feature_dir [feature_name]
        feature_name="${1:-$FEATURE_NAME}"
        root=$(get_gobuildme_root)

        # Guard: require valid gobuildme root with .gobuildme/ directory
        if [[ -z "$root" ]] || [[ ! -d "$root/.gobuildme" ]]; then
            echo "ERROR: Cannot resolve feature dir - GoBuildMe not initialized" >&2
            echo "       Run 'gobuildme init .' to initialize GoBuildMe." >&2
            return 1
        fi

        specs_root="$root/.gobuildme/specs"
    fi

    # Step 1: Check flat layout first (existing feature)
    if [[ -d "$specs_root/$feature_name" ]]; then
        echo "$specs_root/$feature_name"
        return 0
    fi

    # Step 2: Parse feature_name for double-dash (epic/slice separator)
    if [[ "$feature_name" == *"--"* ]]; then
        local epic_part="${feature_name%%--*}"    # Everything before first --
        local slice_part="${feature_name#*--}"    # Everything after first --
        local epic=$(normalize_slug "$epic_part")
        local slice=$(normalize_slug "$slice_part")

        # Check registry first (canonical source of truth)
        local registry="$specs_root/epics/$epic/slice-registry.yaml"
        if [[ -f "$registry" ]]; then
            # Verify slice exists in registry (anchored match to avoid substrings)
            if grep -qE "^[[:space:]]*slice_name:[[:space:]]*${slice}$" "$registry" 2>/dev/null; then
                echo "$specs_root/epics/$epic/$slice"
                return 0
            fi
        fi

        # Fallback to directory check
        if [[ -d "$specs_root/epics/$epic/$slice" ]]; then
            echo "$specs_root/epics/$epic/$slice"
            return 0
        fi

        # For epic--slice branches without existing registry:
        # Return the expected path (don't error) - let template show warning
        # This allows /gbm.request to display "orphan slice" warning and let user proceed
        # (Templates handle missing registry gracefully, see request.md step 6)
        echo "$specs_root/epics/$epic/$slice"
        return 0
    fi

    # Step 3: Search epics directory for matching slice (slice-name-only case)
    # Skip this if feature_name contains "--" (we already tried explicit epic path above)
    if [[ -d "$specs_root/epics" ]]; then
        for epic_dir in "$specs_root/epics"/*/; do
            if [[ -d "$epic_dir$feature_name" ]]; then
                echo "$epic_dir$feature_name"
                return 0
            fi
        done
    fi

    # Step 4: For simple features (no "--"): return flat path (may need to be created)
    echo "$specs_root/$feature_name"
    return 0
}

# Get all valid feature directories (standalone + sliced).
# Returns paths to all feature directories for spec enumeration.
#
# USAGE:
#   source common.sh
#   REPO_ROOT=$(get_repo_root)
#   for feature_dir in $(get_all_feature_dirs "$REPO_ROOT"); do
#       echo "Processing: $feature_dir"
#   done
#
# RETURNS:
#   - Standalone features: .gobuildme/specs/<feature>/
#   - Sliced features: .gobuildme/specs/epics/<epic>/<slice>/
#
# NOTE: This is infrastructure for progress tracking, telemetry, CI status, etc.
#       If no scripts currently call it, that's intentional - it's available for future use.
get_all_feature_dirs() {
    local repo_root="$1"
    local specs_root
    specs_root=$(get_specs_root "$repo_root")

    # Standalone features: specs/<feature>/
    for d in "$specs_root"/*/; do
        if [[ -d "$d" ]]; then
            local dirname
            dirname=$(basename "$d")
            # Exclude epics directory (it contains sliced features, not standalone)
            if [[ "$dirname" != "epics" ]]; then
                echo "$d"
            fi
        fi
    done

    # Sliced features: specs/epics/<epic>/<slice>/
    if [[ -d "$specs_root/epics" ]]; then
        for epic_dir in "$specs_root/epics"/*/; do
            if [[ -d "$epic_dir" ]]; then
                for slice_dir in "$epic_dir"*/; do
                    if [[ -d "$slice_dir" ]]; then
                        local slice_name
                        slice_name=$(basename "$slice_dir")
                        # Exclude registry file (not a directory, but glob might catch it)
                        if [[ "$slice_name" != "slice-registry.yaml" ]]; then
                            echo "$slice_dir"
                        fi
                    fi
                done
            fi
        done
    fi
}

get_feature_paths() {
    # =============================================================================
    # WORKSPACE-AWARE FEATURE PATH RESOLUTION
    # =============================================================================
    # Uses new monorepo/workspace root resolution functions:
    # - get_gobuildme_root(): Nearest .gobuildme/ for feature artifacts
    # - get_workspace_root(): Workspace/monorepo root for constitution
    # - get_git_root(): Git repo for branch operations
    # =============================================================================

    local gbm_root=$(get_gobuildme_root)
    local workspace_root=$(get_workspace_root)
    local git_root=$(get_git_root)
    local current_branch=$(get_current_branch)
    local has_git_repo="false"
    local deployment_mode=$(get_mode)

    if has_git; then
        has_git_repo="true"
    fi

    # Validate GoBuildMe is initialized
    if [[ -z "$gbm_root" ]] || [[ ! -d "$gbm_root/.gobuildme" ]]; then
        echo "ERROR: GoBuildMe not initialized. Run 'gobuildme init .' first." >&2
        return 1
    fi

    # Use new 1-arg signature for workspace-aware feature directory resolution
    local feature_dir=$(get_feature_dir "$current_branch")
    if [[ -z "$feature_dir" ]]; then
        echo "ERROR: Failed to resolve feature directory for branch '$current_branch'" >&2
        return 1
    fi

    # Resolve workspace-aware paths
    local constitution_path=$(get_constitution_path)
    local architecture_dirs=$(get_architecture_dirs | tr '\n' ':' | sed 's/:$//')

    # Legacy alias for backward compatibility
    local repo_root="${git_root:-$gbm_root}"

    cat <<EOF
REPO_ROOT='$repo_root'
GBM_ROOT='$gbm_root'
WORKSPACE_ROOT='$workspace_root'
GIT_ROOT='$git_root'
CURRENT_BRANCH='$current_branch'
HAS_GIT='$has_git_repo'
MODE='$deployment_mode'
FEATURE_DIR='$feature_dir'
REQUEST_FILE='$feature_dir/request.md'
FEATURE_SPEC='$feature_dir/spec.md'
IMPL_PLAN='$feature_dir/plan.md'
TASKS='$feature_dir/tasks.md'
RESEARCH='$feature_dir/research.md'
DATA_MODEL='$feature_dir/data-model.md'
QUICKSTART='$feature_dir/quickstart.md'
CONTRACTS_DIR='$feature_dir/contracts'
PRD='$feature_dir/prd.md'
CONSTITUTION_PATH='$constitution_path'
ARCHITECTURE_DIRS='$architecture_dirs'
EOF
}

# Lightweight status helpers used by setup commands to report readiness.
check_file() { [[ -f "$1" ]] && echo "  ✓ $2" || echo "  ✗ $2"; }
check_dir() { [[ -d "$1" && -n $(ls -A "$1" 2>/dev/null) ]] && echo "  ✓ $2" || echo "  ✗ $2"; }

# =============================================================================
# SCOPE VALIDATION HELPERS
# =============================================================================
# These functions support slice scope validation and constitution traceability.
# Used by validate-slice-consistency.sh and other validation scripts.
# =============================================================================

# Get base branch for git diff comparison.
# Priority: constitution config -> origin/HEAD -> "main" fallback
#
# Usage: BASE=$(get_base_branch)
get_base_branch() {
    local constitution_path
    constitution_path=$(get_constitution_path 2>/dev/null)

    # 1. Check constitution for explicit config
    if [[ -n "$constitution_path" ]] && [[ -f "$constitution_path" ]]; then
        local constitution_branch
        constitution_branch=$(python3 -c "import re,sys; m=re.search(r'<!-- default_branch: (\w+)', open(sys.argv[1]).read()); print(m.group(1) if m else '')" "$constitution_path" 2>/dev/null || echo "")
        if [[ -n "$constitution_branch" ]]; then
            echo "$constitution_branch"
            return
        fi
    fi

    # 2. Try origin/HEAD
    local origin_head
    origin_head=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@refs/remotes/origin/@@')
    if [[ -n "$origin_head" ]]; then
        echo "$origin_head"
        return
    fi

    # 3. Fallback
    echo "main"
}

# Normalize git diff path to scope path format based on registry_mode.
# Git diff paths are always repo-relative; scope paths vary by mode.
#
# Usage: NORMALIZED=$(normalize_path_for_scope "$file" "$registry_mode" "$module_path" "$repo_path")
normalize_path_for_scope() {
    local file="$1"
    local mode="$2"
    local mod_path="$3"
    local repo_path="$4"

    case "$mode" in
        local)
            # No normalization needed - both repo-relative
            echo "$file"
            ;;
        cross_module)
            # Strip module_path prefix from repo-relative git diff path
            if [[ -n "$mod_path" ]] && [[ "$file" == "$mod_path/"* ]]; then
                echo "${file#$mod_path/}"
            else
                echo "$file"
            fi
            ;;
        cross_repo)
            # Prefix repo_path to repo-relative git diff path
            if [[ -n "$repo_path" ]]; then
                echo "$repo_path/$file"
            else
                echo "$file"
            fi
            ;;
        *)
            echo "$file"
            ;;
    esac
}

# Check if a file path matches allowed scope in scope.json.
# Uses Python for reliable glob matching (pathlib handles ** correctly).
# Returns 0 if in scope, 1 if out of scope.
#
# Usage: if is_file_in_scope "$file" "$scope_json"; then ...; fi
is_file_in_scope() {
    local file="$1"
    local scope_file="$2"

    python3 << EOF
import json
from pathlib import PurePath
import fnmatch

with open('$scope_file') as f:
    scope = json.load(f)

file_path = '$file'

# 1. CHECK EXCLUDES FIRST (explicit deny takes priority)
for pattern in scope.get('excludes', []):
    if fnmatch.fnmatch(file_path, pattern):
        exit(1)  # Explicitly excluded

# 2. CHECK EXPLICIT ALLOWED_FILES
if file_path in scope.get('allowed_files', []):
    exit(0)  # Exact match

# 3. CHECK ALLOWED_PATTERNS (glob matching)
for pattern in scope.get('allowed_patterns', []):
    # Handle ** patterns using PurePath.match
    if '**' in pattern:
        if PurePath(file_path).match(pattern):
            exit(0)
    elif fnmatch.fnmatch(file_path, pattern):
        exit(0)

exit(1)  # Not in any allowed path/pattern
EOF
    return $?
}

# JSON helper with Python fallback (jq preferred).
# Usage: VALUE=$(json_get "$file" "key")
json_get() {
    local file="$1"
    local key="$2"
    if command -v jq &>/dev/null; then
        jq -r ".$key // empty" "$file" 2>/dev/null
    else
        python3 -c "import json; d=json.load(open('$file')); print(d.get('$key', '') if d.get('$key') is not None else '')" 2>/dev/null || echo ""
    fi
}

# YAML helper with fallback chain: yq -> Python yaml -> grep.
# Usage: VALUE=$(yaml_get "$file" "key")
yaml_get() {
    local file="$1"
    local key="$2"
    if command -v yq &>/dev/null; then
        yq ".$key" "$file" 2>/dev/null | grep -v '^null$' || echo ""
    elif python3 -c "import yaml" 2>/dev/null; then
        python3 -c "
import yaml
with open('$file') as f:
    d = yaml.safe_load(f)
val = d.get('$key', '') if d else ''
print(val if val is not None else '')
" 2>/dev/null || echo ""
    else
        # Last resort: grep for simple top-level keys
        grep -E "^${key}:" "$file" 2>/dev/null | sed "s/^${key}:[[:space:]]*//" | tr -d '"' || echo ""
    fi
}
