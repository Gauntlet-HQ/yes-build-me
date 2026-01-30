#!/usr/bin/env bash
# Purpose: Review test quality, coverage, and best practices
# Why: Ensures tests meet quality standards before final review
# How: Analyzes test structure, coverage, and AC traceability

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/qa-common.sh"

echo "🔍 Reviewing test quality..."
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 1: Check and generate architecture
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_and_generate_architecture

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 1.5: Quality Gate - Check Task Completion (Critical)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# This quality gate enforces that all test implementation tasks are complete
# before allowing the review to proceed. This prevents incomplete test
# implementations from passing through to merge.

TASKS_FILE=".gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md"

if [ -f "$TASKS_FILE" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚧 Quality Gate: Task Completion Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Count unchecked tasks
    INCOMPLETE_COUNT=$(grep -c "^- \[ \] [0-9]" "$TASKS_FILE" 2>/dev/null || echo "0")
    TOTAL_COUNT=$(grep -c "^- \[.\] [0-9]" "$TASKS_FILE" 2>/dev/null || echo "0")
    COMPLETED_COUNT=$(grep -c "^- \[x\] [0-9]" "$TASKS_FILE" 2>/dev/null || echo "0")

    if [ "$INCOMPLETE_COUNT" -gt 0 ]; then
        echo "❌ Quality Gate: Test Implementation Incomplete"
        echo ""
        echo "   Status: $COMPLETED_COUNT/$TOTAL_COUNT tasks complete"
        echo "   Remaining: $INCOMPLETE_COUNT tasks"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🔄 Automatically continuing test implementation..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        # Automatically run qa-implement.sh to finish remaining tasks
        if [ -f "$SCRIPT_DIR/qa-implement.sh" ]; then
            echo "Running /gbm.qa.implement to complete remaining tasks..."
            echo ""

            # Execute qa-implement.sh to finish all remaining tasks
            bash "$SCRIPT_DIR/qa-implement.sh"

            # After implementation, check again
            INCOMPLETE_AFTER=$(grep -c "^- \[ \] [0-9]" "$TASKS_FILE" 2>/dev/null || echo "0")

            if [ "$INCOMPLETE_AFTER" -gt 0 ]; then
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "⚠️  Warning: $INCOMPLETE_AFTER tasks still incomplete"
                echo "   User stopped implementation. Run /gbm.qa.review-tests again to continue."
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                exit 1
            else
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "✅ All tasks completed! Continuing with review..."
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
            fi
        else
            echo "❌ Error: qa-implement.sh not found at $SCRIPT_DIR/qa-implement.sh"
            echo "   Please run /gbm.qa.implement manually to complete remaining tasks"
            echo ""
            exit 1
        fi
    else
        echo "✅ Task completion check passed"
        echo "   All $TOTAL_COUNT tasks completed"
        echo ""
    fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 2: Load context (architecture, persona, config)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

load_architecture_context
load_feature_context
load_persona_config
load_qa_config

LANGUAGE="${ARCH_LANGUAGE:-$(detect_language)}"
TEST_FRAMEWORK=$(detect_test_framework)

print_section "📊 Context Loaded"
echo "Language:        $LANGUAGE"
echo "Test Framework:  $TEST_FRAMEWORK"

# Display persona if configured
if [ -n "${PERSONA_NAME:-}" ]; then
    echo "Persona:         $PERSONA_NAME"
    if [ -n "${PERSONA_COVERAGE_FLOOR:-}" ]; then
        echo "Coverage Floor:  $(awk "BEGIN {printf \"%.0f\", ${PERSONA_COVERAGE_FLOOR} * 100}" 2>/dev/null || echo "85")% (persona)"
    fi
fi

# Display gate mode
echo "Gate Mode:       ${QA_GATE_MODE:-advisory}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 3: Check test structure
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_section "📁 Test Structure Check"

ISSUES=0

# Check if tests directory exists
if [ ! -d "tests" ]; then
    print_error "tests/ directory not found"
    ISSUES=$((ISSUES + 1))
else
    print_success "tests/ directory exists"
    
    # Check for test subdirectories
    if [ -d "tests/unit" ]; then
        print_success "tests/unit/ exists"
    else
        print_warning "tests/unit/ not found"
    fi
    
    if [ -d "tests/integration" ]; then
        print_success "tests/integration/ exists"
    else
        print_warning "tests/integration/ not found"
    fi
    
    if [ -d "tests/e2e" ]; then
        print_success "tests/e2e/ exists"
    else
        print_warning "tests/e2e/ not found (optional)"
    fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 4: Check for remaining TODOs
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_section "📝 TODO Check"

TODO_FILES=$(scan_test_todos "tests")

if [ -z "$TODO_FILES" ]; then
    print_success "No TODO tests found"
else
    TODO_COUNT=$(echo "$TODO_FILES" | wc -l | tr -d ' ')
    print_warning "Found $TODO_COUNT file(s) with TODOs"
    echo "$TODO_FILES" | while read -r file; do
        if [ -n "$file" ]; then
            echo "  • $file"
        fi
    done
    ISSUES=$((ISSUES + 1))
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 5: Run coverage analysis
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_section "📊 Coverage Analysis"

COVERAGE_PASSED=true
COVERAGE_ISSUES=0

# Get coverage thresholds from config (aligned with documentation)
UNIT_THRESHOLD=$(get_coverage_threshold "unit" 2>/dev/null || echo "90")
INTEGRATION_THRESHOLD=$(get_coverage_threshold "integration" 2>/dev/null || echo "95")
E2E_THRESHOLD=$(get_coverage_threshold "e2e" 2>/dev/null || echo "80")
OVERALL_THRESHOLD=$(get_coverage_threshold "overall" 2>/dev/null || echo "85")

echo "Coverage targets (from qa-config.yaml):"
echo "  Unit: ${UNIT_THRESHOLD}% | Integration: ${INTEGRATION_THRESHOLD}% | E2E: ${E2E_THRESHOLD}% | Overall: ${OVERALL_THRESHOLD}%"
echo ""

case "$TEST_FRAMEWORK" in
    pytest)
        if command -v pytest >/dev/null 2>&1; then
            echo "Running pytest with coverage..."

            # Run coverage for each test type
            UNIT_COVERAGE=0
            INTEGRATION_COVERAGE=0
            E2E_COVERAGE=0
            OVERALL_COVERAGE=0

            # Overall coverage first
            if pytest --cov --cov-report=term-missing --cov-report=json -q 2>/dev/null; then
                if [ -f "coverage.json" ]; then
                    OVERALL_COVERAGE=$(python3 -c "import json; data=json.load(open('coverage.json')); print(int(data['totals']['percent_covered']))" 2>/dev/null || echo "0")
                fi
            fi

            # Per-type coverage (if directories exist)
            if [ -d "tests/unit" ]; then
                if pytest tests/unit/ --cov --cov-report=json -q 2>/dev/null; then
                    if [ -f "coverage.json" ]; then
                        UNIT_COVERAGE=$(python3 -c "import json; data=json.load(open('coverage.json')); print(int(data['totals']['percent_covered']))" 2>/dev/null || echo "0")
                    fi
                fi
            else
                UNIT_COVERAGE="N/A"
            fi

            if [ -d "tests/integration" ]; then
                if pytest tests/integration/ --cov --cov-report=json -q 2>/dev/null; then
                    if [ -f "coverage.json" ]; then
                        INTEGRATION_COVERAGE=$(python3 -c "import json; data=json.load(open('coverage.json')); print(int(data['totals']['percent_covered']))" 2>/dev/null || echo "0")
                    fi
                fi
            else
                INTEGRATION_COVERAGE="N/A"
            fi

            if [ -d "tests/e2e" ]; then
                if pytest tests/e2e/ --cov --cov-report=json -q 2>/dev/null; then
                    if [ -f "coverage.json" ]; then
                        E2E_COVERAGE=$(python3 -c "import json; data=json.load(open('coverage.json')); print(int(data['totals']['percent_covered']))" 2>/dev/null || echo "0")
                    fi
                fi
            else
                E2E_COVERAGE="N/A"
            fi

            # Report and validate each threshold
            echo ""
            echo "Coverage Results:"

            # Unit coverage check
            if [ "$UNIT_COVERAGE" != "N/A" ]; then
                if [ "$UNIT_COVERAGE" -ge "$UNIT_THRESHOLD" ]; then
                    print_success "Unit tests: ${UNIT_COVERAGE}% (threshold: ${UNIT_THRESHOLD}%)"
                else
                    print_error "Unit tests: ${UNIT_COVERAGE}% (threshold: ${UNIT_THRESHOLD}%) - BELOW TARGET"
                    COVERAGE_ISSUES=$((COVERAGE_ISSUES + 1))
                fi
            else
                print_info "Unit tests: N/A (no tests/unit directory)"
            fi

            # Integration coverage check
            if [ "$INTEGRATION_COVERAGE" != "N/A" ]; then
                if [ "$INTEGRATION_COVERAGE" -ge "$INTEGRATION_THRESHOLD" ]; then
                    print_success "Integration tests: ${INTEGRATION_COVERAGE}% (threshold: ${INTEGRATION_THRESHOLD}%)"
                else
                    print_error "Integration tests: ${INTEGRATION_COVERAGE}% (threshold: ${INTEGRATION_THRESHOLD}%) - BELOW TARGET"
                    COVERAGE_ISSUES=$((COVERAGE_ISSUES + 1))
                fi
            else
                print_info "Integration tests: N/A (no tests/integration directory)"
            fi

            # E2E coverage check
            if [ "$E2E_COVERAGE" != "N/A" ]; then
                if [ "$E2E_COVERAGE" -ge "$E2E_THRESHOLD" ]; then
                    print_success "E2E tests: ${E2E_COVERAGE}% (threshold: ${E2E_THRESHOLD}%)"
                else
                    print_error "E2E tests: ${E2E_COVERAGE}% (threshold: ${E2E_THRESHOLD}%) - BELOW TARGET"
                    COVERAGE_ISSUES=$((COVERAGE_ISSUES + 1))
                fi
            else
                print_info "E2E tests: N/A (no tests/e2e directory)"
            fi

            # Overall coverage check
            if [ "$OVERALL_COVERAGE" -ge "$OVERALL_THRESHOLD" ]; then
                print_success "Overall: ${OVERALL_COVERAGE}% (threshold: ${OVERALL_THRESHOLD}%)"
            else
                print_error "Overall: ${OVERALL_COVERAGE}% (threshold: ${OVERALL_THRESHOLD}%) - BELOW TARGET"
                COVERAGE_ISSUES=$((COVERAGE_ISSUES + 1))
            fi

            # Fail if any coverage target not met
            if [ $COVERAGE_ISSUES -gt 0 ]; then
                COVERAGE_PASSED=false
                ISSUES=$((ISSUES + COVERAGE_ISSUES))
                echo ""
                print_error "Coverage targets not met: $COVERAGE_ISSUES threshold(s) below target"
            fi
        else
            print_warning "pytest not installed, skipping coverage"
        fi
        ;;
    jest|vitest)
        if command -v npm >/dev/null 2>&1; then
            echo "Running Jest/Vitest with coverage..."
            if npm test -- --coverage --silent 2>/dev/null; then
                print_success "Coverage check passed"
            else
                print_warning "Coverage check failed"
                COVERAGE_PASSED=false
            fi
        else
            print_warning "npm not found, skipping coverage"
        fi
        ;;
    *)
        print_warning "Coverage analysis not implemented for $TEST_FRAMEWORK"
        ;;
esac

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 6: Check AC traceability
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_section "✅ AC Traceability Check"

if [ -n "${FEATURE_ACS:-}" ]; then
    AC_COUNT=$(echo "$FEATURE_ACS" | wc -l | tr -d ' ')
    TESTED_ACS=0

    echo "Checking $AC_COUNT acceptance criteria..."
    echo ""

    # Check for manual overrides
    AC_OVERRIDES_FILE=".gobuildme/specs/qa-test-scaffolding/ac-overrides.yaml"
    MANUAL_REVIEW_ACS=0

    # Use process substitution to avoid subshell (fixes variable scope issue)
    while IFS= read -r ac; do
        if [ -n "$ac" ]; then
            AC_NUM=$(echo "$ac" | grep -o "^[0-9]\+" || echo "")
            if [ -n "$AC_NUM" ]; then
                # Check if AC is marked for manual review
                if [ -f "$AC_OVERRIDES_FILE" ] && grep -q "AC${AC_NUM}" "$AC_OVERRIDES_FILE" 2>/dev/null; then
                    echo "  ℹ️  AC${AC_NUM}: Manual review required"
                    MANUAL_REVIEW_ACS=$((MANUAL_REVIEW_ACS + 1))
                # Search for AC reference in tests
                elif grep -r "AC${AC_NUM}\|AC-${AC_NUM}\|AC ${AC_NUM}" tests/ >/dev/null 2>&1; then
                    echo "  ✓ AC${AC_NUM}: Tested"
                    TESTED_ACS=$((TESTED_ACS + 1))
                else
                    echo "  ✗ AC${AC_NUM}: Not tested"
                fi
            fi
        fi
    done <<EOF
$FEATURE_ACS
EOF

    # Calculate traceability percentage
    if [ "$AC_COUNT" -gt 0 ]; then
        TESTABLE_AC_COUNT=$((AC_COUNT - MANUAL_REVIEW_ACS))
        if [ "$TESTABLE_AC_COUNT" -gt 0 ]; then
            AC_TRACEABILITY=$((TESTED_ACS * 100 / TESTABLE_AC_COUNT))
        else
            AC_TRACEABILITY=100
        fi
    else
        AC_TRACEABILITY=0
    fi

    AC_MIN_THRESHOLD="${QA_AC_TRACEABILITY_MIN:-95}"

    if [ "$TESTED_ACS" -eq "$TESTABLE_AC_COUNT" ]; then
        print_success "All testable ACs have tests (100% traceability)"
    elif [ "$AC_TRACEABILITY" -ge "$AC_MIN_THRESHOLD" ]; then
        print_success "$TESTED_ACS/$TESTABLE_AC_COUNT ACs have tests (${AC_TRACEABILITY}% ≥ ${AC_MIN_THRESHOLD}%)"
        if [ "$MANUAL_REVIEW_ACS" -gt 0 ]; then
            print_info "$MANUAL_REVIEW_ACS AC(s) marked for manual review"
        fi
    else
        print_error "$TESTED_ACS/$TESTABLE_AC_COUNT ACs have tests (${AC_TRACEABILITY}% < ${AC_MIN_THRESHOLD}%)"
        ISSUES=$((ISSUES + 1))
        if [ "$MANUAL_REVIEW_ACS" -gt 0 ]; then
            print_info "$MANUAL_REVIEW_ACS AC(s) marked for manual review"
        fi
        if [ "${QA_AC_MANUAL_REVIEW:-true}" = "true" ]; then
            print_info "Tip: Mark non-testable ACs in $AC_OVERRIDES_FILE"
        fi
    fi
else
    print_info "No acceptance criteria found (skipping traceability check)"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 7: Generate review report
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

mkdir -p .gobuildme/specs/qa-test-scaffolding

cat > .gobuildme/specs/qa-test-scaffolding/quality-review.md << EOF
# Test Quality Review Report

**Generated**: $(date)
**Language**: $LANGUAGE
**Test Framework**: $TEST_FRAMEWORK

## Summary

- **Test Structure**: $([ -d "tests" ] && echo "✓ Pass" || echo "✗ Fail")
- **TODO Tests**: $([ -z "$TODO_FILES" ] && echo "✓ None" || echo "⚠️ Found")
- **Coverage**: $([ "$COVERAGE_PASSED" = true ] && echo "✓ Pass" || echo "⚠️ Below threshold")
- **AC Traceability**: $([ -n "${FEATURE_ACS:-}" ] && echo "Checked" || echo "N/A")

## Issues Found

Total issues: $ISSUES

EOF

if [ $ISSUES -eq 0 ]; then
    cat >> .gobuildme/specs/qa-test-scaffolding/quality-review.md << 'EOF'
✅ **No issues found!** Tests meet quality standards.

EOF
else
    cat >> .gobuildme/specs/qa-test-scaffolding/quality-review.md << 'EOF'
⚠️ **Issues found.** Please address before proceeding.

EOF
fi

cat >> .gobuildme/specs/qa-test-scaffolding/quality-review.md << 'EOF'
## Recommendations

1. **Implement all TODO tests** - Use /gbm.qa.implement-tests for guidance
2. **Improve coverage** - Add tests for uncovered code paths
3. **Ensure AC traceability** - Reference ACs in test docstrings
4. **Follow AAA pattern** - Arrange, Act, Assert structure
5. **Use descriptive names** - Test names should describe behavior

## Next Steps

- Fix any issues found above
- Re-run: /gbm.qa.review-tests
- When all checks pass: /gbm.review
- Then: /gbm.push

EOF

# Save pass/fail status for /gbm.review integration
echo "quality_review_passed=$([ $ISSUES -eq 0 ] && echo 'true' || echo 'false')" > .gobuildme/specs/qa-test-scaffolding/quality-review.txt

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 8: Display results
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_section "📊 Review Summary"

# Determine exit code based on gate mode
EXIT_CODE=0

if [ $ISSUES -eq 0 ]; then
    echo "✅ All quality checks passed!"
    echo ""
    echo "Next steps:"
    echo "  • Run final review: /gbm.review"
    echo "  • Create PR: /gbm.push"
    EXIT_CODE=0
else
    case "${QA_GATE_MODE:-advisory}" in
        strict)
            echo "❌ Found $ISSUES issue(s) - BLOCKING (strict mode)"
            echo ""
            echo "Quality gates failed. Must fix before proceeding."
            echo ""
            echo "Next steps:"
            echo "  • Address issues listed above"
            echo "  • Re-run: /gbm.qa.review-tests"
            echo ""
            echo "To change gate mode, edit .gobuildme/config/qa-config.yaml"
            EXIT_CODE=$ISSUES
            ;;
        advisory)
            echo "⚠️  Found $ISSUES issue(s) - WARNING (advisory mode)"
            echo ""
            echo "Quality gates flagged issues but not blocking."
            echo ""
            echo "Next steps:"
            echo "  • Review issues listed above"
            echo "  • Address critical issues before merging"
            echo "  • Optional: Re-run /gbm.qa.review-tests after fixes"
            EXIT_CODE=0  # Don't block in advisory mode
            ;;
        disabled)
            echo "ℹ️  Found $ISSUES issue(s) - INFO ONLY (gates disabled)"
            echo ""
            echo "Quality gates are disabled. Review issues manually."
            EXIT_CODE=0
            ;;
        *)
            echo "⚠️  Found $ISSUES issue(s)"
            EXIT_CODE=$ISSUES
            ;;
    esac
fi

echo ""
echo "📄 Full report: .gobuildme/specs/qa-test-scaffolding/quality-review.md"
echo "Gate Mode: ${QA_GATE_MODE:-advisory}"
echo ""

# Exit with appropriate code
exit $EXIT_CODE

