---
description: "Final validation checkpoint: synthesize all discovery evidence and make go/no-go decision before PRD (PM Validation Gate)"
scripts:
  sh: scripts/bash/pm-validate-problem.sh
  ps: scripts/powershell/pm-validate-problem.ps1
artifacts:
  - path: "$FEATURE_DIR/validation-report.md"
    description: "Complete yet concise validation report with final go/no-go decision"
---

## Output Style Requirements (MANDATORY)

**Validation Report**:
- Decision at top: GO / NO-GO / NEED MORE DATA in header
- Evidence summary: table format (evidence type | source | supports/refutes)
- Confidence score: single line with percentage and rationale
- Risks: numbered list, one line per risk + mitigation

**Criteria Assessment**:
- Pass/fail per criterion as table: criterion | status | evidence
- No multi-paragraph justifications - bullet key points
- Unresolved questions: list with owner + next step

For complete style guidance, see .gobuildme/templates/_concise-style.md

# Product Manager: Problem Validation Checkpoint

You are helping a Product Manager make a final go/no-go decision before committing to a PRD.

## Persona Context

**Primary**: Product Manager persona (owns this command)
**Available to**: Product Manager only (validation gate is PM responsibility)

## Prerequisites

**Required:**
- ✅ Completed `/gbm.pm.discover` (problem identified, opportunity scored)
- ✅ Completed `/gbm.pm.interview` (user research conducted, synthesis done)
- ✅ Completed `/gbm.pm.research` (market, competitive, analytics, feasibility)

**This is a gate command**: It synthesizes all discovery work and makes a formal decision.

## Your Task

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.pm.validate-problem" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

Run `{SCRIPT}` to create validation workspace, then guide PM through final validation.

The script will:
1. Create `$FEATURE_DIR/validation-report.md`
2. Import key findings from discovery, interviews, research
3. Generate validation scorecard
4. Prepare decision template

## Validation Process

### Step 3: Evidence Review & Scoring

Guide PM through the validation report. Full template: `.gobuildme/templates/reference/pm-validation-template.md`

**Report Structure:**
1. Executive Summary (verdict + impact)
2. Evidence Summary (6 sources: discovery, interviews, market, competitive, analytics, technical)
3. Validation Scorecard (6 dimensions, 0-10 scoring)
4. Critical Success Factors (10 checkboxes, need ≥8/10)
5. Risk Assessment (top 3 risks + tolerance)
6. Final Decision (matrix + GO/NO-GO/MORE DATA)

**Validation Scorecard Dimensions:**

| Dimension | Weight | Threshold | Key Criteria |
|-----------|--------|-----------|--------------|
| Problem Validation | 25% | ≥7.0 | Pain severity, frequency, analytics, workarounds |
| Market Opportunity | 15% | ≥6.0 | TAM/SAM, growth, segment clarity, timing |
| Competitive Advantage | 15% | ≥6.0 | Gaps, differentiation, positioning, barriers |
| User Demand | 25% | ≥7.0 | Adoption, willingness to pay, urgency, validation |
| Feasibility & ROI | 10% | ≥6.0 | Technical, effort/impact, resources, risk |
| Evidence Quality | 10% | ≥7.0 | Sample size, diversity, freshness, triangulation |

**Score Interpretation:**
- 8.0-10.0: Strong → **GO**
- 6.0-7.9: Good → **GO** (with de-risking)
- 4.0-5.9: Weak → **NEED MORE DATA**
- 0.0-3.9: Failed → **NO-GO**

**Critical Success Factors (need ≥8/10):**
- Problem real (≥7/10 pain) + frequent
- Business impact quantified
- User demand (≥60% rated ≥7/10)
- Market size meets thresholds
- Competitive gap exists
- Technical feasibility: YES or YES-BUT
- Evidence quality: ≥10 interviews + analytics + competitive
- Assumptions validated
- Stakeholder alignment

## Quality Checks

Before finalizing validation:

- [ ] All 6 dimensions scored with reasoning
- [ ] Overall validation score calculated correctly
- [ ] All 10 critical success factors evaluated
- [ ] Risk assessment complete (top 3 risks identified)
- [ ] Decision matrix filled out (all thresholds checked)
- [ ] Final decision (GO / NO-GO / NEED MORE DATA) made with clear reasoning
- [ ] If GO: Next steps defined (timeline, team, de-risking)
- [ ] If NO-GO: Learnings captured, pivot options identified
- [ ] If NEED MORE DATA: Specific gaps listed, de-risking plan with timeline
- [ ] Stakeholder sign-off section filled

## Output Summary

After completing validation, present summary:

```markdown
## Validation Checkpoint Summary

**Problem/Opportunity:** [From /gbm.pm.discover]
**Validation Date:** [YYYY-MM-DD]
**Product Manager:** [Name]

**Overall Validation Score:** [X.X/10]
**Critical Success Factors:** [Y/10 met]
**Decision:** [✅ GO / ❌ NO-GO / ⚠️ NEED MORE DATA]

**If GO:**
Next step: Run `/gbm.pm.prd` to create Product Requirements Document
Timeline: Target [X weeks] from PRD to launch
Team: [N engineers, M designers]

**If NO-GO:**
Next step: Return to `/gbm.pm.discover` to explore [Alternative Problem]
Key learnings: [1-sentence summary]

**If NEED MORE DATA:**
Next step: Execute de-risking plan ([X] actions, [Y] weeks)
Re-validation checkpoint: [Date]
```

## Next Steps

### If GO Decision:

**Immediate Next Step:**
Run `/gbm.pm.prd` to create Product Requirements Document

**PRD Will Include:**
- Problem statement (validated)
- User personas (from interviews)
- Success metrics (from business impact analysis)
- User stories (informed by research)
- Competitive positioning (from competitive analysis)
- Technical approach (from feasibility assessment)

**Timeline:**
- PRD: [1-2 weeks]
- Design: [2-4 weeks]
- Engineering: [Effort estimate from research]
- Launch: [Total timeline]

### If NO-GO Decision:

**Immediate Next Step:**
1. Document learnings in discovery artifacts
2. Update opportunity matrix in `/gbm.pm.discover` (mark this problem as invalidated)
3. Choose next problem from opportunity matrix
4. Run `/gbm.pm.discover` again for new problem

**Pivot Options:**
- [Alternative 1 from discovery - Problem #2]
- [Alternative 2 from discovery - Problem #3]
- [New discovery session if all alternatives exhausted]

### If NEED MORE DATA Decision:

**Immediate Next Step:**
1. Execute de-risking plan (list specific actions)
2. Set re-validation checkpoint date
3. Assign owners for each data-gathering task
4. Re-run `/gbm.pm.validate-problem` after data gathered

**Timeline:**
[X weeks to gather data, then re-validate]

## Tips for PM

**Good Validation:**
- ✅ Honest scoring (don't inflate scores to justify favorite idea)
- ✅ All dimensions evaluated (not cherry-picking)
- ✅ Risk-aware (identify and mitigate risks, don't ignore)
- ✅ Evidence-based decision (not gut feel)
- ✅ Clear criteria (thresholds defined upfront, not adjusted to fit)

**Bad Validation:**
- ❌ Confirmation bias (scoring to justify pre-determined decision)
- ❌ Skipping dimensions that look unfavorable
- ❌ Moving goalposts (adjusting thresholds to get desired outcome)
- ❌ Ignoring contradictory evidence
- ❌ Rushing to PRD despite weak validation

## Files Created

- `$FEATURE_DIR/validation-report.md` - Complete yet concise validation report with decision

## Integration with PM Workflow

**Workflow Position:**
```
/gbm.pm.discover → /gbm.pm.interview → /gbm.pm.research → /gbm.pm.validate-problem ← YOU ARE HERE
                                                        ↓
                                              ✅ GO: /gbm.pm.prd
                                              ❌ NO-GO: back to /gbm.pm.discover
                                              ⚠️ MORE DATA: de-risk, then re-validate
```

**Validation Uses:**
- Discovery insights (problem definition, opportunity score)
- Interview findings (user pain, demand, quotes)
- Research data (market, competitive, analytics, feasibility)

**Validation Feeds Into:**
- **If GO**: PRD creation with validated requirements
- **If NO-GO**: Learnings for future discovery
- **If NEED MORE DATA**: Targeted data-gathering plan

**This is a formal gate**: PM should not proceed to PRD without passing validation.

### Step 4: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-pm-validate-problem` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit problem validation report with additional evidence
- Run `/gbm.pm.interview` to gather more user feedback
- Run `/gbm.pm.research` to investigate problem space deeper
- Re-run `/gbm.pm.validate-problem` with new data

