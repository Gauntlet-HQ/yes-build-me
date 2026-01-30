### ML Engineer Fact-Checking Standards

**Philosophy**: ML benchmarks, cloud pricing, and model performance must be verified with official sources and standardized benchmarks.

---

#### Critical Claim Types

**1. MLPerf Benchmarks** (Required Quality: A, 90%+)
- Training times, inference speeds, model accuracy

**Verification Requirements**: **ONLY** mlcommons.org (MLPerf official site), no alternatives acceptable

**2. Cloud Pricing** (Required Quality: A, 90%+)
- GPU/TPU costs, training infrastructure pricing

**Verification Requirements**: Official cloud vendor pricing pages, must be archived, date specified

**3. Training Dataset Requirements** (Required Quality: B+, 85%+)
- Dataset sizes, GPU memory requirements, storage needs

**Verification Requirements**: Official model documentation, papers with code, vendor specifications

---

#### Integration with ML Engineering Workflow

```bash
/gbm.ml.model
/gbm.fact-check model-design.md
```
