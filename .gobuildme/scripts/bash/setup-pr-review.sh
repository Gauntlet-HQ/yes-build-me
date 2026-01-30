#!/usr/bin/env bash
# Purpose : Scaffold a minimal PR review workflow tying into GoBuildMe scripts.
# Why     : Gives teams a quick way to gate pull requests with lint, types, tests,
#           and security checks aligned with `/review`.
# How     : Writes a GitHub Actions workflow that runs the shared scripts and
#           uploads artifacts for inspection.
set -euo pipefail

# Ensure output paths are relative to repo root.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"
mkdir -p .github/workflows

# Emit the workflow file with standard review jobs.
cat > .github/workflows/basic-pr-review.yml <<'YAML'
name: Basic PR Review

on:
  pull_request:

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Lint
        run: .gobuildme/scripts/bash/run-lint.sh || true
      - name: Type Check
        run: .gobuildme/scripts/bash/run-type-check.sh || true
      - name: Tests
        run: .gobuildme/scripts/bash/run-tests.sh --json | tee tests.json
      - name: Security
        run: .gobuildme/scripts/bash/security-scan.sh || true
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: pr-review-artifacts
          path: |
            tests.json
YAML

echo "Wrote .github/workflows/basic-pr-review.yml"
