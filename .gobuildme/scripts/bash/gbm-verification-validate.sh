#!/usr/bin/env bash
#
# GoBuildMe Verification Validate Script
# =======================================
#
# PURPOSE:
#   Validates that the verification matrix hasn't been tampered with.
#   Detects scope drift by comparing current matrix against the lock file.
#
# WHY THIS EXISTS:
#   - Enforces immutability of acceptance criteria (tooling, not trust)
#   - Prevents scope creep by detecting unauthorized changes
#   - Acts as a quality gate in /gbm.review and /gbm.push commands
#   - Provides audit trail for compliance and code review
#
# HOW IT WORKS:
#   1. Reads verification-matrix.json (current state)
#   2. Reads verification-matrix.lock.json (locked state with SHA256 hashes)
#   3. Computes hashes of immutable fields for each item
#   4. Compares against locked hashes
#   5. Reports any discrepancies (modified, added, or deleted items)
#
# MUTABLE VS IMMUTABLE FIELDS:
#   - MUTABLE (can change): passes, verified_at, verified_in_session, verification_evidence
#   - IMMUTABLE (locked): id, type, description, verification_method
#
# USAGE:
#   gbm-verification-validate.sh <feature>
#
# EXAMPLE:
#   gbm-verification-validate.sh user-auth
#
# VALIDATION RESULTS:
#   - SKIP: No verification-matrix.json found (opt-in feature, backwards compatible)
#   - WARN: Matrix exists but no lock file (suggest creating lock)
#   - PASS: All hashes match (no tampering detected)
#   - BLOCK: Tampering detected (hash mismatch, added/deleted items)
#
# EXIT CODES:
#   0 - PASS, SKIP, or WARN (proceed with workflow)
#   1 - BLOCK (tampering detected) or error (stop workflow)
#
# FILES READ:
#   .gobuildme/specs/<feature>/verification/verification-matrix.json
#   .gobuildme/specs/<feature>/verification/verification-matrix.lock.json
#
# WHEN TO USE:
#   - Automatically called by /gbm.review and /gbm.push commands
#   - Manually when you suspect scope drift
#   - In CI/CD pipelines as a quality gate
#
# IF VALIDATION FAILS:
#   - Review the tampered items listed in the output
#   - If changes were intentional: run 'gobuildme harness regenerate-lock <feature>'
#   - If changes were accidental: restore from git history
#
# DEPENDENCIES:
#   - gobuildme CLI must be installed and in PATH
#   - Install with: uv tool install gobuildme-cli
#
# SEE ALSO:
#   - gbm-verification-status.sh - Reports pass/fail status of items
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
    echo "GoBuildMe Verification Validate"
    echo ""
    echo "Usage:"
    echo "  gbm-verification-validate.sh <feature>"
    echo ""
    echo "Validates that the verification matrix hasn't been tampered with."
    echo "Compares current matrix against the lock file using SHA256 hashes."
    echo ""
    echo "Detects:"
    echo "  - MODIFIED: Item exists in both but hash differs"
    echo "  - DELETED: Item in lock file but not in matrix"
    echo "  - ADDED: Item in matrix but not in lock file"
    echo ""
    echo "Validation results:"
    echo "  SKIP  - No verification-matrix.json (opt-in, proceed)"
    echo "  WARN  - Matrix exists, no lock file (suggest creating lock)"
    echo "  PASS  - All hashes match (no tampering)"
    echo "  BLOCK - Tampering detected (stop workflow)"
    echo ""
    echo "Exit codes:"
    echo "  0 - PASS, SKIP, or WARN"
    echo "  1 - BLOCK (tampering detected) or error"
    echo ""
    echo "Example:"
    echo "  gbm-verification-validate.sh user-auth"
    echo ""
    echo "If validation fails:"
    echo "  - Intentional change: gobuildme harness regenerate-lock <feature>"
    echo "  - Accidental change: restore from git history"
    echo ""
    echo "Note: This script delegates to 'gobuildme harness verify-validate'."
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
            # Feature name validation (path traversal prevention) happens in Python CLI
            check_gobuildme
            gobuildme harness verify-validate "$1"
            ;;
    esac
}

# Execute main function with all script arguments
main "$@"
