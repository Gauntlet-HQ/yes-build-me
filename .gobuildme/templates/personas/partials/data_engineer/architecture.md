## Data Engineer-Specific Architecture Documentation

As a **Data Engineer**, your focus is on documenting data architecture, data pipelines, ETL processes, and data quality.

### Data Architecture

**Required**: Document data architecture in `.gobuildme/docs/technical/architecture/patterns/data-architecture.md`

Include:
- **Data Sources**: Where data comes from (databases, APIs, files, streams)
- **Data Storage**: Data lakes, data warehouses, databases
- **Data Models**: Dimensional models, normalized schemas
- **Data Partitioning**: How data is partitioned for performance
- **Data Retention**: How long data is kept and archival strategy
- **Data Lineage**: How data flows through the system
- **Master Data Management**: How master data is managed

### ETL/ELT Pipelines

**Required**: Document data pipeline architecture

Include:
- **Pipeline Orchestration**: Airflow, Prefect, Dagster, or other
- **Data Extraction**: How data is extracted from sources
- **Data Transformation**: Transformation logic and tools (dbt, Spark)
- **Data Loading**: How data is loaded into targets
- **Pipeline Scheduling**: When pipelines run
- **Pipeline Monitoring**: How pipeline health is monitored
- **Error Handling**: How pipeline failures are handled
- **Data Quality Checks**: Validation and quality gates

### Data Quality

**Required**: Document data quality measures

Include:
- **Data Validation**: What validations are performed
- **Data Profiling**: How data is profiled
- **Data Quality Metrics**: Completeness, accuracy, consistency, timeliness
- **Data Quality Monitoring**: How quality is monitored
- **Data Quality Alerts**: When alerts are triggered
- **Data Quality Remediation**: How quality issues are fixed

### Data Engineer Checklist for `/gbm.architecture`

- [ ] **Data Architecture**: Data storage and models documented
- [ ] **Data Pipelines**: ETL/ELT processes documented
- [ ] **Data Quality**: Quality measures and monitoring documented
- [ ] **Data Lineage**: Data flow and lineage documented
- [ ] **Data Governance**: Data governance policies documented

