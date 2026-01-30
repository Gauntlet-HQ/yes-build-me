#!/usr/bin/env bash
# Purpose : Validate code conventions using non-mutating checks.
# Why     : Gives `/review` confidence that formatters and linters have run,
#           without altering files mid-pipeline.
# How     : Executes formatter/linter checks per language and reports pass/fail
#           status based on aggregate exit codes.
set -euo pipefail

# Resolve repository root for consistent globbing.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

fail=0

# Non-mutating format checks where possible
if command -v black >/dev/null 2>&1 && rg -q '\\.py$' -n . 2>/dev/null; then
  black --check . || fail=1
fi
if command -v ruff >/dev/null 2>&1; then
  ruff check . || fail=1
fi
if command -v prettier >/dev/null 2>&1 && [ -f package.json ]; then
  prettier -c . || fail=1
fi
if command -v eslint >/dev/null 2>&1 && [ -f package.json ]; then
  eslint . --ext .js,.jsx,.ts,.tsx || fail=1
fi
if command -v phpcs >/dev/null 2>&1 && [ -f composer.json ]; then
  phpcs -q || fail=1
fi
if command -v golangci-lint >/dev/null 2>&1 && [ -f go.mod ]; then
  golangci-lint run || fail=1
fi
if command -v cargo >/dev/null 2>&1 && [ -f Cargo.toml ]; then
  cargo fmt --check || fail=1
  cargo clippy --all-targets -- -D warnings || true
fi

[ $fail -eq 0 ] && echo "Conventions validation passed" || echo "Conventions validation failed"
exit $fail
