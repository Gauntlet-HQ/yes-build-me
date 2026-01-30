#!/usr/bin/env bash
# Purpose: Common functions for QA commands (architecture integration, etc.)
# Why: Centralizes architecture integration and QA-specific utilities
# How: Provides reusable functions for all QA scripts

# Source the main common.sh for repo utilities
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/common.sh" ]; then
    echo "Error: common.sh not found in $SCRIPT_DIR"
    echo "Please ensure GoBuildMe is properly installed"
    exit 1
fi

source "$SCRIPT_DIR/common.sh"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Architecture Integration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_and_generate_architecture() {
    # Use get_architecture_dirs() for monorepo/workspace support
    # Returns architecture directories in search order: module → root
    local gbm_root=$(get_gobuildme_root)
    local scripts_dir="${gbm_root:-.}/.gobuildme/scripts/bash"
    local arch_dirs=($(get_architecture_dirs))
    local arch_file=""

    # Find first existing technology-stack.md in search order
    for dir in "${arch_dirs[@]}"; do
        if [ -f "$dir/technology-stack.md" ]; then
            arch_file="$dir/technology-stack.md"
            break
        fi
    done

    # Fallback to legacy path if no architecture dirs found
    if [ -z "$arch_file" ]; then
        if [ -n "$gbm_root" ]; then
            arch_file="$gbm_root/.gobuildme/docs/technical/architecture/technology-stack.md"
        else
            arch_file=".gobuildme/docs/technical/architecture/technology-stack.md"
        fi
    fi

    # Check if architecture docs exist
    if [ ! -f "$arch_file" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📐 Architecture documentation not found."
        echo "   Generating architecture for better test generation..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        # Run architecture command
        if [ -f "$scripts_dir/analyze-architecture.sh" ]; then
            if ! bash "$scripts_dir/analyze-architecture.sh"; then
                # Auto-generation failed - show helpful error
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "❌ Error: Architecture generation failed"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                echo "   QA commands require architecture documentation to:"
                echo "   - Understand your tech stack (language, framework, database)"
                echo "   - Generate appropriate test scaffolds (PHPUnit vs pytest vs Jest)"
                echo "   - Create correct fixture patterns"
                echo "   - Provide accurate test recommendations"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🎯 Action Required: Run /gbm.architecture manually"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                echo "   This will analyze your codebase and create necessary docs."
                echo "   Then retry the QA command."
                echo ""
                return 1
            fi
        else
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "⚠️  Error: Architecture script not found"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "   Expected location: $scripts_dir/analyze-architecture.sh"
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🎯 Action Required: Ensure GoBuildMe is properly installed"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "   Run: gobuildme init"
            echo ""
            return 1
        fi
        
        echo ""
        echo "✓ Architecture documentation generated"
        echo ""
        return 0
    fi
    
    # Check if architecture is outdated (>7 days)
    if [ -f "$arch_file" ]; then
        # Get file modification time (cross-platform)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            local arch_date=$(stat -f '%m' "$arch_file" 2>/dev/null || echo "0")
        else
            # Linux
            local arch_date=$(stat -c '%Y' "$arch_file" 2>/dev/null || echo "0")
        fi
        
        local current_date=$(date +%s)
        local days_old=$(( (current_date - arch_date) / 86400 ))
        
        if [ $days_old -gt 7 ]; then
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📐 Architecture documentation is $days_old days old."
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

            # Check if running in interactive shell
            if [ -t 0 ]; then
                # Interactive shell - ask user
                read -p "   Refresh architecture? [Y/n] " refresh
            else
                # Non-interactive (CI/CD) - default to yes
                refresh="y"
                echo "   Refresh architecture? [Y/n] y (auto-refresh in CI/CD)"
            fi
            echo ""

            if [ "$refresh" != "n" ] && [ "$refresh" != "N" ]; then
                echo "Refreshing architecture documentation..."
                echo ""

                if [ -f "$scripts_dir/analyze-architecture.sh" ]; then
                    bash "$scripts_dir/analyze-architecture.sh"
                else
                    echo "⚠️  Architecture script not found at $scripts_dir/analyze-architecture.sh"
                    return 1
                fi
                
                echo ""
                echo "✓ Architecture documentation refreshed"
                echo ""
            fi
        fi
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Architecture Data Loading
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

load_architecture_context() {
    # Use get_architecture_dirs() for monorepo/workspace support
    local arch_dirs=($(get_architecture_dirs))
    local tech_stack=""

    # Find first existing technology-stack.md in search order
    for dir in "${arch_dirs[@]}"; do
        if [ -f "$dir/technology-stack.md" ]; then
            tech_stack="$dir/technology-stack.md"
            break
        fi
    done

    # Fallback to legacy path if no architecture dirs found
    if [ -z "$tech_stack" ]; then
        local gbm_root=$(get_gobuildme_root)
        if [ -n "$gbm_root" ]; then
            tech_stack="$gbm_root/.gobuildme/docs/technical/architecture/technology-stack.md"
        else
            tech_stack=".gobuildme/docs/technical/architecture/technology-stack.md"
        fi
    fi

    if [ ! -f "$tech_stack" ]; then
        echo "⚠️  Architecture not found. Using basic detection."
        return 1
    fi

    # Extract key information from architecture docs
    export ARCH_LANGUAGE=$(grep -i "^.*Language:" "$tech_stack" | head -1 | sed 's/.*Language:[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "")
    export ARCH_FRAMEWORK=$(grep -i "^.*Framework:" "$tech_stack" | head -1 | sed 's/.*Framework:[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "")
    export ARCH_TEST_FRAMEWORK=$(grep -i "^.*Test Framework:" "$tech_stack" | head -1 | sed 's/.*Test Framework:[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "")
    export ARCH_DATABASE=$(grep -i "^.*Database:" "$tech_stack" | head -1 | sed 's/.*Database:[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "")

    return 0
}

load_integration_landscape() {
    # Use get_architecture_dirs() for monorepo/workspace support
    local arch_dirs=($(get_architecture_dirs))
    local integration_file=""

    # Find first existing integration-landscape.md in search order
    for dir in "${arch_dirs[@]}"; do
        if [ -f "$dir/integration-landscape.md" ]; then
            integration_file="$dir/integration-landscape.md"
            break
        fi
    done

    # Fallback to legacy path if no architecture dirs found
    if [ -z "$integration_file" ]; then
        local gbm_root=$(get_gobuildme_root)
        if [ -n "$gbm_root" ]; then
            integration_file="$gbm_root/.gobuildme/docs/technical/architecture/integration-landscape.md"
        else
            integration_file=".gobuildme/docs/technical/architecture/integration-landscape.md"
        fi
    fi

    if [ ! -f "$integration_file" ]; then
        return 1
    fi

    # Extract external services (lines starting with "- " under "External Services" section)
    # Handle both "- Service" and "- Service (description)" formats
    # Use awk to find lines between "External Services" and next section (## or end of file)
    export ARCH_EXTERNAL_SERVICES=$(awk '
        BEGIN { in_section=0 }
        /^## External Services/ { in_section=1; next }
        /^##/ && in_section { in_section=0 }
        in_section && /^[[:space:]]*-/ {
            sub(/^[[:space:]]*-[[:space:]]*/, "")
            sub(/[[:space:]]*\(.*\).*$/, "")
            if (length($0) > 0) print
        }
    ' "$integration_file")

    # Extract API type
    export ARCH_API_TYPE=$(grep -i "^.*API.*Type:" "$integration_file" | head -1 | sed 's/.*:[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "REST")

    return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Feature Context Loading
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

load_feature_context() {
    local feature="${1:-}"

    if [ -z "$feature" ]; then
        feature=$(get_current_branch)
    fi

    # Use get_gobuildme_root for monorepo/workspace support
    local gbm_root=$(get_gobuildme_root)
    # Use get_feature_dir for correct path resolution (handles epic--slice)
    local feature_dir=$(get_feature_dir "$feature")

    # Load data model entities with fallback priority:
    # Priority 1: Feature-specific data-model.md (most detailed, feature-scoped)
    # Priority 2: Global data-architecture.md (comprehensive entity catalog from /gbm.architecture)
    if [ -f "$feature_dir/data-model.md" ]; then
        export FEATURE_ENTITIES=$(grep "^## " "$feature_dir/data-model.md" | sed 's/^## //' | grep -v "Data Model" || echo "")
    else
        # Search for data-architecture.md in architecture dirs (module → root)
        local arch_dirs=($(get_architecture_dirs))
        local data_arch_file=""
        for dir in "${arch_dirs[@]}"; do
            if [ -f "$dir/data-architecture.md" ]; then
                data_arch_file="$dir/data-architecture.md"
                break
            fi
        done
        # Fallback to legacy path
        if [ -z "$data_arch_file" ] && [ -n "$gbm_root" ]; then
            data_arch_file="$gbm_root/.gobuildme/docs/technical/architecture/data-architecture.md"
        fi
        if [ -f "$data_arch_file" ]; then
            # Extract entities from "## Entity Catalog" section
            export FEATURE_ENTITIES=$(sed -n '/^## Entity Catalog/,/^## /p' "$data_arch_file" | grep "^### " | sed 's/^### //' || echo "")
        fi
    fi

    # Load acceptance criteria
    if [ -f "$feature_dir/spec.md" ]; then
        export FEATURE_ACS=$(grep -E "^[0-9]+\." "$feature_dir/spec.md" || echo "")
    fi

    # Check for feature architecture context
    if [ -f "$feature_dir/docs/technical/architecture/feature-context.md" ]; then
        export FEATURE_ARCH_CONTEXT="$feature_dir/docs/technical/architecture/feature-context.md"
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Language Detection
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

detect_language() {
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "python"
    elif [ -f "package.json" ]; then
        # Check if TypeScript
        if grep -q "typescript" package.json 2>/dev/null; then
            echo "typescript"
        else
            echo "javascript"
        fi
    elif [ -f "composer.json" ]; then
        echo "php"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "java"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    elif [ -f "Gemfile" ]; then
        echo "ruby"
    elif [ -f "*.csproj" ]; then
        echo "csharp"
    else
        echo "unknown"
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Test Framework Detection (with architecture fallback)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

detect_test_framework() {
    # First try architecture
    if [ -n "$ARCH_TEST_FRAMEWORK" ]; then
        echo "$ARCH_TEST_FRAMEWORK"
        return 0
    fi
    
    # Fallback to manual detection
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        if grep -q "pytest" requirements.txt 2>/dev/null || grep -q "pytest" pyproject.toml 2>/dev/null; then
            echo "pytest"
        else
            echo "unittest"
        fi
    elif [ -f "package.json" ]; then
        if grep -q "jest" package.json 2>/dev/null; then
            echo "jest"
        elif grep -q "vitest" package.json 2>/dev/null; then
            echo "vitest"
        else
            echo "mocha"
        fi
    elif [ -f "composer.json" ]; then
        echo "phpunit"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "junit"
    else
        echo "unknown"
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TODO Scanning
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

scan_test_todos() {
    local test_dir="${1:-tests}"
    
    if [ ! -d "$test_dir" ]; then
        echo ""
        return 1
    fi
    
    # Find all test files with TODO markers
    find "$test_dir" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.php" -o -name "*.java" \) \
        -exec grep -l "TODO\|pytest.skip\|test.skip\|@skip" {} \; 2>/dev/null
}

get_todo_details() {
    local file="$1"
    
    # Extract TODO comments and skip markers with line numbers
    grep -n "TODO\|pytest.skip\|test.skip\|@skip" "$file" 2>/dev/null || echo ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Persona Loading
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

load_persona_config() {
    # Use get_workspace_root() for persona config (shared across modules/repos)
    local workspace_root=$(get_workspace_root)
    local config_base="${workspace_root:-.}/.gobuildme"
    local personas_config="$config_base/config/personas.yaml"

    # Initialize with empty values
    export PERSONA_ID=""
    export PERSONA_NAME=""
    export PERSONA_COVERAGE_FLOOR=""
    export PERSONA_INTEGRATION_COVERAGE_FLOOR=""

    # Check if personas config exists
    if [ ! -f "$personas_config" ]; then
        return 1
    fi

    # Try to extract default_persona (handle empty values)
    if command -v yq >/dev/null 2>&1; then
        # Use yq if available (more reliable)
        PERSONA_ID=$(yq eval '.default_persona // ""' "$personas_config" 2>/dev/null)
    else
        # Fallback to grep/sed
        PERSONA_ID=$(grep "^default_persona:" "$personas_config" | sed 's/default_persona:[[:space:]]*//' | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/" | grep -v "^$" || echo "")
    fi

    # If no persona set or empty, return
    if [ -z "$PERSONA_ID" ] || [ "$PERSONA_ID" = '""' ] || [ "$PERSONA_ID" = "''" ]; then
        return 1
    fi

    # Load persona-specific configuration
    local persona_file="$config_base/personas/${PERSONA_ID}.yaml"

    if [ ! -f "$persona_file" ]; then
        print_warning "Persona '$PERSONA_ID' configured but file not found: $persona_file"
        return 1
    fi

    # Extract persona details
    if command -v yq >/dev/null 2>&1; then
        PERSONA_NAME=$(yq eval '.name // ""' "$persona_file" 2>/dev/null)
        PERSONA_COVERAGE_FLOOR=$(yq eval '.defaults.coverage_floor // ""' "$persona_file" 2>/dev/null)
        PERSONA_INTEGRATION_COVERAGE_FLOOR=$(yq eval '.defaults.integration_coverage_floor // ""' "$persona_file" 2>/dev/null)
    else
        # Fallback parsing
        PERSONA_NAME=$(grep "^name:" "$persona_file" | head -1 | sed 's/name:[[:space:]]*//' || echo "")
        PERSONA_COVERAGE_FLOOR=$(grep "coverage_floor:" "$persona_file" | head -1 | sed 's/.*coverage_floor:[[:space:]]*//' | grep -o "[0-9.]*" || echo "")
        PERSONA_INTEGRATION_COVERAGE_FLOOR=$(grep "integration_coverage_floor:" "$persona_file" | head -1 | sed 's/.*integration_coverage_floor:[[:space:]]*//' | grep -o "[0-9.]*" || echo "")
    fi

    export PERSONA_ID
    export PERSONA_NAME
    export PERSONA_COVERAGE_FLOOR
    export PERSONA_INTEGRATION_COVERAGE_FLOOR

    return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# QA Configuration Loading
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

load_qa_config() {
    # Use get_workspace_root() for QA config (shared across modules/repos)
    local workspace_root=$(get_workspace_root)
    local qa_config="${workspace_root:-.}/.gobuildme/config/qa-config.yaml"

    # Initialize defaults
    export QA_GATE_MODE="advisory"  # strict, advisory, or disabled
    export QA_COVERAGE_UNIT="85"
    export QA_COVERAGE_INTEGRATION="90"
    export QA_COVERAGE_E2E="80"
    export QA_COVERAGE_OVERALL="80"
    export QA_AC_TRACEABILITY_MIN="95"
    export QA_AC_MANUAL_REVIEW="true"
    export QA_TODO_MAX_PERCENT="10"
    export QA_TODO_BLOCK="false"

    # If no config file, use defaults
    if [ ! -f "$qa_config" ]; then
        return 0
    fi

    # Check for yq (recommended for reliable YAML parsing)
    if ! command -v yq >/dev/null 2>&1; then
        echo "⚠️  Note: 'yq' not found, using basic YAML parsing"
        echo "   For complex YAML configurations, install yq:"
        echo "   • macOS: brew install yq"
        echo "   • Linux: snap install yq or download from https://github.com/mikefarah/yq"
        echo ""
    fi

    # Parse config file
    if command -v yq >/dev/null 2>&1; then
        # Use yq for reliable YAML parsing
        QA_GATE_MODE=$(yq eval '.quality_gates.mode // "advisory"' "$qa_config" 2>/dev/null)
        QA_COVERAGE_UNIT=$(yq eval '.quality_gates.coverage.unit // 85' "$qa_config" 2>/dev/null)
        QA_COVERAGE_INTEGRATION=$(yq eval '.quality_gates.coverage.integration // 90' "$qa_config" 2>/dev/null)
        QA_COVERAGE_E2E=$(yq eval '.quality_gates.coverage.e2e // 80' "$qa_config" 2>/dev/null)
        QA_COVERAGE_OVERALL=$(yq eval '.quality_gates.coverage.overall // 80' "$qa_config" 2>/dev/null)
        QA_AC_TRACEABILITY_MIN=$(yq eval '.quality_gates.ac_traceability.minimum // 95' "$qa_config" 2>/dev/null)
        QA_AC_MANUAL_REVIEW=$(yq eval '.quality_gates.ac_traceability.allow_manual_review // true' "$qa_config" 2>/dev/null)
        QA_TODO_MAX_PERCENT=$(yq eval '.quality_gates.todo_tests.max_percentage // 10' "$qa_config" 2>/dev/null)
        QA_TODO_BLOCK=$(yq eval '.quality_gates.todo_tests.block_on_todos // false' "$qa_config" 2>/dev/null)
    else
        # Fallback to grep/sed (basic parsing)
        local mode=$(grep "mode:" "$qa_config" | grep -v "#" | head -1 | sed 's/.*mode:[[:space:]]*//' | tr -d '"' || echo "advisory")
        [ -n "$mode" ] && QA_GATE_MODE="$mode"

        local unit=$(grep "unit:" "$qa_config" | grep -v "#" | head -1 | sed 's/.*unit:[[:space:]]*//' | grep -o "[0-9]*" || echo "85")
        [ -n "$unit" ] && QA_COVERAGE_UNIT="$unit"

        local integration=$(grep "integration:" "$qa_config" | grep -v "#" | head -1 | sed 's/.*integration:[[:space:]]*//' | grep -o "[0-9]*" || echo "90")
        [ -n "$integration" ] && QA_COVERAGE_INTEGRATION="$integration"

        local e2e=$(grep "e2e:" "$qa_config" | grep -v "#" | head -1 | sed 's/.*e2e:[[:space:]]*//' | grep -o "[0-9]*" || echo "80")
        [ -n "$e2e" ] && QA_COVERAGE_E2E="$e2e"

        local overall=$(grep "overall:" "$qa_config" | grep -v "#" | head -1 | sed 's/.*overall:[[:space:]]*//' | grep -o "[0-9]*" || echo "80")
        [ -n "$overall" ] && QA_COVERAGE_OVERALL="$overall"

        local ac_min=$(grep "minimum:" "$qa_config" | grep -v "#" | head -1 | sed 's/.*minimum:[[:space:]]*//' | grep -o "[0-9]*" || echo "95")
        [ -n "$ac_min" ] && QA_AC_TRACEABILITY_MIN="$ac_min"
    fi

    export QA_GATE_MODE
    export QA_COVERAGE_UNIT
    export QA_COVERAGE_INTEGRATION
    export QA_COVERAGE_E2E
    export QA_COVERAGE_OVERALL
    export QA_AC_TRACEABILITY_MIN
    export QA_AC_MANUAL_REVIEW
    export QA_TODO_MAX_PERCENT
    export QA_TODO_BLOCK

    return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Coverage Utilities
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

get_coverage_threshold() {
    local test_type="$1"

    # Load QA config and persona config if not already loaded
    if [ -z "${QA_COVERAGE_UNIT:-}" ]; then
        load_qa_config
    fi
    if [ -z "${PERSONA_ID:-}" ]; then
        load_persona_config
    fi

    # Determine threshold based on test type
    local threshold=""

    case "$test_type" in
        unit)
            threshold="${QA_COVERAGE_UNIT:-85}"
            ;;
        integration)
            # Use persona integration floor if set, otherwise use config
            if [ -n "${PERSONA_INTEGRATION_COVERAGE_FLOOR:-}" ]; then
                # Convert 0.95 to 95 using awk (more portable than bc)
                threshold=$(awk "BEGIN {printf \"%.0f\", ${PERSONA_INTEGRATION_COVERAGE_FLOOR} * 100}" 2>/dev/null || echo "${QA_COVERAGE_INTEGRATION:-90}")
            else
                threshold="${QA_COVERAGE_INTEGRATION:-90}"
            fi
            ;;
        e2e)
            threshold="${QA_COVERAGE_E2E:-80}"
            ;;
        overall)
            # Use persona coverage floor if set, otherwise use config
            if [ -n "${PERSONA_COVERAGE_FLOOR:-}" ]; then
                # Convert 0.85 to 85 using awk (more portable than bc)
                threshold=$(awk "BEGIN {printf \"%.0f\", ${PERSONA_COVERAGE_FLOOR} * 100}" 2>/dev/null || echo "${QA_COVERAGE_OVERALL:-80}")
            else
                threshold="${QA_COVERAGE_OVERALL:-80}"
            fi
            ;;
        *)
            threshold="${QA_COVERAGE_OVERALL:-80}"
            ;;
    esac

    echo "$threshold"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Backup and Rollback Utilities
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

create_backup() {
    local operation="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local pid=$$
    local backup_dir=".gobuildme/test-generation-backup/${operation}_${timestamp}_${pid}"

    mkdir -p "$backup_dir"

    local backed_up_files=()

    # Backup tests directory if it exists
    if [ -d "tests" ]; then
        cp -r tests "$backup_dir/" 2>/dev/null || true
        backed_up_files+=("tests/")
    fi

    # Backup root-level test configuration files
    for file in conftest.py pytest.ini jest.config.js jest.config.ts vitest.config.js vitest.config.ts phpunit.xml pom.xml build.gradle; do
        if [ -f "$file" ]; then
            cp "$file" "$backup_dir/" 2>/dev/null || true
            backed_up_files+=("$file")
        fi
    done

    # Backup test scaffolding reports if they exist
    if [ -d ".gobuildme/specs/qa-test-scaffolding" ]; then
        mkdir -p "$backup_dir/.gobuildme"
        cp -r .gobuildme/specs/qa-test-scaffolding "$backup_dir/.gobuildme/" 2>/dev/null || true
        backed_up_files+=(".gobuildme/specs/qa-test-scaffolding/")
    fi

    # Create manifest with backed up files list
    cat > "$backup_dir/manifest.json" <<EOF
{
  "operation": "$operation",
  "timestamp": "$timestamp",
  "pid": $pid,
  "backed_up": [
$(printf '    "%s",\n' "${backed_up_files[@]}" | sed '$ s/,$//')
  ]
}
EOF

    echo "$backup_dir"
}

restore_from_backup() {
    local backup_dir="$1"

    if [ ! -d "$backup_dir" ]; then
        print_error "Backup not found: $backup_dir"
        return 1
    fi

    # Verify backup integrity
    if [ ! -f "$backup_dir/manifest.json" ]; then
        print_warning "Backup missing manifest, may be incomplete"
    fi

    print_warning "Restoring from backup: $backup_dir"

    # Remove current tests directory
    if [ -d "tests" ]; then
        rm -rf tests
    fi

    # Restore tests from backup
    if [ -d "$backup_dir/tests" ]; then
        cp -r "$backup_dir/tests" .
        print_success "Restored tests/ directory"
    fi

    # Restore root-level test configuration files
    for file in conftest.py pytest.ini jest.config.js jest.config.ts vitest.config.js vitest.config.ts phpunit.xml pom.xml build.gradle; do
        if [ -f "$backup_dir/$file" ]; then
            cp "$backup_dir/$file" .
            print_success "Restored $file"
        fi
    done

    # Restore test scaffolding reports
    if [ -d "$backup_dir/.gobuildme/specs/qa-test-scaffolding" ]; then
        mkdir -p .gobuildme
        cp -r "$backup_dir/.gobuildme/specs/qa-test-scaffolding" .gobuildme/
        print_success "Restored .gobuildme/specs/qa-test-scaffolding/"
    fi

    return 0
}

get_latest_backup() {
    local backup_base=".gobuildme/test-generation-backup"

    if [ ! -d "$backup_base" ]; then
        echo ""
        return 1
    fi

    # Find most recent backup
    find "$backup_base" -mindepth 1 -maxdepth 1 -type d | sort -r | head -1
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Dry-run Utilities
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Check if dry-run mode is enabled
is_dry_run() {
    [ "${DRY_RUN:-false}" = "true" ]
}

dry_run_message() {
    if is_dry_run; then
        echo "[DRY-RUN] $1"
    fi
}

# Execute command only if not in dry-run mode
exec_if_not_dry_run() {
    if is_dry_run; then
        dry_run_message "Would execute: $*"
        return 0
    else
        "$@"
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Output Formatting
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_section() {
    local title="$1"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$title"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

print_success() {
    echo "✓ $1"
}

print_warning() {
    echo "⚠️  $1"
}

print_error() {
    echo "✗ $1"
}

print_info() {
    echo "ℹ️  $1"
}

