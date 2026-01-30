### SRE Fact-Checking Standards

**Philosophy**: SLA/SLO guarantees and infrastructure costs must be verified with official vendor documentation and archived pricing.

---

#### Critical Claim Types

**1. SLA/SLO Guarantees** (Required Quality: A, 90%+)
- Uptime guarantees, availability targets, credits

**Verification Requirements**: Official vendor SLAs, service level agreements, must be current version

**2. Infrastructure Costs** (Required Quality: A, 90%+)
- Compute, storage, network pricing

**Verification Requirements**: Official cloud vendor pricing, must be archived, date specified ("as of October 2024")

**3. Incident Metrics** (Required Quality: B+, 85%+)
- MTTR, MTBF, error budgets

**Verification Requirements**: Industry reports, published incident post-mortems (Tier 1-2), documented SRE practices

---

#### Integration with SRE Workflow

```bash
/gbm.sre.incident
/gbm.fact-check incident-analysis.md
```
