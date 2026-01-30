#!/usr/bin/env bash
# Run integration tests for GoBuildMe CLI
# Usage: ./scripts/bash/run-integration-tests.sh [OPTIONS]
#
# Options:
#   --fast       Run only fast tests (skip slow agent tests)
#   --slow       Run all tests including slow agent tests
#   --agent NAME Run tests for specific agent only
#   --suite NAME Run specific test suite (init_agents, persona_commands, prd_workflow)
#   --verbose    Show detailed output
#   --help       Show this help message

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Default options
RUN_SLOW=false
VERBOSE=""
AGENT=""
SUITE=""
PYTEST_ARGS=()

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_help() {
    cat << EOF
Run integration tests for GoBuildMe CLI

Usage: $0 [OPTIONS]

Options:
    --fast       Run only fast tests (skip slow agent tests) [default]
    --slow       Run all tests including slow agent tests
    --agent NAME Run tests for specific agent only (e.g., claude, gemini)
    --suite NAME Run specific test suite:
                   - init_agents: Agent initialization tests
                   - persona_commands: Persona management tests
                   - prd_workflow: PRD workflow tests
    --verbose    Show detailed output (-v -s)
    --help       Show this help message

Examples:
    # Run fast tests only (default)
    $0

    # Run all tests including slow ones
    $0 --slow

    # Run tests for specific agent
    $0 --agent claude

    # Run specific test suite
    $0 --suite persona_commands

    # Run with verbose output
    $0 --verbose

    # Combine options
    $0 --slow --verbose
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --fast)
            RUN_SLOW=false
            shift
            ;;
        --slow)
            RUN_SLOW=true
            shift
            ;;
        --agent)
            AGENT="$2"
            shift 2
            ;;
        --suite)
            SUITE="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE="-v -s"
            shift
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_help
            exit 1
            ;;
    esac
done

# Change to repo root
cd "$REPO_ROOT"

# Check if pytest is installed
if ! command -v pytest &> /dev/null; then
    echo -e "${RED}Error: pytest not found${NC}"
    echo "Install with: pip install pytest pytest-timeout"
    exit 1
fi

# Check if gobuildme is installed
if ! command -v gobuildme &> /dev/null; then
    echo -e "${RED}Error: gobuildme CLI not found${NC}"
    echo "Install with: pip install -e ."
    exit 1
fi

# Build pytest command
PYTEST_CMD="pytest tests/integration/"

# Add suite filter
if [[ -n "$SUITE" ]]; then
    PYTEST_CMD="pytest tests/integration/test_${SUITE}.py"
fi

# Add agent filter
if [[ -n "$AGENT" ]]; then
    PYTEST_ARGS+=("-k" "$AGENT")
fi

# Add slow test handling
if [[ "$RUN_SLOW" == "true" ]]; then
    PYTEST_ARGS+=("--run-slow")
else
    PYTEST_ARGS+=("-m" "not slow")
fi

# Add verbose if requested
if [[ -n "$VERBOSE" ]]; then
    PYTEST_ARGS+=($VERBOSE)
else
    PYTEST_ARGS+=("-v")
fi

# Add standard options
PYTEST_ARGS+=("--tb=short" "--color=yes")

# Print configuration
echo -e "${GREEN}Running GoBuildMe Integration Tests${NC}"
echo "Repository: $REPO_ROOT"
echo "Test mode: $([ "$RUN_SLOW" == "true" ] && echo "All tests (including slow)" || echo "Fast tests only")"
[[ -n "$AGENT" ]] && echo "Agent filter: $AGENT"
[[ -n "$SUITE" ]] && echo "Suite filter: $SUITE"
echo ""

# Run tests
echo -e "${YELLOW}Executing: $PYTEST_CMD ${PYTEST_ARGS[*]}${NC}"
echo ""

if $PYTEST_CMD "${PYTEST_ARGS[@]}"; then
    echo ""
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi

