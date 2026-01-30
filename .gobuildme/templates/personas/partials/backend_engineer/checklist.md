### Backend Engineer Quality Dimensions

When validating backend requirements and specifications, ensure these quality dimensions are addressed:

#### API Design & Contracts

**REST API Design**:
- Are RESTful principles followed consistently?
- Are HTTP methods used semantically (GET, POST, PUT, PATCH, DELETE)?
- Is resource naming convention documented?
- Are URI structure guidelines specified?

**API Contracts**:
- Are all endpoints documented with HTTP method and path?
- Are request body schemas defined with data types and constraints?
- Are response schemas defined for all status codes (2xx, 4xx, 5xx)?
- Are header requirements specified (authentication, content-type)?

**API Versioning**:
- Is API versioning strategy specified (URL path, header, query param)?
- Are version deprecation policies documented?
- Is backward compatibility strategy defined?
- Are version migration paths specified?

**GraphQL Design** (if applicable):
- Is GraphQL schema documented?
- Are query/mutation/subscription types defined?
- Is resolver implementation strategy specified?
- Are N+1 query prevention strategies documented?

#### Data Model & Persistence

**Database Schema**:
- Is database schema documented (tables, columns, types)?
- Are relationships clearly defined (one-to-one, one-to-many, many-to-many)?
- Are indexes specified for query optimization?
- Are constraints documented (primary keys, foreign keys, unique, check)?

**Data Modeling**:
- Is normalization/denormalization strategy documented?
- Are data access patterns identified?
- Is sharding strategy specified (if applicable)?
- Are partitioning requirements defined?

**Migrations**:
- Is migration strategy specified (forward, backward)?
- Are migration rollback procedures documented?
- Is zero-downtime migration strategy defined?
- Are data backfill requirements specified?

**ORM/Query Builder**:
- Is ORM/query builder specified (SQLAlchemy, Prisma, TypeORM)?
- Are query patterns documented?
- Is lazy/eager loading strategy defined?
- Are transaction management requirements specified?

#### Authentication & Authorization

**Authentication Mechanisms**:
- Is authentication method specified (JWT, OAuth2, session-based)?
- Are token generation/validation requirements documented?
- Is password hashing algorithm specified (bcrypt, argon2)?
- Are multi-factor authentication requirements defined?

**Authorization Model**:
- Is authorization model clearly defined (RBAC, ABAC, policy-based)?
- Are permission checking requirements documented?
- Is role hierarchy specified?
- Are resource-level permissions defined?

**Session Management**:
- Is session storage strategy specified?
- Are session expiration policies documented?
- Is session refresh strategy defined?
- Are concurrent session handling requirements specified?

**API Security**:
- Are rate limiting requirements defined per endpoint?
- Is throttling strategy documented?
- Are CORS policies specified?
- Is API key management strategy defined?

#### Business Logic & Service Layer

**Service Architecture**:
- Is service layer architecture documented?
- Are service responsibilities clearly defined?
- Is service-to-service communication pattern specified?
- Are service boundaries documented?

**Business Logic Organization**:
- Is business logic separation from controllers documented?
- Are domain model patterns specified?
- Is validation logic organization strategy defined?
- Are use case/command patterns documented?

**Transaction Management**:
- Is transaction boundary strategy specified?
- Are isolation level requirements documented?
- Is distributed transaction strategy defined (if applicable)?
- Are rollback/compensation strategies specified?

**Domain Events**:
- Is domain event strategy specified?
- Are event types and payloads documented?
- Is event sourcing strategy defined (if applicable)?
- Are event handling patterns specified?

#### Error Handling & Logging

**Error Response Format**:
- Is error response format standardized?
- Are error codes documented?
- Is error message strategy specified (user-facing vs. internal)?
- Are error details structure requirements defined?

**Exception Handling**:
- Is exception handling strategy documented?
- Are exception hierarchies defined?
- Is global exception handler pattern specified?
- Are retry strategies for transient errors documented?

**Logging Strategy**:
- Are log levels used consistently (DEBUG, INFO, WARN, ERROR)?
- Is logging format specified (structured logging)?
- Are sensitive data logging prevention measures documented?
- Is log correlation strategy defined (trace IDs, request IDs)?

**Observability**:
- Are metrics to be collected specified?
- Is distributed tracing strategy documented?
- Are health check endpoints defined?
- Is log aggregation strategy specified?

#### Performance & Scalability

**Performance Requirements**:
- Are response time targets specified (p50, p95, p99)?
- Are throughput requirements defined (requests per second)?
- Are resource utilization limits documented (CPU, memory)?
- Are database query performance targets specified?

**Caching Strategy**:
- Is caching solution specified (Redis, Memcached)?
- Are cache invalidation strategies documented?
- Is cache key naming convention defined?
- Are TTL requirements specified per cache type?

**Connection Pooling**:
- Is connection pool configuration specified?
- Are pool size requirements documented?
- Is connection timeout strategy defined?
- Are connection leak detection requirements specified?

**Scalability Strategy**:
- Is horizontal scaling strategy documented?
- Are stateless service requirements specified?
- Is load balancing strategy defined?
- Are auto-scaling triggers documented?

#### Data Validation & Sanitization

**Input Validation**:
- Are validation rules defined for all input parameters?
- Is validation error response format specified?
- Are data type validation requirements documented?
- Are business rule validation requirements defined?

**Request Validation**:
- Is request schema validation strategy specified?
- Are required/optional fields clearly documented?
- Is field constraint validation defined (min, max, pattern)?
- Are nested object validation requirements specified?

**Data Sanitization**:
- Is input sanitization strategy documented?
- Are SQL injection prevention measures specified?
- Is NoSQL injection prevention strategy defined?
- Are command injection prevention requirements documented?

#### Background Jobs & Queues

**Job Queue System**:
- Is job queue solution specified (Celery, Bull, Sidekiq)?
- Are queue architecture patterns documented?
- Is message serialization format defined?
- Are queue monitoring requirements specified?

**Job Processing**:
- Are job types and handlers documented?
- Is retry strategy specified for failed jobs?
- Are job timeout requirements defined?
- Is dead letter queue strategy documented?

**Scheduled Tasks**:
- Are scheduled task requirements specified?
- Is scheduling mechanism documented (cron, interval)?
- Are task overlap prevention strategies defined?
- Are task execution logging requirements specified?

**Async Processing**:
- Is async processing strategy specified?
- Are callback/webhook patterns documented?
- Is long-running operation handling strategy defined?
- Are progress tracking requirements specified?

#### External Service Integration

**Third-Party APIs**:
- Are external API dependencies documented?
- Is API client implementation strategy specified?
- Are retry/timeout strategies for external calls defined?
- Is circuit breaker pattern requirement specified?

**Service Mesh** (if applicable):
- Is service mesh solution specified?
- Are service discovery requirements documented?
- Is load balancing strategy defined?
- Are traffic management policies specified?

**Message Brokers** (if applicable):
- Is message broker solution specified (Kafka, RabbitMQ)?
- Are message schemas documented?
- Is consumer/producer pattern defined?
- Are exactly-once delivery requirements specified?

**Webhook Integration**:
- Is webhook handling strategy specified?
- Are webhook signature verification requirements documented?
- Is retry strategy for webhook delivery defined?
- Are webhook payload schemas specified?

#### Testing Strategy

**Unit Testing**:
- Are unit test requirements specified for services?
- Is test coverage target defined?
- Is mocking strategy documented?
- Are test data builders/factories specified?

**Integration Testing**:
- Are integration test scenarios documented?
- Is database test isolation strategy specified?
- Are external service mocking requirements defined?
- Is integration test data management strategy documented?

**API Testing**:
- Are API test scenarios specified?
- Is contract testing strategy documented?
- Are API test automation requirements defined?
- Is API testing tool specified (Postman, REST Assured)?

**Performance Testing**:
- Are load test scenarios specified?
- Is stress testing strategy documented?
- Are performance benchmarks defined?
- Is performance regression detection strategy specified?

#### Deployment & Infrastructure

**Container Strategy**:
- Is containerization strategy specified (Docker)?
- Are Dockerfile requirements documented?
- Is multi-stage build strategy defined?
- Are container security requirements specified?

**Orchestration**:
- Is orchestration platform specified (Kubernetes, ECS)?
- Are deployment manifests documented?
- Is rolling update strategy defined?
- Are health check/readiness probe requirements specified?

**Configuration Management**:
- Is configuration management strategy specified?
- Are environment-specific config requirements documented?
- Is secrets management strategy defined?
- Are feature flag requirements specified?

**Database Migration**:
- Is database migration strategy specified?
- Are migration tool requirements documented (Flyway, Liquibase)?
- Is zero-downtime migration strategy defined?
- Are migration rollback procedures specified?

#### Monitoring & Alerting

**Application Monitoring**:
- Are application metrics specified?
- Is APM solution documented (New Relic, Datadog)?
- Are custom metrics requirements defined?
- Is metrics retention policy specified?

**Alerting Strategy**:
- Are alerting rules documented?
- Is alert severity classification defined?
- Are alert notification channels specified?
- Is on-call escalation policy documented?

**Incident Response**:
- Is incident response process documented?
- Are runbook requirements specified?
- Is incident postmortem process defined?
- Are SLA/SLO requirements documented?

#### Security

**Dependency Security**:
- Is dependency vulnerability scanning strategy specified?
- Are dependency update policies documented?
- Is security advisory monitoring strategy defined?
- Are vulnerable dependency remediation requirements specified?

**Secrets Management**:
- Is secrets storage solution specified (Vault, AWS Secrets Manager)?
- Are secret rotation requirements documented?
- Is secret access control strategy defined?
- Are secret injection mechanisms specified?

**Data Protection**:
- Is data encryption at rest strategy specified?
- Is data encryption in transit requirements documented?
- Are PII handling requirements defined?
- Is data masking strategy specified?

**Compliance**:
- Are regulatory compliance requirements identified?
- Is audit logging strategy documented?
- Are data retention policies defined?
- Is compliance validation strategy specified?

---

**Quality Gate Checklist**: Before marking specification as "ready for development":

- [ ] API design follows REST principles with complete contracts and versioning strategy
- [ ] Data model, persistence strategy, and migrations are documented
- [ ] Authentication and authorization mechanisms are clearly specified
- [ ] Business logic organization and service architecture are defined
- [ ] Error handling, logging, and observability strategy are comprehensive
- [ ] Performance requirements and scalability strategy are documented
- [ ] Data validation, sanitization, and security measures are specified
- [ ] Background jobs, queues, and async processing strategy are defined
- [ ] External service integration patterns are documented
- [ ] Testing strategy covers unit, integration, API, and performance testing
- [ ] Deployment, infrastructure, and configuration management are specified
- [ ] Monitoring, alerting, and incident response procedures are defined
- [ ] Security requirements include dependency scanning, secrets management, and data protection
