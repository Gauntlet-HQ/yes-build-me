#!/usr/bin/env bash
# pm-research.sh - Create research workspace for PM market/competitive/analytics analysis
set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# =============================================================================
# PM Research Workspace Setup
# =============================================================================

main() {
    log_info "Setting up PM research workspace..."

    # Get feature name from arguments or prompt
    local feature_name="${1:-}"
    if [[ -z "$feature_name" ]]; then
        log_error "Feature name required"
        log_info "Usage: pm-research.sh <feature-name>"
        log_info "Example: pm-research.sh real-time-dashboard"
        exit 1
    fi

    # Check prerequisites
    check_prerequisites "$feature_name"

    # Get repo root and resolve feature directory (handles epic--slice paths)
    local repo_root=$(get_repo_root)
    local spec_dir=$(get_feature_dir "$repo_root" "$feature_name")

    # Create research workspace directory
    local research_dir="${spec_dir}/research"
    mkdir -p "$research_dir"

    log_success "Created research workspace: $research_dir"

    # Create research templates
    create_market_research_template "$research_dir"
    create_competitive_analysis_template "$research_dir"
    create_analytics_report_template "$research_dir"
    create_technical_feasibility_template "$research_dir"
    create_synthesis_template "$research_dir"

    # Create research metadata
    create_research_metadata "$research_dir" "$feature_name"

    log_info ""
    log_success "✅ PM Research workspace initialized!"
    log_info ""
    log_info "Feature: $feature_name"
    log_info "Workspace: $research_dir"
    log_info ""
    log_info "Files created:"
    log_info "  - market-research.md           (Market sizing, trends, segments)"
    log_info "  - competitive-analysis.md      (Competitor deep-dives, gaps)"
    log_info "  - analytics-report.md          (Data-driven insights)"
    log_info "  - technical-feasibility.md     (Engineering assessment)"
    log_info "  - synthesis.md                 (Evidence quality, recommendation)"
    log_info "  - metadata.json                (Research tracking)"
    log_info ""
    log_info "Next: Follow the /gbm.pm.research command to:"
    log_info "  1. Market research & sizing (TAM/SAM/SOM)"
    log_info "  2. Competitive analysis (3+ competitors)"
    log_info "  3. Analytics deep-dive (validate with data)"
    log_info "  4. Technical feasibility (consult engineering)"
    log_info "  5. Synthesize evidence & make recommendation"
}

# =============================================================================
# Prerequisite Checking
# =============================================================================

check_prerequisites() {
    local feature="$1"
    local repo_root=$(get_repo_root)
    local base_dir=$(get_feature_dir "$repo_root" "$feature")

    log_info "Checking prerequisites..."

    # Check for interview data
    if [[ ! -f "${base_dir}/interviews/synthesis.md" ]]; then
        log_warning "Warning: No /gbm.pm.interview synthesis found"
        log_info "  Recommended: Run /gbm.pm.interview first"
        log_info "  Research should be informed by user interview findings"
    else
        log_success "  ✓ Interview data exists"
    fi

    log_info "Prerequisite check complete"
}

# =============================================================================
# Template Creation Functions
# =============================================================================

create_market_research_template() {
    local dir="$1"
    local file="$dir/market-research.md"
    local template_file=".gobuildme/templates/pm-market-research-template.md"

    if [[ ! -f "$template_file" ]]; then
        log_error "Market research template not found: $template_file"
        exit 1
    fi

    cp "$template_file" "$file"
    log_success "Created: market-research.md"
}

create_competitive_analysis_template() {
    local dir="$1"
    local file="$dir/competitive-analysis.md"
    local template_file=".gobuildme/templates/pm-competitive-analysis-template.md"

    if [[ ! -f "$template_file" ]]; then
        log_error "Competitive analysis template not found: $template_file"
        exit 1
    fi

    cp "$template_file" "$file"
    log_success "Created: competitive-analysis.md"
}

create_analytics_report_template() {
    local dir="$1"
    local file="$dir/analytics-report.md"
    local template_file=".gobuildme/templates/pm-analytics-report-template.md"

    if [[ ! -f "$template_file" ]]; then
        log_error "Analytics report template not found: $template_file"
        exit 1
    fi

    cp "$template_file" "$file"
    log_success "Created: analytics-report.md"
}

create_technical_feasibility_template() {
    local dir="$1"
    local file="$dir/technical-feasibility.md"
    local template_file=".gobuildme/templates/pm-technical-feasibility-template.md"

    if [[ ! -f "$template_file" ]]; then
        log_error "Technical feasibility template not found: $template_file"
        exit 1
    fi

    cp "$template_file" "$file"
    log_success "Created: technical-feasibility.md"
}

create_synthesis_template() {
    local dir="$1"
    local file="$dir/synthesis.md"
    local template_file=".gobuildme/templates/pm-synthesis-template.md"

    if [[ ! -f "$template_file" ]]; then
        log_error "Synthesis template not found: $template_file"
        exit 1
    fi

    cp "$template_file" "$file"
    log_success "Created: synthesis.md"
}

create_research_metadata() {
    local dir="$1"
    local feature="$2"
    local file="$dir/metadata.json"

    cat > "$file" <<EOF
{
  "feature": "$feature",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "command": "/gbm.pm.research",
  "phase": "discovery",
  "status": "in_progress",
  "artifacts": {
    "market_research": "market-research.md",
    "competitive_analysis": "competitive-analysis.md",
    "analytics_report": "analytics-report.md",
    "technical_feasibility": "technical-feasibility.md",
    "synthesis": "synthesis.md"
  },
  "next_steps": [
    "Complete market research (TAM/SAM/SOM)",
    "Analyze 3+ competitors",
    "Validate with analytics data",
    "Assess technical feasibility",
    "/gbm.pm.validate-problem"
  ]
}
EOF

    log_success "Created: metadata.json"
}

# =============================================================================
# Execute
# =============================================================================

main "$@"
