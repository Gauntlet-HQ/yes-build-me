#!/usr/bin/env bash
# pm-stories.sh - Break down PRD into user stories and create Jira import file
set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# =============================================================================
# PM Stories Creation
# =============================================================================

main() {
    log_info "Setting up PM stories workspace..."

    # Get feature name from arguments
    local feature_name="${1:-}"
    if [[ -z "$feature_name" ]]; then
        log_error "Feature name required"
        log_info "Usage: pm-stories.sh <feature-name>"
        log_info "Example: pm-stories.sh real-time-dashboard"
        exit 1
    fi

    # Get repo root and resolve feature directory (handles epic--slice paths)
    local repo_root=$(get_repo_root)
    local spec_dir=$(get_feature_dir "$repo_root" "$feature_name")

    # Create stories directory
    local stories_dir="${spec_dir}/stories"
    mkdir -p "$stories_dir"

    log_success "Created stories workspace: $stories_dir"

    # Check prerequisites
    check_prerequisites "$feature_name"

    # Create story templates
    create_story_templates "$stories_dir"

    # Create Jira import CSV
    create_jira_import "$stories_dir" "$feature_name"

    # Create README with import instructions
    create_readme "$stories_dir"

    # Create stories metadata
    create_stories_metadata "$stories_dir" "$feature_name"

    log_info ""
    log_success "✅ PM Stories workspace initialized!"
    log_info ""
    log_info "Feature: $feature_name"
    log_info "Workspace: $stories_dir"
    log_info ""
    log_info "Files created:"
    log_info "  - epic-template.md        (Template for breaking down epics)"
    log_info "  - jira-import.csv         (CSV for Jira bulk import)"
    log_info "  - README.md               (Import instructions)"
    log_info "  - metadata.json           (Story tracking)"
    log_info ""
    log_info "Next: Follow the /gbm.pm.stories command to:"
    log_info "  1. Break down PRD epics into stories"
    log_info "  2. Size stories (story points)"
    log_info "  3. Import to Jira"
    log_info "  4. Run /gbm.pm.align for stakeholder alignment"
}

# =============================================================================
# Prerequisite Checking
# =============================================================================

check_prerequisites() {
    local feature="$1"
    local repo_root=$(get_repo_root)
    local base_dir=$(get_feature_dir "$repo_root" "$feature")

    log_info "Checking prerequisites..."

    # Check for PRD
    if [[ ! -f "${base_dir}/prd.md" ]]; then
        log_warning "Warning: No /gbm.pm.prd found"
        log_info "  Recommended: Run /gbm.pm.prd first"
    else
        log_success "  ✓ PRD exists"
    fi

    log_info "Prerequisite check complete"
}

# =============================================================================
# Template Creation
# =============================================================================

create_story_templates() {
    local dir="$1"
    local file="$dir/epic-template.md"

    cat > "$file" <<'EOF'
# Epic Breakdown Template

## Epic: [Epic Name from PRD]

**Epic Description:**
[From PRD - high-level capability]

**Priority:** [P0 / P1 / P2 from PRD]
**Business Value:** [Why this matters]

---

## Story Breakdown

### Story 1: [Specific, implementable story]

**Story:**
**As a** [specific persona],
**I want to** [specific action],
**So that** [specific benefit].

**Acceptance Criteria:**

**Given** [precondition],
**When** [user action],
**Then** [expected outcome].

**Additional Criteria:**
- [ ] Criterion 2: [Another testable condition]
- [ ] Criterion 3: [Another testable condition]

**Story Points:** [1, 2, 3, 5, 8, 13]
**Component:** [Backend / Frontend / Design / etc.]
**Dependencies:** [Story IDs or components]

**Definition of Done:**
- [ ] Code complete and reviewed
- [ ] Unit tests written and passing
- [ ] Acceptance criteria validated
- [ ] Documentation updated

---

### Story 2: [Next story]

[Same structure]

---

## Epic Summary

- Total stories: [N]
- Total story points: [X]
- Estimated duration: [Y weeks]
- Dependencies: [Critical dependencies]

---

## Story Sizing Guidelines

**1 Point (XS):** 1-4 hours, no dependencies
**2 Points (S):** Half day to 1 day, minimal dependencies
**3 Points (M):** 1-2 days, some dependencies
**5 Points (L):** 2-3 days, multiple dependencies
**8 Points (XL):** 3-5 days, significant dependencies
**13 Points:** TOO LARGE - Break it down!

---

## INVEST Checklist

For each story, verify:
- [ ] **Independent:** Can be developed in any order
- [ ] **Negotiable:** Details can be discussed
- [ ] **Valuable:** Delivers value to user/business
- [ ] **Estimable:** Team can estimate effort
- [ ] **Small:** Completable in 1 sprint
- [ ] **Testable:** Clear acceptance criteria
EOF

    log_success "Created: epic-template.md"
}

create_jira_import() {
    local dir="$1"
    local feature="$2"
    local file="$dir/jira-import.csv"

    cat > "$file" <<'EOF'
Issue Type,Summary,Description,Priority,Story Points,Epic Link,Component,Labels,Acceptance Criteria
Epic,"[Epic Name]","[Epic description from PRD]",High,,[Parent Epic],,"feature-name",""
Story,"[Story 1]","As a [persona], I want [action], so that [benefit].",High,5,[Epic Key],Backend,"feature-name, api","AC1: Given [condition], When [action], Then [outcome].
AC2: [Additional criterion]"
Story,"[Story 2]","As a [persona], I want [action], so that [benefit].",High,3,[Epic Key],Frontend,"feature-name, ui","AC1: [Criterion 1]
AC2: [Criterion 2]"
EOF

    log_success "Created: jira-import.csv"
}

create_readme() {
    local dir="$1"
    local file="$dir/README.md"

    cat > "$file" <<'EOF'
# User Stories & Jira Import

This directory contains user stories broken down from the PRD.

## Files

- `epic-template.md` - Template for breaking down epics into stories
- `jira-import.csv` - CSV file ready for Jira bulk import
- `epic-[N]-stories.md` - Stories for each epic (create these)

## Jira Import Instructions

### Step 1: Prepare CSV

1. Open `jira-import.csv`
2. Fill in actual epic and story details from PRD
3. Update priorities, story points, components
4. Ensure acceptance criteria are clear

### Step 2: Import to Jira

1. Go to Jira → Issues → Import issues from CSV
2. Upload `jira-import.csv`
3. Map CSV columns to Jira fields:
   - Issue Type → Issue Type
   - Summary → Summary
   - Description → Description
   - Priority → Priority
   - Story Points → Story Points
   - Epic Link → Epic Link
   - Component → Component
   - Labels → Labels
   - Acceptance Criteria → Custom field or Description

### Step 3: Verify Import

1. Check epic hierarchy is correct
2. Verify story points are assigned
3. Confirm acceptance criteria are visible
4. Link stories to epics

### Step 4: Story Refinement

1. Review stories with engineering team
2. Refine acceptance criteria
3. Update story points based on team estimates
4. Identify and document dependencies

## Story Quality Checklist

Before importing, verify each story:

- [ ] **INVEST criteria met**:
  - Independent
  - Negotiable
  - Valuable
  - Estimable
  - Small (<8 points)
  - Testable

- [ ] **Acceptance criteria**:
  - Uses Given/When/Then format
  - All criteria are testable
  - Includes success and error cases

- [ ] **Sizing**:
  - Story points assigned (Fibonacci scale)
  - Stories are right-sized (<8 points)
  - Large stories broken down

- [ ] **Traceability**:
  - Links to PRD requirement
  - Links to user need from interviews

## Sprint Planning

After import:

1. Calculate team velocity (story points/sprint)
2. Allocate stories to sprints based on priority
3. Identify sprint goals
4. Plan for dependencies

## Next Steps

1. Complete story breakdown for all PRD epics
2. Import to Jira
3. Story refinement session with engineering
4. Sprint planning
5. Run `/gbm.pm.align` for final stakeholder alignment
EOF

    log_success "Created: README.md"
}

create_stories_metadata() {
    local dir="$1"
    local feature="$2"
    local file="$dir/metadata.json"

    cat > "$file" <<EOF
{
  "feature": "$feature",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "command": "/gbm.pm.stories",
  "phase": "definition",
  "status": "in_progress",
  "artifacts": {
    "epic_template": "epic-template.md",
    "jira_import": "jira-import.csv",
    "readme": "README.md"
  },
  "total_epics": 0,
  "total_stories": 0,
  "total_story_points": 0,
  "next_steps": [
    "Break down PRD epics into stories",
    "Fill jira-import.csv",
    "Import to Jira",
    "/gbm.pm.align"
  ]
}
EOF

    log_success "Created: metadata.json"
}

# =============================================================================
# Execute
# =============================================================================

main "$@"
