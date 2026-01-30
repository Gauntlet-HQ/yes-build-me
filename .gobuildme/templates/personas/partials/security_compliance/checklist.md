### Security Compliance Quality Dimensions

When validating security and compliance requirements, ensure these quality dimensions are addressed:

#### Authentication & Authorization

**Authentication Mechanisms**:
- Is authentication method specified (JWT, OAuth2, SAML, mTLS)?
- Are multi-factor authentication (MFA) requirements defined?
- Is password policy specified (length, complexity, rotation)?
- Are session management requirements documented (timeout, refresh)?

**Authorization Model**:
- Is authorization model clearly defined (RBAC, ABAC, ACL)?
- Are permission granularity requirements specified?
- Is principle of least privilege enforced?
- Are privilege escalation scenarios documented?

**Token Management**:
- Is token generation strategy specified (secret keys, algorithms)?
- Are token expiration policies defined?
- Is token revocation mechanism documented?
- Are refresh token security requirements specified?

#### Data Protection

**Encryption Requirements**:
- Is data encryption at rest specified (algorithms, key length)?
- Is data encryption in transit specified (TLS version, cipher suites)?
- Are encryption key management requirements documented?
- Is key rotation strategy defined?

**Data Classification**:
- Are data classification levels defined (public, internal, confidential, restricted)?
- Are handling requirements specified for each classification?
- Is data retention policy documented?
- Are data disposal requirements specified?

**Personally Identifiable Information (PII)**:
- Are PII data elements identified?
- Is PII protection strategy specified (masking, tokenization, encryption)?
- Are PII access controls documented?
- Is PII breach notification process defined?

#### Network Security

**Network Architecture**:
- Is network segmentation strategy specified?
- Are firewall rules documented?
- Is DMZ architecture defined (if applicable)?
- Are VPN/bastion host requirements specified?

**API Security**:
- Is API authentication mechanism specified?
- Are rate limiting requirements defined?
- Is API throttling strategy documented?
- Are CORS policies specified?

**DDoS Protection**:
- Are DDoS mitigation requirements specified?
- Is traffic filtering strategy defined?
- Are rate limiting policies documented?
- Is CDN/WAF usage specified?

#### Application Security

**Input Validation**:
- Are input validation requirements defined for all user inputs?
- Is allowlist validation strategy specified?
- Are SQL injection prevention measures documented?
- Is command injection prevention strategy defined?

**Cross-Site Scripting (XSS) Prevention**:
- Is output encoding strategy specified?
- Are Content Security Policy (CSP) headers defined?
- Is sanitization library specified?
- Are XSS prevention measures documented for rich text inputs?

**Cross-Site Request Forgery (CSRF) Prevention**:
- Is CSRF token generation strategy specified?
- Are CSRF validation requirements documented?
- Is SameSite cookie policy defined?
- Are state-changing operations protected?

**Security Headers**:
- Are security headers specified (X-Frame-Options, X-Content-Type-Options)?
- Is HTTP Strict Transport Security (HSTS) policy defined?
- Are referrer policy requirements specified?
- Is Permissions Policy documented?

#### Vulnerability Management

**Dependency Management**:
- Is dependency scanning strategy specified?
- Are vulnerable dependency remediation requirements defined?
- Is dependency update policy documented?
- Are security advisory monitoring requirements specified?

**Code Security**:
- Is static application security testing (SAST) strategy specified?
- Is dynamic application security testing (DAST) required?
- Are code review security requirements documented?
- Is security linting strategy defined?

**Penetration Testing**:
- Is penetration testing frequency defined?
- Are penetration testing scope requirements specified?
- Is vulnerability remediation SLA documented?
- Are remediation verification requirements defined?

#### Compliance & Regulatory Requirements

**Regulatory Compliance**:
- Are applicable regulations identified (GDPR, HIPAA, PCI-DSS, SOC2, ISO 27001)?
- Are compliance requirements documented for each regulation?
- Is compliance validation strategy specified?
- Are audit requirements defined?

**GDPR Compliance** (if applicable):
- Are data subject rights mechanisms defined (access, rectification, erasure)?
- Is consent management strategy specified?
- Are data processing agreements documented?
- Is data transfer mechanism defined (EU-US, adequacy decisions)?

**HIPAA Compliance** (if applicable):
- Are PHI data elements identified?
- Is PHI access control strategy specified?
- Are audit logging requirements documented?
- Is breach notification process defined?

**PCI-DSS Compliance** (if applicable):
- Are cardholder data handling requirements specified?
- Is PCI-DSS scope minimization strategy documented?
- Are tokenization/encryption requirements defined?
- Is quarterly scanning requirement documented?

#### Audit & Logging

**Audit Logging**:
- Are audit log requirements specified (events to log)?
- Is audit log retention policy defined?
- Are audit log protection measures documented?
- Is audit log monitoring strategy specified?

**Security Event Logging**:
- Are security event types defined (login failures, permission changes)?
- Is log correlation strategy specified?
- Are log analysis requirements documented?
- Is SIEM integration strategy defined?

**Log Protection**:
- Are log integrity protection measures specified?
- Is log access control strategy documented?
- Are log backup requirements defined?
- Is log tampering detection strategy specified?

#### Incident Response

**Incident Detection**:
- Are security incident detection mechanisms specified?
- Is anomaly detection strategy defined?
- Are alerting thresholds documented?
- Is incident classification criteria specified?

**Incident Response Plan**:
- Is incident response team identified?
- Is incident escalation process documented?
- Are incident response procedures defined?
- Is incident communication plan specified?

**Breach Notification**:
- Is breach notification timeline defined (regulatory requirements)?
- Are breach notification stakeholders identified?
- Is breach notification process documented?
- Are post-breach remediation requirements specified?

#### Secrets Management

**Secret Storage**:
- Is secrets management solution specified (Vault, AWS Secrets Manager)?
- Are secret encryption requirements documented?
- Is secret access control strategy defined?
- Are secret rotation requirements specified?

**Secret Distribution**:
- Is secret injection mechanism specified (environment variables, config files)?
- Are secret distribution security measures documented?
- Is secret versioning strategy defined?
- Are secret backup requirements specified?

**Secret Rotation**:
- Is secret rotation frequency defined?
- Is automated rotation strategy specified?
- Are rotation verification requirements documented?
- Is emergency rotation process defined?

#### Access Control & Identity Management

**Identity Management**:
- Is user provisioning/deprovisioning process documented?
- Are identity verification requirements specified?
- Is single sign-on (SSO) strategy defined?
- Is identity federation mechanism specified?

**Access Control Policies**:
- Are access control policies documented?
- Is access review frequency defined?
- Are access revocation requirements specified?
- Is privileged access management (PAM) strategy defined?

**Separation of Duties**:
- Are separation of duties requirements identified?
- Is conflicting permission detection strategy specified?
- Are approval workflows documented?
- Is dual authorization requirement defined?

#### Security Testing & Validation

**Security Test Coverage**:
- Are security test scenarios defined?
- Is security test frequency specified?
- Are security test automation requirements documented?
- Is security regression testing strategy defined?

**Threat Modeling**:
- Is threat modeling process specified?
- Are threat scenarios documented?
- Is risk assessment methodology defined?
- Are mitigation strategies specified for identified threats?

**Security Acceptance Criteria**:
- Are security acceptance criteria defined for each feature?
- Is security sign-off process documented?
- Are security gate requirements specified?
- Is security validation methodology defined?

#### Security Research & Evidence Quality

**CVE & Vulnerability Data** (Required Quality: A, 100%):
- Are CVE claims verified with official sources (nvd.nist.gov, cve.mitre.org)?
- Are vulnerability severity scores (CVSS) traceable to authoritative sources?
- Are patch availability claims verified with vendor security advisories?
- Are exploit availability claims sourced from reputable security databases?

**Regulatory & Compliance Claims** (Required Quality: A, 100%):
- Are GDPR requirements sourced from *.gov or official EU sources?
- Are HIPAA requirements sourced from hhs.gov or official HHS guidance?
- Are PCI-DSS requirements sourced from official PCI Security Standards Council?
- Are SOC 2 criteria sourced from AICPA official documentation?

**Security Standards & Best Practices** (Required Quality: B+, 85%+):
- Are OWASP references citing current official OWASP documentation?
- Are NIST guidelines citing official NIST publications?
- Are CIS benchmarks citing official CIS documentation?
- Are security framework claims (ISO 27001, SANS) verified with official sources?

**Security Tool Claims** (Required Quality: B+, 85%+):
- Are security tool capabilities verified with official documentation?
- Are vulnerability scanner accuracy claims backed by independent research?
- Are encryption library security claims sourced from official docs or audits?
- Are security product comparisons backed by reputable sources?

**Research Verification**:
- Has `/gbm.fact-check` been run on security documentation?
- Are CVE and regulatory claims verified at 100% quality (Quality A)?
- Are security standard claims verified at 85%+ quality (Quality B+)?
- Are weak sources (Quality C-D) for critical claims corrected?

**Note**: For security and compliance, CVE data and regulatory claims require 100% verification with official sources only. This is non-negotiable for security-critical specifications. Use `/gbm.fact-check` to verify and improve claim quality.

---

**Quality Gate Checklist**: Before marking specification as "ready for development":

- [ ] Authentication and authorization mechanisms are clearly specified
- [ ] Data protection requirements include encryption, classification, and PII handling
- [ ] Network security architecture is documented (segmentation, API security, DDoS)
- [ ] Application security measures address input validation, XSS, CSRF, and security headers
- [ ] Vulnerability management strategy includes dependency scanning, code security, and penetration testing
- [ ] Compliance requirements are identified and documented for applicable regulations
- [ ] Audit and logging requirements specify events, retention, protection, and monitoring
- [ ] Incident response plan includes detection, response procedures, and breach notification
- [ ] Secrets management strategy covers storage, distribution, and rotation
- [ ] Access control and identity management policies are comprehensive
- [ ] Security testing and validation requirements include threat modeling and acceptance criteria
- [ ] Security research quality is verified (critical: CVE/regulatory claims at 100%)
