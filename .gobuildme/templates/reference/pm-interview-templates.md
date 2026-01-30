# PM Interview Templates

> **Usage**: Full templates for `/gbm.pm.interview` command.
> **Location**: `.gobuildme/specs/<feature>/interviews/`

---

## Interview Guide Template

```markdown
# Interview Guide: [Feature/Problem Name]

## Research Objectives

**Primary Question:** [Main thing you're trying to learn]
Example: "Do account managers struggle to understand customer health without a dashboard?"

**Secondary Questions:**
1. [Supporting question 1]
2. [Supporting question 2]
3. [Supporting question 3]

## Problem Being Validated

**From Discovery:** [Copy problem statement from /gbm.pm.discover]
**Hypothesis:** [Copy hypothesis from discovery]

## Target Participants

**Persona 1:** [Description]
- Characteristics: [e.g., "Account managers at mid-market companies"]
- Sample size: [5-7 interviews]
- Why this persona: [Reasoning]

**Persona 2:** [Description] (if applicable)
**Total Target:** [10-15 interviews recommended]

## Interview Script (60 minutes)

### Introduction (5 min)
"Thanks for taking time. I'm [Name] from [Company], researching how [target users] currently [do something related to problem]. This isn't a sales call - we're in early research. No right or wrong answers. I'll take notes, everything confidential. Questions before we start?"

### Current State (10-15 min)
Goal: Understand current behavior and context

1. "Walk me through how you currently [do X related to problem]."
   - Follow-up: Frequency? Who else involved?
2. "What tools or systems do you use?"
   - Follow-up: What do you like/dislike?
3. "Describe a typical day/week when [context around problem]."
   - Listen for: Workflow, pain points, time spent

### Pain Points (10-15 min)
Goal: Validate problem exists and understand severity

1. "What's the hardest part about [activity related to problem]?"
   - Follow-up: Specific example? How often?
2. "What happens when [problem occurs]?"
   - Follow-up: Impact on work? On business?
3. "On a scale of 1-10, how painful is [problem]? Why?"
   - If <7: What would make it more painful?
   - If ≥7: What have you tried to fix it?

### Workarounds & Alternatives (10-15 min)
Goal: Understand current solutions and unmet needs

1. "What have you tried to solve or work around [problem]?"
   - Follow-up: Did it work? What was missing?
2. "Have you looked at other tools or solutions?"
   - Follow-up: What did you try? Why didn't you adopt?
3. "If you had a magic wand, what would the perfect solution look like?"
   - Listen for: Must-haves vs. nice-to-haves

### Solution Exploration (10-15 min)
Goal: Test hypothesis and gauge solution interest

"I want to share a concept we're exploring and get your reaction."
[Describe solution concept at high level]

1. "What's your initial reaction?"
   - Follow-up: What excites you? What concerns you?
2. "How would this fit into your current workflow?"
3. "On a scale of 1-10, how likely would you be to use this? Why?"
   - If <7: What would make you more likely?
   - If ≥7: What would make this a must-have?
4. "What features are must-haves vs. nice-to-haves?"

### Wrap-up (5 min)
1. "Anything else about [problem/solution] I should know?"
2. "Can I follow up in a few weeks?"
3. "Know anyone else with insights on this topic?" (Snowball sampling)

Thank participant for time and candid feedback.
```

---

## Individual Interview Notes Template

```markdown
# Interview [N]: [Participant Code/Name]

**Date:** [YYYY-MM-DD] | **Duration:** [X min] | **Interviewer:** [Name]
**Participant:** [Anonymized ID or role]

## Participant Profile
- **Role:** [Job title]
- **Company:** [Size/industry]
- **Experience:** [Years in role]
- **Persona:** [Which target persona]

## Interview Notes

### Current State
**How they currently [do X]:** [Notes on process]
**Tools/Systems:** Tool 1 (what/why), Tool 2 (what/why)
**Frequency/Context:** [How often, when, where]

### Pain Points
**Pain Point 1:** [Description]
- Severity: [Critical/High/Medium/Low]
- Frequency: [Daily/Weekly/Monthly/Rare]
- Impact: [How it affects work]

**Pain Score:** [1-10] | **Rationale:** [Why this score]

### Workarounds
**What they've tried:**
1. [Workaround] - Result: [Worked/Didn't/Partial]

**Alternatives Considered:** [Other tools]
**Why not adopted:** [Reasons]

### Solution Reaction
**Concept Described:** [Brief summary]
**Initial Reaction:** [Positive/negative/mixed]
**Excitement:** [What they liked, use cases]
**Concerns:** [Worries, blockers]
**Likelihood to Use:** [1-10] | **Rationale:** [Why]

**Must-Have Features:**
1. [Feature] - Why: [Reason]

**Nice-to-Have Features:**
1. [Feature]

### Key Quotes (Verbatim)
> "[Quote about pain point]"
> "[Quote about desired outcome]"
> "[Quote about solution reaction]"

### Behavioral Observations
- Said vs. Did: [Discrepancies]
- Body language/Tone: [Nonverbal cues]
- Hesitations: [Uncertain topics]

## Post-Interview Reflection

**Key Insights:**
1. [Most important takeaway]
2. [Second most important]
3. [Third most important]

**Confidence Levels:**
| Question | Confidence |
|----------|------------|
| Problem exists for persona? | High/Med/Low |
| Pain severe enough? | High/Med/Low |
| Solution resonates? | High/Med/Low |
| Would actually use? | High/Med/Low |

**Hypothesis Validation:** ☐ Supported ☐ Refuted ☐ Mixed ☐ Unclear

**Tags:** [#high-pain, #workflow-fit, #pricing-concern]
```

---

## Synthesis Template

```markdown
# Interview Synthesis: [Feature/Problem Name]

**Date:** [YYYY-MM-DD] | **Total Interviews:** [N]
**Personas:** Persona 1 ([N]), Persona 2 ([N])

## Cross-Interview Patterns

### Themes by Frequency

**Strong Pattern (≥70%):**
- **Theme 1:** [Theme name] - [X/N participants]
  - Description: [What they said]
  - Implications: [What this means for solution]

**Moderate Pattern (50-69%):**
- **Theme 2:** [Theme name] - [X/N participants]

**Weak/Persona-Specific (<50%):**
- **Theme 3:** [Theme name] - Note: [Why outlier]

### Pain Severity Distribution

| Score | Count | % | Personas |
|-------|-------|---|----------|
| 9-10 (Critical) | [N] | [%] | [Which] |
| 7-8 (High) | [N] | [%] | [Which] |
| 5-6 (Medium) | [N] | [%] | [Which] |
| <5 (Low) | [N] | [%] | [Which] |

**Average:** [X.X/10] | **Insight:** [Is pain severe enough?]

### Likelihood to Use Distribution

| Score | Count | % | Personas |
|-------|-------|---|----------|
| 9-10 (Definitely) | [N] | [%] | [Which] |
| 7-8 (Likely) | [N] | [%] | [Which] |
| 5-6 (Maybe) | [N] | [%] | [Which] |
| <5 (Unlikely) | [N] | [%] | [Which] |

**Average:** [X.X/10] | **Insight:** [Is demand strong enough?]

## Persona Differences

| Insight | Persona 1 | Persona 2 | Implication |
|---------|-----------|-----------|-------------|
| Pain severity | [Score] | [Score] | [Which to focus on] |
| Main pain point | [What] | [What] | [Different needs] |
| Must-have feature | [Feature] | [Feature] | [Different use cases] |

**Primary Target:** [Persona] | **Rationale:** [Higher pain/intent/fit]

## Must-Have vs. Nice-to-Have

**Must-Have (>60% critical):**
1. **[Feature]** - [X/N] - Why: [Reason]
2. **[Feature]** - [X/N] - Why: [Reason]

**Nice-to-Have:**
1. **[Feature]** - [X/N]

**NOT Wanted (<20%):**
1. **[Feature]** - Why: [Concerns]

## Hypothesis Validation

**Original:** [From discovery]
**Result:** ☐ STRONGLY SUPPORTED (>70%) ☐ SUPPORTED (50-70%) ☐ MIXED ☐ REFUTED

**Supporting Evidence:**
1. [Evidence 1]
2. [Evidence 2]

**Contradicting Evidence:**
1. [Counter-example]

**Revised Hypothesis (if needed):** [Refinement]

## Key Insights Summary

1. **[Insight]** - Confidence: H/M/L - Impact: [Change to approach]
2. **[Insight]** - Confidence: H/M/L
3. **[Insight]** - Confidence: H/M/L

## Confidence Assessment

| Evidence Type | Quality | Notes |
|---------------|---------|-------|
| Sample size | ✅/⚠️/❌ | [N interviews] |
| Persona coverage | ✅/⚠️/❌ | [Coverage] |
| Response consistency | ✅/⚠️/❌ | [Agreement %] |
| Pain severity | ✅/⚠️/❌ | [Avg score] |
| Likelihood to use | ✅/⚠️/❌ | [Avg score] |

**Overall Confidence:** ☐ High ☐ Medium ☐ Low
**Strengths:** [Confident about]
**Gaps:** [Still need to learn]

## Recommendations

**Proceed?**
☐ YES - Strong evidence
☐ YES, WITH ADJUSTMENTS - Adjust approach
☐ NO, NEED MORE RESEARCH - Gaps remain
☐ NO, PIVOT - Different direction

**Next Steps:**
- If YES: Run `/gbm.pm.research` for market/competitive analysis
- If ADJUST: [What to change and why]
- If MORE RESEARCH: Conduct [N] more interviews focusing on [X]
- If PIVOT: Return to `/gbm.pm.discover`
```

---

## Interview Cadence Guidelines

- **Target**: 2-3 interviews per day
- **Spacing**: Allow time between for reflection
- **Iteration**: Adjust questions based on learnings
- **Minimum**: 10 interviews for reliable patterns
- **Saturation**: Stop when hearing same themes repeatedly

## Good vs. Bad Interview Practices

**Good:**
- Ask open-ended questions ("Tell me about..." not "Do you...?")
- Listen more than talk (80/20 rule)
- Dig into specifics ("Can you give an example?")
- Look for patterns across interviews
- Stay neutral (don't lead)

**Bad:**
- Leading questions ("Don't you think X is a problem?")
- Pitching solution instead of listening
- Accepting vague answers
- Confirmation bias
- Small sample size (<5)
