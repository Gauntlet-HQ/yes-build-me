#!/usr/bin/env bash
# pm-handoff.sh - Create engineering handoff checklist and kickoff plan
set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# =============================================================================
# PM Handoff Setup
# =============================================================================

main() {
    log_info "Setting up PM engineering handoff..."

    # Get feature name from arguments
    local feature_name="${1:-}"
    if [[ -z "$feature_name" ]]; then
        log_error "Feature name required"
        log_info "Usage: pm-handoff.sh <feature-name>"
        log_info "Example: pm-handoff.sh real-time-dashboard"
        exit 1
    fi

    # Get repo root and resolve feature directory (handles epic--slice paths)
    local repo_root=$(get_repo_root)
    local spec_dir=$(get_feature_dir "$repo_root" "$feature_name")
    mkdir -p "$spec_dir"

    # Create handoff file
    local handoff_file="${spec_dir}/handoff-checklist.md"

    log_success "Created handoff workspace: $spec_dir"

    # Check prerequisites
    check_prerequisites "$feature_name"

    # Create handoff checklist
    create_handoff_template "$handoff_file" "$feature_name"

    log_info ""
    log_success "✅ PM Handoff checklist initialized!"
    log_info ""
    log_info "Feature: $feature_name"
    log_info "Checklist: $handoff_file"
    log_info ""
    log_info "Next: Follow the /gbm.pm.handoff command to:"
    log_info "  1. Verify pre-handoff checklist"
    log_info "  2. Schedule kickoff meeting"
    log_info "  3. Present feature context to engineering"
    log_info "  4. Define PM support plan"
    log_info "  5. Development starts!"
}

check_prerequisites() {
    local feature="$1"
    local repo_root=$(get_repo_root)
    local base_dir=$(get_feature_dir "$repo_root" "$feature")

    log_info "Checking prerequisites..."

    if [[ ! -f "${base_dir}/alignment-checklist.md" ]]; then
        log_warning "Warning: No alignment checklist found"
        log_info "  Recommended: Run /gbm.pm.align first"
    else
        log_success "  ✓ Alignment checklist exists"
    fi

    log_info "Prerequisite check complete"
}

create_handoff_template() {
    local file="$1"
    local feature="$2"

    cat > "$file" <<'EOF'
# Engineering Handoff Checklist

**Feature:** [Feature name from PRD]
**PM Owner:** [Your name]
**Engineering Lead:** [Name]
**Handoff Date:** [YYYY-MM-DD]
**Development Start:** [YYYY-MM-DD]

---

## Pre-Handoff Verification

**Before scheduling kickoff:**

### Documentation Complete
- [ ] PRD finalized and approved
- [ ] User stories created and imported to Jira
- [ ] Alignment checklist complete with all sign-offs
- [ ] All discovery artifacts available

### Design Assets Ready
- [ ] Wireframes complete
- [ ] High-fidelity mockups complete
- [ ] Design system components identified
- [ ] Figma/Sketch links shared

### Technical Preparation
- [ ] Technical design document reviewed
- [ ] API contracts defined
- [ ] Development environment ready
- [ ] Feature flags configured

### Resources Allocated
- [ ] Engineering team assigned ([N] engineers)
- [ ] Designer assigned
- [ ] QA engineer assigned
- [ ] Sprint capacity confirmed

### Stakeholder Alignment
- [ ] All required sign-offs obtained
- [ ] All high-severity concerns resolved

**All Items Complete:** [✅ Yes / ❌ No]

---

## Kickoff Meeting (90 minutes)

**Date:** [YYYY-MM-DD]
**Time:** [HH:MM]
**Location:** [Room / Zoom link]

**Required Attendees:**
- PM Owner: [Name]
- Engineering Lead: [Name]
- Engineers: [Names]
- Designer: [Name]
- QA Lead: [Name]

---

### Agenda

**1. Feature Context (15 min)**
- Problem statement
- Target users
- Business impact
- Success metrics

**2. Solution Overview (20 min)**
- High-level approach
- Key components
- User flows
- Design walkthrough

**3. Requirements (20 min)**
- P0 requirements walkthrough
- Acceptance criteria
- Out of scope

**4. Sprint Plan (15 min)**
- Total effort: [X story points]
- Sprint allocation
- Milestones
- Launch timeline

**5. Dependencies & Risks (10 min)**
- Critical dependencies
- Top risks

**6. Roles & Responsibilities (5 min)**
- PM role during development
- Engineering Lead role
- Designer role
- QA role

**7. Q&A (15 min)**

---

## PM Support Plan

**PM Availability:**
- Slack: <2hr response time
- Office Hours: [Day/Time]
- Weekly 1:1 with Eng Lead: [Day/Time]

**Sprint Ceremonies:**
- Daily Standup: [Time]
- Sprint Planning: [Day/Time] (Every 2 weeks)
- Sprint Review/Demo: [Day/Time] (Every 2 weeks)
- Sprint Retro: [Day/Time] (Every 2 weeks)

**Decision Framework:**
- Small decisions: Engineering Lead decides
- Medium decisions: PM + Eng Lead together
- Large decisions (scope): PM after stakeholder consult

---

## Milestones

**Sprint 1:** [Goal]
- [ ] Story 1.1
- [ ] Story 1.2
- **Status:** [On Track / At Risk / Blocked]

**Launch Milestones:**
- [ ] Alpha Launch (Week [X]) - [Date]
- [ ] Beta Launch (Week [Y]) - [Date]
- [ ] GA Launch (Week [Z]) - [Date]

---

## Success Metrics Tracking

| Metric | Baseline | Target | Current | Status |
|--------|----------|--------|---------|--------|
| [Metric 1] | [X] | [Y] | [Z] | [🟢/🟡/🔴] |
| [Metric 2] | [X] | [Y] | [Z] | [🟢/🟡/🔴] |

---

## Handoff Complete

**Feature:** [Feature name]
**Handoff Date:** [YYYY-MM-DD]
**Development Start:** [YYYY-MM-DD]
**Expected Launch:** [YYYY-MM-DD]

**Sign-Off:**
- PM Owner: __________ Date: __________
- Engineering Lead: __________ Date: __________

**Status:** ✅ **DEVELOPMENT IN PROGRESS**

**Ongoing Support:**
- PM available via Slack `#feature-[name]`
- Weekly check-ins: [Day/Time]
- Next milestone: [Milestone] - [Date]

---

**Good luck, team! 🚀**
EOF

    log_success "Created: handoff-checklist.md"
}

main "$@"
