### Product Manager Fact-Checking Standards

**Philosophy**: Market research and competitive intelligence must be accurate to drive product strategy. When claims cannot be verified, we provide alternative data sources and correction suggestions.

---

#### Critical Claim Types

**1. Market Sizing Claims** (Required Quality: A, 90%+)
- TAM/SAM/SOM calculations
- Market share data
- Revenue projections
- Growth rates (CAGR)

**Verification Requirements**:
- Minimum 3 Tier 1 analyst sources (Gartner, Forrester, IDC, McKinsey)
- Sources must be from last 12 months
- If older, mark as "[OUTDATED - Q4 2023 DATA]"

**Correction Assistance**:
- If <3 sources: System suggests searches for additional analysts
- If sources weak: System provides alternative phrasings from stronger sources
- If data conflicting: System presents all findings and suggests range format

**Example Correction**:
```
❌ Original (Quality: D):
"The AI coding assistant market is valued at $1.5B in 2024"

✅ Option A - Stronger Source (Quality: A):
"According to Gartner's 2024 Market Guide, the AI development tools market is estimated at $1.2-1.8B, with 38% YoY growth [1]"
[1] Gartner. (2024). Market Guide for AI-Powered Developer Tools.

✅ Option B - Mark as Estimate (Quality: C):
"[INDUSTRY ESTIMATE] The AI coding assistant market is valued at approximately $1-2B in 2024 based on multiple analyst projections [2][3]"
```

---

**2. Competitive Intelligence** (Required Quality: B+, 85%+)
- Feature comparisons
- Pricing data
- Market position
- User counts/adoption metrics

**Verification Requirements**:
- Tier 1-2 sources acceptable
- Screenshots required for UI/UX claims
- Pricing must be archived (changes frequently)
- User counts require official announcements or verified press

**Correction Assistance**:
- If pricing unavailable: Suggest contacting sales or trial
- If features uncertain: Suggest "as of [date]" qualifier
- If user counts unavailable: Suggest "estimated based on [source]" or remove

---

**3. User Demographics** (Required Quality: B+, 85%+)
- User personas
- Demographics data
- Behavioral data
- Survey results

**Verification Requirements**:
- Sample size > 1,000 for quantitative claims
- Methodology must be disclosed
- Survey provider credibility (Tier 1-2)

**Correction Assistance**:
- Small sample: Suggest "small-scale survey" qualifier or remove percentage
- Unclear methodology: Suggest "informal survey" or "anecdotal evidence"
- Weak source: Search for larger, authoritative surveys

---

**4. Pricing Data** (Required Quality: A, 90%+)
- SaaS pricing tiers
- Infrastructure costs
- License fees

**Verification Requirements**:
- Must be archived
- Date specified ("as of October 2024")
- Tier 1 sources only (official pricing pages, vendor quotes)

**Correction Assistance**:
- Page down: Provide Web Archive link or suggest sales contact
- Outdated: Search for current pricing and suggest update
- Regional variance: Suggest specifying region or range

---

#### Integration with PM Workflow

```bash
# Standard workflow
/gbm.pm.research "Market analysis for AI coding assistants"
/gbm.fact-check research.md

# Review corrections
cat .gobuildme/specs/<feature>/fact-check-report.md

# Choose option: A) Accept all, B) Selective, C) Continue as-is
# Then proceed
/gbm.pm.prd
```

**Note**: Low-quality research shows warnings in PRD but does NOT block creation.
