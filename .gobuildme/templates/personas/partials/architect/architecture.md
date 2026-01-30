## Architect-Specific Architecture Documentation

As the **Architect** persona, you are the primary owner of the `/gbm.architecture` command. Your focus is on establishing and maintaining comprehensive architectural documentation that guides all development decisions.

### Architecture Decision Records (ADRs)

**Required**: Document all significant architectural decisions in `.gobuildme/docs/technical/architecture/decisions/`

For each major decision, create an ADR with:
- **Context**: What problem or requirement drove this decision?
- **Decision**: What was decided and why?
- **Alternatives Considered**: What other options were evaluated?
- **Rationale**: Why was this option chosen over alternatives?
- **Consequences**: What are the trade-offs and implications?
- **Status**: Proposed, Accepted, Deprecated, Superseded

**Examples of decisions requiring ADRs**:
- Choice of architectural style (monolith, microservices, serverless)
- Technology stack selections (frameworks, databases, message queues)
- Integration patterns (REST, GraphQL, gRPC, event-driven)
- Data storage strategies (SQL, NoSQL, caching layers)
- Authentication/authorization approaches
- Deployment and infrastructure decisions

### Technology Stack Documentation

**Required**: Document the complete technology stack in `overview.md`

Include:
- **Languages**: Primary and secondary languages with version requirements
- **Frameworks**: Web frameworks, testing frameworks, build tools
- **Databases**: Primary data stores, caching layers, search engines
- **Infrastructure**: Cloud providers, container orchestration, CI/CD
- **External Services**: Third-party APIs, SaaS integrations
- **Development Tools**: IDEs, linters, formatters, debuggers

For each technology, document:
- **Version requirements**: Minimum and recommended versions
- **Rationale**: Why this technology was chosen
- **Alternatives**: What was considered and rejected
- **Migration path**: How to upgrade or replace if needed
- **Known limitations**: Issues, gotchas, or constraints

### Architectural Patterns

**Required**: Document established patterns in `.gobuildme/docs/technical/architecture/patterns/`

Key patterns to document:
- **Layering**: How the system is layered (presentation, business logic, data access)
- **Module boundaries**: How code is organized into modules/packages
- **Dependency rules**: What can depend on what (e.g., no circular dependencies)
- **Error handling**: Standard error handling patterns
- **Logging and monitoring**: How observability is implemented
- **Configuration management**: How configuration is handled
- **Testing strategies**: Unit, integration, e2e testing approaches

### System Boundaries and Constraints

**Required**: Define clear boundaries and constraints

Document:
- **System context**: What's inside vs. outside the system
- **Bounded contexts**: If using DDD, define bounded contexts
- **Integration points**: Where the system connects to external systems
- **Scalability constraints**: Known limits and bottlenecks
- **Performance requirements**: Latency, throughput, resource usage
- **Security boundaries**: Trust boundaries, authentication points
- **Compliance requirements**: Regulatory or policy constraints

### Quality Attributes

**Required**: Document quality attribute requirements

Address:
- **Performance**: Response time, throughput, resource utilization
- **Scalability**: Horizontal/vertical scaling capabilities
- **Reliability**: Uptime requirements, fault tolerance, disaster recovery
- **Security**: Authentication, authorization, data protection, audit
- **Maintainability**: Code quality, documentation, testability
- **Usability**: User experience, accessibility, internationalization
- **Deployability**: Deployment frequency, rollback capability, zero-downtime

### Architecture Validation

**Required**: Establish validation criteria

Define how to validate:
- **Compliance checks**: Automated checks for architectural rules
- **Dependency analysis**: Tools to detect violations
- **Performance benchmarks**: Baseline performance metrics
- **Security scans**: Automated security validation
- **Code review criteria**: What reviewers should check

### Evolution and Maintenance

**Required**: Plan for architectural evolution

Document:
- **Technical debt**: Known architectural debt and remediation plans
- **Deprecation strategy**: How to phase out old patterns
- **Migration paths**: How to evolve the architecture
- **Refactoring guidelines**: When and how to refactor
- **Breaking changes**: How to handle breaking architectural changes

### Communication and Collaboration

**Required**: Ensure architecture is communicated effectively

Establish:
- **Architecture review process**: When and how architecture is reviewed
- **Stakeholder communication**: How to communicate decisions
- **Documentation standards**: How architecture docs are maintained
- **Onboarding materials**: How new team members learn the architecture
- **Architecture diagrams**: Visual representations of the system

### Architect Checklist for `/gbm.architecture`

Before completing the architecture documentation, verify:

- [ ] **ADRs Created**: All major decisions have ADRs
- [ ] **Technology Stack Documented**: Complete stack with rationale
- [ ] **Patterns Established**: Key patterns documented with examples
- [ ] **Boundaries Defined**: Clear system boundaries and constraints
- [ ] **Quality Attributes**: Non-functional requirements documented
- [ ] **Validation Criteria**: How to validate architectural compliance
- [ ] **Evolution Plan**: How architecture will evolve
- [ ] **Communication Plan**: How architecture is shared and maintained
- [ ] **Diagrams Created**: Visual representations of architecture
- [ ] **Review Scheduled**: Architecture review with stakeholders planned

### Architecture Accuracy Guidelines (CRITICAL)

**Authentication Classification:**
- **Identity PROVIDERS** = WHO authenticates (Okta, Auth0, Keycloak, internal user service)
- **Authentication METHODS** = HOW users authenticate (Password, Magic Links, MFA, SSO, OAuth flow)
- **CRITICAL**: Magic Links is a METHOD, not a provider. List it under authentication methods, NOT identity providers.
- Example: "Auth0 (provider) with Magic Link + Password methods" - NOT "Magic Links (Identity Provider)"

**Data Storage Documentation:**
- Only list databases the app connects to DIRECTLY
- Check dependencies for database drivers (psycopg2, mysql2, mongoose, pg, typeorm, prisma)
- If NO database drivers found: Document as "API-based persistence" or "Data persisted via [Service] API"
- Example: "Data persisted via Classy APIv2" NOT "PostgreSQL (via API)" - the app doesn't connect to PostgreSQL directly
- When unsure: Trace data persistence code to verify actual connection vs API call

**Accuracy Checklist (Human Review Recommended):**
- [ ] Identity Providers are actual providers (not methods or protocols)
- [ ] Databases listed only if app has direct connection (drivers in dependencies)
- [ ] Each listed integration is actually USED in code (not just referenced)
- [ ] Versions match dependency files (package.json, requirements.txt, composer.json)
- [ ] Architectural style matches actual codebase structure

### Integration with Other Commands

As the architect, ensure:
- `/gbm.plan` validates against architectural constraints
- `/gbm.review` checks architectural compliance
- `/gbm.implement` follows architectural patterns
- `/gbm.tests` validates architectural boundaries

