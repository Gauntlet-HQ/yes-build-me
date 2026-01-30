#!/usr/bin/env bash
# Purpose : Collect raw architectural data for AI Agent analysis
# Why     : Supports `/specify` phase by gathering structured data that AI Agents
#           can analyze to generate comprehensive architectural insights
# How     : Collects facts about project structure, technology stack, patterns,
#           and integrations in structured JSON format for AI Agent consumption
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Resolve repository and feature context (workspace-aware)
if ! eval "$(get_feature_paths)"; then
    echo "Failed to resolve feature paths" >&2
    exit 1
fi

# Use GBM_ROOT for architecture docs (workspace-aware)
# GIT_ROOT for git operations if available
if [[ -n "$GIT_ROOT" ]]; then
    cd "$GIT_ROOT"
elif [[ -n "$GBM_ROOT" ]]; then
    cd "$GBM_ROOT"
fi

if ! check_feature_branch "$CURRENT_BRANCH" "$HAS_GIT"; then
    exit 1
fi

# Check if there's existing code (use GIT_ROOT if available, else GBM_ROOT)
SCAN_ROOT="${GIT_ROOT:-$GBM_ROOT}"
HAS_EXISTING_CODE=false
if find "$SCAN_ROOT" -maxdepth 2 -type f \( -name "*.php" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.go" -o -name "*.rb" -o -name "*.cs" -o -name "*.cpp" -o -name "*.c" \) -not -path "*/.gobuildme/*" | head -1 >/dev/null 2>&1; then
    HAS_EXISTING_CODE=true
fi

# Create global architecture directory at GBM_ROOT (not GIT_ROOT) for proper scoping
GLOBAL_ARCH_DIR="$GBM_ROOT/.gobuildme/docs/technical/architecture"
if [ "$HAS_EXISTING_CODE" = true ]; then
    mkdir -p "$GLOBAL_ARCH_DIR"
fi

# Create feature-specific architecture directory
mkdir -p "$FEATURE_DIR"
FEATURE_ARCH_DIR="$FEATURE_DIR/docs/technical/architecture"
mkdir -p "$FEATURE_ARCH_DIR"

# Output file for data collection (feature-specific)
OUTFILE="$FEATURE_ARCH_DIR/data-collection.md"

# Generate structured data for AI Agent analysis
if [ "$HAS_EXISTING_CODE" = true ]; then
    echo "# Raw Architecture Data Collection (Existing Codebase)" > "$OUTFILE"
    echo >> "$OUTFILE"
    echo "**IMPORTANT**: This is RAW DATA ONLY - AI Agent must create actual architecture documentation" >> "$OUTFILE"
    echo "**Purpose**: Data collection for AI Agent to analyze and generate comprehensive architecture documentation" >> "$OUTFILE"
    echo "**Codebase Status**: Existing code detected - AI Agent should run /architecture command for global analysis" >> "$OUTFILE"
    echo "**AI Action Required**: Create system-analysis.md, component-architecture.md, and other architecture docs" >> "$OUTFILE"
else
    echo "# Raw Architecture Data Collection (New Project)" > "$OUTFILE"
    echo >> "$OUTFILE"
    echo "**IMPORTANT**: This is RAW DATA ONLY - AI Agent must establish architectural foundation" >> "$OUTFILE"
    echo "**Purpose**: Basic project setup data for AI Agent to plan initial architecture" >> "$OUTFILE"
    echo "**Codebase Status**: New/empty project - AI Agent should use constitutional principles" >> "$OUTFILE"
    echo "**AI Action Required**: Establish architectural foundation based on constitutional constraints" >> "$OUTFILE"
fi
echo >> "$OUTFILE"

# Data Collection Functions for AI Agent Analysis

# Collect raw project structure data
collect_project_structure() {
    echo "## Project Structure Data" >> "$OUTFILE"
    echo '```json' >> "$OUTFILE"
    echo '{' >> "$OUTFILE"
    echo '  "directories": [' >> "$OUTFILE"
    find . -maxdepth 3 -type d \
        -not -path './.git*' -not -path './.venv*' -not -path './node_modules*' \
        -not -path './.gobuildme*' | sed 's|^./||' | sed 's/^/    "/' | sed 's/$/"/' | sed '$!s/$/,/' >> "$OUTFILE"
    echo '  ],' >> "$OUTFILE"
    echo '  "config_files": [' >> "$OUTFILE"
    (ls -1 composer.json package.json requirements.txt pyproject.toml go.mod Cargo.toml pom.xml build.gradle .env artisan manage.py 2>/dev/null | sed 's/^/    "/' | sed 's/$/"/' | sed '$!s/$/,/' || echo '    ""') >> "$OUTFILE"
    echo '  ],' >> "$OUTFILE"
    echo '  "framework_indicators": [' >> "$OUTFILE"
    local indicators=""
    [ -f "artisan" ] && indicators="$indicators\"laravel\","
    [ -f "manage.py" ] && indicators="$indicators\"django\","
    [ -f "package.json" ] && grep -q "express" package.json 2>/dev/null && indicators="$indicators\"express\","
    [ -f "package.json" ] && grep -q "react" package.json 2>/dev/null && indicators="$indicators\"react\","
    [ -f "package.json" ] && grep -q "vue" package.json 2>/dev/null && indicators="$indicators\"vue\","
    [ -f "pom.xml" ] && grep -q "spring" pom.xml 2>/dev/null && indicators="$indicators\"spring\","
    [ -f "go.mod" ] && indicators="$indicators\"go\","
    [ -f "Dockerfile" ] && indicators="$indicators\"docker\","
    [ -f "docker-compose.yml" ] && indicators="$indicators\"docker-compose\","
    [ -d "k8s" ] && indicators="$indicators\"kubernetes\","
    echo "    ${indicators%,}" >> "$OUTFILE"
    echo '  ]' >> "$OUTFILE"
    echo '}' >> "$OUTFILE"
    echo '```' >> "$OUTFILE"
}

# Collect technology stack indicators
collect_technology_indicators() {
    echo >> "$OUTFILE"
    echo "## Technology Stack Indicators" >> "$OUTFILE"
    echo '```json' >> "$OUTFILE"
    echo '{' >> "$OUTFILE"
    
    # Language detection
    echo '  "languages": {' >> "$OUTFILE"
    local php_files=$(find . -name "*.php" -not -path './.git*' -not -path './vendor*' -not -path './.gobuildme*' | wc -l)
    local js_files=$(find . -name "*.js" -o -name "*.ts" -not -path './.git*' -not -path './node_modules*' -not -path './.gobuildme*' | wc -l)
    local py_files=$(find . -name "*.py" -not -path './.git*' -not -path './.venv*' -not -path './.gobuildme*' | wc -l)
    local java_files=$(find . -name "*.java" -not -path './.git*' -not -path './target*' -not -path './.gobuildme*' | wc -l)
    local go_files=$(find . -name "*.go" -not -path './.git*' -not -path './.gobuildme*' | wc -l)
    
    [ $php_files -gt 0 ] && echo "    \"php\": $php_files," >> "$OUTFILE"
    [ $js_files -gt 0 ] && echo "    \"javascript\": $js_files," >> "$OUTFILE"
    [ $py_files -gt 0 ] && echo "    \"python\": $py_files," >> "$OUTFILE"
    [ $java_files -gt 0 ] && echo "    \"java\": $java_files," >> "$OUTFILE"
    [ $go_files -gt 0 ] && echo "    \"go\": $go_files," >> "$OUTFILE"
    echo '    "total": 0' >> "$OUTFILE"
    echo '  },' >> "$OUTFILE"
    
    # Database indicators
    echo '  "database_indicators": [' >> "$OUTFILE"
    local db_indicators=""
    grep -r "mysql\|MySQL" --include="*.env*" --include="*.yml" --include="*.yaml" . >/dev/null 2>&1 && db_indicators="$db_indicators\"mysql\","
    grep -r "postgresql\|postgres" --include="*.env*" --include="*.yml" --include="*.yaml" . >/dev/null 2>&1 && db_indicators="$db_indicators\"postgresql\","
    grep -r "mongodb\|mongo" --include="*.env*" --include="*.yml" --include="*.yaml" . >/dev/null 2>&1 && db_indicators="$db_indicators\"mongodb\","
    grep -r "redis\|Redis" --include="*.env*" --include="*.yml" --include="*.yaml" . >/dev/null 2>&1 && db_indicators="$db_indicators\"redis\","
    grep -r "sqlite\|SQLite" --include="*.env*" --include="*.yml" --include="*.yaml" . >/dev/null 2>&1 && db_indicators="$db_indicators\"sqlite\","
    echo "    ${db_indicators%,}" >> "$OUTFILE"
    echo '  ],' >> "$OUTFILE"
    
    # Infrastructure indicators
    echo '  "infrastructure_indicators": [' >> "$OUTFILE"
    local infra_indicators=""
    [ -f "Dockerfile" ] && infra_indicators="$infra_indicators\"docker\","
    [ -f "docker-compose.yml" ] && infra_indicators="$infra_indicators\"docker-compose\","
    [ -d "k8s" ] && infra_indicators="$infra_indicators\"kubernetes\","
    grep -r "aws\|AWS" --include="*.env*" --include="*.yml" --include="*.tf" . >/dev/null 2>&1 && infra_indicators="$infra_indicators\"aws\","
    grep -r "gcp\|google-cloud" --include="*.env*" --include="*.yml" --include="*.tf" . >/dev/null 2>&1 && infra_indicators="$infra_indicators\"gcp\","
    grep -r "azure\|Azure" --include="*.env*" --include="*.yml" --include="*.tf" . >/dev/null 2>&1 && infra_indicators="$infra_indicators\"azure\","
    echo "    ${infra_indicators%,}" >> "$OUTFILE"
    echo '  ]' >> "$OUTFILE"
    echo '}' >> "$OUTFILE"
    echo '```' >> "$OUTFILE"
}

# Collect architectural pattern indicators
collect_architectural_patterns() {
    echo >> "$OUTFILE"
    echo "## Architectural Pattern Indicators" >> "$OUTFILE"
    echo '```json' >> "$OUTFILE"
    echo '{' >> "$OUTFILE"

    # MVC pattern indicators
    echo '  "mvc_indicators": {' >> "$OUTFILE"
    echo "    \"models_dir\": $([ -d "models" ] || [ -d "app/Models" ] && echo "true" || echo "false")," >> "$OUTFILE"
    echo "    \"views_dir\": $([ -d "views" ] || [ -d "resources/views" ] || [ -d "templates" ] && echo "true" || echo "false")," >> "$OUTFILE"
    echo "    \"controllers_dir\": $([ -d "controllers" ] || [ -d "app/Http/Controllers" ] || [ -d "app/Controllers" ] && echo "true" || echo "false")" >> "$OUTFILE"
    echo '  },' >> "$OUTFILE"

    # Microservices indicators
    echo '  "microservices_indicators": {' >> "$OUTFILE"
    echo "    \"docker_compose\": $([ -f "docker-compose.yml" ] && echo "true" || echo "false")," >> "$OUTFILE"
    echo "    \"dockerfile\": $([ -f "Dockerfile" ] && echo "true" || echo "false")," >> "$OUTFILE"
    echo "    \"kubernetes\": $([ -d "k8s" ] || [ -f "kubernetes.yml" ] && echo "true" || echo "false")," >> "$OUTFILE"
    echo "    \"services_dir\": $([ -d "services" ] || [ -d "microservices" ] && echo "true" || echo "false")" >> "$OUTFILE"
    echo '  },' >> "$OUTFILE"

    # API patterns
    echo '  "api_patterns": [' >> "$OUTFILE"
    local api_patterns=""
    grep -r "/api/v[0-9]" . >/dev/null 2>&1 && api_patterns="$api_patterns\"versioned_api\","
    grep -r "graphql\|GraphQL" . >/dev/null 2>&1 && api_patterns="$api_patterns\"graphql\","
    grep -r "Route::\|@app.route\|app\.\(get\|post\)" . >/dev/null 2>&1 && api_patterns="$api_patterns\"rest_api\","
    echo "    ${api_patterns%,}" >> "$OUTFILE"
    echo '  ],' >> "$OUTFILE"

    # Event-driven patterns
    echo '  "event_driven_indicators": [' >> "$OUTFILE"
    local event_patterns=""
    grep -r "event\|Event" --include="*.php" --include="*.py" --include="*.js" . >/dev/null 2>&1 && event_patterns="$event_patterns\"events\","
    grep -r "listener\|Listener" --include="*.php" --include="*.py" --include="*.js" . >/dev/null 2>&1 && event_patterns="$event_patterns\"listeners\","
    grep -r "queue\|Queue" --include="*.php" --include="*.py" --include="*.js" . >/dev/null 2>&1 && event_patterns="$event_patterns\"queues\","
    grep -r "observer\|Observer" --include="*.php" --include="*.py" --include="*.js" . >/dev/null 2>&1 && event_patterns="$event_patterns\"observers\","
    echo "    ${event_patterns%,}" >> "$OUTFILE"
    echo '  ]' >> "$OUTFILE"
    echo '}' >> "$OUTFILE"
    echo '```' >> "$OUTFILE"
}

# Collect security and integration indicators
collect_security_integration_indicators() {
    echo >> "$OUTFILE"
    echo "## Security & Integration Indicators" >> "$OUTFILE"
    echo '```json' >> "$OUTFILE"
    echo '{' >> "$OUTFILE"

    # Authentication indicators
    echo '  "authentication_indicators": [' >> "$OUTFILE"
    local auth_indicators=""
    grep -r "jwt\|JWT" --include="*.env*" --include="*.php" --include="*.py" --include="*.js" . >/dev/null 2>&1 && auth_indicators="$auth_indicators\"jwt\","
    grep -r "oauth\|OAuth" --include="*.env*" --include="*.php" --include="*.py" --include="*.js" . >/dev/null 2>&1 && auth_indicators="$auth_indicators\"oauth\","
    grep -r "passport" --include="*.php" --include="*.js" . >/dev/null 2>&1 && auth_indicators="$auth_indicators\"passport\","
    grep -r "session\|Session" --include="*.php" --include="*.py" --include="*.js" . >/dev/null 2>&1 && auth_indicators="$auth_indicators\"session\","
    echo "    ${auth_indicators%,}" >> "$OUTFILE"
    echo '  ],' >> "$OUTFILE"

    # Authorization indicators
    echo '  "authorization_indicators": [' >> "$OUTFILE"
    local authz_indicators=""
    grep -r "role\|Role" --include="*.php" --include="*.py" --include="*.js" . >/dev/null 2>&1 && authz_indicators="$authz_indicators\"roles\","
    grep -r "permission\|Permission" --include="*.php" --include="*.py" --include="*.js" . >/dev/null 2>&1 && authz_indicators="$authz_indicators\"permissions\","
    grep -r "policy\|Policy" --include="*.php" --include="*.py" --include="*.js" . >/dev/null 2>&1 && authz_indicators="$authz_indicators\"policies\","
    grep -r "middleware.*auth" --include="*.php" --include="*.py" --include="*.js" . >/dev/null 2>&1 && authz_indicators="$authz_indicators\"middleware\","
    echo "    ${authz_indicators%,}" >> "$OUTFILE"
    echo '  ],' >> "$OUTFILE"

    # External service indicators
    echo '  "external_service_indicators": [' >> "$OUTFILE"
    local external_indicators=""
    grep -r "stripe\|paypal" --include="*.env*" . >/dev/null 2>&1 && external_indicators="$external_indicators\"payment_gateway\","
    grep -r "smtp\|sendgrid\|mailgun" --include="*.env*" . >/dev/null 2>&1 && external_indicators="$external_indicators\"email_service\","
    grep -r "s3\|S3\|aws.*storage" --include="*.env*" . >/dev/null 2>&1 && external_indicators="$external_indicators\"cloud_storage\","
    grep -r "sentry\|bugsnag" --include="*.env*" . >/dev/null 2>&1 && external_indicators="$external_indicators\"error_tracking\","
    grep -r "analytics\|tracking" --include="*.env*" . >/dev/null 2>&1 && external_indicators="$external_indicators\"analytics\","
    echo "    ${external_indicators%,}" >> "$OUTFILE"
    echo '  ]' >> "$OUTFILE"
    echo '}' >> "$OUTFILE"
    echo '```' >> "$OUTFILE"
}

# Generate final data summary for AI Agent
generate_data_summary() {
    echo >> "$OUTFILE"
    echo "## Data Collection Summary" >> "$OUTFILE"
    echo '```json' >> "$OUTFILE"
    echo '{' >> "$OUTFILE"
    echo '  "collection_metadata": {' >> "$OUTFILE"
 >> "$OUTFILE"
    echo "    \"project_root\": \"$(pwd)\"," >> "$OUTFILE"
    echo '    "analysis_version": "2.0",' >> "$OUTFILE"
    echo '    "data_collector": "GoBuildMe Architecture Data Collector"' >> "$OUTFILE"
    echo '  },' >> "$OUTFILE"
    echo '  "ai_agent_instructions": {' >> "$OUTFILE"
    echo '    "purpose": "Generate comprehensive architectural analysis from collected data",' >> "$OUTFILE"
    echo '    "focus": "High-level strategic architectural insights and system design understanding",' >> "$OUTFILE"
    echo '    "output_format": "Executive-level architectural documentation with business context",' >> "$OUTFILE"
    echo '    "analysis_areas": ["architectural_style", "technology_decisions", "component_relationships", "scalability_patterns", "security_architecture", "integration_landscape"]' >> "$OUTFILE"
    echo '  }' >> "$OUTFILE"
    echo '}' >> "$OUTFILE"
    echo '```' >> "$OUTFILE"

    echo >> "$OUTFILE"
    echo "---" >> "$OUTFILE"
    echo "**Next Step**: This raw data should be analyzed by an AI Agent to generate comprehensive architectural insights and strategic recommendations." >> "$OUTFILE"
}

# Run data collection for AI Agent analysis
if [ "$HAS_EXISTING_CODE" = true ]; then
    # Full data collection for existing codebase
    collect_project_structure
    collect_technology_indicators
    collect_architectural_patterns
    collect_security_integration_indicators
    generate_data_summary

    echo "Wrote $OUTFILE (existing codebase data collection)"
    echo "Note: AI Agent must create actual architecture documentation from this data"
else
    # Minimal data collection for new project
    echo "## Project Setup Information" >> "$OUTFILE"
    echo "- **Project Type**: New/empty project" >> "$OUTFILE"
    echo "- **Architecture Approach**: Establish foundation based on constitutional principles" >> "$OUTFILE"
    echo "- **Global Analysis**: Skipped (no existing code to analyze)" >> "$OUTFILE"
    echo >> "$OUTFILE"

    generate_data_summary

    echo "Wrote $OUTFILE (new project data collection)"
    echo "Note: AI Agent should establish architectural foundation based on constitutional principles"
fi
