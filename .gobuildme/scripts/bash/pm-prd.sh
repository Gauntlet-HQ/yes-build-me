#!/usr/bin/env bash
# pm-prd.sh - Create PRD workspace from validated discovery
set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# =============================================================================
# PM PRD Creation
# =============================================================================

main() {
    log_info "Setting up PM PRD workspace..."

    # Get feature name from arguments
    local feature_name="${1:-}"
    if [[ -z "$feature_name" ]]; then
        log_error "Feature name required"
        log_info "Usage: pm-prd.sh <feature-name>"
        log_info "Example: pm-prd.sh real-time-dashboard"
        exit 1
    fi

    # Get repo root and resolve feature directory (handles epic--slice paths)
    local repo_root=$(get_repo_root)
    local spec_dir=$(get_feature_dir "$repo_root" "$feature_name")
    mkdir -p "$spec_dir"

    # Create PRD file
    local prd_file="${spec_dir}/prd.md"

    log_success "Created PRD workspace: $spec_dir"

    # Check prerequisites
    check_prerequisites "$feature_name"

    # Create PRD template
    create_prd_template "$prd_file" "$feature_name"

    # Create PRD metadata
    create_prd_metadata "$spec_dir" "$feature_name"

    log_info ""
    log_success "✅ PM PRD workspace initialized!"
    log_info ""
    log_info "Feature: $feature_name"
    log_info "PRD File: $prd_file"
    log_info ""
    log_info "Next: Follow the /gbm.pm.prd command to:"
    log_info "  1. Complete PRD based on validated discovery"
    log_info "  2. Include evidence from interviews and research"
    log_info "  3. Define success metrics with baselines"
    log_info "  4. Review with stakeholders"
}

# =============================================================================
# Prerequisite Checking
# =============================================================================

check_prerequisites() {
    local feature="$1"
    local repo_root=$(get_repo_root)
    local base_dir=$(get_feature_dir "$repo_root" "$feature")

    log_info "Checking prerequisites..."

    # Check for validation report
    if [[ ! -f "${base_dir}/validation-report.md" ]]; then
        log_warning "Warning: No /gbm.pm.validate-problem report found"
        log_info "  Recommended: Run /gbm.pm.validate-problem first"
    else
        log_success "  ✓ Validation report exists"
    fi

    # Check for discovery artifacts
    if [[ ! -d "${base_dir}/interviews" ]]; then
        log_warning "Warning: No interview data found"
    else
        log_success "  ✓ Interview data exists"
    fi

    if [[ ! -d "${base_dir}/research" ]]; then
        log_warning "Warning: No research data found"
    else
        log_success "  ✓ Research data exists"
    fi

    log_info "Prerequisite check complete"
}

# =============================================================================
# Template Creation
# =============================================================================

create_prd_template() {
    local file="$1"
    local feature="$2"

    # Copy template from repository
    local template_file=".gobuildme/templates/pm-prd-template.md"

    if [[ ! -f "$template_file" ]]; then
        log_error "PRD template not found: $template_file"
        exit 1
    fi

    cp "$template_file" "$file"

    log_success "Created: prd.md (from template)"
}

create_prd_metadata() {
    local dir="$1"
    local feature="$2"
    local file="$dir/prd-metadata.json"

    cat > "$file" <<EOF
{
  "feature": "$feature",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "command": "/gbm.pm.prd",
  "phase": "definition",
  "status": "draft",
  "version": "1.0",
  "artifacts": {
    "prd": "prd.md"
  },
  "next_steps": [
    "Complete PRD sections",
    "Stakeholder review",
    "/gbm.pm.stories"
  ]
}
EOF

    log_success "Created: prd-metadata.json"
}

# =============================================================================
# Execute
# =============================================================================

main "$@"
