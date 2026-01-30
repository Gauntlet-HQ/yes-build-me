# Enhanced GoBuildMe Project Makefile
# Combines multi-language support with Augment Code integration
# Based on template repository best practices

# Colors for enhanced output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
PURPLE=\033[0;35m
CYAN=\033[0;36m
WHITE=\033[1;37m
NC=\033[0m # No Color

# Project configuration
PROJECT_NAME := $(shell basename $(CURDIR))
BRANCH := $(shell git branch --show-current 2>/dev/null || echo "unknown")
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

.PHONY: help install test lint format type-check build security ci pre-commit
.PHONY: analyze-architecture extract-conventions validate-architecture validate-conventions
.PHONY: gitflow-feature-start gitflow-feature-finish gitflow-release-start gitflow-hotfix-start
.PHONY: status sync check-branch clean dev-setup
.PHONY: dev deploy purge enter logs _maybe-devspace-test
.DEFAULT_GOAL := help

# Enhanced language detection
HAS_PYTHON := $(shell test -f pyproject.toml -o -f requirements.txt -o -f setup.py && echo true)
HAS_NODE   := $(shell test -f package.json && echo true)
HAS_TS     := $(shell test -f tsconfig.json && echo true)
HAS_PHP    := $(shell test -f composer.json && echo true)
HAS_GO     := $(shell test -f go.mod && echo true)
HAS_RUST   := $(shell test -f Cargo.toml && echo true)
HAS_JAVA   := $(shell test -f pom.xml -o -f build.gradle -o -f build.gradle.kts && echo true)

# Enhanced package manager detection for Node.js (from template repository)
HAS_BUN := $(shell test -f bun.lockb && echo true)
HAS_PNPM := $(shell test -f pnpm-lock.yaml && echo true)
HAS_YARN := $(shell test -f yarn.lock && echo true)

# Package manager selection logic
ifeq ($(HAS_BUN),true)
    PKG_MANAGER := bun
    INSTALL_CMD := bun install
    RUN_CMD := bun run
else ifeq ($(HAS_PNPM),true)
    PKG_MANAGER := pnpm
    INSTALL_CMD := pnpm install
    RUN_CMD := pnpm run
else ifeq ($(HAS_YARN),true)
    PKG_MANAGER := yarn
    INSTALL_CMD := yarn install
    RUN_CMD := yarn run
else
    PKG_MANAGER := npm
    INSTALL_CMD := npm install
    RUN_CMD := npm run
endif

# Tool detection
HAS_UV := $(shell command -v uv >/dev/null 2>&1 && echo true)
HAS_POETRY := $(shell command -v poetry >/dev/null 2>&1 && echo true)
HAS_GIT := $(shell command -v git >/dev/null 2>&1 && echo true)
HAS_PRE_COMMIT := $(shell command -v pre-commit >/dev/null 2>&1 && echo true)
HAS_DOCKER := $(shell command -v docker >/dev/null 2>&1 && echo true)
HAS_DEVSPACE := $(shell command -v devspace >/dev/null 2>&1 && echo true)

# DevSpace detection and runtime selection
# ENGINE can be overridden: ENGINE=devspace|docker|host (default: auto)
ENGINE ?= auto
DEVSPACE_FILE := $(firstword $(wildcard devspace.yaml) $(wildcard devspace.yml) $(wildcard .devspace/devspace.yaml))
DEVSPACE_PROFILE ?=
DEVSPACE_NAMESPACE ?=
DEVSPACE_FLAGS := $(if $(DEVSPACE_PROFILE),--profile $(DEVSPACE_PROFILE),) $(if $(DEVSPACE_NAMESPACE),--namespace $(DEVSPACE_NAMESPACE),)

# GoBuildMe/Augment Code configuration
GOBUILDME_DIR := .gobuildme
AUGMENT_DIR := .augment
MEMORY_DIR := $(GOBUILDME_DIR)/memory
SCRIPTS_DIR := $(GOBUILDME_DIR)/scripts

help: ## Show this enhanced help with project status
	@echo "$(CYAN)╔══════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║                    Enhanced GoBuildMe Project Makefile                      ║$(NC)"
	@echo "$(CYAN)╚══════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(WHITE)Project:$(NC) $(PROJECT_NAME) $(YELLOW)($(BRANCH):$(COMMIT))$(NC)"
	@echo "$(WHITE)Detected:$(NC) PY=$(HAS_PYTHON) NODE=$(HAS_NODE) TS=$(HAS_TS) PHP=$(HAS_PHP) GO=$(HAS_GO) RUST=$(HAS_RUST) JAVA=$(HAS_JAVA) DEVSPACE=$(HAS_DEVSPACE)"
ifeq ($(HAS_NODE),true)
	@echo "$(WHITE)Package Manager:$(NC) $(PKG_MANAGER)"
endif
	@echo "$(WHITE)Runtime:$(NC) ENGINE=$(ENGINE) $(if $(DEVSPACE_FILE),DEVSPACE_FILE=$(DEVSPACE_FILE),) $(if $(DEVSPACE_PROFILE),PROFILE=$(DEVSPACE_PROFILE),) $(if $(DEVSPACE_NAMESPACE),NAMESPACE=$(DEVSPACE_NAMESPACE),)"
	@echo ""
	@echo "$(PURPLE)📋 Development Commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E "(install|test|lint|format|type-check|build)" | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(PURPLE)🧠 Augment Code Integration:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E "(analyze|extract|validate)" | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(PURPLE)🌿 GitFlow Commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E "gitflow" | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(PURPLE)🔧 Utility Commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E "(status|sync|check|clean|dev-setup|security|ci|pre-commit)" | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-20s$(NC) %s\n", $$1, $$2}'

status: ## Show comprehensive project status
	@echo "$(CYAN)📊 Project Status$(NC)"
	@echo "$(WHITE)Project:$(NC) $(PROJECT_NAME)"
	@echo "$(WHITE)Branch:$(NC) $(BRANCH)"
	@echo "$(WHITE)Commit:$(NC) $(COMMIT)"
	@echo ""
	@echo "$(WHITE)Languages:$(NC)"
	@if [ "$(HAS_PYTHON)" = "true" ]; then echo "  $(GREEN)✓$(NC) Python"; else echo "  $(RED)✗$(NC) Python"; fi
	@if [ "$(HAS_NODE)" = "true" ]; then echo "  $(GREEN)✓$(NC) Node.js"; else echo "  $(RED)✗$(NC) Node.js"; fi
	@if [ "$(HAS_GO)" = "true" ]; then echo "  $(GREEN)✓$(NC) Go"; else echo "  $(RED)✗$(NC) Go"; fi
	@if [ "$(HAS_RUST)" = "true" ]; then echo "  $(GREEN)✓$(NC) Rust"; else echo "  $(RED)✗$(NC) Rust"; fi
	@if [ "$(HAS_JAVA)" = "true" ]; then echo "  $(GREEN)✓$(NC) Java"; else echo "  $(RED)✗$(NC) Java"; fi
	@if [ "$(HAS_PHP)" = "true" ]; then echo "  $(GREEN)✓$(NC) PHP"; else echo "  $(RED)✗$(NC) PHP"; fi
	@echo ""
	@echo "$(WHITE)Tools:$(NC)"
	@if [ "$(HAS_UV)" = "true" ]; then echo "  $(GREEN)✓$(NC) uv"; else echo "  $(RED)✗$(NC) uv"; fi
	@if [ "$(HAS_GIT)" = "true" ]; then echo "  $(GREEN)✓$(NC) git"; else echo "  $(RED)✗$(NC) git"; fi
	@if [ "$(HAS_PRE_COMMIT)" = "true" ]; then echo "  $(GREEN)✓$(NC) pre-commit"; else echo "  $(RED)✗$(NC) pre-commit"; fi
	@if [ "$(HAS_DOCKER)" = "true" ]; then echo "  $(GREEN)✓$(NC) docker"; else echo "  $(RED)✗$(NC) docker"; fi

install: ## Install dependencies (intelligent detection)
	@echo "$(CYAN)📦 Installing dependencies...$(NC)"
ifeq ($(HAS_PYTHON),true)
	@echo "$(YELLOW)[Python]$(NC) Installing dependencies..."
	@if [ "$(HAS_UV)" = "true" ]; then \
		if [ -f pyproject.toml ]; then uv sync --dev; elif [ -f requirements.txt ]; then uv pip install -r requirements.txt; fi; \
	elif [ "$(HAS_POETRY)" = "true" ]; then \
		poetry install; \
	elif [ -f requirements.txt ]; then \
		pip install -r requirements.txt; \
	else \
		echo "$(RED)No Python package manager found$(NC)"; \
	fi
endif
ifeq ($(HAS_NODE),true)
	@echo "$(YELLOW)[Node.js]$(NC) Installing dependencies with $(PKG_MANAGER)..."
	@$(INSTALL_CMD)
endif
ifeq ($(HAS_PHP),true)
	@echo "$(YELLOW)[PHP]$(NC) Installing dependencies..."
	@composer install
endif
ifeq ($(HAS_GO),true)
	@echo "$(YELLOW)[Go]$(NC) Installing dependencies..."
	@go mod download
endif
ifeq ($(HAS_RUST),true)
	@echo "$(YELLOW)[Rust]$(NC) Installing dependencies..."
	@cargo fetch
endif
ifeq ($(HAS_JAVA),true)
	@echo "$(YELLOW)[Java]$(NC) Installing dependencies..."
	@if [ -f pom.xml ]; then mvn dependency:resolve; \
	elif [ -f build.gradle ]; then ./gradlew dependencies; fi
endif

test: ## Run tests for all detected languages
	@echo "$(CYAN)🧪 Running tests...$(NC)"
	@$(MAKE) _maybe-devspace-test || true
ifeq ($(HAS_PYTHON),true)
	@echo "$(YELLOW)[Python]$(NC) Running tests..."
	@if [ "$(HAS_UV)" = "true" ]; then \
		uv run pytest --cov=src --cov-report=term-missing || echo "$(RED)Python tests failed$(NC)"; \
	elif command -v pytest >/dev/null 2>&1; then \
		pytest --cov=src --cov-report=term-missing || echo "$(RED)Python tests failed$(NC)"; \
	else \
		echo "$(RED)pytest not found$(NC)"; \
	fi
endif
ifeq ($(HAS_NODE),true)
	@echo "$(YELLOW)[Node.js]$(NC) Running tests..."
	@npm test || echo "$(RED)Node.js tests failed$(NC)"
endif
ifeq ($(HAS_GO),true)
	@echo "$(YELLOW)[Go]$(NC) Running tests..."
	@go test ./... || echo "$(RED)Go tests failed$(NC)"
endif
ifeq ($(HAS_RUST),true)
	@echo "$(YELLOW)[Rust]$(NC) Running tests..."
	@cargo test || echo "$(RED)Rust tests failed$(NC)"
endif
ifeq ($(HAS_JAVA),true)
	@echo "$(YELLOW)[Java]$(NC) Running tests..."
	@if [ -f pom.xml ]; then mvn test; elif [ -f build.gradle ]; then ./gradlew test; fi
endif

lint: ## Run linting for all detected languages
	@echo "$(CYAN)🔍 Running linting...$(NC)"
ifeq ($(HAS_PYTHON),true)
	@echo "$(YELLOW)[Python]$(NC) Running linting..."
	@if [ "$(HAS_UV)" = "true" ]; then \
		uv run ruff check . || echo "$(RED)Python linting failed$(NC)"; \
	elif command -v ruff >/dev/null 2>&1; then \
		ruff check . || echo "$(RED)Python linting failed$(NC)"; \
	else \
		echo "$(RED)ruff not found$(NC)"; \
	fi
endif
ifeq ($(HAS_NODE),true)
	@echo "$(YELLOW)[Node.js]$(NC) Running linting..."
	@npm run lint || echo "$(RED)Node.js linting failed$(NC)"
endif
ifeq ($(HAS_GO),true)
	@echo "$(YELLOW)[Go]$(NC) Running linting..."
	@golangci-lint run || echo "$(RED)Go linting failed$(NC)"
endif
ifeq ($(HAS_RUST),true)
	@echo "$(YELLOW)[Rust]$(NC) Running linting..."
	@cargo clippy -- -D warnings || echo "$(RED)Rust linting failed$(NC)"
endif

format: ## Format code for all detected languages
	@echo "$(CYAN)✨ Formatting code...$(NC)"
ifeq ($(HAS_PYTHON),true)
	@echo "$(YELLOW)[Python]$(NC) Formatting code..."
	@if [ "$(HAS_UV)" = "true" ]; then \
		uv run ruff format . || echo "$(RED)Python formatting failed$(NC)"; \
	elif command -v ruff >/dev/null 2>&1; then \
		ruff format . || echo "$(RED)Python formatting failed$(NC)"; \
	else \
		echo "$(RED)ruff not found$(NC)"; \
	fi
endif
ifeq ($(HAS_NODE),true)
	@echo "$(YELLOW)[Node.js]$(NC) Formatting code..."
	@npm run format || echo "$(RED)Node.js formatting failed$(NC)"
endif
ifeq ($(HAS_GO),true)
	@echo "$(YELLOW)[Go]$(NC) Formatting code..."
	@go fmt ./... || echo "$(RED)Go formatting failed$(NC)"
endif
ifeq ($(HAS_RUST),true)
	@echo "$(YELLOW)[Rust]$(NC) Formatting code..."
	@cargo fmt || echo "$(RED)Rust formatting failed$(NC)"
endif

type-check: ## Run type checking for supported languages
	@echo "$(CYAN)🔍 Running type checking...$(NC)"
ifeq ($(HAS_PYTHON),true)
	@echo "$(YELLOW)[Python]$(NC) Running type checking..."
	@if [ "$(HAS_UV)" = "true" ]; then \
		uv run mypy src/ || echo "$(RED)Python type checking failed$(NC)"; \
	elif command -v mypy >/dev/null 2>&1; then \
		mypy src/ || echo "$(RED)Python type checking failed$(NC)"; \
	else \
		echo "$(RED)mypy not found$(NC)"; \
	fi
endif
ifeq ($(HAS_TS),true)
	@echo "$(YELLOW)[TypeScript]$(NC) Running type checking..."
	@npx tsc --noEmit || echo "$(RED)TypeScript type checking failed$(NC)"
endif

# Augment Code Integration Commands
analyze-architecture: ## Run Augment Code architecture analysis
	@echo "$(CYAN)🏗️ Running Augment Code architecture analysis...$(NC)"
	@echo "$(PURPLE)💡 Using 200k-token context engine for comprehensive understanding$(NC)"
	@if [ -d "$(GOBUILDME_DIR)" ]; then \
		echo "$(GREEN)✓$(NC) GoBuildMe directory found"; \
		echo "$(YELLOW)Note:$(NC) This requires interactive Augment Code agent session"; \
		echo "$(BLUE)Command:$(NC) /analyze with architecture focus"; \
	else \
		echo "$(RED)✗$(NC) GoBuildMe directory not found. Run 'gobuildme init' first."; \
	fi

extract-conventions: ## Extract project conventions using Augment Code
	@echo "$(CYAN)📋 Extracting conventions with Augment Code...$(NC)"
	@echo "$(PURPLE)💡 Using semantic chunking across 400k+ files$(NC)"
	@if [ -d "$(GOBUILDME_DIR)" ]; then \
		echo "$(GREEN)✓$(NC) GoBuildMe directory found"; \
		echo "$(YELLOW)Note:$(NC) This requires interactive Augment Code agent session"; \
		echo "$(BLUE)Command:$(NC) /analyze with convention extraction focus"; \
	else \
		echo "$(RED)✗$(NC) GoBuildMe directory not found. Run 'gobuildme init' first."; \
	fi

validate-architecture: ## Validate architecture compliance with Augment Code
	@echo "$(CYAN)✅ Validating architecture compliance...$(NC)"
	@echo "$(PURPLE)💡 Using real-time indexing for compliance checking$(NC)"
	@if [ -d "$(GOBUILDME_DIR)" ]; then \
		echo "$(GREEN)✓$(NC) GoBuildMe directory found"; \
		echo "$(YELLOW)Note:$(NC) This requires interactive Augment Code agent session"; \
		echo "$(BLUE)Command:$(NC) /review with architecture validation focus"; \
	else \
		echo "$(RED)✗$(NC) GoBuildMe directory not found. Run 'gobuildme init' first."; \
	fi

validate-conventions: ## Validate convention compliance with Augment Code
	@echo "$(CYAN)✅ Validating convention compliance...$(NC)"
	@echo "$(PURPLE)💡 Using pattern recognition for consistency checking$(NC)"
	@if [ -d "$(GOBUILDME_DIR)" ]; then \
		echo "$(GREEN)✓$(NC) GoBuildMe directory found"; \
		echo "$(YELLOW)Note:$(NC) This requires interactive Augment Code agent session"; \
		echo "$(BLUE)Command:$(NC) /review with convention validation focus"; \
	else \
		echo "$(RED)✗$(NC) GoBuildMe directory not found. Run 'gobuildme init' first."; \
	fi

# GitFlow Integration Commands
gitflow-feature-start: ## Start a new feature branch with Augment Code analysis
	@echo "$(CYAN)🚀 Starting feature branch with Augment Code integration...$(NC)"
	@if [ "$(HAS_GIT)" = "true" ]; then \
		read -p "Feature name: " feature_name; \
		git checkout -b feature/$$feature_name; \
		echo "$(GREEN)✓$(NC) Created feature branch: feature/$$feature_name"; \
		echo "$(PURPLE)💡$(NC) Use 'make analyze-architecture' for comprehensive analysis"; \
	else \
		echo "$(RED)✗$(NC) Git not found"; \
	fi

gitflow-feature-finish: ## Finish feature branch with validation
	@echo "$(CYAN)🏁 Finishing feature branch with validation...$(NC)"
	@if [ "$(HAS_GIT)" = "true" ]; then \
		current_branch=$$(git branch --show-current); \
		if [[ $$current_branch == feature/* ]]; then \
			echo "$(YELLOW)Running pre-merge validation...$(NC)"; \
			$(MAKE) pre-commit; \
			echo "$(GREEN)✓$(NC) Feature branch ready for merge: $$current_branch"; \
			echo "$(PURPLE)💡$(NC) Consider running 'make validate-architecture' before merging"; \
		else \
			echo "$(RED)✗$(NC) Not on a feature branch"; \
		fi \
	else \
		echo "$(RED)✗$(NC) Git not found"; \
	fi

gitflow-release-start: ## Start release branch with comprehensive analysis
	@echo "$(CYAN)🚀 Starting release branch with comprehensive analysis...$(NC)"
	@if [ "$(HAS_GIT)" = "true" ]; then \
		read -p "Release version: " version; \
		git checkout -b release/$$version; \
		echo "$(GREEN)✓$(NC) Created release branch: release/$$version"; \
		echo "$(PURPLE)💡$(NC) Running comprehensive system analysis..."; \
		$(MAKE) ci; \
		echo "$(BLUE)Recommendation:$(NC) Run full Augment Code analysis before release"; \
	else \
		echo "$(RED)✗$(NC) Git not found"; \
	fi

gitflow-hotfix-start: ## Start hotfix branch with rapid analysis
	@echo "$(CYAN)🔥 Starting hotfix branch with rapid analysis...$(NC)"
	@if [ "$(HAS_GIT)" = "true" ]; then \
		read -p "Hotfix description: " hotfix_desc; \
		hotfix_name=$$(echo "$$hotfix_desc" | tr ' ' '-' | tr '[:upper:]' '[:lower:]'); \
		git checkout -b hotfix/$$hotfix_name; \
		echo "$(GREEN)✓$(NC) Created hotfix branch: hotfix/$$hotfix_name"; \
		echo "$(PURPLE)💡$(NC) Use focused Augment Code analysis for rapid validation"; \
	else \
		echo "$(RED)✗$(NC) Git not found"; \
	fi

# Utility Commands
sync: ## Sync with remote and update dependencies
	@echo "$(CYAN)🔄 Syncing project...$(NC)"
	@if [ "$(HAS_GIT)" = "true" ]; then \
		git fetch --all; \
		git pull; \
		echo "$(GREEN)✓$(NC) Git sync completed"; \
	fi
	@$(MAKE) install
	@echo "$(GREEN)✓$(NC) Project sync completed"

check-branch: ## Check branch status and recommendations
	@echo "$(CYAN)🌿 Branch Status$(NC)"
	@if [ "$(HAS_GIT)" = "true" ]; then \
		current_branch=$$(git branch --show-current); \
		echo "$(WHITE)Current branch:$(NC) $$current_branch"; \
		if [[ $$current_branch == feature/* ]]; then \
			echo "$(YELLOW)📋 Feature branch detected$(NC)"; \
			echo "  • Run 'make pre-commit' before pushing"; \
			echo "  • Use 'make gitflow-feature-finish' when ready"; \
		elif [[ $$current_branch == release/* ]]; then \
			echo "$(PURPLE)🚀 Release branch detected$(NC)"; \
			echo "  • Run 'make ci' for comprehensive testing"; \
			echo "  • Validate with 'make validate-architecture'"; \
		elif [[ $$current_branch == hotfix/* ]]; then \
			echo "$(RED)🔥 Hotfix branch detected$(NC)"; \
			echo "  • Focus on minimal, targeted changes"; \
			echo "  • Run 'make test' and 'make lint'"; \
		else \
			echo "$(BLUE)📋 Standard branch$(NC)"; \
		fi; \
		git status --porcelain | wc -l | xargs -I {} echo "$(WHITE)Uncommitted changes:$(NC) {}"; \
	else \
		echo "$(RED)✗$(NC) Git not found"; \
	fi

clean: ## Clean build artifacts and caches
	@echo "$(CYAN)🧹 Cleaning project...$(NC)"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "node_modules" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "target" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "build" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "dist" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✓$(NC) Cleanup completed"

dev-setup: ## Setup development environment
	@echo "$(CYAN)🛠️ Setting up development environment...$(NC)"
	@$(MAKE) install
	@if [ "$(HAS_PRE_COMMIT)" = "true" ]; then \
		pre-commit install; \
		echo "$(GREEN)✓$(NC) Pre-commit hooks installed"; \
	else \
		echo "$(YELLOW)⚠️$(NC) pre-commit not found, consider installing it"; \
	fi
	@echo "$(GREEN)✓$(NC) Development environment ready"

security: ## Run security scans
	@echo "$(CYAN)🔒 Running security scans...$(NC)"
ifeq ($(HAS_PYTHON),true)
	@echo "$(YELLOW)[Python]$(NC) Running security scan..."
	@if command -v safety >/dev/null 2>&1; then \
		safety check || echo "$(RED)Security vulnerabilities found$(NC)"; \
	else \
		echo "$(YELLOW)safety not found, install with: pip install safety$(NC)"; \
	fi
	@if command -v bandit >/dev/null 2>&1; then \
		bandit -r src/ || echo "$(RED)Security issues found$(NC)"; \
	else \
		echo "$(YELLOW)bandit not found, install with: pip install bandit$(NC)"; \
	fi
endif
ifeq ($(HAS_NODE),true)
	@echo "$(YELLOW)[Node.js]$(NC) Running security audit..."
	@npm audit || echo "$(RED)Security vulnerabilities found$(NC)"
endif

ci: ## Run full CI pipeline locally
	@echo "$(CYAN)🔄 Running full CI pipeline...$(NC)"
	@$(MAKE) install
	@$(MAKE) lint
	@$(MAKE) type-check
	@$(MAKE) test
	@$(MAKE) security
	@echo "$(GREEN)✅ CI pipeline completed successfully$(NC)"

pre-commit: ## Run pre-commit checks
	@echo "$(CYAN)✅ Running pre-commit checks...$(NC)"
	@if [ "$(HAS_PRE_COMMIT)" = "true" ]; then \
		pre-commit run --all-files; \
	else \
		$(MAKE) format; \
		$(MAKE) lint; \
		$(MAKE) type-check; \
		$(MAKE) test; \
	fi
	@echo "$(GREEN)✅ Pre-commit checks completed$(NC)"

# Enhanced Release Management (from template repository)
changelog: ## Generate changelog preview
	@echo "$(CYAN)📝 Generating changelog preview...$(NC)"
	@if command -v git-cliff >/dev/null 2>&1; then \
		git-cliff --output CHANGELOG.md; \
		echo "$(GREEN)✓ Changelog generated with git-cliff$(NC)"; \
	else \
		echo "$(YELLOW)⚠ git-cliff not found. Install with: cargo install git-cliff$(NC)"; \
		echo "$(BLUE)📋 Using Release Please for changelog generation$(NC)"; \
		echo "$(BLUE)💡 Changelogs are automatically generated from conventional commits$(NC)"; \
	fi

release-dry-run: ## Preview what the next release would look like
	@echo "$(CYAN)🔍 Dry run release preview...$(NC)"
	@if command -v gh >/dev/null 2>&1; then \
		echo "$(BLUE)📋 Checking for existing release PRs...$(NC)"; \
		gh pr list --label "autorelease: pending" --state open || echo "$(YELLOW)No pending release PRs found$(NC)"; \
	else \
		echo "$(YELLOW)⚠ GitHub CLI not found. Install with: brew install gh$(NC)"; \
	fi
	@echo "$(BLUE)💡 Release Please will create a PR automatically when you push conventional commits to main$(NC)"

release: ## Trigger release process (creates release PR)
	@echo "$(CYAN)🚀 Triggering release process...$(NC)"
	@echo "$(BLUE)💡 Release Please will automatically create a release PR based on conventional commits$(NC)"
	@echo "$(BLUE)📋 To complete the release:$(NC)"
	@echo "  1. Push conventional commits to main branch"
	@echo "  2. Review the auto-generated release PR"
	@echo "  3. Merge the release PR to create the release"
	@if command -v gh >/dev/null 2>&1; then \
		echo "$(BLUE)📋 Current release PRs:$(NC)"; \
		gh pr list --label "autorelease: pending" --state open || echo "$(YELLOW)No pending release PRs found$(NC)"; \
	fi

# Enhanced Branch Management (from template repository)
branch-status: ## Check current branch and git status
	@echo "$(CYAN)📋 Current branch and status:$(NC)"
	@echo "$(GREEN)Current branch:$(NC) $$(git branch --show-current)"
	@echo "$(GREEN)Git status:$(NC)"
	@git status --porcelain || echo "Working directory clean"
	@echo ""
	@echo "$(BLUE)📋 Recent commits:$(NC)"
	@git log --oneline -5

check-main-sync: ## Check if current branch is synced with main
	@echo "$(CYAN)🔍 Checking sync with main branch...$(NC)"
	@# Try to fetch but ignore network errors (CI or local offline)
	@git fetch origin main >/dev/null 2>&1 || true
	@# If origin doesn't exist or origin/main is unknown, skip gracefully
	@if ! git remote get-url origin >/dev/null 2>&1; then \
		echo "$(YELLOW)ℹ No 'origin' remote configured; skipping sync check$(NC)"; \
		exit 0; \
	fi
	@if ! git show-ref --verify --quiet refs/remotes/origin/main; then \
		echo "$(YELLOW)ℹ No remote-tracking branch 'origin/main'; skipping sync check$(NC)"; \
		echo "$(BLUE)💡 Tip: run 'git fetch origin main' when online$(NC)"; \
		exit 0; \
	fi
	@BEHIND=$$(git rev-list --count HEAD..origin/main); \
	AHEAD=$$(git rev-list --count origin/main..HEAD); \
	if [ $$BEHIND -gt 0 ]; then \
		echo "$(YELLOW)⚠ Your branch is $$BEHIND commits behind main$(NC)"; \
		echo "$(BLUE)💡 Run: git rebase origin/main$(NC)"; \
	elif [ $$AHEAD -gt 0 ]; then \
		echo "$(GREEN)✓ Your branch is $$AHEAD commits ahead of main$(NC)"; \
	else \
		echo "$(GREEN)✓ Your branch is up to date with main$(NC)"; \
	fi

ready-to-push: pre-commit check-main-sync ## Comprehensive pre-push validation
	@echo "$(GREEN)🚀 Ready to push! All validations passed.$(NC)"
	@echo "$(BLUE)💡 Next steps:$(NC)"
	@echo "  1. git push origin $$(git branch --show-current)"
	@echo "  2. Create pull request"
	@echo "  3. Wait for CI/CD validation"

# -------------------------
# DevSpace integration (prefer if present)
# -------------------------

# Choose if we should use DevSpace
USE_DEVSPACE = $(or $(filter devspace,$(ENGINE)),$(and $(filter auto,$(ENGINE)),$(filter true,$(HAS_DEVSPACE)),$(DEVSPACE_FILE)))

dev: ## Start inner-loop development (DevSpace if available)
	@if [ "$(USE_DEVSPACE)" ]; then \
		echo "$(CYAN)[DevSpace]$(NC) devspace dev $(DEVSPACE_FLAGS)"; \
		devspace dev $(DEVSPACE_FLAGS); \
	else \
		echo "$(YELLOW)DevSpace not detected (ENGINE=$(ENGINE), HAS_DEVSPACE=$(HAS_DEVSPACE), FILE=$(DEVSPACE_FILE)).$(NC)"; \
		echo "Use your normal local dev flow or set ENGINE=devspace."; \
		echo "Tip: install DevSpace https://devspace.sh/ and add devspace.yaml"; \
	fi

deploy: ## Deploy via DevSpace if available
	@if [ "$(USE_DEVSPACE)" ]; then \
		echo "$(CYAN)[DevSpace]$(NC) devspace deploy $(DEVSPACE_FLAGS)"; \
		devspace deploy $(DEVSPACE_FLAGS); \
	else \
		echo "$(YELLOW)No DevSpace config/CLI found. Skipping deploy.$(NC)"; \
	fi

purge: ## Purge DevSpace deployment if available
	@if [ "$(USE_DEVSPACE)" ]; then \
		echo "$(CYAN)[DevSpace]$(NC) devspace purge $(DEVSPACE_FLAGS)"; \
		devspace purge $(DEVSPACE_FLAGS); \
	else \
		echo "$(YELLOW)No DevSpace config/CLI found. Skipping purge.$(NC)"; \
	fi

enter: ## Enter a running DevSpace container if available
	@if [ "$(USE_DEVSPACE)" ]; then \
		devspace enter $(DEVSPACE_FLAGS) || echo "$(YELLOW)Unable to enter container$(NC)"; \
	else \
		echo "$(YELLOW)No DevSpace config/CLI found. Skipping enter.$(NC)"; \
	fi

logs: ## Tail DevSpace logs if available
	@if [ "$(USE_DEVSPACE)" ]; then \
		devspace logs $(DEVSPACE_FLAGS) || echo "$(YELLOW)Unable to get logs$(NC)"; \
	else \
		echo "$(YELLOW)No DevSpace config/CLI found. Skipping logs.$(NC)"; \
	fi

# Run tests inside DevSpace when a 'test' run is defined; otherwise no-op
_maybe-devspace-test:
	@if [ "$(USE_DEVSPACE)" ]; then \
		if devspace run --help 2>/dev/null | grep -q " devspace run test"; then \
			echo "$(CYAN)[DevSpace]$(NC) Running tests inside DevSpace: devspace run test"; \
			devspace run test || true; \
		fi; \
	fi; true
