---
description: "Run test suite, validate coverage against thresholds, and fill any coverage gaps. Tests should already exist from TDD during /gbm.implement. Updates tasks.md to mark Testing Validation phase tasks (T1-T3) as complete."
scripts:
  sh: scripts/bash/run-tests.sh --json
  ps: scripts/powershell/run-tests.ps1 -Json
artifacts:
  - path: ".gobuildme/test-results/quality-review.md"
    description: "Test quality review results with coverage analysis and AC traceability validation"
  - path: "tests/"
    description: "Test suite directory with acceptance, unit, integration, and E2E tests"
  - path: "$FEATURE_DIR/tasks.md"
    description: "Updated task breakdown with Testing Validation tasks (T1-T3) marked complete"
  - path: ".gobuildme/test-results/<feature>/test-output.md"
    description: "Full test runner output: all test results, verbose logs, stack traces (Tier 2 detail artifact)"
---

## Output Style Requirements (MANDATORY)

**Test Generation Output**:
- One test function per AC - no combined tests
- Test names must be self-documenting (no docstrings repeating the name)
- No comments inside test bodies unless testing complex logic
- Fixtures over inline setup - DRY test data

**Test Report Output**:
- Coverage numbers in table format
- Failed tests as list: test_name | reason | file:line
- No prose summaries of what tests do

**AC Coverage Report**:
- Table format: AC-ID | test file | status (covered/missing)
- No explanations of why tests were written

**Two-Tier Output Enforcement (Issue #51)**:
- **Progress summary first**: "✅ X/Y passing | Coverage: N%" before any details
- Do NOT paste raw test runner output, full stack traces, or verbose logs to CLI
- Write full output to: `.gobuildme/test-results/<feature>/test-output.md`
- CLI shows: progress summary + suite table + "Full output: `<path>`"
- Max 5 failed tests shown inline; if more → "See `.gobuildme/test-results/<feature>/test-output.md` for N more failures"
- Stack traces go to detail artifact; CLI shows one-line failure reason only

For complete style guidance, see .gobuildme/templates/_concise-style.md

You are the Tests Command. Your job is to validate the test suite created during /gbm.implement (TDD cycle), run all tests, enforce coverage thresholds, and fill any coverage gaps. Tests should already exist from TDD - this command validates completeness and quality.

**Note**: This command is feature-scoped (tests for a specific feature). For bootstrapping test structure for existing projects without tests, use `/gbm.qa.scaffold-tests` instead.

**Persona Context**: Loaded in step 2 with participants support. Multiple personas may be active (driver + participants), and their requirements are merged.

---

## Step 0: Orientation (MANDATORY — DO THIS FIRST)

Before ANY work, establish context by running these commands:

```bash
# 1. Resolve repo root (works from any subdirectory)
# Try git first, fallback to searching for .gobuildme/manifest.json
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
  # Non-git project: search upward for .gobuildme/manifest.json
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

# 2. Verify GoBuildMe project structure
if [ -d "$REPO_ROOT/.gobuildme/specs/" ]; then
    ls -la "$REPO_ROOT/.gobuildme/specs/"
else
    echo "No specs directory yet (run /gbm.request first)"
fi

# 3. Read progress notes (CRITICAL) — tolerant of missing file
cat "$FEATURE_DIR/verification/gbm-progress.txt" 2>/dev/null || echo "No progress file yet"

# 4. Review git history
if git rev-parse --git-dir >/dev/null 2>&1; then
    git log --oneline -15
else
    echo "Not a git repository - skipping git history"
fi

# 5. Load task status
cat "$FEATURE_DIR/tasks.md" 2>/dev/null | head -100

# 6. Count remaining work
grep -c "^\- \[ \]" "$FEATURE_DIR/tasks.md" 2>/dev/null || echo "0"
```

**DO NOT proceed until you understand**:
- What was completed in previous sessions
- What task you should work on next
- Any blockers or issues to be aware of

**If progress notes exist**: Resume from where the previous session left off.
**If no progress notes**: This is the first session — proceed normally and create progress notes at session end.

---

## Step 0.2: Branch Guard (MANDATORY — Before Any Commits)

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
3. **DO NOT proceed with testing until on a feature branch**

**Why this matters**: The harness system requires commits at session end. Without this guard, commits would land on main.

**Inline usage** (before each commit in this template):
- Bash: `.gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1`
- PowerShell: `.gobuildme/scripts/powershell/guard-protected-branch.ps1 -Quiet; if ($LASTEXITCODE -ne 0) { exit 1 }`

---

## Step 0.5: Smoke Test (MANDATORY — Before Starting Work)

**Purpose**: Verify existing tests pass before running test validation.

```bash
# Detect and run project test command
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
    echo "No standard test command detected - will discover during validation"
fi
```

**If tests FAIL at session START**:
1. Check if failures are from the current feature or pre-existing
2. If pre-existing: Document in progress notes, may need to fix first
3. If from current feature: This is expected - proceed with test validation

**If tests PASS**: Proceed with test validation.

---

Follow this exact flow:

**Script Output Variables**: The `{SCRIPT}` output above provides key paths. Parse and use these values:
- `FEATURE_DIR` - Feature directory path (e.g., `.gobuildme/specs/<feature>/` or `.gobuildme/specs/epics/<epic>/<slice>/`)
- `AVAILABLE_DOCS` - List of available documentation files in the feature directory

1) Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.tests" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2) **Load Persona Configuration** (with Participants Support):

   **Load feature persona file**:
   - Read `$FEATURE_DIR/persona.yaml`
   - Extract `feature_persona` (driver persona ID)
   - Extract `participants` (list of participant persona IDs, may be empty list or missing field)
   - If file missing, fall back to `default_persona` from `.gobuildme/config/personas.yaml`

   **Build active personas list**:
   - Active personas = [driver] + participants
   - Example: If driver=`backend_engineer` and participants=`[security_compliance, sre]`
   - Then active_personas = `[backend_engineer, security_compliance, sre]`
   - If participants empty or missing: active_personas = [driver] only

   **Merge required sections for /tests**:
   - For each persona in active_personas:
     * Read `.gobuildme/personas/<persona_id>.yaml`
     * Extract `required_sections["/tests"]` (may not exist for all personas)
     * Collect all sections into merged list
   - Ensure persona-specific testing requirements are addressed in test plan
   - Example merged sections:
     * Backend Engineer: ["Contract Tests", "Integration Tests", "Performance Budgets"]
     * Security: ["Security Tests", "Compliance Validation"]
     * QA Engineer: ["Coverage Gaps", "AC Traceability"]
     * Result: All sections required in test coverage report

   **Compute coverage threshold** (highest wins):
   - For each persona in active_personas:
     * Read `.gobuildme/personas/<persona_id>.yaml`
     * Extract `defaults.coverage_floor` (e.g., 0.85 = 85%)
     * Track the maximum value
   - Apply max(all coverage_floor values) as effective threshold
   - Example: backend=0.85, security=0.0, sre=0.0 → Use 85%
   - If no personas have coverage_floor: Fall back to 85% default
   - Store as `$COVERAGE_THRESHOLD` for use in step 7

   **Include persona partials**:
   - For each persona in active_personas:
     * If `templates/personas/partials/<persona_id>/tests.md` exists:
       - Include its content under a `### <Persona Name> Testing Requirements` section
   - If no persona files exist, proceed as generalist

   **Error Handling**:
   - If participant persona file missing: Skip with warning, continue with remaining personas
   - If driver persona file missing: Fall back to default_persona
   - If no valid personas found: Proceed as generalist with 85% default coverage

   **Validation**:
   - Report which personas are active (driver + participants)
   - Show merged required sections grouped by persona
   - Display effective coverage threshold and which persona set it

3) **Load All Available Context** (for test generation):

   **3a. Feature-Specific Artifacts** (from request/specify/clarify/plan phases):
   - `$FEATURE_DIR/spec.md` - **REQUIRED** - Acceptance Criteria structure and requirements
   - `$FEATURE_DIR/plan.md` - **REQUIRED** - Technology stack, Coverage Threshold, test structure
   - `$FEATURE_DIR/request.md` - Original user request and context (optional)
   - `$FEATURE_DIR/quickstart.md` - Integration scenarios for integration tests (if exists)
   - `$FEATURE_DIR/data-model.md` - Entity definitions for fixture generation (if exists)
   - `$FEATURE_DIR/contracts/` - API endpoint specifications for contract tests (if exists)
   - `$FEATURE_DIR/docs/references/` - External documentation summaries (if exists)
     * Confluence pages, technical docs, API specs, design docs
     * Fetched during specify phase via WebFetch
     * Non-blocking if directory doesn't exist or is empty

   **3b. Architecture Documentation** (MANDATORY for existing codebases):

   **Root Resolution** (for monorepo/workspace support):
   - Source `common.sh` and call `get_architecture_dirs()` to get ordered list of architecture directories
   - Search order: module-level first → workspace/monorepo root second
   - Example: In monorepo module, checks `apps/api/.gobuildme/docs/technical/architecture/` then `<root>/.gobuildme/docs/technical/architecture/`

   **Architecture files to load** (from each discovered architecture directory):
   - `system-analysis.md` - Architectural patterns, boundaries, layering rules
   - `technology-stack.md` - Languages, frameworks, test runners, testing patterns
   - `security-architecture.md` - Auth patterns, security controls for security tests
   - `integration-landscape.md` - External service integrations for integration tests (if exists)
   - `$FEATURE_DIR/docs/technical/architecture/feature-context.md` - Feature-specific architectural context (if exists)

   **BLOCKING**: If codebase exists but no architecture files found in any searched directory:
   - Stop execution
   - Display: "❌ Architecture documentation required. Run `/gbm.architecture` first."
   - Do not proceed until documentation exists

   **Skip for**: New/empty projects with no existing source code.

   **3c. Governance & Principles** (NON-NEGOTIABLE):

   **Constitution Resolution** (for monorepo/workspace support):
   - Source `common.sh` and call `get_constitution_path()` to get constitution location
   - Constitution is ALWAYS at workspace/monorepo root (not per-module)

   - Constitution file contains organizational rules, security requirements, compliance constraints
   - **CRITICAL**: Constitution defines non-negotiable principles for test design
   - Security and compliance requirements from constitution must be reflected in test coverage
   - Any test design that conflicts with constitution must be rejected or revised

4) Detect test infrastructure and repository conventions:
   - Run {SCRIPT} once to detect repo language(s), test runner(s), and CI context
   - Parse the JSON for `detected` info but ignore `results` for now
   - Identify existing test structure, naming conventions, and fixture patterns

5) **TDD Prerequisite Check** (MANDATORY - Validates TDD Contract):

   **Check for Existing Tests** (from /gbm.implement TDD cycle):
   - Check if test directory exists (e.g., `tests/`, `test/`, `__tests__/` based on language)
   - Count existing test files matching repository patterns
   - Verify tests were created during implementation phase (TDD RED-GREEN cycle)

   **If NO tests found or test directory empty**:
   - 🔴 **WARNING**: "No tests found. TDD contract violated."
   - **Expected behavior**: Tests should have been created FIRST during `/gbm.implement` (Phase 2 - RED)
   - **Recommendation**:
     * "Return to `/gbm.implement` and follow TDD: write tests first (RED), then implement code (GREEN)"
     * "Tests created at this stage violate TDD principles and should be avoided"
   - **User Decision Required**:
     * Option A (RECOMMENDED): Stop and return to `/gbm.implement` with proper TDD
     * Option B: Continue and generate tests now (NOT recommended - violates TDD contract)

   **If tests exist** (expected path):
   - ✅ Proceed with test validation and coverage enforcement
   - Note: This command will fill coverage gaps, not create primary test suite

6) **Test Validation and Coverage Gap Filling** (MANDATORY):

   **PRIMARY: Validate Existing Tests** (created during /gbm.implement TDD cycle):
   - Scan existing test suite structure and organization
   - Identify test coverage patterns and naming conventions
   - Validate tests follow architectural patterns and technology stack conventions
   - Map existing tests to acceptance criteria (AC traceability)
   - Identify coverage gaps by comparing existing tests against ACs

   **SECONDARY: Fill Coverage Gaps** (only if gaps identified):

   Add missing tests ONLY for uncovered acceptance criteria:
   - **Acceptance Criteria Gap Tests**: Add tests for ACs without coverage:
     * **Happy Path Tests**: One test per uncovered AC-XXX in `tests/acceptance/happy-path/`
     * **Error Handling Tests**: One test per uncovered AC-EXX in `tests/acceptance/error-handling/`
     * **Edge Case Tests**: One test per uncovered AC-BXX in `tests/acceptance/edge-cases/`
     * **Performance Tests**: One test per uncovered AC-PXX in `tests/acceptance/performance/`
     * **Security Tests**: One test per uncovered AC-SXX in `tests/acceptance/security/`
   - **Contract Tests**: Add only if endpoints lack contract test coverage
   - **Integration Tests**: Add only if scenarios from `quickstart.md` lack coverage
   - **Unit Tests**: Add only for critical logic paths missing tests

   **Architecture-Specific Gap Filling**:
   - **Boundary Tests**: Add if architectural boundaries lack validation tests
   - **Integration Point Tests**: Add if system integration points lack coverage
   - **Security Architecture Tests**: Add if security patterns lack validation tests
   - **Technology Stack Tests**: Use frameworks and patterns from documented technology stack

   **Gap-Filling Guidelines**:
   - Respect existing naming, layout, and fixture patterns
   - New tests should verify actual implementation behavior (not theoretical RED state)
   - Map each new test to its corresponding AC ID for traceability
   - Minimize new test creation - only add what's genuinely missing

7) Run the suite
   - If DevSpace is present and a `run test` task exists, prefer `devspace run test`.
   - Then execute {SCRIPT} to run all tests on the host as a fallback or complement. If runner/coverage tools are not present, propose minimal setup in the plan, but still run what's available.

8) Acceptance Criteria coverage validation
   - Verify that every AC in `spec.md` has a corresponding test case
   - Generate AC coverage report showing which criteria are tested
   - Flag any untested acceptance criteria as coverage gaps

9) Coverage gate
   - Use `$COVERAGE_THRESHOLD` computed in step 2 (highest coverage_floor from all active personas)
   - If coverage threshold not computed: fall back to plan.md "Coverage Threshold" or default to 85%
   - If coverage is below threshold, add more tests focused on the lowest-covered areas and rerun
   - Ensure AC coverage is 100% (every acceptance criterion must have at least one test)
   - Report which persona set the threshold (e.g., "Backend Engineer requires 85% coverage")

10) **Update Verification Matrix** (MANDATORY if matrix exists):

   **Check for verification matrix**:
   ```bash
   MATRIX_FILE="$FEATURE_DIR/verification/verification-matrix.json"
   if [ -f "$MATRIX_FILE" ]; then
       echo "Found verification matrix: $MATRIX_FILE"
       cat "$MATRIX_FILE"
   else
       echo "No verification matrix found - skipping (optional)"
   fi
   ```

   **If verification matrix exists, update it**:
   - The verification matrix was created during `/gbm.tasks` (if opted in) with all acceptance criteria
   - Each item has `"passes": false` initially - YOUR JOB is to update them based on test results
   - For EACH verification item in the matrix:
     1. Find the corresponding test(s) that verify that AC
     2. Check if the test PASSES (from step 7 test run results)
     3. If test passes: Update `"passes": true`, `"verified_at"`, and `"verification_evidence"`
     4. If test fails or doesn't exist: Leave `"passes": false`

   **Update matrix JSON** (matches schema from /gbm.tasks):
   ```json
   {
     "verification_items": [
       {
         "id": "V1",
         "type": "acceptance_criteria",
         "description": "AC-001: Addition returns correct sum",
         "verification_method": { "type": "builtin", "ref": "run_tests" },
         "passes": true,
         "verified_at": "2025-01-15T10:30:00Z",
         "verified_in_session": "session-abc123",
         "verification_evidence": "test_addition_happy_path (tests/unit/test_operations.py) PASSED"
       }
     ]
   }
   ```

   **Commit matrix update** (with branch guard):
   ```bash
   # Verify not on protected branch before committing
   .gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1
   git add "$MATRIX_FILE"
   git commit -m "chore(<feature>): update verification matrix - X/Y ACs verified"
   ```

   **If no matrix exists**: Skip this step (matrix is optional, created during `/gbm.tasks` (if opted in) for traceability).

11) CI integration
   - If no CI workflow exists to run the tests on PRs, add `.github/workflows/tests.yml` that executes the project's test runner with coverage and enforces the threshold
   - Include AC coverage validation in CI pipeline

12) Quality Review (AUTOMATIC)
   - After tests pass, automatically run `/gbm.qa.review-tests` to validate test quality
   - This checks:
     * Test structure (unit/, integration/, e2e/ directories)
     * Remaining TODO tests
     * Coverage thresholds
     * AC traceability (100% coverage goal)
   - Review results are saved to `.gobuildme/test-results/quality-review.md`
   - If quality review fails, address issues before proceeding

13) Output
   - Summarize files created/updated and final coverage
   - Report AC coverage statistics (X/Y acceptance criteria covered)
   - List any untested acceptance criteria that need attention
   - Display quality review results
   - Provide the exact command(s) to run the suite locally.
   - Suggest a commit message (e.g., `test: add contract/integration/unit tests for <feature> (≥<threshold>% coverage)`).

---

## CRITICAL: Test Quality Guidelines (Prevents Hallucinated Tests)

### Rule: Tests MUST verify REAL behavior, not imaginary code

**Before adding or updating tests in `/gbm.tests`, verify:**

1. **The code being tested actually exists**:
   - Locate the symbol or file in the repo (don’t guess names/paths)
   - Example:
     ```bash
     rg -n "FunctionName|ClassName" src/ lib/ app/ 2>/dev/null
     ```

2. **Imports and module paths are real**:
   - Read the source file first
   - Use the exact function signatures and import paths

3. **Tests can be collected/executed in your stack**:
   - Use the repo’s standard test command
   - Examples (choose what matches the project):
     - Python: `pytest path/to/test.py -q --collect-only`
     - JS/TS: `npm test -- --listTests` (or framework equivalent)
     - Go: `go test ./...`
     - Java: `mvn -q -Dtest=ClassName test` (or Gradle equivalent)

### ❌ HALLUCINATED TESTS (Never do these):
- Testing functions that don’t exist
- Using import paths that don’t match the repo
- Asserting behavior that wasn’t implemented
- Placeholder assertions like `assert True`
- Mocking symbols that don’t exist or have different signatures

### ✅ QUALITY TESTS:
- Read the source first, then write the test
- Use exact function names/signatures from code
- Assert real behavior with specific, meaningful checks

### Test Quality Metrics

Before marking `/gbm.tests` complete, verify:

| Metric | Requirement |
|--------|-------------|
| Tests execute | Tests can be collected and run |
| No import errors | Imports resolve to real modules |
| No missing symbols | Methods being called exist |
| Meaningful assertions | No placeholders |
| Matches implementation | Test behavior matches code |

**Why this matters**: Hallucinated tests provide false confidence. They pass but don’t verify real behavior.

---

Rules and conventions
- Follow the repository's Codebase Profile and Compatibility Constraints from the plan.
- Keep tests small, deterministic, and isolated; prefer dependency injection over global state.
- Use existing fixtures/mocks when present; add new ones under the repo's testing conventions.

## Persona-Aware Next Steps

**Detecting Persona** (always do this):
1. Read: `.gobuildme/config/personas.yaml` → check `default_persona` field
2. Store the value in variable: `$CURRENT_PERSONA`
3. If file doesn't exist or field not set → `$CURRENT_PERSONA = null`

**Test Quality Gates** (check first):
- ✅ Coverage meets persona-specific threshold
- ✅ All tests pass
- ✅ Quality review passes

13) **Mark Testing Validation Tasks Complete** (MANDATORY):

   **NOTE**: This command updates `$FEATURE_DIR/tasks.md` to mark Testing Validation
   tasks as complete. This is expected behavior - /gbm.tests is a "doing work" command that creates
   test files and validates test quality, parallel to /gbm.implement which marks implementation tasks.

   - Load tasks.md from FEATURE_DIR
   - Find all Phase 8 (Testing Validation) tasks (tasks starting with T1, T2, T3)
   - Mark each Testing Validation task as complete by changing `[ ]` to `[x]`
   - Save updated tasks.md
   - Report: "✅ Marked X Testing Validation tasks complete in tasks.md"

   **Testing Validation tasks to mark complete**:
   - T1: Run full test suite and verify all tests pass
   - T2: Validate test coverage meets requirements
   - T3: Validate test quality

   **Why mark these complete**: The /gbm.tests command runs the full test suite, validates coverage,
   and performs quality checks, so these tasks are inherently completed by running this command successfully.

**Persona-Specific Next Steps** (display based on $CURRENT_PERSONA):

| Persona | Coverage | Next Command | Key Focus (if gates fail) |
|---------|----------|--------------|---------------------------|
| backend_engineer | 85% | /gbm.review | API contracts, DB ops, business logic |
| frontend_engineer | 85% | /gbm.review | Component tests, a11y, visual regression |
| fullstack_engineer | 85% | /gbm.review | E2E flows, API+UI integration |
| qa_engineer | 90/95/80% | /gbm.qa.review-tests | Coverage gaps, AC traceability |
| data_engineer | 80% | /gbm.review | Pipeline tests, data validation |
| data_scientist | 70% | /gbm.review | Statistical tests, reproducibility |
| ml_engineer | 75% | /gbm.review | Model tests, inference validation |
| sre | 80% | /gbm.review | Chaos tests, load tests, failover |
| security_compliance | 90% | /gbm.review | Security tests, compliance validation |
| architect | — | /gbm.analyze | ADRs, boundary checks, NFR validation |
| product_manager | — | /gbm.review | Business requirements validation |
| maintainer | — | /gbm.review | PR quality, tech debt, release notes |
| null (not set) | 85% | /gbm.persona | Set persona first for guidance |

**For extended guidance**: Read `.gobuildme/templates/reference/persona-next-steps.md` for detailed focus areas, quality gate requirements, and remediation steps per persona.

**For Legacy Projects**: Use `/gbm.qa.scaffold-tests` to bootstrap test structure first

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
14) Track command complete and trigger auto-upload:
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-tests` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/post-command-hook.sh --command "gbm.tests" --status "success|failure" --command-id "$command_id" --feature-dir "$SPEC_DIR" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - This handles both telemetry tracking AND automatic spec upload (if enabled in manifest)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

## Optional: Spec Repository Upload

After updating `tasks.md` with Testing Validation completion markers (T1-T3), you can optionally upload the spec directory:

→ `/gbm.upload-spec` - Upload specs to S3 for cross-project analysis and centralized storage

*Requires AWS credentials. Use `--dry-run` to validate access first.*

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Core workflow:**
→ `/gbm.review` (comprehensive quality gate - Phase 9)

**Optional preflight check:**
- `/gbm.preflight` — Quick validation (lint, type, tests, coverage) before formal review

**Not ready?**
- Fix failing tests by correcting test code or implementation
- Re-run `/gbm.implement` if implementation needs fixes
- Manually edit test files to improve coverage
- Re-run `/gbm.tests` to regenerate tests from updated spec

---

## Final Step: Clean State Validation & Progress Notes (MANDATORY)

Before ending this session, you MUST ensure clean state AND update progress notes.

### Part 1: Clean State Checklist (REQUIRED before stopping)

```bash
# 1. Check for uncommitted changes
echo "=== Git Status ==="
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo "❌ UNCOMMITTED CHANGES - commit or stash before stopping"
    git status --short
else
    echo "✓ Clean - no uncommitted changes"
fi

# 2. Final test run to confirm all pass
echo "=== Final Test Run ==="
if [ -f "$REPO_ROOT/package.json" ]; then
    npm test && echo "✓ All tests pass" || echo "❌ Tests failing"
elif [ -f "$REPO_ROOT/pyproject.toml" ]; then
    pytest && echo "✓ All tests pass" || echo "❌ Tests failing"
elif [ -f "$REPO_ROOT/Makefile" ] && grep -q "^test:" "$REPO_ROOT/Makefile"; then
    make test && echo "✓ All tests pass" || echo "❌ Tests failing"
fi
```

### ❌ NEVER end session with:
- Uncommitted changes
- Failing tests
- Outdated progress notes

### ✅ ALWAYS end session with:
- Clean `git status`
- All tests passing
- Progress notes capturing session work

---

### Part 2: Update Progress Notes

1. **Create or Update Progress File** at `$FEATURE_DIR/verification/gbm-progress.txt`:
   - If file doesn't exist: Create it using the template at `.gobuildme/templates/gbm-progress-template.md`
     * Replace placeholders: `{{FEATURE_NAME}}`, `{{PERSONA_ID}}`, `{{PARTICIPANT_PERSONAS}}`
     * Set initial task counts from tasks.md
   - Add new session entry at TOP of Session History section (follow template instructions)
   - Update Summary section with current task counts

2. **Session Entry Content** (add for each session):
   - Session number and timestamp
   - Status (in-progress, completed, blocked)
   - Current phase (Testing Validation)
   - Tasks completed this session (T1, T2, T3 testing tasks)
   - Issues encountered and resolutions
   - Verification results (coverage %, tests passed)
   - Next steps in priority order
   - Notes for next session (important context)

3. **Commit Progress Notes** (with branch guard):
   ```bash
   # Verify not on protected branch before committing
   .gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1
   git add $FEATURE_DIR/verification/gbm-progress.txt
   git commit -m "chore(<feature>): update progress notes - session N"
   ```

**Why this matters**: Progress notes enable the next agent/session to resume exactly where you left off without wasting tokens rediscovering state.
