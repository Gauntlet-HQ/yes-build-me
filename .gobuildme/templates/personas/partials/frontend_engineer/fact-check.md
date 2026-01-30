### Frontend Engineer Fact-Checking Standards

**Philosophy**: Accessibility and browser compatibility claims must be verified with official sources. WCAG claims require 100% verification.

---

#### Critical Claim Types

**1. WCAG Accessibility** (Required Quality: A, 100%)
- WCAG 2.1/2.2 compliance levels
- Accessibility requirements
- Success criteria

**Verification Requirements**:
- **ONLY** w3.org or .gov sources
- No exceptions - 100% verification mandatory
- Official WCAG documentation

**Correction Assistance**:
- Direct W3C links
- Specific success criteria references
- Example: "1.4.3 Contrast (Minimum): 4.5:1"

**Example Correction**:
```
🔴 CRITICAL (Quality: C):
"The application must meet WCAG 2.1 AA standards"

✅ Option A - Add W3C Citation (Recommended):
"The application must meet WCAG 2.1 Level AA success criteria as defined by W3C [1]"

[1] W3C. (2018). Web Content Accessibility Guidelines (WCAG) 2.1. https://www.w3.org/TR/WCAG21/
```

**2. Browser Compatibility** (Required Quality: B+, 85%+)
- Browser version support
- Feature availability
- Polyfill requirements

**Verification Requirements**:
- caniuse.com for compatibility data
- MDN for feature documentation
- Official browser docs

**3. Framework Capabilities** (Required Quality: B+, 85%+)
- React, Vue, Angular features
- SSR/CSR support
- Performance characteristics

**Verification Requirements**:
- Official framework documentation
- Release notes and changelogs
- Framework benchmarks (if applicable)

---

#### Integration with Frontend Workflow

```bash
/gbm.architecture  # Document frontend architecture
/gbm.fact-check architecture.md  # Verify WCAG claims
```

**CRITICAL**: Frontend persona requires 100% verification for WCAG accessibility claims.
