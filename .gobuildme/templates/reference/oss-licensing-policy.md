# AI-Generated Code & Open Source Licensing Policy

> **Policy Alignment**: This reference aligns with the GoFundMe Open Source License Policy and ensures AI-generated code complies with licensing requirements.

## Core Principle

**Assume AI-generated code may include OSS.** Any code generated or suggested by AI that introduces or modifies the use of a framework, library, or dependency must be treated as potentially open-source-licensed and subject to the GoFundMe Open Source License Policy, including the **Roadmap (Go / Caution / Stop)** decision framework.

## Roadmap: Go / Caution / Stop

The Roadmap is the **canonical decision table** for whether and how we can use a given OSS license.

> **Engineering Directors must approve *all* OSS use.**
> Legal approvals are required as described below.

| **Go** | **Caution** | **Stop** |
| --- | --- | --- |
| You do **not** need Legal approval to use code licensed under these licenses for **any use case**, subject to Engineering Director approval and the rest of this policy. | You must obtain **Legal approval to distribute** code licensed under these licenses. You do **not** need Legal approval to make **internal use** of code licensed under these licenses (as defined in the policy). | You must obtain **Legal approval to use any code at all** licensed under these licenses (including purely internal use). |
| **Examples include:**<br><br>• Permissive licenses: **MIT**, **Apache-2.0**, **BSD 2-Clause**, **BSD 3-Clause**<br>• Blue Oak Council **"Bronze" or better** permissive licenses<br>• Creative Commons attribution licenses: **CC-BY-1.0**, **CC-BY-2.0**, **CC-BY-2.5**, **CC-BY-3.0**, **CC-BY-4.0** (where appropriate for code/content) | **Examples include:**<br><br>• Weak copyleft: **LGPL-2.1** (distribution allowed only when dynamically linked), Blue Oak Council *weak copyleft* family<br>• Strong copyleft with approved exceptions: **GPL-2.0-only**, **GPL-3.0-only** *with* Autoconf, Bison, Classpath, Font, GCC exceptions<br>• Other obligations on distribution: **EPL-2.0** and similar | **Examples include:**<br><br>• Blue Oak Council **"Lead"** (highest risk): **WTFPL**<br>• Network copyleft: **AGPL-1.0-only**, **AGPL-3.0-only**<br>• Maximal copyleft: **RPL-1.5**<br>• **Any license not mentioned on the Roadmap** (treat as Stop by default) |
| **Safe for general use** with Engineering Director approval. Follow tracking and attribution requirements. | **Requires Legal approval before distribution.** Submit request via **Legal Intake Form**. Internal use is allowed without Legal approval. | **Requires Legal approval for any use** (including internal). Submit request via **Legal Intake Form**. |

**Key rule:** If you cannot confidently map a license to **Go** or **Caution**, you must treat it as **Stop** until Legal confirms otherwise.

## License Identification Requirements

When accepting AI-generated code that:
- adds a new dependency (framework, library, SDK, plugin, package), or
- changes how we link to or use an existing dependency in a meaningful way,

the author **must**:

1. **Identify the dependency's license** via:
   - LICENSE or COPYING file in the project repository
   - Project documentation or README
   - File headers or copyright notices
   - Package metadata (package.json, setup.py, pom.xml, etc.)
   - Package registry information (npm, PyPI, Maven Central, etc.)

2. **Confirm the Roadmap category** (Go / Caution / Stop) using the table above

3. **Obtain required approvals**:
   - **Go**: Engineering Director approval (per policy)
   - **Caution**: Legal approval before distribution (via Legal Intake Form)
   - **Stop**: Legal approval for any use (via Legal Intake Form)

## Roadmap Compliance and Legal Approval

- **Go Column** (e.g., MIT, Apache-2.0, BSD 2/3-Clause, Blue Oak Bronze+ permissive, CC-BY family):
  - May be used without Legal review
  - Subject to Engineering Director approval as required by policy
  - Must follow tracking and attribution requirements

- **Caution Column** (e.g., weak/strong copyleft with conditions, LGPL, GPL with exceptions, EPL-2.0):
  - Requires **Legal approval before distribution** (mobile apps, browser-delivered code, SDKs, distributed artifacts)
  - Internal use is allowed without Legal approval (internal tools, build scripts, development environments)
  - Submit Legal Intake Form for distribution approval

- **Stop Column** (e.g., AGPL, RPL-1.5, maximal/network copyleft, Blue Oak "Lead" licenses, **unlisted licenses**):
  - Requires **Legal approval for any use** (including purely internal)
  - Must submit Legal Intake Form before using
  - If license not on Roadmap, treat as **Stop** by default

## Usage Guidelines for AI-Generated Code

**Prefer AI-generated code for:**
- Internal tools and utilities
- Test harnesses, mocks, and test scripts
- Boilerplate and glue code with low IP sensitivity
- Infrastructure automation and build scripts
- Development environment setup
- Where underlying dependencies fall in **Go** or are approved under **Caution**

**Apply stricter scrutiny for:**
- Product code and customer-facing functionality
- Code that will be distributed (mobile apps, browser JavaScript, SDKs, client libraries)
- Artifacts that leave our control (open-source projects, public APIs, downloadable packages)
- Security-sensitive code paths (authentication, authorization, cryptography, payment processing)

## Approved AI Tools Only

- **Only company-approved enterprise AI tools** may be used with GoBuildMe code and GoFundMe proprietary code
- Examples of approved tools: [List approved tools - GitHub Copilot Enterprise, etc.]
- Contributors **must not** paste GoFundMe proprietary code into:
  - Free-tier or personal AI tools
  - Unapproved commercial AI services
  - Public AI chat interfaces
  - Any service without enterprise-grade data protection

## Tracking & Documentation

Any new dependency (or change to how an existing dependency is used) introduced via AI suggestions **must**:

1. **Add to OSS inventory:**
   - Update project's dependency manifest (package.json, requirements.txt, pom.xml, go.mod, etc.)
   - Add to OSS tracking system if one exists
   - Ensure GitHub dependency scanning picks it up

2. **Document in PR description:**
   - Dependency name and version
   - License identified (with link to LICENSE file or source)
   - **Roadmap category** (Go / Caution / Stop)
   - Whether Legal approval was required and, if so:
     - Legal Intake Form ticket number
     - Approval status and date

**Example PR Documentation:**

```markdown
## OSS Dependencies Added

| Dependency | Version | License | Roadmap | Legal Approval |
|------------|---------|---------|---------|----------------|
| express-validator | 7.0.1 | MIT | Go | Not required (Go category) |
| uuid | 9.0.0 | MIT | Go | Not required (Go category) |
```

3. **Maintain attribution:**
   - Preserve license headers and copyright notices
   - Include NOTICE files where required
   - Document attribution requirements

## Escalation Process

If a contributor suspects that AI-generated code is derived from copyleft or otherwise problematic OSS, they **must**:

1. **Stop usage immediately:**
   - Do not merge the PR
   - Do not deploy the code
   - Remove the suspicious snippet from working branches

2. **Document the concern:**
   - Note in PR comments:
     - What code appears problematic
     - Why (e.g., looks copied from known project X, license unclear, license not on Roadmap)
     - Suspected source or license

3. **Escalate to Legal:**
   - Submit **Legal Intake Form** with:
     - Code snippet or file
     - Suspected source or license
     - Context (how AI generated it, what it does)
   - Do **not** proceed until Legal provides guidance

4. **Alternatives if code is rejected:**
   - Rewrite the functionality without AI assistance
   - Find a Go-category alternative dependency
   - Seek Legal-approved Caution-category dependency
   - Remove the feature if no compliant solution exists

## Review Enforcement

Code reviewers **must** verify:

- [ ] Any new dependencies are documented with license and Roadmap category
- [ ] PR description includes OSS dependency documentation if applicable
- [ ] Legal approvals are referenced for Caution/Stop dependencies
- [ ] No unapproved AI tools were used
- [ ] No proprietary code was pasted into unapproved AI services

## OSS Inventory

The project's OSS inventory lives at: [Specify location - e.g., `.gobuildme/oss-inventory.md` or link to central system]

**Inventory must include:**
- Dependency name and version
- License and Roadmap category
- Usage context (distributed vs internal)
- Legal approval status (if Caution/Stop)
- Last reviewed date

## Remediation Playbook

If a non-compliant dependency is discovered after merge:

1. **Assess impact:**
   - Is code distributed or internal-only?
   - What Roadmap category is the license?
   - Is Legal approval needed?

2. **Immediate actions:**
   - For Stop-category: Halt distribution immediately, escalate to Legal
   - For Caution-category: If distributed without Legal approval, halt distribution, submit Legal Intake Form
   - For Go-category: Verify Engineering Director approval exists

3. **Remediation options (in order of preference):**
   - **Replace** with Go-category alternative
   - **Obtain Legal approval** (if Caution/Stop and viable)
   - **Refactor** to remove dependency
   - **Rollback** the feature if no compliant solution exists

4. **Prevention:**
   - Update PR template with OSS checklist
   - Add pre-commit hooks for dependency checks
   - Conduct quarterly OSS inventory audits
