---
description: "Ensure stakeholder alignment on requirements using RACI matrix before development starts (PM Alignment Phase)"
scripts:
  sh: scripts/bash/pm-align.sh
  ps: scripts/powershell/pm-align.ps1
artifacts:
  - path: "$FEATURE_DIR/alignment-checklist.md"
    description: "Stakeholder alignment checklist with RACI matrix and sign-offs"
---

## Output Style Requirements (MANDATORY)

**Alignment Checklist**:
- RACI matrix: table format (decision area | R | A | C | I)
- Sign-off status: table with name | role | status | date
- Blockers: numbered list, one line per blocker + owner
- No narrative summaries of discussions - bullet key decisions

**Meeting Notes**:
- Decision log as table: decision | outcome | owner
- Action items: checkbox + owner + date, one line each

# Product Manager: Stakeholder Alignment

You are helping a Product Manager ensure all stakeholders are aligned before development starts.

## Persona Context

**Primary**: Product Manager persona (owns this command)
**Available to**: Product Manager only (alignment is PM responsibility)

## Prerequisites

**Required:**
- ✅ Completed `/gbm.pm.prd` with finalized PRD
- ✅ Completed `/gbm.pm.stories` with detailed user stories
- ✅ Stories imported to Jira (or equivalent)

**This command ensures everyone is aligned before committing engineering resources.**

## Your Task

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.pm.align" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

Run `{SCRIPT}` to create alignment checklist, then guide PM through stakeholder alignment.

The script will:
1. Create `$FEATURE_DIR/alignment-checklist.md`
2. Generate RACI matrix template
3. Create sign-off tracking table
4. Parse PRD/stories for alignment items

## Alignment Process

### Step 3: Identify Stakeholders

**Stakeholder Mapping:**

```markdown
# Stakeholder Alignment Checklist

**Feature:** [Feature name from PRD]
**PM Owner:** [Your name]
**Alignment Date:** [YYYY-MM-DD]

---

## Stakeholders

**Required Sign-Off (Must approve before development):**

| Role | Name | Department | Sign-Off Required | Status |
|------|------|------------|-------------------|--------|
| Engineering Lead | [Name] | Engineering | ✅ Yes | ⏳ Pending |
| Design Lead | [Name] | Design | ✅ Yes | ⏳ Pending |
| QA Lead | [Name] | Quality | ✅ Yes | ⏳ Pending |
| Security Lead | [Name] | Security | ✅ Yes | ⏳ Pending |
| [Other] | [Name] | [Dept] | ✅ Yes | ⏳ Pending |

**Informed (No sign-off required, but must be aware):**

| Role | Name | Department | Status |
|------|------|------------|--------|
| Sales Lead | [Name] | Sales | ⏳ Not Briefed |
| Customer Success | [Name] | CS | ⏳ Not Briefed |
| Marketing | [Name] | Marketing | ⏳ Not Briefed |
| Support | [Name] | Support | ⏳ Not Briefed |

---

## RACI Matrix

**R**esponsible: Does the work
**A**ccountable: Final decision maker
**C**onsulted: Provides input
**I**nformed: Kept in the loop

| Activity | PM | Eng Lead | Design | QA | Security | Sales | CS |
|----------|----|---------:|-------|----|----------|-------|-----|
| PRD Creation | A | C | C | C | C | I | I |
| User Story Breakdown | A,R | C | C | I | I | I | I |
| Technical Design | C | A,R | I | C | C | I | I |
| UI/UX Design | C | C | A,R | I | I | I | I |
| Development | C | A,R | I | I | I | I | I |
| Testing | C | C | I | A,R | C | I | I |
| Security Review | C | C | I | I | A,R | I | I |
| Go-Live Decision | A | C | C | C | C | I | I |
| Launch Communication | C | I | I | I | I | A,R | C |
| Customer Training | C | I | I | I | I | C | A,R |
```

### Step 4: Alignment Review Meetings

**Meeting 1: Engineering Alignment (60 min)**

**Attendees:** PM, Engineering Lead, Tech Leads, Architects

**Agenda:**
1. **PRD Walkthrough** (15 min)
   - Problem context
   - Success metrics
   - Technical requirements
For complete style guidance, see .gobuildme/templates/_concise-style.md


2. **Story Review** (20 min)
   - Walk through P0 stories
   - Clarify acceptance criteria
   - Discuss technical approach

3. **Concerns & Risks** (15 min)
   - Engineering raises concerns
   - Discuss technical risks from PRD
   - Identify blockers

4. **Estimate Validation** (10 min)
   - Validate story points
   - Confirm timeline feasibility
   - Discuss resource needs

**Alignment Checklist:**
- [ ] Engineering understands problem and user needs
- [ ] Technical approach agreed upon
- [ ] All P0 stories are clear and estimated
- [ ] Dependencies identified
- [ ] Risks discussed and mitigated
- [ ] Timeline realistic
- [ ] Resources confirmed available
- [ ] No blocking concerns remain

**Sign-Off:** Engineering Lead: __________ Date: __________

---

**Meeting 2: Design Alignment (45 min)**

**Attendees:** PM, Design Lead, UI/UX Designers

**Agenda:**
1. **PRD Review** (10 min)
   - User personas
   - User needs from interviews
   - Design requirements

2. **Design Review** (20 min)
   - Mockups/prototypes walkthrough
   - User flows
   - Accessibility considerations

3. **User Validation** (10 min)
   - Has design been tested with users?
   - Any changes based on feedback?

4. **Handoff Plan** (5 min)
   - Design assets ready?
   - Design system components?
   - Timeline for any pending designs

**Alignment Checklist:**
- [ ] Design understands user needs (from /gbm.pm.interview)
- [ ] Mockups address PRD requirements
- [ ] User flows validated
- [ ] Accessibility requirements met (WCAG 2.1 AA)
- [ ] Design assets ready for engineering
- [ ] Design review sessions scheduled
- [ ] No blocking design concerns

**Sign-Off:** Design Lead: __________ Date: __________

---

**Meeting 3: QA Alignment (30 min)**

**Attendees:** PM, QA Lead, QA Engineers

**Agenda:**
1. **PRD & Stories Review** (10 min)
   - Acceptance criteria walkthrough
   - Edge cases discussion

2. **Test Strategy** (15 min)
   - Test coverage plan
   - Automation vs. manual
   - Performance/load testing needs
   - Security testing requirements

3. **QA Timeline** (5 min)
   - QA resource allocation
   - Test environment needs
   - Integration with development

**Alignment Checklist:**
- [ ] QA understands acceptance criteria
- [ ] Test strategy defined
- [ ] Test cases can be written from acceptance criteria
- [ ] Test environments ready
- [ ] QA resources allocated
- [ ] Performance testing plan (if needed)
- [ ] Security testing plan (if needed)

**Sign-Off:** QA Lead: __________ Date: __________

---

**Meeting 4: Security Review (30 min)**

**Attendees:** PM, Security Lead, Engineering Lead

**Agenda:**
1. **PRD Security Requirements** (10 min)
   - Data handling (PII, encryption)
   - Authentication/authorization
   - Compliance (GDPR, SOC2, etc.)

2. **Threat Modeling** (15 min)
   - Potential attack vectors
   - Risk assessment
   - Mitigation strategies

3. **Security Sign-Off** (5 min)
   - Security requirements clear?
   - Penetration testing needed?
   - Compliance review needed?

**Alignment Checklist:**
- [ ] Security requirements in PRD reviewed
- [ ] Threat model completed
- [ ] Data encryption approach approved
- [ ] Authentication/authorization approach approved
- [ ] Compliance requirements identified
- [ ] Penetration testing plan (if needed)
- [ ] No blocking security concerns

**Sign-Off:** Security Lead: __________ Date: __________

---

**Meeting 5: Cross-Functional Alignment (45 min)**

**Attendees:** PM, Sales, CS, Marketing, Support

**Agenda:**
1. **Feature Overview** (10 min)
   - What we're building
   - Why it matters (business value)
   - Who it's for (target personas)

2. **Launch Plan** (15 min)
   - Timeline
   - Rollout strategy (beta, GA)
   - Customer communication plan

3. **Enablement Needs** (15 min)
   - Sales: Demo, pitch deck, objection handling
   - CS: Training materials, onboarding docs
   - Support: FAQ, troubleshooting guide
   - Marketing: Announcement, blog post, positioning

4. **Feedback & Questions** (5 min)

**Alignment Checklist:**
- [ ] Sales understands value prop and target customers
- [ ] CS understands how to onboard customers
- [ ] Support has documentation for common issues
- [ ] Marketing has positioning and messaging
- [ ] Launch communication plan agreed upon
- [ ] Enablement timeline confirmed

**Sign-Off:**
- Sales Lead: __________ Date: __________
- CS Lead: __________ Date: __________
- Marketing Lead: __________ Date: __________
- Support Lead: __________ Date: __________

---

### Step 5: Concerns & Resolutions Log

**Open Concerns:**

| ID | Concern | Raised By | Category | Severity | Resolution | Owner | Status |
|----|---------|-----------|----------|----------|------------|-------|--------|
| C-1 | [Concern description] | [Name] | [Tech/Design/Timeline] | [High/Med/Low] | [How resolved] | [Owner] | ⏳ Open |
| C-2 | [Concern] | [Name] | [Category] | [Severity] | [Resolution] | [Owner] | ✅ Closed |

**Severity Levels:**
- **High:** Blocks development, must resolve before starting
- **Medium:** Should resolve before sprint 2
- **Low:** Can address later, doesn't block progress

**Resolution Process:**
1. PM logs concern in table above
2. Assign owner to investigate
3. Set deadline for resolution
4. Update status when resolved
5. Communicate resolution to stakeholder

**All High Severity Concerns Must Be Resolved Before Development Starts.**

---

### Step 6: Assumptions & Dependencies

**Critical Assumptions:**

| Assumption | Source | Validation | Risk if Wrong | Mitigation |
|------------|--------|------------|---------------|------------|
| [Assumption 1] | [From PRD/research] | [How validated] | [Impact] | [Backup plan] |
| [Assumption 2] | [Source] | [Validation] | [Risk] | [Mitigation] |

**Example:**
| Assumption | Source | Validation | Risk if Wrong | Mitigation |
|------------|--------|------------|---------------|------------|
| Users check dashboard daily | /gbm.pm.interview (8/10 users said so) | Track usage post-launch | Low engagement | Add email notifications |

**External Dependencies:**

| Dependency | Owner | Status | Impact if Delayed | Mitigation |
|------------|-------|--------|-------------------|------------|
| [API from Team X] | [Team X Lead] | ⏳ In Progress | [Blocks feature Y] | [Use mock data for now] |
| [Third-party integration] | [Vendor] | ✅ Ready | [N/A] | [N/A] |

**Dependency Management:**
- Weekly check-ins with dependency owners
- Escalate if dependency at risk
- Always have fallback plan

---

### Step 7: Go/No-Go Decision

**Final Alignment Check:**

| Criteria | Status | Notes |
|----------|--------|-------|
| All required sign-offs obtained | [✅/❌] | [Missing: X] |
| All high-severity concerns resolved | [✅/❌] | [Open concerns: N] |
| Engineering confident in timeline | [✅/❌] | [Concerns about X] |
| Design assets ready | [✅/❌] | [Pending: Y] |
| Resources allocated | [✅/❌] | [Need: Z] |
| Dependencies on track | [✅/❌] | [At risk: W] |
| QA test plan approved | [✅/❌] | [Missing: V] |
| Security review complete | [✅/❌] | [Pending: U] |

**All Criteria Met:** [✅ Yes / ❌ No]

---

## ✅ GO Decision

**We are aligned and ready to start development.**

**Sign-Off:**
- Product Manager: __________ Date: __________
- Engineering Lead: __________ Date: __________
- Design Lead: __________ Date: __________
- QA Lead: __________ Date: __________
- Security Lead: __________ Date: __________

**Next Steps:**
1. Run `/gbm.pm.handoff` to formally hand off to engineering
2. Schedule sprint planning
3. Kick off development

---

## ❌ NO-GO (Not Ready Yet)

**We are NOT ready to start development because:**

**Blocking Issues:**
1. [Issue 1 - e.g., "Design assets not complete"]
2. [Issue 2 - e.g., "Security review pending"]
3. [Issue 3 - e.g., "Engineering concerns not resolved"]

**Action Plan:**

| Blocker | Owner | Target Date | Status |
|---------|-------|-------------|--------|
| [Blocker 1] | [Owner] | [Date] | ⏳ In Progress |
| [Blocker 2] | [Owner] | [Date] | ⏳ Not Started |

**Re-Alignment Meeting:** [Schedule date when blockers resolved]

---

## Communication Plan

**Stakeholder Updates:**

**Weekly Updates (During Development):**
- Audience: Engineering, Design, QA
- Format: Slack update + standup
- Content: Progress, blockers, next steps

**Bi-Weekly Updates:**
- Audience: Sales, CS, Marketing, Support
- Format: Email + optional sync
- Content: Feature status, launch timeline, enablement needs

**Monthly Executive Updates:**
- Audience: Leadership team
- Format: Exec summary + metrics dashboard
- Content: Progress vs. plan, risks, business impact projection

**Milestone Communication:**
- Sprint completion
- Beta launch
- GA launch
- Post-launch metrics review

---

**Document Version:** 1.0
**Last Updated:** [YYYY-MM-DD]
**Status:** [Draft / Aligned / Approved]
```

## Quality Checks

Before marking alignment complete:

- [ ] All required stakeholders identified
- [ ] RACI matrix complete
- [ ] All alignment meetings scheduled/completed
- [ ] All high-severity concerns resolved
- [ ] All required sign-offs obtained
- [ ] Dependencies tracked
- [ ] Assumptions validated
- [ ] Communication plan defined
- [ ] Go/No-Go decision made

## Output Summary

After completing alignment, present summary:

```markdown
## Alignment Summary

**Feature:** [Feature name]
**Status:** [Aligned / Not Ready]
**Date:** [YYYY-MM-DD]

**Stakeholder Sign-Offs:**
- Engineering: [✅/❌]
- Design: [✅/❌]
- QA: [✅/❌]
- Security: [✅/❌]

**Open Concerns:** [N high, M medium, P low]

**Dependencies:** [N total, X at risk]

**Decision:** [GO / NO-GO]

**If GO:**
Next step: Run `/gbm.pm.handoff` to formally hand off to engineering

**If NO-GO:**
Blocking issues: [List]
Re-alignment date: [Date]
```

## Next Steps

**If Aligned (GO):**
1. Run `/gbm.pm.handoff` for formal engineering handoff
2. Development starts

**If Not Aligned (NO-GO):**
1. Resolve blocking issues
2. Schedule re-alignment meeting
3. Repeat alignment process

## Tips for PM

**Good Alignment:**
- ✅ All stakeholders involved early
- ✅ Concerns surfaced and resolved
- ✅ Clear RACI (no confusion on ownership)
- ✅ Dependencies tracked proactively
- ✅ Communication plan defined

**Bad Alignment:**
- ❌ "Engineering will figure it out" (no tech review)
- ❌ Ignoring stakeholder concerns
- ❌ Unclear ownership
- ❌ Surprise dependencies discovered mid-development
- ❌ No communication plan

## Files Created

- `$FEATURE_DIR/alignment-checklist.md` - Full alignment checklist with RACI and sign-offs

## Integration with PM Workflow

**Workflow Position:**
```
... → /gbm.pm.prd → /gbm.pm.stories → /gbm.pm.align ← YOU ARE HERE
                                    ↓
                               /gbm.pm.handoff
```

**Alignment Uses:**
- PRD (requirements to review)
- Stories (work to be estimated)
- Research (context for stakeholders)

**Alignment Gates:**
- Development start (must align first)

### Step 8: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-pm-align` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit alignment report to address stakeholder concerns
- Run `/gbm.pm.interview` to gather more stakeholder input
- Re-run `/gbm.pm.align` after updating requirements or PRD

