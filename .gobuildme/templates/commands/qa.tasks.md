---
description: "Generate a detailed task checklist from the test implementation plan with priorities and parallel execution markers"
artifacts:
  - path: ".gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md"
    description: "Detailed task checklist with priority-based ordering and progress tracking"
scripts:
  sh: scripts/bash/qa-tasks.sh
  ps: scripts/powershell/qa-tasks.ps1
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

You are the QA Test Tasks Command. Your job is to generate a detailed task checklist from the test implementation plan.

## Workflow

### Step 0: Orientation (MANDATORY — DO THIS FIRST)

Before generating tasks, establish context from previous sessions:

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

# 5. Check if plan exists (prerequisite)
if [ -f "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/qa-test-plan.md" ]; then
    echo "=== Test Plan Summary ==="
    head -50 "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/qa-test-plan.md"
else
    echo "⚠️ No test plan found - run /gbm.qa.plan first"
fi
```

**DO NOT proceed until you understand**:
- What QA work was done in previous sessions
- Whether the test plan exists and is current
- Any issues or blockers documented in progress notes

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.qa.tasks" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

**IMPORTANT**: Run `{SCRIPT}` from the repository root. The script will:
- Automatically check and generate architecture documentation if needed
- Load test implementation plan from qa-test-scaffolding directory
- Scan all test files for TODO/unimplemented tests
- Extract test names and locations
- Match tests with priorities from the plan
- Create task for each test with checkbox format
- Order tasks by priority (high → medium → low)
- Group tasks by test file for efficiency
- Mark parallel-executable tasks with [P]
- Generate task checklist using qa-test-tasks-template.md

The script handles the entire task generation process. Do NOT attempt to manually
implement the task generation logic yourself.

### What the Script Does

The script (`{SCRIPT}`) performs these steps automatically:

**1) Architecture Integration**
   - Checks if `.gobuildme/docs/technical/architecture/technology-stack.md` exists
   - If missing: Automatically runs `/gbm.architecture` to generate it
   - If old (>7 days): Prompts user to refresh
   - Loads architecture context for task generation

**2) Load Test Implementation Plan**
   - Reads `.gobuildme/specs/qa-test-scaffolding/qa-test-plan.md`
   - If not found: ERROR "Run /gbm.qa.plan first"
   - Extracts total tests, priorities, categories

**3) COMPREHENSIVE Coverage Analysis (NOT just TODO markers)**

   **CRITICAL**: Do NOT limit task generation to existing TODO markers or `markTestSkipped` tests.
   This command must analyze the ENTIRE codebase for testing needs.

   **Phase 3a: Scan Existing Test Files**
   - Parses test file structure (PHPUnit, pytest, Jest, etc.)
   - Finds TODO/unimplemented test markers (`markTestSkipped`, `@todo`, `TODO`, `skip`, etc.)
   - Extracts test names and line numbers
   - Maps test file paths relative to repository root

   **Phase 3b: Identify Coverage Gaps (MANDATORY - this is the key step)**
   - Analyze production code files NOT covered by existing tests:
     * List all source files in src/, app/, lib/, etc.
     * Cross-reference with test files to find untested modules
     * Identify classes/functions with NO corresponding tests
   - Focus on critical business logic:
     * Authentication/authorization code
     * Payment processing
     * Data validation
     * Core domain logic
     * API endpoints without test coverage
   - Generate NEW test tasks for untested code (not just filling existing placeholders)

   **Output**: Combined list of:
   1. Existing TODO/placeholder tests to implement
   2. NEW tests to create for untested code (coverage gaps)

**4) Match Tests with Priorities and Requirements**
   - Loads priority assignments from plan
   - Maps tests to Test Requirements (TR-001, TR-002, etc.) from plan
   - Categorizes each test as high/medium/low priority
   - Extracts quality standards for each requirement
   - Identifies test type (unit, integration API, integration DB, e2e, etc.)

**5) Generate Verification Checklists**
   - For each task, extract quality standards from corresponding TR-XXX
   - Create "Must verify before marking [x]" checklist with criteria:
     - AAA pattern compliance
     - Mocking requirements
     - Assertion requirements
     - Performance requirements (test execution time)
     - Cleanup requirements
     - Test passes requirement
   - Include TR-XXX reference for full details in plan.md

**6) Generate Tasks by Priority and Category**
   - **High-priority tests first**: Auth, security, critical paths
   - **Medium-priority tests second**: CRUD, validation, business logic
   - **Low-priority tests last**: Edge cases, non-critical
   - Groups tests by test file for efficiency

**6) Apply Task Rules**
   - **Different test files**: Mark with `[P]` for parallel execution
   - **Same test file**: Sequential (no `[P]`)
   - **Fixtures before tests**: If fixtures not generated, add fixture phase
   - **Hierarchical numbering**: 1, 1-1, 1-2, 2, 2-1, etc.

**7) Create Task Hierarchy**
   - **Level 1**: Test file or category (e.g., "5 Implement LoginApiTest tests")
   - **Level 2**: Individual tests (e.g., "5-1 test_magic_link_authentication_succeeds")
   - **Level 3**: Test setup steps if complex (e.g., "5-1-1 Set up authentication fixtures")

**8) Generate Progress Tracking Section**
   - Calculate total tasks
   - Break down by phase (fixtures, high priority, medium, low, validation)
   - Break down by priority
   - Initialize completion status: `[ ] 0/{TOTAL} complete (0%)`

**9) Create Task Checklist File**
   - Copies `templates/qa-test-tasks-template.md` to `.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md`
   - Fills template with actual tasks:
     - Phase 1: Fixture generation (optional)
     - Phase 2: High-priority tests (with checkboxes)
     - Phase 3: Medium-priority tests (with checkboxes)
     - Phase 4: Low-priority tests (with checkboxes)
     - Phase 5: Validation & quality check
   - All tasks start unchecked `[ ]`
   - Includes file paths and line numbers for each test

**10) Output Tasks Location**
   - Tasks saved to: `.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md`
   - Ready for next step: `/gbm.qa.implement`

## Prerequisites

**Required**:
- [ ] Test implementation plan exists (run `/gbm.qa.plan` first)
- [ ] Plan file exists at `.gobuildme/specs/qa-test-scaffolding/qa-test-plan.md`
- [ ] Test files with TODO markers exist

**Recommended**:
- [ ] Architecture documentation exists (auto-generated if missing)
- [ ] Review plan before generating tasks

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


After running the script, present the tasks summary to the user:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ QA Test Task Checklist Created
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Task Summary
   • Total: [N] tasks
   • High priority: [N] tasks
   • Medium priority: [N] tasks
   • Low priority: [N] tasks

📁 Tasks Location
   .gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md

ℹ️  Task Format
   [ ] = pending | [x] = complete | [P] = can run in parallel

🎯 Next Command
   [If plan recommended fixtures AND fixtures not yet generated:]
   /gbm.qa.generate-fixtures (recommended - creates reusable test data)

   [Otherwise:]
   /gbm.qa.implement (start implementing tests task-by-task)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Example Task Structure

```markdown
## Phase 2: Implement High-Priority Tests

### tests/integration/api/LoginApiTest.php (High Priority)
- [ ] 5 Implement LoginApiTest tests (tests/integration/api/LoginApiTest.php)
  - [ ] 5-1 test_magic_link_authentication_succeeds - Validates magic link login flow
  - [ ] 5-2 test_expired_magic_link_is_rejected - Ensures expired links fail
  - [ ] 5-3 test_invalid_magic_link_returns_error - Validates error handling
  - [ ] 5-4 test_redirect_after_login - Verifies post-login redirect

### tests/integration/api/UserApiTest.php (High Priority)
- [ ] 6 [P] Implement UserApiTest tests (tests/integration/api/UserApiTest.php)
  - [ ] 6-1 test_user_registration_succeeds - Validates user signup
  - [ ] 6-2 test_duplicate_email_is_rejected - Ensures unique email constraint
```

**Note**: Task 6 has `[P]` marker because it's in a different test file than task 5, so they can run in parallel.

## Error Handling

**If plan not found**:
```
❌ Error: Test implementation plan not found

Expected location: .gobuildme/specs/qa-test-scaffolding/qa-test-plan.md

Action required: Run /gbm.qa.plan first to create test implementation plan
```

**If no TODO tests found**:
```
⚠️  Warning: No TODO tests found

Scanned test files but found no TODO/unimplemented tests.

Possible reasons:
- All tests already implemented
- Test files don't use TODO markers
- Scaffolding pattern not recognized

Verification:
- Check test files for TODO comments
- Verify test framework pattern

Next step: Run /gbm.qa.review-tests to verify test quality
```

**If architecture generation needed**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 Architecture documentation not found.
   Generating architecture for better task generation...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Architecture generation runs automatically...]

✓ Architecture documentation generated

🏗️ Generating task checklist with architecture context...
```

## Quality Gates

Before generating tasks, verify:
- [ ] Plan file exists
- [ ] Plan has priority assignments
- [ ] Test files exist
- [ ] TODO tests found
- [ ] Architecture context available (or auto-generated)

After generating tasks, verify:
- [ ] Tasks file created successfully
- [ ] All TODO tests have corresponding tasks
- [ ] Tasks organized by priority
- [ ] Parallel markers applied correctly
- [ ] Progress tracking initialized
- [ ] All tasks start unchecked `[ ]`

## Integration with Workflow

**Position in Workflow**:
```
/gbm.qa.scaffold-tests → /gbm.qa.plan → /gbm.qa.tasks → /gbm.qa.implement → /gbm.qa.review-tests
                                             ↑
                                        (You are here)
```

**Inputs**:
- `.gobuildme/specs/qa-test-scaffolding/qa-test-plan.md` (from `/gbm.qa.plan`)
- Test files with TODO markers
- Architecture documentation (auto-generated if needed)

**Outputs**:
- `.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md` (for `/gbm.qa.implement`)

**Next Command**:
- `/gbm.qa.implement` - Implement tests systematically task-by-task

## Notes

- **Tasks are tactical**: Each task = one test implementation with checkbox
- **Implementation is systematic**: Next command (`/gbm.qa.implement`) goes task-by-task
- **Resumable**: Checkboxes track what's done, can stop and resume anytime
- **Quality gates**: `/gbm.qa.review-tests` will check all tasks are marked `[x]` before allowing merge
- **Never pre-check**: All tasks must start as `[ ]`, earn `[x]` through implementation

### Step 3: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-qa-tasks` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit `$FEATURE_DIR/qa-tasks.md` to adjust test tasks
- Re-run `/gbm.qa.plan` if test strategy needs revision
- Re-run `/gbm.qa.tasks` with refined task breakdown

