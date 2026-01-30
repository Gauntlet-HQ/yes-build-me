#!/usr/bin/env bash
# pm-validate-problem.sh - Create validation checkpoint workspace for final go/no-go decision
set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# =============================================================================
# PM Problem Validation Checkpoint Setup
# =============================================================================

main() {
    log_info "Setting up PM validation checkpoint..."

    # Get feature name from arguments
    local feature_name="${1:-}"
    if [[ -z "$feature_name" ]]; then
        log_error "Feature name required"
        log_info "Usage: pm-validate-problem.sh <feature-name>"
        log_info "Example: pm-validate-problem.sh real-time-dashboard"
        exit 1
    fi

    # Get repo root and resolve feature directory (handles epic--slice paths)
    local repo_root=$(get_repo_root)
    local validation_dir=$(get_feature_dir "$repo_root" "$feature_name")
    mkdir -p "$validation_dir"

    # Create validation file
    local validation_file="${validation_dir}/validation-report.md"

    log_success "Created validation workspace: $validation_dir"

    # Check prerequisites
    check_prerequisites "$feature_name"

    # Create validation report template
    create_validation_report "$validation_file" "$feature_name"

    # Create validation metadata
    create_validation_metadata "$validation_dir" "$feature_name"

    log_info ""
    log_success "✅ PM Validation checkpoint initialized!"
    log_info ""
    log_info "Feature: $feature_name"
    log_info "Workspace: $validation_dir"
    log_info ""
    log_info "Files created:"
    log_info "  - validation-report.md    (Comprehensive validation with scorecard)"
    log_info "  - validation-metadata.json (Validation tracking)"
    log_info ""
    log_info "Next: Follow the /gbm.pm.validate-problem command to:"
    log_info "  1. Review all evidence (discovery, interviews, research)"
    log_info "  2. Score 6 dimensions (problem, market, competitive, demand, feasibility, evidence)"
    log_info "  3. Calculate overall validation score"
    log_info "  4. Make GO/NO-GO/NEED MORE DATA decision"
}

# =============================================================================
# Prerequisite Checking
# =============================================================================

check_prerequisites() {
    local feature="$1"
    local repo_root=$(get_repo_root)
    local base_dir=$(get_feature_dir "$repo_root" "$feature")

    log_info "Checking prerequisites..."

    # Check for discovery session
    if [[ ! -d ".gobuildme/specs/pm-discovery" ]]; then
        log_warning "Warning: No /gbm.pm.discover session found"
        log_info "  Recommended: Run /gbm.pm.discover first"
    else
        log_success "  ✓ Discovery session exists"
    fi

    # Check for interviews
    if [[ ! -d "${base_dir}/interviews" ]]; then
        log_warning "Warning: No /gbm.pm.interview workspace found"
        log_info "  Recommended: Run /gbm.pm.interview first"
    else
        log_success "  ✓ Interview workspace exists"
    fi

    # Check for research
    if [[ ! -d "${base_dir}/research" ]]; then
        log_warning "Warning: No /gbm.pm.research workspace found"
        log_info "  Recommended: Run /gbm.pm.research first"
    else
        log_success "  ✓ Research workspace exists"
    fi

    log_info "Prerequisite check complete"
}

# =============================================================================
# Template Creation Functions
# =============================================================================

create_validation_report() {
    local file="$1"
    local feature="$2"

    cat > "$file" <<'EOF'
# Problem Validation Report

**Problem/Opportunity:** [From /gbm.pm.discover]
**Validation Date:** [YYYY-MM-DD]
**Product Manager:** [Name]

---

## Executive Summary

**Problem Statement:**
[One-sentence problem from /gbm.pm.discover]

**Validation Verdict:** [GO / NO-GO / NEED MORE DATA]

**If GO:**
- Proceed to `/gbm.pm.prd` immediately
- Estimated business impact: [$X/month]
- Recommended timeline: [Z weeks/months]

---

## Evidence Summary

### Source 1: Discovery Session
**From:** `/gbm.pm.discover`
**Opportunity Score:** [X.XX out of ~15]
**Initial Confidence:** [High / Medium / Low]

### Source 2: User Interviews
**From:** `/gbm.pm.interview` ([N] interviews)
**Average Pain Score:** [X.X/10]
**Average Likelihood-to-Use:** [X.X/10]

### Source 3: Market Research
**From:** `/gbm.pm.research`
**TAM:** [$X billion]
**SAM:** [$Y million]
**SOM:** [$Z thousand]

### Source 4: Competitive Analysis
**Competitors Analyzed:** [N]
**Key Gaps Identified:** [N gaps]

### Source 5: Analytics Data
**Users Affected:** [N users, X%]
**Business Impact:** [$X/month]

### Source 6: Technical Feasibility
**Feasibility:** [YES / YES, BUT / NO]
**Effort Estimate:** [X person-weeks]

---

## Validation Scorecard

### Dimension 1: Problem Validation (Weight: 25%)

| Criterion | Score (0-10) | Reasoning |
|-----------|--------------|-----------|
| User pain severity | [X] | [Avg pain from interviews] |
| Frequency of problem | [X] | [How often users hit it] |
| Analytics confirmation | [X] | [Data shows problem] |
| Current workarounds | [X] | [Users spend time on workarounds] |

**Dimension 1 Average:** [X.X/10]
**Result:** [✅ Pass (≥7.0) / ❌ Fail]

---

### Dimension 2: Market Opportunity (Weight: 15%)

| Criterion | Score (0-10) | Reasoning |
|-----------|--------------|-----------|
| Market size | [X] | [TAM/SAM assessment] |
| Market growth | [X] | [Growing / Stable / Declining] |
| Target segment clarity | [X] | [Clear segment defined] |
| Market timing | [X] | [Now is right time] |

**Dimension 2 Average:** [X.X/10]
**Result:** [✅ Pass (≥6.0) / ❌ Fail]

---

### Dimension 3: Competitive Advantage (Weight: 15%)

| Criterion | Score (0-10) | Reasoning |
|-----------|--------------|-----------|
| Competitive gaps exist | [X] | [Clear gaps identified] |
| Differentiation potential | [X] | [Unique approach] |
| Positioning clarity | [X] | [Clear positioning] |
| Barriers to entry | [X] | [Defensible] |

**Dimension 3 Average:** [X.X/10]
**Result:** [✅ Pass (≥6.0) / ❌ Fail]

---

### Dimension 4: User Demand (Weight: 25%)

| Criterion | Score (0-10) | Reasoning |
|-----------|--------------|-----------|
| Likelihood to adopt | [X] | [Avg from interviews] |
| Willingness to pay | [X] | [Users mention budget] |
| Urgency | [X] | [Critical need] |
| User validation | [X] | [N users would use today] |

**Dimension 4 Average:** [X.X/10]
**Result:** [✅ Pass (≥7.0) / ❌ Fail]

---

### Dimension 5: Feasibility & ROI (Weight: 10%)

| Criterion | Score (0-10) | Reasoning |
|-----------|--------------|-----------|
| Technical feasibility | [X] | [YES:10, YES-BUT:6, NO:0] |
| Effort vs. impact | [X] | [High ROI / Low ROI] |
| Resource availability | [X] | [Team available] |
| Risk level | [X] | [Low / Medium / High risk] |

**Dimension 5 Average:** [X.X/10]
**Result:** [✅ Pass (≥6.0) / ❌ Fail]

---

### Dimension 6: Evidence Quality (Weight: 10%)

| Criterion | Score (0-10) | Reasoning |
|-----------|--------------|-----------|
| Sample size | [X] | [N interviews sufficient] |
| Source diversity | [X] | [Qual + quant + competitive] |
| Data freshness | [X] | [Recent data] |
| Triangulation | [X] | [Sources agree] |

**Dimension 6 Average:** [X.X/10]
**Result:** [✅ Pass (≥7.0) / ❌ Fail]

---

## Overall Validation Score

**Calculation:**
```
Overall Score = (
  Dimension 1 × 25% +
  Dimension 2 × 15% +
  Dimension 3 × 15% +
  Dimension 4 × 25% +
  Dimension 5 × 10% +
  Dimension 6 × 10%
) / 10
```

**Overall Validation Score:** [X.X/10]

**Score Interpretation:**
- **8.0-10.0**: Strong validation → **GO**
- **6.0-7.9**: Good validation → **GO** (with de-risking)
- **4.0-5.9**: Weak validation → **NEED MORE DATA**
- **0.0-3.9**: Failed validation → **NO-GO**

---

## Critical Success Factors

- [ ] Problem is real (≥7/10 severity)
- [ ] Problem is frequent
- [ ] Business impact quantified
- [ ] User demand strong (≥60% likely-to-use ≥7/10)
- [ ] Market size adequate
- [ ] Competitive gap identified
- [ ] Technical feasibility confirmed
- [ ] Evidence quality high (≥10 interviews + data)
- [ ] All assumptions validated
- [ ] Stakeholder alignment

**Critical Success Factors Met:** [X/10]
**Threshold:** ≥8/10
**Result:** [✅ Pass / ❌ Fail]

---

## Risk Assessment

**Risk 1: [Risk name]**
- **Category:** [Market / Technical / Competitive / Adoption]
- **Likelihood:** [High / Medium / Low]
- **Impact:** [High / Medium / Low]
- **Mitigation:** [How to reduce]
- **Acceptable?** [Yes / No]

**Overall Risk Level:** [High / Medium / Low]

---

## Final Decision

### Decision Matrix

| Criterion | Threshold | Actual | Pass? |
|-----------|-----------|--------|-------|
| Overall Validation Score | ≥6.0 | [X.X/10] | [✅/❌] |
| Critical Success Factors | ≥8/10 | [Y/10] | [✅/❌] |
| All Dimensions Pass | 6 of 6 | [Z of 6] | [✅/❌] |
| Risk Acceptable | Yes | [Yes/No] | [✅/❌] |

**All Criteria Met:** [✅ Yes / ❌ No]

---

### ✅ GO Decision

**We will proceed to PRD because:**
1. [Reason 1 - overall score high]
2. [Reason 2 - all critical factors met]
3. [Reason 3 - clear differentiation]
4. [Reason 4 - technical feasibility confirmed]

**Next Steps:**
1. Run `/gbm.pm.prd` immediately
2. Timeline: [X weeks to launch]
3. Team: [N engineers, M designers]

---

### ❌ NO-GO Decision

**We will NOT proceed because:**
1. [Reason 1 - weak validation]
2. [Reason 2 - failed dimension]
3. [Reason 3 - contradictory evidence]

**Next Steps:**
1. Document learnings
2. Return to `/gbm.pm.discover` for different problem

---

### ⚠️ NEED MORE DATA Decision

**We cannot decide yet because:**
1. [Gap 1]
2. [Gap 2]

**De-Risking Plan:**

| Gap | Target | How to Get | Timeline |
|-----|--------|------------|----------|
| [Gap 1] | [What we need] | [Method] | [X weeks] |

**Re-Validation Checkpoint:** [Date]

---

**Document Version:** 1.0
**Last Updated:** [YYYY-MM-DD]
EOF

    log_success "Created: validation-report.md"
}

create_validation_metadata() {
    local dir="$1"
    local feature="$2"
    local file="$dir/validation-metadata.json"

    cat > "$file" <<EOF
{
  "feature": "$feature",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "command": "/gbm.pm.validate-problem",
  "phase": "discovery",
  "status": "validation_pending",
  "artifacts": {
    "validation_report": "validation-report.md"
  },
  "decision": null,
  "overall_score": null,
  "next_steps": []
}
EOF

    log_success "Created: validation-metadata.json"
}

# =============================================================================
# Execute
# =============================================================================

main "$@"
