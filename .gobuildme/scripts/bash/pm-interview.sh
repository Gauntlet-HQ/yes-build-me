#!/usr/bin/env bash
# pm-interview.sh - Create interview workspace for PM user research
set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# =============================================================================
# PM Interview Workspace Setup
# =============================================================================

main() {
    log_info "Setting up PM interview workspace..."

    # Get feature name from arguments or prompt
    local feature_name="${1:-}"
    if [[ -z "$feature_name" ]]; then
        log_error "Feature name required"
        log_info "Usage: pm-interview.sh <feature-name>"
        log_info "Example: pm-interview.sh real-time-dashboard"
        exit 1
    fi

    # Check prerequisites
    check_prerequisites

    # Get repo root and resolve feature directory (handles epic--slice paths)
    local repo_root=$(get_repo_root)
    local spec_dir=$(get_feature_dir "$repo_root" "$feature_name")

    # Create interview workspace directory
    local interview_dir="${spec_dir}/interviews"
    mkdir -p "$interview_dir"

    log_success "Created interview workspace: $interview_dir"

    # Create interview guide template
    create_interview_guide "$interview_dir"

    # Create synthesis template
    create_synthesis_template "$interview_dir"

    # Create interview notes template (first 3 as examples)
    for i in {1..3}; do
        create_interview_note "$interview_dir" "$(printf '%02d' $i)"
    done

    # Create interview metadata
    create_interview_metadata "$interview_dir" "$feature_name"

    log_info ""
    log_success "✅ PM Interview workspace initialized!"
    log_info ""
    log_info "Feature: $feature_name"
    log_info "Workspace: $interview_dir"
    log_info ""
    log_info "Files created:"
    log_info "  - interview-guide.md      (Research questions & script)"
    log_info "  - interview-01.md         (First interview template)"
    log_info "  - interview-02.md         (Second interview template)"
    log_info "  - interview-03.md         (Third interview template)"
    log_info "  - synthesis.md            (Cross-interview analysis)"
    log_info "  - metadata.json           (Interview tracking)"
    log_info ""
    log_info "Next: Follow the /gbm.pm.interview command to:"
    log_info "  1. Plan interviews (create interview guide)"
    log_info "  2. Conduct 10-15 interviews (copy interview-01.md template)"
    log_info "  3. Synthesize findings (after 10+ interviews)"
}

# =============================================================================
# Prerequisite Checking
# =============================================================================

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check for discovery artifacts
    local discovery_dirs=(.gobuildme/specs/pm-discovery/*)

    # Check if glob found any directories and if first one exists
    if [ ${#discovery_dirs[@]} -eq 0 ] || [ ! -e "${discovery_dirs[0]}" ]; then
        log_warning "Warning: No /gbm.pm.discover artifacts found"
        log_info "  Recommended: Run /gbm.pm.discover first"
        log_info "  This helps identify the problem/hypothesis to validate"
    else
        log_success "  ✓ Discovery artifacts exist"
    fi

    log_info "Prerequisite check complete"
}

# =============================================================================
# Template Creation Functions
# =============================================================================

create_interview_guide() {
    local dir="$1"
    local file="$dir/interview-guide.md"

    cat > "$file" <<'EOF'
# Interview Guide

**Feature/Problem:** [From /gbm.pm.discover]
**Created:** [YYYY-MM-DD]
**PM:** [Your name]
**Target Participants:** [N interviews planned]

---

## Research Questions

**Primary Research Questions** (What we need to learn):

1. [Question 1 - e.g., "How do users currently handle [X]?"]
2. [Question 2 - e.g., "What's the most frustrating part of [Y]?"]
3. [Question 3 - e.g., "Would users adopt [solution concept]?"]
4. [Question 4 - e.g., "What's the acceptable price point?"]
5. [Question 5 - e.g., "What features are must-haves vs. nice-to-haves?"]

**Hypotheses to Validate** (From /gbm.pm.discover):
1. [Hypothesis 1 from discovery]
2. [Hypothesis 2 from discovery]
3. [Hypothesis 3 from discovery]

---

## Target Participants

**Who to Interview:**

**Persona 1: [Persona name]**
- **Role:** [e.g., "Account Manager, B2B SaaS companies"]
- **Target Count:** [N interviews]
- **Why Them:** [Why this persona is important]
- **Recruitment Method:** [How to find them - e.g., "Existing users", "LinkedIn outreach"]

**Persona 2: [Persona name]**
- **Role:** [e.g., "Sales Operations Manager"]
- **Target Count:** [N interviews]
- **Why Them:** [Why this persona is important]
- **Recruitment Method:** [How to find them]

**Total Target:** [N total interviews] (minimum 10 recommended)

**Screening Criteria:**
- ✅ Must have: [e.g., "Uses product X daily"]
- ✅ Must have: [e.g., "Experienced problem Y in last 30 days"]
- ❌ Exclude: [e.g., "Free trial users (not paying customers)"]

---

## Interview Script (60 minutes)

Use this script as a guide, but allow conversation to flow naturally.

### Introduction (5 minutes)

**Purpose:** Build rapport, set expectations

"Hi [Name], thanks for taking the time to speak with me today. I'm [Your Name], a Product Manager at [Company]. We're researching [problem space] to better understand how teams like yours work.

This conversation will take about 60 minutes. I'll be asking you about your current workflow, challenges you face, and your thoughts on some concepts we're exploring.

**Important:** There are no right or wrong answers. We're here to learn from your experience. Everything you share will be confidential and used only to improve our product.

Do you have any questions before we start? Great, let's begin."

**[Ask for permission to record if recording]**

---

### Current State (10-15 minutes)

**Goal:** Understand how they work today

1. "Walk me through how you currently [do X related to problem]."
   - Follow-up: "How often do you do this?" (frequency)
   - Follow-up: "How long does it typically take?" (time investment)

2. "What tools do you use for [activity]?"
   - Follow-up: "What do you like about [tool]?"
   - Follow-up: "What frustrates you about it?"

3. "When was the last time you [did this activity]?"
   - Follow-up: "Tell me about that experience in detail."

**Listen for:** Workarounds, manual steps, time spent, frustration signals

---

### Pain Points (10-15 minutes)

**Goal:** Validate problem severity

1. "What's the hardest part about [activity related to problem]?"
   - Follow-up: "Can you give me a specific example?"
   - Follow-up: "How does that impact your work?"

2. "On a scale of 1-10, how painful is [problem]? Why that number?"
   - ✅ **Record score for synthesis**
   - Follow-up: "What would make it a 10?"
   - Follow-up: "What would make it a 1?"

3. "How much time do you lose per week because of [problem]?"
   - Follow-up: "What else could you do with that time?"

4. "Have you tried to solve this problem? How?"
   - Follow-up: "What worked? What didn't?"

**Listen for:** Emotional language ("frustrating", "annoying", "hate"), time/money costs, business impact

---

### Workarounds & Alternatives (10-15 minutes)

**Goal:** Understand what they've tried

1. "What have you tried to solve or work around [problem]?"
   - Follow-up: "Why did you choose that approach?"
   - Follow-up: "How well does it work?"

2. "Have you looked at [Competitor A] or [Competitor B]?"
   - Follow-up: "What did you think of them?"
   - Follow-up: "Why didn't you adopt them?" (if they didn't)

3. "If you could wave a magic wand and fix this problem, what would change?"
   - Follow-up: "What's the ideal solution in your mind?"

**Listen for:** Willingness to try alternatives, what they value, why existing solutions fail

---

### Solution Exploration (10-15 minutes)

**Goal:** Gauge interest in proposed solution

1. **Describe Solution Concept** (2-3 minutes)
   "[Brief description of solution concept from /gbm.pm.discover hypothesis]"

2. "What's your initial reaction to this?"
   - Follow-up: "What excites you about it?"
   - Follow-up: "What concerns you?"

3. "On a scale of 1-10, how likely would you be to use this?"
   - ✅ **Record score for synthesis**
   - Follow-up: "Why that number?"
   - Follow-up: "What would make you more likely to use it?"

4. "What's the most important feature for you?"
   - Follow-up: "Why that one?"
   - Follow-up: "What else is a must-have?"

5. "How much would you expect to pay for this?"
   - Follow-up: "What's the maximum you'd pay?"
   - Follow-up: "At what price does it become too expensive?"

**Listen for:** Genuine interest vs. politeness, must-have vs. nice-to-have features, price sensitivity

---

### Wrap-Up (5 minutes)

**Goal:** Confirm understanding, get referrals

1. "Is there anything I didn't ask about that you think is important?"

2. "Do you know anyone else who might have insights on this problem?"
   - **Get 1-2 referrals per interview** (snowball sampling)

3. "Thank you so much for your time. Would you be open to a follow-up conversation in a few weeks?"
   - ✅ **Record for future research panel**

4. "We'll share what we learn from this research. Can I send you a summary?"

---

## Interview Best Practices

**During the Interview:**
- ✅ **DO:** Ask "Why?" and "Can you give an example?" frequently
- ✅ **DO:** Let silence hang (don't fill it - let them think)
- ✅ **DO:** Probe for specific stories, not hypotheticals
- ✅ **DO:** Take notes on direct quotes (capture their exact words)
- ❌ **DON'T:** Lead with your solution ("Would you like it if we built X?")
- ❌ **DON'T:** Ask yes/no questions ("Do you have this problem?")
- ❌ **DON'T:** Defend your product or get defensive
- ❌ **DON'T:** Oversell - this is research, not a sales call

**After the Interview:**
- Write up notes within 24 hours (while fresh)
- Extract key quotes verbatim
- Note pain score and likelihood-to-use score
- Identify recurring themes vs. one-off comments

---

## Pilot Interview

**Before conducting all interviews:**
1. Do 1 pilot interview
2. Review script - what worked, what didn't?
3. Adjust questions based on pilot learnings
4. Then proceed with remaining interviews

**Pilot Completed:** [ ] Yes / [ ] No
**Pilot Date:** [YYYY-MM-DD]
**Adjustments Made:** [What changed after pilot]
EOF

    log_success "Created: interview-guide.md"
}

create_interview_note() {
    local dir="$1"
    local num="$2"
    local file="$dir/interview-${num}.md"

    cat > "$file" <<'EOF'
# Interview [NN]: [Participant Name/Company]

**Date:** [YYYY-MM-DD]
**Time:** [HH:MM - HH:MM] ([Duration] minutes)
**Interviewer:** [PM name]
**Format:** [Video / Phone / In-person]

---

## Participant Profile

**Name:** [First name or pseudonym]
**Role:** [Job title]
**Company:** [Company name]
**Industry:** [Industry]
**Company Size:** [N employees]
**Experience:** [Years in role]

**Persona:** [Which persona from interview guide]

**Screener Qualification:**
- Uses [Product X]: [Yes / No]
- Experiences [Problem Y]: [Yes / No]
- [Other criteria]: [Yes / No]

---

## Interview Notes

### Current State

**How they currently do [activity]:**
[Notes from interview - what's their current workflow?]

**Tools they use:**
- [Tool 1]: [What they use it for, what they like/dislike]
- [Tool 2]: [What they use it for, what they like/dislike]

**Frequency:** [How often they do this - daily, weekly, monthly]
**Time Investment:** [How long it takes them - minutes, hours per week]

**Key Quote:**
> "[Exact quote about current state]"

---

### Pain Points

**Main Pain Point:**
[Most frustrating part of current workflow]

**Pain Severity Score:** [X/10]
**Reasoning:** [Why they gave that score]

**Impact on Work:**
[How this pain affects their job, productivity, etc.]

**Time Lost:** [X hours per week / month]
**Business Impact:** [Revenue, cost, efficiency impact]

**Key Quote:**
> "[Exact quote about pain - capture emotional language]"

---

### Workarounds & Alternatives

**Current Workarounds:**
1. [Workaround 1 - how they cope with the problem]
2. [Workaround 2]

**Alternatives Considered:**
- **[Competitor A]:** [Their experience, why they did/didn't adopt]
- **[Competitor B]:** [Their experience, why they did/didn't adopt]

**Ideal Solution** (magic wand question):
[What they wish existed]

**Key Quote:**
> "[Quote about workarounds or ideal solution]"

---

### Solution Reaction

**Initial Reaction:**
[First impressions when you described solution concept]

**Excitement Level:**
[What they seemed excited about]

**Concerns:**
[What worried them about the solution]

**Likelihood to Use Score:** [X/10]
**Reasoning:** [Why they gave that score]

**Must-Have Features:**
1. [Feature 1 - they said this is essential]
2. [Feature 2]
3. [Feature 3]

**Nice-to-Have Features:**
1. [Feature 1 - they'd like but not essential]
2. [Feature 2]

**Pricing Feedback:**
- Expected Price: [$X per month/year]
- Maximum Price: [$Y - "anything above this is too expensive"]
- Value Justification: [How they think about ROI]

**Key Quote:**
> "[Quote about solution concept reaction]"

---

### Hypothesis Validation

**Hypothesis 1:** [From /gbm.pm.discover]
- **Validated:** [✅ Yes / ⚠️ Partially / ❌ No]
- **Evidence:** [What they said that validates/invalidates]

**Hypothesis 2:** [From /gbm.pm.discover]
- **Validated:** [✅ Yes / ⚠️ Partially / ❌ No]
- **Evidence:** [What they said]

**Hypothesis 3:** [From /gbm.pm.discover]
- **Validated:** [✅ Yes / ⚠️ Partially / ❌ No]
- **Evidence:** [What they said]

---

### Other Insights

**Unexpected Findings:**
[Anything surprising or not in interview guide]

**Related Problems Mentioned:**
[Other pain points they brought up]

**Context/Constraints:**
[Company policies, budgets, technical constraints they mentioned]

---

### Follow-Up

**Referrals Provided:**
1. [Name, role, company - how to reach them]
2. [Name, role, company]

**Interested in Future Research:** [Yes / No]
**Want Summary of Findings:** [Yes / No]
**Contact Info:** [Email for follow-up]

---

## Interviewer Reflection

**Confidence in This Interview:** [High / Medium / Low]
**Why:** [Data quality, participant engagement, etc.]

**Key Takeaways:**
1. [Takeaway 1]
2. [Takeaway 2]
3. [Takeaway 3]

**Questions to Add/Remove:**
[Adjustments for next interviews based on this one]

---

**Interview Quality:** [✅ High / ⚠️ Medium / ❌ Low]
**Include in Synthesis:** [✅ Yes / ❌ No - if no, explain why]
EOF

    log_success "Created: interview-${num}.md"
}

create_synthesis_template() {
    local dir="$1"
    local file="$dir/synthesis.md"

    cat > "$file" <<'EOF'
# Interview Synthesis

**Feature/Problem:** [From /gbm.pm.discover]
**Synthesis Date:** [YYYY-MM-DD]
**PM:** [Your name]
**Interviews Analyzed:** [N interviews]

---

## Executive Summary

**Research Goal:** [What we wanted to learn]

**Key Finding 1:** [Most important insight]
**Key Finding 2:** [Second most important insight]
**Key Finding 3:** [Third most important insight]

**Recommendation:** [Proceed / Pivot / Stop - based on synthesis]

---

## Participant Overview

**Total Interviews:** [N]
**Date Range:** [YYYY-MM-DD to YYYY-MM-DD]

**Personas:**
- [Persona 1]: [N interviews]
- [Persona 2]: [N interviews]

**Companies Represented:**
- [N companies]
- Industries: [List industries]
- Company sizes: [Range - e.g., "50-500 employees"]

**Interview Quality:**
- High quality: [N interviews]
- Medium quality: [N interviews]
- Low quality (excluded): [N interviews]

---

## Themes by Frequency

**Theme Categories:**
- **Strong Pattern:** Mentioned by ≥70% of participants
- **Moderate Pattern:** Mentioned by 40-69% of participants
- **Weak Signal:** Mentioned by <40% of participants

### Strong Patterns

**Theme 1:** [Theme name]
- **Frequency:** [X/N participants - X%]
- **Description:** [What they said consistently]
- **Quotes:**
  > "[Quote from Interview 1]"
  > "[Quote from Interview 2]"
  > "[Quote from Interview 3]"
- **Implications:** [What this means for solution]

**Theme 2:** [Theme name]
- **Frequency:** [X/N participants - X%]
- **Description:** [What they said]
- **Quotes:** [3+ quotes]
- **Implications:** [What this means]

**Theme 3:** [Theme name]
[Same structure]

### Moderate Patterns

**Theme 4:** [Theme name]
- **Frequency:** [X/N participants - X%]
- **Description:** [What they said]
- **Quotes:** [2-3 quotes]
- **Implications:** [What this means]

[Continue with other moderate themes]

### Weak Signals

**Theme X:** [Theme name]
- **Frequency:** [X/N participants - X%]
- **Description:** [What they said]
- **Note:** [Why this might still be important despite low frequency]

---

## Pain Severity Analysis

### Pain Severity Distribution

| Pain Score | Count | % of Total | Personas |
|------------|-------|------------|----------|
| 9-10 (Critical) | [N] | [X%] | [Which personas rated it this high] |
| 7-8 (High) | [N] | [X%] | [Which personas] |
| 5-6 (Medium) | [N] | [X%] | [Which personas] |
| 3-4 (Low) | [N] | [X%] | [Which personas] |
| 1-2 (Minimal) | [N] | [X%] | [Which personas] |

**Average Pain Score:** [X.X/10]
**Median Pain Score:** [X/10]
**Mode (Most Common):** [X/10]

**Interpretation:**
[What the pain severity tells us - is problem real and significant?]

### Pain Severity by Persona

**[Persona 1]:**
- Average pain: [X.X/10]
- Most painful aspect: [What hurts most for this persona]

**[Persona 2]:**
- Average pain: [X.X/10]
- Most painful aspect: [What hurts most for this persona]

**Primary vs. Secondary Users:**
[Who feels the pain more acutely?]

---

## Likelihood to Adopt Analysis

### Likelihood-to-Use Distribution

| Likelihood Score | Count | % of Total | Interpretation |
|------------------|-------|------------|----------------|
| 9-10 (Definitely) | [N] | [X%] | Would use immediately |
| 7-8 (Likely) | [N] | [X%] | Strong interest |
| 5-6 (Maybe) | [N] | [X%] | Lukewarm |
| 3-4 (Unlikely) | [N] | [X%] | Not interested |
| 1-2 (Definitely Not) | [N] | [X%] | Would not use |

**Average Likelihood:** [X.X/10]
**Median Likelihood:** [X/10]

**Interpretation:**
[What the adoption likelihood tells us - is there real demand?]

### Demand by Persona

**[Persona 1]:**
- Average likelihood: [X.X/10]
- Why they'd use it: [Key motivators]

**[Persona 2]:**
- Average likelihood: [X.X/10]
- Why they'd use it: [Key motivators]

---

## Hypothesis Validation

### Hypothesis 1: [From /gbm.pm.discover]

**Validation Result:** [✅ Validated / ⚠️ Partially Validated / ❌ Invalidated]

**Evidence:**
- [N/M participants confirmed this]
- Key supporting quotes: [2-3 quotes]
- Contradictory evidence: [If any]

**Conclusion:** [What we learned]

### Hypothesis 2: [From /gbm.pm.discover]

**Validation Result:** [✅ Validated / ⚠️ Partially Validated / ❌ Invalidated]

[Same structure]

### Hypothesis 3: [From /gbm.pm.discover]

**Validation Result:** [✅ Validated / ⚠️ Partially Validated / ❌ Invalidated]

[Same structure]

**Overall Hypothesis Validation:** [All validated / Mixed / Failed]

---

## Feature Priorities

Based on interview feedback:

### Must-Have Features (Mentioned by ≥70%)

1. **[Feature 1]**
   - Mentioned by: [X/N participants]
   - Why it's critical: [Reasoning]
   - Quotes: [1-2 quotes]

2. **[Feature 2]**
[Same structure]

3. **[Feature 3]**
[Same structure]

### Nice-to-Have Features (Mentioned by 40-69%)

1. **[Feature 4]**
   - Mentioned by: [X/N participants]
   - Why it's valuable: [Reasoning]

2. **[Feature 5]**
[Same structure]

### Low-Priority Features (Mentioned by <40%)

[List features with low demand]

---

## Pricing Insights

**Price Expectations:**
- Minimum: [$X] (lowest expectation)
- Average: [$Y] (mean expected price)
- Maximum: [$Z] (highest willingness to pay)

**Price Distribution:**

| Price Range | Count | % of Total |
|-------------|-------|------------|
| $0-50 | [N] | [X%] |
| $51-100 | [N] | [X%] |
| $101-250 | [N] | [X%] |
| $251-500 | [N] | [X%] |
| $500+ | [N] | [X%] |

**Value Justification:**
[How participants think about ROI - time saved, revenue gained, etc.]

**Pricing Model Preference:**
- Per user: [N participants]
- Per company: [N participants]
- Usage-based: [N participants]
- One-time: [N participants]

---

## Competitive Insights

**Competitors Mentioned:**
1. [Competitor A]: Mentioned by [X/N participants]
2. [Competitor B]: Mentioned by [X/N participants]

**What Users Like About Competitors:**
- [Competitor A]: [Strengths participants mentioned]
- [Competitor B]: [Strengths]

**What Users Dislike:**
- [Competitor A]: [Weaknesses - our opportunity]
- [Competitor B]: [Weaknesses]

**Why Users Didn't Adopt Competitors:**
[Common reasons - too expensive, too complex, missing features, etc.]

---

## Unexpected Findings

**Surprise 1:** [Something we didn't expect]
- Evidence: [How many mentioned this]
- Implications: [What it means for solution]

**Surprise 2:** [Something we didn't expect]
[Same structure]

**Related Problems Discovered:**
[Other pain points mentioned that might be future opportunities]

---

## Persona Differences

**[Persona 1] vs. [Persona 2]:**

| Dimension | Persona 1 | Persona 2 |
|-----------|-----------|-----------|
| Pain severity | [X/10] | [Y/10] |
| Adoption likelihood | [X/10] | [Y/10] |
| Must-have features | [List] | [List] |
| Price expectation | [$X] | [$Y] |
| Key motivator | [What drives them] | [What drives them] |

**Primary Target:** [Which persona to prioritize - and why]

---

## Confidence Assessment

**Sample Size Adequacy:** [✅ Sufficient (10+) / ⚠️ Borderline (7-9) / ❌ Too Small (<7)]

**Data Quality:** [High / Medium / Low]
**Reasoning:** [Engagement level, specificity of answers, consistency across interviews]

**Confidence in Findings:** [High / Medium / Low]
**Reasoning:** [Why we're confident or not]

**Gaps Remaining:**
1. [Gap 1 - what we still don't know]
2. [Gap 2]
3. [Gap 3]

---

## Recommendations

**Should We Proceed?**

### ✅ PROCEED if:
- Pain severity ≥7/10 for ≥70% of participants
- Adoption likelihood ≥7/10 for ≥60% of participants
- Hypotheses validated or partially validated
- Clear must-have features identified
- Pricing feedback supports business model

### ⚠️ PROCEED WITH CAUTION if:
- Pain severity 5-7/10 for most participants
- Adoption likelihood 5-7/10
- Mixed hypothesis validation
- Need more research to de-risk

### ❌ STOP if:
- Pain severity <5/10 for most participants
- Adoption likelihood <5/10
- Hypotheses invalidated
- No clear product-market fit signal

**Our Recommendation:** [PROCEED / PROCEED WITH CAUTION / STOP]

**Reasoning:**
1. [Reason 1 - evidence from interviews]
2. [Reason 2]
3. [Reason 3]

---

## Next Steps

**If PROCEED:**
1. Run `/gbm.pm.research` for market and competitive analysis
2. Run `/gbm.pm.validate-problem` for final go/no-go decision
3. If validated: Run `/gbm.pm.prd` to create Product Requirements Document

**If PROCEED WITH CAUTION:**
1. Conduct [N] additional interviews focusing on [specific gap]
2. Re-synthesize with full dataset
3. Then proceed to `/gbm.pm.research`

**If STOP:**
1. Document learnings
2. Return to `/gbm.pm.discover` to explore different problem from opportunity matrix

---

**Synthesis Quality Check:**
- [ ] All interviews reviewed
- [ ] Themes identified with frequencies
- [ ] Pain and adoption scores calculated
- [ ] Hypotheses validation complete
- [ ] Feature priorities ranked
- [ ] Persona differences analyzed
- [ ] Recommendation made with clear reasoning
EOF

    log_success "Created: synthesis.md"
}

create_interview_metadata() {
    local dir="$1"
    local feature="$2"
    local file="$dir/metadata.json"

    cat > "$file" <<EOF
{
  "feature": "$feature",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "command": "/gbm.pm.interview",
  "phase": "discovery",
  "status": "in_progress",
  "artifacts": {
    "interview_guide": "interview-guide.md",
    "synthesis": "synthesis.md",
    "interviews": []
  },
  "target_interviews": 10,
  "completed_interviews": 0,
  "synthesis_ready": false,
  "next_steps": [
    "Conduct interviews (target: 10+)",
    "Synthesize findings after 10 interviews",
    "/gbm.pm.research",
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
