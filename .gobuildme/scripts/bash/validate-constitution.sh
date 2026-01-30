#!/usr/bin/env bash
# Purpose : Validate the repository against organizational constitution rules.
# Why     : Keeps teams honest to GoBuildMe governance by surfacing violations
#           early in the SDD workflow.
# How     : Loads the constitution, inspects code/test layout, runs heuristics,
#           and aggregates actionable errors/warnings for follow-up.
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

constitution_file=".gobuildme/memory/constitution.md"
errors=0
warnings=0

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    errors=$((errors+1))
}

log_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}" >&2
    warnings=$((warnings+1))
}

log_info() {
    echo -e "${GREEN}INFO: $1${NC}"
}

# Check if constitution exists
if [ ! -f "$constitution_file" ]; then
    log_error "Constitution file not found at $constitution_file"
    exit 1
fi

log_info "Validating constitutional compliance..."

# Extract principles from constitution (look for ### headers)
principles=$(grep "^### " "$constitution_file" | sed 's/^### //' || true)

if [ -z "$principles" ]; then
    log_warning "No principles found in constitution (expected ### headers)"
fi

# Check for common constitutional violations

# 1. Test-First principle validation
if grep -q "Test-First\|TDD" "$constitution_file"; then
    log_info "Checking Test-First compliance..."
    
    # Check if tests exist
    test_dirs=("test" "tests" "__tests__" "spec" "specs")
    has_tests=false
    for dir in "${test_dirs[@]}"; do
        if [ -d "$dir" ]; then
            has_tests=true
            break
        fi
    done
    
    if [ "$has_tests" = false ]; then
        # Check for test files in src directories
        if find . -name "*test*" -o -name "*spec*" | grep -E "\.(py|js|ts|go|rs|java)$" >/dev/null 2>&1; then
            has_tests=true
        fi
    fi
    
    if [ "$has_tests" = false ]; then
        log_error "Test-First principle violated: No test files found"
    else
        log_info "Test-First principle: Tests found"
    fi
fi

# 2. Library-First principle validation
if grep -q "Library-First" "$constitution_file"; then
    log_info "Checking Library-First compliance..."
    
    # Check for proper library structure
    if [ -d "src" ] || [ -d "lib" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ] || [ -f "package.json" ]; then
        log_info "Library-First principle: Library structure detected"
    else
        log_warning "Library-First principle: No clear library structure found"
    fi
fi

# 3. CLI Interface principle validation
if grep -q "CLI Interface" "$constitution_file"; then
    log_info "Checking CLI Interface compliance..."
    
    # Check for CLI entry points
    has_cli=false
    if [ -f "pyproject.toml" ] && grep -q "\[project.scripts\]" pyproject.toml; then
        has_cli=true
    elif [ -f "package.json" ] && grep -q "\"bin\":" package.json; then
        has_cli=true
    elif [ -f "Cargo.toml" ] && grep -q "\[\[bin\]\]" Cargo.toml; then
        has_cli=true
    elif find . -name "main.py" -o -name "cli.py" -o -name "main.go" >/dev/null 2>&1; then
        has_cli=true
    fi
    
    if [ "$has_cli" = true ]; then
        log_info "CLI Interface principle: CLI entry points found"
    else
        log_warning "CLI Interface principle: No CLI entry points detected"
    fi
fi

# 4. Security requirements validation
if grep -q -i "security\|secrets\|tls" "$constitution_file"; then
    log_info "Checking security compliance..."
    
    # Check for secrets in code
    if command -v rg >/dev/null 2>&1; then
        secrets_found=$(rg -i "password\s*=\s*['\"][^'\"]+['\"]|api_key\s*=\s*['\"][^'\"]+['\"]|secret\s*=\s*['\"][^'\"]+['\"]" --type py --type js --type ts --type go 2>/dev/null || true)
    else
        secrets_found=$(grep -r -i "password\s*=\s*['\"][^'\"]\+['\"]" --include="*.py" --include="*.js" --include="*.ts" --include="*.go" . 2>/dev/null || true)
    fi
    
    if [ -n "$secrets_found" ]; then
        log_error "Security violation: Potential hardcoded secrets found in code"
    else
        log_info "Security check: No obvious hardcoded secrets found"
    fi
    
    # Check for .env files in git
    if [ -f ".env" ] && git ls-files --error-unmatch .env >/dev/null 2>&1; then
        log_error "Security violation: .env file is tracked in git"
    fi
fi

# 5. Dependency management validation
if grep -q -i "dependency\|pin" "$constitution_file"; then
    log_info "Checking dependency management compliance..."
    
    # Check for lock files
    lock_files=("package-lock.json" "yarn.lock" "pnpm-lock.yaml" "poetry.lock" "Pipfile.lock" "Cargo.lock" "go.sum")
    has_lockfile=false
    for lockfile in "${lock_files[@]}"; do
        if [ -f "$lockfile" ]; then
            has_lockfile=true
            log_info "Dependency management: Found $lockfile"
            break
        fi
    done
    
    if [ "$has_lockfile" = false ]; then
        log_warning "Dependency management: No lock files found (dependencies not pinned)"
    fi
fi

# 6. Architecture baseline validation
if grep -q "Architecture Baseline" "$constitution_file"; then
    log_info "Checking architecture baseline compliance..."
    
    # Run architecture validation
    if [ -f "scripts/bash/validate-architecture.sh" ]; then
        if ./scripts/bash/validate-architecture.sh >/dev/null 2>&1; then
            log_info "Architecture baseline: Validation passed"
        else
            log_error "Architecture baseline: Validation failed"
        fi
    else
        log_warning "Architecture baseline: No validation script found"
    fi
fi

# Summary
echo
if [ $errors -gt 0 ]; then
    echo -e "${RED}Constitutional compliance failed: $errors error(s), $warnings warning(s)${NC}" >&2
    exit 1
elif [ $warnings -gt 0 ]; then
    echo -e "${YELLOW}Constitutional compliance passed with warnings: $warnings warning(s)${NC}"
    exit 0
else
    echo -e "${GREEN}Constitutional compliance: All checks passed${NC}"
    exit 0
fi
