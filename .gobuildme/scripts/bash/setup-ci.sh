#!/usr/bin/env bash
# Purpose : Scaffold a baseline CI workflow that calls into GoBuildMe scripts.
# Why     : Provides teams an immediate pipeline that runs lint, type checks,
#           tests, and security scans aligned with the SDD workflow.
# How     : Generates a GitHub Actions YAML under .github/workflows and copies
#           a Makefile template when missing.
set -euo pipefail

# Operate from repo root so generated files land in expected locations.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

target=".github/workflows/tests.yml"
mkdir -p .github/workflows

# Write the opinionated workflow capturing multi-language setup and script calls.
cat > "$target" <<'YAML'
name: Tests

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Python
      - name: Set up Python
        if: ${{ hashFiles('pyproject.toml', 'requirements.txt') != '' }}
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Install Python deps
        if: ${{ hashFiles('pyproject.toml', 'requirements.txt') != '' }}
        run: |
          python -m pip install --upgrade pip
          if [ -f pyproject.toml ]; then pip install . || true; fi
          if [ -f requirements.txt ]; then pip install -r requirements.txt || true; fi

      # Node/TS
      - name: Set up Node
        if: ${{ hashFiles('package.json') != '' }}
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - name: Install Node deps
        if: ${{ hashFiles('package.json') != '' }}
        run: |
          if [ -f pnpm-lock.yaml ]; then corepack enable && pnpm i; \
          elif [ -f yarn.lock ]; then corepack enable && yarn install; \
          else npm ci; fi

      # PHP
      - name: Set up PHP
        if: ${{ hashFiles('composer.json') != '' }}
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          tools: composer
      - name: Install PHP deps
        if: ${{ hashFiles('composer.json') != '' }}
        run: composer install --no-interaction --prefer-dist

      # Go
      - name: Set up Go
        if: ${{ hashFiles('go.mod') != '' }}
        uses: actions/setup-go@v5
        with:
          go-version: '1.22'

      # Rust
      - name: Set up Rust
        if: ${{ hashFiles('Cargo.toml') != '' }}
        uses: dtolnay/rust-toolchain@stable

      # Java
      - name: Set up Java
        if: ${{ hashFiles('pom.xml', 'build.gradle', 'build.gradle.kts') != '' }}
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'

      # Run checks via repo scripts
      - name: Lint
        run: .gobuildme/scripts/bash/run-lint.sh || true
      - name: Type Check
        run: .gobuildme/scripts/bash/run-type-check.sh || true
      - name: Tests
        run: .gobuildme/scripts/bash/run-tests.sh --json | tee tests.json
      - name: Security Scan
        run: .gobuildme/scripts/bash/security-scan.sh || true
YAML

echo "Wrote $target"

# Copy Makefile.example if no Makefile exists
if [ ! -f Makefile ] && [ -f templates/Makefile.example ]; then
  cp templates/Makefile.example Makefile
  echo "Copied templates/Makefile.example -> Makefile"
fi
