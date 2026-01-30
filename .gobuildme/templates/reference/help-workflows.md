# Help System Workflow Reference

Detailed persona-specific workflows for `/gbm.help workflow` command.

---

## Generic SDD Workflow (All Personas)

```
Setup (Once per project)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. /gbm.constitution    → Define project goals, constraints, standards
2. /gbm.persona         → Configure your role (optional - defaults to fullstack)
3. /gbm.architecture    → Document tech stack and patterns

Feature Development (Per feature)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4. /gbm.request    → Capture feature request
5. /gbm.specify    → Define spec with acceptance criteria
6. /gbm.clarify    → Resolve ambiguities
7. /gbm.plan       → Create implementation plan
8. /gbm.tasks      → Break into task checklist
9. /gbm.analyze    → Validate technical approach
10. /gbm.implement → Build feature (TDD)
11. /gbm.tests     → Write tests
12. /gbm.review    → Quality validation
13. /gbm.push      → Final validation and PR
```

---

## Persona-Specific Focus Areas

| Persona | Coverage | Specify Focus | Plan Focus | Quality Gates |
|---------|----------|---------------|------------|---------------|
| backend_engineer | 85% | API contracts, data model, error handling | OpenAPI spec, migrations, observability | contracts_present, migrations_planned |
| frontend_engineer | 85% | UX flows, accessibility, performance targets | Component hierarchy, state management | a11y_planned, performance_budgets |
| fullstack_engineer | 80% | End-to-end requirements | Full stack integration | contracts_present, components_designed |
| qa_engineer | 90%/95%/80% | Test strategy, coverage gaps | Test implementation plan | coverage_met, test_isolation |
| data_engineer | 80% | Pipeline requirements, data quality | DAG design, monitoring | pipeline_tested, data_quality |
| data_scientist | 70% | Model requirements, metrics | Experiment design, feature engineering | model_validated, reproducibility |
| ml_engineer | 75% | Model serving, performance | Inference optimization, monitoring | model_performance, deployment_ready |
| sre | 75% | SLIs/SLOs, observability | Runbooks, alerting | observability_complete, runbooks_ready |
| security_compliance | 80% | Threat model, compliance | Security controls, audit | security_reviewed, compliance_met |
| architect | 75% | System design, ADRs | Technical strategy | architecture_documented, adrs_approved |
| product_manager | N/A | PRD, stakeholder alignment | Roadmap, success metrics | stakeholder_aligned |
| maintainer | 75% | Tech debt, migration plan | Refactoring strategy | tests_passing, backwards_compatible |

---

## QA Engineer Special Workflow

QA Engineers have a dedicated workflow separate from core SDD:

```
Setup
━━━━━
1. /gbm.constitution
2. /gbm.persona → qa_engineer
3. /gbm.architecture

Test Scaffolding
━━━━━━━━━━━━━━━
4. git checkout -b qa-test-scaffolding
5. /gbm.qa.scaffold-tests
6. /gbm.qa.plan

Test Implementation
━━━━━━━━━━━━━━━━━━
7. /gbm.qa.tasks
8. /gbm.qa.generate-fixtures
9. /gbm.qa.implement

Review & Merge
━━━━━━━━━━━━━
10. /gbm.qa.review-tests
11. /gbm.push
```

---

## Product Manager Workflow

PMs follow a discovery-to-handoff workflow:

```
Discovery Phase
━━━━━━━━━━━━━━━
/gbm.pm.discover → /gbm.pm.interview → /gbm.pm.research → /gbm.pm.validate-problem

Definition Phase
━━━━━━━━━━━━━━━━
/gbm.pm.prd → /gbm.pm.stories

Alignment Phase
━━━━━━━━━━━━━━━
/gbm.pm.align → /gbm.pm.handoff
```

---

## Persona Manual Locations

Each persona has a detailed manual in:
`.gobuildme/gobuildme-docs/personas/<persona>-manual.md`

Examples:
- backend-engineer-manual.md
- frontend-engineer-manual.md
- qa-engineer-manual.md
