---
description: "Fact-check research documents and validate claims against constitution standards with correction-focused guidance"
artifacts:
  - path: "$FEATURE_DIR/research/fact-check-report.md"
    description: "Complete fact-check report with verification results, quality scores, and correction suggestions"
  - path: "$FEATURE_DIR/research/claims.yaml"
    description: "All extracted claims with verification results and source citations"
  - path: "$FEATURE_DIR/research/citations.yaml"
    description: "Structured citation data with source authority tiers"
  - path: "$FEATURE_DIR/research/<source>-verified.md"
    description: "Corrected version of source document with verified claims and citations"
scripts:
  sh: scripts/bash/fact-check.sh
  ps: scripts/powershell/fact-check.ps1
---

## User Input

The user input can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

## Fact-Checking Workflow

### 1. Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.fact-check" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### 2. Parse Context

Run `{SCRIPT}` from repo root and parse JSON output:
- `feature_dir`: Feature specs directory
- `source_file`: Document to fact-check
- `persona_id`: Active persona ID
- `constitution_path`: Constitution file path

**Note**: For single quotes in args like "I'm Groot", use escape syntax: `'I'\''m Groot'` (or double-quote: `"I'm Groot"`).

---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide


### 3. Load Standards

**A. Load Constitution Standards** (REQUIRED):
- Read `constitution_path` Section VI: Research and Fact-Checking Standards
- Extract: Quality score definitions (A/B/C/D), source authority tiers (Tier 1/2/3/Prohibited), citation format (APA/IEEE/Chicago), archival requirements
- **Philosophy Check**: Confirm fact-checking is correction-focused, NOT blocking

**B. Load Persona Requirements** (if `persona_id` set):
- Check if persona has fact-checking requirements in `.gobuildme/config/personas.yaml`
- If yes, read `.gobuildme/templates/personas/partials/<persona_id>/fact-check.md`
- Extract: Critical claim types, required quality levels (90%+, 100%), source tier requirements, correction patterns
- **Fallback**: Use generalist standards (constitution only) if persona config missing

---

### 4. Phase 1: Claim Extraction

**Goal**: Identify all verifiable claims in source document without judgment.

**Process**:
1. Read `source_file` content
2. Extract claims using patterns for 10 types:
   - **Statistical**: Numbers, percentages, metrics
   - **Market Sizing**: TAM/SAM/SOM, market share, revenue
   - **Technical Specs**: API limits, performance, compatibility
   - **Compliance**: GDPR, HIPAA, SOC 2, WCAG, ISO
   - **Competitive**: Features, pricing, market position
   - **Temporal**: Dates, timelines, releases
   - **Performance**: Speed, latency, throughput, scalability
   - **Cost/Pricing**: Infrastructure, licenses, cloud costs
   - **Security**: CVEs, encryption, authentication
   - **Research/Academic**: Studies, peer-reviewed, methodologies

3. For each claim, extract: Claim text (exact quote), context (surrounding 1-2 sentences), source line number, claim type, persona-critical flag (true if persona requires 100%)

4. Generate `$FEATURE_DIR/claims.yaml`:
```yaml
claims:
  - id: CLAIM-001
    type: market_sizing
    text: "The AI coding assistant market is valued at $1.5B in 2024"
    context: "According to recent industry reports, the market is growing rapidly."
    source_line: 42
    source_file: research.md
    persona_critical: false
    verification_status: pending
```

**Output**: `claims.yaml` with all extracted claims

---

### 5. Phase 2: Verification with Correction Suggestions

**Goal**: Verify each claim AND generate correction options for weak/unverified claims.

**Process** (for each claim):

**A. Generate Search Query**: Optimize for claim type, add specificity (dates, official sources)

**B. Execute WebSearch**:
```
WebSearch(query=<optimized_query>, num_results=10, recency_filter=<if_applicable>)
```

**C. Score Sources** (for each result):
- **Authority Score**: Match domain against constitution tiers (100/70/40/0)
- **Relevance Score**: Semantic similarity to claim (0-100)
- **Recency Score**: Date freshness for claim type (0-100)
- **Total Score**: Weighted average (40% authority, 40% relevance, 20% recency)

**D. Determine Quality Grade**:
- **A (90-100)**: Best source score ≥90, Tier 1
- **B (80-89)**: Best source score 80-89, Tier 2
- **C (70-79)**: Best source score 70-79, weak verification
- **D (0-69)**: Best source score <70, unverified

**E. Generate Correction Suggestions** (for Quality C-D):

If **Quality C** (weak):
```markdown
**Issue**: Source authority lower than ideal (Tier 2-3)

**Suggested Improvements**:
- **Option A**: Stronger phrasing with Tier 1 source (if found via search)
- **Option B**: Mark as estimate with context
- **Option C**: Try these searches: site:gartner.com <query>, site:forrester.com <query>
```

If **Quality D** (unverified):
```markdown
**Issue**: Could not find authoritative sources for this claim

**Suggested Corrections**:
- **Option A**: Alternative phrasing with qualitative claim
- **Option B**: Mark as [NEEDS VERIFICATION]
- **Option C**: Search suggestions: Broader query, Official sources, Recent only
- **Option D**: Remove claim (if non-critical)
```

**F. Persona-Critical Claims** (100% required):
If claim is persona-critical AND Quality C-D:
- Use 15 search results (vs. 10)
- Generate additional search queries
- Emphasize: "CRITICAL: <persona> requires 100% verification for <claim type>"
- Provide detailed steps to verify manually

**G. Update claims.yaml** with verification results

**Output**: Updated `claims.yaml` with verification status and correction suggestions

---

### 6. Phase 3: Citation Generation

**Goal**: Generate proper citations with quality indicators.

**Process** (for each Quality A-C claim):

**A. Generate Citation** using format from constitution (APA/IEEE/Chicago):
- **APA**: Gartner. (2024). Market Guide for AI-Powered Developer Tools. Retrieved October 13, 2024, from https://www.gartner.com/...
- **IEEE**: Gartner, "Market Guide for AI-Powered Developer Tools," 2024. [Online]. Available: https://www.gartner.com/... [Accessed: Oct. 13, 2024].

**B. Add Quality Marker**:
- Quality A-B: ✓ (checkmark)
- Quality C: ⚠ (warning)
- Quality D: [NEEDS VERIFICATION]

**C. Generate Archival Link** (if required): Use `scripts/bash/generate-web-archive-link.sh <url>`

**D. Save to citations.yaml**:
```yaml
citations:
  - id: CIT-001
    claim_id: CLAIM-001
    text: "Gartner. (2024). Market Guide..."
    quality: "A"
    quality_marker: "✓"
    url: "https://www.gartner.com/..."
    archive_url: "https://web.archive.org/..."
    accessed_date: "2024-10-13"
    authority_tier: "tier_1_authoritative"
    verification_score: 95
```

**Output**: `citations.yaml` with structured citation data

---

### 7. Phase 4: Report Generation with Corrective Guidance

**Goal**: Generate actionable report that helps user improve research quality.

**Process**: Generate `$FEATURE_DIR/fact-check-report.md` with:

**A. Executive Summary**:
```markdown
# Fact-Check Report: research.md
**Generated**: 2024-10-13 14:30:00
**Overall Quality Score**: B+ (82/100)
**Status**: ✅ READY TO PROCEED (with suggested improvements)

---

## Executive Summary

✅ **23 claims verified** with strong sources (Quality A-B)
⚠️ **5 claims have weak verification** (Quality C) - improvement suggestions below
❌ **2 claims unverified** (Quality D) - correction options provided

**Recommendation**: Review the 7 flagged claims below and apply suggested corrections. You can proceed with current version, but applying corrections will improve research quality.
```

**B. Claims Requiring Attention** (for each Quality C-D claim):
```markdown
### 🟡 CLAIM-003 (Quality: C - Weak Verification)
**Original Text** (Line 67):
> "The AI coding assistant market is growing at 42% CAGR through 2028"

**Issue**: Source found but authority is lower than ideal (Tier 2 - Tech blog vs. Tier 1 - Market research firm)

**Current Source**: TechCrunch article (Tier 2) - [Link](...)

**Suggested Improvements**:
**Option A - Better Source Found** (Recommended): [Full correction with Tier 1 source]
**Option B - Mark as Estimate**: [Modified phrasing with context]
**Option C - Search for Better Source**: [Specific search queries]

**Action**: Choose an option above or continue with current version (will show ⚠ marker in output)
```

**C. Verification Statistics**:
```markdown
| Quality Grade | Count | Percentage | Action Required |
|--------------|-------|------------|-----------------|
| A (Tier 1 sources) | 18 | 60% | ✅ None - excellent quality |
| B (Tier 2 sources) | 5 | 17% | ✅ None - good quality |
| C (Weak verification) | 5 | 17% | ⚠️ Review suggestions above |
| D (Unverified) | 2 | 6% | ⚠️ Apply corrections above |

**Overall Quality**: B+ (82/100)
```

**D. Next Steps** (3 clear options):
```markdown
### Immediate (Choose One):

**A. Accept All Corrections** (Recommended - 5 minutes):
cp $FEATURE_DIR/<source>-verified.md $FEATURE_DIR/<source>.md

**Then proceed based on your workflow**:
- Product Manager workflow: `/gbm.pm.prd` (if after research) or `/gbm.specify` (if after PRD)
- Architecture workflow: `/gbm.request` (if after architecture)
- General workflow: Continue with next command in your workflow

**B. Selective Corrections** (10-15 minutes):
1. Review the flagged claims above
2. Choose correction option for each
3. Manually edit <source>.md
4. Optionally re-run `/gbm.fact-check <source>.md` to verify fixes

**Then proceed with your workflow** (same as Option A)

**C. Continue As-Is** (Immediate):
Proceed with your next workflow command without applying corrections.
Quality warnings will appear in `/gbm.review` but will NOT block progression.

**Common Next Steps**:
- After PM research: `/gbm.pm.validate-problem` → `/gbm.pm.prd`
- After PRD: `/gbm.specify`
- After architecture: `/gbm.request`
```

**E. Quality Improvement Tips** (persona-specific from loaded persona partial)

**F. Constitution Compliance**:
```markdown
**Verification Threshold**: 80% (from constitution)
**Current Score**: 82%
**Status**: ✅ MEETS THRESHOLD

**Note**: You can proceed to next stage. Applying suggested corrections will improve quality to 95%+.
```

**Output**: `fact-check-report.md` with complete guidance

---

### 8. Generate Corrected Version

**Goal**: Create verified version with all corrections applied.

**Process**: Generate `$FEATURE_DIR/<source-file>-verified.md`:
1. Start with original content
2. For Quality A claims: Insert inline citations
3. For Quality B-C claims: Add ⚠ marker + citation
4. For Quality D claims: Add [NEEDS VERIFICATION] marker
5. Add References section at end with all citations

**Example**:
```markdown
# Market Research: AI Coding Assistants

## Market Size

According to Gartner's 2024 Market Guide, the AI development tools market is estimated at $1.2-1.8B, with 38% year-over-year growth [1]. ✓

⚠ [INDUSTRY ESTIMATE] Some analysts project growth rates of 40-45% CAGR through 2028 [2].

[NEEDS VERIFICATION] Approximately 85% of developers prefer AI assistants that integrate with their IDE.

---

## References

[1] Gartner. (2024). Market Guide for AI-Powered Developer Tools. (Tier 1, Quality: A, Score: 95)
[2] TechCrunch. (2024). AI Coding Assistants See Massive Growth. (Tier 2, Quality: C, Score: 72)
```

**Output**: `<source-file>-verified.md` with corrections applied

---

### 9. No Blocking, Only Guidance

**CRITICAL RULES**:
- ✅ **Always allow progression** - Users can proceed at any quality level
- 📊 **Quality tracking** - Scores visible in downstream commands (`/gbm.review`)
- ⚠️ **Recommendations only** - Suggest corrections but NEVER mandate
- 🎯 **Extra help for critical claims** - Persona-critical claims (CVEs, regulations, WCAG) get additional correction assistance but still don't block

**User Choice**: At every step, present 3 clear options:
- A) Accept all corrections (fastest)
- B) Selective corrections (flexible)
- C) Continue as-is (fastest, with warnings)

---

## Output Files Summary

1. **`claims.yaml`**: All extracted claims with verification results
2. **`citations.yaml`**: Structured citation data
3. **`fact-check-report.md`**: Complete yet concise report with correction suggestions
4. **`<source>-verified.md`**: Corrected version with citations

---

## Next Steps

After fact-checking completes, display:

```
✅ Fact-check complete!

Overall Quality: <GRADE> (<SCORE>/100)
Status: ✅ READY TO PROCEED

<N> claims could benefit from better sources. Review correction suggestions in fact-check-report.md.

Next steps (choose one):
A. Accept all corrections:
   cp $FEATURE_DIR/<source>-verified.md $FEATURE_DIR/<source>.md
   Then: /gbm.pm.prd (PM workflow) or /gbm.specify (general workflow) or /gbm.request (architecture workflow)

B. Review suggestions:
   cat $FEATURE_DIR/fact-check-report.md
   Then apply selective corrections and proceed with your workflow

C. Continue as-is:
   Proceed with next workflow command (/gbm.pm.prd, /gbm.specify, or /gbm.request)

Note: Research quality will be visible in /gbm.review but does NOT block PR creation.
```

### 10. Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-fact-check` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Correct factual errors identified in fact-check report
- Update documentation with accurate information
- Re-run `/gbm.specify` or `/gbm.plan` if fundamental assumptions were wrong
- Re-run `/gbm.fact-check` after corrections to verify accuracy

