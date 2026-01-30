---
description: "Implementation plan for donation confirmation dialog - frontend-only UX enhancement"
metadata:
  feature_name: "donation-confirmation-dialog"
  artifact_type: plan
  created_timestamp: "2026-01-30T19:30:00Z"
  created_by_git_user: "Omkar Chavan"
  input_summary:
    - "Add confirmation modal before donation submission"
    - "Reuse existing Modal component"
    - "Display donation amount and donor details"
    - "No backend changes required"
    - "Fee breakdown display in confirmation"
---

# Donation Confirmation Dialog - Technical Plan

**Feature Branch**: `feature/donation-confirmation-dialog`  
**Persona**: `fullstack_engineer`  
**Issue**: [#10](https://github.com/Gauntlet-HQ/yes-build-me/issues/10)

## Epic & PR Slice Context (Incremental Delivery)

| Field | Value |
|-------|-------|
| Epic Link | (none) |
| PR Slice | standalone |
| Depends On | (none) |

### This PR Delivers
- Confirmation modal integration in DonationForm.jsx
- Display of donation amount, donor name, message, anonymous status
- Fee breakdown display
- Confirm/Cancel button actions

### Deferred to Future PRs (Out of Scope)
| Future PR | Scope | Dependencies |
|-----------|-------|--------------|
| (none) | Standalone feature | N/A |

---

## Technical Approach

### Implementation Strategy
- **Pattern**: Intercept form submission, show modal, then proceed on confirm
- **Reuse**: Leverage existing `Modal` component from `components/common/Modal.jsx`
- **State**: Add single boolean `showConfirmation` state to DonationForm
- **Estimated LoC**: ~50 lines (modal content + state logic)

### Closest Existing Implementations

| Feature | Files | Similarity | Reusable Patterns |
|---------|-------|------------|-------------------|
| Modal component | `components/common/Modal.jsx` | 90% | Modal structure, escape key handling, backdrop click |
| DonationForm | `components/donations/DonationForm.jsx` | 100% | Form state, validation, submission flow |

### Alternatives Considered

| Decision Point | Options | Chosen | Rationale |
|----------------|---------|--------|-----------|
| Confirmation UI | 1. Browser confirm()<br>2. Custom modal<br>3. Inline expansion | Custom modal | Consistent UX, better styling, reuses existing Modal |
| State location | 1. DonationForm state<br>2. Context<br>3. URL state | DonationForm state | Simplest approach, component-local concern |

---

## Components & State Management

### State Changes to DonationForm.jsx

```javascript
// New state
const [showConfirmation, setShowConfirmation] = useState(false)

// Modified flow
handleSubmit → validateForm → setShowConfirmation(true)
handleConfirm → actual API call
handleCancel → setShowConfirmation(false)
```

### Component Structure

```
DonationForm.jsx (modified)
├── Form inputs (existing)
├── Submit button (existing, now triggers confirmation)
└── Modal (new)
    └── ConfirmationContent (inline JSX)
        ├── Amount display
        ├── Donor info (conditional)
        ├── Message preview (conditional)
        ├── Anonymous indicator (conditional)
        ├── Fee breakdown
        └── Confirm/Cancel buttons
```

### Props Flow

| Component | Props | Source |
|-----------|-------|--------|
| Modal | `isOpen`, `onClose`, `title` | DonationForm state |
| ConfirmationContent | `amount`, `donorName`, `message`, `isAnonymous` | DonationForm state |

---

## API Contracts

**No API changes required.** This feature modifies only the frontend UX layer.

Existing API endpoint used:
- `POST /campaigns/:id/donations` - unchanged, called after user confirms

---

## Data Model & Migrations

**No database changes required.** This is a frontend-only enhancement.

### Frontend Data Structure (for confirmation display)

```typescript
interface DonationPreview {
  amount: number;
  donorName?: string;      // Guest donations only
  message?: string;        // Optional
  isAnonymous: boolean;    // Logged-in users only
}
```

---

## API Integration

Existing integration unchanged:
- Form collects data → Validation → **[NEW: Confirmation modal]** → API call
- No new API calls introduced
- Error handling remains in existing `catch` block

---

## Error Model

### Existing Error Handling (unchanged)
| Error Type | Handling | User Feedback |
|------------|----------|---------------|
| Validation failure | Prevent modal | Form error message |
| API error | Catch in handleConfirm | Display error, allow retry |
| Network failure | Catch in handleConfirm | Display error message |

### New Modal-Specific Handling
| Scenario | Handling |
|----------|----------|
| Modal open + Escape key | Close modal, preserve form |
| Modal open + Backdrop click | Close modal, preserve form |
| Confirm + API failure | Show error, keep modal open for retry |

---

## Observability

**Minimal observability requirements** (learning project):
- Console.log for debugging during development
- No structured logging or metrics required per constitution

### Debug Points (development only)
- Log when confirmation modal opens
- Log when user confirms/cancels
- Log API submission result

---

## Routing

**No routing changes required.** The confirmation modal is displayed inline within the existing campaign detail page.

---

## i18n

**Not applicable** for this learning project. All strings are hardcoded English.

Future consideration: If i18n is added, extract these strings:
- "Confirm Your Donation"
- "You are about to donate"
- "Donor Name"
- "Message"
- "Anonymous donation"
- "Confirm Donation"
- "Cancel"

---

## Constitution Alignment

- **component-based**: Reuses Modal component, keeps confirmation logic in DonationForm
- **api-first**: No API changes, frontend-only enhancement
- **test-driven**: Tests planned for modal display, confirm/cancel actions
- **security-first**: No security impact, validation unchanged
- **simplicity**: Minimal state addition, reuses existing patterns
- **pr-slicing-rules**: Single concern, ~50 LoC, standalone PR

---

## Files to Create/Modify

| File | Action | Changes |
|------|--------|---------|
| `packages/client/src/components/donations/DonationForm.jsx` | Modify | Add state, modal, handlers (~50 LoC) |

---

## Task Generation Approach

Tasks will be generated in `/gbm.tasks` following this sequence:
1. Add confirmation state and handlers
2. Add Modal import and JSX structure
3. Add confirmation content (amount, donor info, message)
4. Add fee breakdown display
5. Wire up confirm/cancel buttons
6. Add tests for modal interactions

---

## Complexity Tracking

| Metric | Budget | Planned | Variance |
|--------|--------|---------|----------|
| Files changed | 2 | 1 | -50% |
| Estimated LoC | 50 | 50 | 0% |
| New dependencies | 0 | 0 | 0% |
| API changes | 0 | 0 | 0% |

**Status**: ✅ Within budget

---

## Review Checklist

- [x] Technical approach documented
- [x] State management defined
- [x] Error handling considered
- [x] Constitution alignment verified
- [x] Complexity within budget
- [x] All persona-required sections addressed
