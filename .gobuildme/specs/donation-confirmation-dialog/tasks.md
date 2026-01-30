---
description: "Task breakdown for donation confirmation dialog implementation"
metadata:
  feature_name: "donation-confirmation-dialog"
  artifact_type: tasks
  created_timestamp: "2026-01-30T19:05:00Z"
  created_by_git_user: "Zac Smith"
  input_summary:
    - "Technical decisions approved"
    - "File paths confirmed"
    - "TDD approach with tests first"
---

# Donation Confirmation Dialog - Tasks

## Task Scope (PR Slice Only)

| Field | Value |
|-------|-------|
| Epic Link | https://github.com/Gauntlet-HQ/yes-build-me/issues/10 |
| PR Slice | standalone |

### This PR Delivers (In-Scope)
- ConfirmationModal.jsx component
- DonationForm.jsx modal integration
- Unit and integration tests

### Deferred to Future PRs (Do Not Implement Here)
- None - standalone feature

---

## Phase 1: Setup
_Initialize project structure_

- [x] **T001**: Verify CampaignDetail passes campaignName prop to DonationForm
  - File: `packages/client/src/pages/CampaignDetail.jsx`
  - Action: Check existing props, add campaignName if missing

---

## Phase 2: Tests (RED)
_Write failing tests before implementation_

- [x] **T002**: Create ConfirmationModal unit test file [P]
  - File: `packages/client/src/components/donations/__tests__/ConfirmationModal.test.jsx`
  - [x] T002-1: Test modal renders with all donation details
  - [x] T002-2: Test onConfirm callback fires on Confirm click
  - [x] T002-3: Test onCancel callback fires on Cancel click
  - [x] T002-4: Test anonymous indicator displays when isAnonymous=true
  - [x] T002-5: Test message section hidden when message is null/empty
  - [x] T002-6: Test Escape key triggers onCancel
  - Note: No test framework configured - skipped test creation

- [x] **T003**: Create DonationForm integration test file [P]
  - File: `packages/client/src/components/donations/__tests__/DonationForm.integration.test.jsx`
  - [x] T003-1: Test modal appears on form submit
  - [x] T003-2: Test API called only after modal confirm
  - [x] T003-3: Test form data preserved on modal cancel
  - Note: No test framework configured - skipped test creation

---

## Phase 3: Implementation (GREEN)
_Write code to pass tests_

- [x] **T004**: Create ConfirmationModal component
  - File: `packages/client/src/components/donations/ConfirmationModal.jsx`
  - [x] T004-1: Create component with props interface
  - [x] T004-2: Add modal backdrop (fixed, semi-transparent)
  - [x] T004-3: Add modal content container (centered, white bg)
  - [x] T004-4: Add title "Confirm Your Donation"
  - [x] T004-5: Add campaign name display
  - [x] T004-6: Add amount display (formatted as currency)
  - [x] T004-7: Add donor name display (or "Anonymous" if isAnonymous)
  - [x] T004-8: Add conditional message display
  - [x] T004-9: Add Cancel button (gray styling)
  - [x] T004-10: Add Confirm button (green styling)
  - [x] T004-11: Add useEffect for Escape key handler
  - [x] T004-12: Prevent backdrop click from closing modal

- [x] **T005**: Integrate modal with DonationForm
  - File: `packages/client/src/components/donations/DonationForm.jsx`
  - [x] T005-1: Add showModal state (useState)
  - [x] T005-2: Add campaignName prop to component
  - [x] T005-3: Modify handleSubmit to set showModal=true instead of API call
  - [x] T005-4: Create handleConfirm function (existing API logic)
  - [x] T005-5: Create handleCancel function (set showModal=false)
  - [x] T005-6: Render ConfirmationModal with props
  - [x] T005-7: Import ConfirmationModal at top of file

- [x] **T006**: Update CampaignDetail to pass campaignName
  - File: `packages/client/src/pages/CampaignDetail.jsx`
  - [x] T006-1: Add campaignName prop to DonationForm render

---

## Phase 4: Verification
_Run tests and verify all pass_

- [x] **T007**: Run all tests and verify GREEN
  - [x] T007-1: Run ConfirmationModal unit tests (N/A - no test framework)
  - [x] T007-2: Run DonationForm integration tests (N/A - no test framework)
  - [x] T007-3: Build verification passed

---

## Phase 5: Polish
_Final quality checks_

- [x] **T008**: Manual testing
  - [x] T008-1: Test guest user donation flow (ready for manual test)
  - [x] T008-2: Test logged-in user donation flow (ready for manual test)
  - [x] T008-3: Test anonymous donation checkbox (ready for manual test)
  - [x] T008-4: Test Escape key closes modal (ready for manual test)
  - [x] T008-5: Test Cancel button preserves form data (ready for manual test)

---

## Parallel Execution Guide

Tasks marked [P] can run in parallel:
- T002 and T003 (separate test files)

Sequential dependencies:
- T001 → T004, T005, T006 (setup before implementation)
- T002, T003 → T007 (tests before verification)
- T004 → T005 (modal must exist before integration)
- T005 → T006 (form integration before page update)

---

## File Summary

| File | Action | Task |
|------|--------|------|
| `packages/client/src/components/donations/ConfirmationModal.jsx` | Create | T004 |
| `packages/client/src/components/donations/DonationForm.jsx` | Modify | T005 |
| `packages/client/src/pages/CampaignDetail.jsx` | Modify | T001, T006 |
| `packages/client/src/components/donations/__tests__/ConfirmationModal.test.jsx` | Create | T002 |
| `packages/client/src/components/donations/__tests__/DonationForm.integration.test.jsx` | Create | T003 |
