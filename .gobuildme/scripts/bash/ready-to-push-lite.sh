#!/usr/bin/env bash
# Purpose : Run lightweight preflight checks for lite/quickfix workflows.
# Why     : Provides essential quality gates (lint, type-check, targeted tests)
#           without the full test suite or security scans of ready-to-push.sh.
# How     : Runs lint and type-check always, then tests only changed test files.
set -euo pipefail

# Output styling
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Lite Preflight Checks${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# === Check for Uncommitted Changes ===
echo -e "\n${BOLD}== Uncommitted Changes Check ==${NC}"
# Check for both staged and unstaged changes
UNCOMMITTED=$(git status --porcelain 2>/dev/null || echo "")
if [[ -n "$UNCOMMITTED" ]]; then
  echo -e "${RED}❌ Uncommitted changes detected:${NC}"
  git status --short
  echo ""
  echo -e "${YELLOW}Please commit or stash your changes before running preflight.${NC}"
  echo -e "${YELLOW}The preflight tests committed code, not your working directory.${NC}"
  exit 1
else
  echo -e "${GREEN}✅ Working directory is clean${NC}"
fi

# Track overall status
LINT_STATUS=0
TYPE_STATUS=0
TEST_STATUS=0
OVERALL_STATUS=0

# === Lint ===
echo -e "\n${BOLD}== Lint ==${NC}"
if [[ -f .gobuildme/scripts/bash/run-lint.sh ]]; then
  if .gobuildme/scripts/bash/run-lint.sh; then
    echo -e "${GREEN}✅ Lint passed${NC}"
    LINT_STATUS=0
  else
    echo -e "${RED}❌ Lint failed${NC}"
    LINT_STATUS=1
    OVERALL_STATUS=1
  fi
else
  echo -e "${YELLOW}⚠️  Lint script not found - skipping${NC}"
fi

# === Type Check ===
echo -e "\n${BOLD}== Type Check ==${NC}"
if [[ -f .gobuildme/scripts/bash/run-type-check.sh ]]; then
  if .gobuildme/scripts/bash/run-type-check.sh; then
    echo -e "${GREEN}✅ Type check passed${NC}"
    TYPE_STATUS=0
  else
    echo -e "${RED}❌ Type check failed${NC}"
    TYPE_STATUS=1
    OVERALL_STATUS=1
  fi
else
  echo -e "${YELLOW}⚠️  Type check script not found - skipping${NC}"
fi

# === Tests (Changed and Related Files) ===
echo -e "\n${BOLD}== Tests (Changed + Related Files) ==${NC}"

# Get base branch for comparison (main -> master -> upstream -> initial commit)
BASE_BRANCH="main"
if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  BASE_BRANCH="master"
fi
if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  BASE_BRANCH="develop"
fi
if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  # Try to find upstream tracking branch
  UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null || echo "")
  if [[ -n "$UPSTREAM" ]]; then
    BASE_BRANCH="$UPSTREAM"
  fi
fi
if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  # Final fallback: use repo's initial commit (guarantees we have something to compare against)
  INITIAL_COMMIT=$(git rev-list --max-parents=0 HEAD 2>/dev/null | tail -1 || echo "")
  if [[ -n "$INITIAL_COMMIT" ]]; then
    BASE_BRANCH="$INITIAL_COMMIT"
  else
    BASE_BRANCH="HEAD~10"  # Last resort
  fi
fi

# Get changed files using merge-base for accurate comparison
MERGE_BASE=$(git merge-base "$BASE_BRANCH" HEAD 2>/dev/null || echo "$BASE_BRANCH")
CHANGED_FILES=$(git diff --name-only "$MERGE_BASE"..HEAD 2>/dev/null || git diff --name-only HEAD~5 2>/dev/null || echo "")

# Separate changed test files and changed source files
CHANGED_TEST_FILES=""
CHANGED_SOURCE_FILES=""
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  [[ ! -f "$file" ]] && continue
  # Match common test file patterns
  if [[ "$file" =~ (test_|_test\.|\.test\.|\.spec\.|tests/|__tests__/) ]]; then
    CHANGED_TEST_FILES="${CHANGED_TEST_FILES}${file}"$'\n'
  else
    # Source file - check if it's code (not config/docs)
    if [[ "$file" =~ \.(py|js|ts|jsx|tsx|go|rs|java|rb|php|cs|swift|kt)$ ]]; then
      CHANGED_SOURCE_FILES="${CHANGED_SOURCE_FILES}${file}"$'\n'
    fi
  fi
done <<< "$CHANGED_FILES"

# Trim trailing newlines
CHANGED_TEST_FILES=$(echo -n "$CHANGED_TEST_FILES" | sed '/^$/d')
CHANGED_SOURCE_FILES=$(echo -n "$CHANGED_SOURCE_FILES" | sed '/^$/d')

TESTS_RAN=false
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

# === Node.js: Use --findRelatedTests for source files (jest native feature) ===
if [[ -f package.json ]] && [[ -n "$CHANGED_SOURCE_FILES" ]]; then
  JS_SOURCE_FILES=$(echo "$CHANGED_SOURCE_FILES" | grep -E '\.(js|ts|jsx|tsx)$' || echo "")
  if [[ -n "$JS_SOURCE_FILES" ]]; then
    if [[ -f node_modules/.bin/jest ]] || command -v jest >/dev/null 2>&1; then
      echo "Finding and running tests related to changed source files..."
      FILES_ARRAY=$(echo "$JS_SOURCE_FILES" | tr '\n' ' ')
      if npx jest --findRelatedTests $FILES_ARRAY --passWithNoTests --maxWorkers=2; then
        echo -e "${GREEN}✅ Related Jest tests passed${NC}"
        TESTS_RAN=true
      else
        echo -e "${RED}❌ Related Jest tests failed${NC}"
        TEST_STATUS=1
        OVERALL_STATUS=1
        TESTS_RAN=true
      fi
    fi
  fi
fi

# === Python: Run tests in same package/directory as changed source files ===
if [[ -f pyproject.toml || -f pytest.ini || -d tests ]] && [[ -n "$CHANGED_SOURCE_FILES" ]]; then
  PY_SOURCE_FILES=$(echo "$CHANGED_SOURCE_FILES" | grep -E '\.py$' || echo "")
  if [[ -n "$PY_SOURCE_FILES" ]] && command -v pytest >/dev/null 2>&1; then
    # Find related test directories for changed source files
    RELATED_TEST_DIRS=""
    while IFS= read -r src_file; do
      [[ -z "$src_file" ]] && continue
      src_dir=$(dirname "$src_file")
      src_name=$(basename "$src_file" .py)
      # Look for test file in tests/ mirroring src structure, or in same dir
      if [[ -d "tests/$src_dir" ]]; then
        RELATED_TEST_DIRS="${RELATED_TEST_DIRS}tests/$src_dir"$'\n'
      elif [[ -d "tests" ]]; then
        # Try to find test_<name>.py in tests/
        potential_test=$(find tests -name "test_${src_name}.py" -o -name "${src_name}_test.py" 2>/dev/null | head -1)
        [[ -n "$potential_test" ]] && RELATED_TEST_DIRS="${RELATED_TEST_DIRS}${potential_test}"$'\n'
      fi
      # Also check for test file in same directory
      if [[ -f "${src_dir}/test_${src_name}.py" ]]; then
        RELATED_TEST_DIRS="${RELATED_TEST_DIRS}${src_dir}/test_${src_name}.py"$'\n'
      fi
    done <<< "$PY_SOURCE_FILES"

    RELATED_TEST_DIRS=$(echo -n "$RELATED_TEST_DIRS" | sed '/^$/d' | sort -u)
    if [[ -n "$RELATED_TEST_DIRS" ]]; then
      echo "Running tests related to changed Python source files..."
      FILES_ARRAY=$(echo "$RELATED_TEST_DIRS" | tr '\n' ' ')
      if pytest $FILES_ARRAY --maxfail=3 -q 2>/dev/null; then
        echo -e "${GREEN}✅ Related Python tests passed${NC}"
        TESTS_RAN=true
      else
        echo -e "${RED}❌ Related Python tests failed${NC}"
        TEST_STATUS=1
        OVERALL_STATUS=1
        TESTS_RAN=true
      fi
    fi
  fi
fi

# === Go: Run tests in packages containing changed source files ===
if [[ -f go.mod ]] && [[ -n "$CHANGED_SOURCE_FILES" ]]; then
  GO_SOURCE_FILES=$(echo "$CHANGED_SOURCE_FILES" | grep -E '\.go$' | grep -v '_test\.go$' || echo "")
  if [[ -n "$GO_SOURCE_FILES" ]]; then
    echo "Running tests for packages with changed Go source files..."
    PACKAGES=$(echo "$GO_SOURCE_FILES" | xargs -I{} dirname {} | sort -u | sed 's|^|./|' | tr '\n' ' ')
    if go test $PACKAGES -count=1 -v 2>/dev/null; then
      echo -e "${GREEN}✅ Related Go tests passed${NC}"
      TESTS_RAN=true
    else
      echo -e "${RED}❌ Related Go tests failed${NC}"
      TEST_STATUS=1
      OVERALL_STATUS=1
      TESTS_RAN=true
    fi
  fi
fi

# === Also run any changed test files directly ===
if [[ -n "$CHANGED_TEST_FILES" ]]; then
  echo "Also running directly changed test files..."
  echo "$CHANGED_TEST_FILES" | while read -r tf; do echo "  - $tf"; done

  # Python (pytest)
  if [[ -f pyproject.toml || -f pytest.ini || -d tests ]]; then
    PY_TEST_FILES=$(echo "$CHANGED_TEST_FILES" | grep -E '\.py$' || echo "")
    if [[ -n "$PY_TEST_FILES" ]] && command -v pytest >/dev/null 2>&1; then
      echo "Running pytest on changed test files..."
      FILES_ARRAY=$(echo "$PY_TEST_FILES" | tr '\n' ' ')
      if pytest $FILES_ARRAY --maxfail=3 -q; then
        echo -e "${GREEN}✅ Python tests passed${NC}"
        TESTS_RAN=true
      else
        echo -e "${RED}❌ Python tests failed${NC}"
        TEST_STATUS=1
        OVERALL_STATUS=1
        TESTS_RAN=true
      fi
    fi
  fi

  # Node.js (jest/vitest/mocha)
  if [[ -f package.json ]]; then
    JS_TEST_FILES=$(echo "$CHANGED_TEST_FILES" | grep -E '\.(js|ts|jsx|tsx)$' || echo "")
    if [[ -n "$JS_TEST_FILES" ]]; then
      echo "Running Node tests on changed test files..."
      FILES_ARRAY=$(echo "$JS_TEST_FILES" | tr '\n' ' ')

      # Try jest first
      if [[ -f node_modules/.bin/jest ]] || command -v jest >/dev/null 2>&1; then
        if npx jest $FILES_ARRAY --passWithNoTests --maxWorkers=2; then
          echo -e "${GREEN}✅ Jest tests passed${NC}"
          TESTS_RAN=true
        else
          echo -e "${RED}❌ Jest tests failed${NC}"
          TEST_STATUS=1
          OVERALL_STATUS=1
          TESTS_RAN=true
        fi
      # Try vitest
      elif [[ -f node_modules/.bin/vitest ]] || command -v vitest >/dev/null 2>&1; then
        if npx vitest run $FILES_ARRAY; then
          echo -e "${GREEN}✅ Vitest tests passed${NC}"
          TESTS_RAN=true
        else
          echo -e "${RED}❌ Vitest tests failed${NC}"
          TEST_STATUS=1
          OVERALL_STATUS=1
          TESTS_RAN=true
        fi
      # Fallback: npm test
      elif command -v npm >/dev/null 2>&1; then
        echo "Using npm test (may run full suite)..."
        if npm test --if-present -- --passWithNoTests 2>/dev/null || npm test --if-present 2>/dev/null; then
          echo -e "${GREEN}✅ npm test passed${NC}"
          TESTS_RAN=true
        else
          echo -e "${RED}❌ npm test failed${NC}"
          TEST_STATUS=1
          OVERALL_STATUS=1
          TESTS_RAN=true
        fi
      fi
    fi
  fi

  # Go
  if [[ -f go.mod ]]; then
    GO_TEST_FILES=$(echo "$CHANGED_TEST_FILES" | grep -E '_test\.go$' || echo "")
    if [[ -n "$GO_TEST_FILES" ]]; then
      echo "Running go test on changed test packages..."
      PACKAGES=$(echo "$GO_TEST_FILES" | xargs -I{} dirname {} | sort -u | sed 's|^|./|' | tr '\n' ' ')
      if go test $PACKAGES -count=1 -v; then
        echo -e "${GREEN}✅ Go tests passed${NC}"
        TESTS_RAN=true
      else
        echo -e "${RED}❌ Go tests failed${NC}"
        TEST_STATUS=1
        OVERALL_STATUS=1
        TESTS_RAN=true
      fi
    fi
  fi

  # Rust
  if [[ -f Cargo.toml ]]; then
    RUST_TEST_FILES=$(echo "$CHANGED_TEST_FILES" | grep -E '\.rs$' || echo "")
    if [[ -n "$RUST_TEST_FILES" ]]; then
      echo "Running cargo test..."
      if cargo test --quiet; then
        echo -e "${GREEN}✅ Rust tests passed${NC}"
        TESTS_RAN=true
      else
        echo -e "${RED}❌ Rust tests failed${NC}"
        TEST_STATUS=1
        OVERALL_STATUS=1
        TESTS_RAN=true
      fi
    fi
  fi
fi

# === Warning if no tests ran ===
if [[ "$TESTS_RAN" == "false" ]]; then
  if [[ -n "$CHANGED_SOURCE_FILES" ]]; then
    echo -e "${YELLOW}⚠️  Source files changed but no related tests found${NC}"
    echo "    Changed source files:"
    echo "$CHANGED_SOURCE_FILES" | head -5 | while read -r sf; do echo "      - $sf"; done
    echo -e "${YELLOW}    Consider adding tests or running full test suite manually${NC}"
  else
    echo "No source or test files changed - skipping test run"
  fi
  TEST_STATUS=0
fi

# === Summary ===
echo -e "\n${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Summary${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

[[ $LINT_STATUS -eq 0 ]] && echo -e "  Lint:       ${GREEN}✅ Passed${NC}" || echo -e "  Lint:       ${RED}❌ Failed${NC}"
[[ $TYPE_STATUS -eq 0 ]] && echo -e "  Type check: ${GREEN}✅ Passed${NC}" || echo -e "  Type check: ${RED}❌ Failed${NC}"
[[ $TEST_STATUS -eq 0 ]] && echo -e "  Tests:      ${GREEN}✅ Passed${NC}" || echo -e "  Tests:      ${RED}❌ Failed${NC}"

if [[ $OVERALL_STATUS -eq 0 ]]; then
  echo -e "\n${GREEN}✅ Lite preflight passed - ready to push${NC}"
  exit 0
else
  echo -e "\n${RED}❌ Lite preflight failed - fix issues before pushing${NC}"
  exit 1
fi
