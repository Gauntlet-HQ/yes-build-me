---
description: "Break down PRD into detailed user stories with acceptance criteria, ready for Jira/Linear/etc. (PM Definition Phase)"
scripts:
  sh: scripts/bash/pm-stories.sh
  ps: scripts/powershell/pm-stories.ps1
artifacts:
  - path: "$FEATURE_DIR/stories/"
    description: "Detailed user stories broken down from PRD epics"
  - path: "$FEATURE_DIR/stories/jira-import.csv"
    description: "CSV file ready for Jira bulk import"
---

## Output Style Requirements (MANDATORY)

**User Story Format**:
- Title: action-oriented, 8 words max
- Description: As a [role], I want [action], so that [benefit] - one line
- Acceptance criteria: 3-7 checkboxes per story, testable actions
- No background sections or context paragraphs in stories

**Story Files**:
- One story per file when detailed, grouped file when small
- Tables for dependencies, estimates, labels
- No redundant info from PRD - reference via link

**Jira Import CSV**:
- Minimal fields: Summary, Description, AC, Story Points, Labels
- Description field: single paragraph with AC as checklist

For complete style guidance, see .gobuildme/templates/_concise-style.md

# Product Manager: User Stories & Jira Tickets

You are helping a Product Manager break down PRD epics into detailed, implementable user stories.

## Persona Context

**Primary**: Product Manager persona (owns this command)
**Available to**: Product Manager only (story creation is PM responsibility)

## Prerequisites

**Required:**
- ✅ Completed `/gbm.pm.prd` with finalized PRD
- ✅ PRD stakeholder review complete

**This command converts PRD epics into actionable user stories ready for engineering.**

## Your Task

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.pm.stories" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

Run `{SCRIPT}` to create stories workspace, then guide PM through story creation.

The script will:
1. Create `$FEATURE_DIR/stories/` directory
2. Parse PRD epics and generate story templates
3. Create Jira import CSV file
4. Generate story breakdown checklist

## Story Creation Process

### Step 3: Epic Breakdown

For each epic from PRD, break down into implementable stories.

**Epic Breakdown Checklist:**

Use template from `.gobuildme/templates/reference/pm-stories-templates.md#epic-breakdown-template`

| Story Element | Requirements |
|--------------|-------------|
| User Story | As a [persona], I want [action], So that [benefit] |
| Acceptance Criteria | Given/When/Then format, 3-7 testable criteria |
| Metadata | Story points (Fibonacci), dependencies, technical notes |
| Definition of Done | Code reviewed, tests passing, AC validated, QA ready |

### Step 2: Story Sizing Guidelines

See `.gobuildme/templates/reference/pm-stories-templates.md#story-point-scale` for detailed scale.

| Points | Duration | Description |
|--------|----------|-------------|
| 1 (XS) | 1-4 hours | No dependencies |
| 2 (S) | 4-8 hours | Clear requirements |
| 3 (M) | 1-2 days | May need design review |
| 5 (L) | 2-3 days | Requires coordination |
| 8 (XL) | 3-5 days | Complex logic |
| 13 (XXL) | 1+ week | **BREAK IT DOWN** |

**Tip:** Include coding, testing, review, docs. Add 1.2-1.5x buffer.

### Step 3: Jira Ticket Structure

See `.gobuildme/templates/reference/pm-stories-templates.md#jira-csv-import-format` for CSV template.

**Jira Hierarchy:** Epic → Story → Sub-task

| Field | Notes |
|-------|-------|
| Summary | Under 80 chars |
| Description | As a/I want/So that + AC |
| Priority | P0→Highest, P1→High, P2→Medium |
| Story Points | Fibonacci (1,2,3,5,8,13) |

**Import:** Jira → Issues → Import CSV → Map columns → Verify hierarchy

### Step 4: Story Quality Checklist

See `.gobuildme/templates/reference/pm-stories-templates.md#invest-quality-criteria` for details.

**INVEST Criteria:**
- [ ] **I**ndependent - Can develop in any order
- [ ] **N**egotiable - Focuses on "what" not "how"
- [ ] **V**aluable - Delivers user/business value, traces to PRD
- [ ] **E**stimable - Team can size it
- [ ] **S**mall - Completable in 1 sprint (2-5 points)
- [ ] **T**estable - Clear AC, can verify "done"

**Additional Checks:**
- [ ] AC uses Given/When/Then + success/error/edge cases
- [ ] Traces to PRD requirement and user need

### Step 5: Sprint Planning

**Capacity:** `(Engineers × Days × Hours) × 0.7` (meetings, review, support)

**Sprint Structure:** Goal → Stories with points → Total → Dependencies

### Step 6: Engineering Handoff

See `.gobuildme/templates/reference/pm-stories-templates.md#definition-of-ready--done` for checklists.

**Refinement Session (100 min):**
1. PRD context (10) → Walk through stories (30) → Estimates (30) → Allocate (20) → Q&A (10)

**Per Story:** Team understands "why" | AC clear | Technical approach | Dependencies | Points agreed

**Definition of Ready:** Story clear, AC defined, sized, no blockers
**Definition of Done:** Merged, tested (≥80%), reviewed, QA validated, deployed

## Story Templates by Type

See `.gobuildme/templates/reference/pm-stories-templates.md#story-templates-by-type` for detailed templates.

| Type | Key AC | Typical Points |
|------|--------|----------------|
| **Backend API** | 400/401/403/500 responses, <500ms p95, OpenAPI docs | 3-5 |
| **Frontend UI** | Matches mockup, responsive, WCAG 2.1 AA, states handled | 2-5 |
| **Integration** | Auth working, data mapping, retry logic, monitoring | 5-8 |
| **Database** | Reversible, no data loss, indexes, tested on staging | 2-5 |
| **Tech Debt** | No functional changes, tests pass, metrics improved | 3-8 |

## Quality Checks

Before finalizing stories:

- [ ] All PRD epics broken down into stories
- [ ] Each story follows INVEST criteria
- [ ] Acceptance criteria are testable (Given/When/Then)
- [ ] Story points assigned to all stories
- [ ] Dependencies identified and documented
- [ ] Design assets linked (for UI stories)
- [ ] Technical notes included (for complex stories)
- [ ] Jira import CSV generated
- [ ] Total effort aligns with PRD timeline estimate
- [ ] Stories reviewed with engineering team

## Output Summary

After completing story breakdown, present summary:

```markdown
## Story Breakdown Summary

**Feature:** [Feature name]
**PRD Version:** [Version from PRD]
**Stories Created:** [N total stories]

**Epic Breakdown:**

| Epic | Priority | Stories | Story Points | Est. Duration |
|------|----------|---------|--------------|---------------|
| Epic 1 | P0 | [N] | [X] | [Y weeks] |
| Epic 2 | P1 | [N] | [X] | [Y weeks] |
| Epic 3 | P2 | [N] | [X] | [Y weeks] |

**Total Effort:**
- Total Story Points: [X]
- Estimated Duration: [Y weeks with Z-person team]
- Sprints Required: [N sprints]

**Jira Import Ready:**
- File: `$FEATURE_DIR/stories/jira-import.csv`
- Epics: [N]
- Stories: [M]
- Import instructions in README.md

**Next Steps:**
1. Import stories to Jira
2. Story refinement session with engineering
3. Sprint planning (allocate stories to sprints)
4. Run `/gbm.pm.align` for stakeholder alignment
```

## Next Steps

**After Stories are Complete:**
1. **Import to Jira:** Use `jira-import.csv` for bulk import
2. **Story Refinement:** Walk through stories with engineering team
3. **Sprint Planning:** Allocate stories to sprints based on priority and capacity
4. **Run `/gbm.pm.align`:** Ensure all stakeholders aligned before development starts
5. **Kickoff:** Begin development

## Tips for PM

**Good User Stories:**
- ✅ Small (completable in 1 sprint)
- ✅ Independent (minimal dependencies)
- ✅ Testable (clear acceptance criteria)
- ✅ Valuable (delivers user/business value)
- ✅ Estimated (team can size it)
- ✅ Traces to PRD (clear lineage)

**Bad User Stories:**
- ❌ Too large (>8 story points)
- ❌ Dependent on many other stories
- ❌ Vague acceptance criteria ("works well")
- ❌ Technical tasks masquerading as user stories
- ❌ No clear user value
- ❌ Engineering can't estimate it

**Common Mistakes:**
- Writing stories from technical perspective ("Refactor API" → should be "As a user, I want faster response times")
- Making stories too large (break down 13-point stories)
- Forgetting edge cases in acceptance criteria
- Not including design assets for UI stories
- Skipping story refinement with engineering

## Files Created

- `$FEATURE_DIR/stories/` - Directory with all story markdown files
- `$FEATURE_DIR/stories/epic-[N]-stories.md` - Stories for each epic
- `$FEATURE_DIR/stories/jira-import.csv` - CSV for Jira bulk import
- `$FEATURE_DIR/stories/README.md` - Import instructions and summary

## Integration with PM Workflow

**Workflow Position:**
```
/gbm.pm.discover → /gbm.pm.interview → /gbm.pm.research → /gbm.pm.validate-problem → /gbm.pm.prd → /gbm.pm.stories ← YOU ARE HERE
                                                                                      ↓
                                                                                 /gbm.pm.align
```

**Stories Use:**
- PRD epics (high-level capabilities)
- PRD requirements (detailed functionality)
- User needs from interviews (persona context)

**Stories Feed Into:**
- Sprint planning (engineering allocation)
- Design (UI/UX implementation)
- QA (test case creation)
- Stakeholder alignment (what's being built)

### Step 4: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-pm-stories` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit user stories to refine acceptance criteria
- Run `/gbm.pm.prd` to update product requirements first
- Run `/gbm.clarify` if user stories need more context
- Re-run `/gbm.pm.stories` with updated PRD

