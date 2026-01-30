### Maintainer Fact-Checking Standards

**Philosophy**: CVE data and license compatibility require 100% verification. Dependency vulnerabilities and EOL dates must be accurate.

---

#### Critical Claim Types (100% Verification Required)

**1. CVE Data** (Required Quality: A, 100%)
- Vulnerability identifiers
- Affected versions
- Patches and mitigations

**Verification Requirements**:
- **ONLY** nvd.nist.gov or cve.mitre.org
- No exceptions - 100% verification mandatory
- Current CVE database

**2. License Compatibility** (Required Quality: A, 100%)
- License types (MIT, Apache, GPL, etc.)
- Compatibility matrices
- Compliance requirements

**Verification Requirements**:
- Official package repositories (npm, PyPI, Maven Central)
- SPDX license validator
- OSI approved license list
- No exceptions - 100% verification mandatory

**3. Dependency Vulnerabilities** (Required Quality: A, 90%+)
- Known vulnerabilities
- Security advisories
- Upgrade paths

**Verification Requirements**:
- GitHub Security Advisories
- Snyk, npm audit, pip-audit reports
- Vendor security pages

**4. EOL Dates** (Required Quality: A, 90%+)
- End-of-life timelines
- Support windows
- LTS versions

**Verification Requirements**:
- Official vendor pages
- endoflife.date for verification
- Product lifecycle documentation

---

#### Integration with Maintainer Workflow

```bash
/gbm.architecture
/gbm.fact-check architecture.md  # Verify CVE and license claims
```

**CRITICAL**: Maintainer persona requires 100% verification for CVE data and license compatibility.
