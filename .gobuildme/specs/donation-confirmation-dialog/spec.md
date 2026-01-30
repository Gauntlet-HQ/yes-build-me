---
description: "Specification for donation confirmation dialog modal"
metadata:
  feature_name: "donation-confirmation-dialog"
  artifact_type: specify
  created_timestamp: "2026-01-30T18:55:00Z"
  created_by_git_user: "Zac Smith"
  input_summary:
    - "Add confirmation dialog before donation submission"
    - "Display donation amount for user verification"
    - "Show campaign name in confirmation"
    - "Allow user to cancel before processing"
    - "Display donor name and message preview"
---

# Donation Confirmation Dialog Specification

## Epic & PR Slice Context (Incremental Delivery)

| Field | Value |
|-------|-------|
| Epic Link | https://github.com/Gauntlet-HQ/yes-build-me/issues/10 |
| PR Slice | standalone |
| Depends On | (none) |

### This PR Delivers
- ConfirmationModal component
- Integration with DonationForm to show modal before API call
- Display of campaign name, donation amount, donor name, and message

### Deferred to Future PRs (Out of Scope)
- None - standalone feature

## Overview

Add a confirmation modal that intercepts the donation submission flow, displaying a summary of the donation details for user verification before processing.

## Functional Requirements

| ID | Requirement |
|----|-------------|
| FR-001 | System displays confirmation modal when user clicks "Donate Now" button |
| FR-002 | Modal displays campaign name prominently |
| FR-003 | Modal displays donation amount formatted as currency |
| FR-004 | Modal displays donor name (for guest users) or indicates logged-in user |
| FR-005 | Modal displays donation message if provided |
| FR-006 | Modal displays "anonymous" indicator if user selected anonymous donation |
| FR-007 | Modal provides "Confirm" button to proceed with donation |
| FR-008 | Modal provides "Cancel" button to return to form without submitting |
| FR-009 | Modal closes and form submits when user confirms |
| FR-010 | Modal closes and form remains editable when user cancels |

## Key Entities

| Entity | Attributes | Description |
|--------|------------|-------------|
| ConfirmationModal | isOpen, onConfirm, onCancel, donationDetails | Reusable modal component |
| DonationDetails | amount, donorName, message, isAnonymous, campaignName | Data displayed in modal |

## User Scenarios & Acceptance Criteria

### Scenario 1: User confirms donation
**Given** a user has filled out the donation form with valid data
**When** the user clicks "Donate Now"
**Then** a confirmation modal appears with donation details

### Scenario 2: User cancels from modal
**Given** the confirmation modal is displayed
**When** the user clicks "Cancel"
**Then** the modal closes and the form remains with entered data

### Scenario 3: Guest user donation
**Given** a guest user (not logged in) fills out the donation form
**When** the confirmation modal is displayed
**Then** the modal shows the donor name they entered

## Acceptance Criteria

### Happy Path
| ID | Criteria |
|----|----------|
| AC-001 | **Given** valid donation form data **When** user clicks "Donate Now" **Then** confirmation modal opens with all details visible |
| AC-002 | **Given** confirmation modal is open **When** user clicks "Confirm" **Then** donation is submitted and modal closes |
| AC-003 | **Given** confirmation modal is open **When** user clicks "Cancel" **Then** modal closes and form data is preserved |
| AC-004 | **Given** guest user **When** modal displays **Then** entered donor name is shown |
| AC-005 | **Given** logged-in user **When** modal displays **Then** user's account name is shown |
| AC-006 | **Given** anonymous donation selected **When** modal displays **Then** "Anonymous donation" indicator is shown |

### Edge Cases
| ID | Criteria |
|----|----------|
| AC-B01 | **Given** no message entered **When** modal displays **Then** message section is hidden or shows "No message" |
| AC-B02 | **Given** user clicks outside modal **When** modal is open **Then** modal remains open (no accidental dismissal) |
| AC-B03 | **Given** user presses Escape key **When** modal is open **Then** modal closes (cancel behavior) |

### Error Handling
| ID | Criteria |
|----|----------|
| AC-E01 | **Given** donation API fails after confirm **When** error occurs **Then** error message is displayed and modal closes |

## Test Specifications

### Unit Tests: ConfirmationModal Component
- **Test File**: `packages/client/src/components/donations/__tests__/ConfirmationModal.test.jsx`
- **Test Cases**:
  - `test_modal_renders_with_donation_details()` - Renders amount, name, message (AC-001)
  - `test_modal_calls_onConfirm_when_confirm_clicked()` - Confirm callback fires (AC-002)
  - `test_modal_calls_onCancel_when_cancel_clicked()` - Cancel callback fires (AC-003)
  - `test_modal_shows_anonymous_indicator()` - Shows anonymous text when isAnonymous=true (AC-006)
  - `test_modal_hides_message_when_empty()` - Message section hidden when no message (AC-B01)
  - `test_modal_closes_on_escape_key()` - Escape key triggers onCancel (AC-B03)

### Integration Tests: DonationForm with Modal
- **Test File**: `packages/client/src/components/donations/__tests__/DonationForm.integration.test.jsx`
- **Test Cases**:
  - `test_form_shows_modal_on_submit()` - Modal appears on form submit (AC-001)
  - `test_form_submits_on_modal_confirm()` - API called after confirm (AC-002)
  - `test_form_preserves_data_on_modal_cancel()` - Form data intact after cancel (AC-003)

## Component Design

### ConfirmationModal Props
```javascript
{
  isOpen: boolean,           // Controls modal visibility
  onConfirm: () => void,     // Called when user confirms
  onCancel: () => void,      // Called when user cancels
  campaignName: string,      // Campaign being donated to
  amount: number,            // Donation amount
  donorName: string,         // Name of donor
  message: string | null,    // Optional message
  isAnonymous: boolean       // Anonymous donation flag
}
```

### UI Layout
```
┌────────────────────────────────────────┐
│         Confirm Your Donation          │
├────────────────────────────────────────┤
│  Campaign: [Campaign Name]             │
│  Amount: $XX.XX                        │
│  From: [Donor Name] (or "Anonymous")   │
│  Message: [Message text or hidden]     │
├────────────────────────────────────────┤
│  [Cancel]              [Confirm]       │
└────────────────────────────────────────┘
```

## Implementation Notes

- Modal uses Tailwind CSS for styling (consistent with existing UI)
- Modal backdrop prevents interaction with form while open
- Confirm button uses green styling (primary action)
- Cancel button uses gray/outline styling (secondary action)
- Modal should be accessible (focus trap, keyboard navigation)

## Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `packages/client/src/components/donations/ConfirmationModal.jsx` | Create | New modal component |
| `packages/client/src/components/donations/DonationForm.jsx` | Modify | Add modal state and integration |

## Checklist

- [ ] All acceptance criteria have corresponding test cases
- [ ] Component props are fully specified
- [ ] UI mockup/layout is defined
- [ ] Accessibility requirements noted
- [ ] Files to modify are identified
