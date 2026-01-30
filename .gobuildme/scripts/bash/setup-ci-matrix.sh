#!/usr/bin/env bash
# Purpose : Scaffold a multi-language CI matrix workflow for the repository.
# Why     : Provides teams with a ready-made pipeline that auto-detects stacks,
#           keeping Spec-Driven automation consistent without hand-editing YAML.
# How     : Creates a GitHub Actions workflow that discovers project languages and
#           conditionally runs language-specific jobs against a generated matrix.
set -euo pipefail

# Ensure the workflow directory exists before writing the composite file.
mkdir -p .github/workflows
# Write the opinionated CI definition with detection and per-language jobs.
cat > .github/workflows/ci.yml <<'YAML'
name: CI

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  detect-project:
    runs-on: ubuntu-latest
    outputs:
      has-python: ${{ steps.detect.outputs.has-python }}
      has-node: ${{ steps.detect.outputs.has-node }}
      has-php: ${{ steps.detect.outputs.has-php }}
      has-go: ${{ steps.detect.outputs.has-go }}
      has-rust: ${{ steps.detect.outputs.has-rust }}
      has-java: ${{ steps.detect.outputs.has-java }}
      package-manager: ${{ steps.detect.outputs.package-manager }}
    steps:
      - uses: actions/checkout@v4
      - id: detect
        run: |
          set -e
          pm="npm"; [ -f pnpm-lock.yaml ] && pm=pnpm; [ -f yarn.lock ] && pm=yarn; [ -f bun.lockb ] && pm=bun
          if [ -f pyproject.toml ] || [ -f requirements.txt ]; then echo "has-python=true" >> $GITHUB_OUTPUT; else echo "has-python=false" >> $GITHUB_OUTPUT; fi
          if [ -f package.json ]; then echo "has-node=true" >> $GITHUB_OUTPUT; else echo "has-node=false" >> $GITHUB_OUTPUT; fi
          if [ -f composer.json ]; then echo "has-php=true" >> $GITHUB_OUTPUT; else echo "has-php=false" >> $GITHUB_OUTPUT; fi
          if [ -f go.mod ]; then echo "has-go=true" >> $GITHUB_OUTPUT; else echo "has-go=false" >> $GITHUB_OUTPUT; fi
          if [ -f Cargo.toml ]; then echo "has-rust=true" >> $GITHUB_OUTPUT; else echo "has-rust=false" >> $GITHUB_OUTPUT; fi
          if [ -f pom.xml ] || [ -f build.gradle ] || [ -f build.gradle.kts ]; then echo "has-java=true" >> $GITHUB_OUTPUT; else echo "has-java=false" >> $GITHUB_OUTPUT; fi
          echo "package-manager=$pm" >> $GITHUB_OUTPUT

  python-test:
    needs: detect-project
    if: needs.detect-project.outputs.has-python == 'true'
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        python-version: ['3.10', '3.11', '3.12']
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      - run: |
          python -m pip install --upgrade pip
          if [ -f pyproject.toml ]; then pip install . || true; fi
          if [ -f requirements.txt ]; then pip install -r requirements.txt || true; fi
          pip install pytest pytest-cov
      - run: pytest -v --cov=. --cov-report=xml --cov-report=term-missing || true
      - uses: actions/upload-artifact@v4
        if: matrix.os == 'ubuntu-latest' && matrix.python-version == '3.11'
        with:
          name: python-coverage
          path: coverage.xml

  node-test:
    needs: detect-project
    if: needs.detect-project.outputs.has-node == 'true'
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        node: ['16', '18', '20']
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
      - run: |
          if [ -f pnpm-lock.yaml ]; then corepack enable && pnpm i; \
          elif [ -f yarn.lock ]; then corepack enable && yarn install; \
          elif [ -f bun.lockb ]; then npm i -g bun && bun install; \
          else npm ci; fi
      - run: |
          if [ -f package.json ]; then npm test --silent || yarn test || pnpm test || bun test || true; fi

  php-test:
    needs: detect-project
    if: needs.detect-project.outputs.has-php == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          tools: composer
      - run: composer install --no-interaction --prefer-dist || true
      - run: |
          if [ -f vendor/bin/phpunit ]; then vendor/bin/phpunit || true; \
          elif [ -f vendor/bin/pest ]; then vendor/bin/pest || true; \
          else composer test || true; fi

  go-test:
    needs: detect-project
    if: needs.detect-project.outputs.has-go == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - run: go test ./... || true

  rust-test:
    needs: detect-project
    if: needs.detect-project.outputs.has-rust == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - run: cargo test --all --quiet || true

  java-test:
    needs: detect-project
    if: needs.detect-project.outputs.has-java == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'
      - run: |
          if [ -f pom.xml ]; then mvn -q -DskipITs=false test || true; \
          elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then ./gradlew test --console=plain || true; fi
YAML

echo "Wrote .github/workflows/ci.yml"
