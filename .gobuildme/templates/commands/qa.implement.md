---
description: "Implement tests systematically task-by-task from the task checklist"
artifacts:
  - path: "tests/<test-files>"
    description: "Implementation of test cases for the feature (unit, integration, e2e tests)"
  - path: "$FEATURE_DIR/logs/qa-implementation-details.md"
    description: "Full QA implementation details: verbose logs, test output, coverage reports (Tier 2 detail artifact)"
scripts:
  sh: scripts/bash/qa-implement.sh
  ps: scripts/powershell/qa-implement.ps1
---

## Output Style Requirements (MANDATORY)

**Test Implementation Output**:
- One test function per task - no combined tests
- Test names self-documenting (no docstrings repeating the name)
- Fixtures over inline setup - DRY test data
- Max 1 comment per test unless complex assertion logic

**Progress Output**:
- Task completion as checklist: `[x] Task ID - brief description`
- Coverage delta: single line showing before/after percentage
- No prose summaries of what was implemented

**Two-Tier Output Enforcement (Issue #51)**:
- **Progress summary first**: "X/Y tasks complete | Coverage: N%" before any details
- Do NOT paste raw test runner output, full coverage reports, or verbose logs to CLI
- Write full output to: `$FEATURE_DIR/logs/qa-implementation-details.md`
- CLI shows: progress summary + task checklist + "Full output: `<path>`"
- Max 5 test failures shown inline; if more → "See `$FEATURE_DIR/logs/qa-implementation-details.md` for N more"
- Stack traces and verbose output go to detail artifact only

For complete style guidance, see .gobuildme/templates/_concise-style.md


You are the QA Test Implementation Command. Your job is to implement tests systematically, one task at a time, with clear checkpoints and progress tracking.

**⚠️ CRITICAL - COMPREHENSIVE TESTING APPROACH**:
Do NOT limit test implementation to only files with `markTestSkipped`, `TODO`, or placeholder tests.
Your task list from `/gbm.qa.tasks` includes TWO categories of work:
1. **Existing placeholder tests** - Convert TODO/skip markers to real tests
2. **Coverage gap tests** - NEW tests for untested production code (critical business logic, APIs, auth)

If your task list ONLY contains placeholder tests, it was generated incorrectly. Before proceeding:
- Verify task list includes coverage gap analysis (untested modules/functions)
- If missing, re-run `/gbm.qa.tasks` to get comprehensive task list
- Goal is INCREASED coverage, not just filling in existing placeholders

## Workflow

### Step 0: Orientation (MANDATORY — DO THIS FIRST)

Before ANY test implementation, establish context:

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

# 4. Review git history for test changes
if git rev-parse --git-dir >/dev/null 2>&1; then
    git log --oneline -15 -- "tests/" 2>/dev/null || git log --oneline -10
else
    echo "Not a git repository - skipping git history"
fi

# 5. Load task status
cat "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md" 2>/dev/null | head -100

# 6. Count remaining test tasks
echo "=== Remaining Test Tasks ==="
grep -c "^- \[ \]" "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md" 2>/dev/null || echo "0"
```

**DO NOT proceed until you understand**:
- What tests were implemented in previous sessions
- What test task you should work on next
- Any blockers or test failures to be aware of

### Step 0.1: Feature Focus (MANDATORY — After Orientation)

**CRITICAL**: Work on ONE test suite per session. Do not switch test contexts mid-session.

```bash
# Identify current test context
echo "=== Current Test Context ==="
ls "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/" 2>/dev/null
cat "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/qa-test-plan.md" 2>/dev/null | head -30
```

**Rules**:
1. Do NOT switch to implementing tests for different features
2. Do NOT accept requests to work on unrelated tests
3. If issues in other test suites are noticed, document but don't fix now
4. Complete current test suite before moving to another

### Step 0.2: Branch Guard (MANDATORY — Before Any Commits)

**CRITICAL**: GoBuildMe prevents commits to protected branches (main, master, develop, etc.).

Run this check ONCE at session start to confirm you're on a feature branch:

**Bash**:
```bash
# Validate not on protected branch - BLOCKS if on main/master/develop
.gobuildme/scripts/bash/guard-protected-branch.sh
```

**PowerShell**:
```powershell
# Validate not on protected branch - BLOCKS if on main/master/develop
.gobuildme/scripts/powershell/guard-protected-branch.ps1
```

**If this fails**:
1. You are on a protected branch (e.g., `main`)
2. Create a feature branch: `git checkout -b <feature-name>`
3. **DO NOT proceed with test implementation until on a feature branch**

**Why this matters**: The harness system requires commits at session end. Without this guard, commits would land on main.

**Inline usage** (before each commit in this template):
- Bash: `.gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1`
- PowerShell: `.gobuildme/scripts/powershell/guard-protected-branch.ps1 -Quiet; if ($LASTEXITCODE -ne 0) { exit 1 }`

---

### Step 0.5: Smoke Test (MANDATORY — Before Starting Work)

**Purpose**: Catch undocumented test regressions from previous sessions before starting new test implementation.

```bash
# Detect and run project test command
# Source common.sh for workspace-aware path resolution
source "$REPO_ROOT/.gobuildme/scripts/bash/common.sh" 2>/dev/null || true
CONSTITUTION_PATH=$(get_constitution_path 2>/dev/null || echo "$REPO_ROOT/.gobuildme/memory/constitution.md")
if [ -f "$CONSTITUTION_PATH" ]; then
    TEST_CMD=$(grep -A5 "## Development Environment" "$CONSTITUTION_PATH" 2>/dev/null | \
               grep -E "^(npm test|pytest|make test|go test)" | head -1)
fi

if [ -z "$TEST_CMD" ]; then
    if [ -f "$REPO_ROOT/package.json" ]; then
        echo "Running: npm test"
        npm test --passWithNoTests 2>/dev/null || echo "⚠️ Existing tests may be failing"
    elif [ -f "$REPO_ROOT/pyproject.toml" ]; then
        echo "Running: pytest"
        pytest -q 2>/dev/null || echo "⚠️ Existing tests may be failing"
    elif [ -f "$REPO_ROOT/Makefile" ] && grep -q "^test:" "$REPO_ROOT/Makefile"; then
        echo "Running: make test"
        make test 2>/dev/null || echo "⚠️ Existing tests may be failing"
    else
        echo "No test command detected - verify manually"
    fi
else
    echo "Running: $TEST_CMD"
    $TEST_CMD 2>/dev/null || echo "⚠️ Existing tests may be failing"
fi
```

**If tests fail at session START**:
1. **DO NOT** proceed with new test implementation
2. Check git log for recent test changes that may have broken tests
3. Read progress notes for any documented issues
4. Fix the regression FIRST, then continue with planned work
5. Document the fix in progress notes

**If tests pass**: Proceed with test implementation.

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.qa.implement" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

**IMPORTANT**: Run `{SCRIPT}` from the repository root. The script will:
- Automatically check and generate architecture documentation if needed
- Load task checklist from qa-test-scaffolding directory
- Find first unchecked task `[ ]`
- Implement that specific test with proper assertions and test data
- Mark task as complete `[x]` when test passes
- Update progress tracking
- Ask user to continue or stop
- Resume from where left off on next run

The script handles the systematic test implementation process. Do NOT attempt to manually
implement all tests at once. The script ensures one task at a time with checkpoints.

### What the Script Does

The script (`{SCRIPT}`) performs these steps automatically:

**1) Architecture Integration**
   - Checks if `.gobuildme/docs/technical/architecture/technology-stack.md` exists
   - If missing: Automatically runs `/gbm.architecture` to generate it
   - If old (>7 days): Prompts user to refresh
   - Loads architecture context for better test implementations

**2) Fixture Generation Pre-Check**
   - Checks if `.gobuildme/specs/qa-test-scaffolding/qa-test-plan.md` recommended fixtures
   - If fixtures recommended:
     - Checks if `.gobuildme/specs/qa-test-scaffolding/fixtures/` directory exists
     - If NOT exists: WARN "Plan recommended /gbm.qa.generate-fixtures - run it first for better efficiency"
     - Prompts: "Continue without fixtures? Tests will need manual test data. [y/N]"
     - If 'n' or blank: STOP with message "Run /gbm.qa.generate-fixtures then retry"
   - If fixtures not recommended: Skip check, proceed

**3) Load Task Checklist**
   - Reads `.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md`
   - If not found: ERROR "Run /gbm.qa.tasks first"
   - Parses all tasks with checkboxes
   - Identifies completed `[x]` vs pending `[ ]` tasks

**4) Find Next Task to Implement**
   - Scans task file for first `[ ]` (unchecked task)
   - If all tasks `[x]`: SUCCESS "All tests implemented!"
   - Extracts task details:
     - Task ID (e.g., "5-1")
     - Test name (e.g., "test_magic_link_authentication_succeeds")
     - Test file (e.g., "tests/integration/api/LoginApiTest.php:42")
     - Test description (e.g., "Validates magic link login flow")

**5) Load Specification Context**
   - Reads `$FEATURE_DIR/spec.md` for Acceptance Criteria
   - Reads `$FEATURE_DIR/plan.md` for implementation details
   - Reads architecture docs for system context
   - Identifies what needs to be tested

**6) Implement the Test**

   **For Unit Tests**:
   - Identify the function/method under test
   - Determine input parameters and expected outputs
   - Create test data (valid, invalid, edge cases)
   - Write assertions for all code branches
   - Mock all external dependencies
   - Follow AAA pattern (Arrange, Act, Assert)

   **For Integration Tests**:
   - Identify integration points (API, DB, Queue, External services)
   - Set up test fixtures and database state
   - Create realistic test data
   - Write assertions for API responses and database state
   - Clean up after test (transactions, rollback)

   **For E2E Tests**:
   - Identify user flow to test
   - Set up browser automation (Playwright/Selenium)
   - Create test user accounts and data
   - Write assertions for UI state and navigation
   - Handle waits and async operations properly

**7) Apply Best Practices**
   - **AAA Pattern**: Arrange, Act, Assert
   - **Descriptive Names**: Test names describe what they test
   - **Clear Assertions**: Descriptive failure messages
   - **Test Isolation**: Each test independent and idempotent
   - **Proper Mocking**: Mock external dependencies only
   - **Cleanup**: Reset state after each test

**7a) Test Code Quality Standards** (CRITICAL - Avoid Common Mistakes)

   **DO NOT write tests that:**
   - Use hardcoded file paths instead of imports (e.g., `require('../../../src/config')` instead of proper module imports)
   - Test constant values (e.g., `expect(CONFIG.API_URL).toBe('https://api.example.com')` - this tests nothing, just validates a constant)
   - Have no meaningful assertions (e.g., just checking `toBeDefined()` or `!== null`)
   - Test existence instead of behavior (e.g., `expect(typeof foo).toBe('function')`)

   **DO write tests that:**
   - Use proper imports and module resolution
   - Test actual behavior, not configuration values
   - Have assertions that verify real outcomes
   - Would catch real bugs when code changes

   **Example of BAD test** (tests nothing useful):
   ```javascript
   test('API_URL is correct', () => {
     expect(CONFIG.API_URL).toBe('https://api.example.com');  // ❌ Just validates a constant
   });
   ```

   **Example of GOOD test** (tests actual behavior):
   ```javascript
   test('API client uses correct URL for requests', () => {
     const mockFetch = jest.fn().mockResolvedValue({ ok: true });
     const client = new ApiClient({ fetch: mockFetch });
     await client.get('/users');
     expect(mockFetch).toHaveBeenCalledWith(expect.stringContaining('/users'));  // ✓ Tests actual behavior
   });
   ```

**8) Run the Test**
   - Execute the implemented test
   - Verify it passes
   - If fails: Debug and fix
   - If passes: Continue to next step

**9) Verify Quality Standards Before Marking Complete**
   - Check task's "Must verify before marking [x]" checklist from qa-test-tasks.md
   - Verify ALL criteria met:
     - ✓ AAA pattern used (clear Arrange, Act, Assert sections)
     - ✓ External dependencies mocked (no real API/DB calls where inappropriate)
     - ✓ Complete assertions (e.g., status 200 AND session created, not just status)
     - ✓ Performance met (test runs within time limit from TR-XXX)
     - ✓ Cleanup performed (resources released, data cleaned up)
     - ✓ Test passes with clear assertion messages
   - If ANY criterion NOT met: DO NOT mark complete, fix issues first
   - Reference TR-XXX in qa-test-plan.md for full quality standards

**10) Mark Task Complete**
   - ONLY after ALL verification criteria met in step 8
   - Update task checkbox: `- [ ]` → `- [x]`
   - Update task file: `.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md`
   - Update progress tracking in task file

**11) Calculate and Report Progress**
   - Count total tasks
   - Count completed tasks
   - Calculate percentage: `(completed / total) * 100`
   - Display progress: `✅ Progress: 5/94 tasks complete (5%)`

**12) Checkpoint - Ask to Continue**
   - Display: `Continue with next task? [Y/n]`
   - If user says `Y` or `yes`: Loop back to step 3 (find next task)
   - If user says `n` or `no`: Stop and save state
   - If user says nothing (Enter): Default to `Y` (continue)

**13) State is Resumable**
   - Task checklist persists in file with `[x]` markers
   - Next run starts from first `[ ]` (unchecked task)
   - No state lost between sessions

**14) Quality Gate on Completion**
   - When all tasks `[x]`: Run quick validation
   - Check all tests pass
   - Report completion status
   - Suggest next step: `/gbm.qa.review-tests`

## Prerequisites

**Required**:
- [ ] Task checklist exists (run `/gbm.qa.tasks` first)
- [ ] Tasks file exists at `.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md`
- [ ] Test files with TODO markers exist

**Recommended**:
- [ ] Architecture documentation exists (auto-generated if missing)
- [ ] Fixtures generated (run `/gbm.qa.generate-fixtures` for better test data)
- [ ] Review task checklist before starting

## Output Format

Progress display format:
- Task header with ID, file, description, priority
- Implementation status → Test run result → Mark complete
- Progress: `✅ X/Y tasks complete (Z%)`
- Checkpoint: `Continue with next task? [Y/n]`
- On pause: Shows completed/remaining counts + resume command
- On completion: Shows 100%, validation status, suggests `/gbm.qa.review-tests`

## Error Handling

**If task checklist not found**:
```
❌ Error: Task checklist not found

Expected location: .gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md

Action required: Run /gbm.qa.tasks first to generate task checklist
```

**If test fails after implementation**:
```
❌ Test Failed: test_magic_link_authentication_succeeds

Error:
AssertionError: Expected status code 200, got 401

Debugging...
- Check authentication setup
- Verify magic link token generation
- Review test data

Fix the test and run /gbm.qa.implement again to retry
```

**If architecture generation needed**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 Architecture documentation not found.
   Generating architecture for better test implementations...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Architecture generation runs automatically...]

✓ Architecture documentation generated

🏗️ Implementing tests with architecture context...
```

## Resumability

**Key feature**: This command is fully resumable.

**Scenario 1: User stops mid-implementation**
```bash
# Session 1
/gbm.qa.implement
> Implements tasks 1-10
> User says "n" to stop
> Progress: 10/94 (11%)

# Session 2 (later)
/gbm.qa.implement
> Resumes from task 11
> Implements tasks 11-25
> User says "n" to stop
> Progress: 25/94 (27%)

# Session 3 (later)
/gbm.qa.implement
> Resumes from task 26
> Implements tasks 26-94
> Progress: 94/94 (100%)
> All done!
```

**State is preserved** in `.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md` with `[x]` markers.

## Quality Gates

**Before starting implementation**:
- [ ] Task checklist exists
- [ ] At least one unchecked task `[ ]` exists
- [ ] Test files exist
- [ ] Architecture context available (or auto-generated)

**During implementation** (per task):
- [ ] Test implemented following AAA pattern
- [ ] Test passes when run
- [ ] External dependencies properly mocked
- [ ] Clear assertion messages
- [ ] Test is independent (no shared state)

**After all tasks complete**:
- [ ] All tasks marked `[x]`
- [ ] All tests pass
- [ ] No unchecked tasks remain
- [ ] Ready for `/gbm.qa.review-tests`

**Critical Quality Gate** (enforced by `/gbm.qa.review-tests`):
- ✅ `/gbm.qa.review-tests` will check if any `[ ]` tasks remain
- ❌ If incomplete: Blocks and requires running `/gbm.qa.implement` to finish
- ✅ If complete: Proceeds with coverage and quality validation

## Integration with Workflow

**Position in Workflow**:
```
/gbm.qa.scaffold-tests → /gbm.qa.plan → /gbm.qa.tasks → /gbm.qa.implement → /gbm.qa.review-tests
                                                              ↑
                                                         (You are here)
```

**Inputs**:
- `.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md` (from `/gbm.qa.tasks`)
- Test files with TODO markers
- Architecture documentation (auto-generated if needed)
- Specification files (spec.md, plan.md)

**Outputs**:
- Updated `.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md` (with `[x]` markers)
- Implemented tests in test files (no more TODOs)
- Progress tracking updated

**Next Command**:
- `/gbm.qa.review-tests` - Validate test quality, coverage, and AC traceability

## Best Practices for Test Implementation

**Unit Tests**: Use AAA pattern (Arrange, Act, Assert), mock external dependencies, clear assertion messages
**Integration Tests**: Verify both API response AND database state, use fixtures for test data
**E2E Tests**: Use explicit waits (not sleeps), proper locators with data-testid, handle async operations

## Task Completion Check (MANDATORY - Enforced Quality Gate)

**CRITICAL QUALITY GATE**: This is a MANDATORY checkpoint that CANNOT be bypassed.

### 1. Load and Parse Tasks File

**ALWAYS** start by reading `.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md`

Parse ALL task checkboxes:
- Count total tasks: All lines matching `- [ ]` or `- [x]` + task number
- Count completed: Lines matching `- [x]`
- Count incomplete: Lines matching `- [ ]`

### 2. Display Task Completion Status

**MANDATORY OUTPUT** - Print this BEFORE doing anything else:

```
═══════════════════════════════════════════════════════════
TASK COMPLETION CHECK
═══════════════════════════════════════════════════════════

Let me check the current task completion status:

Total Tasks: X
Completed: Y tasks [x]
Incomplete: Z tasks [ ]

Status: [✓ ALL COMPLETE / ⚠️ CONTINUE IMPLEMENTATION REQUIRED]
═══════════════════════════════════════════════════════════
```

### 3. Quality Gate Decision Logic

**IF all tasks complete** (Z = 0):
  - ✅ Status: "✓ ALL COMPLETE"
  - ✅ Proceed to "Next Steps" section below
  - ✅ Suggest `/gbm.qa.review-tests`
  - ✅ You may stop

**IF any tasks incomplete** (Z > 0):
  - ❌ Status: "⚠️ CONTINUE IMPLEMENTATION REQUIRED"
  - ❌ **DO NOT STOP**
  - ❌ **DO NOT SUGGEST** `/gbm.qa.review-tests` or any other command
  - ❌ **DO NOT ASK USER** what to do
  - ✅ **AUTOMATICALLY CONTINUE** implementing remaining tasks
  - ✅ Print: "⚠️ Test implementation not complete. Z tasks remaining. Continuing implementation..."
  - ✅ List the next incomplete task
  - ✅ Implement that task
  - ✅ Mark task as `[x]` when complete
  - ✅ **LOOP BACK** to step 1 (reload and recheck)
  - ✅ **REPEAT** until ALL tasks are `[x]`

### 4. Automatic Loop Enforcement

**THE SYSTEM MUST**:
1. Check task completion status
2. If incomplete: Implement next task
3. Mark complete: Update `[ ]` → `[x]`
4. **GOTO step 1** (reload and recheck)
5. Repeat steps 1-4 until Z = 0 (all complete)
6. ONLY when Z = 0: Proceed to Next Steps

**NEVER**:
- ❌ Ask user "Would you like me to continue?"
- ❌ Stop with incomplete tasks and suggest resuming later
- ❌ Offer options like "A) Continue" or "B) Demonstrate workflow"
- ❌ Suggest `/gbm.qa.review-tests` when tasks incomplete
- ❌ Give excuses like "184 tasks is too much"

**ALWAYS**:
- ✅ Check completion status
- ✅ Auto-continue if incomplete
- ✅ Implement systematically task-by-task
- ✅ Loop until 100% complete
- ✅ Update progress after each task
- ✅ Only stop when Z = 0

### 5. Progress Tracking

After completing each task:
- Update task file: Change `- [ ]` to `- [x]` for completed task
- Reload task file
- Recount totals
- Print progress: "✅ Progress: Y/X tasks complete (percentage%)"
- Continue to next incomplete task

### 6. Completion Criteria

**ONLY** print "Next Steps" when:
- ✅ Total tasks = Completed tasks
- ✅ Incomplete tasks = 0
- ✅ ALL checkboxes in task file are `[x]`
- ✅ No `[ ]` checkboxes remain

**QUALITY GATE ENFORCEMENT**: The `/gbm.qa.review-tests` command will REJECT and BLOCK if ANY tasks remain incomplete.

Next Steps (ONLY print when ALL tasks 100% complete):
- Run `/gbm.qa.review-tests` to validate test quality, coverage, and AC traceability
- All quality gates must pass before merge

**USER REQUIREMENT MET**: "make sure we have gates which checks if all test tasks are completed and if not, make the system to continue and finish all tasks"
- ✅ Gate checks task completion (MANDATORY, cannot bypass)
- ✅ System auto-continues until 100% complete
- ✅ Blocks suggesting next steps when incomplete
- ✅ Enforces systematic completion of ALL tasks

## Notes

- **Task-by-task**: Implements one test at a time, not all at once
- **Checkpoints**: Asks user to continue after each task
- **Resumable**: Can stop anytime and resume later from exact task
- **Progress tracking**: Always shows X/Y complete (percentage)
- **Quality gates**: All tasks must be complete before suggesting next steps
- **State persistence**: Task checklist file is the source of truth

**User's requirement met**: "make sure we have gates which checks if all test tasks are completed and if not, make the system to continue and finish all tasks"
- ✅ Gate checks task completion (MANDATORY before finishing)
- ✅ System continues task-by-task until all complete
- ✅ BLOCKS suggesting next steps if any tasks incomplete
- ✅ Forces continuation until 100% complete

### Step 3: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-qa-implement` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Fix failing tests by editing test code or fixtures
- Re-run `/gbm.qa.tasks` if test task breakdown needs revision
- Manually edit test infrastructure code
- Re-run `/gbm.qa.implement` for specific test tasks

## Final Step: Clean State Validation & Progress Notes (MANDATORY)

Before ending this session, you MUST ensure clean state AND update progress notes.

### Part 1: Clean State Checklist (REQUIRED before stopping)

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo "=== Clean State Validation ==="

# 1. Check for uncommitted changes
echo "=== Git Status ==="
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo "❌ UNCOMMITTED CHANGES - commit before stopping"
    git status --short
else
    echo "✅ Git status clean"
fi

# 2. Check for WIP commits that need cleanup
echo ""
echo "=== Recent Commits ==="
if git log --oneline -5 2>/dev/null | grep -qi "wip"; then
    echo "⚠️ WIP commits found - consider squashing before next session"
else
    echo "✅ No WIP commits"
fi

# 3. Check tests pass
echo ""
echo "=== Test Status ==="
if [ -f "$REPO_ROOT/package.json" ]; then
    npm test --passWithNoTests 2>/dev/null && echo "✅ Tests passing" || echo "❌ TESTS FAILING - fix before stopping"
elif [ -f "$REPO_ROOT/pyproject.toml" ]; then
    pytest -q 2>/dev/null && echo "✅ Tests passing" || echo "❌ TESTS FAILING - fix before stopping"
elif [ -f "$REPO_ROOT/Makefile" ] && grep -q "^test:" "$REPO_ROOT/Makefile"; then
    make test 2>/dev/null && echo "✅ Tests passing" || echo "❌ TESTS FAILING - fix before stopping"
fi

# 4. Check task status
echo ""
echo "=== Task Completion ==="
INCOMPLETE=$(grep -c "^- \[ \]" "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md" 2>/dev/null || echo "0")
TOTAL=$(grep -c "^- \[" "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md" 2>/dev/null || echo "0")
COMPLETE=$((TOTAL - INCOMPLETE))
echo "Tasks: $COMPLETE/$TOTAL complete ($INCOMPLETE remaining)"
```

**If ANY check fails**, DO NOT end session - fix the issue first.

### Part 2: Update Progress Notes (REQUIRED before stopping)

Update `.gobuildme/specs/qa-test-scaffolding/verification/gbm-progress.txt`:

1. Add new session entry at top of Session History:
   ```markdown
   ### Session N — <Date/Time UTC>

   **Status**: in-progress | completed | blocked
   **Phase**: QA Test Implementation
   **Tasks Completed This Session**: <count>
   - [x] Task X.Y: <test description>
   - [x] Task X.Z: <test description>

   **Issues Encountered**:
   - <issue and resolution>

   **Next Steps (Priority Order)**:
   1. Task A: <description>
   2. Task B: <description>

   **Notes for Next Session**:
   - <important context for resuming>
   ```

2. Commit progress (after branch guard passes):
   ```bash
   .gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1
   git add .gobuildme/specs/qa-test-scaffolding/verification/gbm-progress.txt
   git commit -m "chore(qa): update progress notes - session N"
   ```

### Victory Conditions (ALL must pass before declaring test implementation complete)

| Condition | Check | Required |
|-----------|-------|----------|
| All test tasks complete | `grep -c "^- \[ \]" qa-test-tasks.md` | 0 |
| All tests pass | Run project test command | Exit 0 |
| No uncommitted changes | `git status --porcelain` | Empty |
| Progress notes updated | `gbm-progress.txt` has current session | Yes |

**DO NOT** declare test implementation complete unless ALL conditions pass.

