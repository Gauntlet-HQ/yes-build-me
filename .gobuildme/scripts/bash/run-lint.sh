#!/usr/bin/env bash
# Purpose : Run lint suites across the ecosystems detected in the repo.
# Why     : Keeps code quality issues visible during `/review` and PR checks.
# How     : Detects manifests, runs best-known linters per language, and logs
#           when tooling is unavailable.
set -euo pipefail

# Linting should occur from the repo root for consistent configuration lookup.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

# Lightweight helper for checking tool availability.
has() { command -v "$1" >/dev/null 2>&1; }

echo "== Lint: Python =="
if [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -d tests ] || rg -q '\\.py$' -n . 2>/dev/null; then
  if has ruff; then ruff check . || true; else echo "ruff not found"; fi
fi

echo "== Lint: Node/TS =="
if [ -f package.json ]; then
  if has pnpm && pnpm -s run | rg -q '^  lint'; then pnpm lint || true; \
  elif has yarn && yarn -s run | rg -q '^  lint'; then yarn lint || true; \
  elif has npm; then npm run lint || true; fi
  if has eslint; then eslint . --ext .js,.jsx,.ts,.tsx || true; fi
fi

echo "== Lint: PHP =="
if [ -f composer.json ]; then
  if has phpcs; then phpcs -q || true; else echo "phpcs not found"; fi
fi

echo "== Lint: Go =="
if [ -f go.mod ]; then
  if has golangci-lint; then golangci-lint run || true; else echo "golangci-lint not found"; fi
fi

echo "== Lint: Rust =="
if [ -f Cargo.toml ]; then
  if has cargo; then cargo clippy --all-targets --quiet || true; fi
fi

echo "== Lint: Java =="
if [ -f pom.xml ] || [ -f build.gradle ] || [ -f build.gradle.kts ]; then
  echo "(configure checkstyle/spotless in your build for full linting)"
fi
