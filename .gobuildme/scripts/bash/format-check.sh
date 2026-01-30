#!/usr/bin/env bash
# Purpose : Verify formatting without mutating files, for CI and `/review`.
# Why     : Ensures contributors run formatters locally before pushing to avoid
#           noisy diffs during review.
# How     : Runs language-aware formatter checks and accumulates a combined
#           exit code.
set -euo pipefail

# Resolve repo root to make relative globs predictable.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

rc=0
if command -v black >/dev/null 2>&1 && rg -q '\\.py$' -n . 2>/dev/null; then black --check . || rc=1; fi
if command -v ruff  >/dev/null 2>&1; then ruff check . || rc=1; fi
if command -v prettier >/dev/null 2>&1 && [ -f package.json ]; then prettier -c . || rc=1; fi
if [ -f Cargo.toml ] && command -v cargo >/dev/null 2>&1; then cargo fmt --check || rc=1; fi
exit $rc
