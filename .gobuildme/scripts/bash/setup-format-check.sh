#!/usr/bin/env bash
# Purpose : Generate a workflow dedicated to enforcing format checks in CI.
# Why     : Keeps formatting consistent on pull requests without running full
#           auto-formatting jobs.
# How     : Writes a minimal GitHub Actions workflow that executes the shared
#           `format-check.sh` script.
set -euo pipefail

# Create workflow relative to repo root.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"
mkdir -p .github/workflows

# Emit the format check workflow on push/PR events.
cat > .github/workflows/format-check.yml <<'YAML'
name: Format Check

on:
  pull_request:
  push:
    branches: [ main ]

jobs:
  fmt:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run non-mutating format checks
        run: .gobuildme/scripts/bash/format-check.sh
YAML

echo "Wrote .github/workflows/format-check.yml"
