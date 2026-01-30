---
description: "Explore problems, brainstorm opportunities, score and prioritize to choose direction (PM Discovery Phase)"
scripts:
  sh: scripts/bash/pm-discover.sh
  ps: scripts/powershell/pm-discover.ps1
artifacts:
  - path: ".gobuildme/specs/pm-discovery/<session-id>/discovery.md"
    description: "Discovery session with problem exploration, opportunity scoring, hypothesis formation"
---

## Output Style Requirements (MANDATORY)

**Discovery Output**:
- Problem statements: one sentence each, specific and measurable
- Opportunity scores: table format (opportunity | impact | confidence | effort)
- Hypotheses: "We believe [action] will result in [outcome] because [evidence]" - one line
- Brainstorm ideas: bullet list, 5-10 words per idea

**Evidence & Data**:
- Citations inline: `[Source, Date]`
- Metrics as tables, not prose
- No multi-paragraph analysis - one insight per bullet

# Product Manager: Discovery & Brainstorming

You are helping a Product Manager explore problems, brainstorm opportunities, and choose a direction.

## Persona Context

**Primary**: Product Manager persona (owns this command)
**Available to**: Product Manager only (discovery is PM-specific work)

## Prerequisites

- Product strategy context (company OKRs, target customers)
- Data access (analytics, support tickets, user feedback)
- Stakeholders available for brainstorming

## Your Task

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.pm.discover" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

Run `{SCRIPT}` to create a discovery session workspace, then guide PM through structured discovery.

The script will:
1. Create `.gobuildme/specs/pm-discovery/<timestamp>/` directory
2. Copy discovery template
3. Generate session ID
4. Create opportunity scoring matrix

## Discovery Process

### Step 3: Problem Space Exploration

Help the PM list all problems/opportunities they're considering.

For each problem, document:

**Problem Template:**
```markdown
### Problem [N]: [One-sentence description]

**Who Experiences This:**
- Target personas: [Primary users affected]
- Frequency: [How often they encounter it]
- Severity: [Critical / High / Medium / Low]

**Evidence So Far:**
- Source 1: [e.g., "25 support tickets in last month"]
- Source 2: [e.g., "Analytics show 40% drop-off at step X"]
- Source 3: [e.g., "5 sales calls mentioned this"]

**Current State:**
- How users handle this today: [Workarounds, manual processes]
- Why it's painful: [What makes it hard/frustrating]

**Business Impact:**
- Revenue: [Lost sales, churn, reduced expansion]
- Cost: [Support overhead, manual work]
- Strategic: [Competitive disadvantage, market gap]

**Initial Confidence:**
- How well do we understand this problem? [High / Medium / Low]
- Why this confidence level: [Reasoning]
```

**Target:** List at least 3-5 problems to evaluate

### Step 4: Opportunity Scoring

For each problem identified, score on these dimensions:

**Scoring Framework:**
For complete style guidance, see .gobuildme/templates/_concise-style.md


1. **Impact (1-5)**: How much does solving this matter?
   - 5 = Critical business need (revenue/retention/efficiency)
   - 4 = High impact on key metrics
   - 3 = Meaningful improvement
   - 2 = Minor improvement
   - 1 = Nice to have

2. **Effort (1-5)**: How hard to solve?
   - 5 = XXL (>6 months, multiple teams)
   - 4 = XL (3-6 months, cross-functional)
   - 3 = L (1-3 months, one team)
   - 2 = M (2-4 weeks)
   - 1 = S/XS (<2 weeks)

3. **Confidence (1-5)**: How well do we understand it?
   - 5 = Very high (validated with data and users)
   - 4 = High (strong evidence)
   - 3 = Medium (some evidence)
   - 2 = Low (assumptions)
   - 1 = Very low (speculation)

4. **Strategic Fit (1-5)**: Aligns with company strategy?
   - 5 = Core to company strategy
   - 4 = Strong alignment
   - 3 = Moderate alignment
   - 2 = Weak alignment
   - 1 = Off-strategy

**Opportunity Score Formula:**
```
Score = (Impact × Strategic Fit) / Effort × Confidence
```

**Create Opportunity Matrix:**

| Problem | Impact | Effort | Confidence | Strategic | Score | Rank |
|---------|--------|--------|------------|-----------|-------|------|
| Problem 1 | 5 | 3 | 4 | 5 | 10.42 | 1 |
| Problem 2 | 4 | 2 | 3 | 4 | 8.00 | 2 |
| Problem 3 | 3 | 4 | 3 | 3 | 2.25 | 3 |

### Step 5: Hypothesis Formation

For the **top 3 ranked problems**, help PM form testable hypotheses:

**Hypothesis Template:**

```markdown
### Hypothesis for Problem [N]

**Problem Statement:**
[Clear, one-sentence problem statement]

**Hypothesis:**
We believe that **[solution concept]** will result in **[measurable outcome]** for **[target users]**.

**Example:** We believe that building a real-time dashboard will result in 30% reduction in "where is my data?" support tickets for account managers.

**Underlying Assumptions:**
1. [Assumption 1: e.g., "Users have 5+ minutes to review dashboard daily"]
2. [Assumption 2: e.g., "Data freshness is the primary complaint, not data accuracy"]
3. [Assumption 3: e.g., "Users can interpret charts without training"]

**Risks to Validate:**
1. [Risk 1: What could make this hypothesis wrong?]
2. [Risk 2: What external factors could interfere?]
3. [Risk 3: What might we be overlooking?]

**Success Looks Like (Measurable):**
- Leading indicator 1: [Early signal, e.g., "50% of users view dashboard weekly"]
- Leading indicator 2: [Usage metric, e.g., "Average session time 3+ minutes"]
- Lagging indicator: [Business outcome, e.g., "Support tickets -30% in 3 months"]

**How We'll Validate:**
- Step 1: [e.g., "10 user interviews to understand current behavior"]
- Step 2: [e.g., "Analytics deep-dive on support ticket content"]
- Step 3: [e.g., "Competitive analysis to see if others solved this"]
```

### Step 6: Decision & Next Steps

**Decision Framework:**

Help PM choose ONE problem to pursue based on:
- Highest opportunity score
- Strategic importance
- Resource availability
- Timing/urgency

**Document Decision:**

```markdown
## Final Decision

**Chosen Problem:** [Problem title from matrix]

**Why This One:**
1. [Reason 1: e.g., "Highest impact × strategic fit score"]
2. [Reason 2: e.g., "Aligns with Q2 OKR on retention"]
3. [Reason 3: e.g., "Engineering capacity available"]
4. [Reason 4: e.g., "Can launch before competitor"]

**Alternatives Considered:**

**Problem [X]:** [Title]
- Why not chosen: [Reason - e.g., "Lower confidence, need more research first"]
- Potential future consideration: [Yes/No, When]

**Problem [Y]:** [Title]
- Why not chosen: [Reason]
- Potential future consideration: [Yes/No, When]

**De-Risking Plan:**
Before committing to full solution, we will:
1. [Validation step 1: e.g., "Run 10 user interviews"]
2. [Validation step 2: e.g., "Analyze 3 months of support data"]
3. [Validation step 3: e.g., "Check technical feasibility with eng"]

**Go/No-Go Criteria:**
We will proceed to PRD if:
- ✅ [Criterion 1: e.g., "≥70% of interviewees confirm pain is high/critical"]
- ✅ [Criterion 2: e.g., "Analytics data validates problem exists"]
- ✅ [Criterion 3: e.g., "Engineering confirms feasibility"]

If criteria not met: Revisit discovery or choose different problem.
```

## Quality Checks

Before completing discovery session:

- [ ] At least 3 problems explored
- [ ] Each problem has evidence cited (not just opinions)
- [ ] Opportunity scoring complete for all problems
- [ ] Top 3 have hypotheses with testable assumptions
- [ ] Final decision includes "why" rationale
- [ ] Alternatives documented (why not chosen)
- [ ] Go/No-Go criteria defined

## Output Summary

After completing discovery, present summary:

```markdown
## Discovery Session Summary

**Session ID:** [Timestamp-based ID]
**Date:** [YYYY-MM-DD]
**Participants:** [PM name + any stakeholders involved]

**Problems Explored:** [N problems]
**Top Ranked:** [Problem title, Score: X.XX]
**Decision:** [Proceed with Problem X]

**Next Steps:**
1. Run `/gbm.pm.interview` to conduct [N] user interviews
2. Target: Complete interviews in [X weeks]
3. After interviews: Run `/gbm.pm.research` for market/competitive analysis
```

## Next Steps

**Immediate:**
1. Create feature branch for chosen problem
2. Run `/gbm.pm.interview` to start user research

**Timeline:**
- Week 1-2: User interviews (10-15 participants)
- Week 2-3: Market research and analytics
- Week 3: Problem validation checkpoint

**Validation Checkpoint:**
After interviews and research, run `/gbm.pm.validate-problem` to decide: Proceed to PRD / Need more research / Kill idea

## Files Created

- `.gobuildme/specs/pm-discovery/<timestamp>/discovery.md` - Full discovery session
- `.gobuildme/specs/pm-discovery/<timestamp>/opportunity-matrix.md` - Scoring matrix
- `.gobuildme/specs/pm-discovery/<timestamp>/hypotheses.md` - Top 3 hypotheses

## Tips for PM

**Good Discovery:**
- ✅ Explores multiple problems (not committed to one solution)
- ✅ Uses evidence (data, feedback) not just opinions
- ✅ Scores objectively (not biased toward favorite idea)
- ✅ Forms testable hypotheses (can validate/invalidate)
- ✅ Plans validation before committing

**Bad Discovery:**
- ❌ Already decided on solution, just going through motions
- ❌ No evidence, all assumptions
- ❌ Scores manipulated to justify pet project
- ❌ Vague hypotheses ("improve user experience")
- ❌ Skips validation, jumps straight to PRD

## Iteration

Discovery is iterative. You can:
- Run `/gbm.pm.discover` multiple times for different opportunity spaces
- Revisit after learning from interviews/research
- Pivot to different problem if validation fails

**Common Flow:**
```
/gbm.pm.discover → /gbm.pm.interview → Learn users don't care about Problem 1
   ↓
   Back to /gbm.pm.discover → Choose Problem 2 → /gbm.pm.interview → Validated!
   ↓
   /gbm.pm.research → /gbm.pm.validate-problem → /gbm.pm.prd
```

### Step 7: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-pm-discover` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit discovery report to refine opportunities
- Run `/gbm.pm.research` to investigate specific opportunities deeper
- Run `/gbm.pm.validate-problem` to verify problem space
- Re-run `/gbm.pm.discover` with additional market insights

