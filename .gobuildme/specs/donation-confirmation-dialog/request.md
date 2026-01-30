---
description: "Add confirmation dialog before submitting donation to prevent accidental submissions"
metadata:
  feature_name: "donation-confirmation-dialog"
  artifact_type: request
  created_timestamp: "2026-01-30T19:15:00Z"
  created_by_git_user: "Omkar Chavan"
  input_summary:
    - "Show confirmation modal before processing donation"
    - "Display donation amount in confirmation dialog"
    - "Allow user to confirm or cancel the donation"
    - "Prevent accidental form submissions"
    - "Improve user experience with explicit confirmation step"
---

# Request

## Summary

Users can currently submit donations immediately without any confirmation step. This enhancement adds a confirmation dialog that displays the donation amount before processing, giving users a chance to review and confirm their donation or cancel if they made a mistake.

**Issue Reference**: [#10 - No confirmation dialog before submitting donation](https://github.com/Gauntlet-HQ/yes-build-me/issues/10)

## Epic & PR Slice (Incremental Delivery)

| Field | Value |
|-------|-------|
| Epic Link | (none) |
| PR Slice | standalone |
| Depends On | (none) |

### PR Scope Assessment
- **Concerns**: 1 (Frontend UI only)
- **Est. LoC**: ~40
- **Status**: ✅ Within guidelines

### This PR Delivers (In-Scope)
- Confirmation modal integration in DonationForm component
- Display of donation amount, donor name (if applicable), and message preview
- Confirm and Cancel button actions
- Proper state management for modal visibility

### Deferred to Future PRs (Out of Scope)
- None - standalone feature

## Goals

- Show a confirmation modal when user clicks "Donate Now" button
- Display the donation amount prominently in the confirmation dialog
- Include donor name and message (if provided) in the confirmation
- Provide clear "Confirm" and "Cancel" buttons in the modal
- Only process the donation after explicit user confirmation
- Reuse the existing Modal component from `components/common/Modal.jsx`

## Non-Goals

- Payment gateway integration (out of scope for this learning project)
- Email confirmation after donation
- Donation receipt generation
- Multi-step donation wizard
- Donation amount editing within the confirmation dialog

## Assumptions

- The existing Modal component is suitable for this use case (confirmed by code review)
- Form validation will still occur before showing the confirmation dialog
- The confirmation dialog should match the existing UI style (Tailwind CSS)
- No backend changes are required - this is purely a frontend UX enhancement

## Open Questions

1. Should the confirmation dialog show a breakdown of any fees? (Assuming no for learning project) - yes show the breakdown of any fees
2. Should there be a timeout or auto-dismiss on the confirmation dialog? (Assuming no - user must explicitly confirm or cancel) - No

## References

- GitHub Issue: https://github.com/Gauntlet-HQ/yes-build-me/issues/10
- Existing Modal component: `packages/client/src/components/common/Modal.jsx`
- DonationForm component: `packages/client/src/components/donations/DonationForm.jsx`
