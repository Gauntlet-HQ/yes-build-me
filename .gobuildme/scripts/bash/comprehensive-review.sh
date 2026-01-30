#!/usr/bin/env bash
# Purpose : Provide `/review` with an end-to-end quality gate across the project.
# Why     : Aggregates architecture, code quality, tests, security, CI/CD, and
#           documentation checks into a single actionable report.
# How     : Invokes supporting scripts, tallies category scores, and prints a
#           human-friendly summary with pass/warn/fail indicators.
set -euo pipefail

# comprehensive-review.sh - End-to-end project review
# Performs systematic checks across all project aspects

script_dir="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/common.sh"

# Initialize review tracking
overall_score=0
total_categories=6

# Category scores and details (using pattern: category_score_<name>=value)
architecture_score=0
architecture_details=""
code_quality_score=0
code_quality_details=""
testing_score=0
testing_details=""
security_score=0
security_details=""
cicd_score=0
cicd_details=""
documentation_score=0
documentation_details=""

# Color codes for status
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Status indicators
PASS="🟢"
WARN="🟡"
FAIL="🔴"

log_header() {
    echo -e "\n${BOLD}${BLUE}========================================${NC}"
    echo -e "${BOLD}${BLUE} $1${NC}"
    echo -e "${BOLD}${BLUE}========================================${NC}\n"
}

log_category() {
    echo -e "\n${BOLD}## $1${NC}\n"
}

log_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS") echo -e "${PASS} ${GREEN}$message${NC}" ;;
        "WARN") echo -e "${WARN} ${YELLOW}$message${NC}" ;;
        "FAIL") echo -e "${FAIL} ${RED}$message${NC}" ;;
        *) echo -e "$message" ;;
    esac
}

# Category scoring: 2=pass, 1=warning, 0=fail
score_category() {
    local category=$1
    local score=$2
    local details=$3

    case $category in
        "architecture")
            architecture_score=$score
            architecture_details="$details"
            ;;
        "code_quality")
            code_quality_score=$score
            code_quality_details="$details"
            ;;
        "testing")
            testing_score=$score
            testing_details="$details"
            ;;
        "security")
            security_score=$score
            security_details="$details"
            ;;
        "cicd")
            cicd_score=$score
            cicd_details="$details"
            ;;
        "documentation")
            documentation_score=$score
            documentation_details="$details"
            ;;
    esac

    overall_score=$((overall_score + score))
}

# 1. Architecture & Structure Review
review_architecture() {
    log_category "1. Architecture & Structure"
    local score=2
    local details=""

    # Run architecture analysis
    if [[ -x "$script_dir/analyze-architecture.sh" ]]; then
        log_status "INFO" "Analyzing architecture..."
        if "$script_dir/analyze-architecture.sh" >/dev/null 2>&1; then
            details+="✓ Architecture analysis completed\n"
        else
            details+="⚠ Architecture analysis had issues\n"
            score=1
        fi
    fi

    # Run codebase scan
    if [[ -x "$script_dir/scan-codebase.sh" ]]; then
        log_status "INFO" "Scanning codebase structure..."
        local scan_output
        scan_output=$("$script_dir/scan-codebase.sh" 2>&1 || true)
        if [[ $? -eq 0 ]]; then
            details+="✓ Codebase scan successful\n"
        else
            details+="⚠ Codebase scan encountered issues\n"
            score=1
        fi
    fi

    # Validate architecture boundaries
    if [[ -x "$script_dir/validate-architecture.sh" ]]; then
        log_status "INFO" "Validating architecture boundaries..."
        if "$script_dir/validate-architecture.sh" >/dev/null 2>&1; then
            details+="✓ Architecture boundaries valid\n"
            log_status "PASS" "Architecture validation passed"
        else
            details+="✗ Architecture boundary violations detected\n"
            log_status "FAIL" "Architecture validation failed"
            score=0
        fi
    else
        details+="- Architecture validation script not found\n"
    fi

    # Validate constitutional compliance
    if [[ -x "$script_dir/validate-constitution.sh" ]]; then
        log_status "INFO" "Validating constitutional compliance..."
        if "$script_dir/validate-constitution.sh" >/dev/null 2>&1; then
            details+="✓ Constitutional compliance validated\n"
            log_status "PASS" "Constitutional validation passed"
        else
            details+="✗ Constitutional violations detected\n"
            log_status "FAIL" "Constitutional validation failed"
            score=0
        fi
    else
        details+="- Constitutional validation script not found"
        score=1
    fi

    score_category "architecture" $score "$details"
}

# 2. Code Quality & Conventions Review
review_code_quality() {
    log_category "2. Code Quality & Conventions"
    local score=2
    local details=""

    # Validate conventions
    if [[ -x "$script_dir/validate-conventions.sh" ]]; then
        log_status "INFO" "Validating code conventions..."
        if "$script_dir/validate-conventions.sh" >/dev/null 2>&1; then
            details+="✓ Code conventions validated\n"
            log_status "PASS" "Code conventions check passed"
        else
            details+="✗ Code convention violations found\n"
            log_status "FAIL" "Code conventions check failed"
            score=0
        fi
    else
        details+="- Convention validation script not found\n"
        score=1
    fi

    # Run linting
    if [[ -x "$script_dir/run-lint.sh" ]]; then
        log_status "INFO" "Running linting checks..."
        local lint_output
        lint_output=$("$script_dir/run-lint.sh" 2>&1 || true)
        if [[ $? -eq 0 ]]; then
            details+="✓ Linting passed\n"
            log_status "PASS" "Linting check passed"
        else
            local error_count
            error_count=$(echo "$lint_output" | grep -c "error\|Error\|ERROR" || true)
            if [[ $error_count -gt 0 ]]; then
                details+="✗ $error_count linting errors found\n"
                log_status "FAIL" "Linting failed with $error_count errors"
                score=0
            else
                details+="⚠ Linting warnings present\n"
                log_status "WARN" "Linting passed with warnings"
                score=1
            fi
        fi
    else
        details+="- Linting script not found\n"
        score=1
    fi

    # Type checking
    if [[ -x "$script_dir/run-type-check.sh" ]]; then
        log_status "INFO" "Running type checks..."
        if "$script_dir/run-type-check.sh" >/dev/null 2>&1; then
            details+="✓ Type checking passed\n"
            log_status "PASS" "Type checking passed"
        else
            details+="✗ Type checking errors found\n"
            log_status "FAIL" "Type checking failed"
            score=0
        fi
    else
        details+="- Type checking script not found\n"
        score=1
    fi

    score_category "code_quality" $score "$details"
}

# 3. Testing & Coverage Review
review_testing() {
    log_category "3. Testing & Coverage"
    local score=2
    local details=""

    # Run tests
    if [[ -x "$script_dir/run-tests.sh" ]]; then
        log_status "INFO" "Running test suite..."
        local test_output
        test_output=$("$script_dir/run-tests.sh" --json 2>&1 || true)
        local test_exit_code=$?

        if [[ $test_exit_code -eq 0 ]]; then
            details+="✓ All tests passed\n"
            log_status "PASS" "Test suite passed"

            # Check for coverage information
            if echo "$test_output" | grep -q "coverage\|Coverage"; then
                local coverage_line
                coverage_line=$(echo "$test_output" | grep -i "coverage" | head -n1 || true)
                details+="✓ Coverage: $coverage_line\n"

                # Extract coverage percentage if possible
                local coverage_pct
                coverage_pct=$(echo "$coverage_line" | grep -oE '[0-9]+%' | head -n1 || true)
                if [[ -n "$coverage_pct" ]]; then
                    local pct_num
                    pct_num=$(echo "$coverage_pct" | tr -d '%')
                    if [[ $pct_num -lt 70 ]]; then
                        details+="⚠ Coverage below 70% threshold\n"
                        log_status "WARN" "Test coverage below recommended threshold"
                        score=1
                    fi
                fi
            else
                details+="- No coverage information available\n"
                score=1
            fi
        else
            local failed_tests
            failed_tests=$(echo "$test_output" | grep -c "FAILED\|failed\|FAIL" || true)
            details+="✗ $failed_tests test(s) failed\n"
            log_status "FAIL" "Test suite failed ($failed_tests failures)"
            score=0
        fi
    else
        details+="- Test script not found\n"
        log_status "WARN" "No test script available"
        score=1
    fi

    score_category "testing" $score "$details"
}

# 4. Security & Compliance Review
review_security() {
    log_category "4. Security & Compliance"
    local score=2
    local details=""

    # Run security scan
    if [[ -x "$script_dir/security-scan.sh" ]]; then
        log_status "INFO" "Running security scan..."
        local security_output
        security_output=$("$script_dir/security-scan.sh" 2>&1 || true)
        if [[ $? -eq 0 ]]; then
            details+="✓ Security scan passed\n"
            log_status "PASS" "Security scan passed"
        else
            local vuln_count
            vuln_count=$(echo "$security_output" | grep -c "vulnerability\|Vulnerability\|VULNERABILITY\|HIGH\|CRITICAL" || true)
            if [[ $vuln_count -gt 0 ]]; then
                details+="✗ $vuln_count security vulnerabilities found\n"
                log_status "FAIL" "Security vulnerabilities detected"
                score=0
            else
                details+="⚠ Security scan completed with warnings\n"
                log_status "WARN" "Security scan passed with warnings"
                score=1
            fi
        fi
    else
        details+="- Security scan script not found\n"
        score=1
    fi

    # Check for sensitive files
    log_status "INFO" "Checking for sensitive data..."
    local sensitive_patterns=("password" "secret" "key" "token" "api_key" "private")
    local sensitive_found=false

    for pattern in "${sensitive_patterns[@]}"; do
        if find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.java" \) \
           -not -path './.git/*' -not -path './node_modules/*' -not -path './.venv/*' \
           -exec grep -l -i "$pattern" {} \; 2>/dev/null | head -n1 | grep -q .; then
            sensitive_found=true
            break
        fi
    done

    if ! $sensitive_found; then
        details+="✓ No obvious sensitive data in code\n"
    else
        details+="⚠ Potential sensitive data found in code files\n"
        score=1
    fi

    score_category "security" $score "$details"
}

# 5. CI/CD & Deployment Review
review_cicd() {
    log_category "5. CI/CD & Deployment"
    local score=2
    local details=""

    # Check branch status
    if [[ -x "$script_dir/branch-status.sh" ]]; then
        log_status "INFO" "Checking branch status..."
        if "$script_dir/branch-status.sh" >/dev/null 2>&1; then
            details+="✓ Branch status clean\n"
            log_status "PASS" "Branch status check passed"
        else
            details+="⚠ Branch status issues detected\n"
            log_status "WARN" "Branch status check has warnings"
            score=1
        fi
    fi

    # Check CI workflows
    if [[ -d ".github/workflows" ]]; then
        local workflow_count
        workflow_count=$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l)
        if [[ $workflow_count -gt 0 ]]; then
            details+="✓ $workflow_count CI workflow(s) found\n"
            log_status "PASS" "CI workflows present"
        else
            details+="- No CI workflows found\n"
            score=1
        fi
    else
        details+="- No .github/workflows directory\n"
        score=1
    fi

    # Ready to push check
    if [[ -x "$script_dir/ready-to-push.sh" ]]; then
        log_status "INFO" "Checking deployment readiness..."
        if "$script_dir/ready-to-push.sh" >/dev/null 2>&1; then
            details+="✓ Ready for deployment\n"
            log_status "PASS" "Deployment readiness check passed"
        else
            details+="✗ Not ready for deployment\n"
            log_status "FAIL" "Deployment readiness check failed"
            score=0
        fi
    else
        details+="- Ready-to-push script not found\n"
        score=1
    fi

    score_category "cicd" $score "$details"
}

# 6. Documentation & Maintenance Review
review_documentation() {
    log_category "6. Documentation & Maintenance"
    local score=2
    local details=""

    # Check for essential documentation
    local essential_docs=("README.md" "CONTRIBUTING.md" "CHANGELOG.md")
    local missing_docs=()

    for doc in "${essential_docs[@]}"; do
        if [[ -f "$doc" ]]; then
            details+="✓ $doc present\n"
        else
            missing_docs+=("$doc")
        fi
    done

    if [[ ${#missing_docs[@]} -eq 0 ]]; then
        log_status "PASS" "Essential documentation present"
    elif [[ ${#missing_docs[@]} -le 1 ]]; then
        details+="⚠ Missing: ${missing_docs[*]}\n"
        log_status "WARN" "Some documentation missing"
        score=1
    else
        details+="✗ Missing: ${missing_docs[*]}\n"
        log_status "FAIL" "Critical documentation missing"
        score=0
    fi

    # Check for code organization documentation
    if [[ -f "docs/ARCHITECTURE.md" ]] || [[ -f "ARCHITECTURE.md" ]]; then
        details+="✓ Architecture documentation found\n"
    else
        details+="- No architecture documentation\n"
        score=1
    fi

    # Check git history health
    local commit_count
    commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    if [[ $commit_count -gt 1 ]]; then
        details+="✓ $commit_count commits in history\n"
    else
        details+="⚠ Limited git history\n"
        score=1
    fi

    score_category "documentation" $score "$details"
}

# Generate comprehensive report
generate_report() {
    log_header "COMPREHENSIVE PROJECT REVIEW REPORT"

    # Calculate overall health score
    local max_score=$((total_categories * 2))
    local health_percentage=$(( (overall_score * 100) / max_score ))

    echo -e "${BOLD}Overall Project Health: $health_percentage% ($overall_score/$max_score)${NC}\n"

    # Health status
    if [[ $health_percentage -ge 90 ]]; then
        echo -e "${PASS} ${GREEN}${BOLD}EXCELLENT${NC} - Project is in excellent condition"
    elif [[ $health_percentage -ge 75 ]]; then
        echo -e "${WARN} ${YELLOW}${BOLD}GOOD${NC} - Project is in good condition with minor issues"
    elif [[ $health_percentage -ge 60 ]]; then
        echo -e "${WARN} ${YELLOW}${BOLD}FAIR${NC} - Project needs attention in several areas"
    else
        echo -e "${FAIL} ${RED}${BOLD}POOR${NC} - Project has significant issues requiring immediate attention"
    fi

    echo -e "\n${BOLD}Category Breakdown:${NC}\n"

    # Display category results
    local categories=("architecture" "code_quality" "testing" "security" "cicd" "documentation")
    local category_names=("Architecture & Structure" "Code Quality & Conventions" "Testing & Coverage" "Security & Compliance" "CI/CD & Deployment" "Documentation & Maintenance")

    for i in "${!categories[@]}"; do
        local cat="${categories[$i]}"
        local name="${category_names[$i]}"
        local score
        local details

        case $cat in
            "architecture")
                score=$architecture_score
                details="$architecture_details"
                ;;
            "code_quality")
                score=$code_quality_score
                details="$code_quality_details"
                ;;
            "testing")
                score=$testing_score
                details="$testing_details"
                ;;
            "security")
                score=$security_score
                details="$security_details"
                ;;
            "cicd")
                score=$cicd_score
                details="$cicd_details"
                ;;
            "documentation")
                score=$documentation_score
                details="$documentation_details"
                ;;
        esac

        echo -e "${BOLD}${name}:${NC}"
        case $score in
            2) echo -e "  ${PASS} ${GREEN}PASS${NC}" ;;
            1) echo -e "  ${WARN} ${YELLOW}WARNING${NC}" ;;
            0) echo -e "  ${FAIL} ${RED}FAIL${NC}" ;;
        esac
        echo -e "$details" | sed 's/^/  /'
        echo
    done

    # Blocking issues
    local blocking_issues=0
    local scores=($architecture_score $code_quality_score $testing_score $security_score $cicd_score $documentation_score)
    for score in "${scores[@]}"; do
        if [[ $score -eq 0 ]]; then
            ((blocking_issues++))
        fi
    done

    if [[ $blocking_issues -gt 0 ]]; then
        echo -e "${BOLD}${RED}⚠ BLOCKING ISSUES DETECTED (${blocking_issues})${NC}"
        echo -e "The following categories have critical issues that must be resolved:"

        for i in "${!categories[@]}"; do
            local cat="${categories[$i]}"
            local name="${category_names[$i]}"
            local score

            case $cat in
                "architecture") score=$architecture_score ;;
                "code_quality") score=$code_quality_score ;;
                "testing") score=$testing_score ;;
                "security") score=$security_score ;;
                "cicd") score=$cicd_score ;;
                "documentation") score=$documentation_score ;;
            esac

            if [[ $score -eq 0 ]]; then
                echo -e "  ${FAIL} ${name}"
            fi
        done
        echo
    fi

    # Recommendations
    echo -e "${BOLD}Next Steps:${NC}"
    if [[ $blocking_issues -gt 0 ]]; then
        echo "1. ${FAIL} Address all blocking issues immediately"
        echo "2. Re-run review after fixes"
        echo "3. Once all issues resolved, run /ready-to-push"
    elif [[ $health_percentage -ge 90 ]]; then
        echo "1. ${PASS} Project ready for deployment"
        echo "2. Consider running /ready-to-push for final validation"
        echo "3. Optional: Run /gbm.preflight for additional verification"
    else
        echo "1. ${WARN} Address warning-level issues in next sprint"
        echo "2. Run /ready-to-push to check deployment readiness"
        echo "3. Consider implementing automated quality gates"
    fi

    echo
    return $blocking_issues
}

# Main execution
main() {
    log_header "Starting Comprehensive Project Review"

    # Run all review categories
    review_architecture
    review_code_quality
    review_testing
    review_security
    review_cicd
    review_documentation

    # Generate final report
    generate_report

    # Exit with appropriate code
    local blocking_issues=$?
    if [[ $blocking_issues -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

# Handle arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [--help]"
        echo "Performs comprehensive end-to-end project review"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
