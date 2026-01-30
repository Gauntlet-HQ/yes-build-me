#!/usr/bin/env bash
# pm-align.sh - Create stakeholder alignment checklist with RACI matrix
set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# =============================================================================
# PM Alignment Setup
# =============================================================================

main() {
    log_info "Setting up PM alignment checklist..."

    # Get feature name from arguments
    local feature_name="${1:-}"
    if [[ -z "$feature_name" ]]; then
        log_error "Feature name required"
        log_info "Usage: pm-align.sh <feature-name>"
        log_info "Example: pm-align.sh real-time-dashboard"
        exit 1
    fi

    # Get repo root and resolve feature directory (handles epic--slice paths)
    local repo_root=$(get_repo_root)
    local spec_dir=$(get_feature_dir "$repo_root" "$feature_name")
    mkdir -p "$spec_dir"

    # Create alignment file
    local alignment_file="${spec_dir}/alignment-checklist.md"

    log_success "Created alignment workspace: $spec_dir"

    # Check prerequisites
    check_prerequisites "$feature_name"

    # Create alignment checklist template
    create_alignment_template "$alignment_file" "$feature_name"

    log_info ""
    log_success "✅ PM Alignment checklist initialized!"
    log_info ""
    log_info "Feature: $feature_name"
    log_info "Checklist: $alignment_file"
    log_info ""
    log_info "Next: Follow the /gbm.pm.align command to:"
    log_info "  1. Identify all stakeholders"
    log_info "  2. Create RACI matrix"
    log_info "  3. Conduct alignment meetings"
    log_info "  4. Obtain required sign-offs"
    log_info "  5. Make GO/NO-GO decision"
}

check_prerequisites() {
    local feature="$1"
    local repo_root=$(get_repo_root)
    local base_dir=$(get_feature_dir "$repo_root" "$feature")

    log_info "Checking prerequisites..."

    if [[ ! -f "${base_dir}/prd.md" ]]; then
        log_warning "Warning: No PRD found"
    else
        log_success "  ✓ PRD exists"
    fi

    if [[ ! -d "${base_dir}/stories" ]]; then
        log_warning "Warning: No stories found"
    else
        log_success "  ✓ Stories exist"
    fi

    log_info "Prerequisite check complete"
}

create_alignment_template() {
    local file="$1"
    local feature="$2"

    cat > "$file" <<'EOF'
# Stakeholder Alignment Checklist

**Feature:** [Feature name from PRD]
**PM Owner:** [Your name]
**Alignment Date:** [YYYY-MM-DD]

---

## Stakeholders

**Required Sign-Off:**

| Role | Name | Department | Sign-Off Required | Status |
|------|------|------------|-------------------|--------|
| Engineering Lead | [Name] | Engineering | ✅ Yes | ⏳ Pending |
| Design Lead | [Name] | Design | ✅ Yes | ⏳ Pending |
| QA Lead | [Name] | Quality | ✅ Yes | ⏳ Pending |
| Security Lead | [Name] | Security | ✅ Yes | ⏳ Pending |

---

## RACI Matrix

**R**esponsible | **A**ccountable | **C**onsulted | **I**nformed

| Activity | PM | Eng Lead | Design | QA | Security |
|----------|----|---------:|-------|----|----------|
| PRD Creation | A | C | C | C | C |
| Technical Design | C | A,R | I | C | C |
| Development | C | A,R | I | I | I |
| Testing | C | C | I | A,R | C |
| Go-Live Decision | A | C | C | C | C |

---

## Alignment Meetings

### Engineering Alignment (60 min)

**Attendees:** PM, Engineering Lead, Tech Leads

**Checklist:**
- [ ] Engineering understands problem and user needs
- [ ] Technical approach agreed upon
- [ ] All P0 stories clear and estimated
- [ ] Dependencies identified
- [ ] Timeline realistic
- [ ] Resources confirmed

**Sign-Off:** Engineering Lead: __________ Date: __________

---

### Design Alignment (45 min)

**Attendees:** PM, Design Lead, Designers

**Checklist:**
- [ ] Design understands user needs
- [ ] Mockups address PRD requirements
- [ ] Design assets ready
- [ ] Accessibility requirements met

**Sign-Off:** Design Lead: __________ Date: __________

---

### QA Alignment (30 min)

**Attendees:** PM, QA Lead

**Checklist:**
- [ ] QA understands acceptance criteria
- [ ] Test strategy defined
- [ ] QA resources allocated

**Sign-Off:** QA Lead: __________ Date: __________

---

### Security Review (30 min)

**Attendees:** PM, Security Lead

**Checklist:**
- [ ] Security requirements reviewed
- [ ] Threat model completed
- [ ] No blocking security concerns

**Sign-Off:** Security Lead: __________ Date: __________

---

## Concerns & Resolutions

| ID | Concern | Raised By | Severity | Resolution | Status |
|----|---------|-----------|----------|------------|--------|
| C-1 | [Concern] | [Name] | [High/Med/Low] | [How resolved] | ⏳ Open |

---

## GO/NO-GO Decision

**Final Alignment Check:**

| Criteria | Status |
|----------|--------|
| All required sign-offs obtained | [✅/❌] |
| All high-severity concerns resolved | [✅/❌] |
| Engineering confident in timeline | [✅/❌] |
| Design assets ready | [✅/❌] |
| Resources allocated | [✅/❌] |

**All Criteria Met:** [✅ Yes / ❌ No]

---

## ✅ GO Decision

**We are aligned and ready to start development.**

**Next Steps:**
1. Run `/gbm.pm.handoff` to formally hand off to engineering
2. Development starts

---

## ❌ NO-GO

**Blocking Issues:**
1. [Issue 1]
2. [Issue 2]

**Re-Alignment Date:** [YYYY-MM-DD]

---

**Document Version:** 1.0
**Last Updated:** [YYYY-MM-DD]
**Status:** [Draft / Aligned / Approved]
EOF

    log_success "Created: alignment-checklist.md"
}

main "$@"
