# Product Requirements Document: [Feature Name]

**Status:** Draft
**Version:** 1.0
**Last Updated:** [YYYY-MM-DD]
**PM Owner:** [Your name]
**Related Discovery:** `.gobuildme/specs/<feature>/validation-report.md`

---

## Executive Summary

**Problem Statement:**
[One-sentence problem from /pm.discover - validated through interviews and research]

**Solution Overview:**
[2-3 sentence description of what we're building]

**Target Users:**
[Primary and secondary personas from /pm.interview]

**Business Impact:**
- Revenue: [$X/month increase or churn reduction from /pm.research analytics]
- Cost: [$Y/month cost savings from /pm.research]
- Strategic: [Competitive positioning from /pm.research competitive analysis]

**Success Criteria:**
- Leading Indicator 1: [From hypothesis in /pm.discover]
- Leading Indicator 2: [Usage metric]
- Lagging Indicator: [Business outcome - e.g., "30% reduction in support tickets"]

**Timeline:**
- Design: [X weeks]
- Engineering: [Y weeks from /pm.research technical feasibility]
- Launch: [Target date]

**Required Resources:**
- Engineering: [N engineers for X weeks]
- Design: [N designers for X weeks]
- [Other resources needed]

---

## Problem Context

### Problem Description

**The Problem:**
[Detailed description of the problem from /pm.discover]

**Who Experiences This:**
[Target personas from /pm.interview with specific quotes]

**Evidence:**

**From User Interviews** (`/pm.interview` - [N] interviews):
- Average pain severity: [X.X/10]
- % rating pain as critical (9-10): [X%]
- Most powerful quote:
  > "[Quote from interview that captures pain]"
  > — [Participant role]

**From Analytics** (`/pm.research` analytics report):
- Users affected: [N users, X% of total]
- Frequency: [How often users encounter problem]
- Current drop-off rate: [X%] (vs. benchmark [Y%])
- Business impact: [$Z/month]

**From Market Research** (`/pm.research` market research):
- Market size: TAM $[X]B, SAM $[Y]M, SOM $[Z]K
- Market trend: [Growing X% YoY]
- Customer segment: [Primary segment identified]

### Current State

**How Users Handle This Today:**
[Workarounds from /pm.interview - what users do now]

**Existing Solutions:**
[Competitive landscape from /pm.research competitive analysis]

| Competitor | Strengths | Weaknesses (Our Opportunity) |
|------------|-----------|-------------------------------|
| [Competitor A] | [What they do well] | [Gap we'll fill] |
| [Competitor B] | [What they do well] | [Gap we'll fill] |

**Why Existing Solutions Fail:**
[From /pm.interview - why users don't adopt competitors]

### Why Now?

**Market Timing:**
[From /pm.research - why this is the right time]

**Competitive Window:**
[From /pm.research competitive analysis - why we need to move now]

**Strategic Alignment:**
[How this aligns with company OKRs/strategy]

---

## Goals

**Primary Goal:**
[Main objective - e.g., "Reduce user drop-off at step X by 30%"]

**Secondary Goals:**
1. [Goal 2 - e.g., "Increase feature adoption to 60% of users"]
2. [Goal 3 - e.g., "Reduce support tickets by 25%"]

**Success Metrics** (from `/pm.discover` hypothesis):

| Metric | Baseline | Target | Timeline |
|--------|----------|--------|----------|
| [Leading indicator 1] | [Current] | [Target] | [When] |
| [Leading indicator 2] | [Current] | [Target] | [When] |
| [Lagging indicator] | [Current] | [Target] | [When] |

**Measurement Plan:**
- Data source: [Where metrics come from]
- Tracking: [How we'll measure]
- Review cadence: [Weekly / Monthly]

## Non-Goals

**What We're NOT Building (At Least Not Now):**

1. [Non-goal 1 - with reasoning why not now]
2. [Non-goal 2 - clarify scope boundaries]
3. [Non-goal 3 - set expectations]

**Why These Are Non-Goals:**
[Explain scope decisions based on effort vs. impact from /pm.research]

---

## Users & Personas

**From:** `/pm.interview` synthesis

### Primary Persona: [Persona 1 Name]

**Profile:**
- Role: [Job title]
- Company type: [Size, industry]
- Experience level: [Years in role]
- Tech savviness: [High / Medium / Low]

**Pain Points** (from interviews):
- Pain severity: [X.X/10 average]
- Top frustration: [Main pain from synthesis]
- Quote:
  > "[Quote from interview]"

**Current Behavior:**
- How they work today: [Workflow from interviews]
- Tools they use: [Current tools]
- Workarounds: [What they do to cope]

**Needs:**
1. [Must-have 1 from /pm.interview synthesis - mentioned by X% of participants]
2. [Must-have 2]
3. [Must-have 3]

**Success Looks Like:**
[What would make this persona love the solution - from interviews]

---

### Secondary Persona: [Persona 2 Name]

**Profile:**
- Role: [Job title]
- Company type: [Size, industry]
- Experience level: [Years in role]
- Tech savviness: [High / Medium / Low]

**Pain Points** (from interviews):
- Pain severity: [X.X/10 average]
- Top frustration: [Main pain from synthesis]
- Quote:
  > "[Quote from interview]"

**Current Behavior:**
- How they work today: [Workflow from interviews]
- Tools they use: [Current tools]
- Workarounds: [What they do to cope]

**Needs:**
1. [Must-have 1 from synthesis]
2. [Must-have 2]
3. [Must-have 3]

**Success Looks Like:**
[What would make this persona love the solution]

---

**Persona Prioritization:**
- Primary persona: [Persona 1] ([X%] of target market)
- Secondary persona: [Persona 2] ([Y%] of target market)
- Reasoning: [Why primary first - from /pm.research market sizing]

---

## User Stories & Acceptance Criteria

**Note:** Detailed user stories will be created in `/pm.stories` command.

**Epic-Level Stories:**

### Epic 1: [Epic Name]

**As a** [persona],
**I want to** [capability],
**So that** [benefit/outcome from interviews].

**Acceptance Criteria (High-Level):**
- [ ] [Criteria 1 - must-have from /pm.interview]
- [ ] [Criteria 2]
- [ ] [Criteria 3]

**Priority:** P0 (Must-Have)
**Rationale:** [Why this is must-have - from /pm.interview synthesis: mentioned by X% of participants]

---

### Epic 2: [Epic Name]

**As a** [persona],
**I want to** [capability],
**So that** [benefit/outcome].

**Acceptance Criteria (High-Level):**
- [ ] [Criteria 1]
- [ ] [Criteria 2]
- [ ] [Criteria 3]

**Priority:** P1 (Should-Have)
**Rationale:** [Why P1 - evidence from interviews]

---

### Epic 3: [Epic Name]

**As a** [persona],
**I want to** [capability],
**So that** [benefit/outcome].

**Acceptance Criteria (High-Level):**
- [ ] [Criteria 1]
- [ ] [Criteria 2]
- [ ] [Criteria 3]

**Priority:** P2 (Nice-to-Have)
**Rationale:** [Why P2 - evidence from interviews]

---

**Feature Prioritization Framework** (from `/pm.interview` synthesis):

| Feature | % Users Mentioned | Pain Score | Priority |
|---------|-------------------|------------|----------|
| [Feature 1] | [X%] | [9/10] | P0 |
| [Feature 2] | [Y%] | [7/10] | P1 |
| [Feature 3] | [Z%] | [5/10] | P2 |

**MVP Scope:** P0 features only
**V1.1 Scope:** P0 + P1 features
**Future Consideration:** P2 features

---

## Functional Requirements

**Note:** Requirements based on validated user needs from `/pm.interview` and feasibility from `/pm.research`.

### Requirement 1: [Requirement Title]

**Description:**
[What the system must do - clear, specific]

**User Need:**
[Which user need this addresses - from /pm.interview]

**Acceptance Criteria:**

**Given** [precondition],
**When** [user action],
**Then** [expected outcome].

**Example:**
**Given** user has data ready to sync,
**When** they click "Sync Now" button,
**Then** system syncs data within 5 seconds AND displays success message.

**NASA Checklist:**
- ✅ **Necessary:** [Why we must have this - user evidence]
- ✅ **Concise:** [Clear and unambiguous description]
- ✅ **Feasible:** [Technically possible per /pm.research]
- ✅ **Testable:** [Clear pass/fail criteria defined]
- ✅ **Unambiguous:** [No room for interpretation]
- ✅ **Complete:** [All necessary details included]

**Priority:** [P0 / P1 / P2]
**Dependencies:** [Other requirements or systems]

---

### Requirement 2: [Requirement Title]

**Description:**
[What the system must do]

**User Need:**
[Which user need this addresses]

**Acceptance Criteria:**

**Given** [precondition],
**When** [user action],
**Then** [expected outcome].

**NASA Checklist:**
- ✅ **Necessary:** [Why we must have this]
- ✅ **Concise:** [Clear description]
- ✅ **Feasible:** [Technically possible]
- ✅ **Testable:** [Clear criteria]
- ✅ **Unambiguous:** [No ambiguity]
- ✅ **Complete:** [All details included]

**Priority:** [P0 / P1 / P2]
**Dependencies:** [Other requirements or systems]

---

### Requirement 3: [Requirement Title]

**Description:**
[What the system must do]

**User Need:**
[Which user need this addresses]

**Acceptance Criteria:**

**Given** [precondition],
**When** [user action],
**Then** [expected outcome].

**NASA Checklist:**
- ✅ **Necessary:** [Why we must have this]
- ✅ **Concise:** [Clear description]
- ✅ **Feasible:** [Technically possible]
- ✅ **Testable:** [Clear criteria]
- ✅ **Unambiguous:** [No ambiguity]
- ✅ **Complete:** [All details included]

**Priority:** [P0 / P1 / P2]
**Dependencies:** [Other requirements or systems]

---

**Total Requirements:** [N requirements]
- P0 (Must-Have): [N requirements]
- P1 (Should-Have): [N requirements]
- P2 (Nice-to-Have): [N requirements]

---

## Non-Functional Requirements

### Performance

**REQ-PERF-1: Response Time**
- All API calls must respond within 500ms at p95
- Rationale: Users mentioned speed as critical (from /pm.interview)
- Test Method: Load testing with [N] concurrent users

**REQ-PERF-2: Availability**
- System uptime ≥99.9%
- Rationale: Users need 24/7 access (from /pm.interview)

### Scalability

**REQ-SCALE-1: User Capacity**
- Support [N] concurrent users
- Growth plan: [X%] user growth per quarter
- Based on: /pm.research market sizing (SOM projection)

### Security

**REQ-SEC-1: Data Encryption**
- All data encrypted at rest (AES-256) and in transit (TLS 1.3)
- Rationale: Compliance requirement, user concern from interviews

**REQ-SEC-2: Authentication**
- Support SSO (SAML 2.0, OAuth 2.0)
- Rationale: [X%] of enterprise users require SSO (from /pm.interview)

### Usability

**REQ-UX-1: Onboarding Time**
- New users productive within 10 minutes
- Rationale: Users mentioned competitor takes 2+ weeks (from /pm.interview)
- Test Method: Usability testing with [N] participants

**REQ-UX-2: Accessibility**
- WCAG 2.1 Level AA compliance
- Rationale: [Compliance / User need from interviews]

### Reliability

**REQ-REL-1: Data Integrity**
- Zero data loss tolerance
- Backup & recovery within 1 hour
- Rationale: User concern from /pm.interview

### Compatibility

**REQ-COMPAT-1: Browser Support**
- Chrome, Firefox, Safari (latest 2 versions)
- Rationale: User environment from /pm.interview

**REQ-COMPAT-2: Integrations**
- Must integrate with [System X], [System Y]
- Rationale: [X%] of users need these integrations (from /pm.interview)

---

## Technical Approach

**From:** `/pm.research` technical feasibility assessment

### High-Level Architecture

**Approach:**
[High-level solution architecture from /pm.research]

**Key Components:**
1. [Component 1 - description]
2. [Component 2 - description]
3. [Component 3 - description]

**Technology Stack:**
- Frontend: [Technologies]
- Backend: [Technologies]
- Database: [Technologies]
- Infrastructure: [Cloud provider, services]

**Rationale:**
[Why this approach - from /pm.research technical feasibility]

### Integration Points

| System | Integration Type | Data Flow | Owner |
|--------|------------------|-----------|-------|
| [System 1] | [REST API / Webhook / etc.] | [Bi-directional / One-way] | [Team name] |
| [System 2] | [Type] | [Flow] | [Owner] |

### Technical Risks

**From:** `/pm.research` technical feasibility

**Risk 1: [Risk name]**
- **Likelihood:** [High / Medium / Low]
- **Impact:** [High / Medium / Low]
- **Mitigation:** [How to reduce risk from /pm.research]

**Risk 2: [Risk name]**
- **Likelihood:** [High / Medium / Low]
- **Impact:** [High / Medium / Low]
- **Mitigation:** [How to reduce risk]

### Technical Constraints

**Existing System Constraints:**
[Constraints from /pm.research technical assessment]

**Must Work With:**
[Existing systems we cannot change]

**Cannot Use:**
[Technologies that are off-limits]

---

## Design & UX

### Design Principles

**From User Interviews:**
1. [Principle 1 - e.g., "Simple over feature-rich" - from /pm.interview feedback]
2. [Principle 2 - e.g., "Fast over perfect" - users prioritize speed]
3. [Principle 3]

### Key User Flows

**Flow 1: [Flow name - e.g., "First-time setup"]**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Success Criteria:**
- Time to complete: [X minutes or less]
- Success rate: [≥Y% of users complete without help]

**Flow 2: [Core workflow]**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Success Criteria:**
- Time to complete: [X minutes or less]
- Success rate: [≥Y% of users complete without help]

### UI/UX Requirements

**REQ-UX-1: Onboarding**
- Guided tour for first-time users
- Rationale: Users mentioned competitor has steep learning curve (from /pm.interview)

**REQ-UX-2: Error Handling**
- Clear, actionable error messages
- Rationale: Users frustrated by cryptic errors (from /pm.interview)

### Design Assets

- Wireframes: [Link to Figma/Sketch]
- Mockups: [Link]
- Prototypes: [Link]
- Design system: [Link to component library]

---

## Go-to-Market Strategy

### Target Launch Date

**MVP Launch:** [YYYY-MM-DD]
**V1.1 Launch:** [YYYY-MM-DD]

**Timeline Rationale:**
[Based on effort estimate from /pm.research technical feasibility]

### Launch Phases

**Phase 1: Alpha (Internal)**
- Users: Internal team ([N] users)
- Duration: [X weeks]
- Goal: Validate core functionality

**Phase 2: Beta (Limited External)**
- Users: [N] friendly customers from /pm.interview participants
- Duration: [X weeks]
- Goal: Validate with real users, gather feedback

**Phase 3: GA (General Availability)**
- Users: All customers
- Rollout: [Gradual / All at once]
- Support: [Support plan]

### Success Criteria (Launch)

**Alpha Exit Criteria:**
- [ ] All P0 requirements met
- [ ] No P0 bugs
- [ ] Internal team validation complete

**Beta Exit Criteria:**
- [ ] [X%] of beta users rate experience ≥8/10
- [ ] Success metrics trending positive
- [ ] No P0 or P1 bugs

**GA Readiness:**
- [ ] Beta success criteria met
- [ ] Support documentation complete
- [ ] Sales/CS training complete
- [ ] Monitoring & alerting configured

### Marketing & Positioning

**From:** `/pm.research` competitive analysis

**Positioning Statement:**
"[One-sentence positioning from /pm.research]"

**Key Messaging:**
- Differentiation 1: [vs. Competitor A]
- Differentiation 2: [vs. Competitor B]
- Proof point: [Evidence from /pm.interview - e.g., "10x faster setup"]

**Target Channels:**
- [Channel 1 - e.g., "In-app announcement"]
- [Channel 2 - e.g., "Email to target segment"]
- [Channel 3 - e.g., "Blog post"]

### Pricing

**From:** `/pm.interview` pricing feedback

**Pricing Model:** [Per user / Per company / Usage-based]

**Pricing Tiers:**
- [Tier 1]: $[X]/month - [Features included]
- [Tier 2]: $[Y]/month - [Features included]

**Rationale:**
- Expected price from interviews: $[Z]
- Maximum willingness to pay: $[W]
- Competitive pricing: [Competitor range]

---

## Dependencies

### Internal Dependencies

| Dependency | Owner | Status | Impact if Delayed |
|------------|-------|--------|-------------------|
| [API from Team X] | [Team X] | [In Progress] | [Blocks feature Y] |
| [Design system update] | [Design team] | [Not Started] | [Delays by 2 weeks] |

### External Dependencies

| Dependency | Vendor | Status | Mitigation |
|------------|--------|--------|------------|
| [Third-party API] | [Vendor name] | [Available] | [Backup plan if unavailable] |

---

## Risks

**Risk Register** (Updated from `/pm.research`):

**Risk 1: [Risk name]**
- **Category:** [Technical / Market / Competitive / Adoption]
- **Likelihood:** [High / Medium / Low]
- **Impact:** [High / Medium / Low]
- **Risk Score:** [H×H=Critical / H×M=High / etc.]
- **Mitigation:** [How to reduce]
- **Owner:** [Who's responsible]
- **Status:** [Open / Mitigated / Closed]

**Risk 2: [Risk name]**
- **Category:** [Technical / Market / Competitive / Adoption]
- **Likelihood:** [High / Medium / Low]
- **Impact:** [High / Medium / Low]
- **Risk Score:** [H×H=Critical / H×M=High / etc.]
- **Mitigation:** [How to reduce]
- **Owner:** [Who's responsible]
- **Status:** [Open / Mitigated / Closed]

**Risk Heat Map:**

|         | High Impact | Medium Impact | Low Impact |
|---------|-------------|---------------|------------|
| **High Likelihood** | [Risk 1] | [Risk 3] | [Risk 5] |
| **Medium Likelihood** | [Risk 2] | [Risk 4] | |
| **Low Likelihood** | | [Risk 6] | |

**Top 3 Risks to Monitor:**
1. [Risk with highest score]
2. [Second highest]
3. [Third highest]

---

## Open Questions

**Questions Requiring Answer Before Development:**

1. [Question 1 - e.g., "Should we support mobile web or native app?"]
   - **Context:** [Why this matters]
   - **Options:** [Option A, Option B]
   - **Owner:** [Who will decide]
   - **Deadline:** [When we need answer]

2. [Question 2]
   - **Context:** [Why this matters]
   - **Options:** [Options to consider]
   - **Owner:** [Who will decide]
   - **Deadline:** [When we need answer]

---

## Decisions Log

**Decision 1: [Decision title]**
- **Date:** [YYYY-MM-DD]
- **Decision:** [What was decided]
- **Rationale:** [Why - based on evidence]
- **Alternatives Considered:** [What we didn't choose and why]
- **Owner:** [Who made decision]

**Decision 2: [Decision title]**
- **Date:** [YYYY-MM-DD]
- **Decision:** [What was decided]
- **Rationale:** [Why - based on evidence]
- **Alternatives Considered:** [What we didn't choose and why]
- **Owner:** [Who made decision]

---

## Appendix

### Discovery Artifacts

**All discovery work referenced in this PRD:**

1. **Discovery Session:** `.gobuildme/specs/pm-discovery/[session-id]/discovery.md`
   - Problem exploration & opportunity scoring
   - Hypothesis formation

2. **User Interviews:** `.gobuildme/specs/<feature>/interviews/`
   - Interview guide: `interview-guide.md`
   - Individual interviews: `interview-01.md` through `interview-[N].md`
   - Synthesis: `synthesis.md`

3. **Market Research:** `.gobuildme/specs/<feature>/research/market-research.md`
   - TAM/SAM/SOM analysis
   - Market trends
   - Customer segments

4. **Competitive Analysis:** `.gobuildme/specs/<feature>/research/competitive-analysis.md`
   - Competitor deep-dives
   - Feature comparison matrix
   - Competitive gaps

5. **Analytics Report:** `.gobuildme/specs/<feature>/research/analytics-report.md`
   - Problem validation metrics
   - Business impact quantification
   - Funnel analysis

6. **Technical Feasibility:** `.gobuildme/specs/<feature>/research/technical-feasibility.md`
   - Architecture approach
   - Effort estimates
   - Technical risks

7. **Validation Report:** `.gobuildme/specs/<feature>/validation-report.md`
   - Overall validation score: [X.X/10]
   - Decision: GO (all dimensions passed)

### References

**Market Research Sources:**
- [Source 1 - report name, date]
- [Source 2]

**Competitive Intelligence:**
- [Competitor A] - [Source, date]
- [Competitor B] - [Source, date]

**User Research:**
- [N] user interviews ([Date range])
- [N] companies represented
- [Industries: list]

### Glossary

**[Term 1]:** [Definition]
**[Term 2]:** [Definition]

### Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [YYYY-MM-DD] | [PM name] | Initial PRD |
| 1.1 | [YYYY-MM-DD] | [PM name] | [What changed] |
