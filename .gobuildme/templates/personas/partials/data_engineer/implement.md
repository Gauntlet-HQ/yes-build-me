### Persona-Specific Implementation Guidance — Data Engineer

Implementation best practices for data engineering:

**Data Pipeline Architecture**:
- Design pipelines with clear stages (extract, transform, load)
- Implement proper orchestration (Airflow, Prefect, Dagster)
- Use directed acyclic graphs (DAGs) for pipeline definitions
- Design for idempotency to handle reruns safely
- Implement proper dependency management between tasks
- Use proper task scheduling and triggering mechanisms
- Design for horizontal scalability

**Data Quality & Validation**:
- Implement data quality checks at ingestion points
- Define and enforce data contracts between systems
- Validate data types, formats, and ranges
- Implement schema validation and evolution
- Use data quality frameworks (Great Expectations, Deequ)
- Set up data quality metrics and monitoring
- Implement proper handling of bad/invalid records
- Create data quality dashboards and alerts

**ETL/ELT Implementation**:
- Choose appropriate pattern (ETL vs. ELT) based on use case
- Implement incremental processing for large datasets
- Use proper partitioning strategies (time-based, hash-based)
- Implement checkpointing for long-running jobs
- Handle late-arriving data appropriately
- Implement proper data deduplication strategies
- Use batch processing for large volumes, streaming for real-time needs

**Data Transformation**:
- Write transformations as pure functions when possible
- Implement proper data type conversions and coercion
- Handle missing values with clear strategies (fill, drop, impute)
- Implement proper joins and aggregations efficiently
- Use window functions for time-series operations
- Implement proper filtering and sampling strategies
- Optimize transformation performance with appropriate frameworks

**Database & Data Store Operations**:
- Choose appropriate storage solutions (SQL, NoSQL, data lakes)
- Implement proper indexing strategies for query performance
- Use partitioning and clustering for large tables
- Implement proper data retention and archival policies
- Optimize table schemas for query patterns
- Use appropriate compression formats (Parquet, ORC, Avro)
- Implement proper backup and disaster recovery strategies

**Streaming Data Processing**:
- Implement real-time processing with Kafka, Kinesis, or Pub/Sub
- Design for at-least-once or exactly-once semantics
- Implement proper windowing strategies (tumbling, sliding, session)
- Handle out-of-order events appropriately
- Implement proper state management in streaming jobs
- Use watermarks for late data handling
- Monitor lag and throughput metrics

**Performance Optimization**:
- Profile pipelines to identify bottlenecks
- Implement proper parallelization and partitioning
- Use appropriate cluster sizing for workloads
- Optimize memory usage and garbage collection
- Use broadcast joins for small dimension tables
- Implement proper caching strategies
- Use columnar storage formats for analytics workloads
- Optimize shuffle operations in distributed processing

**Error Handling & Resilience**:
- Implement proper retry logic with exponential backoff
- Use dead letter queues for failed records
- Implement circuit breakers for external dependencies
- Handle partial failures gracefully
- Implement proper logging with structured formats
- Set up alerts for pipeline failures
- Create runbooks for common failure scenarios
- Implement proper backpressure handling

**Data Governance & Security**:
- Implement proper data encryption (at rest and in transit)
- Use appropriate access control (RBAC, ABAC)
- Implement data lineage tracking
- Handle PII/sensitive data with proper masking/anonymization
- Implement audit logging for data access
- Follow data retention and deletion policies
- Ensure compliance with regulations (GDPR, CCPA, HIPAA)

**Testing Strategy**:
- Write unit tests for transformation logic
- Implement integration tests for pipeline components
- Use test fixtures with realistic data samples
- Test data quality rules and validations
- Implement end-to-end pipeline tests
- Test error handling and failure scenarios
- Validate idempotency with repeated executions
- Test with production-like data volumes
- Achieve minimum 80% code coverage

**Monitoring & Observability**:
- Implement pipeline execution metrics (duration, throughput, success rate)
- Monitor data quality metrics (completeness, accuracy, consistency)
- Set up data freshness monitoring
- Track resource utilization (CPU, memory, I/O)
- Implement proper alerting for failures and SLA breaches
- Use distributed tracing for complex pipelines
- Monitor downstream data consumers
- Create operational dashboards

**Schema Management**:
- Implement schema version control
- Use schema registries (Confluent Schema Registry, AWS Glue)
- Plan for schema evolution (backwards/forwards compatibility)
- Implement proper schema validation at boundaries
- Document schema changes and breaking changes
- Use appropriate schema formats (Avro, Protobuf, JSON Schema)
- Test schema migrations thoroughly

**Infrastructure as Code**:
- Define data infrastructure with IaC (Terraform, CloudFormation)
- Version control all infrastructure definitions
- Implement proper environment management (dev, staging, prod)
- Use modules for reusable infrastructure patterns
- Implement proper secrets management
- Document infrastructure dependencies
- Test infrastructure changes in non-production environments

**Backfill & Migration Strategies**:
- Design backfill jobs for historical data processing
- Implement proper date range handling for backfills
- Use incremental backfills to reduce resource usage
- Test backfill logic before running on production data
- Monitor backfill progress and performance
- Implement proper rollback mechanisms
- Document backfill procedures and requirements

**Cost Optimization**:
- Monitor and optimize cloud resource costs
- Use spot/preemptible instances for batch jobs
- Implement proper data lifecycle policies
- Optimize storage costs with appropriate tiers
- Right-size clusters based on workload requirements
- Use cost allocation tags for tracking
- Implement cost alerts and budgets

**Documentation**:
- Document pipeline architecture and data flows
- Maintain data catalog with schema documentation
- Create runbooks for operational procedures
- Document data quality rules and expectations
- Maintain SLA documentation for data delivery
- Document upstream and downstream dependencies
- Create troubleshooting guides for common issues
