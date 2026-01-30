#!/usr/bin/env bash
# Purpose : Run static/type analysis across supported languages.
# Why     : Surfaces type regressions early, mirroring `/tests` but for
#           semantic checks.
# How     : Detects language manifests, runs per-ecosystem tools, and logs
#           when tooling is unavailable instead of failing hard.
set -euo pipefail

# Always evaluate from repository root for consistent include paths.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

# Helper for tool detection to keep conditions readable.
has() { command -v "$1" >/dev/null 2>&1; }

echo "== Type Check: Python =="
if [ -f pyproject.toml ] || rg -q '\\.py$' -n . 2>/dev/null; then
  if has mypy; then mypy . || true; elif has pyright; then pyright || true; else echo "mypy/pyright not found"; fi
fi

# Run Node/TypeScript type checks via package scripts when available.
echo "== Type Check: TypeScript =="
if [ -f tsconfig.json ] || rg -q '\\.ts$|\\.tsx$' -n . 2>/dev/null; then
  if has pnpm && pnpm -s run | rg -q '^  type-check'; then pnpm type-check || true; \
  elif has yarn && yarn -s run | rg -q '^  type-check'; then yarn type-check || true; \
  elif has npm; then npm run type-check || npx tsc --noEmit --skipLibCheck || true; fi
fi

# PHP static analyzers (phpstan/psalm) flagged here.
echo "== Type Check: PHP =="
if [ -f composer.json ]; then
  if has phpstan; then phpstan analyse || true; elif has psalm; then psalm || true; else echo "phpstan/psalm not found"; fi
fi

# Go vet covers structural issues; treat as best-effort.
echo "== Type Check: Go =="
if [ -f go.mod ]; then
  go vet ./... || true
fi

echo "== Type Check: Rust =="
if [ -f Cargo.toml ]; then
  cargo check --quiet || true
fi

echo "== Type Check: Java =="
if [ -f pom.xml ]; then mvn -q -DskipTests verify || true; fi
if [ -f build.gradle ] || [ -f build.gradle.kts ]; then ./gradlew check --console=plain || true; fi
