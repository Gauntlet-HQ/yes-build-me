### Data Engineer Fact-Checking Standards

**Philosophy**: Pipeline benchmarks and data format standards must be verified with official documentation and industry benchmarks.

---

#### Critical Claim Types

**1. Pipeline Benchmarks** (Required Quality: B+, 85%+)
- Throughput rates, processing times, scalability limits

**Verification Requirements**: Official Apache docs, TPC benchmarks, vendor whitepapers (Tier 2 acceptable)

**2. Data Format Standards** (Required Quality: B+, 85%+)
- Parquet, Avro, ORC specifications

**Verification Requirements**: Apache project documentation, format specifications

**3. ETL Performance** (Required Quality: B+, 85%+)
- Transform speeds, load times, tool capabilities

**Verification Requirements**: Official tool docs, published benchmarks

---

#### Integration with Data Engineering Workflow

```bash
/gbm.data.pipeline
/gbm.fact-check pipeline-design.md
```
