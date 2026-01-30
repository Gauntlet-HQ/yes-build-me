---
description: "Formal handoff from PM to Engineering with kickoff checklist and ongoing support plan (PM Handoff Phase)"
scripts:
  sh: scripts/bash/pm-handoff.sh
  ps: scripts/powershell/pm-handoff.ps1
artifacts:
  - path: "$FEATURE_DIR/handoff-checklist.md"
    description: "Engineering handoff checklist with PM support plan"
---

## Output Style Requirements (MANDATORY)

**Handoff Checklist**:
- Checklist items: checkbox + one-line action, no explanations
- Context sections: 3-5 bullets max per area
- Support plan: table format (area | contact | hours | escalation)
- No restating PRD content - link to artifacts

**Kickoff Notes**:
- One paragraph overview + bulleted key decisions
- Questions/risks as numbered list
- Action items: owner + date, one line each

For complete style guidance, see .gobuildme/templates/_concise-style.md

# Product Manager: Engineering Handoff

You are helping a Product Manager formally hand off a feature to the engineering team.

## Persona Context

**Primary**: Product Manager persona (owns this command)
**Available to**: Product Manager only (handoff is PM ceremony)

## Prerequisites

**Required:**
- ✅ Completed `/gbm.pm.align` with all stakeholder sign-offs
- ✅ All alignment checklist items passed
- ✅ GO decision from alignment

**This is the final PM step before development begins.**

## Your Task

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.pm.handoff" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

Run `{SCRIPT}` to create handoff checklist, then guide PM through formal handoff ceremony.

The script will:
1. Create `$FEATURE_DIR/handoff-checklist.md`
2. Generate kickoff meeting agenda
3. Create PM support plan template
4. Set up ongoing communication channels

## Handoff Process

### Step 3: Pre-Handoff Checklist

Use templates from `.gobuildme/templates/reference/pm-handoff-templates.md`

**Pre-Handoff Verification:**

| Area | Requirements |
|------|-------------|
| Documentation | PRD, Jira stories, alignment checklist, all discovery artifacts |
| Design Assets | Wireframes, mockups, prototype, specs shared |
| Technical | Design reviewed, API contracts, schema, feature flags |
| Resources | Engineering/Design/QA assigned, capacity confirmed, no blockers |
| Sign-offs | Eng Lead, Design Lead, QA Lead, Security Lead |

**All complete?** → Schedule kickoff. **Gaps?** → Resolve before handoff.

## Kickoff Meeting (90 min)

See `.gobuildme/templates/reference/pm-handoff-templates.md#kickoff-meeting-agenda` for detailed agenda.

**Required Attendees:** PM, Eng Lead, Engineers, Designer, QA Lead

**Agenda Overview:**

| Section | Duration | Content |
|---------|----------|---------|
| Context | 15 min | Problem, users, impact, metrics, key user quote |
| Solution | 20 min | Technical approach, components, flows, design walkthrough |
| Requirements | 20 min | P0 with AC, P1 summary, out of scope |
| Sprint Plan | 15 min | Points, sprints, milestones, alpha/beta/GA dates |
| Dependencies & Risks | 10 min | Tables with owner/status/mitigation |
| Roles | 5 min | PM/Eng/Design/QA responsibilities |
| Communication | 5 min | Channels, meetings, decision framework, escalation |
| Q&A | 15 min | Questions logged with owners |
| Next Steps | 5 min | Actions and commitments |

## PM Support Plan

See `.gobuildme/templates/reference/pm-handoff-templates.md` for detailed templates.

**Availability:** Slack <2hr response | Office hours [Day/Time] | Backup: [Name]

**Meetings:**
- Weekly 1:1 with Eng Lead (30 min): progress, blockers, scope, morale
- Sprint demos (bi-weekly): validate AC, capture feedback

**Decision Log:** Document all decisions with date/context/rationale/impact/stakeholders

**Scope Change Authority:**
- <2 points: PM decides
- 2-8 points: PM + Eng Lead
- >8 points: Escalate

**Bug Triage:**
- P0 (critical): 1hr response, same day fix
- P1 (high): 4hr response, this sprint
- P2 (medium): 1 day response, next sprint
- P3 (low): 1 week response, backlog

**Milestone Tracking:** Sprint goals → Alpha → Beta → GA with success criteria

## Ongoing PM Responsibilities

**Weekly:** Sprint progress, bug triage, Q&A, ceremonies, stakeholder updates, demos

**Pre-Launch:** Alpha/beta/GA prep checklists

**Post-Launch:** Monitor metrics, triage issues, feedback, iterate

## Success Metrics

| Metric | Baseline | Target | Current | Status |
|--------|----------|--------|---------|--------|
| [Leading 1] | [X] | [Y] | [Z] | 🟢/🟡/🔴 |

**Status:** 🟢 >80% | 🟡 50-80% | 🔴 <50%

## Quality Checks

Before completing handoff:

- [ ] All pre-handoff checklist items verified
- [ ] Kickoff meeting scheduled
- [ ] All required attendees confirmed
- [ ] Kickoff agenda prepared
- [ ] PM support plan defined
- [ ] Communication channels created
- [ ] Sprint plan confirmed
- [ ] Milestones defined
- [ ] Success metrics dashboard configured

## Output Summary

After completing handoff, present summary:

```markdown
## Handoff Summary

**Feature:** [Feature name]
**Status:** ✅ Handed Off to Engineering
**Date:** [YYYY-MM-DD]

**Kickoff Meeting:** [Date/Time] - ✅ Complete

**Team:**
- PM: [Name]
- Eng Lead: [Name]
- Engineers: [N] assigned
- Designer: [Name]
- QA: [Name]

**Development Timeline:**
- Start: [YYYY-MM-DD]
- Alpha: [YYYY-MM-DD] (Week [X])
- Beta: [YYYY-MM-DD] (Week [Y])
- GA: [YYYY-MM-DD] (Week [Z])

**Sprint Plan:**
- Total Sprints: [N]
- Story Points: [X]
- Estimated Duration: [Y weeks]

**PM Support:**
- Availability: Slack `#feature-[name]`, <2hr response
- Check-ins: Weekly with Eng Lead
- Office Hours: [Day/Time]

**Next PM Actions:**
- Monitor sprint progress
- Weekly stakeholder updates
- Unblock dependencies
- Review demos

**Good luck to the team! 🚀**
```

## Tips for PM

**Good Handoff:**
- ✅ All documentation complete before kickoff
- ✅ Engineering feels set up for success
- ✅ Clear communication channels established
- ✅ PM availability committed
- ✅ Success criteria defined
- ✅ Risks acknowledged and mitigated

**Bad Handoff:**
- ❌ "Figure it out as you go" (incomplete PRD)
- ❌ PM disappears after handoff ("You've got this!")
- ❌ Unclear requirements ("We'll clarify later")
- ❌ No decision framework (everything escalates)
- ❌ Unrealistic timeline (team set up to fail)

**PM Anti-Patterns During Development:**
- Changing requirements mid-sprint
- Bypassing Engineering Lead (going directly to engineers)
- Slow decision-making (blocking team)
- Ignoring engineering concerns
- Micromanaging implementation

## Files Created

- `$FEATURE_DIR/handoff-checklist.md` - Full handoff checklist with ongoing support plan

## Integration with PM Workflow

**Workflow Position:**
```
... → /gbm.pm.prd → /gbm.pm.stories → /gbm.pm.align → /gbm.pm.handoff ← YOU ARE HERE
                                                  ↓
                                          DEVELOPMENT STARTS
                                                  ↓
                                          /gbm.specify (Engineering workflow begins)
```

**PM Workflow Complete!** 🎉

**Discovery Phase:**
- /gbm.pm.discover ✅
- /gbm.pm.interview ✅
- /gbm.pm.research ✅
- /gbm.pm.validate-problem ✅

**Definition Phase:**
- /gbm.pm.prd ✅
- /gbm.pm.stories ✅

**Alignment Phase:**
- /gbm.pm.align ✅
- /gbm.pm.handoff ✅

**Next:** Engineering takes over with GoBuildMe's core SDD workflow.

### Step 4: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-pm-handoff` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit handoff documentation to clarify engineering requirements
- Run `/gbm.pm.prd` to create/update product requirements first
- Run `/gbm.pm.align` to ensure stakeholder alignment
- Re-run `/gbm.pm.handoff` after PRD updates

