#!/usr/bin/env bash
#
# GoBuildMe Harness Script
# ========================
#
# PURPOSE:
#   Thin wrapper for session handoff and verification commands.
#   Part of the harness system that enables AI agents to work effectively
#   across multiple context windows on long-running features.
#
# WHY THIS EXISTS:
#   - Provides shell-friendly interface for the harness CLI commands
#   - Enables integration into shell workflows and CI/CD pipelines
#   - Delegates to Python CLI (gobuildme harness) for actual logic
#   - Scripts are simpler to call than Python modules directly
#
# USAGE:
#   gbm-harness.sh progress seed <feature> <persona> [participants...]
#   gbm-harness.sh progress update <feature>
#   gbm-harness.sh progress show <feature>
#
# EXAMPLES:
#   # Start a new feature with session handoff
#   gbm-harness.sh progress seed user-auth backend_engineer
#
#   # Multi-persona feature (backend lead + security + SRE reviewing)
#   gbm-harness.sh progress seed api-refactor qa_engineer frontend_engineer backend_engineer
#
#   # Update progress counts from tasks.md after completing work
#   gbm-harness.sh progress update user-auth
#
#   # Check current progress (useful at session start)
#   gbm-harness.sh progress show user-auth
#
# DEPENDENCIES:
#   - gobuildme CLI must be installed and in PATH
#   - Install with: uv tool install gobuildme-cli
#
# SEE ALSO:
#   - docs/handbook/harness-guide.md - Full harness system documentation
#   - docs/reference/harness-cli.md - CLI command reference
#   - gbm-verification-status.sh - Report verification matrix status
#   - gbm-verification-validate.sh - Validate matrix integrity
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

# ANSI color codes for user-friendly output
# Using basic colors that work across terminals (including CI/CD systems)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color - resets formatting

# ============================================================================
# Help & Usage
# ============================================================================

print_usage() {
    # Provides comprehensive help for users unfamiliar with the harness system
    echo "GoBuildMe Harness - Session Handoff & Verification"
    echo ""
    echo "Usage:"
    echo "  gbm-harness.sh progress seed <feature> <persona> [participants...]"
    echo "      Create a new progress file for session handoff."
    echo "      This file enables agents to resume work after context window resets."
    echo ""
    echo "  gbm-harness.sh progress update <feature>"
    echo "      Update progress summary from tasks.md."
    echo "      Call this after completing tasks to keep counts accurate."
    echo ""
    echo "  gbm-harness.sh progress show <feature>"
    echo "      Display current progress for a feature."
    echo "      Use at session start to understand current state."
    echo ""
    echo "Examples:"
    echo "  gbm-harness.sh progress seed user-auth backend_engineer"
    echo "  gbm-harness.sh progress seed api-refactor qa_engineer frontend_engineer backend_engineer"
    echo "  gbm-harness.sh progress update user-auth"
    echo "  gbm-harness.sh progress show user-auth"
    echo ""
    echo "Output Location:"
    echo "  .gobuildme/specs/<feature>/verification/gbm-progress.txt"
    echo ""
    echo "Note: This script delegates to 'gobuildme harness' CLI commands."
    echo "Ensure gobuildme is installed and in your PATH."
}

# ============================================================================
# Validation Functions
# ============================================================================

check_gobuildme() {
    # Verify gobuildme CLI is available before attempting to use it.
    # Failing early with a clear message is better than cryptic "command not found".
    if ! command -v gobuildme &> /dev/null; then
        echo -e "${RED}Error: gobuildme CLI not found in PATH${NC}" >&2
        echo "Install with: uv tool install gobuildme-cli" >&2
        exit 1
    fi
}

# ============================================================================
# Main Entry Point
# ============================================================================

main() {
    # Require at least one argument (the command group)
    if [ $# -lt 1 ]; then
        print_usage
        exit 1
    fi

    # Route to appropriate handler based on command group
    case "$1" in
        -h|--help|help)
            # Help is always available, even without gobuildme installed
            print_usage
            exit 0
            ;;
        progress)
            # Progress commands: seed, update, show
            # These manage the gbm-progress.txt file for session handoff
            check_gobuildme
            if [ $# -lt 2 ]; then
                echo -e "${RED}Error: progress requires a subcommand (seed, update, show)${NC}" >&2
                print_usage
                exit 1
            fi
            subcommand="$2"
            shift 2  # Remove 'progress' and subcommand, leaving feature and other args
            case "$subcommand" in
                seed)
                    # Create new progress file from template
                    # Args: <feature> <persona> [participants...]
                    gobuildme harness progress-seed "$@"
                    ;;
                update)
                    # Update Summary section counts from tasks.md
                    # Args: <feature>
                    gobuildme harness progress-update "$@"
                    ;;
                show)
                    # Display current progress (task counts + progress file path)
                    # Args: <feature>
                    gobuildme harness progress-show "$@"
                    ;;
                *)
                    echo -e "${RED}Error: Unknown progress subcommand: $subcommand${NC}" >&2
                    print_usage
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo -e "${RED}Error: Unknown command: $1${NC}" >&2
            print_usage
            exit 1
            ;;
    esac
}

# Execute main function with all script arguments
main "$@"
