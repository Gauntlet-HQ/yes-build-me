---
description: "Review test quality, coverage, and best practices compliance."
artifacts:
  - path: ".gobuildme/qa/<feature>/test-review-report.md"
    description: "Review report validating test coverage and quality standards"
scripts:
  sh: scripts/bash/review-tests.sh
  ps: scripts/powershell/review-tests.ps1
---

## Output Style Requirements (MANDATORY)

**Review Report Output**:
- Verdict first: PASS / NEEDS WORK / FAIL
- Metrics as table: metric | value | threshold | status
- Issues as table: severity | file:line | issue | fix
- No prose explanations of best practices - link to docs

**Coverage Analysis**:
- AC coverage as table: AC-ID | test file | status
- Gap list as bullets, not prose
- No explanations of why coverage matters
For complete style guidance, see .gobuildme/templates/_concise-style.md


You are the Review Tests Command. Your job is to review test quality, ensure best practices are followed, validate coverage, and identify gaps.

**Context**: This command helps QA Engineers ensure tests are high-quality, maintainable, and thorough.

## Workflow

### Step 0: Orientation (MANDATORY — DO THIS FIRST)

Before ANY test review, establish context:

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

# 5. Check task completion status
echo "=== Task Completion Status ==="
INCOMPLETE=$(grep -c "^- \[ \]" "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md" 2>/dev/null || echo "0")
TOTAL=$(grep -c "^- \[" "$REPO_ROOT/.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md" 2>/dev/null || echo "0")
echo "Tasks: $((TOTAL - INCOMPLETE))/$TOTAL complete ($INCOMPLETE remaining)"
```

**DO NOT proceed if tasks incomplete** - run `/gbm.qa.implement` first.

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
3. **DO NOT proceed with test review until on a feature branch**

**Why this matters**: The harness system requires commits at session end. Without this guard, commits would land on main.

**Inline usage** (before each commit in this template):
- Bash: `.gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1`
- PowerShell: `.gobuildme/scripts/powershell/guard-protected-branch.ps1 -Quiet; if ($LASTEXITCODE -ne 0) { exit 1 }`

---

### Step 0.5: Smoke Test (MANDATORY — Before Review)

**Purpose**: Verify all tests pass before conducting quality review.

```bash
# Run all tests
if [ -f "$REPO_ROOT/package.json" ]; then
    echo "Running: npm test"
    npm test || echo "❌ Tests failing - cannot proceed with review"
elif [ -f "$REPO_ROOT/pyproject.toml" ]; then
    echo "Running: pytest"
    pytest || echo "❌ Tests failing - cannot proceed with review"
elif [ -f "$REPO_ROOT/Makefile" ] && grep -q "^test:" "$REPO_ROOT/Makefile"; then
    echo "Running: make test"
    make test || echo "❌ Tests failing - cannot proceed with review"
fi
```

**If tests fail**: Fix failing tests FIRST before conducting quality review.

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.qa.review-tests" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

**IMPORTANT**: Run `{SCRIPT}` from the repository root. The script will:
- Automatically check and generate architecture documentation if needed
- Review test quality and best practices compliance
- Analyze test coverage (unit, integration, e2e)
- Validate AC traceability (100% required)
- Enforce persona-aware quality gates
- Generate a complete quality review report

The script handles the entire test review process. Do NOT attempt to manually review tests yourself.

### What the Script Does

The script (`{SCRIPT}`) performs these steps automatically:

Persona Context (optional):
- If `.gobuildme/config/personas.yaml` exists and `default_persona` is set to `qa_engineer`, applies strict quality standards.
- If `templates/personas/partials/qa_engineer/review-tests.md` exists, includes enhanced standards.

**1) Architecture Integration**
   - Checks if architecture documentation exists
   - If missing: Automatically runs `/gbm.architecture` to generate it
   - If old (>7 days): Prompts to refresh
   - Loads architecture context for better review

**2) Task Completion Validation (MANDATORY)**

   **Before reviewing test quality**, verify all test implementation tasks are complete:

   - Load task checklist: `.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md`
   - Count total tasks, completed `[x]`, and incomplete `[ ]`
   - **Task Completion Gate**:
     - 🟢 **PASS**: All tasks marked `[x]` → Proceed with quality review
     - 🔴 **FAIL**: Any tasks marked `[ ]` → **BLOCK** and require completion

   **If Tasks Incomplete**:
   - List all incomplete tasks with IDs and descriptions
   - Output: "❌ Review blocked: X tasks incomplete. Run /gbm.qa.implement to finish all tasks before review"
   - **DO NOT PROCEED** with quality review until all tasks complete
   - Exit with error status

   **Task Completion Report**:
   ```
   ═══════════════════════════════════════════════════════════
   TASK COMPLETION CHECK
   ═══════════════════════════════════════════════════════════
   Total Tasks: X
   Completed: Y [x]
   Incomplete: Z [ ]

   Status: [✓ ALL COMPLETE / ❌ INCOMPLETE - BLOCKING]
   ═══════════════════════════════════════════════════════════
   ```

**3) Test Quality Review**

   **ONLY after all tasks complete**, check each test for:

   **Structure**:
   - ✅ Uses AAA pattern (Arrange, Act, Assert)
   - ✅ Has descriptive name
   - ✅ Has clear docstring
   - ✅ Tests one thing (single responsibility)
   - ✅ Is independent (no shared state)

   **Assertions**:
   - ✅ Has clear assertions
   - ✅ Assertions have failure messages
   - ✅ Tests expected behavior, not implementation
   - ✅ Covers happy path and error cases

   **Test Data**:
   - ✅ Uses realistic test data
   - ✅ Uses fixtures for reusable data
   - ✅ Cleans up after test
   - ✅ Doesn't hardcode sensitive data

   **Mocking**:
   - ✅ Mocks external dependencies
   - ✅ Doesn't mock the system under test
   - ✅ Uses appropriate mock types (Mock, MagicMock, patch)
   - ✅ Verifies mock calls when needed

**4) Coverage Analysis & ENFORCEMENT GATE**

   **⚠️ CRITICAL GATE - COVERAGE MUST MEET TARGETS**

   This gate enforces coverage targets. Behavior depends on the gate mode configured
   in `.gobuildme/config/qa-config.yaml`:
   - **strict** (production): Blocks review if targets not met
   - **advisory** (default): Warns but allows proceeding
   - **disabled**: Information only

   **Run Coverage Analysis**:
   - Execute coverage tool (pytest-cov, phpunit --coverage, nyc, etc.)
   - Identify uncovered lines, branches, functions
   - Calculate coverage percentages by test type

   **Coverage Targets**:
   | Type | Target | Action if Below |
   |------|--------|-----------------|
   | Unit Tests | 90% | Re-run `/gbm.qa.tasks` to generate gap tasks |
   | Integration Tests | 95% | Re-run `/gbm.qa.tasks` to generate gap tasks |
   | E2E Tests | 80% | Re-run `/gbm.qa.tasks` to generate gap tasks |
   | **Overall** | **85%** | Re-run `/gbm.qa.tasks`; block in strict mode |

   **Coverage Enforcement Logic**:
   - IF overall coverage < 85%:
     * Identify coverage gaps (uncovered production code files)
     * Output: "❌ Coverage 62% is below 85% target. Run /gbm.qa.tasks to generate gap tasks."
     * **strict mode**: BLOCK REVIEW - must close gaps first
     * **advisory mode**: WARN but allow proceeding (default)
     * **Action Required**: Re-run `/gbm.qa.tasks` to generate actionable tasks for coverage gaps
   - IF coverage ≥ 85%: **PASS** - continue with quality review

   **Coverage Gaps** (generated by `/gbm.qa.tasks`):
   - Source files without corresponding test files
   - Critical paths lacking test coverage
   - Missing error handling tests
   - Untested integration points
   - Run `/gbm.qa.tasks` to generate actionable tasks for ALL gaps

**5) AC Traceability**

   **Verify**:
   - Every AC has at least one test
   - Test names reference AC IDs
   - Tests actually validate the AC
   - No orphaned tests (tests without ACs)

   **Report**:
   - List ACs with tests
   - List ACs without tests
   - List tests without ACs
   - Calculate traceability percentage

**6) Best Practices Compliance**

   **Unit Tests**:
   - ✅ Fast (< 100ms per test)
   - ✅ No external dependencies
   - ✅ Deterministic (same input = same output)
   - ✅ Tests public interface, not internals

   **Integration Tests**:
   - ✅ Tests real integrations
   - ✅ Uses test database/services
   - ✅ Cleans up after each test
   - ✅ Moderate execution time (< 5s)

   **E2E Tests**:
   - ✅ Tests critical user flows
   - ✅ Uses page objects
   - ✅ Uses explicit waits (not sleeps)
   - ✅ Stable selectors (data-testid)

   **General**:
   - ✅ No skipped tests (unless documented)
   - ✅ No commented-out tests
   - ✅ No print statements (use logging)
   - ✅ No hardcoded values (use constants/config)

**7) Non-Functional Testing**

   **Performance Tests**:
   - ✅ Response time tests exist
   - ✅ Load tests for critical endpoints
   - ✅ Database query performance tested

   **Security Tests**:
   - ✅ SQL injection tests
   - ✅ XSS tests
   - ✅ CSRF tests
   - ✅ Authentication/authorization tests
   
   **Accessibility Tests**:
   - ✅ WCAG compliance tests
   - ✅ Keyboard navigation tests
   - ✅ Screen reader compatibility tests

**8) Test Maintainability**

   **Code Quality**:
   - ✅ No code duplication
   - ✅ Uses helper functions
   - ✅ Uses fixtures appropriately
   - ✅ Clear variable names
   
   **Documentation**:
   - ✅ Tests have docstrings
   - ✅ Complex logic is commented
   - ✅ Test data is explained
   - ✅ Setup/teardown is documented

## Output Format

### Test Quality Report

```
╔════════════════════════════════════════════════════════════════╗
║                    TEST QUALITY REPORT                         ║
╚════════════════════════════════════════════════════════════════╝

📊 COVERAGE SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Unit Tests:        92% (threshold: 90%) ✓
Integration Tests: 96% (threshold: 95%) ✓
E2E Tests:         85% (threshold: 80%) ✓
Overall:           91% (threshold: 85%) ✓

📋 AC TRACEABILITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total ACs:         12
ACs with tests:    12 (100%) ✓
ACs without tests: 0
Orphaned tests:    0

✅ QUALITY CHECKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Structure:         45/45 tests ✓
Assertions:        45/45 tests ✓
Test Data:         43/45 tests ⚠ (2 issues)
Mocking:           40/40 unit tests ✓
Best Practices:    44/45 tests ⚠ (1 issue)

⚠️  ISSUES FOUND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. tests/unit/test_auth.py:45
   Issue: Hardcoded password in test
   Fix: Use fixture or constant
   
2. tests/integration/test_api.py:78
   Issue: No cleanup after test
   Fix: Add teardown to reset database state
   
3. tests/e2e/test_login.py:23
   Issue: Uses time.sleep() instead of explicit wait
   Fix: Use page.wait_for_selector()

📈 COVERAGE GAPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Uncovered Lines:
  • app/auth.py:45-48 (error handling)
  • app/users.py:123 (edge case)

Uncovered Branches:
  • app/validators.py:34 (else branch)

Recommendations:
  1. Add test for password reset error handling
  2. Add test for user creation with duplicate email
  3. Add test for invalid email format

🎯 RECOMMENDATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

High Priority:
  1. Fix hardcoded test data (2 tests)
  2. Add cleanup to integration tests (1 test)
  3. Cover error handling in auth.py

Medium Priority:
  1. Add performance tests for login endpoint
  2. Add security tests for SQL injection
  3. Improve test documentation

Low Priority:
  1. Refactor duplicate test setup code
  2. Add more edge case tests
  3. Improve test naming consistency

✅ OVERALL ASSESSMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Test Quality:  GOOD (3 minor issues)
Coverage:      EXCELLENT (91%, target: 85%)
Traceability:  EXCELLENT (100%)
Maintainability: GOOD

Status: ✅ READY FOR REVIEW (fix 3 minor issues)
```

## Review Checklist

### Unit Tests

- [ ] All unit tests run in < 100ms
- [ ] No external dependencies (DB, network, file system)
- [ ] All dependencies are mocked
- [ ] Tests are deterministic
- [ ] Coverage ≥ 90%
- [ ] All branches covered
- [ ] Error cases tested
- [ ] Edge cases tested

### Integration Tests

- [ ] Tests use real integrations (DB, API, Queue)
- [ ] Test database is used (not production)
- [ ] Each test is isolated
- [ ] Cleanup after each test
- [ ] Coverage ≥ 95%
- [ ] All integration points tested
- [ ] Error handling tested
- [ ] Timeouts tested

### E2E Tests

- [ ] Tests critical user flows
- [ ] Uses page objects
- [ ] Uses explicit waits (no sleeps)
- [ ] Uses stable selectors (data-testid)
- [ ] Coverage ≥ 80%
- [ ] Happy paths tested
- [ ] Error flows tested
- [ ] Cross-browser tested (if applicable)

### General

- [ ] All tests pass
- [ ] No skipped tests (or documented why)
- [ ] No commented-out tests
- [ ] AC traceability = 100%
- [ ] Non-functional tests exist
- [ ] Tests are maintainable
- [ ] Tests are documented

## Common Issues and Fixes

### Issue: Hardcoded Test Data

**Bad**:
```python
def test_user_creation():
    user = create_user("test@example.com", "password123")
    assert user.email == "test@example.com"
```

**Good**:
```python
@pytest.fixture
def test_user_data():
    return {
        "email": "test@example.com",
        "password": "SecurePass123!"
    }

def test_user_creation(test_user_data):
    user = create_user(**test_user_data)
    assert user.email == test_user_data["email"]
```

### Issue: No Cleanup

**Bad**:
```python
def test_create_user(db_session):
    user = User(email="test@example.com")
    db_session.add(user)
    db_session.commit()
    # No cleanup - user remains in DB
```

**Good**:
```python
@pytest.fixture
def db_session():
    session = Session()
    yield session
    session.rollback()  # Cleanup
    session.close()

def test_create_user(db_session):
    user = User(email="test@example.com")
    db_session.add(user)
    db_session.commit()
    # Cleanup happens automatically
```

### Issue: Using time.sleep()

**Bad**:
```python
def test_login_flow(page):
    page.click('button[type="submit"]')
    time.sleep(2)  # Bad: flaky
    assert page.locator('.success').is_visible()
```

**Good**:
```python
def test_login_flow(page):
    page.click('button[type="submit"]')
    page.wait_for_selector('.success', state='visible')  # Good: explicit wait
    assert page.locator('.success').is_visible()
```

## Next Steps

After reviewing tests, follow this workflow:

### If Issues Found

1. **Fix Issues**: Address all identified issues
   - Hardcoded data → Use fixtures
   - Missing cleanup → Add teardown
   - time.sleep() → Use explicit waits
   - **Why**: Improve test quality and maintainability

2. **Fill Coverage Gaps**: Add tests for uncovered code
   ```bash
   pytest --cov=app --cov-report=html tests/
   open htmlcov/index.html
   ```
   **Why**: Meet coverage thresholds (Unit: 90%, Integration: 95%, E2E: 80%)

3. **Re-run Review** (`/gbm.qa.review-tests`)
   - Validate improvements
   - **Why**: Ensure all issues resolved

### If All Checks Pass

4. **Validate Coverage** (`scripts/bash/validate-coverage.sh`) - **NEXT COMMAND**
   - Enforce coverage thresholds
   - **Why**: Automated validation before final review

5. **Validate AC Traceability** (`/gbm.analyze`)
   - Ensure 100% AC coverage
   - **Why**: Required quality gate

6. **Final Review** (`/gbm.review`) - **FINAL STEP**
   - Complete quality gates validation
   - All tests pass
   - Coverage thresholds met
   - AC traceability 100%
   - No linting errors
   - No security issues
   - **Why**: Ready for merge

7. **Push** (`/gbm.push`)
   - Create PR and merge
   - **Why**: Deploy to production

## Related Commands

- `/gbm.qa.scaffold-tests` - Generate initial test structure (run first)
- `/gbm.qa.generate-fixtures` - Generate test fixtures (run early)
- `/gbm.qa.implement` - Implement tests systematically task-by-task (run before review)
- `/gbm.tests` - Run feature-scoped tests
- `/gbm.analyze` - Validate AC traceability (run next)
- `/gbm.review` - Complete quality gates (run after this)
- `/gbm.push` - Create PR and merge (final step)

### Step 3: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-qa-review-tests` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Address test quality issues identified in review report
- Fix failing tests or improve test coverage
- Re-run `/gbm.qa.implement` if tests need major rework
- Re-run `/gbm.qa.review-tests` after fixes to verify improvements

## Final Step: Clean State Validation & Progress Notes (MANDATORY)

Before ending this session, you MUST ensure clean state AND update progress notes.

### Clean State Checklist

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo "=== Clean State Validation ==="

# 1. Check for uncommitted changes
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo "❌ UNCOMMITTED CHANGES - commit before stopping"
    git status --short
else
    echo "✅ Git status clean"
fi

# 2. Check tests still pass
echo ""
echo "=== Final Test Verification ==="
if [ -f "$REPO_ROOT/package.json" ]; then
    npm test --passWithNoTests 2>/dev/null && echo "✅ Tests passing" || echo "❌ TESTS FAILING"
elif [ -f "$REPO_ROOT/pyproject.toml" ]; then
    pytest -q 2>/dev/null && echo "✅ Tests passing" || echo "❌ TESTS FAILING"
elif [ -f "$REPO_ROOT/Makefile" ] && grep -q "^test:" "$REPO_ROOT/Makefile"; then
    make test 2>/dev/null && echo "✅ Tests passing" || echo "❌ TESTS FAILING"
fi

# 3. Check review report exists
echo ""
echo "=== Review Report Status ==="
if [ -f "$REPO_ROOT/.gobuildme/qa/test-review-report.md" ]; then
    echo "✅ Review report exists"
else
    echo "⚠️ Review report not found"
fi
```

### Update Progress Notes

Update `.gobuildme/specs/qa-test-scaffolding/verification/gbm-progress.txt`:

```markdown
### Session N — <Date/Time UTC>

**Status**: completed
**Phase**: QA Test Review
**Review Results**:
- Test Quality: <PASS/NEEDS WORK/FAIL>
- Coverage: <percentage>%
- AC Traceability: <percentage>%

**Issues Found**:
- <issue 1>
- <issue 2>

**Next Steps**:
1. Run `/gbm.review` for final quality gates
```

Commit progress (after branch guard passes):
```bash
.gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1
git add .gobuildme/specs/qa-test-scaffolding/verification/gbm-progress.txt
git commit -m "chore(qa): update progress notes after test review"
```
