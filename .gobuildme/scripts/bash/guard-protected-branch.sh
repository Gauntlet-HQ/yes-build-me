#!/usr/bin/env bash
# Purpose : Prevent commits on protected branches (main, master, develop, etc.)
# Why     : The harness system instructs frequent commits, but these should never
#           happen on protected branches. This guard prevents accidental commits
#           to main/master when users haven't created a feature branch.
# How     : Checks current git branch against protected branch list and exits
#           with error if on a protected branch.
# Usage   : source this script before any git commit, or run directly
#           ./guard-protected-branch.sh [--quiet]

set -e

# Parse arguments
QUIET=false
for arg in "$@"; do
    case "$arg" in
        --quiet|-q)
            QUIET=true
            ;;
    esac
done

# Protected branch patterns
PROTECTED_BRANCHES="^(main|master|develop|dev|staging|production|prod)$"

# Get current branch
get_current_branch() {
    if git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
        git rev-parse --abbrev-ref HEAD
    else
        echo ""
    fi
}

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    # Not a git repository - can't commit anyway, so just warn and exit success
    if [[ "$QUIET" != "true" ]]; then
        echo "[guard] Not a git repository - skipping branch guard" >&2
    fi
    exit 0
fi

CURRENT_BRANCH=$(get_current_branch)

if [[ -z "$CURRENT_BRANCH" ]]; then
    echo "ERROR: Could not determine current branch" >&2
    exit 1
fi

# Check if current branch is protected
if [[ "$CURRENT_BRANCH" =~ $PROTECTED_BRANCHES ]]; then
    echo "" >&2
    echo "╔══════════════════════════════════════════════════════════════════╗" >&2
    echo "║  ❌ COMMIT BLOCKED: You are on protected branch '$CURRENT_BRANCH'" >&2
    echo "╠══════════════════════════════════════════════════════════════════╣" >&2
    echo "║  GoBuildMe prevents commits directly to protected branches.      ║" >&2
    echo "║                                                                  ║" >&2
    echo "║  To fix this, create a feature branch:                           ║" >&2
    echo "║     git checkout -b <feature-name>                               ║" >&2
    echo "║                                                                  ║" >&2
    echo "║  Then re-run your command.                                       ║" >&2
    echo "╚══════════════════════════════════════════════════════════════════╝" >&2
    echo "" >&2
    exit 1
fi

# Branch is safe for commits
if [[ "$QUIET" != "true" ]]; then
    echo "[guard] ✓ On feature branch '$CURRENT_BRANCH' - commits allowed" >&2
fi
exit 0

