#!/usr/bin/env bash
# Purpose : Execute test suites across supported language stacks.
# Why     : Provides a single consistent entry point for `/tests` and CI gates,
#           reporting machine-readable metadata while tolerating missing tools.
# How     : Detects active ecosystems, delegates to best-known runners, and
#           aggregates structured results optionally returned as JSON.
set -euo pipefail

# run-tests.sh --json [--threshold <pct>]

# Flags configure output mode; threshold is reserved for future gating.
JSON=false
THRESHOLD=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=true; shift ;;
    --threshold) THRESHOLD="$2"; shift 2 ;;
    --help|-h) echo "Usage: $0 [--json] [--threshold <percent>]"; exit 0 ;;
    *) shift ;;
  esac
done

# Tests must run from repo root to respect config discovery.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

detected=()
results=()

# Run a command if the tool exists, capturing exit status for reporting.
run_cmd() {
  local name="$1"; shift
  local cmd=("$@")
  local ok=0 out err
  if command -v ${cmd[0]} >/dev/null 2>&1 || [[ ${cmd[0]} == npm || ${cmd[0]} == yarn || ${cmd[0]} == pnpm || ${cmd[0]} == bun ]]; then
    out="$({ set +e; "${cmd[@]}" 2> >(err=$(cat); typeset -p err >/dev/null) ; printf -v rc "%d" $?; set -e; echo "__RC__:$rc"; } 2>&1)"
    rc=$(printf '%s' "$out" | tail -n1 | sed 's/^__RC__://')
    out=$(printf '%s' "$out" | sed '$d')
    ok=$rc
  else
    ok=127
    err="not found: ${cmd[0]}"
  fi
  results+=("{\"name\":\"$name\",\"command\":\"$(printf '%q ' "${cmd[@]}")\",\"exit_code\":$ok}")
  return $ok
}

# Detect runners based on manifest files.
has_py=false; [[ -f pyproject.toml || -f pytest.ini || -d tests ]] && has_py=true
has_node=false; [[ -f package.json ]] && has_node=true
has_go=false; [[ -f go.mod ]] && has_go=true
has_rust=false; [[ -f Cargo.toml ]] && has_rust=true
has_maven=false; [[ -f pom.xml ]] && has_maven=true
has_gradle=false; [[ -f build.gradle || -f build.gradle.kts || -f gradlew ]] && has_gradle=true
has_php=false; [[ -f composer.json ]] && has_php=true

$has_py && detected+=("python-pytest")
$has_node && detected+=("node")
$has_go && detected+=("go")
$has_rust && detected+=("rust")
$has_maven && detected+=("maven")
$has_gradle && detected+=("gradle")
$has_php && detected+=("php")

# Run tests per env (best-effort, with coverage if common tools exist).
if $has_py; then
  # Prefer pytest if installed; use coverage if plugin available
  if command -v pytest >/dev/null 2>&1; then
    if python -c 'import pytest_cov' 2>/dev/null; then
      run_cmd pytest pytest --maxfail=1 --disable-warnings --cov --cov-report=term-missing
    else
      run_cmd pytest pytest --maxfail=1 --disable-warnings -q
    fi
  else
    results+=("{\"name\":\"pytest\",\"command\":\"pytest\",\"exit_code\":127}")
  fi
fi

if $has_node; then
  if command -v pnpm >/dev/null 2>&1; then run_cmd node-pnpm pnpm test --silent || true; fi
  if command -v yarn >/dev/null 2>&1; then run_cmd node-yarn yarn test --silent || true; fi
  if command -v npm >/dev/null 2>&1; then run_cmd node-npm npm test --silent || true; fi
  # Fallback: common test frameworks
  if command -v npx >/dev/null 2>&1; then
    if [ -f node_modules/.bin/jest ] || npx --yes jest --help >/dev/null 2>&1; then run_cmd node-jest npx --yes jest --coverage || true; fi
    if [ -f node_modules/.bin/vitest ] || npx --yes vitest --help >/dev/null 2>&1; then run_cmd node-vitest npx --yes vitest run || true; fi
    if [ -f node_modules/.bin/mocha ] || npx --yes mocha --help >/dev/null 2>&1; then run_cmd node-mocha npx --yes mocha || true; fi
  fi
fi

if $has_go; then
  run_cmd go go test ./...
fi

if $has_rust; then
  run_cmd rust cargo test --all --quiet
fi

if $has_maven; then
  run_cmd maven mvn -q -DskipITs=false test
fi

if $has_gradle; then
  if [[ -x ./gradlew ]]; then run_cmd gradle ./gradlew test --console=plain; else run_cmd gradle gradle test --console=plain; fi
fi

if $has_php; then
  # Common: phpunit or pest via composer scripts
  if command -v composer >/dev/null 2>&1; then
    if composer run -l 2>/dev/null | rg -q ' test'; then run_cmd php-composer composer test || true; fi
  fi
  if command -v phpunit >/dev/null 2>&1; then run_cmd phpunit phpunit || true; fi
  if command -v pest >/dev/null 2>&1; then run_cmd pest pest || true; fi
fi

# Output aggregated metadata for humans or automation.
detected_json=$(printf '%s\n' "${detected[@]}" | sed '/^$/d' | awk '{print "\""$0"\""}' | paste -sd, - | sed 's/^/[/' | sed 's/$/]/')
results_json=$(printf '%s\n' "${results[@]}" | paste -sd, - | sed 's/^/[/' | sed 's/$/]/')
out="{\n  \"detected\": $detected_json,\n  \"results\": $results_json\n}"

if $JSON; then
  printf '%s\n' "$out"
else
  echo "$out" | sed 's/,/\n  /g'
fi
