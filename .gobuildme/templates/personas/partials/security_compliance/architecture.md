## Security & Compliance-Specific Architecture Documentation

As a **Security & Compliance** specialist, your focus is on documenting security architecture, threat models, compliance requirements, and security controls.

### Security Architecture

**Required**: Document security architecture in `.gobuildme/docs/technical/architecture/patterns/security.md`

Include:
- **Security Model**: Zero trust, defense in depth, or other
- **Trust Boundaries**: Where trust boundaries exist in the system
- **Authentication Architecture**: How users and services authenticate
- **Authorization Architecture**: How permissions are enforced
- **Identity Management**: User identity lifecycle
- **Session Management**: How sessions are created, maintained, invalidated
- **API Security**: API authentication, rate limiting, input validation
- **Data Protection**: Encryption at rest and in transit

### Threat Model

**Required**: Document threat model and mitigations

Include:
- **Assets**: What needs to be protected
- **Threat Actors**: Who might attack the system
- **Attack Vectors**: How attacks might occur
- **Threat Scenarios**: Specific threat scenarios (STRIDE analysis)
- **Mitigations**: How each threat is mitigated
- **Residual Risks**: Accepted risks and why
- **Security Controls**: Technical and procedural controls

### Compliance Requirements

**Required**: Document compliance obligations

Include:
- **Regulatory Requirements**: GDPR, HIPAA, SOC2, PCI-DSS, or other
- **Data Classification**: How data is classified (public, internal, confidential, restricted)
- **Data Residency**: Where data must be stored
- **Data Retention**: How long data must be kept
- **Right to Erasure**: How data deletion requests are handled
- **Audit Requirements**: What must be audited and logged
- **Compliance Controls**: Technical controls for compliance
- **Compliance Reporting**: How compliance is demonstrated

### Authentication and Authorization

**Required**: Document auth architecture in detail

Include:
- **Authentication Methods**: Password, MFA, SSO, OAuth2, SAML
- **Password Policy**: Requirements, rotation, storage
- **Multi-Factor Authentication**: MFA implementation
- **Single Sign-On**: SSO integration if applicable
- **Service Authentication**: How services authenticate to each other
- **Authorization Model**: RBAC, ABAC, or other
- **Permission Model**: How permissions are structured
- **Privilege Escalation**: How elevated access is granted

### Data Security

**Required**: Document data protection measures

Include:
- **Encryption at Rest**: What data is encrypted, how, and where keys are stored
- **Encryption in Transit**: TLS versions, cipher suites
- **Key Management**: How encryption keys are managed
- **Data Masking**: How sensitive data is masked in logs, UI
- **Tokenization**: If PII is tokenized
- **Data Loss Prevention**: DLP measures
- **Secure Data Deletion**: How data is securely deleted
- **Backup Security**: How backups are protected

### Network Security

**Required**: Document network security architecture

Include:
- **Network Segmentation**: How network is segmented
- **Firewalls**: Firewall rules and policies
- **WAF**: Web Application Firewall configuration
- **DDoS Protection**: DDoS mitigation strategies
- **VPN**: VPN access for remote users
- **Private Networks**: VPCs, private subnets
- **Network Monitoring**: IDS/IPS, network traffic analysis
- **Zero Trust Networking**: If applicable

### Application Security

**Required**: Document application security measures

Include:
- **Input Validation**: How inputs are validated and sanitized
- **Output Encoding**: How outputs are encoded to prevent XSS
- **SQL Injection Prevention**: Parameterized queries, ORMs
- **CSRF Protection**: CSRF token implementation
- **Clickjacking Prevention**: X-Frame-Options, CSP
- **Security Headers**: All security-related HTTP headers
- **Dependency Management**: How dependencies are scanned for vulnerabilities
- **SAST/DAST**: Static and dynamic application security testing

### Secrets Management

**Required**: Document secrets management

Include:
- **Secrets Storage**: Vault, AWS Secrets Manager, or other
- **Secret Rotation**: How secrets are rotated
- **Secret Access**: Who/what can access secrets
- **Secret Auditing**: How secret access is audited
- **Development Secrets**: How secrets are handled in development
- **CI/CD Secrets**: How secrets are used in pipelines
- **Emergency Access**: Break-glass procedures

### Incident Response

**Required**: Document security incident response

Include:
- **Incident Detection**: How security incidents are detected
- **Incident Classification**: How incidents are classified
- **Response Procedures**: Step-by-step response process
- **Escalation**: When and how to escalate
- **Communication**: Who to notify and when
- **Forensics**: How to preserve evidence
- **Post-Incident**: Post-mortem and lessons learned
- **Breach Notification**: Legal requirements for breach notification

### Security Monitoring and Auditing

**Required**: Document security monitoring

Include:
- **Security Logging**: What security events are logged
- **Log Retention**: How long logs are kept
- **Log Protection**: How logs are protected from tampering
- **SIEM**: Security Information and Event Management
- **Alerting**: Security alert rules and thresholds
- **Anomaly Detection**: How anomalies are detected
- **Access Auditing**: How access is audited
- **Compliance Auditing**: How compliance is audited

### Security & Compliance Checklist for `/gbm.architecture`

Before completing the architecture documentation, verify:

- [ ] **Security Architecture**: Overall security model documented
- [ ] **Threat Model**: Threats and mitigations documented
- [ ] **Compliance**: Regulatory requirements documented
- [ ] **Authentication**: Auth architecture documented
- [ ] **Authorization**: Permission model documented
- [ ] **Data Protection**: Encryption and data security documented
- [ ] **Network Security**: Network security measures documented
- [ ] **Application Security**: AppSec controls documented
- [ ] **Secrets Management**: Secrets handling documented
- [ ] **Incident Response**: Security incident procedures documented
- [ ] **Monitoring**: Security monitoring and auditing documented
- [ ] **Penetration Testing**: Pen test schedule and scope documented

