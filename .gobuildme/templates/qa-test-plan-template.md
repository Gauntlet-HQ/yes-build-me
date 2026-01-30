---
description: "Test implementation plan template for QA Engineer persona"
scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

# QA Test Implementation Plan: [PROJECT/FEATURE]

**Branch**: `qa-test-scaffolding` | **Date**: [DATE] | **Scope**: [Project-wide | Feature-specific]
**Input**: Scaffolded tests from `.gobuildme/specs/qa-test-scaffolding/scaffold-report.md`

## Execution Flow (/gbm.qa.plan command scope)
```
1. Load scaffold report from qa-test-scaffolding directory
   → If not found: ERROR "Run /gbm.qa.scaffold-tests first"
2. Scan all test files for TODO/unimplemented tests
   → Parse test file structure
   → Count total TODO tests
   → Categorize by type (unit, integration, e2e)
3. Analyze test priorities
   → Identify high-priority tests (auth, critical paths, security)
   → Identify medium-priority tests (CRUD, validation, business logic)
   → Identify low-priority tests (edge cases, static content)
4. Load architecture context
   → Read .gobuildme/docs/technical/architecture/
   → Understand system components for test context
5. Define test implementation strategy
   → Order by priority and dependencies
   → Plan fixture generation approach
   → Plan mock strategy for external dependencies
6. Fill this plan template with actual data
7. Update Progress Tracking
8. STOP - Ready for /gbm.qa.tasks command
```

**IMPORTANT**: The /gbm.qa.plan command analyzes scaffolded tests and creates this plan. Downstream execution:
- `/gbm.qa.tasks` - Creates task checklist from this plan
- `/gbm.qa.implement` - Implements tests task-by-task
- `/gbm.qa.review-tests` - Validates quality gates

## Test Coverage Summary

**Total Tests Scaffolded**: [NUMBER]
**TODO Tests to Implement**: [NUMBER]
**Tests Already Implemented**: [NUMBER]

### Breakdown by Test Type
| Type | Total | Implemented | TODO | Priority |
|------|-------|-------------|------|----------|
| **Unit Tests** | [N] | [N] | [N] | [High/Medium/Low] |
| **Integration - API** | [N] | [N] | [N] | [High/Medium/Low] |
| **Integration - Database** | [N] | [N] | [N] | [High/Medium/Low] |
| **Integration - Queue** | [N] | [N] | [N] | [High/Medium/Low] |
| **Integration - External** | [N] | [N] | [N] | [High/Medium/Low] |
| **Integration - Cache** | [N] | [N] | [N] | [High/Medium/Low] |
| **E2E - User Flows** | [N] | [N] | [N] | [High/Medium/Low] |
| **E2E - Critical Paths** | [N] | [N] | [N] | [High/Medium/Low] |
| **E2E - Smoke Tests** | [N] | [N] | [N] | [High/Medium/Low] |

### Test Files Analysis
| File Path | Total Tests | TODO | Priority | Dependencies |
|-----------|-------------|------|----------|--------------|
| [e.g., tests/integration/api/LoginApiTest.php] | [N] | [N] | [High] | [Auth fixtures, User mocks] |
| [e.g., tests/integration/database/UserModelTest.php] | [N] | [N] | [Medium] | [Database fixtures] |
| [Continue for each test file...] | | | | |

## Test Requirements

*This section defines WHAT to test, quality standards per requirement, and success criteria. Each requirement (TR-XXX) will generate detailed tasks with verification checklists.*

### High Priority Requirements

**TR-001: Authentication & Authorization** (Critical Path)
- **Scope**: Login, logout, session management, password reset, OAuth flows
- **Coverage Target**: 100% (critical security path)
- **Quality Standards**:
  - ✓ Must use AAA pattern (Arrange, Act, Assert)
  - ✓ Must mock all external auth providers (Okta, OAuth, SAML)
  - ✓ Must assert both response status AND session/token creation
  - ✓ Must test both success AND failure paths
  - ✓ Must verify security headers (CSRF tokens, session cookies)
  - ✓ Must clean up sessions/tokens after test
  - ✓ Integration tests must run in <5s per test
- **Success Criteria**:
  - [ ] All auth flows tested (valid/invalid credentials, expired sessions, etc.)
  - [ ] 100% coverage of auth controller/service methods
  - [ ] All security vulnerabilities tested (brute force, session hijacking)
  - [ ] All tests passing with clear assertions

**TR-002: API Endpoints** (High Priority)
- **Scope**: REST API CRUD operations, validation, error handling
- **Coverage Target**: 95%
- **Quality Standards**:
  - ✓ Must use AAA pattern
  - ✓ Must test all HTTP methods (GET, POST, PUT, PATCH, DELETE)
  - ✓ Must assert response status, body structure, AND headers
  - ✓ Must test validation errors with specific error messages
  - ✓ Must mock database operations (use fixtures, not real DB for API tests)
  - ✓ Must verify content-type headers
  - ✓ API tests must run in <3s per test
- **Success Criteria**:
  - [ ] All endpoints tested with valid/invalid inputs
  - [ ] All validation rules tested
  - [ ] All error scenarios tested (400, 401, 403, 404, 500)
  - [ ] Request/response schemas validated

**TR-003: Database Operations** (High Priority)
- **Scope**: CRUD operations, transactions, constraints, relationships
- **Coverage Target**: 95%
- **Quality Standards**:
  - ✓ Must use AAA pattern
  - ✓ Must use database fixtures (Factory pattern preferred)
  - ✓ Must test within transactions (rollback after test)
  - ✓ Must assert data integrity (constraints, foreign keys)
  - ✓ Must test cascade deletes and relationship updates
  - ✓ Must verify unique constraints and validation at DB level
  - ✓ Database tests must run in <5s per test
- **Success Criteria**:
  - [ ] All model CRUD operations tested
  - [ ] All relationships tested (one-to-many, many-to-many)
  - [ ] All constraints tested (unique, not null, foreign key)
  - [ ] Transaction rollback behavior verified

### Medium Priority Requirements

**TR-004: External Service Integrations** (Medium Priority)
- **Scope**: Third-party APIs (payment, email, SMS, analytics)
- **Coverage Target**: 90%
- **Quality Standards**:
  - ✓ Must use AAA pattern
  - ✓ Must mock ALL external API calls (never call real services)
  - ✓ Must test both success and failure responses
  - ✓ Must test timeout/retry logic
  - ✓ Must test error handling (network errors, API errors, rate limits)
  - ✓ Must verify request payloads match API contracts
  - ✓ Integration tests must run in <5s per test
- **Success Criteria**:
  - [ ] All external service calls mocked
  - [ ] All success/failure scenarios tested
  - [ ] Timeout and retry logic tested
  - [ ] Rate limiting behavior tested

**TR-005: Business Logic** (Medium Priority)
- **Scope**: Core business rules, calculations, workflows
- **Coverage Target**: 90%
- **Quality Standards**:
  - ✓ Must use AAA pattern
  - ✓ Must test boundary conditions
  - ✓ Must test edge cases (null, zero, negative, max values)
  - ✓ Must mock external dependencies
  - ✓ Must assert exact calculation results (not approximate)
  - ✓ Unit tests must run in <100ms per test
- **Success Criteria**:
  - [ ] All business rules tested
  - [ ] All calculations verified (with edge cases)
  - [ ] All state transitions tested

### Low Priority Requirements

**TR-006: Static Content & Helpers** (Low Priority)
- **Scope**: Utility functions, static content rendering, helpers
- **Coverage Target**: 80%
- **Quality Standards**:
  - ✓ Must use AAA pattern
  - ✓ Must test common use cases
  - ✓ Unit tests must run in <50ms per test
- **Success Criteria**:
  - [ ] Common helper functions tested
  - [ ] Static content rendering verified

### Security Requirements (OWASP Top 10)

**TR-007: Security Vulnerabilities** (Critical - All High Priority)
- **Scope**: OWASP Top 10 vulnerabilities
- **Coverage Target**: 100% of OWASP Top 10
- **Quality Standards**:
  - ✓ Must use AAA pattern
  - ✓ Must test actual attack vectors (XSS payloads, SQL injection strings)
  - ✓ Must assert proper sanitization/escaping
  - ✓ Must verify security headers (CSP, X-Frame-Options, etc.)
  - ✓ E2E security tests must run in <10s per test
- **OWASP Coverage**:
  - [ ] A01: Broken Access Control (CSRF protection, session validation)
  - [ ] A02: Cryptographic Failures (TLS, encrypted sessions)
  - [ ] A03: Injection (XSS, SQL injection, command injection)
  - [ ] A04: Insecure Design (rate limiting, input validation)
  - [ ] A05: Security Misconfiguration (CORS, headers, defaults)
  - [ ] A07: Authentication Failures (brute force, credential storage)
  - [ ] A08: Data Integrity Failures (OAuth state, signatures)
- **Success Criteria**:
  - [ ] All OWASP Top 10 vulnerabilities tested
  - [ ] Attack payloads properly blocked
  - [ ] Security headers verified

---

## Test Implementation Strategy

### Phase 0: Analysis & Setup
**Goal**: Understand test landscape and prepare for implementation

**Actions**:
1. **Scan codebase**: Analyze existing application code to understand test requirements
2. **Review architecture**: Load `.gobuildme/docs/technical/architecture/` for context
3. **Identify dependencies**: Determine external services, databases, APIs that need mocking
4. **Assess complexity**: Categorize tests by complexity (simple, moderate, complex)

**Output**: Clear understanding of what needs to be tested and how

### Phase 1: Fixture & Mock Generation
**Goal**: Create reusable test data and mocks before writing tests

**Fixture Strategy**:
- **Database Fixtures**: Generate fixtures for all data models
  - User fixtures (valid, invalid, edge cases)
  - Entity fixtures for each model
  - Relationship fixtures
- **API Fixtures**: Request/response fixtures for all endpoints
  - Valid request data
  - Invalid request scenarios
  - Edge case payloads
- **Mock Services**: Mock external dependencies
  - Third-party APIs (payment, email, SMS)
  - External services
  - Database connections (for unit tests)

**Recommended**: Run `/gbm.qa.generate-fixtures` to auto-generate fixtures from architecture

**Output**: Comprehensive fixtures in `tests/fixtures/` directory

### Phase 2: Priority-Based Test Implementation
**Goal**: Implement tests systematically by priority

**Implementation Order**:

**High Priority (Implement First)**:
- [ ] Authentication & authorization tests
- [ ] Critical user flows (login, signup, checkout)
- [ ] Security tests (CSRF, XSS, SQL injection)
- [ ] Payment processing tests
- [ ] Data integrity tests
- [ ] Session management tests

**Medium Priority (Implement Second)**:
- [ ] CRUD operation tests
- [ ] Validation tests
- [ ] Business logic tests
- [ ] API endpoint tests
- [ ] Database query tests
- [ ] Cache operation tests

**Low Priority (Implement Last)**:
- [ ] Edge case tests
- [ ] Static content tests
- [ ] Non-critical helper function tests
- [ ] Performance optimization tests

**Estimated Implementation Time**: [e.g., 40 high-priority tests × 15 min = 10 hours]

### Phase 3: Validation & Quality
**Goal**: Ensure all tests are implemented and passing

**Validation Steps**:
1. Run all tests: Verify 100% pass rate
2. Measure coverage: Enforce thresholds (Unit: 90%, Integration: 95%, E2E: 80%)
3. Check AC traceability: Ensure 100% of acceptance criteria have tests
4. Verify test quality: AAA pattern, proper mocking, clear assertions
5. Review test isolation: Each test independent and idempotent

**Quality Gates**: (enforced by `/gbm.qa.review-tests`)
- [ ] All TODO tests implemented (0 remaining)
- [ ] All tests passing
- [ ] Coverage thresholds met
- [ ] AC traceability 100%
- [ ] No skipped tests without documentation
- [ ] No hardcoded test data

## Technical Context

**Language/Version**: [e.g., Python 3.11, PHP 8.2, JavaScript ES2022]
**Testing Framework**: [e.g., pytest, PHPUnit, Jest]
**Primary Dependencies**: [e.g., pytest-mock, Mockery, Sinon]
**Database**: [e.g., PostgreSQL 15, MySQL 8.0, MongoDB 6.0]
**Test Database Strategy**: [e.g., transactions+rollback, separate test DB, in-memory DB]
**Mocking Strategy**: [e.g., unittest.mock, Mockery, jest.mock]
**Fixtures Strategy**: [e.g., Factory Boy, Faker, fixtures.js]
**External Services to Mock**: [e.g., Stripe API, SendGrid API, Redis]
**Coverage Tool**: [e.g., pytest-cov, PHPUnit --coverage-html, Jest --coverage]
**Coverage Thresholds**:
- Unit Tests: 90%
- Integration Tests: 95%
- E2E Tests: 80%
- Overall: 85%

## Test Quality Standards

### AAA Pattern (Arrange, Act, Assert)
All tests must follow:
```
# Arrange: Set up test data and environment
# Act: Execute the code under test
# Assert: Verify the expected outcome
```

### Test Isolation
- [ ] Each test is independent
- [ ] No shared state between tests
- [ ] Tests can run in any order
- [ ] Cleanup after each test

### Mocking Best Practices
- [ ] Mock external dependencies (APIs, databases, queues)
- [ ] Don't mock the system under test
- [ ] Verify mock calls when testing interactions
- [ ] Use appropriate mock types (Mock, Spy, Stub)

### Clear Assertions
- [ ] Descriptive test names (test_user_cannot_login_with_expired_password)
- [ ] Clear assertion messages
- [ ] One assertion per test (or closely related assertions)
- [ ] Test both success and failure paths

### Fixture Usage
- [ ] Reuse fixtures across tests
- [ ] Keep fixtures simple and focused
- [ ] Use factory patterns for complex objects
- [ ] Parameterize tests for multiple scenarios

## Architecture Alignment Check
*GATE: Validate tests align with application architecture*

### Architecture Context
- [ ] Latest architecture docs loaded from `.gobuildme/docs/technical/architecture/`
- [ ] Technology stack understood (frameworks, databases, external services)
- [ ] Integration points identified (APIs, queues, external services)
- [ ] Security patterns understood (auth, authorization, encryption)

### Test Architecture Alignment
- [ ] Tests follow application's architectural patterns
- [ ] Integration tests cover all integration points
- [ ] External services properly mocked
- [ ] Database tests use correct ORM/query patterns
- [ ] API tests match API contract specifications
- [ ] Security tests cover authentication/authorization patterns

### Technology Alignment
- [ ] Test framework compatible with application stack
- [ ] Mocking libraries appropriate for tech stack
- [ ] Coverage tools compatible with language/framework
- [ ] Test fixtures use same data types as application

## Test Categories & Approach

### Unit Tests (Target: 90% coverage)
**Scope**: Individual functions, methods, classes in isolation

**Approach**:
- Mock all external dependencies
- Test each code path (happy path, error cases, edge cases)
- Fast execution (<100ms per test)
- No database, API, or file system calls

**Example Test Categories**:
- Model validation logic
- Service business logic
- Utility functions
- Helper classes

### Integration Tests (Target: 95% coverage)
**Scope**: Interactions between components and external systems

**Approach**:
- Test real integrations (database, API, cache)
- Use test database with transactions/rollback
- Mock only external third-party services
- Moderate execution time (<5s per test)

**Example Test Categories**:
- API endpoint tests (request → response)
- Database operation tests (CRUD)
- Message queue tests (publish/consume)
- Cache operation tests (get/set/invalidate)
- External service integration tests (mocked)

### E2E Tests (Target: 80% coverage)
**Scope**: Complete user workflows through the entire system

**Approach**:
- Test critical user journeys
- Use browser automation (Playwright, Selenium)
- Test in staging-like environment
- Slower execution (10-30s per test)

**Example Test Categories**:
- User registration → email verification → login
- Product search → add to cart → checkout → payment
- Admin dashboard → create user → assign permissions

## Test Priority Matrix

### High Priority (Critical - Implement First)
**Criteria**: Security-sensitive, revenue-impacting, user-facing critical paths

**Examples**:
- Authentication & authorization (login, logout, session management)
- Payment processing (checkout, refunds, billing)
- Data integrity (user data, financial transactions)
- Security (CSRF protection, XSS prevention, SQL injection prevention)
- Critical user flows (signup, password reset, account recovery)

**Impact if not tested**: Security breaches, financial loss, user lockout, data corruption

### Medium Priority (Important - Implement Second)
**Criteria**: Business logic, CRUD operations, common user actions

**Examples**:
- CRUD operations (create, read, update, delete entities)
- Validation logic (form validation, data sanitization)
- Business rules (discount calculations, eligibility checks)
- API endpoints (REST/GraphQL operations)
- Search & filtering functionality

**Impact if not tested**: Business logic bugs, incorrect calculations, poor UX

### Low Priority (Nice-to-Have - Implement Last)
**Criteria**: Edge cases, static content, rarely used features

**Examples**:
- Edge case scenarios (unusual input combinations)
- Static page rendering (about us, terms of service)
- Rarely used admin features
- Legacy compatibility tests
- Performance optimization tests

**Impact if not tested**: Minor bugs in edge cases, less critical functionality

## Test Dependencies

### Prerequisites for Test Implementation
- [ ] Application code implemented (can't test what doesn't exist)
- [ ] Test fixtures available (auto-generate with `/gbm.qa.generate-fixtures`)
- [ ] Mock services configured
- [ ] Test database configured
- [ ] Test environment set up

### Dependencies Between Tests
- **Fixtures before tests**: Generate fixtures → implement tests using fixtures
- **Unit before integration**: Unit tests help debug integration test failures
- **Integration before E2E**: E2E tests depend on stable integration points

### External Dependencies
- **Database**: Test database configured with migrations
- **Cache**: Test cache (Redis/Memcached) or in-memory mock
- **Queue**: Test queue (RabbitMQ/SQS) or in-memory mock
- **External APIs**: Mocked (Stripe, SendGrid, etc.)

## Complexity Tracking
*Fill ONLY if there are unusual test implementation challenges*

| Challenge | Reason | Mitigation Strategy |
|-----------|--------|---------------------|
| [e.g., Complex async flows] | [WebSocket testing difficult] | [Use dedicated testing library] |
| [e.g., Legacy code untestable] | [No dependency injection] | [Refactor incrementally] |

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [ ] Phase 0: Analysis complete (/gbm.qa.plan command)
- [ ] Phase 1: Fixtures generated (/gbm.qa.generate-fixtures or manual)
- [ ] Phase 2: Tasks created (/gbm.qa.tasks command)
- [ ] Phase 3: High-priority tests implemented (/gbm.qa.implement)
- [ ] Phase 4: Medium-priority tests implemented (/gbm.qa.implement)
- [ ] Phase 5: Low-priority tests implemented (/gbm.qa.implement)
- [ ] Phase 6: Validation passed (/gbm.qa.review-tests)

**Gate Status**:
- [ ] Architecture Alignment Check: PASS
- [ ] Fixture strategy defined
- [ ] All test categories identified
- [ ] Priorities assigned to all tests
- [ ] Quality standards documented

**Test Implementation Progress**:
- [ ] High-priority tests: 0/[N] complete (0%)
- [ ] Medium-priority tests: 0/[N] complete (0%)
- [ ] Low-priority tests: 0/[N] complete (0%)
- [ ] **Overall**: 0/[TOTAL] complete (0%)

**Quality Metrics**:
- [ ] Unit test coverage: 0% (target: 90%)
- [ ] Integration test coverage: 0% (target: 95%)
- [ ] E2E test coverage: 0% (target: 80%)
- [ ] Overall coverage: 0% (target: 85%)
- [ ] AC traceability: 0% (target: 100%)

---
*Next Step*: Run `/gbm.qa.tasks` to generate task checklist from this plan
