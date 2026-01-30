#!/usr/bin/env bash
# Purpose: Generate task checklist from test implementation plan
# Why: Breaks down plan into actionable tasks with checkboxes
# How: Scans test files for TODO tests, creates task for each with checkbox

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
PLAN_FILE="$SCAFFOLD_DIR/qa-test-plan.md"
TASKS_TEMPLATE="$GBM_BASE/templates/qa-test-tasks-template.md"
TASKS_FILE="$SCAFFOLD_DIR/qa-test-tasks.md"

# Global variables (declared here for bash 3.2 compatibility)
TEST_FILES=()           # Array of test file paths
NUM_TEST_FILES=0        # Count of test files
TOTAL_TASKS=0
HIGH_PRIORITY_TASKS=0
MEDIUM_PRIORITY_TASKS=0
LOW_PRIORITY_TASKS=0

# TODO test tracking (parallel arrays)
TODO_TEST_FILES=()      # File paths with TODO tests
TODO_TEST_LINES=()      # Line numbers
TODO_TEST_NAMES=()      # Test function names
TODO_TEST_PRIORITIES=() # Priority level (high, medium, low)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_prerequisites() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 QA Test Task Generation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Check for plan file
    if [ ! -f "$PLAN_FILE" ]; then
        echo "❌ Error: Test implementation plan not found"
        echo ""
        echo "Expected location: $PLAN_FILE"
        echo ""
        echo "Action required: Run /gbm.qa.plan first to create test implementation plan"
        echo ""
        exit 1
    fi

    # Check for tasks template
    if [ ! -f "$TASKS_TEMPLATE" ]; then
        echo "❌ Error: Tasks template not found"
        echo ""
        echo "Expected location: $TASKS_TEMPLATE"
        echo ""
        echo "Action required: Ensure GoBuildMe is properly installed"
        echo ""
        exit 1
    fi

    echo "✓ Prerequisites check passed"
    echo ""
}

extract_test_files() {
    echo "📂 Extracting test files from plan..."
    echo ""

    # Find test directories (common patterns)
    local test_dirs=("tests" "test" "spec" "__tests__")
    local test_files=()

    for dir in "${test_dirs[@]}"; do
        if [ -d "$dir" ]; then
            # Find test files (PHP, Python, JavaScript, Java)
            local test_tmp=$(mktemp)
            find "$dir" -type f \( -name "*Test.php" -o -name "test_*.py" -o -name "*.test.js" -o -name "*.test.ts" -o -name "*Test.java" \) 2>/dev/null > "$test_tmp" || true
            while IFS= read -r file; do
                test_files+=("$file")
            done < "$test_tmp"
            rm -f "$test_tmp"
        fi
    done

    # Store in global array (handle empty array safely)
    if [ ${#test_files[@]} -gt 0 ]; then
        TEST_FILES=("${test_files[@]}")
    else
        TEST_FILES=()
    fi
    NUM_TEST_FILES=${#test_files[@]}

    echo "   Found $NUM_TEST_FILES test files"
    echo ""
}

parse_todo_tests() {
    echo "🔍 Parsing TODO tests from test files..."
    echo ""

    # Global variables already declared at top for bash 3.2 compatibility
    # (TOTAL_TASKS, HIGH_PRIORITY_TASKS, MEDIUM_PRIORITY_TASKS, LOW_PRIORITY_TASKS)
    # (TODO_TEST_FILES, TODO_TEST_LINES, TODO_TEST_NAMES, TODO_TEST_PRIORITIES)

    # Scan each test file for TODO tests (handle empty array safely)
    if [ ${#TEST_FILES[@]} -eq 0 ]; then
        echo "   No test files found to parse"
        echo ""
        return
    fi

    for test_file in "${TEST_FILES[@]}"; do
        if [ ! -f "$test_file" ]; then
            continue
        fi

        # Determine priority based on file path (used for all matches in this file)
        local priority="low"
        if [[ "$test_file" == *"/api/"* ]] || [[ "$test_file" == *"/auth/"* ]] || [[ "$test_file" == *"/security/"* ]]; then
            priority="high"
        elif [[ "$test_file" == *"/integration/"* ]] || [[ "$test_file" == *"/database/"* ]]; then
            priority="medium"
        fi

        # PHP: public function testSomething() with TODO comment
        if [[ "$test_file" == *.php ]]; then
            while IFS=: read -r line_num rest; do
                [ -z "$line_num" ] && continue
                # Check if previous lines have TODO
                if sed -n "$((line_num-5)),$((line_num-1))p" "$test_file" 2>/dev/null | grep -q "TODO"; then
                    local test_name=$(echo "$rest" | grep -o "test[A-Za-z_]*" || echo "unnamed_test")
                    TODO_TEST_FILES+=("$test_file")
                    TODO_TEST_LINES+=("$line_num")
                    TODO_TEST_NAMES+=("$test_name")
                    TODO_TEST_PRIORITIES+=("$priority")
                    TOTAL_TASKS=$((TOTAL_TASKS + 1))
                    case "$priority" in
                        high) HIGH_PRIORITY_TASKS=$((HIGH_PRIORITY_TASKS + 1)) ;;
                        medium) MEDIUM_PRIORITY_TASKS=$((MEDIUM_PRIORITY_TASKS + 1)) ;;
                        *) LOW_PRIORITY_TASKS=$((LOW_PRIORITY_TASKS + 1)) ;;
                    esac
                fi
            done < <(grep -n "public function test" "$test_file" 2>/dev/null || true)
        fi

        # Python: def test_something() with pytest.skip or TODO
        if [[ "$test_file" == *.py ]]; then
            while IFS=: read -r line_num rest; do
                [ -z "$line_num" ] && continue
                # Check if function has pytest.skip or TODO
                if sed -n "${line_num},$((line_num+10))p" "$test_file" 2>/dev/null | grep -q "pytest.skip\|TODO"; then
                    local test_name=$(echo "$rest" | grep -o "test_[a-z_]*" || echo "unnamed_test")
                    TODO_TEST_FILES+=("$test_file")
                    TODO_TEST_LINES+=("$line_num")
                    TODO_TEST_NAMES+=("$test_name")
                    TODO_TEST_PRIORITIES+=("$priority")
                    TOTAL_TASKS=$((TOTAL_TASKS + 1))
                    case "$priority" in
                        high) HIGH_PRIORITY_TASKS=$((HIGH_PRIORITY_TASKS + 1)) ;;
                        medium) MEDIUM_PRIORITY_TASKS=$((MEDIUM_PRIORITY_TASKS + 1)) ;;
                        *) LOW_PRIORITY_TASKS=$((LOW_PRIORITY_TASKS + 1)) ;;
                    esac
                fi
            done < <(grep -n "def test_" "$test_file" 2>/dev/null || true)
        fi

        # JavaScript/TypeScript: it('test name') or test('test name') with TODO
        if [[ "$test_file" == *.js ]] || [[ "$test_file" == *.ts ]]; then
            while IFS=: read -r line_num rest; do
                [ -z "$line_num" ] && continue
                # Check if test has TODO or skip
                if sed -n "${line_num},$((line_num+10))p" "$test_file" 2>/dev/null | grep -q "TODO\|skip"; then
                    local test_name=$(echo "$rest" | grep -o "'[^']*'" | head -1 | tr -d "'" || echo "unnamed_test")
                    [ -z "$test_name" ] && test_name="unnamed_test"
                    TODO_TEST_FILES+=("$test_file")
                    TODO_TEST_LINES+=("$line_num")
                    TODO_TEST_NAMES+=("$test_name")
                    TODO_TEST_PRIORITIES+=("$priority")
                    TOTAL_TASKS=$((TOTAL_TASKS + 1))
                    case "$priority" in
                        high) HIGH_PRIORITY_TASKS=$((HIGH_PRIORITY_TASKS + 1)) ;;
                        medium) MEDIUM_PRIORITY_TASKS=$((MEDIUM_PRIORITY_TASKS + 1)) ;;
                        *) LOW_PRIORITY_TASKS=$((LOW_PRIORITY_TASKS + 1)) ;;
                    esac
                fi
            done < <(grep -n "it(\|test(" "$test_file" 2>/dev/null || true)
        fi
    done

    echo "   Total TODO tests found: ${#TODO_TEST_FILES[@]}"
    echo "   High priority: $HIGH_PRIORITY_TASKS"
    echo "   Medium priority: $MEDIUM_PRIORITY_TASKS"
    echo "   Low priority: $LOW_PRIORITY_TASKS"
    echo ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Coverage Gap Analysis (CRITICAL for #31/#32)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Global counters for coverage gaps
COVERAGE_GAP_TASKS=0
UNTESTED_FILES=()
UNTESTED_PRIORITIES=()  # Parallel array: "high", "medium", or "low"

# Test directories to search (supports tests/, test/, spec/, __tests__/)
TEST_DIRS=("tests" "test" "spec" "__tests__")

find_in_test_dirs() {
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

analyze_coverage_gaps() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Analyzing Coverage Gaps (Production Code Without Tests)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Source directories to scan (common patterns)
    local source_dirs=("src" "app" "lib" "pkg" "internal" "cmd")
    local source_files=()

    # Find source files
    for dir in "${source_dirs[@]}"; do
        if [ -d "$dir" ]; then
            local tmp_file=$(mktemp)
            # Find source files (PHP, Python, JavaScript, TypeScript, Go, Java)
            find "$dir" -type f \( \
                -name "*.php" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \
                -o -name "*.go" -o -name "*.java" -o -name "*.rb" \
            \) ! -name "*_test.*" ! -name "test_*" ! -name "*.test.*" ! -name "*Test.*" \
            2>/dev/null > "$tmp_file" || true

            while IFS= read -r file; do
                source_files+=("$file")
            done < "$tmp_file"
            rm -f "$tmp_file"
        fi
    done

    echo "   Found ${#source_files[@]} source files to analyze"
    echo "   Searching test directories: ${TEST_DIRS[*]}"
    echo ""

    if [ ${#source_files[@]} -eq 0 ]; then
        echo "   No source files found in common directories (src/, app/, lib/, etc.)"
        echo ""
        return
    fi

    # Analyze each source file for test coverage
    local untested_count=0
    local high_priority_gap=0
    local medium_priority_gap=0
    local low_priority_gap=0

    for source_file in "${source_files[@]}"; do
        if [ ! -f "$source_file" ]; then
            continue
        fi

        # Generate expected test file name patterns
        local base_name=$(basename "$source_file")
        local name_no_ext="${base_name%.*}"
        local ext="${base_name##*.}"

        # Look for corresponding test file
        local has_test=false

        # Check common test naming patterns across all test directories
        case "$ext" in
            php)
                # PHP: UserController.php -> UserControllerTest.php
                if find_in_test_dirs "${name_no_ext}Test.php"; then
                    has_test=true
                fi
                ;;
            py)
                # Python: user_service.py -> test_user_service.py
                if find_in_test_dirs "test_${name_no_ext}.py"; then
                    has_test=true
                fi
                ;;
            js|ts)
                # JavaScript/TypeScript: UserService.js -> UserService.test.js or UserService.spec.js
                if find_in_test_dirs "${name_no_ext}.test.*" || find_in_test_dirs "${name_no_ext}.spec.*"; then
                    has_test=true
                fi
                ;;
            go)
                # Go: user.go -> user_test.go (usually in same directory)
                local dir_name=$(dirname "$source_file")
                if [ -f "${dir_name}/${name_no_ext}_test.go" ]; then
                    has_test=true
                fi
                ;;
            java)
                # Java: UserService.java -> UserServiceTest.java
                if find . -path "*/test/*" -name "${name_no_ext}Test.java" 2>/dev/null | grep -q .; then
                    has_test=true
                fi
                ;;
        esac

        # If no test found, add to coverage gaps with priority
        if [ "$has_test" = false ]; then
            UNTESTED_FILES+=("$source_file")
            untested_count=$((untested_count + 1))

            # Assign priority based on file content/path
            if [[ "$source_file" == *"/auth/"* ]] || [[ "$source_file" == *"/security/"* ]] || \
               [[ "$source_file" == *"/payment/"* ]] || [[ "$source_file" == *"Controller"* ]] || \
               [[ "$source_file" == *"Service"* ]]; then
                high_priority_gap=$((high_priority_gap + 1))
                UNTESTED_PRIORITIES+=("high")
            elif [[ "$source_file" == *"/api/"* ]] || [[ "$source_file" == *"/model/"* ]] || \
                 [[ "$source_file" == *"/repository/"* ]]; then
                medium_priority_gap=$((medium_priority_gap + 1))
                UNTESTED_PRIORITIES+=("medium")
            else
                low_priority_gap=$((low_priority_gap + 1))
                UNTESTED_PRIORITIES+=("low")
            fi
        fi
    done

    # Update global counters
    COVERAGE_GAP_TASKS=$untested_count
    TOTAL_TASKS=$((TOTAL_TASKS + untested_count))
    HIGH_PRIORITY_TASKS=$((HIGH_PRIORITY_TASKS + high_priority_gap))
    MEDIUM_PRIORITY_TASKS=$((MEDIUM_PRIORITY_TASKS + medium_priority_gap))
    LOW_PRIORITY_TASKS=$((LOW_PRIORITY_TASKS + low_priority_gap))

    echo "   Coverage Gap Analysis Results:"
    echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   Source files without tests: $untested_count"
    echo "   - High priority gaps: $high_priority_gap (auth, security, controllers, services)"
    echo "   - Medium priority gaps: $medium_priority_gap (api, models, repositories)"
    echo "   - Low priority gaps: $low_priority_gap (other files)"
    echo ""

    if [ $untested_count -gt 0 ]; then
        echo "   Top 10 untested files (by priority):"
        local count=0
        for file in "${UNTESTED_FILES[@]}"; do
            if [ $count -ge 10 ]; then
                break
            fi
            echo "   - $file"
            count=$((count + 1))
        done
        if [ ${#UNTESTED_FILES[@]} -gt 10 ]; then
            echo "   ... and $((${#UNTESTED_FILES[@]} - 10)) more"
        fi
        echo ""
    fi
}

generate_tasks_file() {
    echo "📝 Generating task checklist..."
    echo ""

    # Create scaffold directory if it doesn't exist
    mkdir -p "$SCAFFOLD_DIR"

    # Copy template
    cp "$TASKS_TEMPLATE" "$TASKS_FILE"

    # Replace placeholders
    sed -i.bak "s/\[PROJECT\/FEATURE\]/Project-wide Test Implementation/g" "$TASKS_FILE"
    sed -i.bak "s/{TOTAL_TASKS}/$TOTAL_TASKS/g" "$TASKS_FILE"

    # Update progress tracking
    sed -i.bak "s/High-priority tests: {N} tasks/High-priority tests: $HIGH_PRIORITY_TASKS tasks/g" "$TASKS_FILE"
    sed -i.bak "s/Medium-priority tests: {N} tasks/Medium-priority tests: $MEDIUM_PRIORITY_TASKS tasks/g" "$TASKS_FILE"
    sed -i.bak "s/Low-priority tests: {N} tasks/Low-priority tests: $LOW_PRIORITY_TASKS tasks/g" "$TASKS_FILE"

    # Clean up backup files
    rm -f "$TASKS_FILE.bak"

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # CRITICAL: Write TODO/placeholder test tasks (#31/#32)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if [ ${#TODO_TEST_FILES[@]} -gt 0 ]; then
        echo "" >> "$TASKS_FILE"
        echo "---" >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"
        echo "## TODO/Placeholder Test Tasks (Auto-Generated)" >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"
        echo "**Purpose**: Complete implementation of tests marked with TODO, pytest.skip, or similar placeholders." >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"
        echo "**Total TODO Test Tasks**: ${#TODO_TEST_FILES[@]}" >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"

        # Group tasks by priority - IDs start at 1 for TODO tests
        local task_id=1

        # High priority section
        echo "### High Priority TODO Tests (Security, Auth, API)" >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"
        local todo_high_count=0
        for i in "${!TODO_TEST_FILES[@]}"; do
            if [ "${TODO_TEST_PRIORITIES[$i]}" = "high" ]; then
                local file="${TODO_TEST_FILES[$i]}"
                local line="${TODO_TEST_LINES[$i]}"
                local name="${TODO_TEST_NAMES[$i]}"

                echo "- [ ] $task_id [P] Implement test: \`$name\`" >> "$TASKS_FILE"
                echo "  - **Location**: \`$file:$line\`" >> "$TASKS_FILE"
                echo "  - **Must verify before marking [x]**:" >> "$TASKS_FILE"
                echo "    - ✓ TODO/skip marker removed" >> "$TASKS_FILE"
                echo "    - ✓ Test logic fully implemented" >> "$TASKS_FILE"
                echo "    - ✓ Uses AAA pattern (Arrange, Act, Assert)" >> "$TASKS_FILE"
                echo "    - ✓ Test passes" >> "$TASKS_FILE"
                echo "" >> "$TASKS_FILE"

                task_id=$((task_id + 1))
                todo_high_count=$((todo_high_count + 1))
            fi
        done
        if [ $todo_high_count -eq 0 ]; then
            echo "_No high priority TODO tests detected._" >> "$TASKS_FILE"
            echo "" >> "$TASKS_FILE"
        fi

        # Medium priority section
        echo "### Medium Priority TODO Tests (Integration, Database)" >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"
        local todo_medium_count=0
        for i in "${!TODO_TEST_FILES[@]}"; do
            if [ "${TODO_TEST_PRIORITIES[$i]}" = "medium" ]; then
                local file="${TODO_TEST_FILES[$i]}"
                local line="${TODO_TEST_LINES[$i]}"
                local name="${TODO_TEST_NAMES[$i]}"

                echo "- [ ] $task_id [P] Implement test: \`$name\`" >> "$TASKS_FILE"
                echo "  - **Location**: \`$file:$line\`" >> "$TASKS_FILE"
                echo "  - **Must verify before marking [x]**:" >> "$TASKS_FILE"
                echo "    - ✓ TODO/skip marker removed" >> "$TASKS_FILE"
                echo "    - ✓ Test logic fully implemented" >> "$TASKS_FILE"
                echo "    - ✓ Uses AAA pattern (Arrange, Act, Assert)" >> "$TASKS_FILE"
                echo "    - ✓ Test passes" >> "$TASKS_FILE"
                echo "" >> "$TASKS_FILE"

                task_id=$((task_id + 1))
                todo_medium_count=$((todo_medium_count + 1))
            fi
        done
        if [ $todo_medium_count -eq 0 ]; then
            echo "_No medium priority TODO tests detected._" >> "$TASKS_FILE"
            echo "" >> "$TASKS_FILE"
        fi

        # Low priority section
        echo "### Low Priority TODO Tests (Unit, Other)" >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"
        local todo_low_count=0
        for i in "${!TODO_TEST_FILES[@]}"; do
            if [ "${TODO_TEST_PRIORITIES[$i]}" = "low" ]; then
                local file="${TODO_TEST_FILES[$i]}"
                local line="${TODO_TEST_LINES[$i]}"
                local name="${TODO_TEST_NAMES[$i]}"

                echo "- [ ] $task_id [P] Implement test: \`$name\`" >> "$TASKS_FILE"
                echo "  - **Location**: \`$file:$line\`" >> "$TASKS_FILE"
                echo "  - **Must verify before marking [x]**:" >> "$TASKS_FILE"
                echo "    - ✓ TODO/skip marker removed" >> "$TASKS_FILE"
                echo "    - ✓ Test logic fully implemented" >> "$TASKS_FILE"
                echo "    - ✓ Uses AAA pattern (Arrange, Act, Assert)" >> "$TASKS_FILE"
                echo "    - ✓ Test passes" >> "$TASKS_FILE"
                echo "" >> "$TASKS_FILE"

                task_id=$((task_id + 1))
                todo_low_count=$((todo_low_count + 1))
            fi
        done
        if [ $todo_low_count -eq 0 ]; then
            echo "_No low priority TODO tests detected._" >> "$TASKS_FILE"
            echo "" >> "$TASKS_FILE"
        fi
    fi

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # CRITICAL: Write coverage gap tasks to the file (#31/#32)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if [ ${#UNTESTED_FILES[@]} -gt 0 ]; then
        echo "" >> "$TASKS_FILE"
        echo "---" >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"
        echo "## Coverage Gap Tasks (Auto-Generated)" >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"
        echo "**Purpose**: Create tests for production code files that have no corresponding test files." >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"
        echo "**Total Coverage Gap Tasks**: ${#UNTESTED_FILES[@]}" >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"

        # Group tasks by priority
        local task_id=100  # Start coverage gap IDs at 100 to avoid conflicts

        # High priority section
        echo "### High Priority Coverage Gaps (Security, Auth, Controllers, Services)" >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"
        local high_count=0
        for i in "${!UNTESTED_FILES[@]}"; do
            if [ "${UNTESTED_PRIORITIES[$i]}" = "high" ]; then
                local file="${UNTESTED_FILES[$i]}"
                local base_name=$(basename "$file")
                local name_no_ext="${base_name%.*}"
                local ext="${base_name##*.}"
                local test_path=$(suggest_test_path "$file" "$ext")

                echo "- [ ] $task_id [P] Create test file for \`$file\`" >> "$TASKS_FILE"
                echo "  - **Source**: \`$file\`" >> "$TASKS_FILE"
                echo "  - **Create test at**: \`$test_path\`" >> "$TASKS_FILE"
                echo "  - **Must verify before marking [x]**:" >> "$TASKS_FILE"
                echo "    - ✓ Test file created at suggested location" >> "$TASKS_FILE"
                echo "    - ✓ Tests cover primary public methods/functions" >> "$TASKS_FILE"
                echo "    - ✓ Uses AAA pattern (Arrange, Act, Assert)" >> "$TASKS_FILE"
                echo "    - ✓ All tests pass" >> "$TASKS_FILE"
                echo "" >> "$TASKS_FILE"

                task_id=$((task_id + 1))
                high_count=$((high_count + 1))
            fi
        done
        if [ $high_count -eq 0 ]; then
            echo "_No high priority coverage gaps detected._" >> "$TASKS_FILE"
            echo "" >> "$TASKS_FILE"
        fi

        # Medium priority section
        echo "### Medium Priority Coverage Gaps (API, Models, Repositories)" >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"
        local medium_count=0
        for i in "${!UNTESTED_FILES[@]}"; do
            if [ "${UNTESTED_PRIORITIES[$i]}" = "medium" ]; then
                local file="${UNTESTED_FILES[$i]}"
                local base_name=$(basename "$file")
                local name_no_ext="${base_name%.*}"
                local ext="${base_name##*.}"
                local test_path=$(suggest_test_path "$file" "$ext")

                echo "- [ ] $task_id [P] Create test file for \`$file\`" >> "$TASKS_FILE"
                echo "  - **Source**: \`$file\`" >> "$TASKS_FILE"
                echo "  - **Create test at**: \`$test_path\`" >> "$TASKS_FILE"
                echo "  - **Must verify before marking [x]**:" >> "$TASKS_FILE"
                echo "    - ✓ Test file created at suggested location" >> "$TASKS_FILE"
                echo "    - ✓ Tests cover primary public methods/functions" >> "$TASKS_FILE"
                echo "    - ✓ Uses AAA pattern (Arrange, Act, Assert)" >> "$TASKS_FILE"
                echo "    - ✓ All tests pass" >> "$TASKS_FILE"
                echo "" >> "$TASKS_FILE"

                task_id=$((task_id + 1))
                medium_count=$((medium_count + 1))
            fi
        done
        if [ $medium_count -eq 0 ]; then
            echo "_No medium priority coverage gaps detected._" >> "$TASKS_FILE"
            echo "" >> "$TASKS_FILE"
        fi

        # Low priority section
        echo "### Low Priority Coverage Gaps (Other Files)" >> "$TASKS_FILE"
        echo "" >> "$TASKS_FILE"
        local low_count=0
        for i in "${!UNTESTED_FILES[@]}"; do
            if [ "${UNTESTED_PRIORITIES[$i]}" = "low" ]; then
                local file="${UNTESTED_FILES[$i]}"
                local base_name=$(basename "$file")
                local name_no_ext="${base_name%.*}"
                local ext="${base_name##*.}"
                local test_path=$(suggest_test_path "$file" "$ext")

                echo "- [ ] $task_id [P] Create test file for \`$file\`" >> "$TASKS_FILE"
                echo "  - **Source**: \`$file\`" >> "$TASKS_FILE"
                echo "  - **Create test at**: \`$test_path\`" >> "$TASKS_FILE"
                echo "  - **Must verify before marking [x]**:" >> "$TASKS_FILE"
                echo "    - ✓ Test file created at suggested location" >> "$TASKS_FILE"
                echo "    - ✓ Tests cover primary public methods/functions" >> "$TASKS_FILE"
                echo "    - ✓ Uses AAA pattern (Arrange, Act, Assert)" >> "$TASKS_FILE"
                echo "    - ✓ All tests pass" >> "$TASKS_FILE"
                echo "" >> "$TASKS_FILE"

                task_id=$((task_id + 1))
                low_count=$((low_count + 1))
            fi
        done
        if [ $low_count -eq 0 ]; then
            echo "_No low priority coverage gaps detected._" >> "$TASKS_FILE"
            echo "" >> "$TASKS_FILE"
        fi
    fi

    echo "   ✓ Task checklist generated: $TASKS_FILE"
    if [ ${#TODO_TEST_FILES[@]} -gt 0 ]; then
        echo "   ✓ Added ${#TODO_TEST_FILES[@]} TODO/placeholder test tasks with locations"
    fi
    if [ ${#UNTESTED_FILES[@]} -gt 0 ]; then
        echo "   ✓ Added ${#UNTESTED_FILES[@]} coverage gap tasks with file paths and IDs"
    fi
    echo ""
}

# Helper: suggest test file path based on source file
suggest_test_path() {
    local source_file="$1"
    local ext="$2"
    local base_name=$(basename "$source_file")
    local name_no_ext="${base_name%.*}"

    # Determine test directory (prefer first existing one, else default to tests/)
    local test_dir="tests"
    for dir in "${TEST_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            test_dir="$dir"
            break
        fi
    done

    case "$ext" in
        php)
            echo "${test_dir}/Unit/${name_no_ext}Test.php"
            ;;
        py)
            echo "${test_dir}/test_${name_no_ext}.py"
            ;;
        js)
            echo "${test_dir}/${name_no_ext}.test.js"
            ;;
        ts)
            echo "${test_dir}/${name_no_ext}.test.ts"
            ;;
        go)
            # Go tests go in same directory as source
            local dir_name=$(dirname "$source_file")
            echo "${dir_name}/${name_no_ext}_test.go"
            ;;
        java)
            echo "${test_dir}/java/${name_no_ext}Test.java"
            ;;
        rb)
            echo "${test_dir}/${name_no_ext}_spec.rb"
            ;;
        *)
            echo "${test_dir}/${name_no_ext}_test.${ext}"
            ;;
    esac
}

display_summary() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ QA Test Task Checklist Created"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📋 Task Breakdown"
    echo "   Total tasks: $TOTAL_TASKS"
    echo ""
    echo "   By Source:"
    echo "   - TODO/placeholder tests: $((TOTAL_TASKS - COVERAGE_GAP_TASKS)) tasks"
    echo "   - Coverage gap tests (NEW): $COVERAGE_GAP_TASKS tasks"
    echo ""
    echo "   By Phase:"
    echo "   - Phase 1 (Fixtures): Optional (run /gbm.qa.generate-fixtures)"
    echo "   - Phase 2 (High Priority): $HIGH_PRIORITY_TASKS tasks"
    echo "   - Phase 3 (Medium Priority): $MEDIUM_PRIORITY_TASKS tasks"
    echo "   - Phase 4 (Low Priority): $LOW_PRIORITY_TASKS tasks"
    echo "   - Phase 5 (Validation): 3 tasks"
    echo ""
    echo "   By Priority:"
    echo "   - High-priority tests: $HIGH_PRIORITY_TASKS tasks"
    echo "   - Medium-priority tests: $MEDIUM_PRIORITY_TASKS tasks"
    echo "   - Low-priority tests: $LOW_PRIORITY_TASKS tasks"
    echo ""
    if [ $COVERAGE_GAP_TASKS -gt 0 ]; then
        echo "⚠️  Coverage Gap Alert"
        echo "   Found $COVERAGE_GAP_TASKS source files without corresponding tests."
        echo "   These tasks ensure comprehensive coverage beyond existing placeholders."
        echo ""
    fi
    echo "📁 Tasks Location"
    echo "   $TASKS_FILE"
    echo ""
    echo "🎯 Task Format"
    echo "   Each task has:"
    echo "   - Checkbox: [ ] = pending, [x] = complete"
    echo "   - ID: Hierarchical numbering (1, 1-1, 1-2, etc.)"
    echo "   - [P]: Indicates can run in parallel"
    echo "   - Description: Clear test name"
    echo "   - Location: File path and line number"
    echo ""
    echo "🔄 Parallel Execution"
    echo "   Tasks marked [P] can be implemented simultaneously"
    echo "   (different test files, no dependencies)"
    echo ""
    echo "🎯 Next Steps"
    echo "   1. Review task checklist: $TASKS_FILE"
    echo "   2. Optionally generate fixtures: /gbm.qa.generate-fixtures (recommended)"
    echo "   3. Start implementation: /gbm.qa.implement (systematic task-by-task)"
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

    # 3. Extract test files
    extract_test_files

    # 4. Parse TODO tests (existing placeholders)
    parse_todo_tests

    # 5. CRITICAL: Analyze coverage gaps (source files without tests)
    # This addresses #31/#32 - comprehensive testing, not just TODO markers
    analyze_coverage_gaps

    # 6. Generate tasks file
    generate_tasks_file

    # 7. Display summary
    display_summary
}

# Run main function
main "$@"
