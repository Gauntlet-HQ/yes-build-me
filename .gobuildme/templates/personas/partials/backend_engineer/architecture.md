## Backend Engineer-Specific Architecture Documentation

As a **Backend Engineer**, your focus is on documenting the backend architecture, API design, data models, and service interactions.

### API Architecture

**Required**: Document API design in `.gobuildme/docs/technical/architecture/patterns/api-design.md`

Include:
- **API Style**: REST, GraphQL, gRPC, or hybrid approach
- **Versioning Strategy**: How APIs are versioned (URL, header, content negotiation)
- **Authentication**: How clients authenticate (OAuth2, JWT, API keys)
- **Authorization**: How permissions are enforced (RBAC, ABAC)
- **Rate Limiting**: How rate limits are implemented and communicated
- **Error Handling**: Standard error response format and codes
- **Pagination**: How large result sets are paginated
- **Filtering and Sorting**: Query parameter conventions
- **Caching**: Cache headers, ETags, cache invalidation strategy
- **Documentation**: API documentation approach (OpenAPI, GraphQL schema)

### Database Architecture

**Required**: Document database design in `.gobuildme/docs/technical/architecture/patterns/database.md`

Include:
- **Database Type**: SQL, NoSQL, or polyglot persistence
- **Schema Design**: Entity relationships, normalization level
- **Indexing Strategy**: What indexes exist and why
- **Query Patterns**: Common query patterns and optimizations
- **Transactions**: Transaction boundaries and isolation levels
- **Migrations**: How schema changes are managed
- **Backup and Recovery**: Backup strategy and RTO/RPO
- **Scaling Strategy**: Read replicas, sharding, partitioning
- **Data Retention**: How long data is kept and archival strategy

### Service Architecture

**Required**: Document service boundaries and interactions

Include:
- **Service Decomposition**: How functionality is split into services
- **Service Communication**: Synchronous (HTTP) vs. asynchronous (messaging)
- **Service Discovery**: How services find each other
- **Load Balancing**: How traffic is distributed
- **Circuit Breakers**: Fault tolerance patterns
- **Retry Logic**: Retry strategies and backoff algorithms
- **Timeouts**: Timeout configurations for service calls
- **Bulkheads**: Resource isolation patterns

### Data Flow and Processing

**Required**: Document how data flows through the system

Include:
- **Request Flow**: How requests are processed end-to-end
- **Data Pipelines**: ETL/ELT processes if applicable
- **Event Processing**: Event-driven architecture patterns
- **Message Queues**: Queue usage, topics, and consumers
- **Batch Processing**: Scheduled jobs and batch operations
- **Stream Processing**: Real-time data processing if applicable

### Performance Considerations

**Required**: Document performance architecture

Include:
- **Caching Strategy**: What is cached, where, and for how long
- **Database Optimization**: Query optimization, connection pooling
- **Async Processing**: Background jobs, task queues
- **Resource Limits**: Connection limits, thread pools, memory limits
- **Performance Monitoring**: What metrics are tracked
- **Bottleneck Identification**: Known bottlenecks and mitigation

### Security Architecture

**Required**: Document backend security measures

Include:
- **Input Validation**: How inputs are validated and sanitized
- **SQL Injection Prevention**: Parameterized queries, ORMs
- **Authentication Flow**: How users authenticate
- **Authorization Model**: How permissions are checked
- **Secrets Management**: How secrets are stored and accessed
- **Encryption**: Data at rest and in transit
- **Audit Logging**: What security events are logged

### Backend Engineer Checklist for `/gbm.architecture`

Before completing the architecture documentation, verify:

- [ ] **API Design Documented**: Complete API patterns and conventions
- [ ] **Database Schema**: Entity relationships and indexing strategy
- [ ] **Service Boundaries**: Clear service responsibilities
- [ ] **Data Flow**: Request and data processing flows documented
- [ ] **Performance Strategy**: Caching, optimization, and scaling plans
- [ ] **Security Measures**: Authentication, authorization, and data protection
- [ ] **Error Handling**: Standard error patterns documented
- [ ] **Monitoring**: What backend metrics are tracked
- [ ] **Integration Points**: External service integrations documented
- [ ] **Deployment**: How backend services are deployed

