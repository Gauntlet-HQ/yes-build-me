# Problem Validation Report Template

> **Usage**: Full template for `/gbm.pm.validate-problem` command.
> **Location**: `.gobuildme/specs/<feature>/validation-report.md`

---

## Executive Summary Section

```markdown
## Problem Validation Report

**Problem/Opportunity:** [From /gbm.pm.discover]
**Validation Date:** [YYYY-MM-DD]
**Product Manager:** [Name]

---

## Executive Summary

**Problem Statement:** [One-sentence from /gbm.pm.discover]
**Target Users:** [From interviews]
**Validation Verdict:** [GO / NO-GO / NEED MORE DATA]

**If GO:**
- Proceed to `/gbm.pm.prd`
- Business impact: [$X/month or Y% improvement]
- Timeline: [Launch in Z weeks/months]

**If NO-GO:**
- Return to `/gbm.pm.discover`
- Key learnings documented below

**If NEED MORE DATA:**
- Gaps identified
- De-risking plan with timeline
```

---

## Evidence Summary Section

### Source 1: Discovery Session

```markdown
**From:** `/gbm.pm.discover` (Session: [ID], Date: [YYYY-MM-DD])
**Problems Explored:** [N]
**Opportunity Score:** [X.XX out of ~15]
**Rank:** [#N of M]

**Hypothesis:** [Copy verbatim from discovery]
**Initial Confidence:** [High / Medium / Low]

**Assumptions to Validate:**
1. [Assumption 1]
2. [Assumption 2]
3. [Assumption 3]
```

### Source 2: User Interviews

```markdown
**From:** `/gbm.pm.interview` (Interviews: [N], Date: [YYYY-MM-DD])

**Participants:** [N interviews, personas, companies]

**Pain Severity:** Avg [X.X/10], Verdict: [Pain is real / Overstated / Mixed]
**Frequency:** [Daily/Weekly/Monthly distribution], Verdict: [Frequent / Occasional]
**Willingness to Adopt:** Avg [X.X/10], Verdict: [Strong / Moderate / Weak demand]

**Top 3 Themes:**
1. [Theme 1 - X/N participants]
2. [Theme 2 - Y/N participants]
3. [Theme 3 - Z/N participants]

**Assumption Validation:**
- Assumption 1: [✅ Validated / ⚠️ Partial / ❌ Invalidated]
- Assumption 2: [✅ / ⚠️ / ❌]
- Assumption 3: [✅ / ⚠️ / ❌]
```

### Source 3: Market Research

```markdown
**From:** `/gbm.pm.research` (Date: [YYYY-MM-DD])

**Market Opportunity:**
- TAM: [$X billion], SAM: [$Y million], SOM: [$Z thousand]
- Verdict: [Large / Niche / Small opportunity]

**Market Maturity:** [Nascent / Growing / Mature / Declining]
**Timing:** [Now / Wait / Too late]
```

### Source 4: Competitive Analysis

```markdown
**From:** `/gbm.pm.research` (Date: [YYYY-MM-DD])

**Competitors:** [N direct, M indirect]

**Key Competitive Gaps:**
1. [Gap 1]
2. [Gap 2]
3. [Gap 3]

**Competitive Intensity:** [Red ocean / Moderate / Blue ocean]
**Differentiation Potential:** [Strong / Moderate / Weak]
```

### Source 5: Analytics Data

```markdown
**From:** `/gbm.pm.research` (Date: [YYYY-MM-DD])

**Problem Validation:**
- Users affected: [N users, X%]
- Frequency: [Y times/user/month]
- Verdict: [Data confirms / Contradicts / Inconclusive]

**Business Impact:** [$X revenue + $Y cost = $Z/month total]
```

### Source 6: Technical Feasibility

```markdown
**From:** `/gbm.pm.research` (Date: [YYYY-MM-DD])

**Feasibility:** [YES / YES, BUT / NO]
**Effort:** [X eng-weeks, Y design-weeks, Z total weeks]
**Confidence:** [High / Medium / Low]
```

---

## Validation Scorecard

### Scoring Framework

Score 0-10 per dimension:
- **10**: Excellent, strong evidence
- **7-9**: Good, minor gaps
- **4-6**: Fair, concerns exist
- **1-3**: Weak, significant gaps
- **0**: No evidence or disproved

### Dimension 1: Problem Validation (Threshold: ≥7.0)

| Criterion | Score | Reasoning |
|-----------|-------|-----------|
| User pain severity | [X] | [Pain X/10 from N interviews] |
| Frequency of problem | [X] | [Daily/weekly in Y% users] |
| Analytics confirmation | [X] | [Z% drop-off, $W impact] |
| Current workarounds | [X] | [N hours/month on workarounds] |

**Average:** [X.X/10] **Result:** [✅ Pass / ❌ Fail]

### Dimension 2: Market Opportunity (Threshold: ≥6.0)

| Criterion | Score | Reasoning |
|-----------|-------|-----------|
| Market size | [X] | [TAM $X, SAM $Y] |
| Market growth | [X] | [X% YoY] |
| Segment clarity | [X] | [Clear/Fragmented] |
| Timing | [X] | [Right time / Early / Late] |

**Average:** [X.X/10] **Result:** [✅ Pass / ❌ Fail]

### Dimension 3: Competitive Advantage (Threshold: ≥6.0)

| Criterion | Score | Reasoning |
|-----------|-------|-----------|
| Competitive gaps | [X] | [N gaps / Saturated] |
| Differentiation | [X] | [Unique / Incremental] |
| Positioning clarity | [X] | [Clear / Unclear] |
| Barriers to entry | [X] | [Defensible / Easy to copy] |

**Average:** [X.X/10] **Result:** [✅ Pass / ❌ Fail]

### Dimension 4: User Demand (Threshold: ≥7.0)

| Criterion | Score | Reasoning |
|-----------|-------|-----------|
| Likelihood to adopt | [X] | [Avg X/10] |
| Willingness to pay | [X] | [Budget / Sensitive / Free] |
| Urgency | [X] | [Critical / Nice-to-have] |
| User validation | [X] | [N said "use today"] |

**Average:** [X.X/10] **Result:** [✅ Pass / ❌ Fail]

### Dimension 5: Feasibility & ROI (Threshold: ≥6.0)

| Criterion | Score | Reasoning |
|-----------|-------|-----------|
| Technical feasibility | [X] | [YES:10, YES-BUT:6, NO:0] |
| Effort vs. impact | [X] | [High/Mod/Low ROI] |
| Resource availability | [X] | [Available / Need hire] |
| Risk level | [X] | [Low / Medium / High] |

**Average:** [X.X/10] **Result:** [✅ Pass / ❌ Fail]

### Dimension 6: Evidence Quality (Threshold: ≥7.0)

| Criterion | Score | Reasoning |
|-----------|-------|-----------|
| Sample size | [X] | [N interviews, M data points] |
| Source diversity | [X] | [Qual+quant+competitive] |
| Data freshness | [X] | [30d / 3mo / 6mo+] |
| Triangulation | [X] | [3+ agree / Mixed / Contradictory] |

**Average:** [X.X/10] **Result:** [✅ Pass / ❌ Fail]

---

## Overall Score Calculation

```
Overall = (D1×25% + D2×15% + D3×15% + D4×25% + D5×10% + D6×10%) / 10
```

**Score Interpretation:**
- **8.0-10.0**: Strong → GO
- **6.0-7.9**: Good → GO (with de-risking)
- **4.0-5.9**: Weak → NEED MORE DATA
- **0.0-3.9**: Failed → NO-GO

---

## Critical Success Factors (Need ≥8/10)

- [ ] Problem is real (≥7/10 pain severity)
- [ ] Problem is frequent (users encounter often)
- [ ] Business impact quantified (≥$X/month)
- [ ] User demand (≥60% rated ≥7/10 adoption)
- [ ] Market size (TAM/SAM thresholds)
- [ ] Competitive gap (clear differentiation)
- [ ] Technical feasibility (YES or YES-BUT)
- [ ] Evidence quality (≥10 interviews + analytics + competitive)
- [ ] Assumptions validated (no major invalidations)
- [ ] Stakeholder alignment (Eng, Design, Sales bought in)

---

## Risk Assessment

**Risk Template:**
- **Category:** [Market / Technical / Competitive / User Adoption]
- **Description:** [What could go wrong]
- **Likelihood × Impact:** [H/M/L × H/M/L]
- **Mitigation:** [How to reduce]
- **Acceptable?** [Yes / No]

**Risk Tolerance:**
- High Risk: Proceed only if score ≥8.0 + clear mitigation
- Medium Risk: Proceed if score ≥6.5
- Low Risk: Proceed if score ≥6.0

---

## Final Decision Matrix

| Criterion | Threshold | Actual | Pass? |
|-----------|-----------|--------|-------|
| Overall Score | ≥6.0 | [X.X/10] | [✅/❌] |
| Critical Factors | ≥8/10 | [Y/10] | [✅/❌] |
| Dimensions Pass | 6/6 | [Z/6] | [✅/❌] |
| Risk Acceptable | Yes | [Yes/No] | [✅/❌] |

---

## Decision Templates

### GO Decision

**✅ Proceed to PRD because:**
1. [Validation score X.X/10, strong evidence]
2. [All critical factors met]
3. [Clear competitive differentiation]
4. [Technical feasibility confirmed]

**Next Steps:**
1. Run `/gbm.pm.prd`
2. Timeline: [X weeks to launch]
3. Team: [N eng, M design]

### NO-GO Decision

**❌ NOT proceeding because:**
1. [Weak score X.X/10]
2. [Dimension X failed]
3. [Contradictory evidence]

**Learnings:** [Key insights]
**Pivot Options:** [Alternatives from discovery]

### NEED MORE DATA Decision

**⚠️ Cannot decide because:**
1. [Gap 1 - current vs. needed]
2. [Gap 2 - current vs. needed]

**De-Risking Plan:**

| Gap | Current | Target | Method | Timeline |
|-----|---------|--------|--------|----------|
| [Gap 1] | [Have] | [Need] | [How] | [X weeks] |

**Re-Validation Date:** [YYYY-MM-DD]

---

## Stakeholder Sign-Off

| Role | Name | Approval | Date |
|------|------|----------|------|
| Product Manager | [Name] | [✅/❌] | [Date] |
| Engineering Lead | [Name] | [✅/❌] | [Date] |
| Design Lead | [Name] | [✅/❌] | [Date] |

---

## Artifact References

1. Discovery: `.gobuildme/specs/pm-discovery/<session-id>/discovery.md`
2. Interviews: `.gobuildme/specs/<feature>/interviews/synthesis.md`
3. Market: `.gobuildme/specs/<feature>/research/market-research.md`
4. Competitive: `.gobuildme/specs/<feature>/research/competitive-analysis.md`
5. Analytics: `.gobuildme/specs/<feature>/research/analytics-report.md`
6. Technical: `.gobuildme/specs/<feature>/research/technical-feasibility.md`
