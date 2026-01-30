---
description: "Add confirmation dialog before submitting donations"
metadata:
  feature_name: "donation-confirmation-dialog"
  artifact_type: request
  created_timestamp: "2026-01-30T18:50:00Z"
  created_by_git_user: "Zac Smith"
  input_summary:
    - "Add confirmation dialog before donation submission"
    - "Display donation amount for user verification"
    - "Prevent accidental submissions"
    - "Allow user to cancel before processing"
    - "Show summary of donation details"
---

# Request

- Date: 2026-01-30
- Requester: GitHub Issue #10
- Feature Branch: `donation-confirmation-dialog`

## Epic & PR Slice (Incremental Delivery)

| Field | Value |
|-------|-------|
| Epic Link | https://github.com/Gauntlet-HQ/yes-build-me/issues/10 |
| PR Slice | standalone |
| Depends On | (none) |

### PR Scope Assessment
- **Concerns**: 1 (Frontend UI)
- **Est. LoC**: ~80
- **Status**: ✅ Within guidelines

### This PR Delivers (In-Scope)
- Confirmation modal component
- Integration with DonationForm
- Display of donation amount and details before submission

### Deferred to Future PRs (Out of Scope)
- None - standalone feature

## Summary

Add a confirmation dialog/modal that appears when users click "Donate Now" on the donation form. The dialog should display the donation amount and allow users to confirm or cancel before the donation is processed. This prevents accidental submissions and gives users a chance to verify their donation amount.

## Goals
- Show confirmation modal before processing donation
- Display donation amount clearly in the modal
- Display donor name (if guest) and message preview
- Allow user to confirm and proceed with donation
- Allow user to cancel and return to form
- Maintain existing form validation behavior

## Non-Goals / Out of Scope
- Payment processing changes
- Receipt/email confirmation
- Donation history tracking
- Multi-currency support

## Assumptions
- Modal will use similar styling to existing UI components
- Modal can be implemented as a simple React component
- No new dependencies required (can use existing Tailwind CSS)

## Open Questions
1. Should the modal show the campaign name as well? yes it should
2. Should there be a "Don't show again" checkbox option? no

## References
- GitHub Issue: https://github.com/Gauntlet-HQ/yes-build-me/issues/10
- Current form: `packages/client/src/components/donations/DonationForm.jsx`
