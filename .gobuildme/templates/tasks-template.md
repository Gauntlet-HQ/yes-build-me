# Tasks: [FEATURE NAME]

**Input**: Design documents from `.gobuildme/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Task Scope (PR Slice Only)

> **Rule**: This `tasks.md` must be completable within a single PR slice. Do NOT include work intended for future PRs; list those under “Deferred”.

- Epic Link: [URL or ticket id] (optional)
- Epic Name: [Name] (optional)
- PR Slice: [standalone | 1/N | 2/N | ...]

### This PR Delivers (In-Scope)
- [Deliverable 1]
- [Deliverable 2]

### Deferred to Future PRs (Do Not Implement Here)
- [PR-2: deferred item]
- [PR-3: deferred item]

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs, implementation documentation
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Multi-Level Task Hierarchy
Use hierarchical numbering for complex tasks requiring subtasks:
- **Level 1**: `1`, `2`, `3` (main tasks)
- **Level 2**: `1-1`, `1-2`, `1-3` (subtasks)
- **Level 3**: `1-1-1`, `1-1-2`, `1-1-3` (sub-subtasks)
- **Level 4**: `1-1-1-1`, `1-1-1-2` (detailed subtasks)
- **Continue as needed**: Add more levels only when complexity requires it

**When to use multi-level breakdown**:
- Complex features requiring multiple components
- Tasks with multiple implementation steps
- Dependencies between subtasks
- Different skill sets or file areas involved

## Task Completion Format
- **Initial State**: All tasks start with `[ ]` (unchecked)
- **Agent Responsibility**: Mark tasks as `[x]` (checked) ONLY when completed
- **Never Pre-check**: Do not create tasks with `[x]` - they must be earned through completion
## Path Conventions
- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

## Phase Gates
Tasks are organized into phases with completion gates:
- **Phase 1 → Phase 2**: All analysis tasks must be `[x]` before setup begins
- **Phase 2 → Phase 3**: All setup tasks must be `[x]` before tests
- **Phase 3 → Phase 4**: All tests must be written and failing before implementation
- **Phase 4 → Phase 5**: All implementation tasks must be `[x]` before integration
- **Phase 5 → Phase 6**: All integration tasks must be `[x]` before polish
- **Phase 6 → Phase 7**: All polish tasks must be `[x]` before reliability
- **Phase 7 → Phase 8**: All reliability tasks must be `[x]` before testing validation
- **Phase 8 → Phase 9**: All tests must pass before review
- **Phase 9 → Phase 10**: All review tasks must be `[x]` before release
- **Phase 10 Complete**: All release tasks must be `[x]` before push

## Phase 1: Analysis (/gbm.analyze)
**Purpose**: Validate requirements and architecture before implementation
**Gate**: All tasks `[x]` before proceeding to Setup

- [ ] A1 Fact-check: Verify all requirements are documented and clear
  - [ ] A1-1 Load all design documents (plan.md, data-model.md, contracts/, research.md)
  - [ ] A1-2 Verify tech stack is documented in plan.md
  - [ ] A1-3 Check all entities have schema definitions
  - [ ] A1-4 Verify all API endpoints have contracts
- [ ] A2 Fact-check: Validate architecture compliance
  - [ ] A2-1 Load .gobuildme/memory/constitution.md
  - [ ] A2-2 Check architecture patterns match constitution
  - [ ] A2-3 Verify no forbidden couplings in design
  - [ ] A2-4 Validate layering rules are respected
- [ ] A3 Fact-check: Verify design completeness
  - [ ] A3-1 All user stories have corresponding test scenarios
  - [ ] A3-2 All error cases are documented
  - [ ] A3-3 Security requirements are specified
  - [ ] A3-4 Performance requirements are defined

## Phase 2: Setup
- [ ] 1 {TASK_DESCRIPTION}
  - [ ] 1-1 {SUBTASK_DESCRIPTION}
  - [ ] 1-2 {SUBTASK_DESCRIPTION}
- [ ] 2 {TASK_DESCRIPTION}
  - [ ] 2-1 {SUBTASK_DESCRIPTION}
  - [ ] 2-2 {SUBTASK_DESCRIPTION}
  - [ ] 2-3 {SUBTASK_DESCRIPTION}
- [ ] 3 [P] {TASK_DESCRIPTION}
  - [ ] 3-1 {SUBTASK_DESCRIPTION}
  - [ ] 3-2 {SUBTASK_DESCRIPTION}
  - [ ] 3-3 {SUBTASK_DESCRIPTION}

## Phase 3: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE PHASE 4
**Purpose**: Write failing tests (TDD) before any implementation
**Gate**: All tests must be written and FAILING before proceeding to Implementation
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [ ] 4 [P] {TASK_DESCRIPTION}
  - [ ] 4-1 {SUBTASK_DESCRIPTION}
    - [ ] 4-1-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 4-1-2 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 4-1-3 {SUB_SUBTASK_DESCRIPTION}
  - [ ] 4-2 {SUBTASK_DESCRIPTION}
    - [ ] 4-2-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 4-2-2 {SUB_SUBTASK_DESCRIPTION}
- [ ] 5 [P] {TASK_DESCRIPTION}
  - [ ] 5-1 {SUBTASK_DESCRIPTION}
    - [ ] 5-1-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 5-1-2 {SUB_SUBTASK_DESCRIPTION}
  - [ ] 5-2 {SUBTASK_DESCRIPTION}
    - [ ] 5-2-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 5-2-2 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 5-2-3 {SUB_SUBTASK_DESCRIPTION}

## Phase 4: Core Implementation (ONLY after tests are failing)
**Purpose**: Implement features to make tests pass
**Gate**: All implementation tasks `[x]` before proceeding to Integration
- [ ] 6 [P] {TASK_DESCRIPTION}
  - [ ] 6-1 {SUBTASK_DESCRIPTION}
    - [ ] 6-1-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 6-1-2 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 6-1-3 {SUB_SUBTASK_DESCRIPTION}
  - [ ] 6-2 {SUBTASK_DESCRIPTION}
    - [ ] 6-2-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 6-2-2 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 6-2-3 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 6-2-4 {SUB_SUBTASK_DESCRIPTION}
- [ ] 7 {TASK_DESCRIPTION}
  - [ ] 7-1 {SUBTASK_DESCRIPTION}
    - [ ] 7-1-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 7-1-2 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 7-1-3 {SUB_SUBTASK_DESCRIPTION}
  - [ ] 7-2 {SUBTASK_DESCRIPTION}
    - [ ] 7-2-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 7-2-2 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 7-2-3 {SUB_SUBTASK_DESCRIPTION}
- [ ] 8 [P] {TASK_DESCRIPTION}
  - [ ] 8-1 {SUBTASK_DESCRIPTION}
  - [ ] 8-2 {SUBTASK_DESCRIPTION}
  - [ ] 8-3 {SUBTASK_DESCRIPTION}
- [ ] 9 {TASK_DESCRIPTION}
  - [ ] 9-1 {SUBTASK_DESCRIPTION}
  - [ ] 9-2 {SUBTASK_DESCRIPTION}
  - [ ] 9-3 {SUBTASK_DESCRIPTION}

## Phase 5: Integration
**Purpose**: Integrate components and add middleware/infrastructure
**Gate**: All integration tasks `[x]` before proceeding to Polish
- [ ] 10 {TASK_DESCRIPTION}
  - [ ] 10-1 {SUBTASK_DESCRIPTION}
    - [ ] 10-1-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 10-1-2 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 10-1-3 {SUB_SUBTASK_DESCRIPTION}
  - [ ] 10-2 {SUBTASK_DESCRIPTION}
    - [ ] 10-2-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 10-2-2 {SUB_SUBTASK_DESCRIPTION}
- [ ] 11 {TASK_DESCRIPTION}
  - [ ] 11-1 {SUBTASK_DESCRIPTION}
    - [ ] 11-1-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 11-1-2 {SUB_SUBTASK_DESCRIPTION}
  - [ ] 11-2 {SUBTASK_DESCRIPTION}
    - [ ] 11-2-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 11-2-2 {SUB_SUBTASK_DESCRIPTION}
- [ ] 12 {TASK_DESCRIPTION}
  - [ ] 12-1 {SUBTASK_DESCRIPTION}
  - [ ] 12-2 {SUBTASK_DESCRIPTION}
  - [ ] 12-3 {SUBTASK_DESCRIPTION}

## Phase 6: Polish
**Purpose**: Add unit tests, performance optimization, and documentation
**Gate**: All polish tasks `[x]` before proceeding to Reliability
- [ ] 13 [P] {TASK_DESCRIPTION}
  - [ ] 13-1 {SUBTASK_DESCRIPTION}
    - [ ] 13-1-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 13-1-2 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 13-1-3 {SUB_SUBTASK_DESCRIPTION}
  - [ ] 13-2 {SUBTASK_DESCRIPTION}
    - [ ] 13-2-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 13-2-2 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 13-2-3 {SUB_SUBTASK_DESCRIPTION}
- [ ] 14 [P] {TASK_DESCRIPTION}
  - [ ] 14-1 {SUBTASK_DESCRIPTION}
    - [ ] 14-1-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 14-1-2 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 14-1-3 {SUB_SUBTASK_DESCRIPTION}
  - [ ] 14-2 {SUBTASK_DESCRIPTION}
    - [ ] 14-2-1 {SUB_SUBTASK_DESCRIPTION}
    - [ ] 14-2-2 {SUB_SUBTASK_DESCRIPTION}
- [ ] T022 Remove duplication
- [ ] T023 Run manual-testing.md
- [ ] T024 Create comprehensive implementation documentation in .docs/implementations/<feature>/implementation-summary.md

## Phase 7: Reliability & Observability
**Purpose**: Add monitoring, SLOs, alerts, and observability
**Gate**: All reliability tasks `[x]` before proceeding to Testing Validation
- [ ] R1 Create `slo.yaml` under `.gobuildme/specs/[###-feature-name]/` from `templates/slo-template.yaml` and customize
- [ ] R2 Wire metrics/logs/traces for SLIs; update dashboards and runbooks
- [ ] R3 Add alert burn‑rate tiers and test notifications
- [ ] R4 Run `.gobuildme/scripts/bash/slo-lint.sh` and fix schema issues
- [ ] R5 In CI, publish `slo-report.json` via `.gobuildme/scripts/bash/slo-synthetic.sh`

## Phase 8: Testing Validation (/gbm.tests)
**Purpose**: Run comprehensive test suite and validate quality
**Gate**: All tests must PASS before proceeding to Review

- [ ] T1 Run full test suite and verify all tests pass
  - [ ] T1-1 Execute unit tests with coverage reporting
  - [ ] T1-2 Execute integration tests
  - [ ] T1-3 Execute end-to-end tests (if applicable)
  - [ ] T1-4 Verify no test failures or errors
- [ ] T2 Validate test coverage meets requirements
  - [ ] T2-1 Check coverage report for minimum threshold (≥85%)
  - [ ] T2-2 Verify all critical paths are covered
  - [ ] T2-3 Identify and document any coverage gaps
- [ ] T3 Validate test quality
  - [ ] T3-1 No skipped tests (all tests must run)
  - [ ] T3-2 No flaky tests (tests are deterministic)
  - [ ] T3-3 Test execution time is acceptable (<5min for unit tests)
  - [ ] T3-4 All test fixtures and mocks are properly cleaned up
- [ ] T4 Update verification matrix (if exists)
  - [ ] T4-1 Check for verification-matrix.json in .gobuildme/specs/<feature>/verification/
  - [ ] T4-2 For each AC with passing test: set "passes": true, add "verified_by" and "verified_at"
  - [ ] T4-3 Commit: "chore(<feature>): update verification matrix - X/Y ACs verified"

## Phase 9: Review (/gbm.review)
**Purpose**: Code review, architecture validation, and quality checks
**Gate**: All review tasks `[x]` before proceeding to Release

- [ ] RV1 Fact-check: Architecture compliance review
  - [ ] RV1-1 Verify no hardcoded values or magic numbers
  - [ ] RV1-2 Check constitution compliance (.gobuildme/memory/constitution.md)
  - [ ] RV1-3 Validate architectural patterns are followed
  - [ ] RV1-4 Verify no forbidden couplings introduced
- [ ] RV2 Fact-check: Requirements coverage
  - [ ] RV2-1 All user stories have corresponding implementation
  - [ ] RV2-2 All API endpoints from contracts are implemented
  - [ ] RV2-3 All data models from schema are created
  - [ ] RV2-4 No extra features not in requirements
- [ ] RV3 Fact-check: Code quality standards
  - [ ] RV3-1 Type hints present and correct (Python) or types defined (TypeScript/Go)
  - [ ] RV3-2 No linter errors or warnings
  - [ ] RV3-3 Proper error handling for all failure cases
  - [ ] RV3-4 Security best practices followed (no SQL injection, XSS, etc.)
  - [ ] RV3-5 Performance considerations addressed
- [ ] RV4 Fact-check: Documentation completeness
  - [ ] RV4-1 Implementation documentation created (.docs/implementations/<feature>/)
  - [ ] RV4-2 API documentation updated (if applicable)
  - [ ] RV4-3 README or user guide updated (if applicable)
  - [ ] RV4-4 No TODO comments remaining in code

## Phase 10: Release (/gbm.push)
**Purpose**: Final validation before pushing changes
**Gate**: All release tasks `[x]` before git push

- [ ] P1 Pre-push validation
  - [ ] P1-1 Verify all previous phase tasks are marked `[x]`
  - [ ] P1-2 Verify git status is clean (no untracked files)
  - [ ] P1-3 Verify branch is up to date with base branch
  - [ ] P1-4 Run final linter check
  - [ ] P1-5 Run final test suite
- [ ] P2 Commit preparation
  - [ ] P2-1 Create comprehensive commit message with task summary
  - [ ] P2-2 Reference issue numbers (if applicable)
  - [ ] P2-3 List completed tasks from tasks.md
  - [ ] P2-4 Verify commit includes all relevant file changes
- [ ] P3 Final quality check
  - [ ] P3-1 Review diff one final time
  - [ ] P3-2 Verify no debug code, console.logs, or print statements
  - [ ] P3-3 Verify no commented-out code blocks
  - [ ] P3-4 Check for accidentally committed secrets or credentials

## Dependencies
- Tests (T004-T007) before implementation (T008-T014)
- T008 blocks T009, T015
- T016 blocks T018
- Implementation before polish (T019-T024)
- Documentation (T024) runs after all other tasks complete

## Parallel Example
```
# Launch T004-T007 together:
Task: "Contract test POST /api/users in tests/contract/test_users_post.py"
Task: "Contract test GET /api/users/{id} in tests/contract/test_users_get.py"
Task: "Integration test registration in tests/integration/test_registration.py"
Task: "Integration test auth in tests/integration/test_auth.py"
```

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- Avoid: vague tasks, same file conflicts

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - Each contract file → contract test task [P]
   - Each endpoint → implementation task
   
2. **From Data Model**:
   - Each entity → model creation task [P]
   - Relationships → service layer tasks
   
3. **From User Stories**:
   - Each story → integration test [P]
   - Quickstart scenarios → validation tasks

4. **Ordering**:
   - Setup → Tests → Models → Services → Endpoints → Polish
   - Dependencies block parallel execution

## Validation Checklist
*GATE: Checked by main() before returning*

- [ ] All contracts have corresponding tests
- [ ] All entities have model tasks
- [ ] All tests come before implementation
- [ ] Parallel tasks truly independent
- [ ] Each task specifies exact file path
- [ ] No task modifies same file as another [P] task
- [ ] Implementation documentation task included as final task
- [ ] Documentation task depends on all other tasks completing
