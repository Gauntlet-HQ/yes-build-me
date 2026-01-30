---
description: "Technical plan for donation confirmation dialog modal implementation"
metadata:
  feature_name: "donation-confirmation-dialog"
  artifact_type: plan
  created_timestamp: "2026-01-30T19:00:00Z"
  created_by_git_user: "Zac Smith"
  input_summary:
    - "Create reusable ConfirmationModal component"
    - "Integrate modal with existing DonationForm"
    - "Use Tailwind CSS consistent with existing UI"
    - "Support keyboard accessibility (Escape key)"
    - "Handle both guest and logged-in user flows"
---

# Donation Confirmation Dialog - Technical Plan

## Epic & PR Slice Context (Incremental Delivery)

| Field | Value |
|-------|-------|
| Epic Link | https://github.com/Gauntlet-HQ/yes-build-me/issues/10 |
| PR Slice | standalone |
| Depends On | (none) |

### This PR Delivers
- ConfirmationModal.jsx component
- DonationForm.jsx integration with modal state
- Keyboard accessibility (Escape to close)

### Deferred to Future PRs (Out of Scope)
- None - standalone feature

## Technical Approach

### Architecture Decision
- **Pattern**: Controlled modal component with parent state management
- **Rationale**: DonationForm owns modal state for tight integration with form submission flow

### Technology Choices
| Choice | Option | Rationale |
|--------|--------|-----------|
| Styling | Tailwind CSS | Consistent with existing codebase |
| State | React useState | Simple boolean toggle, no external state needed |
| Events | Native keyboard events | Standard accessibility pattern |

## Implementation Phases

### Phase 1: Create ConfirmationModal Component
- Create `packages/client/src/components/donations/ConfirmationModal.jsx`
- Implement props interface per spec
- Add backdrop with click prevention
- Style with Tailwind (green confirm, gray cancel)
- Add Escape key handler

### Phase 2: Integrate with DonationForm
- Add `showModal` state to DonationForm
- Modify `handleSubmit` to show modal instead of immediate API call
- Create `handleConfirm` to proceed with API call
- Create `handleCancel` to close modal
- Pass campaign name prop (requires parent to provide it)

### Phase 3: Testing
- Unit tests for ConfirmationModal
- Integration tests for DonationForm with modal

## Files to Create/Modify

| File | Action | Lines Est. |
|------|--------|------------|
| `packages/client/src/components/donations/ConfirmationModal.jsx` | Create | ~60 |
| `packages/client/src/components/donations/DonationForm.jsx` | Modify | ~25 |

**Total Estimated LoC**: ~85

## Component Interface

### ConfirmationModal Props
```javascript
{
  isOpen: boolean,
  onConfirm: () => void,
  onCancel: () => void,
  campaignName: string,
  amount: number,
  donorName: string,
  message: string | null,
  isAnonymous: boolean
}
```

## Dependencies

- No new dependencies required
- Uses existing: React, Tailwind CSS

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Campaign name not available in form | Low | Medium | Check CampaignDetail passes name to form |
| Focus trap complexity | Low | Low | Use simple Escape handler, skip full focus trap for MVP |

## Acceptance Criteria Traceability

| AC | Implementation |
|----|----------------|
| AC-001 | Modal opens on form submit |
| AC-002 | onConfirm triggers API call |
| AC-003 | onCancel closes modal, preserves form |
| AC-004 | donorName prop displays guest name |
| AC-005 | donorName prop displays user name |
| AC-006 | isAnonymous shows indicator |
| AC-B01 | Conditional message rendering |
| AC-B02 | Backdrop click does nothing |
| AC-B03 | Escape key calls onCancel |
| AC-E01 | Error handling in DonationForm |

## Checklist

- [x] Technical approach defined
- [x] Files identified
- [x] Component interface specified
- [x] Risks assessed
- [x] AC traceability mapped
