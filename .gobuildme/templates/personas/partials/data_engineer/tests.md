### Persona-Specific Testing Requirements — Data Engineer

Testing checkpoints:
- **Data Quality Tests**: Validate completeness, accuracy, consistency, and timeliness of data
- **Pipeline Integration Tests**: Test end-to-end data pipeline execution
- **Data Transformation Tests**: Test transformation logic with sample datasets
- **Schema Validation Tests**: Verify data conforms to expected schemas
- **Idempotency Tests**: Test pipelines can run multiple times with same results
- **Data Lineage Tests**: Verify data tracking through transformation stages
- **Performance Tests**: Test pipeline execution time and resource usage
- **Failure Recovery Tests**: Test retry logic and error handling
- **Data Validation Rules**: Test business rules and data quality constraints
- **Volume Tests**: Test pipeline performance with production-scale data
- **Incremental Processing Tests**: Verify incremental load logic
- **Late Data Handling Tests**: Test how pipeline handles out-of-order or late-arriving data
- **Backfill Tests**: Verify historical data processing logic
- **Data Deduplication Tests**: Test duplicate detection and removal
- **Coverage Requirement**: 80% test coverage for pipeline and transformation code
