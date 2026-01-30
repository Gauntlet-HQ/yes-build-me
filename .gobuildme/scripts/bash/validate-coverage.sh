#!/usr/bin/env bash
# Purpose: Validate test coverage meets thresholds
# Why: Enforce quality gates for unit, integration, and e2e tests
# How: Run coverage tools and compare against thresholds

set -euo pipefail

# Default thresholds (can be overridden by constitution or CLI args)
UNIT_THRESHOLD=${UNIT_THRESHOLD:-90}
INTEGRATION_THRESHOLD=${INTEGRATION_THRESHOLD:-95}
E2E_THRESHOLD=${E2E_THRESHOLD:-80}
OVERALL_THRESHOLD=${OVERALL_THRESHOLD:-85}

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              TEST COVERAGE VALIDATION                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Detect language and test framework
detect_language() {
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "python"
    elif [ -f "package.json" ]; then
        echo "javascript"
    elif [ -f "composer.json" ]; then
        echo "php"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "java"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

LANGUAGE=$(detect_language)
echo -e "${BLUE}Detected language: $LANGUAGE${NC}"
echo ""

# Run coverage for Python
run_python_coverage() {
    echo "Running Python coverage..."
    
    if ! command -v pytest >/dev/null 2>&1; then
        echo -e "${RED}✗ pytest not found${NC}"
        return 1
    fi
    
    # Run coverage
    if python -c 'import pytest_cov' 2>/dev/null; then
        pytest --cov=. --cov-report=term-missing --cov-report=json tests/ || true
        
        # Parse coverage.json
        if [ -f "coverage.json" ]; then
            overall=$(python3 -c "import json; data=json.load(open('coverage.json')); print(int(data['totals']['percent_covered']))")
            echo -e "${GREEN}Overall coverage: ${overall}%${NC}"
            
            if [ "$overall" -lt "$OVERALL_THRESHOLD" ]; then
                echo -e "${RED}✗ Coverage ${overall}% is below threshold ${OVERALL_THRESHOLD}%${NC}"
                return 1
            else
                echo -e "${GREEN}✓ Coverage ${overall}% meets threshold ${OVERALL_THRESHOLD}%${NC}"
                return 0
            fi
        fi
    else
        echo -e "${YELLOW}⚠ pytest-cov not installed${NC}"
        return 1
    fi
}

# Run coverage for JavaScript/TypeScript
run_javascript_coverage() {
    echo "Running JavaScript/TypeScript coverage..."
    
    if [ -f "package.json" ]; then
        # Check for coverage script
        if grep -q '"coverage"' package.json; then
            npm run coverage || yarn coverage || pnpm coverage || true
            
            # Parse coverage from output or coverage-summary.json
            if [ -f "coverage/coverage-summary.json" ]; then
                overall=$(node -e "const data=require('./coverage/coverage-summary.json'); console.log(Math.floor(data.total.lines.pct))")
                echo -e "${GREEN}Overall coverage: ${overall}%${NC}"
                
                if [ "$overall" -lt "$OVERALL_THRESHOLD" ]; then
                    echo -e "${RED}✗ Coverage ${overall}% is below threshold ${OVERALL_THRESHOLD}%${NC}"
                    return 1
                else
                    echo -e "${GREEN}✓ Coverage ${overall}% meets threshold ${OVERALL_THRESHOLD}%${NC}"
                    return 0
                fi
            fi
        else
            echo -e "${YELLOW}⚠ No coverage script found in package.json${NC}"
            return 1
        fi
    fi
}

# Run coverage for PHP
run_php_coverage() {
    echo "Running PHP coverage..."
    
    if command -v phpunit >/dev/null 2>&1; then
        phpunit --coverage-text --coverage-html=coverage || true
        
        # Parse coverage from output
        coverage_line=$(phpunit --coverage-text 2>&1 | grep "Lines:" | tail -n1 || echo "")
        if [ -n "$coverage_line" ]; then
            overall=$(echo "$coverage_line" | grep -oE '[0-9]+\.[0-9]+%' | head -n1 | tr -d '%' | cut -d'.' -f1)
            echo -e "${GREEN}Overall coverage: ${overall}%${NC}"
            
            if [ "$overall" -lt "$OVERALL_THRESHOLD" ]; then
                echo -e "${RED}✗ Coverage ${overall}% is below threshold ${OVERALL_THRESHOLD}%${NC}"
                return 1
            else
                echo -e "${GREEN}✓ Coverage ${overall}% meets threshold ${OVERALL_THRESHOLD}%${NC}"
                return 0
            fi
        fi
    else
        echo -e "${YELLOW}⚠ PHPUnit not found${NC}"
        return 1
    fi
}

# Run coverage for Java
run_java_coverage() {
    echo "Running Java coverage..."
    
    if [ -f "pom.xml" ]; then
        # Maven with JaCoCo
        mvn clean test jacoco:report || true
        
        # Parse coverage from target/site/jacoco/index.html
        if [ -f "target/site/jacoco/index.html" ]; then
            overall=$(grep -oE 'Total[^0-9]*([0-9]+)%' target/site/jacoco/index.html | grep -oE '[0-9]+' | head -n1)
            echo -e "${GREEN}Overall coverage: ${overall}%${NC}"
            
            if [ "$overall" -lt "$OVERALL_THRESHOLD" ]; then
                echo -e "${RED}✗ Coverage ${overall}% is below threshold ${OVERALL_THRESHOLD}%${NC}"
                return 1
            else
                echo -e "${GREEN}✓ Coverage ${overall}% meets threshold ${OVERALL_THRESHOLD}%${NC}"
                return 0
            fi
        fi
    elif [ -f "build.gradle" ]; then
        # Gradle with JaCoCo
        ./gradlew test jacocoTestReport || gradle test jacocoTestReport || true
        
        # Parse coverage from build/reports/jacoco/test/html/index.html
        if [ -f "build/reports/jacoco/test/html/index.html" ]; then
            overall=$(grep -oE 'Total[^0-9]*([0-9]+)%' build/reports/jacoco/test/html/index.html | grep -oE '[0-9]+' | head -n1)
            echo -e "${GREEN}Overall coverage: ${overall}%${NC}"
            
            if [ "$overall" -lt "$OVERALL_THRESHOLD" ]; then
                echo -e "${RED}✗ Coverage ${overall}% is below threshold ${OVERALL_THRESHOLD}%${NC}"
                return 1
            else
                echo -e "${GREEN}✓ Coverage ${overall}% meets threshold ${OVERALL_THRESHOLD}%${NC}"
                return 0
            fi
        fi
    fi
}

# Run coverage for Go
run_go_coverage() {
    echo "Running Go coverage..."
    
    if command -v go >/dev/null 2>&1; then
        go test -coverprofile=coverage.out ./... || true
        
        if [ -f "coverage.out" ]; then
            overall=$(go tool cover -func=coverage.out | grep total | grep -oE '[0-9]+\.[0-9]+' | cut -d'.' -f1)
            echo -e "${GREEN}Overall coverage: ${overall}%${NC}"
            
            if [ "$overall" -lt "$OVERALL_THRESHOLD" ]; then
                echo -e "${RED}✗ Coverage ${overall}% is below threshold ${OVERALL_THRESHOLD}%${NC}"
                return 1
            else
                echo -e "${GREEN}✓ Coverage ${overall}% meets threshold ${OVERALL_THRESHOLD}%${NC}"
                return 0
            fi
        fi
    fi
}

# Main execution
case "$LANGUAGE" in
    python)
        run_python_coverage
        ;;
    javascript)
        run_javascript_coverage
        ;;
    php)
        run_php_coverage
        ;;
    java)
        run_java_coverage
        ;;
    go)
        run_go_coverage
        ;;
    *)
        echo -e "${RED}✗ Unsupported language: $LANGUAGE${NC}"
        exit 1
        ;;
esac

exit_code=$?

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              COVERAGE VALIDATION COMPLETE                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"

exit $exit_code

