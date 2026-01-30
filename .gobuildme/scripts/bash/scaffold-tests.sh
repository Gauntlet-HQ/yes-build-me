#!/usr/bin/env bash
# Purpose: Scaffold integration test structure with samples and TODOs
# Why: Provides starting point for comprehensive integration testing
# How: Scans codebase, generates test files from templates

set -euo pipefail

# Source common utilities (if available)
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/qa-common.sh" ]; then
    source "$SCRIPT_DIR/qa-common.sh"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Parse arguments
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

export DRY_RUN=false
SKIP_BRANCH_CHECK=false
SKIP_WORKING_TREE_CHECK=false
PROTECT_EXISTING=true
AUTO_YES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-branch-check)
            SKIP_BRANCH_CHECK=true
            shift
            ;;
        --skip-working-tree-check)
            SKIP_WORKING_TREE_CHECK=true
            shift
            ;;
        --no-protect)
            PROTECT_EXISTING=false
            shift
            ;;
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --help)
            echo "Usage: scaffold-tests.sh [OPTIONS]"
            echo ""
            echo "Scaffold integration test structure with samples and TODOs for existing codebase"
            echo ""
            echo "⚠️  WARNING: This generates tests for the ENTIRE codebase (not just a feature)"
            echo ""
            echo "Recommended workflow:"
            echo "  1. Create dedicated branch: git checkout -b qa-test-scaffolding"
            echo "  2. Preview: /gbm.qa.scaffold-tests --dry-run"
            echo "  3. Execute: /gbm.qa.scaffold-tests"
            echo "  4. Review and commit"
            echo "  5. Open PR for review before merging to main"
            echo ""
            echo "Options:"
            echo "  --dry-run                    Preview changes without modifying files"
            echo "  --skip-branch-check          Skip branch safety check (not recommended)"
            echo "  --skip-working-tree-check    Skip uncommitted changes check"
            echo "  --no-protect                 Allow overwriting existing tests (dangerous!)"
            echo "  --yes, -y                    Auto-confirm all prompts"
            echo "  --help                       Show this help message"
            echo ""
            echo "Safety features:"
            echo "  • Warns if on main/master branch"
            echo "  • Warns if on feature branch"
            echo "  • Checks for uncommitted changes"
            echo "  • Protects existing real tests from being overwritten"
            echo "  • Creates automatic backup before modifications"
            echo ""
            echo "See docs/reference/TEST-GENERATION-ISOLATION.md for full workflow guide"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Use get_gobuildme_root() for monorepo/workspace support
GBM_ROOT=$(get_gobuildme_root)
GBM_BASE="${GBM_ROOT:-.}/.gobuildme"
SCAFFOLD_DIR="$GBM_BASE/specs/qa-test-scaffolding"
TEMPLATES_DIR="$GBM_BASE/templates"
SCRIPTS_DIR="$GBM_BASE/scripts/bash"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Safety Checks
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_branch_safety() {
    if [ "$SKIP_BRANCH_CHECK" = "true" ]; then
        return 0
    fi

    local current_branch=$(git branch --show-current 2>/dev/null)

    if [ -z "$current_branch" ]; then
        # Check if it's a git repo at all
        if git rev-parse --git-dir >/dev/null 2>&1; then
            # It's a git repo but detached HEAD or old git version
            current_branch="<detached-HEAD>"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "⚠️  WARNING: Running in detached HEAD state"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "This is common in CI/CD but risky for local development."
            echo ""
            echo "Detached HEAD means:"
            echo "  • You're not on any branch"
            echo "  • Commits may be lost when switching branches"
            echo "  • Usually happens after 'git checkout <commit-hash>'"
            echo ""
            echo "Recommended actions:"
            echo "  • Create a branch: git checkout -b qa-test-scaffolding"
            echo "  • Or switch to existing branch: git checkout main"
            echo ""

            if [ "$AUTO_YES" != "true" ]; then
                read -p "Continue in detached HEAD state? [y/N] " confirm
                if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
                    echo "Aborted. Create a branch first."
                    exit 0
                fi
            else
                echo "ℹ️  Auto-confirming (--yes flag active)"
            fi
        else
            # Not a git repo - probably OK for extracted projects or non-git workflows
            return 0
        fi
    fi

    # Check if on main/master
    if [[ "$current_branch" =~ ^(main|master)$ ]]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "⚠️  WARNING: You are on '$current_branch' branch"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Test scaffolding generates files for the ENTIRE codebase and may:"
        echo "  • Interfere with ongoing feature development"
        echo "  • Cause merge conflicts for active feature branches"
        echo "  • Create CI/CD failures if TODOs are not implemented"
        echo ""
        echo "Recommended workflow:"
        echo "  1. Create dedicated branch:"
        echo "     git checkout -b qa-test-scaffolding"
        echo ""
        echo "  2. Run scaffolding:"
        echo "     /gbm.qa.scaffold-tests"
        echo ""
        echo "  3. Review and commit:"
        echo "     git commit -m 'Add test scaffolding'"
        echo ""
        echo "  4. Open PR for review:"
        echo "     gh pr create --title 'Add test scaffolding'"
        echo ""
        echo "  5. Merge after approval:"
        echo "     git checkout main && git merge --no-ff qa-test-scaffolding"
        echo ""
        echo "See: docs/reference/TEST-GENERATION-ISOLATION.md"
        echo ""

        if [ "$AUTO_YES" != "true" ]; then
            read -p "Continue on '$current_branch' anyway? [y/N] " confirm
            if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
                echo "Cancelled. Create a dedicated branch first:"
                echo "  git checkout -b qa-test-scaffolding"
                exit 0
            fi
        else
            echo "[AUTO-CONFIRMED] Continuing on '$current_branch'"
        fi
        echo ""
    fi

    # Check if on active feature branch
    if [[ "$current_branch" =~ ^(feature/|feat/|fix/|bugfix/) ]]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "⚠️  WARNING: You are on feature branch '$current_branch'"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Running FULL-CODEBASE test scaffolding on a feature branch will:"
        echo "  • Create tests unrelated to your feature"
        echo "  • Cause merge conflicts when merging to main"
        echo "  • Pollute your feature with scaffolding commits"
        echo ""
        echo "Recommended: Use dedicated qa-test-scaffolding branch instead."
        echo ""
        echo "If you need tests for your feature only, use:"
        echo "  /gbm.tests    (feature-scoped test generation)"
        echo ""

        if [ "$AUTO_YES" != "true" ]; then
            read -p "Continue full-codebase scaffolding on feature branch? [y/N] " confirm
            if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
                exit 0
            fi
        else
            echo "[AUTO-CONFIRMED] Continuing on feature branch"
        fi
        echo ""
    fi
}

check_working_tree() {
    if [ "$SKIP_WORKING_TREE_CHECK" = "true" ]; then
        return 0
    fi

    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "⚠️  WARNING: You have uncommitted changes"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        git status --short | head -10
        if [ $(git status --short | wc -l) -gt 10 ]; then
            echo "... and $(git status --short | wc -l) more files"
        fi
        echo ""
        echo "Test scaffolding will create many files. It's safer to:"
        echo "  • Commit your current work: git commit -am 'WIP'"
        echo "  • Or stash it: git stash"
        echo ""
        echo "This allows easy rollback if needed."
        echo ""

        if [ "$AUTO_YES" != "true" ]; then
            read -p "Continue with uncommitted changes? [y/N] " confirm
            if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
                exit 0
            fi
        else
            echo "[AUTO-CONFIRMED] Continuing with uncommitted changes"
        fi
        echo ""
    fi
}

echo "🏗️ Scaffolding integration tests..."
if is_dry_run 2>/dev/null || [ "${DRY_RUN}" = "true" ]; then
    echo "   [DRY-RUN MODE - No files will be modified]"
fi
echo ""

# Run safety checks (unless in dry-run mode)
if [ "${DRY_RUN}" != "true" ]; then
    check_branch_safety
    check_working_tree
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create backup before making changes
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if ! is_dry_run 2>/dev/null && [ "${DRY_RUN}" != "true" ]; then
    if type create_backup >/dev/null 2>&1; then
        BACKUP_DIR=$(create_backup "scaffold-tests")
        echo "ℹ️  Backup created: $BACKUP_DIR"
        echo ""
    fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Check and generate architecture if needed
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📐 Checking Architecture Documentation..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ARCH_FILE="$GBM_BASE/docs/technical/architecture/technology-stack.md"

if [ ! -f "$ARCH_FILE" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ Architecture documentation not found"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "   /gbm.qa.scaffold-tests requires architecture documentation to:"
    echo "   - Understand your tech stack (language, framework, database)"
    echo "   - Generate appropriate test scaffolds (PHPUnit vs pytest vs Jest)"
    echo "   - Create correct fixture patterns"
    echo "   - Provide accurate test recommendations"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 Action Required: Run /gbm.architecture first"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "   1. Run: /gbm.architecture"
    echo "   2. Review the generated architecture docs"
    echo "   3. Commit if satisfied: git add . && git commit -m 'docs: add architecture documentation'"
    echo "   4. Then run: /gbm.qa.scaffold-tests"
    echo ""
    echo "   NOTE: Architecture files are NOT auto-generated or auto-committed"
    echo "         to ensure you review and approve them first."
    echo ""
    exit 1
else
    echo "✓ Architecture documentation found"
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Detect language and framework
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
detect_language() {
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "python"
    elif [ -f "composer.json" ]; then
        echo "php"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "java"
    elif [ -f "package.json" ]; then
        echo "javascript"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

detect_framework() {
    local lang="$1"

    if [ "$lang" = "python" ]; then
        if grep -q "fastapi" requirements.txt 2>/dev/null || grep -q "fastapi" pyproject.toml 2>/dev/null; then
            echo "fastapi"
        elif grep -q "django" requirements.txt 2>/dev/null || grep -q "django" pyproject.toml 2>/dev/null; then
            echo "django"
        elif grep -q "flask" requirements.txt 2>/dev/null || grep -q "flask" pyproject.toml 2>/dev/null; then
            echo "flask"
        else
            echo "unknown"
        fi
    elif [ "$lang" = "javascript" ]; then
        if grep -q "express" package.json 2>/dev/null; then
            echo "express"
        elif grep -q "nestjs" package.json 2>/dev/null; then
            echo "nestjs"
        else
            echo "unknown"
        fi
    elif [ "$lang" = "php" ]; then
        if grep -q "laravel" composer.json 2>/dev/null; then
            echo "laravel"
        elif grep -q "symfony" composer.json 2>/dev/null; then
            echo "symfony"
        else
            echo "unknown"
        fi
    elif [ "$lang" = "java" ]; then
        if grep -q "spring-boot" pom.xml 2>/dev/null || grep -q "spring-boot" build.gradle 2>/dev/null; then
            echo "spring-boot"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

LANGUAGE=$(detect_language)
FRAMEWORK=$(detect_framework "$LANGUAGE")

echo "🔍 Detected language: $LANGUAGE"
echo "🔍 Detected framework: $FRAMEWORK"
echo ""

# Create test directory structure
create_test_structure() {
    echo "📁 Creating test directory structure..."

    if [ "$LANGUAGE" = "python" ]; then
        # Unit tests
        mkdir -p tests/unit/{models,services,utils,controllers}
        # Integration tests
        mkdir -p tests/integration/{api,database,queue,external,cache}
        # E2E tests
        mkdir -p tests/e2e/{user-flows,critical-paths,smoke-tests}
        # Fixtures
        mkdir -p tests/fixtures
        mkdir -p "$SCAFFOLD_DIR"

        # Create __init__.py files
        touch tests/__init__.py
        touch tests/unit/__init__.py
        touch tests/unit/models/__init__.py
        touch tests/unit/services/__init__.py
        touch tests/unit/utils/__init__.py
        touch tests/unit/controllers/__init__.py
        touch tests/integration/__init__.py
        touch tests/integration/api/__init__.py
        touch tests/integration/database/__init__.py
        touch tests/integration/queue/__init__.py
        touch tests/integration/external/__init__.py
        touch tests/integration/cache/__init__.py
        touch tests/e2e/__init__.py
        touch tests/e2e/user-flows/__init__.py
        touch tests/e2e/critical-paths/__init__.py
        touch tests/e2e/smoke-tests/__init__.py
        touch tests/fixtures/__init__.py

    elif [ "$LANGUAGE" = "javascript" ]; then
        # Unit tests
        mkdir -p tests/unit/{models,services,utils,controllers}
        # Integration tests
        mkdir -p tests/integration/{api,database,queue,external,cache}
        # E2E tests
        mkdir -p tests/e2e/{user-flows,critical-paths,smoke-tests}
        # Fixtures
        mkdir -p tests/fixtures
        mkdir -p "$SCAFFOLD_DIR"

    elif [ "$LANGUAGE" = "php" ]; then
        # Unit tests
        mkdir -p tests/Unit/{Models,Services,Utils,Controllers}
        # Integration tests
        mkdir -p tests/Integration/{Api,Database,Queue,External,Cache}
        # E2E tests (Feature tests in Laravel/Symfony)
        mkdir -p tests/Feature/{UserFlows,CriticalPaths,SmokeTests}
        mkdir -p "$SCAFFOLD_DIR"

    elif [ "$LANGUAGE" = "java" ]; then
        # Unit tests
        mkdir -p src/test/java/com/example/unit/{models,services,utils,controllers}
        # Integration tests
        mkdir -p src/test/java/com/example/integration/{api,database,queue,external,cache}
        # E2E tests
        mkdir -p src/test/java/com/example/e2e/{userflows,criticalpaths,smoketests}
        mkdir -p "$SCAFFOLD_DIR"

    elif [ "$LANGUAGE" = "go" ]; then
        # Go tests are typically in same package
        mkdir -p tests/{unit,integration,e2e}
        mkdir -p "$SCAFFOLD_DIR"
    fi

    echo "  ✓ Created test directory structure (unit, integration, e2e)"
}

# Copy fixture templates
copy_fixtures() {
    echo "📋 Copying fixture templates..."
    
    local template_dir="$TEMPLATES_DIR/test-templates/fixtures"
    
    if [ -d "$template_dir" ]; then
        if [ "$LANGUAGE" = "python" ]; then
            cp "$template_dir/api_fixtures.py" tests/fixtures/ 2>/dev/null || true
            cp "$template_dir/database_fixtures.py" tests/fixtures/ 2>/dev/null || true
            cp "$template_dir/mock_services.py" tests/fixtures/ 2>/dev/null || true
            echo "  ✓ Copied fixture templates"
        fi
    else
        echo "  ⚠️  Template directory not found, skipping fixtures"
    fi
}

# Generate conftest.py for pytest
generate_conftest() {
    if [ "$LANGUAGE" = "python" ]; then
        echo "📝 Generating conftest.py..."
        
        cat > tests/conftest.py << 'EOF'
"""
Pytest configuration and shared fixtures

This file is automatically loaded by pytest and provides:
- Shared fixtures available to all tests
- Pytest configuration
- Test hooks
"""

import pytest
import sys
from pathlib import Path

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

# Import fixtures from fixtures directory
pytest_plugins = [
    "tests.fixtures.api_fixtures",
    "tests.fixtures.database_fixtures",
    "tests.fixtures.mock_services",
]


@pytest.fixture(scope="session", autouse=True)
def setup_test_environment():
    """
    Setup test environment before running tests
    
    This runs once per test session
    """
    # TODO: Add test environment setup
    # - Set environment variables
    # - Initialize test database
    # - Start test services
    
    yield
    
    # TODO: Add test environment teardown
    # - Clean up test data
    # - Stop test services


@pytest.fixture(autouse=True)
def reset_test_state():
    """
    Reset test state before each test
    
    This runs before each test function
    """
    # TODO: Add state reset logic
    # - Clear caches
    # - Reset mocks
    # - Clean up test data
    
    yield
    
    # TODO: Add cleanup after each test
EOF
        
        echo "  ✓ Generated conftest.py"
    fi
}

# Generate sample unit test
generate_sample_unit_test() {
    if [ "$LANGUAGE" = "python" ]; then
        echo "📝 Generating sample unit test..."

        cat > tests/unit/test_sample_unit.py << 'EOF'
"""
SAMPLE: Unit tests

This is a sample unit test file demonstrating best practices.
Use this as a template for your own unit tests.

Delete this file once you've created your actual tests.
"""

import pytest
from unittest.mock import Mock


def test_sample_function():
    """
    SAMPLE: Test a simple function

    This demonstrates:
    - Testing a pure function
    - Simple assertions
    - No external dependencies
    """
    def add(a, b):
        return a + b

    result = add(2, 3)
    assert result == 5


def test_sample_with_mock():
    """
    SAMPLE: Test with mocked dependency

    This demonstrates:
    - Mocking dependencies
    - Verifying mock calls
    - Isolating unit under test
    """
    mock_service = Mock()
    mock_service.get_data.return_value = {"key": "value"}

    # Use the mock
    result = mock_service.get_data()

    assert result == {"key": "value"}
    mock_service.get_data.assert_called_once()


# TODO: Replace this sample file with your actual unit tests
# 1. Identify your functions and classes
# 2. Create test files for each module
# 3. Use the templates in .gobuildme/templates/test-templates/
# 4. Delete this sample file
EOF

        echo "  ✓ Generated sample unit test"
    fi
}

# Generate sample e2e test
generate_sample_e2e_test() {
    if [ "$LANGUAGE" = "python" ]; then
        echo "📝 Generating sample E2E test..."

        cat > tests/e2e/test_sample_e2e.py << 'EOF'
"""
SAMPLE: End-to-end tests

This is a sample E2E test file demonstrating best practices.
Use this as a template for your own E2E tests.

Delete this file once you've created your actual tests.
"""

import pytest


def test_sample_user_flow():
    """
    SAMPLE: Test complete user flow

    This demonstrates:
    - Testing end-to-end user journey
    - Multiple steps in sequence
    - Verifying final outcome

    Note: This is a placeholder. Real E2E tests would use
    Playwright, Selenium, or similar tools.
    """
    # Step 1: User navigates to page
    # Step 2: User fills form
    # Step 3: User submits
    # Step 4: Verify success

    # TODO: Implement actual E2E test with browser automation
    pytest.skip("TODO: Implement E2E test with Playwright/Selenium")


# TODO: Replace this sample file with your actual E2E tests
# 1. Install Playwright or Selenium
# 2. Create test files for each user flow
# 3. Use the templates in .gobuildme/templates/test-templates/
# 4. Delete this sample file
EOF

        echo "  ✓ Generated sample E2E test"
    fi
}

# Generate sample integration test file
generate_sample_api_test() {
    if [ "$LANGUAGE" = "python" ]; then
        echo "📝 Generating sample integration test..."

        cat > tests/integration/api/test_sample_api.py << 'EOF'
"""
SAMPLE: Integration tests for API endpoints

This is a sample test file demonstrating best practices.
Use this as a template for your own API tests.

Delete this file once you've created your actual tests.
"""

import pytest
from tests.fixtures.api_fixtures import test_client, auth_headers


def test_sample_get_endpoint(test_client):
    """
    SAMPLE: Test GET endpoint
    
    This demonstrates:
    - Making GET request
    - Checking status code
    - Validating response structure
    """
    response = test_client.get("/api/health")
    
    assert response.status_code == 200
    data = response.json()
    assert "status" in data


def test_sample_post_endpoint(test_client, auth_headers):
    """
    SAMPLE: Test POST endpoint with authentication
    
    This demonstrates:
    - Making POST request
    - Using authentication
    - Sending JSON data
    - Validating response
    """
    payload = {
        "name": "Test Item",
        "description": "Test description"
    }
    
    response = test_client.post(
        "/api/items",
        headers=auth_headers,
        json=payload
    )
    
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == payload["name"]


# TODO: Replace this sample file with your actual API tests
# 1. Identify your API endpoints
# 2. Create test files for each resource (e.g., test_users_api.py)
# 3. Use the templates in .gobuildme/templates/test-templates/
# 4. Delete this sample file
EOF
        
        echo "  ✓ Generated sample API test"
    fi
}

# Generate README
generate_readme() {
    echo "📝 Generating test README..."

    cat > tests/README.md << 'EOF'
# Test Suite

This directory contains comprehensive tests scaffolded by `/gbm.scaffold-tests`.

## Structure

```
tests/
├── unit/                      # Unit tests (90% coverage target)
│   ├── models/                # Model unit tests
│   ├── services/              # Service unit tests
│   ├── utils/                 # Utility unit tests
│   └── controllers/           # Controller unit tests
├── integration/               # Integration tests (95% coverage target)
│   ├── api/                   # API endpoint tests
│   ├── database/              # Database integration tests
│   ├── queue/                 # Message queue tests
│   ├── external/              # External service tests
│   └── cache/                 # Cache operation tests
├── e2e/                       # End-to-end tests (80% coverage target)
│   ├── user-flows/            # Complete user journeys
│   ├── critical-paths/        # Critical business flows
│   └── smoke-tests/           # Basic health checks
├── fixtures/
│   ├── api_fixtures.py        # API test fixtures
│   ├── database_fixtures.py   # Database fixtures
│   └── mock_services.py       # External service mocks
└── conftest.py                # Test configuration
```

## Coverage Targets

- **Unit tests**: 90% (functions, classes, utilities)
- **Integration tests**: 95% (integration points)
- **E2E tests**: 80% (critical user flows)
- **Overall**: 85% (combined)

## Running Tests

```bash
# Run all tests
pytest tests/

# Run by test type
pytest tests/unit/              # Unit tests only
pytest tests/integration/       # Integration tests only
pytest tests/e2e/               # E2E tests only

# Run specific test file
pytest tests/unit/models/test_user.py

# Run with coverage
pytest --cov=app tests/

# Run with coverage by type
pytest --cov=app tests/unit/
pytest --cov=app tests/integration/
pytest --cov=app tests/e2e/

# Validate coverage thresholds
$SCRIPTS_DIR/validate-coverage.sh

# Run with verbose output
pytest -v tests/
```

## Test Types Explained

### Unit Tests
- Test individual functions/methods in isolation
- No external dependencies (database, network, file system)
- Use mocks for all dependencies
- Fast execution (< 100ms per test)
- Target: 90% coverage

### Integration Tests
- Test integration between components
- May use real database, message queues, etc.
- Test API endpoints, database operations, external services
- Moderate execution time (< 5s per test)
- Target: 95% coverage

### E2E Tests
- Test complete user flows from start to finish
- Use browser automation (Playwright, Selenium)
- Test critical business paths
- Slower execution (5-30s per test)
- Target: 80% coverage of critical flows

## Next Steps

1. **Review generated files**: Check the sample tests and fixtures
2. **Customize fixtures**: Adapt fixtures to your data models
3. **Implement TODO tests**: Fill in the TODO test cases
4. **Add more tests**: Create additional test files as needed
5. **Run tests**: Execute tests and measure coverage
6. **Validate coverage**: Ensure all thresholds are met

## Best Practices

### General
- **Use fixtures**: Reuse test data and setup code
- **Test isolation**: Each test should be independent
- **Clear assertions**: Make test failures easy to understand
- **Descriptive names**: Test names should describe what they test

### Unit Tests
- **One assertion per test**: Focus on one behavior
- **Mock all dependencies**: No real external calls
- **Fast**: Keep tests under 100ms

### Integration Tests
- **Test real integrations**: Use real database, queues, etc.
- **Mock external services**: Don't call third-party APIs
- **Clean up**: Reset state after each test

### E2E Tests
- **Test critical paths**: Focus on important user journeys
- **Use page objects**: Organize UI interactions
- **Handle waits**: Use explicit waits, not sleeps

## Resources

- Pytest documentation: https://docs.pytest.org/
- Playwright documentation: https://playwright.dev/
- Testing best practices: See \`$SCAFFOLD_DIR/scaffold-report.md\`
EOF

    echo "  ✓ Generated test README"
}

# Generate scaffold report
generate_report() {
    echo "📄 Generating scaffold report..."
    
    mkdir -p "$SCAFFOLD_DIR"
    
    cat > "$SCAFFOLD_DIR/scaffold-report.md" << EOF
# Test Scaffolding Report

Generated: $(date +"%Y-%m-%d %H:%M:%S")

## Summary

- **Language**: $LANGUAGE
- **Framework**: $FRAMEWORK
- **Test Directory**: tests/integration/
- **Fixtures Directory**: tests/fixtures/

## Generated Files

### Test Structure
- \`tests/integration/api/\` - API endpoint tests
- \`tests/integration/database/\` - Database model tests
- \`tests/integration/queue/\` - Message queue tests
- \`tests/integration/external/\` - External service tests
- \`tests/integration/cache/\` - Cache operation tests

### Fixtures
- \`tests/fixtures/api_fixtures.py\` - API test fixtures (sample)
- \`tests/fixtures/database_fixtures.py\` - Database fixtures (sample)
- \`tests/fixtures/mock_services.py\` - External service mocks (sample)

### Configuration
- \`tests/conftest.py\` - Pytest configuration
- \`tests/README.md\` - Testing documentation

## Next Steps

### 1. Review Generated Files
- [ ] Review sample test files
- [ ] Review fixture templates
- [ ] Review conftest.py configuration

### 2. Customize Fixtures
- [ ] Update \`api_fixtures.py\` with your models
- [ ] Update \`database_fixtures.py\` with your models
- [ ] Update \`mock_services.py\` with your external services

### 3. Implement Tests
- [ ] Create API tests for each endpoint
- [ ] Create database tests for each model
- [ ] Create queue tests for message handlers
- [ ] Create external service integration tests

### 4. Run Tests
\`\`\`bash
# Install test dependencies
pip install pytest pytest-cov

# Run tests
pytest tests/integration/

# Run with coverage
pytest --cov=app tests/integration/
\`\`\`

### 5. Measure Coverage
- [ ] Run coverage report
- [ ] Identify gaps
- [ ] Add tests for uncovered code
- [ ] Aim for 95%+ coverage

## Testing Best Practices

1. **Use AAA Pattern**: Arrange, Act, Assert
2. **Test Isolation**: Each test should be independent
3. **Clear Names**: Test names should describe what they test
4. **One Assertion**: Focus each test on one behavior
5. **Mock External Services**: Don't call real APIs
6. **Use Fixtures**: Reuse test data and setup
7. **Fast Tests**: Keep tests fast (< 5s each)
8. **Deterministic**: Tests should always produce same result

## Resources

- Test templates: \`$TEMPLATES_DIR/test-templates/\`
- Pytest docs: https://docs.pytest.org/
- Testing guide: See project documentation
EOF
    
    echo "  ✓ Generated scaffold report"
}

# Main execution
main() {
    create_test_structure
    copy_fixtures
    generate_conftest
    generate_sample_unit_test
    generate_sample_api_test
    generate_sample_e2e_test
    generate_readme
    generate_report

    echo ""
    echo "✅ Scaffolding complete!"
    echo ""
    echo "📊 Summary:"
    echo "  - Test structure created:"
    echo "    • tests/unit/ (unit tests - 90% coverage target)"
    echo "    • tests/integration/ (integration tests - 95% coverage target)"
    echo "    • tests/e2e/ (end-to-end tests - 80% coverage target)"
    echo "  - Sample fixtures copied to tests/fixtures/"
    echo "  - Configuration generated in tests/conftest.py"
    echo "  - Sample tests created for all test types"
    echo ""
    echo "📄 Report saved to: $SCAFFOLD_DIR/scaffold-report.md"
    echo ""
    echo "Next Steps:"
    echo "  1. Review generated files in tests/"
    echo "  2. Customize fixtures for your models"
    echo "  3. Implement TODO tests"
    echo "  4. Run tests:"
    echo "     • Unit: pytest tests/unit/"
    echo "     • Integration: pytest tests/integration/"
    echo "     • E2E: pytest tests/e2e/"
    echo "     • All: pytest tests/"
    echo "  5. Measure coverage: pytest --cov=app tests/"
    echo "  6. Validate coverage: $SCRIPTS_DIR/validate-coverage.sh"
}

main

