### Security Compliance Fact-Checking Standards

**Philosophy**: Security and compliance claims require 100% verification with authoritative sources. Unverified critical claims get extensive correction assistance.

---

#### Critical Claim Types (100% Verification Required)

**1. CVE Data** (Required Quality: A, 100%)
- CVE numbers and details
- Patch status
- Vulnerability severity

**Verification Requirements**:
- **ONLY** nvd.nist.gov or cve.mitre.org
- No exceptions - 100% verification mandatory
- Current CVE database entries

**Correction Assistance**:
- Direct links to NVD lookup
- Step-by-step verification process
- Alternative: Mark as [UNCONFIRMED - REQUIRES VERIFICATION]

**Example Correction**:
```
🔴 CRITICAL (Quality: D):
"CVE-2024-12345 has been patched in version 2.4.1"

✅ Option A - Verify with NVD (Recommended):
1. Search: https://nvd.nist.gov/vuln/detail/CVE-2024-12345
2. Check "Vendor Advisory" for patch info
3. Use: "CVE-2024-12345 was addressed in version 2.4.1 per NIST NVD [1]"

[1] NIST NVD. (2024). CVE-2024-12345 Detail.
```

**2. Regulatory Claims** (Required Quality: A, 100%)
- GDPR, HIPAA, SOC 2, ISO requirements
- Compliance obligations
- Regulatory deadlines

**Verification Requirements**:
- **ONLY** .gov sources (nist.gov, hhs.gov, etc.)
- No exceptions - 100% verification mandatory
- Official regulatory text

**3. Encryption Standards** (Required Quality: A, 90%+)
- Approved algorithms (AES, RSA, etc.)
- Key length requirements
- FIPS compliance

**Verification Requirements**:
- NIST, FIPS documentation
- Official cryptographic standards
- Current approved algorithms list

---

#### Integration with Security Workflow

```bash
/gbm.security.audit
/gbm.fact-check security-audit.md  # MANDATORY for CVEs and regulatory claims
```

**CRITICAL**: Security persona requires 100% verification for CVE data and regulatory claims. System provides extra correction help but these claims must be verified before production.
