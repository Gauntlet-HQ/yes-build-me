# Persona-Specific Next Steps - Detailed Reference

> **Purpose**: Complete guidance for persona-specific workflow progression.
> **Used by**: implement.md, specify.md, plan.md, tasks.md, tests.md, review.md

---

## Quick Reference (Inline in Templates)

Use this condensed format in templates (context: **after /gbm.implement**):

```markdown
## Persona-Specific Next Command

| Persona | Next Command | Key Focus |
|---------|--------------|-----------|
| backend_engineer | /gbm.tests | API contracts, DB ops, 85% coverage |
| frontend_engineer | /gbm.tests | Component tests, a11y, visual regression |
| fullstack_engineer | /gbm.tests | E2E flows, API+UI integration |
| qa_engineer | /gbm.qa.review-tests | Coverage gaps, edge cases |
| data_engineer | /gbm.tests | Pipeline tests, data validation |
| data_scientist | /gbm.tests | Model validation, metrics |
| ml_engineer | /gbm.tests | Model tests, inference validation |
| sre | /gbm.tests | Reliability tests, chaos scenarios |
| security_compliance | /gbm.tests | Security tests, compliance validation |
| architect | /gbm.analyze | ADRs, boundary checks, NFR validation |
| product_manager | /gbm.pm.handoff | Acceptance validation, stakeholder review |
| maintainer | /gbm.review | PR quality, tech debt, release management |
```

---

## Detailed Per-Persona Guidance

### backend_engineer

**After /gbm.implement → Next: /gbm.tests**

Focus areas:
- Contract tests for all API endpoints (request/response schemas)
- Integration tests for database operations (CRUD, transactions)
- Error handling tests (4xx, 5xx responses)
- Edge case coverage (null inputs, boundary values)
- Performance tests for critical paths
- Target: 85% code coverage minimum

**After /gbm.tests → Next: /gbm.review**

Focus areas:
- API design consistency
- Database query efficiency
- Error message clarity
- Security validation

---

### frontend_engineer

**After /gbm.implement → Next: /gbm.tests**

Focus areas:
- Component unit tests (rendering, props, state)
- Accessibility tests (WCAG compliance)
- Visual regression tests (snapshots)
- User interaction tests (clicks, inputs)
- Responsive layout tests
- Target: 85% component coverage

**After /gbm.tests → Next: /gbm.review**

Focus areas:
- Component reusability
- Accessibility compliance
- Performance (bundle size, render time)
- Design system consistency

---

### fullstack_engineer

**After /gbm.implement → Next: /gbm.tests**

Focus areas:
- E2E workflow tests (complete user journeys)
- API + UI integration tests
- Cross-layer data consistency
- Authentication flow tests
- Target: 85% coverage (E2E for all user stories)

**After /gbm.tests → Next: /gbm.review**

Focus areas:
- Full-stack consistency
- Data flow correctness
- Error propagation
- User experience

---

### qa_engineer

**After /gbm.implement → Next: /gbm.qa.review-tests**

Focus areas:
- Test coverage gap analysis
- Edge case identification
- Test data quality
- Test maintainability
- Boundary value analysis

**After /gbm.qa.review-tests → Next: /gbm.review**

Focus areas:
- Test effectiveness
- Coverage metrics
- Risk areas

---

### data_engineer

**After /gbm.implement → Next: /gbm.tests**

Focus areas:
- Pipeline integration tests
- Data validation tests (schema, quality)
- ETL correctness tests
- Performance benchmarks
- Idempotency tests
- Target: 80% pipeline coverage

---

### data_scientist

**After /gbm.implement → Next: /gbm.tests**

Focus areas:
- Model validation tests (accuracy, precision, recall)
- Data preprocessing tests
- Feature engineering tests
- Metric calculation tests
- Reproducibility tests

---

### ml_engineer

**After /gbm.implement → Next: /gbm.tests**

Focus areas:
- Model inference tests
- Serving endpoint tests
- Model versioning tests
- Performance benchmarks
- A/B testing infrastructure

---

### sre

**After /gbm.implement → Next: /gbm.tests**

Focus areas:
- Reliability tests (failover, recovery)
- Chaos engineering scenarios
- Monitoring validation
- Alert threshold tests
- Runbook validation

---

### security_compliance

**After /gbm.implement → Next: /gbm.tests**

Focus areas:
- Security vulnerability tests
- Compliance validation (SOC2, GDPR)
- Authentication tests
- Authorization tests
- Audit logging tests

---

### architect

**After /gbm.implement → Next: /gbm.analyze**

Focus areas:
- Architecture Decision Records (ADRs) for key technical decisions
- Boundary checks and architectural constraint validation
- Non-Functional Requirements (NFR) verification
- Design pattern adherence and consistency
- Technical debt assessment and documentation
- Scalability and evolvability review

---

### product_manager

**After /gbm.implement → Next: /gbm.pm.handoff**

Focus areas:
- Acceptance criteria validation
- User story completion
- Stakeholder review preparation
- Release notes draft
- Demo preparation

---

### maintainer

**After /gbm.implement → Next: /gbm.review**

**Coverage Target**: No personal coverage requirement (reviews others' test coverage)

Focus areas:
- PR quality and reviewability
- Technical debt assessment
- Backward compatibility considerations
- Release notes and versioning
- CI status and quality gates
- Deprecation documentation
