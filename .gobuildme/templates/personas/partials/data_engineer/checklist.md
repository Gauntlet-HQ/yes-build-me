### Data Engineer Quality Dimensions

When validating data engineering requirements and specifications, ensure these quality dimensions are addressed:

#### Data Pipeline Architecture

**Pipeline Design**:
- Is data pipeline architecture documented (batch, streaming, lambda)?
- Are pipeline stages clearly defined (ingestion, transformation, storage)?
- Is data flow diagram provided?
- Are pipeline dependencies mapped?

**Data Ingestion**:
- Are data sources identified and documented?
- Is ingestion method specified (pull, push, CDC)?
- Are ingestion frequency requirements defined?
- Is incremental vs. full load strategy specified?

**Data Transformation**:
- Are transformation logic requirements documented?
- Is transformation order/dependency specified?
- Are data quality checks defined?
- Is data validation strategy documented?

**Orchestration**:
- Is orchestration tool specified (Airflow, Prefect, Dagster)?
- Are DAG structures documented?
- Is task dependency mapping defined?
- Are retry and failure handling strategies specified?

#### Data Storage & Formats

**Storage Architecture**:
- Is storage solution specified (data lake, data warehouse, lakehouse)?
- Are storage tiers defined (hot, warm, cold)?
- Is data partitioning strategy documented?
- Are indexing requirements specified?

**Data Formats**:
- Is data format specified (Parquet, Avro, ORC, JSON, CSV)?
- Is format selection rationale documented?
- Are compression requirements defined?
- Is schema evolution strategy specified?

**Data Organization**:
- Is data catalog strategy specified?
- Are naming conventions documented?
- Is folder/namespace structure defined?
- Are metadata management requirements specified?

**Storage Optimization**:
- Is data partitioning strategy specified (time, region, category)?
- Are clustering/bucketing requirements defined?
- Is data compaction strategy documented?
- Are storage cost optimization requirements specified?

#### Data Quality & Validation

**Data Quality Dimensions**:
- Are data quality dimensions defined (completeness, accuracy, consistency, timeliness)?
- Are quality metrics quantified?
- Is data quality monitoring strategy specified?
- Are quality SLAs documented?

**Data Validation Rules**:
- Are validation rules clearly defined?
- Is schema validation strategy specified?
- Are data type validation requirements documented?
- Are business rule validation requirements defined?

**Data Quality Checks**:
- Are data quality check frequency requirements specified?
- Is anomaly detection strategy documented?
- Are threshold definitions for quality metrics specified?
- Is alerting strategy for quality violations defined?

**Data Profiling**:
- Is data profiling frequency specified?
- Are profiling metrics documented?
- Is profiling automation strategy defined?
- Are profiling results storage requirements specified?

#### Schema Management

**Schema Design**:
- Is schema design documented?
- Are data types clearly specified?
- Is denormalization strategy defined?
- Are surrogate key requirements specified?

**Schema Evolution**:
- Is schema evolution strategy specified?
- Are backward compatibility requirements documented?
- Is schema versioning strategy defined?
- Are migration procedures documented?

**Schema Validation**:
- Is schema validation strategy specified?
- Are schema compatibility checks defined?
- Is schema registry solution specified?
- Are schema documentation requirements defined?

#### Data Lineage & Metadata

**Data Lineage Tracking**:
- Is data lineage tracking strategy specified?
- Is lineage granularity level defined (column, table, dataset)?
- Are lineage visualization requirements documented?
- Is lineage query capability specified?

**Metadata Management**:
- Is metadata management solution specified?
- Are metadata types documented (technical, business, operational)?
- Is metadata capture strategy defined?
- Are metadata search requirements specified?

**Data Catalog**:
- Is data catalog solution specified?
- Are catalog entry requirements documented?
- Is catalog discovery strategy defined?
- Are data ownership tracking requirements specified?

#### Performance & Scalability

**Performance Requirements**:
- Are throughput requirements specified (records/second, GB/hour)?
- Are latency requirements defined (end-to-end pipeline latency)?
- Is query performance target specified?
- Are concurrency requirements documented?

**Scalability Strategy**:
- Is horizontal scaling strategy specified?
- Are resource allocation requirements documented?
- Is auto-scaling strategy defined?
- Are load testing requirements specified?

**Performance Optimization**:
- Is query optimization strategy specified?
- Are caching requirements defined?
- Is data pruning strategy documented?
- Are performance monitoring requirements specified?

#### Data Security & Privacy

**Access Control**:
- Is access control strategy specified (RBAC, ABAC)?
- Are data access policies documented?
- Is authentication/authorization mechanism defined?
- Are audit logging requirements specified?

**Data Encryption**:
- Is encryption at rest strategy specified?
- Is encryption in transit requirements documented?
- Are key management requirements defined?
- Is column-level encryption strategy specified?

**Data Masking & Anonymization**:
- Is data masking strategy specified?
- Are anonymization requirements documented?
- Is tokenization strategy defined?
- Are de-identification requirements specified?

**Compliance**:
- Are regulatory compliance requirements identified (GDPR, HIPAA)?
- Is data retention policy documented?
- Are data deletion requirements specified?
- Is right to be forgotten implementation strategy defined?

#### Monitoring & Observability

**Pipeline Monitoring**:
- Are pipeline monitoring requirements specified?
- Is pipeline health check strategy documented?
- Are SLA monitoring requirements defined?
- Is alerting strategy specified?

**Data Monitoring**:
- Is data freshness monitoring strategy specified?
- Are data volume monitoring requirements documented?
- Is data drift detection strategy defined?
- Are schema drift monitoring requirements specified?

**Operational Metrics**:
- Are operational metrics specified (latency, throughput, error rate)?
- Is metrics collection strategy documented?
- Are dashboarding requirements defined?
- Is historical metrics retention policy specified?

**Logging**:
- Are logging requirements specified?
- Is log aggregation strategy documented?
- Are log retention requirements defined?
- Is log analysis strategy specified?

#### Data Versioning & Reproducibility

**Data Versioning**:
- Is data versioning strategy specified?
- Are version identification requirements documented?
- Is snapshot strategy defined?
- Are versioning tools specified (DVC, lakeFS)?

**Reproducibility**:
- Is pipeline reproducibility strategy specified?
- Are deterministic execution requirements documented?
- Is environment reproducibility strategy defined?
- Are dependency versioning requirements specified?

**Rollback Strategy**:
- Is data rollback strategy specified?
- Are checkpoint requirements documented?
- Is recovery point objective (RPO) defined?
- Are rollback testing requirements specified?

#### Error Handling & Recovery

**Error Handling Strategy**:
- Is error handling strategy documented?
- Are error classification criteria defined?
- Are error recovery procedures specified?
- Is dead letter queue strategy documented?

**Retry Logic**:
- Is retry strategy specified (exponential backoff, max retries)?
- Are idempotency requirements documented?
- Are retry budget requirements defined?
- Is retry monitoring strategy specified?

**Failure Recovery**:
- Is failure recovery strategy specified?
- Are checkpoint/restart requirements documented?
- Is partial failure handling strategy defined?
- Are recovery testing requirements specified?

**Data Reconciliation**:
- Is data reconciliation strategy specified?
- Are reconciliation frequency requirements documented?
- Is discrepancy resolution procedure defined?
- Are reconciliation reporting requirements specified?

#### Testing Strategy

**Unit Testing**:
- Are unit test requirements specified for transformations?
- Is test data generation strategy documented?
- Are test coverage requirements defined?
- Is mocking/stubbing strategy specified?

**Integration Testing**:
- Are integration test scenarios documented?
- Is end-to-end pipeline testing strategy specified?
- Are integration test data requirements defined?
- Is test environment strategy documented?

**Data Quality Testing**:
- Are data quality test requirements specified?
- Is validation rule testing strategy documented?
- Are schema validation test requirements defined?
- Is data profiling testing strategy specified?

**Performance Testing**:
- Are performance test requirements specified?
- Is load testing strategy documented?
- Are stress testing requirements defined?
- Is performance regression testing strategy specified?

#### Cost Optimization

**Cost Monitoring**:
- Are cost monitoring requirements specified?
- Is cost allocation strategy documented?
- Are cost alerting thresholds defined?
- Is cost reporting strategy specified?

**Resource Optimization**:
- Is compute resource optimization strategy specified?
- Are storage cost optimization requirements documented?
- Is data lifecycle management strategy defined?
- Are idle resource detection requirements specified?

**Cost-Benefit Analysis**:
- Is cost-benefit analysis strategy specified?
- Are cost per pipeline/job tracking requirements documented?
- Is ROI measurement strategy defined?
- Are cost optimization opportunities identification requirements specified?

#### Disaster Recovery & Business Continuity

**Backup Strategy**:
- Is backup strategy specified (full, incremental, differential)?
- Are backup frequency requirements documented?
- Is backup retention policy defined?
- Are backup testing requirements specified?

**Disaster Recovery**:
- Is disaster recovery plan documented?
- Is recovery time objective (RTO) specified?
- Is recovery point objective (RPO) defined?
- Are disaster recovery testing requirements documented?

**High Availability**:
- Are high availability requirements specified?
- Is failover strategy documented?
- Are redundancy requirements defined?
- Is multi-region strategy specified?

---

**Quality Gate Checklist**: Before marking specification as "ready for development":

- [ ] Data pipeline architecture is clearly documented (ingestion, transformation, orchestration)
- [ ] Data storage, formats, and organization strategy are specified
- [ ] Data quality dimensions, validation rules, and profiling strategy are defined
- [ ] Schema management including design, evolution, and validation is documented
- [ ] Data lineage tracking and metadata management strategy are specified
- [ ] Performance, scalability, and optimization requirements are defined
- [ ] Data security, privacy, and compliance requirements are comprehensive
- [ ] Monitoring, observability, and operational metrics strategy is documented
- [ ] Data versioning, reproducibility, and rollback strategy are specified
- [ ] Error handling, recovery, and data reconciliation procedures are defined
- [ ] Testing strategy covers unit, integration, quality, and performance testing
- [ ] Cost optimization and monitoring requirements are documented
- [ ] Disaster recovery, backup, and high availability strategy are specified
