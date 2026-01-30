---
description: "Conduct market research, competitive analysis, and analytics deep-dive to validate opportunities (PM Research Phase)"
scripts:
  sh: scripts/bash/pm-research.sh
  ps: scripts/powershell/pm-research.ps1
artifacts:
  - path: "$FEATURE_DIR/research/market-research.md"
    description: "Market sizing, trends, competitive landscape"
  - path: "$FEATURE_DIR/research/competitive-analysis.md"
    description: "Competitor feature comparison and positioning"
  - path: "$FEATURE_DIR/research/analytics-report.md"
    description: "Data-driven insights from product analytics"
---

## Output Style Requirements (MANDATORY)

**Research Artifacts**:
- Executive summary: 3-5 key findings first
- Tables for competitor comparisons, market data, metrics
- Citations: brief inline `[Source, Date]` format
- One insight per bullet - no multi-paragraph findings
- Recommendations: numbered action items, not prose

**Analytics Reports**:
- Dashboard screenshot references, not lengthy descriptions
- Metrics as tables: metric | value | trend | insight
- Statistical significance notes inline, not separate sections

# Product Manager: Market Research & Analytics

You are helping a Product Manager conduct thorough research to validate a problem/opportunity.

## Persona Context

**Primary**: Product Manager persona (owns this command)
**Available to**: Product Manager only (research is PM-specific work)

## Prerequisites

- **Required**: Completed `/gbm.pm.discover` (problem identified and scored)
- **Optional**: Completed `/gbm.pm.interview` (user research insights available)
- Access to:
  - Analytics platform (GA, Amplitude, Mixpanel, etc.)
  - Competitive intelligence tools
  - Market research databases
  - Internal data sources

## Your Task

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.pm.research" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

Run `{SCRIPT}` to create a research workspace, then guide PM through thorough research.

The script will:
1. Create `$FEATURE_DIR/research/` directory
2. Copy research templates (market, competitive, analytics)
3. Generate research session ID
4. Initialize evidence tracking matrix

## Research Process

**⚠️ MANDATORY: Web Search Requirement**

**YOU MUST USE WEB SEARCH TOOLS FOR ALL RESEARCH.**

This research phase requires real, current, verifiable data. You MUST use web search tools (WebSearch, online search, Google search) to:
- Find market research reports and analyst data
- Research actual competitors and their products
- Gather user reviews and feedback
- Validate claims with authoritative sources

**DO NOT:**
- ❌ Generate hypothetical or assumed data
- ❌ Create placeholder content like "[Research from X]"
- ❌ Invent competitor names or features
- ❌ Make up market statistics
- ❌ Assume pricing or company data

**Quality Standard:**
- ✅ Every claim must cite a specific source with URL
- ✅ Use authoritative sources (Gartner, Forrester, Crunchbase, G2, etc.)
- ✅ Data must be from last 12 months (prefer last 6 months)
- ✅ Competitors must be real companies with verifiable websites
- ✅ User reviews must be actual quotes with sources

**Citation Format (REQUIRED):**

Use this exact format for all citations:

**For Market Data:**
```
**Source:** [Report Title], [Publisher], [Publication Date], [URL]
**Example:** "Global CRM Market Size Report", Gartner, September 2024, https://gartner.com/reports/crm-2024
```

**For Competitor Data:**
```
**Source:** [Company Name] via [Platform], accessed [Date], [URL]
**Example:** Salesforce funding via Crunchbase, accessed Oct 2024, https://crunchbase.com/organization/salesforce
```

**For User Reviews:**
```
**Quote Source:** [Reviewer Name/Role], [Review Platform], [Date], [URL]
**Example:** "John D., IT Manager", G2 Reviews, Aug 2024, https://g2.com/products/salesforce/reviews/...
```

**For Trends/News:**
```
**Source:** [Article Title], [Publication], [Author], [Date], [URL]
**Example:** "AI Adoption in Enterprise Software", Forbes, Jane Smith, Sep 2024, https://forbes.com/...
```

**ENFORCEMENT:**
- Every data point, statistic, or claim MUST have a citation in the format above
- If you cannot find a source, write "**Data not available** - further research needed" instead of assuming
- Vague citations like "industry reports" or "market research" are NOT acceptable

---

### Step 3: Market Research & Sizing

Help the PM understand the market opportunity for the problem/solution.

**CRITICAL: Use Web Search Tools**

You MUST use web search tools (WebSearch, online search, Google search) to gather real, current market data. Do NOT generate hypothetical or assumed data.

**Required Web Searches:**
For complete style guidance, see .gobuildme/templates/_concise-style.md


1. **Market Sizing Data:**
   - Search: "[industry] market size 2024 2025 TAM SAM"
   - Search: "[problem space] market research report"
   - Search: "[industry] addressable market [geography]"
   - **Requirement:** Find at least 2 authoritative sources (Gartner, Forrester, IDC, Statista, industry associations, CB Insights)
   - **Cite:** Include source name, publication date, and URL

2. **Market Trends:**
   - Search: "[industry] trends 2024 2025"
   - Search: "[problem space] emerging technology"
   - Search: "[industry] market growth forecast"
   - **Requirement:** Find trends from last 6 months only (recent data)
   - **Cite:** Include analyst firm, report title, date, URL

3. **Customer Segment Validation:**
   - Search: "[target segment] statistics [industry]"
   - Search: "[customer persona] demographics market size"
   - Search: "[segment] willingness to pay [product category]"
   - **Cite:** Include source and date

4. **Market Maturity Indicators:**
   - Search: "[industry] maturity stage analysis"
   - Search: "[problem space] adoption curve"
   - Search: "[industry] funding trends venture capital"
   - **Cite:** Include source

**Evidence Quality Standard:**
- ✅ Every market claim must cite specific source with URL
- ✅ Data must be from last 12 months (prefer last 6 months)
- ✅ Use multiple sources to triangulate (minimum 2 sources per major claim)
- ❌ NO placeholder data like "[Research from X]" without actual research
- ❌ NO assumed numbers without source validation

**Market Research Checklist:**

Use template from `.gobuildme/templates/reference/pm-research-templates.md#market-research-template`

| Section | Requirements |
|---------|-------------|
| Market Sizing | TAM/SAM/SOM with sources, confidence rating |
| Market Trends | 3+ trends with impact/timeline, cited sources |
| Customer Segments | Size, severity, WTP per segment, primary target |
| Market Maturity | Stage + implications for solution/timing/competition |

**Citation Format:** `[Report], [Publisher], [Date], [URL]`

### Step 4: Competitive Analysis

Help the PM analyze how competitors address (or don't address) the problem.

**CRITICAL: Use Web Search Tools**

You MUST use web search tools to research actual competitors. Do NOT generate hypothetical competitor information.

**Required Web Searches:**

1. **Identify Competitors:**
   - Search: "[problem space] competitors"
   - Search: "[solution category] software vendors"
   - Search: "[industry] [problem] solutions"
   - Search: "[problem] alternative tools"
   - **Requirement:** Identify at least 3 real, named competitors with websites

2. **Competitor Company Data:**
   - Search: "[competitor name] funding crunchbase"
   - Search: "[competitor name] company overview"
   - Search: "[competitor name] team size employees"
   - Search: "[competitor name] revenue customers"
   - **Cite:** Include source (Crunchbase, LinkedIn, company website, news articles)

3. **Competitor Product Features:**
   - Search: "[competitor name] features documentation"
   - Search: "[competitor name] product tour"
   - Search: "[competitor name] pricing plans"
   - Visit competitor websites directly to review features
   - **Requirement:** Review actual product pages, not assumptions

4. **Competitor Reviews & Feedback:**
   - Search: "[competitor name] reviews G2"
   - Search: "[competitor name] reviews Capterra"
   - Search: "[competitor name] reddit complaints"
   - Search: "[competitor name] customer feedback twitter"
   - **Requirement:** Find at least 5 actual user reviews per major competitor
   - **Cite:** Include review source and date

5. **Competitive Intelligence:**
   - Search: "[competitor name] recent news announcements"
   - Search: "[competitor name] product roadmap"
   - Search: "[competitor name] vs [competitor B] comparison"
   - **Requirement:** Recent news (last 6 months)

**Evidence Quality Standard:**
- ✅ Every competitor must be a real company with verifiable website
- ✅ Company data must cite specific source (Crunchbase, news, LinkedIn)
- ✅ Feature analysis must reference actual product pages/docs
- ✅ User feedback must quote actual reviews with source
- ✅ Pricing must reference current public pricing page
- ❌ NO hypothetical competitors like "CompanyX" or "Tool123"
- ❌ NO assumed features without verification
- ❌ NO made-up user quotes

**Competitive Analysis Checklist:**

Use template from `.gobuildme/templates/reference/pm-research-templates.md#competitive-analysis-template`

| Section | Requirements |
|---------|-------------|
| Competitor Overview | 3+ competitors with website, funding, team size, position |
| Feature Comparison | Matrix with ✅/❌ ratings, identify gaps |
| Competitive Gaps | What's missing + user evidence + our advantage |
| User Feedback | Praise/complaints from G2/Capterra with quotes |
| Positioning | Primary differentiator + one-sentence positioning |

**Citation Format:** `[Company] via [Platform], accessed [Date], [URL]`

### Step 5: Analytics Deep-Dive

Help the PM analyze product data to validate the problem with quantitative evidence.

**Analytics Report Checklist:**

Use template from `.gobuildme/templates/reference/pm-research-templates.md#analytics-report-template`

| Section | Requirements |
|---------|-------------|
| Problem Validation | Current vs benchmark, trend (↑/↓/→), interpretation |
| User Impact | % affected, segment breakdown with severity |
| Business Impact | Lost revenue + support cost + churn delta = total |
| Funnel Analysis | Step-by-step with drop-off percentages |

**Validation Verdict:** YES if ≥10% affected + quantified impact + stable/worsening trend

### Step 6: Technical Feasibility Assessment

Help the PM assess whether the solution is technically viable.

**Technical Feasibility Checklist:**

| Section | Requirements |
|---------|-------------|
| Constraints | Architecture, tech stack, dependencies, tech debt |
| Risks | 3+ risks with likelihood/impact/mitigation |
| Effort | Component table with complexity/time/dependencies |
| Verdict | YES / YES-BUT / NO with reasoning |

**Verdict Criteria:**
- YES: Buildable with existing stack, manageable risks
- YES-BUT: Needs re-architecture or spikes
- NO: Fundamental limitations or external blockers

### Step 7: Research Synthesis & Evidence Quality

Help the PM synthesize all research and score evidence quality.

**Research Synthesis Checklist:**

Use template from `.gobuildme/templates/reference/pm-research-templates.md#research-synthesis-template`

| Section | Requirements |
|---------|-------------|
| Evidence Summary | ✅/❌ for each type: interviews, analytics, market, competitive, technical |
| Triangulation | Finding + quality + conclusion per evidence type |
| Quality Scoring | Weighted score table (interviews 30%, analytics 30%, market 20%, competitive 10%, technical 10%) |
| Recommendation | GO / GO WITH CAUTION / NO-GO with reasoning |

**Decision Criteria:**
- GO: Score ≥7, 3+ sources validate, feasibility YES/YES-BUT
- GO WITH CAUTION: Score 5-7, contradictions, needs de-risking
- NO-GO: Score <5, contradicts problem, feasibility NO

## Quality Checks

Before completing research session:

- [ ] Market sizing complete (TAM/SAM/SOM)
- [ ] At least 3 market trends documented with sources
- [ ] Competitive analysis covers 3+ direct competitors
- [ ] Feature comparison matrix complete
- [ ] Analytics validates problem with quantitative data
- [ ] Business impact quantified (revenue/cost)
- [ ] Technical feasibility assessed with engineering input
- [ ] Evidence triangulation shows validation across 3+ sources
- [ ] Evidence quality score calculated
- [ ] Go/No-Go recommendation made with clear reasoning

## Output Summary

After completing research, present summary:

```markdown
## Research Session Summary

**Problem/Opportunity:** [From /gbm.pm.discover]
**Research Date:** [YYYY-MM-DD]
**PM:** [Name]

**Evidence Quality:** [X/10]
**Evidence Result:** [VALIDATED / MIXED / NOT VALIDATED]
**Recommendation:** [GO / GO WITH CAUTION / NO-GO]

**Key Findings:**
1. Market: [TAM $X, growing Y% YoY]
2. Competition: [N competitors, Z key gaps identified]
3. Analytics: [Problem affects X% users, $Y business impact]
4. Feasibility: [Technical verdict]

**Next Steps:**
- If GO: Run `/gbm.pm.validate-problem` for final checkpoint
- If GO WITH CAUTION: Execute de-risking plan, then `/gbm.pm.validate-problem`
- If NO-GO: Return to `/gbm.pm.discover` to explore different problem
```

## Next Steps

**Recommended: Verify Research Quality with Fact-Checking**

After completing research, you should verify the quality of your sources and claims:

```bash
/gbm.fact-check research/market-research.md
/gbm.fact-check research/competitive-analysis.md
```

**What Fact-Checking Provides:**
- ✅ Verifies sources are authoritative (Gartner, Forrester, official docs)
- ⚠️ Flags weak sources and suggests better alternatives
- 📊 Scores research quality (A/B/C/D grading)
- 🔗 Generates proper citations (APA/IEEE/Chicago)
- ✨ Creates verified version with inline citations

**Important:** Fact-checking is advisory, not blocking. You can proceed with research regardless of quality score, but higher quality improves downstream decision-making.

**If Research Shows GO/GO WITH CAUTION:**
1. (Optional) Run fact-check commands above to improve research quality
2. Run `/gbm.pm.validate-problem` for final validation checkpoint
3. This command synthesizes discovery + interviews + research
4. Makes final go/no-go decision before committing to PRD

**If Research Shows NO-GO:**
1. Document learnings
2. Return to `/gbm.pm.discover` to explore different problem from opportunity matrix
3. Don't proceed to PRD with low-quality evidence

## Files Created

- `$FEATURE_DIR/research/market-research.md` - Market sizing, trends, segments
- `$FEATURE_DIR/research/competitive-analysis.md` - Competitor deep-dives, gaps
- `$FEATURE_DIR/research/analytics-report.md` - Data-driven insights
- `$FEATURE_DIR/research/technical-feasibility.md` - Engineering assessment
- `$FEATURE_DIR/research/synthesis.md` - Evidence quality, recommendation

## Tips for PM

**Good Research:**
- ✅ Multi-source evidence (not just one data point)
- ✅ Quantified business impact (not vague)
- ✅ Honest about gaps and uncertainties
- ✅ Competitive analysis shows differentiation opportunity
- ✅ Technical feasibility consulted with engineering (not PM guess)

**Bad Research:**
- ❌ Cherry-picking data to support favorite idea
- ❌ Skipping analytics ("we know users want this")
- ❌ Competitive analysis only shows our advantages
- ❌ Technical feasibility assumed without engineering input
- ❌ No sources cited for market claims

## Integration with PM Workflow

**Workflow Position:**
```
/gbm.pm.discover → /gbm.pm.interview → /gbm.pm.research ← YOU ARE HERE
                                      ↓
                          /gbm.pm.validate-problem → /gbm.pm.prd
```

**Research Uses:**
- Discovery insights (problem identified, hypotheses formed)
- Interview findings (user pain validated, quotes captured)
- Analytics data (quantitative validation)
- Competitive landscape (differentiation identified)

**Research Feeds Into:**
- Problem validation checkpoint (final go/no-go)
- PRD (market context, competitive positioning)
- User stories (informed by research insights)

### Step 8: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-pm-research` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit research report to add additional findings
- Run `/gbm.pm.interview` to gather more data points
- Run `/gbm.pm.discover` to identify new opportunities
- Re-run `/gbm.pm.research` with refined research questions

