# PM Research Templates

Reference templates for `/gbm.pm.research` artifacts. Use these structures when creating research documents.

---

## Market Research Template

```markdown
## Market Research Report

**Problem/Opportunity:** [From /gbm.pm.discover]
**Research Date:** [YYYY-MM-DD]

### Market Sizing

| Market | Size | Source |
|--------|------|--------|
| TAM | $X billion | [Report], [Publisher], [Date], [URL] |
| SAM | $X million | [Report], [Publisher], [Date], [URL] |
| SOM | $X thousand | Based on [competitive analysis] |

**Confidence:** [High/Medium/Low] - [Reasoning]

### Market Trends

| Trend | Impact | Timeline | Source |
|-------|--------|----------|--------|
| [Trend 1] | [Impact on problem] | [Short/Medium/Long] | [Source], [Date], [URL] |
| [Trend 2] | [Impact] | [Timeline] | [Source] |
| [Trend 3] | [Impact] | [Timeline] | [Source] |

### Customer Segments

| Segment | Size | Problem Severity | Willingness to Pay |
|---------|------|------------------|-------------------|
| [Segment 1] | [X%] | [High/Med/Low] | [High/Med/Low] |
| [Segment 2] | [X%] | [Severity] | [WTP] |

**Primary Target:** [Segment name] - [One-line rationale]
```

---

## Competitive Analysis Template

```markdown
## Competitive Analysis

**Analysis Date:** [YYYY-MM-DD]

### Competitor Overview

| Competitor | Website | Funding | Team Size | Position |
|------------|---------|---------|-----------|----------|
| [Name A] | [URL] | [$X, Series Y] | [N] | [Leader/Challenger] |
| [Name B] | [URL] | [Funding] | [N] | [Position] |
| [Name C] | [URL] | [Funding] | [N] | [Position] |

**Source:** Crunchbase, accessed [Date]

### Feature Comparison

| Feature | Our Approach | Competitor A | Competitor B | Competitor C | Gap? |
|---------|--------------|--------------|--------------|--------------|------|
| [Feature 1] | [How] | ✅ Advanced | ✅ Basic | ❌ None | **Opportunity** |
| [Feature 2] | [How] | ❌ None | ✅ Basic | ✅ Basic | Catch-up |

### Competitive Gaps

| Gap | What's Missing | User Evidence | Our Advantage |
|-----|----------------|---------------|---------------|
| [Gap 1] | [Description] | [From reviews/interviews] | [Why we can fill] |
| [Gap 2] | [Description] | [Evidence] | [Advantage] |

### User Feedback Summary

| Competitor | Praise | Complaints | Net Sentiment | Source |
|------------|--------|------------|---------------|--------|
| [Name A] | [What users love] | [What users hate] | [Pos/Neu/Neg] | [G2/Capterra], [Date] |

### Positioning

**Differentiation:** [Primary differentiator vs. competitors]
**Messaging:** "[One-sentence positioning statement]"
```

---

## Analytics Report Template

```markdown
## Analytics Deep-Dive

**Date Range:** [YYYY-MM-DD to YYYY-MM-DD]
**Data Sources:** [GA4, Amplitude, etc.]

### Problem Validation

| Metric | Current | Benchmark | Trend | Interpretation |
|--------|---------|-----------|-------|----------------|
| [Abandonment rate] | [X%] | [Y%] | [↑/↓/→] | [What this means] |
| [Support tickets] | [N/month] | [Trend] | [↑/↓/→] | [Interpretation] |

### User Impact

| Segment | % of Users | % Experiencing Problem | Severity (1-10) |
|---------|------------|------------------------|-----------------|
| [Segment 1] | [X%] | [Y%] | [Z] |

**Affected Users:** [N users] ([X%] of total)

### Business Impact

| Impact Type | Amount | Calculation |
|-------------|--------|-------------|
| Lost Revenue | [$X/month] | [Methodology] |
| Support Cost | [$Y/month] | [N tickets × $Z] |
| Churn Delta | [+X%] | [Problem vs. non-problem users] |

**Total Impact:** [$X/year]

### Funnel Analysis

```
Step 1: [Action] → [X%] proceed
  ↓ [-Y%] drop-off ← PROBLEM
Step 2: [Action] → [Z%] proceed
```

**Verdict:** [YES/NO] - [Reasoning]
```

---

## Research Synthesis Template

```markdown
## Research Synthesis

### Evidence Summary

| Evidence Type | Available | Quality | Score (1-10) |
|---------------|-----------|---------|--------------|
| User interviews | [✅/❌] | [H/M/L] | [X] |
| Analytics data | [✅/❌] | [H/M/L] | [X] |
| Market research | [✅/❌] | [H/M/L] | [X] |
| Competitive intel | [✅/❌] | [H/M/L] | [X] |
| Technical assess | [✅/❌] | [H/M/L] | [X] |

**Weighted Score:** [X/10]

### Triangulation

| Evidence Type | Finding | Conclusion |
|---------------|---------|------------|
| User Research | [Key finding] | [Validates/Contradicts/Neutral] |
| Analytics | [Key finding] | [Validates/Contradicts/Neutral] |
| Market | [Key finding] | [Validates/Contradicts/Neutral] |
| Competitive | [Key finding] | [Validates/Contradicts/Neutral] |

**Result:** [VALIDATED/MIXED/NOT VALIDATED]

### Recommendation

**Decision:** [GO / GO WITH CAUTION / NO-GO]

**Reasoning:**
1. [Evidence quality]
2. [Market opportunity]
3. [Technical feasibility]
4. [Competitive position]

**De-Risking (if GO WITH CAUTION):**
1. [Action + timeline]
2. [Action + timeline]
```

---

## Citation Formats

**Market Data:** `[Report Title], [Publisher], [Date], [URL]`

**Competitor Data:** `[Company] via [Platform], accessed [Date], [URL]`

**User Reviews:** `[Name/Role], [Platform], [Date], [URL]`

**News/Trends:** `[Title], [Publication], [Author], [Date], [URL]`
