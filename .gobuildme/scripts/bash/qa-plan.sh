#!/usr/bin/env bash
# Purpose: Create test implementation plan from scaffolded tests
# Why: Provides systematic approach to test implementation
# How: Scans test files, categorizes, prioritizes, generates plan from template

set -euo pipefail

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Setup
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/qa-common.sh"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Use get_gobuildme_root() for monorepo/workspace support
GBM_ROOT=$(get_gobuildme_root)
GBM_BASE="${GBM_ROOT:-.}/.gobuildme"

SCAFFOLD_DIR="$GBM_BASE/specs/qa-test-scaffolding"
SCAFFOLD_REPORT="$SCAFFOLD_DIR/scaffold-report.md"
PLAN_TEMPLATE="$GBM_BASE/templates/qa-test-plan-template.md"
PLAN_FILE="$SCAFFOLD_DIR/qa-test-plan.md"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_prerequisites() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 QA Test Planning"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Check for scaffold report
    if [ ! -f "$SCAFFOLD_REPORT" ]; then
        echo "❌ Error: Scaffold report not found"
        echo ""
        echo "Expected location: $SCAFFOLD_REPORT"
        echo ""
        echo "Action required: Run /gbm.qa.scaffold-tests first to generate test scaffolding"
        echo ""
        exit 1
    fi

    # Check for plan template
    if [ ! -f "$PLAN_TEMPLATE" ]; then
        echo "❌ Error: Plan template not found"
        echo ""
        echo "Expected location: $PLAN_TEMPLATE"
        echo ""
        echo "Action required: Ensure GoBuildMe is properly installed"
        echo ""
        exit 1
    fi

    echo "✓ Prerequisites check passed"
    echo ""
}

scan_test_files() {
    echo "📊 Scanning test files for TODO tests..."
    echo ""

    # Initialize counters
    local total_tests=0
    local todo_tests=0
    local implemented_tests=0

    # Find all test files from scaffold report
    local test_files=$(grep -o "tests/[^)]*\.\(php\|py\|js\|ts\|java\)" "$SCAFFOLD_REPORT" 2>/dev/null | sort -u || true)

    if [ -z "$test_files" ]; then
        echo "⚠️  Warning: No test files found in scaffold report"
        echo ""
        return 0
    fi

    # Scan each test file
    while IFS= read -r test_file; do
        if [ ! -f "$test_file" ]; then
            continue
        fi

        # Count TODO markers (common patterns across frameworks)
        local file_todos=$(grep -c "TODO\|@skip\|pytest.skip\|markTestSkipped" "$test_file" 2>/dev/null || echo "0")

        # Count total test functions/methods
        local file_total=$(grep -c "function test\|def test_\|it('.*')\|it(\".*\")\|@Test\|public function test" "$test_file" 2>/dev/null || echo "0")

        todo_tests=$((todo_tests + file_todos))
        total_tests=$((total_tests + file_total))
    done <<< "$test_files"

    implemented_tests=$((total_tests - todo_tests))

    # Export for later use
    export TOTAL_TESTS=$total_tests
    export TODO_TESTS=$todo_tests
    export IMPLEMENTED_TESTS=$implemented_tests

    echo "   Total tests scaffolded: $total_tests"
    echo "   TODO tests to implement: $todo_tests"
    echo "   Tests already implemented: $implemented_tests"
    echo ""
}

categorize_tests() {
    echo "📈 Categorizing tests by type and priority..."
    echo ""

    # Initialize category counters
    export UNIT_TESTS=0
    export INTEGRATION_API_TESTS=0
    export INTEGRATION_DB_TESTS=0
    export INTEGRATION_QUEUE_TESTS=0
    export INTEGRATION_EXTERNAL_TESTS=0
    export INTEGRATION_CACHE_TESTS=0
    export E2E_USER_FLOW_TESTS=0
    export E2E_CRITICAL_PATH_TESTS=0
    export E2E_SMOKE_TESTS=0

    export HIGH_PRIORITY_TESTS=0
    export MEDIUM_PRIORITY_TESTS=0
    export LOW_PRIORITY_TESTS=0

    # Parse scaffold report for test categories
    if grep -q "Unit Tests" "$SCAFFOLD_REPORT"; then
        UNIT_TESTS=$(grep -A 5 "Unit Tests" "$SCAFFOLD_REPORT" | grep -o "[0-9]\+ tests" | head -1 | grep -o "[0-9]\+" || echo "0")
    fi

    if grep -q "Integration Tests - API" "$SCAFFOLD_REPORT"; then
        INTEGRATION_API_TESTS=$(grep -A 5 "Integration Tests - API" "$SCAFFOLD_REPORT" | grep -o "[0-9]\+ tests" | head -1 | grep -o "[0-9]\+" || echo "0")
    fi

    if grep -q "Integration Tests - Database" "$SCAFFOLD_REPORT"; then
        INTEGRATION_DB_TESTS=$(grep -A 5 "Integration Tests - Database" "$SCAFFOLD_REPORT" | grep -o "[0-9]\+ tests" | head -1 | grep -o "[0-9]\+" || echo "0")
    fi

    if grep -q "E2E Tests" "$SCAFFOLD_REPORT"; then
        E2E_USER_FLOW_TESTS=$(grep -A 5 "E2E Tests" "$SCAFFOLD_REPORT" | grep -o "[0-9]\+ tests" | head -1 | grep -o "[0-9]\+" || echo "0")
    fi

    # Assign priorities (heuristic based on test type)
    # High priority: API, Auth, Security
    HIGH_PRIORITY_TESTS=$((INTEGRATION_API_TESTS))

    # Medium priority: Database, CRUD
    MEDIUM_PRIORITY_TESTS=$((INTEGRATION_DB_TESTS + UNIT_TESTS))

    # Low priority: E2E, Edge cases
    LOW_PRIORITY_TESTS=$((E2E_USER_FLOW_TESTS))

    echo "   High priority: $HIGH_PRIORITY_TESTS tests"
    echo "   Medium priority: $MEDIUM_PRIORITY_TESTS tests"
    echo "   Low priority: $LOW_PRIORITY_TESTS tests"
    echo ""
}

detect_tech_stack() {
    echo "🔍 Detecting technology stack..."
    echo ""

    # Detect language and framework
    if [ -f "composer.json" ]; then
        export LANGUAGE="PHP"
        export TESTING_FRAMEWORK="PHPUnit"
        export MOCKING_LIBRARY="Mockery"
        export FIXTURES_STRATEGY="Database factories"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        export LANGUAGE="Python"
        export TESTING_FRAMEWORK="pytest"
        export MOCKING_LIBRARY="pytest-mock"
        export FIXTURES_STRATEGY="Factory Boy"
    elif [ -f "package.json" ]; then
        export LANGUAGE="JavaScript/TypeScript"
        export TESTING_FRAMEWORK="Jest"
        export MOCKING_LIBRARY="jest.mock"
        export FIXTURES_STRATEGY="fixtures.js"
    else
        export LANGUAGE="Unknown"
        export TESTING_FRAMEWORK="Unknown"
        export MOCKING_LIBRARY="Unknown"
        export FIXTURES_STRATEGY="Unknown"
    fi

    # Detect database
    if [ -f ".env" ] && grep -q "DATABASE_URL" .env; then
        export DATABASE=$(grep "DATABASE_URL" .env | grep -o "postgresql\|mysql\|sqlite" | head -1 || echo "Unknown")
    else
        export DATABASE="Unknown"
    fi

    echo "   Language: $LANGUAGE"
    echo "   Testing framework: $TESTING_FRAMEWORK"
    echo "   Database: $DATABASE"
    echo ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Coverage Gap Analysis (CRITICAL for #32)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Test directories to search
TEST_DIRS=("tests" "test" "spec" "__tests__")

find_test_in_dirs() {
    local pattern="$1"
    for dir in "${TEST_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            if find "$dir" -name "$pattern" 2>/dev/null | grep -q .; then
                return 0
            fi
        fi
    done
    return 1
}

analyze_coverage_baseline() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 Analyzing Coverage Baseline (Production Code Without Tests)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Source directories to scan
    local source_dirs=("src" "app" "lib" "pkg" "internal" "cmd")
    local source_files=()
    local untested_files=()

    # Find source files
    for dir in "${source_dirs[@]}"; do
        if [ -d "$dir" ]; then
            local tmp_file=$(mktemp)
            find "$dir" -type f \( \
                -name "*.php" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \
                -o -name "*.go" -o -name "*.java" -o -name "*.rb" \
            \) ! -name "*_test.*" ! -name "test_*" ! -name "*.test.*" ! -name "*Test.*" \
            2>/dev/null > "$tmp_file" || true

            while IFS= read -r file; do
                [ -n "$file" ] && source_files+=("$file")
            done < "$tmp_file"
            rm -f "$tmp_file"
        fi
    done

    local total_source=${#source_files[@]}
    echo "   Found $total_source source files to analyze"
    echo "   Checking test directories: ${TEST_DIRS[*]}"
    echo ""

    if [ $total_source -eq 0 ]; then
        echo "   No source files found in common directories (src/, app/, lib/, etc.)"
        export COVERAGE_BASELINE=100
        export UNTESTED_COUNT=0
        export COVERAGE_GAP_HIGH=0
        export COVERAGE_GAP_MEDIUM=0
        export COVERAGE_GAP_LOW=0
        return
    fi

    # Count files without tests
    local untested_count=0
    local high_priority=0
    local medium_priority=0
    local low_priority=0

    for source_file in "${source_files[@]}"; do
        [ ! -f "$source_file" ] && continue

        local base_name=$(basename "$source_file")
        local name_no_ext="${base_name%.*}"
        local ext="${base_name##*.}"
        local has_test=false

        case "$ext" in
            php)
                find_test_in_dirs "${name_no_ext}Test.php" && has_test=true
                ;;
            py)
                find_test_in_dirs "test_${name_no_ext}.py" && has_test=true
                ;;
            js|ts)
                (find_test_in_dirs "${name_no_ext}.test.*" || find_test_in_dirs "${name_no_ext}.spec.*") && has_test=true
                ;;
            go)
                local dir_name=$(dirname "$source_file")
                [ -f "${dir_name}/${name_no_ext}_test.go" ] && has_test=true
                ;;
            java)
                find . -path "*/test/*" -name "${name_no_ext}Test.java" 2>/dev/null | grep -q . && has_test=true
                ;;
        esac

        if [ "$has_test" = false ]; then
            untested_files+=("$source_file")
            untested_count=$((untested_count + 1))

            # Categorize by priority
            if [[ "$source_file" == *"/auth/"* ]] || [[ "$source_file" == *"/security/"* ]] || \
               [[ "$source_file" == *"/payment/"* ]] || [[ "$source_file" == *"Controller"* ]] || \
               [[ "$source_file" == *"Service"* ]]; then
                high_priority=$((high_priority + 1))
            elif [[ "$source_file" == *"/api/"* ]] || [[ "$source_file" == *"/model/"* ]] || \
                 [[ "$source_file" == *"/repository/"* ]]; then
                medium_priority=$((medium_priority + 1))
            else
                low_priority=$((low_priority + 1))
            fi
        fi
    done

    # Calculate baseline coverage percentage
    local tested_count=$((total_source - untested_count))
    local coverage_pct=0
    if [ $total_source -gt 0 ]; then
        coverage_pct=$((tested_count * 100 / total_source))
    fi

    # Export for use in plan generation
    export COVERAGE_BASELINE=$coverage_pct
    export UNTESTED_COUNT=$untested_count
    export TOTAL_SOURCE_FILES=$total_source
    export COVERAGE_GAP_HIGH=$high_priority
    export COVERAGE_GAP_MEDIUM=$medium_priority
    export COVERAGE_GAP_LOW=$low_priority

    echo "   Coverage Baseline Results:"
    echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   Total source files: $total_source"
    echo "   Files with tests: $tested_count"
    echo "   Files without tests: $untested_count"
    echo "   Current test coverage: ${coverage_pct}%"
    echo ""
    echo "   Coverage Gaps by Priority:"
    echo "   - High priority (auth, security, controllers, services): $high_priority"
    echo "   - Medium priority (api, models, repositories): $medium_priority"
    echo "   - Low priority (other): $low_priority"
    echo ""

    if [ $untested_count -gt 0 ] && [ $untested_count -le 10 ]; then
        echo "   Untested files:"
        for file in "${untested_files[@]}"; do
            echo "   - $file"
        done
        echo ""
    elif [ $untested_count -gt 10 ]; then
        echo "   Top 10 untested files:"
        local count=0
        for file in "${untested_files[@]}"; do
            [ $count -ge 10 ] && break
            echo "   - $file"
            count=$((count + 1))
        done
        echo "   ... and $((untested_count - 10)) more"
        echo ""
    fi
}

generate_plan() {
    echo "📝 Generating test implementation plan..."
    echo ""

    # Create scaffold directory if it doesn't exist
    mkdir -p "$SCAFFOLD_DIR"

    # Copy template
    cp "$PLAN_TEMPLATE" "$PLAN_FILE"

    # Get current date
    local current_date=$(date +%Y-%m-%d)

    # Replace placeholders in plan
    sed -i.bak "s/\[DATE\]/$current_date/g" "$PLAN_FILE"
    sed -i.bak "s/\[PROJECT\/FEATURE\]/Project-wide Test Implementation/g" "$PLAN_FILE"
    sed -i.bak "s/\[Scope\: Project-wide | Feature-specific\]/Scope: Project-wide/g" "$PLAN_FILE"

    # Fill in test counts
    sed -i.bak "s/\[NUMBER\]/$TOTAL_TESTS/g" "$PLAN_FILE"
    sed -i.bak "s/TODO Tests to Implement\]: \[NUMBER\]/TODO Tests to Implement]: $TODO_TESTS/g" "$PLAN_FILE"
    sed -i.bak "s/Tests Already Implemented\]: \[NUMBER\]/Tests Already Implemented]: $IMPLEMENTED_TESTS/g" "$PLAN_FILE"

    # Fill in technology stack
    sed -i.bak "s/Language\/Version\]: \[e\.g\., Python 3\.11, PHP 8\.2, JavaScript ES2022\]/Language\/Version]: $LANGUAGE/g" "$PLAN_FILE"
    sed -i.bak "s/Testing Framework\]: \[e\.g\., pytest, PHPUnit, Jest\]/Testing Framework]: $TESTING_FRAMEWORK/g" "$PLAN_FILE"
    sed -i.bak "s/Mocking Strategy\]: \[e\.g\., unittest\.mock, Mockery, jest\.mock\]/Mocking Strategy]: $MOCKING_LIBRARY/g" "$PLAN_FILE"
    sed -i.bak "s/Fixtures Strategy\]: \[e\.g\., Factory Boy, Faker, fixtures\.js\]/Fixtures Strategy]: $FIXTURES_STRATEGY/g" "$PLAN_FILE"
    sed -i.bak "s/Database\]: \[e\.g\., PostgreSQL 15, MySQL 8\.0, MongoDB 6\.0\]/Database]: $DATABASE/g" "$PLAN_FILE"

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # CRITICAL: Persist coverage baseline to the artifact (#32)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    # Insert Coverage Baseline Analysis section after Test Coverage Summary
    local coverage_section="
## Coverage Baseline Analysis (Production Code)

**Analysis Date**: $current_date
**Source Directories Scanned**: src/, app/, lib/, pkg/, internal/, cmd/
**Test Directories Checked**: ${TEST_DIRS[*]}

### Production Code Coverage Baseline

| Metric | Value |
|--------|-------|
| Total Source Files | ${TOTAL_SOURCE_FILES:-0} |
| Files With Tests | $((${TOTAL_SOURCE_FILES:-0} - ${UNTESTED_COUNT:-0})) |
| Files Without Tests | ${UNTESTED_COUNT:-0} |
| **Coverage Baseline** | **${COVERAGE_BASELINE:-0}%** |

### Coverage Gaps by Priority

| Priority | Count | Description |
|----------|-------|-------------|
| **High** | ${COVERAGE_GAP_HIGH:-0} | Auth, security, controllers, services |
| **Medium** | ${COVERAGE_GAP_MEDIUM:-0} | API, models, repositories |
| **Low** | ${COVERAGE_GAP_LOW:-0} | Other utility code |
| **Total Gaps** | ${UNTESTED_COUNT:-0} | Production files without corresponding tests |

> **Note**: Coverage gaps are production code files that don't have corresponding test files.
> Run \`/gbm.qa.tasks\` to generate actionable tasks for each gap.

"
    # Find the line number after "Test Coverage Summary" section's table
    local insert_after_line=$(grep -n "### Test Files Analysis" "$PLAN_FILE" | head -1 | cut -d: -f1)

    if [ -n "$insert_after_line" ]; then
        # Insert coverage baseline section before "### Test Files Analysis"
        {
            head -n $((insert_after_line - 1)) "$PLAN_FILE"
            echo "$coverage_section"
            tail -n +$insert_after_line "$PLAN_FILE"
        } > "${PLAN_FILE}.tmp"
        mv "${PLAN_FILE}.tmp" "$PLAN_FILE"
    else
        # Fallback: append to end of file if marker not found
        echo "$coverage_section" >> "$PLAN_FILE"
    fi

    # Update Quality Metrics section with actual baseline values
    sed -i.bak "s/Overall coverage: 0% (target: 85%)/Overall coverage: ${COVERAGE_BASELINE:-0}% (target: 85%)/g" "$PLAN_FILE"

    # Clean up backup files
    rm -f "$PLAN_FILE.bak"

    echo "   ✓ Plan generated: $PLAN_FILE"
    echo "   ✓ Coverage baseline persisted to artifact"
    echo ""
}

display_summary() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ QA Test Implementation Plan Created"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📊 Test Coverage Summary"
    echo "   Total tests scaffolded: $TOTAL_TESTS"
    echo "   TODO tests to implement: $TODO_TESTS"
    echo "   Tests already implemented: $IMPLEMENTED_TESTS"
    echo ""
    echo "📈 Coverage Baseline (Production Code Analysis)"
    echo "   Total source files: ${TOTAL_SOURCE_FILES:-0}"
    echo "   Files with tests: $((${TOTAL_SOURCE_FILES:-0} - ${UNTESTED_COUNT:-0}))"
    echo "   Files without tests: ${UNTESTED_COUNT:-0}"
    echo "   Current coverage baseline: ${COVERAGE_BASELINE:-0}%"
    echo ""
    echo "   Coverage gaps by priority:"
    echo "   - High priority: ${COVERAGE_GAP_HIGH:-0} files (auth, security, controllers, services)"
    echo "   - Medium priority: ${COVERAGE_GAP_MEDIUM:-0} files (api, models, repositories)"
    echo "   - Low priority: ${COVERAGE_GAP_LOW:-0} files (other)"
    echo ""
    echo "📈 Breakdown by Priority (Scaffolded Tests)"
    echo "   High priority: $HIGH_PRIORITY_TESTS tests (auth, security, critical paths)"
    echo "   Medium priority: $MEDIUM_PRIORITY_TESTS tests (CRUD, validation, business logic)"
    echo "   Low priority: $LOW_PRIORITY_TESTS tests (edge cases, non-critical)"
    echo ""
    echo "📁 Plan Location"
    echo "   $PLAN_FILE"
    echo ""
    echo "🎯 Next Steps"
    echo "   1. Review the plan: $PLAN_FILE"
    echo "   2. Generate task checklist: /gbm.qa.tasks"
    echo "   3. Optionally generate fixtures: /gbm.qa.generate-fixtures (recommended)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Main
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

main() {
    # 1. Architecture integration
    check_and_generate_architecture || exit 1

    # 2. Check prerequisites
    check_prerequisites

    # 3. Scan test files
    scan_test_files

    # 4. Categorize tests
    categorize_tests

    # 5. Detect tech stack
    detect_tech_stack

    # 6. CRITICAL: Analyze coverage baseline (production code without tests)
    # This addresses #32 - comprehensive coverage planning, not just TODO markers
    analyze_coverage_baseline

    # 7. Generate plan
    generate_plan

    # 8. Display summary
    display_summary
}

# Run main function
main "$@"
