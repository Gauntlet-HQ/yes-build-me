---
description: "Create complete Product Requirements Document based on validated discovery (PM Definition Phase)"
scripts:
  sh: scripts/bash/pm-prd.sh
  ps: scripts/powershell/pm-prd.ps1
artifacts:
  - path: "$FEATURE_DIR/prd.md"
    description: "Product Requirements Document with validated requirements"
---

## Output Style Requirements (MANDATORY)

**PRD Structure**:
- Executive summary: 5-7 bullets, scannable in 60 seconds
- Goals/Non-goals as parallel bullet lists
- Success metrics: table format (metric | target | measurement)
- Requirements: numbered, one requirement per item

**PRD Sections**:
- Problem: 2-3 paragraphs max with data citations
- Solution: bullet points + diagrams, not prose
- User stories: summary table linking to detailed stories
- Milestones: timeline table, not narrative

**Avoid in PRDs**:
- Multi-paragraph justifications (use bullets)
- Repeating discovery findings verbatim (summarize + link)
- Vague adjectives without quantification

# Product Manager: Product Requirements Document (PRD)

You are helping a Product Manager create a complete PRD based on validated discovery research.

## Persona Context

**Primary**: Product Manager persona (owns this command)
**Available to**: Product Manager only (PRD creation is PM responsibility)

## Prerequisites

**Required:**
- ✅ Completed `/gbm.pm.validate-problem` with GO decision
- ✅ All discovery artifacts available (discover, interview, research, validation)

**This command should ONLY be run after validation passes.** If validation shows NO-GO or NEED MORE DATA, return to discovery phase.

## Your Task

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.pm.prd" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

Run `{SCRIPT}` to create PRD workspace, then guide PM through PRD creation.

The script will:
1. Create `$FEATURE_DIR/prd.md` from template
2. Copy complete PRD template (`templates/pm-prd-template.md`)
3. Create PRD metadata file
4. Validate prerequisites (discovery artifacts)

## PRD Template Structure

The PRD template (`.gobuildme/templates/pm-prd-template.md`) provides complete structure:

### 13 Major Sections:
1. **Executive Summary** - Problem, solution, impact, success criteria, timeline
2. **Problem Context** - Problem description, evidence, current state, market timing
3. **Goals & Non-Goals** - Primary goal, success metrics, what we're NOT building
4. **Users & Personas** - Primary/secondary personas with pain points and needs
5. **User Stories & Acceptance Criteria** - Epic-level stories with prioritization
6. **Functional Requirements** - Detailed requirements with NASA checklist
7. **Non-Functional Requirements** - Performance, security, scalability, usability
8. **Technical Approach** - Architecture, components, tech stack, risks
9. **Design & UX** - Design principles, user flows, UI/UX requirements
10. **Go-to-Market Strategy** - Launch phases, success criteria, marketing
11. **Dependencies** - Internal/external dependencies
12. **Risks** - Risk register with heat map
13. **Appendix** - Discovery artifacts, references, glossary, changelog

### Evidence Integration

The template includes placeholders for evidence from all discovery phases:
- **From `/gbm.pm.discover`**: Problem statement, hypothesis, opportunity score
- **From `/gbm.pm.interview`**: User quotes, pain severity, feature priorities
- **From `/gbm.pm.research`**: Market sizing, competitive analysis, analytics, technical feasibility
- **From `/gbm.pm.validate-problem`**: Validation scores, GO/NO-GO decision

### Quality Standards

**Requirements follow NASA checklist:**
- ✅ **N**ecessary - Must have this (user evidence)
- ✅ **A**mbiguous - No ambiguity (clear description)
- ✅ **S**pecific - Clear and concise
- ✅ **A**ttainable - Technically feasible

Actually: **N**ecessary, **C**oncise, **F**easible, **T**estable, **U**nambiguous, **C**omplete

## Workflow Guide

### 1. Load Discovery Evidence

Before filling PRD, load all discovery artifacts:

```bash
# Check what evidence is available
ls $FEATURE_DIR/

# Review validation decision
cat $FEATURE_DIR/validation-report.md

# Review interview synthesis
cat $FEATURE_DIR/interviews/synthesis.md

# Review market research
cat $FEATURE_DIR/research/market-research.md
cat $FEATURE_DIR/research/competitive-analysis.md
cat $FEATURE_DIR/research/analytics-report.md
cat $FEATURE_DIR/research/technical-feasibility.md
```

### 2. Complete PRD Sections Sequentially

Work through PRD sections in order, using evidence:

**Executive Summary**
- Copy problem statement from discovery
- Reference validation decision
- Include business impact from analytics report
- Set success metrics from hypothesis

**Problem Context**
- Summarize evidence from all sources
- Include most powerful user quotes
- Show quantitative validation (pain scores, analytics)
- Explain market timing from research

**Goals & Success Metrics**
- Define measurable targets with baselines
- Reference hypothesis from `/gbm.pm.discover`
- Set realistic timelines based on technical feasibility

**Users & Personas**
- Copy primary/secondary personas from interview synthesis
- Include pain severity scores
- Reference actual user quotes
- Prioritize based on market sizing

**Requirements**
- For each requirement, apply NASA checklist
- Include Given-When-Then acceptance criteria
- Map to user needs from interviews
- Verify feasibility with technical research
- Prioritize (P0/P1/P2) based on interview data

### 3. Quality Checks

Before finalizing PRD:

- [ ] All sections complete (no placeholders left)
- [ ] Evidence cited from discovery artifacts (not assumptions)
- [ ] Requirements follow NASA checklist
- [ ] Success metrics have baselines and targets
- [ ] All P0 requirements have clear acceptance criteria
- [ ] Technical approach validated with engineering
- [ ] Risks identified with mitigations
- [ ] Open questions have owners and deadlines
- [ ] Stakeholder review planned

### 4. Present PRD Summary

After completing PRD, provide this summary:

```markdown
## PRD Summary

**Feature:** [Feature name]
**Status:** Ready for Review
**Version:** 1.0

**Requirements:**
- P0 (Must-Have): [N] requirements
- P1 (Should-Have): [N] requirements
- Total: [N] requirements

**Effort Estimate:**
- Engineering: [N] person-weeks
- Design: [N] person-weeks
- Timeline: [X] weeks to launch

**Success Metrics:**
- [Metric 1]: [Baseline] → [Target]
- [Metric 2]: [Baseline] → [Target]

**Validation Evidence:**
- Interviews: [N] participants, [X.X/10] pain severity
- Market: TAM $[X]B, SAM $[Y]M, SOM $[Z]K
- Analytics: [N] users affected, $[Z]/month impact
- Validation Score: [X.X/10] - GO decision

**Next Steps:**
1. Stakeholder review ([List reviewers])
2. Run `/gbm.pm.stories` to create detailed user stories
3. Engineering kickoff meeting
```

## Next Steps

**After PRD is Complete:**
For complete style guidance, see .gobuildme/templates/_concise-style.md


1. **Stakeholder Review**
   - Get sign-off from Engineering, Design, Sales, CS
   - Address open questions
   - Finalize priorities

2. **Run `/gbm.pm.stories`**
   - Break epics into detailed user stories
   - Add granular acceptance criteria
   - Create engineering-ready stories

3. **Run `/gbm.pm.align`**
   - Ensure all stakeholders aligned on requirements
   - Validate resource commitments
   - Confirm timeline feasibility

4. **Engineering Kickoff**
   - Present PRD to engineering team
   - Review technical approach
   - Establish implementation plan

5. **Track Progress**
   - PRD is source of truth throughout development
   - Update PRD as requirements evolve
   - Maintain version history in changelog

## Tips for PM

**Good PRD:**
- ✅ Evidence-based (cites discovery artifacts)
- ✅ Clear success metrics (measurable with baselines)
- ✅ Prioritized (P0/P1/P2 with rationale)
- ✅ Testable requirements (clear acceptance criteria)
- ✅ Risk-aware (identifies and mitigates risks)
- ✅ User-focused (solves validated user problems)
- ✅ Feasible (validated technical approach)

**Bad PRD:**
- ❌ Opinion-based ("I think users want...")
- ❌ Vague success criteria ("improve user experience")
- ❌ Everything is P0 (no real prioritization)
- ❌ Untestable requirements ("system should be fast")
- ❌ Ignores risks
- ❌ Solution in search of a problem
- ❌ No evidence from discovery

## Files Created

- `$FEATURE_DIR/prd.md` - Complete Product Requirements Document (from `templates/pm-prd-template.md`)
- `$FEATURE_DIR/prd-metadata.json` - PRD metadata and workflow info

## Integration with PM Workflow

**Workflow Position:**
```
/gbm.pm.discover → /gbm.pm.interview → /gbm.pm.research → /gbm.pm.validate-problem → /gbm.pm.prd ← YOU ARE HERE
                                                                           ↓
                                                                      /gbm.pm.stories
```

**PRD Uses:**
- Validated problem from `/gbm.pm.discover`
- User needs from `/gbm.pm.interview`
- Market context from `/gbm.pm.research`
- Evidence quality from `/gbm.pm.validate-problem`

**PRD Feeds Into:**
- User stories (`/gbm.pm.stories` - detailed breakdown)
- Engineering estimates (technical planning)
- Design (UI/UX requirements)
- QA (acceptance criteria)
- Stakeholder alignment (`/gbm.pm.align`)

### Step 3: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-pm-prd` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit `$FEATURE_DIR/prd.md` to refine requirements
- Run `/gbm.pm.research` to add missing context or insights
- Run `/gbm.pm.validate-problem` to verify problem space
- Re-run `/gbm.pm.prd` with additional research findings

