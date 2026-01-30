# QA Test Tasks: [PROJECT/FEATURE]

**Input**: Test implementation plan from `.gobuildme/specs/qa-test-scaffolding/qa-test-plan.md`
**Prerequisites**: qa-test-plan.md (required), scaffold-report.md, architecture docs

## Execution Flow (main)
```
1. Load qa-test-plan.md from qa-test-scaffolding directory
   → If not found: ERROR "Run /gbm.qa.plan first"
   → Extract: total tests, priorities, categories
2. Scan all test files for TODO/unimplemented tests
   → Parse test file structure (PHPUnit, pytest, Jest, etc.)
   → Extract test names and locations
   → Match with priority from plan
3. Generate tasks by priority and category:
   → High-priority tests first
   → Medium-priority tests second
   → Low-priority tests last
   → Group by test file for efficiency
4. Apply task rules:
   → Different test files = mark [P] for parallel
   → Same test file = sequential (no [P])
   → Fixtures before tests (if not generated)
5. Number tasks hierarchically (1, 1-1, 1-2, 2, 2-1, etc.)
6. Generate progress tracking section
7. Create task checklist in `.gobuildme/specs/qa-test-scaffolding/qa-test-tasks.md`
8. Return: SUCCESS (ready for /gbm.qa.implement)
```

## Format: `[ID] [P?] Description (File:Line)`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths and line numbers for each test
- Group related tests under parent tasks

## Multi-Level Task Hierarchy
Use hierarchical numbering for complex test files:
- **Level 1**: `1`, `2`, `3` (test file or category)
- **Level 2**: `1-1`, `1-2`, `1-3` (individual tests in file)
- **Level 3**: `1-1-1`, `1-1-2` (test setup steps if complex)

**When to use multi-level breakdown**:
- Test file has many tests (>5)
- Tests share common setup/fixtures
- Tests have dependencies within file

## Task Completion Format
- **Initial State**: All tasks start with `[ ]` (unchecked)
- **Implementation Responsibility**: Mark tasks as `[x]` (checked) ONLY when test implemented and passing
- **Never Pre-check**: Do not create tasks with `[x]` - they must be earned through completion

## Verification Checklist Format

**Each task includes a "Must verify before marking [x]" section** with quality criteria from qa-test-plan.md:

```markdown
- [ ] 5-1 test_login_with_valid_credentials
  - **Location**: tests/integration/api/LoginApiTest.php:42
  - **Requirements**: TR-001 (see qa-test-plan.md for full details)
  - **Must verify before marking [x]**:
    - ✓ Uses AAA pattern (Arrange, Act, Assert)
    - ✓ Mocks external auth provider
    - ✓ Asserts response status AND session created
    - ✓ Runs in <5s
    - ✓ Test passes
```

**Purpose**: Provides clear completion criteria - test is NOT done until ALL criteria met.

**Enforcement**: `/gbm.qa.implement` and `/gbm.qa.review-tests` validate these criteria.

**Quality Standards**: Extracted from Test Requirements (TR-XXX) in qa-test-plan.md.

## Test Implementation Conventions
- **All test files**: Use framework-appropriate test discovery patterns
- **Test naming**: Descriptive names that explain what is being tested
- **Paths**: Relative to repository root (e.g., `tests/integration/api/LoginApiTest.php`)

---

## Phase 1: Generate Fixtures (Optional but Recommended)

**Purpose**: Create reusable test data before implementing tests

**Recommendation**: Run `/gbm.qa.generate-fixtures` to auto-generate from architecture

If generating manually, create these tasks:

- [ ] 1 [P] Generate API request/response fixtures (tests/fixtures/api_fixtures.{ext})
- [ ] 2 [P] Generate database model fixtures (tests/fixtures/database_fixtures.{ext})
- [ ] 3 [P] Generate mock services for external APIs (tests/fixtures/mock_services.{ext})
- [ ] 4 [P] Generate test data sets (valid, invalid, edge cases) (tests/fixtures/test_data.{ext})

**Skip if**: Fixtures already generated or will be created inline with tests

---

## Phase 2: Implement High-Priority Tests

**Purpose**: Implement critical tests first (auth, security, critical paths)

**Estimated**: [N] high-priority tests

### {TEST_FILE_1} (High Priority - e.g., LoginApiTest)
- [ ] 5 Implement {TEST_FILE_1} tests (tests/integration/api/{TEST_FILE_1}.{ext})
  - [ ] 5-1 {TEST_NAME_1} - {BRIEF_DESCRIPTION} (e.g., test_login_with_valid_credentials)
    - **Location**: tests/integration/api/{TEST_FILE_1}.{ext}:42
    - **Requirements**: TR-001 (see qa-test-plan.md)
    - **Must verify before marking [x]**:
      - ✓ Uses AAA pattern (Arrange, Act, Assert)
      - ✓ Mocks external auth provider (no real API calls)
      - ✓ Asserts response status 200 AND session created
      - ✓ Verifies security headers (CSRF token, session cookie)
      - ✓ Cleans up session after test
      - ✓ Runs in <5s
      - ✓ Test passes with clear assertion messages
  - [ ] 5-2 {TEST_NAME_2} - {BRIEF_DESCRIPTION} (e.g., test_login_with_invalid_credentials)
    - **Location**: tests/integration/api/{TEST_FILE_1}.{ext}:58
    - **Requirements**: TR-001 (see qa-test-plan.md)
    - **Must verify before marking [x]**:
      - ✓ Uses AAA pattern
      - ✓ Mocks auth provider to return error
      - ✓ Asserts response status 401
      - ✓ Asserts no session created
      - ✓ Verifies error message is clear
      - ✓ Runs in <5s
      - ✓ Test passes
  - [ ] 5-3 {TEST_NAME_3} - {BRIEF_DESCRIPTION}
  - [ ] 5-4 {TEST_NAME_4} - {BRIEF_DESCRIPTION}
  - [ ] 5-5 {TEST_NAME_5} - {BRIEF_DESCRIPTION}

### {TEST_FILE_2} (High Priority - e.g., UserApiTest)
- [ ] 6 [P] Implement {TEST_FILE_2} tests (tests/integration/api/{TEST_FILE_2}.{ext})
  - [ ] 6-1 {TEST_NAME_1} - {BRIEF_DESCRIPTION} (e.g., test_create_user_with_valid_data)
    - **Location**: tests/integration/api/{TEST_FILE_2}.{ext}:25
    - **Requirements**: TR-002 (see qa-test-plan.md)
    - **Must verify before marking [x]**:
      - ✓ Uses AAA pattern
      - ✓ Tests POST request with valid payload
      - ✓ Asserts response status 201 AND response body structure
      - ✓ Asserts content-type header is application/json
      - ✓ Verifies created resource has expected fields
      - ✓ Mocks database operations (uses fixtures)
      - ✓ Runs in <3s
      - ✓ Test passes
  - [ ] 6-2 {TEST_NAME_2} - {BRIEF_DESCRIPTION}
  - [ ] 6-3 {TEST_NAME_3} - {BRIEF_DESCRIPTION}

### {TEST_FILE_3} (High Priority)
- [ ] 7 [P] Implement {TEST_FILE_3} tests (tests/e2e/critical-paths/{TEST_FILE_3}.{ext})
  - [ ] 7-1 {TEST_NAME_1} - {BRIEF_DESCRIPTION}
  - [ ] 7-2 {TEST_NAME_2} - {BRIEF_DESCRIPTION}

**Continue for all high-priority test files...**

---

## Phase 3: Implement Medium-Priority Tests

**Purpose**: Implement business logic and CRUD tests

**Estimated**: [N] medium-priority tests

### {TEST_FILE_4} (Medium Priority)
- [ ] {ID} [P] Implement {TEST_FILE_4} tests (tests/integration/database/{TEST_FILE_4}.{ext})
  - [ ] {ID}-1 {TEST_NAME_1} - {BRIEF_DESCRIPTION}
  - [ ] {ID}-2 {TEST_NAME_2} - {BRIEF_DESCRIPTION}
  - [ ] {ID}-3 {TEST_NAME_3} - {BRIEF_DESCRIPTION}

### {TEST_FILE_5} (Medium Priority)
- [ ] {ID} [P] Implement {TEST_FILE_5} tests (tests/unit/services/{TEST_FILE_5}.{ext})
  - [ ] {ID}-1 {TEST_NAME_1} - {BRIEF_DESCRIPTION}
  - [ ] {ID}-2 {TEST_NAME_2} - {BRIEF_DESCRIPTION}

**Continue for all medium-priority test files...**

---

## Phase 4: Implement Low-Priority Tests

**Purpose**: Implement edge cases and non-critical tests

**Estimated**: [N] low-priority tests

### {TEST_FILE_6} (Low Priority)
- [ ] {ID} [P] Implement {TEST_FILE_6} tests (tests/integration/external/{TEST_FILE_6}.{ext})
  - [ ] {ID}-1 {TEST_NAME_1} - {BRIEF_DESCRIPTION}
  - [ ] {ID}-2 {TEST_NAME_2} - {BRIEF_DESCRIPTION}

**Continue for all low-priority test files...**

---

## Phase 5: Validation & Quality Check

**Purpose**: Ensure all tests pass and meet quality standards

- [ ] {FINAL_ID-2} Run all tests and verify they pass
  - [ ] {FINAL_ID-2}-1 Run unit tests: `{RUN_UNIT_TESTS_COMMAND}`
  - [ ] {FINAL_ID-2}-2 Run integration tests: `{RUN_INTEGRATION_TESTS_COMMAND}`
  - [ ] {FINAL_ID-2}-3 Run E2E tests: `{RUN_E2E_TESTS_COMMAND}`
  - [ ] {FINAL_ID-2}-4 Verify all tests pass (0 failures, 0 errors)

- [ ] {FINAL_ID-1} Measure test coverage
  - [ ] {FINAL_ID-1}-1 Generate coverage report: `{COVERAGE_COMMAND}`
  - [ ] {FINAL_ID-1}-2 Verify unit test coverage ≥ 90%
  - [ ] {FINAL_ID-1}-3 Verify integration test coverage ≥ 95%
  - [ ] {FINAL_ID-1}-4 Verify E2E test coverage ≥ 80%
  - [ ] {FINAL_ID-1}-5 Verify overall coverage ≥ 85%

- [ ] {FINAL_ID} Validate quality gates (run `/gbm.qa.review-tests`)
  - [ ] {FINAL_ID}-1 Check all tasks in this file are marked [x]
  - [ ] {FINAL_ID}-2 Validate AC traceability is 100%
  - [ ] {FINAL_ID}-3 Verify no skipped tests without documentation
  - [ ] {FINAL_ID}-4 Confirm all tests follow AAA pattern
  - [ ] {FINAL_ID}-5 Check proper mocking of external dependencies

---

## Progress Tracking

**Total Tasks**: {TOTAL_TASKS}

**By Phase**:
- Phase 1 (Fixtures): {N} tasks
- Phase 2 (High Priority): {N} tasks
- Phase 3 (Medium Priority): {N} tasks
- Phase 4 (Low Priority): {N} tasks
- Phase 5 (Validation): {N} tasks

**By Priority**:
- High-priority tests: {N} tasks
- Medium-priority tests: {N} tasks
- Low-priority tests: {N} tasks

**Completion Status**:
```
[ ] 0/{TOTAL_TASKS} complete (0%)
```

*This will be updated automatically as tests are implemented*

---

## Parallel Execution Guidance

Tasks marked with `[P]` can be run in parallel. Here are recommended parallel execution batches:

**Batch 1: High-Priority Test Files** (can run simultaneously)
```bash
# Run in parallel (different test files)
Task 5: {TEST_FILE_1}
Task 6: {TEST_FILE_2}
Task 7: {TEST_FILE_3}
```

**Batch 2: Medium-Priority Test Files** (can run simultaneously)
```bash
# Run in parallel (different test files)
Task {ID}: {TEST_FILE_4}
Task {ID}: {TEST_FILE_5}
```

**Sequential Dependencies**:
- Fixtures (Phase 1) must complete before tests (Phases 2-4)
- Tests within same file must run sequentially
- Validation (Phase 5) must complete last

---

## Task Completion Checklist

**Before marking task complete**:
- [ ] Test implemented following AAA pattern
- [ ] Test passes when run
- [ ] External dependencies properly mocked
- [ ] Test data uses fixtures (not hardcoded)
- [ ] Clear assertion messages
- [ ] Test is independent (no shared state)
- [ ] Docstring/comment explains what test validates

**After task completion**:
- Update task marker: `[ ]` → `[x]`
- Update progress tracking
- Commit changes
- Run tests to verify still passing

---

## Example: Completed Task Checklist

```markdown
# Before (unchecked)
- [ ] 5-1 test_magic_link_authentication_succeeds - Validates magic link login flow

# After implementation (checked)
- [x] 5-1 test_magic_link_authentication_succeeds - Validates magic link login flow
```

---

## Dependencies Between Tasks

**Fixture Generation → Test Implementation**:
- If fixtures are generated (Phase 1), tests in Phases 2-4 can use them
- If skipping Phase 1, tests must create their own test data inline

**Test Priority Order**:
- High-priority tests (Phase 2) can be implemented independently
- Medium-priority tests (Phase 3) can be implemented independently
- Low-priority tests (Phase 4) can be implemented independently
- Within same test file, tests must be implemented sequentially

**Validation Dependencies**:
- All test implementation tasks (Phases 2-4) must complete before validation (Phase 5)

---

## Quality Gates

**Task Completion Gate** (enforced by `/gbm.qa.review-tests`):
- ✅ All tasks marked [x] (no `[ ]` remaining)
- ✅ Progress tracking shows 100%
- ✅ All tests passing

**Coverage Gate** (enforced by `/gbm.qa.review-tests`):
- ✅ Unit test coverage ≥ 90%
- ✅ Integration test coverage ≥ 95%
- ✅ E2E test coverage ≥ 80%
- ✅ Overall coverage ≥ 85%

**Quality Gate** (enforced by `/gbm.qa.review-tests`):
- ✅ AC traceability 100%
- ✅ No skipped tests without documentation
- ✅ All tests follow AAA pattern
- ✅ External dependencies mocked

---

*Next Step*: Run `/gbm.qa.implement` to start systematic test implementation
