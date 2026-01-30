---
description: "Scaffold integration test structure with samples and TODOs for existing codebase"
scripts:
  sh: scripts/bash/scaffold-tests.sh
  ps: scripts/powershell/scaffold-tests.ps1
artifacts:
  - path: ".gobuildme/specs/qa-test-scaffolding/scaffold-report.md"
    description: "Report of scaffolded tests with coverage analysis"
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

# Scaffold Tests Command

You are the Scaffold Tests Command. Your job is to create a complete test structure with sample tests and TODOs for an existing codebase.

## Purpose

Generate test scaffolding that includes:
- Test file structure organized by integration type
- Sample tests demonstrating best practices
- TODO comments guiding what to implement
- Fixtures and mocks for reusable test utilities
- Clear documentation on testing patterns

## Persona Context

- **Primary**: QA Engineer persona (owns this command)
- **Available to**: All personas (but QA Engineer gets enhanced guidance)
- **Integration**: Works with existing codebase (not feature-specific)

## Prerequisites

- Existing codebase with integration points
- Test framework installed (pytest, jest, etc.)
- Repository follows standard structure

## Workflow

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.qa.scaffold-tests" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

**IMPORTANT**: Run `{SCRIPT}` from the repository root. The script will:
- Check if architecture documentation exists (and prompt user if missing)
- Analyze the codebase and discover integration points
- Generate complete test scaffolding structure
- Create sample tests and fixtures
- Generate a detailed report

The script handles the entire scaffolding process. Do NOT attempt to manually implement the scaffolding logic yourself.

**⚠️ CRITICAL - NO AUTO-COMMIT**: Do NOT automatically commit any files during this command, including architecture documentation. All file commits must be done manually by the user after reviewing the generated content. This applies to ALL generated files (architecture docs, test scaffolds, reports, etc.).

### What the Script Does

The script (`{SCRIPT}`) performs these steps automatically:

**1. Architecture Integration**
- Checks if `.gobuildme/docs/technical/architecture/technology-stack.md` exists
- If missing: Prompts user to run `/gbm.architecture` first (does NOT auto-generate or auto-commit)
- If old (>7 days): Prompts to refresh (user must manually re-run `/gbm.architecture`)
- Loads architecture context for better test generation
- **NOTE**: Architecture files are NEVER auto-committed - user must commit manually

**2. Scan Codebase**

Discovers integration points:
- API endpoints (REST, GraphQL, gRPC)
- Database models and operations
- Message queue producers/consumers
- External service integrations
- File system operations
- Cache operations
- Authentication/authorization
- Email/SMS services
- Payment integrations
- Search operations

**3. Analyze Test Coverage**

Checks existing tests:
- Identify what's already tested
- Find gaps in coverage
- Categorize by integration type
- Prioritize by risk and business impact

**4. Generate Scaffold Structure**

Create test directory structure for all test types:
```
tests/
├── unit/                              # Unit tests (90% coverage target)
│   ├── models/
│   │   └── test_user_model.py         # Sample + TODOs
│   ├── services/
│   │   └── test_user_service.py       # Sample + TODOs
│   ├── utils/
│   │   └── test_validators.py         # Sample + TODOs
│   └── controllers/
│       └── test_user_controller.py    # Sample + TODOs
├── integration/                       # Integration tests (95% coverage target)
│   ├── api/
│   │   ├── test_users_api.py          # Sample + TODOs
│   │   └── test_products_api.py       # Sample + TODOs
│   ├── database/
│   │   ├── test_user_model.py         # Sample + TODOs
│   │   └── test_product_model.py      # Sample + TODOs
│   ├── queue/
│   │   └── test_email_queue.py        # Sample + TODOs
│   ├── external/
│   │   ├── test_stripe.py             # Sample + TODOs
│   │   └── test_sendgrid.py           # Sample + TODOs
│   └── cache/
│       └── test_redis_cache.py        # Sample + TODOs
├── e2e/                               # End-to-end tests (80% coverage target)
│   ├── user-flows/
│   │   └── test_user_registration.py  # Sample + TODOs
│   ├── critical-paths/
│   │   └── test_checkout_flow.py      # Sample + TODOs
│   └── smoke-tests/
│       └── test_health_checks.py      # Sample + TODOs
├── fixtures/
│   ├── api_fixtures.py                # Sample fixtures
│   ├── database_fixtures.py           # Sample fixtures
│   └── mock_services.py               # Sample mocks
└── conftest.py                        # Test configuration
```

**Supported Tech Stacks**:
- Python (pytest, unittest)
- JavaScript/TypeScript (Jest, Mocha, Vitest)
- PHP (PHPUnit, Pest)
- Java (JUnit, TestNG)
- Kotlin (JUnit, Kotest)
- Go (testing package)
- Ruby (RSpec, Minitest)
- C# (.NET xUnit, NUnit)
- Rust (cargo test)

**5. Generate Sample Tests**

For each integration type, create:
- **1-2 complete sample tests** demonstrating best practices
- **TODO tests** for remaining scenarios
- **Inline comments** explaining the pattern
- **Fixture usage** examples
- **Mock usage** examples

**6. Generate Fixtures & Mocks**

Create reusable test utilities:
- Database fixtures (test data)
- API fixtures (request/response)
- Mock external services
- Test configuration
- Helper functions

**7. Generate Documentation**

Create `.gobuildme/specs/qa-test-scaffolding/scaffold-report.md`:
- Summary of scaffolded tests
- Coverage analysis
- TODO checklist
- Next steps
- Testing best practices guide

**8. Validate Structure**

Check:
- All test files are syntactically correct
- Imports are valid
- Fixtures are properly defined
- Mocks are properly configured
- Sample tests can run

## Output Format

### Console Output

```
🏗️ Scaffolding integration tests...

🔍 Scanning codebase...
  ✓ Detected: Python (FastAPI)
  ✓ Found 45 API endpoints
  ✓ Found 12 database models
  ✓ Found 3 message queues
  ✓ Found 8 external services

📊 Analyzing existing tests...
  ✓ API tests: 15/45 endpoints covered (33%)
  ✓ Database tests: 4/12 models covered (33%)
  ✓ Queue tests: 0/3 queues covered (0%)
  ✓ External tests: 2/8 services covered (25%)

🏗️ Generating test scaffolds...
  ✓ Created tests/integration/api/test_users_api.py (2 samples + 8 TODOs)
  ✓ Created tests/integration/api/test_products_api.py (2 samples + 10 TODOs)
  ✓ Created tests/integration/database/test_user_model.py (2 samples + 6 TODOs)
  ✓ Created tests/integration/queue/test_email_queue.py (2 samples + 4 TODOs)
  ✓ Created tests/fixtures/api_fixtures.py (5 sample fixtures)
  ✓ Created tests/fixtures/database_fixtures.py (8 sample fixtures)
  ✓ Created tests/fixtures/mock_services.py (3 sample mocks)

📝 Summary:
  - Test files created: 12
  - Sample tests: 24
  - TODO tests: 78
  - Fixtures created: 16
  - Mocks created: 8
  - Estimated coverage after completion: 95%

📄 Report saved to: .gobuildme/specs/qa-test-scaffolding/scaffold-report.md

✅ Scaffolding complete!

Next Steps:
1. Review generated test files
2. Fill in TODO tests (78 remaining)
3. Customize fixtures and mocks
4. Run tests: pytest tests/integration/
5. Measure coverage: pytest --cov=app tests/
```

## Next Steps

After scaffolding:
- Review generated test structure
- Implement TODO tests
- Customize fixtures and mocks
- Run `/gbm.tests` to validate
- Measure coverage and iterate

## Quality Gates

- All generated files are syntactically correct
- Sample tests demonstrate best practices
- TODOs provide clear guidance
- Fixtures are reusable
- Mocks are properly configured

## Persona-Specific Behavior

### QA Engineer Persona

When qa_engineer is active:
- Generate more complete samples
- Include advanced testing patterns
- Add performance test scaffolds
- Add security test scaffolds
- Include accessibility test scaffolds
- Generate detailed test documentation

{PERSONA_PARTIAL:qa_engineer}

## Error Handling

If scaffolding fails:
- Report which integration types failed
- Provide partial scaffolding for successful types
- Suggest manual steps for failed types
- Log errors to `.gobuildme/specs/qa-test-scaffolding/errors.log`

## Configuration

Optional flags:
- `--type <integration-type>` - Scaffold specific type only (api, database, queue, etc.)
- `--overwrite` - Overwrite existing test files (default: skip)
- `--samples-only` - Generate only sample tests, no TODOs
- `--todos-only` - Generate only TODO scaffolds, no samples
- `--framework <name>` - Specify test framework (pytest, jest, etc.)

Examples:
```bash
/gbm.qa.scaffold-tests                          # Scaffold all integration types
/gbm.qa.scaffold-tests --type api               # Scaffold API tests only
/gbm.qa.scaffold-tests --type database --overwrite  # Overwrite existing DB tests
```

## Integration with Workflow

This command is a **utility command** (not part of core SDD workflow):
- Can be run anytime, on any branch
- Typically run once for legacy projects
- Generates structure for manual completion
- Complements `/gbm.tests` (which is feature-scoped)

## Best Practices

1. **Review before implementing** - Understand the generated structure
2. **Customize for your needs** - Adapt samples to your patterns
3. **Fill in TODOs systematically** - Start with high-priority tests
4. **Run tests frequently** - Validate as you implement
5. **Measure coverage** - Track progress toward 95% goal

## Next Steps

After scaffolding tests, follow the SDD workflow:

1. **Create Test Plan** (`/gbm.qa.plan`) - **NEXT COMMAND**
   - Analyze test structure and requirements
   - Define test strategy and approach
   - Identify test dependencies and priorities
   - Create complete test implementation plan
   - **Why**: Strategic planning ensures complete coverage and efficient implementation

2. **Generate Tasks** (`/gbm.qa.tasks`)
   - Break down test plan into actionable tasks
   - Order tasks by dependencies
   - Identify parallelizable work
   - **Why**: Structured task breakdown ensures systematic progress

3. **Generate Fixtures** (`/gbm.qa.generate-fixtures`)
   - Create reusable test fixtures for your data models
   - Generate mock services for external dependencies
   - Build test data sets (valid, invalid, edge cases)
   - **Why**: Reduces duplication and makes tests more maintainable

4. **Implement Tests** (`/gbm.qa.implement` or `/gbm.implement`)
   - Execute tasks using TDD approach
   - Convert TODO placeholders into working tests
   - Follow AAA pattern (Arrange, Act, Assert)
   - Mark tasks complete as you finish them
   - **Why**: Systematic TDD implementation with progress tracking

5. **Review Test Quality** (`/gbm.qa.review-tests`)
   - Validate test quality and best practices
   - Check coverage thresholds (Unit: 90%, Integration: 95%, E2E: 80%)
   - Verify AC traceability (100%)
   - **Why**: Catch issues before final review

6. **Final Review** (`/gbm.review`)
   - Complete quality gates validation
   - **Why**: Ready for merge

## Related Commands

- `/gbm.qa.plan` - Create test implementation plan (run next)
- `/gbm.qa.tasks` - Generate task breakdown
- `/gbm.qa.generate-fixtures` - Generate test fixtures and mocks
- `/gbm.qa.implement` - Implement tests using TDD
- `/gbm.qa.review-tests` - Review test quality
- `/gbm.tests` - Run feature-scoped tests (for new features)
- `/gbm.review` - Final quality gates

### Step 3: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-qa-scaffold-tests` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit scaffolded test files to add assertions
- Re-run `/gbm.qa.plan` if test structure needs revision
- Run `/gbm.qa.generate-fixtures` to create test data first
- Re-run `/gbm.qa.scaffold-tests` with updated specifications

