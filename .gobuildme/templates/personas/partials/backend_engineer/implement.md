### Persona-Specific Implementation Guidance — Backend Engineer

Implementation best practices for backend development:

**API Design & Implementation**:
- Design RESTful APIs following HTTP semantics and standard status codes
- Use consistent URL patterns and resource naming conventions
- Implement proper HTTP method usage (GET, POST, PUT, PATCH, DELETE)
- Version APIs from the start (/v1/, /v2/ or Accept headers)
- Document APIs with OpenAPI/Swagger specifications
- Use appropriate response formats (JSON, XML, Protocol Buffers)

**Service Layer Architecture**:
- Separate business logic from controllers/handlers
- Implement service layer for complex business operations
- Use dependency injection for loose coupling
- Follow single responsibility principle for services
- Implement proper transaction boundaries
- Design for testability with clear interfaces

**Database Operations**:
- Use ORM/query builders for type safety and consistency
- Implement proper connection pooling and management
- Write efficient queries with appropriate indexes
- Use database migrations for schema changes
- Implement soft deletes for data retention requirements
- Handle database transactions with proper ACID guarantees
- Optimize N+1 query problems with eager loading

**Error Handling & Validation**:
- Validate inputs at API boundary (request validation middleware)
- Return consistent error response structures across endpoints
- Use appropriate HTTP status codes for different error types
- Implement proper exception handling and logging
- Provide meaningful error messages without exposing internals
- Handle edge cases and boundary conditions

**Security Implementation**:
- Implement JWT or session-based authentication
- Use bcrypt/Argon2 for password hashing
- Implement proper authorization checks at service layer
- Sanitize all user inputs to prevent injection attacks
- Use parameterized queries to prevent SQL injection
- Implement rate limiting to prevent abuse
- Follow OWASP Top 10 security guidelines
- Store secrets in environment variables or secret managers

**Data Access Patterns**:
- Implement repository pattern for data access abstraction
- Use caching strategically (Redis, Memcached)
- Implement proper cache invalidation strategies
- Design database schemas with normalization/denormalization trade-offs
- Use database constraints for data integrity
- Implement pagination for large datasets
- Consider read replicas for high-traffic read operations

**Background Jobs & Async Processing**:
- Use job queues (Celery, Bull, Sidekiq) for long-running tasks
- Implement proper job retry logic with exponential backoff
- Design idempotent jobs to handle duplicate executions
- Monitor job queue depth and processing times
- Implement job timeouts and failure handling
- Use dead letter queues for failed jobs

**API Integration & External Services**:
- Implement circuit breakers for external service calls
- Use proper timeout and retry strategies
- Handle rate limits from external APIs
- Implement fallback mechanisms for service failures
- Use API client libraries when available
- Mock external services in tests

**Observability & Monitoring**:
- Implement structured logging with consistent log levels
- Add correlation IDs to track requests across services
- Instrument code with metrics (response times, error rates)
- Use APM tools (New Relic, DataDog, Application Insights)
- Monitor database query performance
- Set up alerts for critical errors and performance degradation
- Implement health check endpoints for load balancers

**Performance Optimization**:
- Profile code to identify bottlenecks
- Implement database query optimization
- Use connection pooling and reuse
- Implement request/response compression
- Cache expensive computations
- Use async/non-blocking I/O where appropriate
- Optimize serialization/deserialization

**Testing Strategy**:
- Write unit tests for business logic and services
- Implement integration tests for database operations
- Create contract tests for API endpoints
- Use test fixtures and factories for consistent test data
- Mock external dependencies in unit tests
- Test error scenarios and edge cases
- Achieve minimum 85% code coverage

**Database Migration Management**:
- Write reversible migrations with up/down methods
- Test migrations on production-like data volumes
- Implement zero-downtime migration strategies
- Use feature flags for gradual rollout of schema changes
- Backup database before running migrations
- Document breaking changes and migration steps

**Deployment & DevOps**:
- Containerize applications with Docker
- Use environment-specific configuration
- Implement proper dependency management
- Create deployment scripts for automation
- Set up CI/CD pipelines for automated testing and deployment
- Implement blue-green or canary deployments
- Monitor deployments with proper rollback procedures

**Documentation**:
- Maintain API documentation (OpenAPI/Swagger)
- Document service architecture and dependencies
- Create runbooks for operational procedures
- Document environment variables and configuration
- Maintain database schema documentation
- Write clear code comments for complex logic
