### Product Manager Quality Dimensions

When validating product requirements and business specifications, ensure these quality dimensions are addressed:

#### Business Value & Impact

**Problem Definition**:
- Is the problem statement clearly articulated and validated?
- Are customer pain points quantified (frequency, severity, impact)?
- Is the problem size estimated (affected users, revenue impact)?
- Are alternative solutions considered and documented?

**Success Metrics**:
- Are success metrics clearly defined and measurable?
- Are success metric targets quantified (e.g., "increase conversion by 15%")?
- Is measurement methodology specified (how will we track success)?
- Are success metric timelines defined (when will we measure)?

**Business Goals Alignment**:
- Are business objectives explicitly stated?
- Is alignment with company OKRs/KPIs documented?
- Is revenue impact estimated (direct or indirect)?
- Are strategic priorities clearly articulated?

#### User Value & Experience

**User Stories**:
- Are user stories written in "As a [user], I want [goal], so that [benefit]" format?
- Are user personas clearly identified?
- Are user motivations and context documented?
- Are user stories independent and testable?

**User Journey**:
- Is the end-to-end user journey documented?
- Are user touchpoints clearly identified?
- Are pain points in current journey documented?
- Is improved journey clearly articulated?

**User Experience Impact**:
- Is UX improvement quantified (reduced clicks, faster task completion)?
- Are accessibility requirements specified?
- Is mobile vs. desktop experience differentiated?
- Are edge cases in user experience identified?

#### Market & Competitive Context

**Market Validation**:
- Is market size estimated?
- Are target market segments identified?
- Is market readiness assessed?
- Are go-to-market considerations documented?

**Competitive Analysis**:
- Are competitor offerings analyzed?
- Is competitive differentiation clearly articulated?
- Are competitive advantages documented?
- Is competitive positioning strategy defined?

**Market Timing**:
- Is market timing rationale documented?
- Are seasonal or cyclical factors considered?
- Is time-to-market urgency justified?
- Are market windows of opportunity identified?

#### Scope & Prioritization

**Feature Scope**:
- Is feature scope clearly bounded (what's in, what's out)?
- Are MVP features explicitly identified?
- Are "nice-to-have" features clearly marked?
- Is scope creep prevention strategy defined?

**Prioritization Rationale**:
- Is prioritization framework specified (RICE, MoSCoW, value vs. effort)?
- Are priority decisions justified with data?
- Are dependencies on other features identified?
- Is phased rollout strategy defined?

**Trade-offs**:
- Are scope vs. timeline trade-offs explicitly stated?
- Are quality vs. speed trade-offs documented?
- Are build vs. buy decisions justified?
- Are resource allocation trade-offs clear?

#### Requirements Quality

**Requirement Completeness**:
- Are functional requirements complete (all scenarios covered)?
- Are non-functional requirements specified (performance, security)?
- Are edge cases and error scenarios documented?
- Are internationalization/localization requirements specified?

**Requirement Clarity**:
- Are requirements unambiguous (one clear interpretation)?
- Are vague terms quantified ("fast" → "<200ms p95")?
- Are assumptions explicitly stated?
- Are constraints clearly documented?

**Requirement Traceability**:
- Are requirements linked to user stories?
- Are requirements traceable to business goals?
- Are acceptance criteria linked to requirements?
- Is requirement dependency mapping complete?

#### Stakeholder Management

**Stakeholder Identification**:
- Are all stakeholders identified (internal and external)?
- Are stakeholder interests and concerns documented?
- Is stakeholder influence/impact mapped?
- Are stakeholder approval requirements specified?

**Communication Plan**:
- Is stakeholder communication plan defined?
- Are communication channels specified?
- Is update frequency defined?
- Are escalation paths documented?

**Alignment & Buy-in**:
- Is stakeholder alignment on goals documented?
- Are conflicting stakeholder interests identified?
- Is conflict resolution strategy defined?
- Is decision-making authority clearly specified?

#### Risk Management

**Risk Identification**:
- Are technical risks identified and assessed?
- Are business risks documented?
- Are user adoption risks analyzed?
- Are market/competitive risks specified?

**Risk Mitigation**:
- Is mitigation strategy defined for each high/critical risk?
- Are contingency plans documented?
- Is risk monitoring strategy specified?
- Are risk owners assigned?

**Assumptions & Dependencies**:
- Are critical assumptions explicitly listed?
- Are external dependencies identified?
- Are dependency risks assessed?
- Are assumption validation plans defined?

#### Launch & Rollout Strategy

**Launch Plan**:
- Is launch strategy defined (big bang vs. phased)?
- Are launch success criteria specified?
- Is rollback strategy documented?
- Are launch communication plans defined?

**Feature Flags & Toggles**:
- Is feature flag strategy specified?
- Are gradual rollout percentages defined?
- Is feature flag removal plan documented?
- Are A/B testing requirements specified?

**Go/No-Go Criteria**:
- Are launch readiness criteria defined?
- Are launch blockers explicitly listed?
- Is launch decision-making process specified?
- Are post-launch monitoring plans documented?

#### Metrics & Success Validation

**Measurement Strategy**:
- Are instrumentation requirements specified?
- Are analytics events defined?
- Is data collection strategy documented?
- Are privacy/compliance requirements considered?

**Success Dashboard**:
- Are success metrics dashboards specified?
- Is dashboard update frequency defined?
- Are alert thresholds specified?
- Is success review cadence defined?

**Post-Launch Validation**:
- Is post-launch validation timeline defined?
- Are success criteria validation methods specified?
- Is iteration strategy based on metrics defined?
- Are pivot criteria documented?

#### Compliance & Governance

**Regulatory Compliance**:
- Are applicable regulations identified (GDPR, HIPAA, SOC2)?
- Are compliance requirements documented?
- Is compliance validation strategy specified?
- Are audit requirements defined?

**Legal & Privacy**:
- Are legal review requirements specified?
- Are privacy implications documented?
- Are data retention requirements defined?
- Are terms of service updates required?

**Internal Governance**:
- Are internal approval processes documented?
- Are budget approval requirements specified?
- Are resource allocation approvals obtained?
- Are architectural review requirements defined?

#### Research & Evidence Quality

**Source Authority**:
- Are market claims backed by authoritative sources (Gartner, Forrester, IDC)?
- Are competitive claims verified with official sources (company websites, Crunchbase)?
- Are user feedback claims sourced from reputable platforms (G2, Capterra)?
- Are statistical claims traceable to primary sources?

**Citation Quality**:
- Are all data points and claims properly cited?
- Do citations include source name, publication date, and URL?
- Are citations recent (last 12 months for market data)?
- Are archived versions of pricing/claims available?

**Research Completeness**:
- Is market sizing supported by multiple sources?
- Are competitive claims verified across at least 3 competitors?
- Are user research findings triangulated with analytics?
- Are technical feasibility claims validated with engineering?

**Evidence Traceability**:
- Is every major claim linked to its source?
- Are research quality scores documented (if fact-checking performed)?
- Are weak sources flagged with warnings or alternatives suggested?
- Is research quality visible to stakeholders?

**Research Verification**:
- Has `/gbm.fact-check` been run on market research files?
- Are weak sources (Quality C-D) addressed with corrections?
- Is overall research quality score acceptable (B+ or higher for critical decisions)?
- Are persona-critical claims (market sizing, pricing) verified at 90%+ quality?

**Note**: Research quality is advisory and does not block progression, but higher quality improves stakeholder confidence and decision-making accuracy. Use `/gbm.fact-check` to verify and improve research quality.

---

**Quality Gate Checklist**: Before marking PRD/specification as "ready for development":

- [ ] Problem statement is validated and quantified
- [ ] Success metrics are defined, measurable, and time-bound
- [ ] User stories are complete, independent, and testable
- [ ] Market validation and competitive analysis are documented
- [ ] Feature scope and prioritization rationale are clear
- [ ] Requirements are complete, clear, and unambiguous
- [ ] Stakeholder alignment is documented and approved
- [ ] Risks are identified with mitigation strategies
- [ ] Launch strategy and rollout plan are defined
- [ ] Metrics and measurement strategy are specified
- [ ] Compliance and governance requirements are addressed
- [ ] Research quality is verified (optional: run `/gbm.fact-check` for quality assessment)
