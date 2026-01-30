# PM Handoff Templates

Reference templates for `/gbm.pm.handoff` artifacts. Use these structures when creating handoff checklists.

---

## Pre-Handoff Verification

### Documentation Complete
- [ ] PRD finalized and approved
- [ ] User stories in Jira
- [ ] Alignment checklist complete
- [ ] All discovery artifacts available

### Design Assets Ready
- [ ] Wireframes + mockups complete
- [ ] Prototype available
- [ ] Design specs shared with engineering

### Technical Preparation
- [ ] Technical design reviewed
- [ ] API contracts defined
- [ ] Database schema designed
- [ ] Feature flags configured

### Resources Allocated
- [ ] Engineering team assigned
- [ ] Designer + QA assigned
- [ ] Sprint capacity confirmed
- [ ] No blocking dependencies

### Stakeholder Sign-offs
- [ ] Engineering Lead
- [ ] Design Lead
- [ ] QA Lead
- [ ] Security Lead (if applicable)

---

## Kickoff Meeting Agenda (90 min)

| Section | Duration | Owner | Content |
|---------|----------|-------|---------|
| Feature Context | 15 min | PM | Problem, users, business impact, success metrics |
| Solution Overview | 20 min | PM + Eng | Technical approach, components, user flows, design walkthrough |
| Requirements | 20 min | PM | P0 requirements with AC, P1 summary, out of scope |
| Sprint Plan | 15 min | Eng Lead | Story points, sprint allocation, milestones, launch timeline |
| Dependencies & Risks | 10 min | PM + Eng | Critical dependencies table, top risks with mitigations |
| Roles & Responsibilities | 5 min | PM | PM/Eng/Design/QA roles during development |
| Communication | 5 min | PM | Slack channels, meetings, decision framework, escalation |
| Q&A | 15 min | All | Questions logged with owners |
| Next Steps | 5 min | PM | Immediate actions and commitments |

---

## PM Support Plan

### Availability
- Slack: <2hr response during business hours
- Urgent: Phone/text
- Backup PM: [Name]
- Office hours: [Day/Time]

### Weekly Check-ins (30 min with Eng Lead)
- Progress update
- Blockers discussion
- Scope questions
- Team morale

### Sprint Demos
- Engineering shows completed stories
- PM validates against AC
- Feedback captured

### Decision Log

| Date | Decision | Context | Rationale | Impact | Stakeholders |
|------|----------|---------|-----------|--------|-------------|
| [Date] | [What] | [Why needed] | [Why this choice] | [Scope/timeline] | [Who told] |

### Scope Change Authority
- Minor (<2 points): PM decides
- Medium (2-8 points): PM + Eng Lead
- Major (>8 points): Escalate to leadership

---

## Bug Severity Levels

| Severity | Description | Response | Fix Timeline |
|----------|-------------|----------|--------------|
| P0 (Critical) | Blocks dev, data loss, security | 1 hour | Same day |
| P1 (High) | Core broken, >50% users | 4 hours | This sprint |
| P2 (Medium) | Partial break, <50% users | 1 day | Next sprint |
| P3 (Low) | Minor, edge case, cosmetic | 1 week | Backlog |

---

## Milestone Tracking

### Sprint Milestones
| Sprint | Goal | Stories | Status | Demo Date |
|--------|------|---------|--------|-----------|
| 1 | [Goal] | [List] | [🟢/🟡/🔴] | [Date] |

### Launch Milestones
| Phase | Date | Audience | Success Criteria |
|-------|------|----------|-----------------|
| Alpha | [Date] | Internal | [List] |
| Beta | [Date] | [N] customers | [List] |
| GA | [Date] | All | [List] |

---

## Success Metrics Tracking

| Metric | Baseline | Target | Current | Status |
|--------|----------|--------|---------|--------|
| [Leading 1] | [X] | [Y] | [Z] | [🟢/🟡/🔴] |
| [Leading 2] | [X] | [Y] | [Z] | [🟢/🟡/🔴] |
| [Lagging] | [X] | [Y] | [Z] | [🟢/🟡/🔴] |

**Status:** 🟢 >80% | 🟡 50-80% | 🔴 <50%

---

## Ongoing PM Responsibilities

**Weekly:** Sprint progress, bug triage, requirements Q&A, ceremonies, stakeholder updates, demos

**As Needed:** Scope decisions, unblock dependencies, design/user testing sessions

**Pre-Launch:** Alpha/beta/GA prep checklists

**Post-Launch:** Monitor metrics, triage issues, collect feedback, iterate

