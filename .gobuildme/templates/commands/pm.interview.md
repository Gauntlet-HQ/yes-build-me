---
description: "Plan, conduct, and synthesize user interviews to validate problem and solution (PM Research Phase)"
scripts:
  sh: scripts/bash/pm-interview.sh
  ps: scripts/powershell/pm-interview.ps1
artifacts:
  - path: "$FEATURE_DIR/interviews/interview-guide.md"
    description: "Interview guide with research questions"
  - path: "$FEATURE_DIR/interviews/interview-[01-N].md"
    description: "Individual interview notes"
  - path: "$FEATURE_DIR/interviews/synthesis.md"
    description: "Cross-interview synthesis and patterns"
---

## Output Style Requirements (MANDATORY)

**Interview Guide**:
- Research questions: numbered list, one question per line
- Follow-ups: indented bullets under main questions
- No lengthy rationale - questions should be self-explanatory

**Interview Notes**:
- Participant info: 3-5 field table (role, context, date, etc.)
- Key quotes: verbatim in quotes with topic tag
- Observations: bullets, not paragraphs

**Synthesis**:
- Patterns: table format (pattern | frequency | example quotes)
- Insights: one sentence each with supporting evidence count
- Recommendations: numbered actions, not prose

For complete style guidance, see .gobuildme/templates/_concise-style.md

# Product Manager: User Interviews

You are helping a Product Manager plan, conduct, and analyze user interviews.

## Persona Context

**Primary**: Product Manager persona (owns this command)
**Available to**: Product Manager only (user research is PM-specific work)

## Prerequisites

- Discovery complete (problem identified from `/gbm.pm.discover`)
- Hypothesis formed (what you're trying to validate)
- Target participants identified (personas, sample size)

## Your Task

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.pm.interview" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

Run `{SCRIPT}` to set up interview workspace, then guide PM through systematic user research.

The script will:
1. Determine feature directory from current branch or prompt for feature name
2. Create `$FEATURE_DIR/interviews/` directory
3. Copy interview guide template
4. Create individual interview note templates
5. Set up synthesis template

## Phase 1: Interview Planning

Create interview guide using template from `.gobuildme/templates/reference/pm-interview-templates.md`.

**Interview Guide Structure:**
1. Research Objectives (primary + secondary questions)
2. Problem Being Validated (from discovery, hypothesis)
3. Target Participants (personas, sample sizes, rationale)
4. 60-minute Interview Script:
   - Introduction (5 min): Set context, not a sales call, confidential
   - Current State (10-15 min): Process, tools, frequency
   - Pain Points (10-15 min): Hardest part, impact, 1-10 severity
   - Workarounds (10-15 min): What tried, alternatives considered
   - Solution Exploration (10-15 min): Reaction, fit, 1-10 likelihood
   - Wrap-up (5 min): Anything else, follow-up, referrals

**Target:** 10-15 interviews recommended

## Phase 2: Conduct Interviews

Use individual interview notes template from `.gobuildme/templates/reference/pm-interview-templates.md`.

**Notes Structure:**
1. Participant Profile (role, company, persona)
2. Current State (process, tools, frequency)
3. Pain Points (severity, frequency, impact, 1-10 score)
4. Workarounds (what tried, alternatives, why not adopted)
5. Solution Reaction (concept, excitement, concerns, 1-10 likelihood)
6. Key Quotes (3-5 verbatim quotes)
7. Behavioral Observations (said vs. did, body language)
8. Post-Interview Reflection (insights, confidence levels, hypothesis status)

**Interview Cadence:**
- Target: 2-3 interviews per day
- Allow time between for reflection
- Adjust questions based on learnings

## Phase 3: Synthesis (After 10+ Interviews)

Use synthesis template from `.gobuildme/templates/reference/pm-interview-templates.md`.

**Synthesis Structure:**
1. Cross-Interview Patterns (themes by frequency: ≥70% strong, 50-69% moderate, <50% weak)
2. Pain Severity Distribution (table: score, count, %, personas)
3. Likelihood to Use Distribution (table: score, count, %, personas)
4. Persona Differences (comparison table + primary target selection)
5. Must-Have vs. Nice-to-Have Features (>60% = must-have)
6. Hypothesis Validation (supported/refuted/mixed + evidence)
7. Key Insights Summary (top 5 with confidence levels)
8. Confidence Assessment (sample size, coverage, consistency, scores)
9. Recommendations (proceed/adjust/more research/pivot)

**Thresholds:**
- Strong pattern: ≥70% of participants
- Must-have feature: >60% mentioned as critical
- Sufficient pain: Average ≥7/10
- Strong demand: Average likelihood ≥7/10

## Quality Checks

Before completing interview phase:

- [ ] ≥10 interviews conducted (minimum)
- [ ] Multiple personas covered (if applicable)
- [ ] Each interview has structured notes
- [ ] Synthesis completed with cross-interview patterns
- [ ] Confidence level assessed (High/Medium/Low)
- [ ] Must-have features identified (≥60% mentioned)
- [ ] Hypothesis validation completed
- [ ] Clear recommendation on next steps

## Output Summary

Present synthesis summary:

```markdown
## Interview Phase Summary

**Interviews Completed:** [N]
**Date Range:** [Start] to [End]
**Personas:** [List]

**Key Finding:** [Most important insight in one sentence]

**Hypothesis Status:** [Supported / Refuted / Mixed / Unclear]

**Pain Severity:** [Avg score]/10
**Likelihood to Use:** [Avg score]/10

**Recommendation:** [Proceed / Adjust / More Research / Pivot]

**Next Steps:**
1. [Next action]
2. [Timeline]
```

## Next Steps

**If validated:**
1. Run `/gbm.pm.research` for market/competitive analysis
2. Target: Complete market research in 1-2 weeks
3. After research: Run `/gbm.pm.validate-problem` for go/no-go decision

**If needs more research:**
1. Conduct additional interviews (specify focus)
2. Re-synthesize with expanded sample
3. Re-assess confidence

**If pivoting:**
1. Return to `/gbm.pm.discover` with new insights
2. Explore alternative problems
3. Start fresh interview cycle

## Files Created

- `$FEATURE_DIR/interviews/interview-guide.md`
- `$FEATURE_DIR/interviews/interview-01.md` through `interview-[N].md`
- `$FEATURE_DIR/interviews/synthesis.md`
- `$FEATURE_DIR/interviews/quotes.md` (optional: best quotes collection)

## Tips for PM

**Good Interviews:**
- ✅ Ask open-ended questions ("Tell me about..." not "Do you...?")
- ✅ Listen more than you talk (80/20 rule)
- ✅ Dig into specifics ("Can you give an example?")
- ✅ Look for patterns across multiple interviews
- ✅ Stay neutral (don't lead the witness)

**Bad Interviews:**
- ❌ Leading questions ("Don't you think X is a problem?")
- ❌ Pitching solution instead of listening
- ❌ Accepting vague answers ("It's hard" → Ask: "What specifically is hard?")
- ❌ Confirming bias (only hearing what you want to hear)
- ❌ Small sample size (<5 interviews = unreliable)

### Step 3: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-pm-interview` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit interview notes to add missing insights
- Conduct additional user/stakeholder interviews
- Run `/gbm.pm.research` to synthesize findings
- Re-run `/gbm.pm.interview` with refined interview questions

