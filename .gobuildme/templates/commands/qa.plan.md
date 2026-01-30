---
description: "Analyze scaffolded tests and create a complete test implementation plan with priorities and quality standards"
artifacts:
  - path: ".gobuildme/specs/qa-test-scaffolding/qa-test-plan.md"
    description: "Complete test implementation plan with test requirements, priorities, and quality standards"
scripts:
  sh: scripts/bash/qa-plan.sh
  ps: scripts/powershell/qa-plan.ps1
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

You are the QA Test Planning Command. Your job is to analyze scaffolded tests and create a complete test implementation plan.

**⚠️ CRITICAL - COVERAGE TARGETS ARE MANDATORY**

The test plan MUST include enough tasks to achieve these coverage targets:
- **Unit Tests**: 90% coverage
- **Integration Tests**: 95% coverage
- **E2E Tests**: 80% coverage
- **Overall**: 85% combined coverage

**Planning Requirements**:
1. Calculate current coverage baseline BEFORE planning
2. Estimate how many new tests are needed to reach each target
3. Generate sufficient tasks to close ALL coverage gaps
4. Plan must include coverage gap analysis (not just existing placeholders)
5. `/gbm.qa.review-tests` will BLOCK if targets are not met

## Workflow

### Step 0: Orientation (MANDATORY — DO THIS FIRST)

Before creating a test plan, establish context from previous sessions:

```bash
# 1. Resolve repo root (works from any subdirectory)
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
  dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.gobuildme/manifest.json" ]; then
      REPO_ROOT="$dir"
      break
    fi
    dir=$(dirname "$dir")
  done
fi
[ -z "$REPO_ROOT" ] && REPO_ROOT="$PWD"
cd "$REPO_ROOT"

# 2. Verify QA workspace exists
ls -la "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/" 2>/dev/null || echo "No QA scaffolding yet"

# 3. Read progress notes (CRITICAL for session continuity)
cat "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/verification/gbm-progress.txt" 2>/dev/null || echo "No progress file yet"

# 4. Review git history for QA workflow changes
if git rev-parse --git-dir >/dev/null 2>&1; then
    git log --oneline -10 -- ".gobuildme/specs/qa-test-scaffolding/" 2>/dev/null || git log --oneline -5
else
    echo "Not a git repository - skipping git history"
fi

# 5. Check if scaffold report exists (prerequisite)
if [ -f "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/scaffold-report.md" ]; then
    echo "=== Scaffold Report Summary ==="
    head -50 "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/scaffold-report.md"
else
    echo "⚠️ No scaffold report found - run /gbm.qa.scaffold-tests first"
fi

# 6. Load architecture context
if [ -f "$REPO_ROOT/.gobuildme/docs/technical/architecture/technology-stack.md" ]; then
    echo "=== Technology Stack ==="
    head -30 "$REPO_ROOT/.gobuildme/docs/technical/architecture/technology-stack.md"
fi
```

**DO NOT proceed until you understand**:
- What QA work was done in previous sessions
- Whether the scaffold report exists and is current
- Any issues or blockers documented in progress notes
- The technology stack and testing context

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.qa.plan" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

**IMPORTANT**: Run `{SCRIPT}` from the repository root. The script will:
- Automatically check and generate architecture documentation if needed
- Load scaffold report from qa-test-scaffolding directory
- Scan all test files for TODO/unimplemented tests
- Count and categorize tests by type (unit, integration, e2e)
- Analyze test priorities (high/medium/low)
- Load architecture context for better planning
- Generate complete test implementation plan using qa-test-plan-template.md

The script handles the entire planning process. Do NOT attempt to manually implement
the planning logic yourself.

### What the Script Does

The script (`{SCRIPT}`) performs these steps automatically:

**1) Architecture Integration**
   - Checks if `.gobuildme/docs/technical/architecture/technology-stack.md` exists
   - If missing: Automatically runs `/gbm.architecture` to generate it
   - If old (>7 days): Prompts user to refresh
   - Loads architecture context for complete test planning

**2) Load Scaffold Report**
   - Reads `.gobuildme/specs/qa-test-scaffolding/scaffold-report.md`
   - If not found: ERROR "Run /gbm.qa.scaffold-tests first"
   - Extracts list of all scaffolded test files

**3) COMPREHENSIVE Coverage Analysis (NOT just TODO markers)**

   **CRITICAL**: Do NOT limit planning to existing TODO markers or `markTestSkipped` tests.
   The test plan must identify ALL testing needs for the codebase.

   **Phase 3a: Scan Existing Test Files**
   - Parses each test file to find TODO/unimplemented tests
   - Detects test framework patterns (PHPUnit, pytest, Jest, etc.)
   - Counts total tests vs implemented tests
   - Extracts test names and locations

   **Phase 3b: Identify Coverage Gaps (MANDATORY)**
   - Analyze production code NOT covered by existing tests:
     * List all source files in src/, app/, lib/, etc.
     * Cross-reference with test files to find untested modules
     * Identify classes/functions with NO corresponding tests
   - Focus on critical business logic:
     * Authentication/authorization code
     * Payment processing
     * Data validation
     * Core domain logic
     * API endpoints without test coverage
   - Document coverage gap findings in plan for `/gbm.qa.tasks`

**4) Categorize Tests by Type**
   - **Unit tests**: Individual functions, methods, classes in isolation
   - **Integration - API**: REST/GraphQL endpoint tests
   - **Integration - Database**: CRUD operation tests
   - **Integration - Queue**: Message queue tests
   - **Integration - External**: Third-party service integration tests
   - **Integration - Cache**: Cache operation tests
   - **E2E - User Flows**: Complete user workflows
   - **E2E - Critical Paths**: Critical business processes
   - **E2E - Smoke Tests**: Basic functionality checks

**5) Analyze Test Priorities**
   - **High priority**: Authentication, authorization, security, critical paths, payment processing
   - **Medium priority**: CRUD operations, validation, business logic, API endpoints
   - **Low priority**: Edge cases, static content, rarely used features

**6) Load Architecture Context**
   - Reads technology stack (frameworks, databases, external services)
   - Identifies integration points
   - Determines mocking requirements
   - Understands system architecture patterns

**7) Define Test Implementation Strategy**
   - **Phase 0**: Analysis & Setup
   - **Phase 1**: Fixture & Mock Generation (recommend `/gbm.qa.generate-fixtures`)
   - **Phase 2**: Priority-Based Test Implementation (high → medium → low)
   - **Phase 3**: Validation & Quality (run tests, measure coverage, verify gates)

**8) Generate Test Requirements**
   - Define Test Requirements (TR-001, TR-002, etc.) based on scaffolded tests
   - Each requirement includes:
     - **Scope**: What tests are included (e.g., Authentication, API endpoints)
     - **Priority**: High, Medium, or Low
     - **Coverage Target**: Percentage (e.g., 100% for auth, 95% for APIs)
     - **Quality Standards**: Specific criteria (AAA pattern, mocking, assertions, performance)
     - **Success Criteria**: Checklist of completion criteria
   - Map scaffolded test files to requirements
   - Extract quality standards from architecture context

**9) Generate Test Implementation Plan**
   - Copies `templates/qa-test-plan-template.md` to `.gobuildme/specs/qa-test-scaffolding/qa-test-plan.md`
   - Fills template with actual data:
     - **Test Requirements section** (TR-001 through TR-NNN with quality standards)
     - Total tests, TODO counts, implemented counts
     - Test type breakdown table
     - Test files analysis table
     - Priority assignments
     - Technical context (frameworks, databases, mocking strategy)
     - Implementation strategy
     - Quality standards and gates
   - Initializes progress tracking (all phases pending)

**9) Output Plan Location**
   - Plan saved to: `.gobuildme/specs/qa-test-scaffolding/qa-test-plan.md`
   - Ready for next step: `/gbm.qa.tasks`

## Prerequisites

**Required**:
- [ ] Scaffolded tests exist (run `/gbm.qa.scaffold-tests` first)
- [ ] Scaffold report exists at `.gobuildme/specs/qa-test-scaffolding/scaffold-report.md`

**Recommended**:
- [ ] Architecture documentation exists (auto-generated if missing)
- [ ] Understand testing framework used in project

## Output Format

**CRITICAL - Conciseness Rule**:
Present ONLY the formatted output shown below. Do NOT add:
- Introductory phrases like "Perfect! Let me..." or "Now I'll..."
- Explanations of workflow options or comparisons between commands
- Code examples or elaborate tutorials beyond the template
- Additional sections, elaborations, or multi-paragraph explanations
- Justifications for why certain approaches are better

Output the summary exactly as specified below, then STOP.

---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide


After running the script, present the plan summary to the user:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ QA Test Implementation Plan Created
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Test Coverage
   • Total scaffolded: [N] tests
   • TODO to implement: [N] tests
   • Already implemented: [N] tests

📈 By Priority
   • High: [N] tests (auth, security, critical paths)
   • Medium: [N] tests (CRUD, validation, business logic)
   • Low: [N] tests (edge cases, non-critical)

🔧 Fixture Generation Assessment

[If project has external services OR complex data models:]
   Based on architecture analysis:
   • External services to mock: [N] ([list top 3-5 services])
   • Entities needing factories: [N] ([list top 3-5 entities])
   • Recommendation: ✅ GENERATE FIXTURES

   Workflow:
   1. Review plan: .gobuildme/specs/qa-test-scaffolding/qa-test-plan.md
   2. Generate fixtures: /gbm.qa.generate-fixtures (saves 30-40% implementation time)
   3. Generate tasks: /gbm.qa.tasks
   4. Implement tests: /gbm.qa.implement (using generated fixtures)

[If project has NO external services AND simple data model:]
   Based on architecture analysis:
   • External services: None or minimal
   • Data model: Simple (manual test data is sufficient)
   • Recommendation: ⏭️  SKIP FIXTURES

   Workflow:
   1. Review plan: .gobuildme/specs/qa-test-scaffolding/qa-test-plan.md
   2. Generate tasks: /gbm.qa.tasks
   3. Implement tests: /gbm.qa.implement (create test data inline)

📁 Plan Location
   .gobuildme/specs/qa-test-scaffolding/qa-test-plan.md

🎯 Next Command
   [If fixtures recommended:] /gbm.qa.generate-fixtures
   [If fixtures skipped:] /gbm.qa.tasks

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Error Handling

**If scaffold report not found**:
```
❌ Error: Scaffold report not found

Expected location: .gobuildme/specs/qa-test-scaffolding/scaffold-report.md

Action required: Run /gbm.qa.scaffold-tests first to generate test scaffolding
```

**If no TODO tests found**:
```
⚠️  Warning: No TODO tests found

All scaffolded tests appear to be implemented.

Verification:
- Scanned [N] test files
- Found [N] total tests
- All tests have implementations

Next step: Run /gbm.qa.review-tests to verify test quality
```

**If architecture generation needed**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 Architecture documentation not found.
   Generating architecture for better test planning...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Architecture generation runs automatically...]

✓ Architecture documentation generated

🏗️ Creating test implementation plan with architecture context...
```

## Quality Gates

Before creating the plan, verify:
- [ ] Scaffold report exists
- [ ] At least one test file exists
- [ ] Test files are parseable
- [ ] Architecture context available (or auto-generated)

After creating the plan, verify:
- [ ] Plan file created successfully
- [ ] All sections filled with actual data
- [ ] Test counts are accurate
- [ ] Priorities assigned correctly
- [ ] Progress tracking initialized

## Integration with Workflow

**Position in Workflow**:
```
/gbm.qa.scaffold-tests → /gbm.qa.plan → /gbm.qa.tasks → /gbm.qa.implement → /gbm.qa.review-tests
                              ↑
                         (You are here)
```

**Inputs**:
- `.gobuildme/specs/qa-test-scaffolding/scaffold-report.md` (from `/gbm.qa.scaffold-tests`)
- Test files with TODO markers
- Architecture documentation (auto-generated if needed)

**Outputs**:
- `.gobuildme/specs/qa-test-scaffolding/qa-test-plan.md` (for `/gbm.qa.tasks`)

**Next Command**:
- `/gbm.qa.tasks` - Generate task checklist from this plan

## Notes

- **Plan is strategic**: Focuses on overall approach, priorities, and phases
- **Tasks are tactical**: Next command (`/gbm.qa.tasks`) breaks plan into specific checkboxes
- **Resumable**: Plan can be reviewed and adjusted before generating tasks
- **Context-rich**: Uses architecture docs to understand system for better planning

### Step 3: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-qa-plan` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit `$FEATURE_DIR/qa-plan.md` to adjust test strategy
- Run `/gbm.clarify` to resolve specification ambiguities
- Re-run `/gbm.qa.plan` with refined testing approach

