#!/usr/bin/env bash
#
# GoBuildMe Verification Status Script
# =====================================
#
# PURPOSE:
#   Reports the current status of verification matrix items.
#   Shows what's passing vs failing, helping track acceptance criteria completion.
#
# IMPORTANT:
#   This script does NOT run automated verification - it only REPORTS status.
#   Actual verification is performed by the AI agent executing each item's
#   verification_method (running tests, manual checks, etc.).
#
# WHY THIS EXISTS:
#   - Provides quick visibility into verification progress
#   - Helps identify which acceptance criteria still need work
#   - Useful for orientation at session start
#   - Can be integrated into CI/CD for status reporting
#
# USAGE:
#   gbm-verification-status.sh <feature>
#
# EXAMPLE:
#   gbm-verification-status.sh user-auth
#
# OUTPUT:
#   Displays a formatted table showing:
#   - Total verification items
#   - Passing count (items with passes: true)
#   - Failing count (items with passes: false)
#   - List of passing/failing item IDs
#
# EXIT CODES:
#   0 - Status retrieved successfully (or no matrix found - opt-in feature)
#   1 - Error retrieving status (e.g., invalid feature name, malformed JSON)
#
# FILES READ:
#   .gobuildme/specs/<feature>/verification/verification-matrix.json
#
# DEPENDENCIES:
#   - gobuildme CLI must be installed and in PATH
#   - Install with: uv tool install gobuildme-cli
#
# SEE ALSO:
#   - gbm-verification-validate.sh - Validates matrix integrity (tamper detection)
#   - gbm-harness.sh - Session handoff commands
#   - docs/handbook/harness-guide.md - Full harness system documentation
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

# ANSI color codes for error messages
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================================================
# Help & Usage
# ============================================================================

print_usage() {
    echo "GoBuildMe Verification Status"
    echo ""
    echo "Usage:"
    echo "  gbm-verification-status.sh <feature>"
    echo ""
    echo "Reports the current status of verification matrix items."
    echo ""
    echo "IMPORTANT: Does NOT run automated verification - only reports status."
    echo "Actual verification is performed by the AI agent running each item's"
    echo "verification_method (tests, manual checks, etc.)."
    echo ""
    echo "Output includes:"
    echo "  - Total items, passing count, failing count"
    echo "  - List of passing item IDs"
    echo "  - List of failing item IDs (need verification)"
    echo ""
    echo "Example:"
    echo "  gbm-verification-status.sh user-auth"
    echo ""
    echo "Exit codes:"
    echo "  0 - Status retrieved (or no matrix - opt-in feature)"
    echo "  1 - Error (invalid feature, malformed JSON)"
    echo ""
    echo "Note: This script delegates to 'gobuildme harness verify-status'."
}

# ============================================================================
# Validation Functions
# ============================================================================

check_gobuildme() {
    # Verify gobuildme CLI is available before attempting to use it.
    # Provides clear installation instructions if missing.
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
    # Require feature argument
    if [ $# -lt 1 ]; then
        print_usage
        exit 1
    fi

    case "$1" in
        -h|--help|help)
            # Help is always available, even without gobuildme installed
            print_usage
            exit 0
            ;;
        *)
            # Any other argument is treated as a feature name
            # Validation of feature name happens in the Python CLI
            check_gobuildme
            gobuildme harness verify-status "$1"
            ;;
    esac
}

# Execute main function with all script arguments
main "$@"
