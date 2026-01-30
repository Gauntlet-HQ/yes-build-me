#!/usr/bin/env bash
# Purpose : Apply opinionated code formatters across supported ecosystems.
# Why     : Keeps generated and hand-written code aligned with house style,
#           reducing noise in reviews and maintaining readability.
# How     : Detects active languages by files/configs, probes formatter tooling,
#           and runs best-available commands without failing when missing.
set -euo pipefail

# Formatters should operate from repository root for consistent include paths.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

# Quick command availability probe to avoid hard failures.
has() { command -v "$1" >/dev/null 2>&1; }

echo "== Format: Python =="
if [ -f pyproject.toml ] || rg -q '\\.py$' -n . 2>/dev/null; then
  if has black; then black . || true; else echo "black not found"; fi
  if has ruff; then ruff check --fix . || true; fi
fi

# Run Node/TypeScript formatters if package.json signals a JavaScript stack.
echo "== Format: Node/TS =="
if [ -f package.json ]; then
  if has pnpm && pnpm -s run | rg -q '^  format'; then pnpm format || true; \
  elif has yarn && yarn -s run | rg -q '^  format'; then yarn format || true; \
  elif has npm; then npm run format || true; fi
  if has prettier; then prettier -w . || true; fi
fi

# PHP formatting falls back to PHPCS-based tools.
echo "== Format: PHP =="
if [ -f composer.json ]; then
  if has php-cs-fixer; then php-cs-fixer fix || true; elif has phpcbf; then phpcbf || true; else echo "php-cs-fixer/phpcbf not found"; fi
fi

# Go relies on built-in `go fmt` to normalize files.
echo "== Format: Go =="
if [ -f go.mod ]; then
  go fmt ./... || true
fi

echo "== Format: Rust =="
if [ -f Cargo.toml ]; then
  if has cargo; then cargo fmt || true; fi
fi
