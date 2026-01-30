#!/usr/bin/env python3
"""
Script to generate missing persona partials for GoBuildMe SDD workflow.
Creates persona-specific guidance for constitution, clarify, analyze, request, review, and push commands.
"""

import sys
from pathlib import Path

# Colors for output
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
NC = '\033[0m'  # No Color

# Counters
created = 0
skipped = 0
failed = 0


def create_partial(persona: str, command: str, content: str, partials_dir: Path):
    """Create a persona partial file if it doesn't exist."""
    global created, skipped, failed

    persona_dir = partials_dir / persona
    file_path = persona_dir / f"{command}.md"

    # Create persona directory if it doesn't exist
    persona_dir.mkdir(parents=True, exist_ok=True)

    # Check if file already exists
    if file_path.exists():
        print(f"{YELLOW}⊘ Skipped{NC} {persona}/{command}.md (already exists)")
        skipped += 1
        return

    # Write content to file
    try:
        file_path.write_text(content, encoding='utf-8')
        print(f"{GREEN}✓ Created{NC} {persona}/{command}.md")
        created += 1
    except Exception as e:
        print(f"{RED}✗ Failed{NC} {persona}/{command}.md: {e}")
        failed += 1


def main():
    # Setup paths
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    partials_dir = project_root / "templates" / "personas" / "partials"

    # ============================================================================
    # CONSTITUTION PARTIALS (12 personas)
    # ============================================================================

    print("Generating constitution.md partials...")

    create_partial("architect", "constitution", """### Persona Considerations — Architect

Constitution-specific guidance for architects:
- Define and validate architectural principles, patterns, and standards for the project
- Establish technology stack constraints, integration boundaries, and service contracts
- Document non-functional requirements (scalability, reliability, maintainability)
- Define quality attributes and architectural decision-making frameworks
- Ensure alignment between architectural vision and project constitution
- Specify architectural review gates and approval processes
""", partials_dir)

    create_partial("backend_engineer", "constitution", """### Persona Considerations — Backend Engineer

Constitution-specific guidance for backend engineers:
- Define API design standards, versioning policies, and backwards compatibility rules
- Establish database schema change procedures and migration strategies
- Document service-level objectives (SLOs) for backend services
- Define error handling, logging, and monitoring standards
- Specify performance benchmarks and resource utilization limits
- Establish coding standards for backend languages and frameworks
""", partials_dir)

    create_partial("data_engineer", "constitution", """### Persona Considerations — Data Engineer

Constitution-specific guidance for data engineers:
- Define data quality standards, validation rules, and schema governance
- Establish ETL/ELT pipeline standards and data flow conventions
- Document data retention policies, archival strategies, and compliance requirements
- Define data access patterns, query optimization guidelines, and performance SLAs
- Specify data lineage tracking and metadata management practices
- Establish data testing standards and validation checkpoints
""", partials_dir)

    create_partial("data_scientist", "constitution", """### Persona Considerations — Data Scientist

Constitution-specific guidance for data scientists:
- Define model performance metrics, validation procedures, and acceptance criteria
- Establish experiment tracking standards, reproducibility requirements, and versioning
- Document feature engineering guidelines and data preprocessing standards
- Define model governance, bias detection, and fairness evaluation procedures
- Specify model monitoring requirements and performance degradation thresholds
- Establish notebook organization standards and code-to-production workflows
""", partials_dir)

    create_partial("frontend_engineer", "constitution", """### Persona Considerations — Frontend Engineer

Constitution-specific guidance for frontend engineers:
- Define UI/UX standards, component libraries, and design system adherence
- Establish accessibility requirements (WCAG compliance levels)
- Document browser support matrix and progressive enhancement strategies
- Define performance budgets (Core Web Vitals, bundle sizes, load times)
- Specify state management patterns and component architecture standards
- Establish responsive design breakpoints and mobile-first requirements
""", partials_dir)

    create_partial("fullstack_engineer", "constitution", """### Persona Considerations — Fullstack Engineer

Constitution-specific guidance for fullstack engineers:
- Define end-to-end integration standards spanning frontend, backend, and database
- Establish full-stack testing strategies (unit, integration, E2E)
- Document API contracts, data flow patterns, and state synchronization rules
- Define deployment standards covering both client and server components
- Specify cross-layer performance optimization requirements
- Establish code organization standards for full-stack project structure
""", partials_dir)

    create_partial("maintainer", "constitution", """### Persona Considerations — Maintainer

Constitution-specific guidance for maintainers:
- Define versioning policy (semantic versioning, release cadence, LTS strategy)
- Establish changelog standards, release notes format, and communication procedures
- Document deprecation policies, migration guides, and backwards compatibility rules
- Define contribution guidelines, PR review standards, and merge criteria
- Specify documentation requirements and maintenance responsibilities
- Establish governance model for constitutional amendments and policy changes
""", partials_dir)

    create_partial("ml_engineer", "constitution", """### Persona Considerations — ML Engineer

Constitution-specific guidance for ML engineers:
- Define ML model deployment standards, serving infrastructure, and latency requirements
- Establish model versioning, registry practices, and rollback procedures
- Document A/B testing frameworks, canary deployment strategies, and monitoring
- Define feature store standards, data pipeline integration, and batch/real-time serving
- Specify model performance SLAs, retraining triggers, and drift detection thresholds
- Establish MLOps practices, CI/CD for ML, and production readiness criteria
""", partials_dir)

    create_partial("product_manager", "constitution", """### Persona Considerations — Product Manager

Constitution-specific guidance for product managers:
- Define product vision, success metrics, and key performance indicators (KPIs)
- Establish scope boundaries, MVP criteria, and feature prioritization frameworks
- Document stakeholder communication protocols and decision-making authority
- Define user feedback integration processes and validation methodologies
- Specify release criteria, go/no-go decision frameworks, and rollback triggers
- Establish product roadmap governance and strategic alignment requirements
""", partials_dir)

    create_partial("qa_engineer", "constitution", """### Persona Considerations — QA Engineer

Constitution-specific guidance for QA engineers:
- Define testing standards, coverage requirements, and quality gates
- Establish test automation strategies, frameworks, and CI/CD integration
- Document defect tracking procedures, severity classifications, and resolution SLAs
- Define regression testing scope, smoke test suites, and production validation
- Specify performance testing requirements, load profiles, and acceptance criteria
- Establish quality metrics, reporting standards, and release readiness criteria
""", partials_dir)

    create_partial("security_compliance", "constitution", """### Persona Considerations — Security & Compliance

Constitution-specific guidance for security & compliance:
- Define security standards, threat modeling requirements, and risk assessment procedures
- Establish authentication/authorization policies, data encryption standards, and secrets management
- Document compliance requirements (GDPR, SOC2, HIPAA, etc.) and audit procedures
- Define vulnerability scanning policies, penetration testing cadence, and remediation SLAs
- Specify security review gates, approval workflows, and incident response procedures
- Establish secure development lifecycle (SDLC) practices and security training requirements
""", partials_dir)

    create_partial("sre", "constitution", """### Persona Considerations — SRE

Constitution-specific guidance for SREs:
- Define reliability targets (SLIs, SLOs, error budgets) and incident response procedures
- Establish infrastructure-as-code standards, configuration management, and change control
- Document monitoring, alerting, and observability requirements
- Define capacity planning procedures, resource allocation, and cost optimization guidelines
- Specify disaster recovery plans, backup strategies, and business continuity requirements
- Establish on-call rotation policies, runbook standards, and operational excellence practices
""", partials_dir)

    # ============================================================================
    # CLARIFY PARTIALS (11 personas - missing only architect)
    # ============================================================================

    print("\nGenerating clarify.md partials...")

    create_partial("architect", "clarify", """### Persona Considerations — Architect

Clarify-specific guidance for architects:
- Clarify architectural boundaries, integration points, and service dependencies
- Resolve ambiguities in non-functional requirements (scalability, resilience, performance)
- Define technology stack decisions and justify architectural trade-offs
- Clarify data flow, state management, and distributed system concerns
- Identify missing quality attributes or architectural constraints
- Resolve conflicts between architectural principles and implementation constraints
""", partials_dir)

    create_partial("backend_engineer", "clarify", """### Persona Considerations — Backend Engineer

Clarify-specific guidance for backend engineers:
- Clarify API contract ambiguities: request/response formats, error codes, versioning strategy
- Resolve data model uncertainties: entity relationships, validation rules, constraints
- Define error handling specifics: retry logic, timeout values, fallback behaviors
- Clarify performance requirements: response time targets, throughput expectations, resource limits
- Resolve integration ambiguities: external service contracts, authentication methods, data formats
- Define testing expectations: unit test coverage, integration test scope, mock strategies
""", partials_dir)

    create_partial("data_engineer", "clarify", """### Persona Considerations — Data Engineer

Clarify-specific guidance for data engineers:
- Clarify data pipeline ambiguities: scheduling frequency, trigger conditions, backfill strategies
- Resolve data quality requirements: validation rules, completeness thresholds, anomaly detection
- Define schema ambiguities: data types, nullable fields, default values, partitioning strategy
- Clarify performance expectations: query latency targets, throughput requirements, resource limits
- Resolve data governance uncertainties: retention policies, access controls, compliance requirements
- Define monitoring requirements: quality metrics, alerting thresholds, lineage tracking
""", partials_dir)

    create_partial("data_scientist", "clarify", """### Persona Considerations — Data Scientist

Clarify-specific guidance for data scientists:
- Clarify model performance requirements: accuracy targets, precision/recall trade-offs, latency constraints
- Resolve feature ambiguities: feature definitions, transformations, aggregation windows
- Define validation methodology: train/test split ratios, cross-validation folds, evaluation metrics
- Clarify data requirements: sample size, class distribution, feature availability, data freshness
- Resolve experiment scope: baseline comparisons, hyperparameter ranges, stopping criteria
- Define reproducibility requirements: random seeds, versioning strategy, environment specification
""", partials_dir)

    create_partial("frontend_engineer", "clarify", """### Persona Considerations — Frontend Engineer

Clarify-specific guidance for frontend engineers:
- Clarify UI/UX ambiguities: user flows, interaction patterns, edge case behaviors
- Resolve accessibility requirements: WCAG level (A, AA, AAA), screen reader support, keyboard navigation
- Define performance expectations: page load targets, interactivity thresholds, animation frame rates
- Clarify responsive behavior: breakpoint definitions, mobile-first or desktop-first, device support
- Resolve state management ambiguities: data persistence, synchronization, conflict resolution
- Define browser support: version matrix, progressive enhancement strategy, polyfill requirements
""", partials_dir)

    create_partial("fullstack_engineer", "clarify", """### Persona Considerations — Fullstack Engineer

Clarify-specific guidance for fullstack engineers:
- Clarify end-to-end data flow: client state → API → database → response → UI update
- Resolve API contract ambiguities: request/response formats, error handling, versioning
- Define integration points: real-time updates, WebSocket usage, polling strategies
- Clarify deployment coordination: frontend/backend release sequencing, feature flag usage
- Resolve authentication flow: session management, token handling, refresh strategies
- Define testing strategy: E2E scenarios, integration test boundaries, mock vs. real services
""", partials_dir)

    create_partial("maintainer", "clarify", """### Persona Considerations — Maintainer

Clarify-specific guidance for maintainers:
- Clarify versioning ambiguities: semantic versioning interpretation, breaking change definition
- Resolve documentation requirements: API docs, user guides, migration guides, changelog format
- Define deprecation policy: notice period, migration path, backward compatibility duration
- Clarify release process: branching strategy, tagging convention, release notes format
- Resolve contribution ambiguities: PR review criteria, merge requirements, CI/CD gates
- Define support commitments: bug fix SLAs, security patch policy, LTS strategy
""", partials_dir)

    create_partial("ml_engineer", "clarify", """### Persona Considerations — ML Engineer

Clarify-specific guidance for ML engineers:
- Clarify model serving requirements: batch vs. real-time, latency SLAs, throughput targets
- Resolve feature engineering ambiguities: feature store usage, transformation logic, versioning
- Define deployment strategy: A/B test design, canary rollout percentage, rollback triggers
- Clarify monitoring requirements: performance metrics, drift detection thresholds, alert conditions
- Resolve training pipeline ambiguities: retraining triggers, hyperparameter tuning scope, resource allocation
- Define MLOps requirements: model registry, experiment tracking, CI/CD integration
""", partials_dir)

    create_partial("product_manager", "clarify", """### Persona Considerations — Product Manager

Clarify-specific guidance for product managers:
- Clarify user value proposition: target users, pain points addressed, success criteria
- Resolve scope ambiguities: MVP definition, feature prioritization, release boundaries
- Define success metrics: KPIs, baseline measurements, target improvements, tracking methodology
- Clarify user experience expectations: workflows, edge cases, error scenarios, help/documentation
- Resolve stakeholder requirements: approval gates, communication plan, rollout strategy
- Define acceptance criteria: feature completeness, quality standards, go/no-go decision framework
""", partials_dir)

    create_partial("qa_engineer", "clarify", """### Persona Considerations — QA Engineer

Clarify-specific guidance for QA engineers:
- Clarify testing scope: test types (unit, integration, E2E), coverage targets, automation requirements
- Resolve quality gate ambiguities: pass/fail criteria, performance benchmarks, security thresholds
- Define test data requirements: data volume, edge cases, production-like scenarios, data masking
- Clarify defect management: severity definitions, resolution SLAs, regression test scope
- Resolve test environment ambiguities: environment parity, data refresh, infrastructure setup
- Define test reporting: metrics, dashboards, test evidence, sign-off criteria
""", partials_dir)

    create_partial("security_compliance", "clarify", """### Persona Considerations — Security & Compliance

Clarify-specific guidance for security & compliance:
- Clarify security requirements: authentication methods, authorization model, data protection levels
- Resolve compliance ambiguities: applicable regulations, audit requirements, data residency
- Define threat model: attack vectors, risk levels, mitigation priorities, security controls
- Clarify vulnerability management: scanning frequency, remediation SLAs, acceptable risk
- Resolve secrets management: storage method, rotation policy, access controls
- Define security review scope: code review, architecture review, penetration testing, sign-off criteria
""", partials_dir)

    create_partial("sre", "clarify", """### Persona Considerations — SRE

Clarify-specific guidance for SREs:
- Clarify reliability targets: SLI definitions, SLO thresholds, error budget calculations
- Resolve operational ambiguities: monitoring requirements, alerting rules, on-call escalation
- Define scalability expectations: traffic patterns, auto-scaling triggers, capacity planning
- Clarify observability requirements: log retention, metrics granularity, tracing depth
- Resolve deployment ambiguities: rollout strategy, canary percentage, rollback conditions
- Define infrastructure requirements: IaC standards, configuration management, disaster recovery
""", partials_dir)

    # ============================================================================
    # ANALYZE PARTIALS (10 personas)
    # ============================================================================

    print("\nGenerating analyze.md partials...")

    create_partial("architect", "analyze", """### Persona Considerations — Architect

Analyze-specific guidance for architects:
- Assess architectural impact: Does this change affect system boundaries, data flow, or integration contracts?
- Evaluate scalability implications: Will this scale with expected load? What are the bottlenecks?
- Analyze technical debt: Does this align with architectural vision or introduce compromises?
- Identify ripple effects across services, layers, and components
- Assess technology stack implications and potential migrations
- Evaluate architectural patterns: Does this follow established patterns or introduce new ones?
""", partials_dir)

    create_partial("backend_engineer", "analyze", """### Persona Considerations — Backend Engineer

Analyze-specific guidance for backend engineers:
- Assess API impact: Breaking changes? Versioning needs? Backwards compatibility?
- Evaluate database implications: Schema changes? Migration complexity? Performance impact?
- Analyze service dependencies: Which services are affected? What integrations need updates?
- Identify performance bottlenecks: Database queries? API latency? Resource utilization?
- Assess error handling: What failure modes exist? What recovery strategies are needed?
- Evaluate testing scope: What integration tests? What mocking is required?
""", partials_dir)

    create_partial("data_engineer", "analyze", """### Persona Considerations — Data Engineer

Analyze-specific guidance for data engineers:
- Assess data pipeline impact: Which pipelines are affected? What's the data flow change?
- Evaluate data quality: What validation rules? What data integrity checks?
- Analyze performance: Query optimization needs? Batch vs. streaming considerations?
- Identify data lineage changes: What upstream/downstream systems are impacted?
- Assess resource requirements: Storage? Compute? Network bandwidth?
- Evaluate data governance: Compliance implications? Access control changes?
""", partials_dir)

    create_partial("data_scientist", "analyze", """### Persona Considerations — Data Scientist

Analyze-specific guidance for data scientists:
- Assess model impact: Feature changes? Training data modifications? Retraining required?
- Evaluate experiment implications: What hypotheses? What validation methodology?
- Analyze data dependencies: What data sources? What feature engineering changes?
- Identify performance implications: Model latency? Throughput? Resource requirements?
- Assess reproducibility: Can experiments be reproduced? What versioning is needed?
- Evaluate business metrics impact: What KPIs are affected? What success criteria?
""", partials_dir)

    create_partial("frontend_engineer", "analyze", """### Persona Considerations — Frontend Engineer

Analyze-specific guidance for frontend engineers:
- Assess UI/UX impact: What components change? What's the user interaction flow?
- Evaluate accessibility implications: WCAG compliance maintained? Keyboard navigation?
- Analyze performance: Bundle size impact? Rendering performance? Core Web Vitals?
- Identify state management changes: What state updates? What side effects?
- Assess browser compatibility: Cross-browser testing needs? Polyfills required?
- Evaluate responsive design: Mobile/tablet/desktop behavior? Breakpoint changes?
""", partials_dir)

    create_partial("fullstack_engineer", "analyze", """### Persona Considerations — Fullstack Engineer

Analyze-specific guidance for fullstack engineers:
- Assess end-to-end impact: Frontend + backend + database changes coordinated?
- Evaluate API contract changes: Client-server synchronization? Data serialization?
- Analyze full-stack data flow: Request → processing → response → UI update
- Identify integration testing scope: What E2E scenarios? What integration points?
- Assess deployment coordination: Frontend/backend deployment order? Feature flags?
- Evaluate cross-layer performance: API latency + UI rendering + data fetching
""", partials_dir)

    create_partial("maintainer", "analyze", """### Persona Considerations — Maintainer

Analyze-specific guidance for maintainers:
- Assess versioning impact: Major/minor/patch? Breaking changes? Deprecations?
- Evaluate documentation needs: What docs updated? What examples? What migration guides?
- Analyze backwards compatibility: What breaks? What migration path?
- Identify release implications: Release notes? Changelog entries? Communication plan?
- Assess maintenance burden: Technical debt introduced? Future refactoring needed?
- Evaluate contributor impact: New contribution patterns? Updated guidelines?
""", partials_dir)

    create_partial("ml_engineer", "analyze", """### Persona Considerations — ML Engineer

Analyze-specific guidance for ML engineers:
- Assess model serving impact: Deployment changes? Serving infrastructure modifications?
- Evaluate training pipeline: Training data changes? Hyperparameter updates? Retraining needs?
- Analyze feature engineering: Feature store updates? Feature transformations? Data preprocessing?
- Identify monitoring needs: Model performance metrics? Drift detection? A/B testing setup?
- Assess MLOps impact: CI/CD for ML changes? Model registry updates? Rollback procedures?
- Evaluate production readiness: Latency requirements? Throughput? Scalability?
""", partials_dir)

    create_partial("product_manager", "analyze", """### Persona Considerations — Product Manager

Analyze-specific guidance for product managers:
- Assess user impact: What user workflows change? What's the value proposition?
- Evaluate business metrics: What KPIs affected? What success criteria? What risks?
- Analyze scope: Is this aligned with product vision? Is scope creep happening?
- Identify stakeholder implications: What teams affected? What communication needed?
- Assess prioritization: Is this the right priority? What dependencies? What sequencing?
- Evaluate go-to-market: Launch plan? User communication? Rollout strategy?
""", partials_dir)

    create_partial("sre", "analyze", """### Persona Considerations — SRE

Analyze-specific guidance for SREs:
- Assess reliability impact: SLO/SLI changes? Error budget implications? Failure modes?
- Evaluate operational readiness: Monitoring? Alerting? Runbooks? Incident response?
- Analyze scalability: Resource requirements? Auto-scaling? Capacity planning?
- Identify deployment risk: Rollout strategy? Canary deployment? Rollback procedures?
- Assess observability: Logging changes? Metrics? Tracing? Debugging capability?
- Evaluate infrastructure: IaC changes? Configuration management? Security posture?
""", partials_dir)

    # ============================================================================
    # REQUEST PARTIALS (11 personas - all except product_manager)
    # ============================================================================

    print("\nGenerating request.md partials...")

    create_partial("architect", "request", """### Persona Considerations — Architect

Request-specific guidance for architects:
- Focus on architectural constraints: What boundaries must be respected? What patterns required?
- Identify integration requirements: What systems interact? What contracts exist?
- Clarify scalability expectations: What load? What growth trajectory?
- Define quality attributes: Performance? Reliability? Maintainability? Security?
- Establish technology preferences: What stack? What tools? What frameworks?
- Identify architectural risks: What unknowns? What proof-of-concepts needed?
""", partials_dir)

    create_partial("backend_engineer", "request", """### Persona Considerations — Backend Engineer

Request-specific guidance for backend engineers:
- Focus on API requirements: What endpoints? What data models? What operations?
- Identify data persistence needs: What entities? What relationships? What queries?
- Clarify business logic: What processing? What validation? What workflows?
- Define performance expectations: Response times? Throughput? Concurrency?
- Establish error handling: What failure scenarios? What recovery strategies?
- Identify integration points: What external services? What data sources?
""", partials_dir)

    create_partial("data_engineer", "request", """### Persona Considerations — Data Engineer

Request-specific guidance for data engineers:
- Focus on data requirements: What data sources? What schemas? What volumes?
- Identify pipeline needs: Batch? Streaming? Hybrid? What frequency?
- Clarify transformations: What ETL logic? What data quality rules?
- Define performance targets: Latency? Throughput? Resource limits?
- Establish data governance: Compliance? Access control? Retention policies?
- Identify observability needs: Data lineage? Quality metrics? Pipeline monitoring?
""", partials_dir)

    create_partial("data_scientist", "request", """### Persona Considerations — Data Scientist

Request-specific guidance for data scientists:
- Focus on problem definition: What question? What hypothesis? What outcome?
- Identify data requirements: What features? What labels? What sample size?
- Clarify model expectations: Accuracy? Explainability? Latency? Fairness?
- Define success metrics: What KPIs? What baseline? What improvement target?
- Establish validation methodology: Train/test split? Cross-validation? Holdout set?
- Identify constraints: Computational resources? Data availability? Deployment environment?
""", partials_dir)

    create_partial("frontend_engineer", "request", """### Persona Considerations — Frontend Engineer

Request-specific guidance for frontend engineers:
- Focus on UI requirements: What screens? What components? What interactions?
- Identify UX expectations: User flows? Responsive behavior? Accessibility needs?
- Clarify visual design: Design system? Branding? Custom styling?
- Define performance targets: Load time? Interactivity? Animation smoothness?
- Establish state management: What data flows? What synchronization needs?
- Identify browser requirements: Support matrix? Progressive enhancement? Polyfills?
""", partials_dir)

    create_partial("fullstack_engineer", "request", """### Persona Considerations — Fullstack Engineer

Request-specific guidance for fullstack engineers:
- Focus on end-to-end requirements: User interaction → backend processing → data persistence
- Identify API contracts: What data exchange? What serialization? What validation?
- Clarify full-stack data flow: Client state → API calls → database operations
- Define integration points: Frontend-backend coordination? Real-time updates?
- Establish testing expectations: E2E scenarios? Integration tests? Component tests?
- Identify deployment needs: Frontend/backend coordination? Feature flags? Rollout strategy?
""", partials_dir)

    create_partial("maintainer", "request", """### Persona Considerations — Maintainer

Request-specific guidance for maintainers:
- Focus on versioning implications: Breaking changes? Deprecations? Migration needs?
- Identify documentation requirements: What docs? What examples? What guides?
- Clarify backwards compatibility: What must remain stable? What can change?
- Define release scope: What version? What release timeline? What communication?
- Establish contribution impact: New patterns? Updated guidelines? Community impact?
- Identify maintenance implications: Technical debt? Future refactoring? Support burden?
""", partials_dir)

    create_partial("ml_engineer", "request", """### Persona Considerations — ML Engineer

Request-specific guidance for ML engineers:
- Focus on model serving requirements: Latency? Throughput? Batch vs. real-time?
- Identify training needs: Training data? Compute resources? Hyperparameter tuning?
- Clarify feature engineering: Feature store? Transformations? Feature monitoring?
- Define deployment expectations: A/B testing? Canary rollout? Rollback capability?
- Establish monitoring needs: Model performance? Drift detection? Alerting?
- Identify MLOps requirements: CI/CD? Model registry? Experiment tracking?
""", partials_dir)

    create_partial("qa_engineer", "request", """### Persona Considerations — QA Engineer

Request-specific guidance for QA engineers:
- Focus on testability: What test scenarios? What edge cases? What failure modes?
- Identify quality requirements: Coverage targets? Performance benchmarks? Acceptance criteria?
- Clarify testing scope: Unit? Integration? E2E? Performance? Security?
- Define test automation: What frameworks? What CI/CD integration? What reporting?
- Establish quality gates: What must pass before merge? Before release?
- Identify test data needs: Mock data? Test fixtures? Production-like scenarios?
""", partials_dir)

    create_partial("security_compliance", "request", """### Persona Considerations — Security & Compliance

Request-specific guidance for security & compliance:
- Focus on security requirements: Authentication? Authorization? Data protection?
- Identify compliance needs: GDPR? SOC2? HIPAA? Industry-specific regulations?
- Clarify threat model: Attack vectors? Risk assessment? Mitigation strategies?
- Define security controls: Encryption? Secrets management? Audit logging?
- Establish vulnerability management: Scanning? Penetration testing? Remediation SLAs?
- Identify security review needs: Code review? Architecture review? Penetration testing?
""", partials_dir)

    create_partial("sre", "request", """### Persona Considerations — SRE

Request-specific guidance for SREs:
- Focus on reliability requirements: SLOs? Error budgets? Availability targets?
- Identify operational needs: Monitoring? Alerting? Incident response? Runbooks?
- Clarify scalability expectations: Traffic patterns? Resource auto-scaling? Capacity planning?
- Define observability requirements: Logging? Metrics? Tracing? Debugging capabilities?
- Establish deployment expectations: Rollout strategy? Canary testing? Rollback procedures?
- Identify infrastructure needs: IaC? Configuration management? Disaster recovery?
""", partials_dir)

    # ============================================================================
    # REVIEW PARTIALS (10 personas)
    # ============================================================================

    print("\nGenerating review.md partials...")

    create_partial("architect", "review", """### Persona Considerations — Architect

Review-specific guidance for architects:
- Validate architectural alignment: Does this follow established patterns and principles?
- Review integration contracts: Are service boundaries respected? Are contracts maintained?
- Assess scalability: Will this scale? Are there bottlenecks? Resource implications?
- Evaluate technical debt: Does this introduce shortcuts? Future refactoring needed?
- Review documentation: Architecture decisions documented? Design rationale clear?
- Validate quality attributes: Performance? Reliability? Maintainability? Security?
""", partials_dir)

    create_partial("backend_engineer", "review", """### Persona Considerations — Backend Engineer

Review-specific guidance for backend engineers:
- Validate API design: RESTful conventions? Versioning? Backwards compatibility?
- Review data access: Efficient queries? N+1 problems? Transaction boundaries?
- Assess error handling: Proper exceptions? Logging? Graceful degradation?
- Evaluate performance: Response times? Resource utilization? Caching strategies?
- Review testing: Unit tests? Integration tests? Edge cases covered?
- Validate code quality: SOLID principles? DRY? Readability? Maintainability?
""", partials_dir)

    create_partial("data_engineer", "review", """### Persona Considerations — Data Engineer

Review-specific guidance for data engineers:
- Validate pipeline logic: Correct transformations? Data quality checks? Error handling?
- Review data schemas: Correct types? Constraints? Indexes? Partitioning?
- Assess performance: Query efficiency? Resource utilization? Scalability?
- Evaluate data quality: Validation rules? Completeness checks? Consistency?
- Review observability: Data lineage tracked? Quality metrics? Pipeline monitoring?
- Validate testing: Data validation tests? Pipeline integration tests? Edge cases?
""", partials_dir)

    create_partial("data_scientist", "review", """### Persona Considerations — Data Scientist

Review-specific guidance for data scientists:
- Validate model performance: Metrics meet targets? Generalization? Overfitting?
- Review experiment methodology: Proper validation? Statistical significance? Reproducibility?
- Assess feature engineering: Feature quality? Feature importance? Data leakage?
- Evaluate model explainability: Interpretability? Bias detection? Fairness evaluation?
- Review code quality: Notebook organization? Code modularity? Documentation?
- Validate reproducibility: Random seeds? Versioned data? Environment dependencies?
""", partials_dir)

    create_partial("frontend_engineer", "review", """### Persona Considerations — Frontend Engineer

Review-specific guidance for frontend engineers:
- Validate UI/UX: Design system adherence? User flow correctness? Visual polish?
- Review accessibility: WCAG compliance? Keyboard navigation? Screen reader support?
- Assess performance: Bundle size? Load time? Core Web Vitals? Smooth interactions?
- Evaluate code quality: Component reusability? State management? Code organization?
- Review browser compatibility: Cross-browser testing? Graceful degradation? Polyfills?
- Validate responsive design: Mobile/tablet/desktop? Touch interactions? Viewport handling?
""", partials_dir)

    create_partial("fullstack_engineer", "review", """### Persona Considerations — Fullstack Engineer

Review-specific guidance for fullstack engineers:
- Validate end-to-end flow: Frontend → backend → database integration correct?
- Review API contracts: Client-server data synchronization? Error propagation?
- Assess full-stack performance: API latency + UI rendering optimized?
- Evaluate testing: E2E tests? Integration tests? Unit tests across layers?
- Review deployment coordination: Frontend/backend compatibility? Feature flags?
- Validate error handling: Client errors? Server errors? Network failures?
""", partials_dir)

    create_partial("ml_engineer", "review", """### Persona Considerations — ML Engineer

Review-specific guidance for ML engineers:
- Validate model serving: Correct inference logic? Latency requirements met? Error handling?
- Review feature engineering: Feature store integration? Transformation correctness?
- Assess monitoring: Model performance metrics? Drift detection? Alerting configured?
- Evaluate deployment: A/B test setup? Canary deployment? Rollback procedures?
- Review MLOps: CI/CD pipeline? Model registry? Experiment tracking?
- Validate production readiness: Resource requirements? Scalability? Observability?
""", partials_dir)

    create_partial("product_manager", "review", """### Persona Considerations — Product Manager

Review-specific guidance for product managers:
- Validate user value: Does this solve the user problem? Is UX intuitive?
- Review scope: Feature complete? Acceptance criteria met? No scope creep?
- Assess business impact: KPIs tracked? Success metrics defined? Rollout plan ready?
- Evaluate user communication: Release notes? User guides? Support documentation?
- Review risks: What could go wrong? Mitigation strategies? Rollback plan?
- Validate go-to-market readiness: Launch checklist complete? Stakeholders aligned?
""", partials_dir)

    create_partial("qa_engineer", "review", """### Persona Considerations — QA Engineer

Review-specific guidance for QA engineers:
- Validate test coverage: All scenarios tested? Edge cases? Failure modes?
- Review test quality: Tests pass consistently? Flaky tests fixed? Assertions correct?
- Assess quality gates: All gates passed? Performance benchmarks met? Security scans clean?
- Evaluate regression testing: Existing functionality unaffected? Smoke tests pass?
- Review defect resolution: All critical/high bugs fixed? Known issues documented?
- Validate release readiness: QA sign-off criteria met? Test reports complete?
""", partials_dir)

    create_partial("sre", "review", """### Persona Considerations — SRE

Review-specific guidance for SREs:
- Validate operational readiness: Monitoring configured? Alerts set up? Runbooks updated?
- Review reliability: SLOs met? Error budgets respected? Failure modes handled?
- Assess observability: Logging sufficient? Metrics collected? Tracing enabled?
- Evaluate deployment safety: Rollout plan safe? Rollback tested? Incident response ready?
- Review infrastructure: IaC changes correct? Configuration validated? Security hardened?
- Validate scalability: Load tested? Resource allocation correct? Auto-scaling configured?
""", partials_dir)

    # ============================================================================
    # PUSH PARTIALS (11 personas - all except maintainer)
    # ============================================================================

    print("\nGenerating push.md partials...")

    create_partial("architect", "push", """### Persona Considerations — Architect

Push-specific guidance for architects:
- Verify architectural documentation: ADRs updated? Design decisions documented?
- Validate integration readiness: Service contracts stable? Integration tests pass?
- Confirm scalability verification: Load tested? Resource requirements validated?
- Check technical debt tracking: Known compromises documented? Future work planned?
- Verify quality attributes: Performance benchmarks met? Reliability validated?
- Ensure architectural review sign-off: Architectural standards followed?
""", partials_dir)

    create_partial("backend_engineer", "push", """### Persona Considerations — Backend Engineer

Push-specific guidance for backend engineers:
- Verify API stability: No breaking changes? Versioning correct? Backwards compatible?
- Validate database migrations: Migration scripts tested? Rollback procedures ready?
- Confirm integration testing: All service integrations tested? Mocks removed?
- Check error handling: All error cases covered? Logging sufficient? Graceful degradation?
- Verify performance: Benchmarks met? Resource usage acceptable? Queries optimized?
- Ensure code quality: Linting passes? Code review approved? Tests pass?
""", partials_dir)

    create_partial("data_engineer", "push", """### Persona Considerations — Data Engineer

Push-specific guidance for data engineers:
- Verify pipeline stability: All pipelines tested? Data quality checks pass?
- Validate schema changes: Migration scripts correct? Backwards compatible?
- Confirm data lineage: Lineage tracking updated? Metadata correct?
- Check performance: Query performance acceptable? Resource usage within limits?
- Verify observability: Pipeline monitoring configured? Data quality metrics tracked?
- Ensure data governance: Compliance requirements met? Access controls correct?
""", partials_dir)

    create_partial("data_scientist", "push", """### Persona Considerations — Data Scientist

Push-specific guidance for data scientists:
- Verify model performance: Validation metrics acceptable? No overfitting? Generalization confirmed?
- Validate reproducibility: Experiments reproducible? Data/code versioned? Random seeds set?
- Confirm documentation: Model card complete? Experiment notes documented? Methodology clear?
- Check code quality: Notebook clean? Code modular? Dependencies documented?
- Verify model artifacts: Model saved correctly? Serialization tested? Versioning correct?
- Ensure experiment tracking: Experiments logged? Hyperparameters recorded? Results tracked?
""", partials_dir)

    create_partial("frontend_engineer", "push", """### Persona Considerations — Frontend Engineer

Push-specific guidance for frontend engineers:
- Verify UI/UX quality: Design system followed? User flows tested? Visual QA passed?
- Validate accessibility: WCAG compliance verified? Keyboard navigation tested? Screen reader compatible?
- Confirm performance: Bundle size acceptable? Load time within budget? Core Web Vitals green?
- Check browser compatibility: Cross-browser tested? Graceful degradation verified?
- Verify responsive design: Mobile/tablet/desktop tested? Touch interactions work?
- Ensure code quality: Linting passes? Component tests pass? Code review approved?
""", partials_dir)

    create_partial("fullstack_engineer", "push", """### Persona Considerations — Fullstack Engineer

Push-specific guidance for fullstack engineers:
- Verify end-to-end integration: Frontend + backend integration tested? Data flow correct?
- Validate API contracts: Client-server synchronization works? Error handling across layers?
- Confirm deployment coordination: Frontend/backend versions compatible? Feature flags correct?
- Check full-stack testing: E2E tests pass? Integration tests pass? Unit tests pass?
- Verify performance: End-to-end latency acceptable? Resource usage optimized?
- Ensure monitoring: Full-stack observability configured? Error tracking across layers?
""", partials_dir)

    create_partial("ml_engineer", "push", """### Persona Considerations — ML Engineer

Push-specific guidance for ML engineers:
- Verify model serving: Inference pipeline tested? Latency requirements met? Error handling correct?
- Validate feature engineering: Feature store updated? Transformations correct? Feature monitoring configured?
- Confirm deployment: A/B test configured? Canary rollout ready? Rollback procedures tested?
- Check monitoring: Model performance metrics tracked? Drift detection configured? Alerts set up?
- Verify MLOps: CI/CD pipeline passes? Model registry updated? Experiment tracking complete?
- Ensure production readiness: Resource allocation correct? Scalability validated? Observability configured?
""", partials_dir)

    create_partial("product_manager", "push", """### Persona Considerations — Product Manager

Push-specific guidance for product managers:
- Verify user value: Feature complete? Acceptance criteria met? User validation done?
- Validate business metrics: KPIs tracked? Success metrics defined? Analytics configured?
- Confirm communication readiness: Release notes drafted? User guides ready? Support docs updated?
- Check stakeholder alignment: All approvals received? Teams notified? Dependencies resolved?
- Verify rollout plan: Phased rollout strategy? Feature flags configured? Rollback plan ready?
- Ensure go-to-market readiness: Launch checklist complete? Marketing aligned? Support team briefed?
""", partials_dir)

    create_partial("qa_engineer", "push", """### Persona Considerations — QA Engineer

Push-specific guidance for QA engineers:
- Verify test completion: All test cases executed? Edge cases tested? Failure modes validated?
- Validate quality gates: All gates passed? Code coverage met? Performance benchmarks met?
- Confirm regression testing: Smoke tests pass? Existing functionality unaffected? No new bugs?
- Check defect status: All critical/high bugs resolved? Known issues documented? Workarounds communicated?
- Verify test automation: Automated tests pass? CI/CD integration works? Test reports generated?
- Ensure release sign-off: QA approval granted? Test evidence documented? Quality metrics met?
""", partials_dir)

    create_partial("security_compliance", "push", """### Persona Considerations — Security & Compliance

Push-specific guidance for security & compliance:
- Verify security controls: Authentication/authorization correct? Data encryption enabled? Secrets secured?
- Validate compliance: Compliance requirements met? Audit logs configured? Privacy controls in place?
- Confirm vulnerability remediation: Security scans clean? Vulnerabilities addressed? Dependencies updated?
- Check security review: Code security review done? Architecture security review done? Penetration testing complete?
- Verify incident response: Incident procedures updated? Security monitoring configured? Alerting working?
- Ensure audit readiness: Audit logs complete? Compliance evidence documented? Change tracking enabled?
""", partials_dir)

    create_partial("sre", "push", """### Persona Considerations — SRE

Push-specific guidance for SREs:
- Verify operational readiness: Monitoring active? Alerts configured? Runbooks updated? On-call notified?
- Validate reliability: SLOs met? Error budgets respected? Load testing complete? Failure modes tested?
- Confirm observability: Logging working? Metrics collected? Tracing enabled? Debugging possible?
- Check deployment safety: Rollout plan validated? Canary deployment tested? Rollback procedures verified?
- Verify infrastructure: IaC applied? Configuration validated? Security hardened? Resource allocation correct?
- Ensure incident readiness: Incident response procedures ready? Escalation paths clear? Rollback tested?
""", partials_dir)

    # ============================================================================
    # SUMMARY
    # ============================================================================

    print("\n" + "=" * 42)
    print("Summary:")
    print("=" * 42)
    print(f"{GREEN}✓ Created:{NC} {created} files")
    print(f"{YELLOW}⊘ Skipped:{NC} {skipped} files (already existed)")
    if failed > 0:
        print(f"{RED}✗ Failed:{NC} {failed} files")
    print()

    if failed > 0:
        print(f"{RED}Some files failed to create. Please review the errors above.{NC}")
        sys.exit(1)
    else:
        print(f"{GREEN}All persona partials generated successfully!{NC}")
        sys.exit(0)


if __name__ == "__main__":
    main()
