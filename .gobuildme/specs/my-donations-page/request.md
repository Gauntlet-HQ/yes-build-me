# Feature Request: My Donations Page

**Issue**: #11 - Add 'My Donations' page to user dashboard
**Date**: 2026-01-30
**Requestor**: User
**Persona**: fullstack_engineer
**Workflow**: Full (new feature, 6+ files expected)

## Problem Statement

Users currently have no way to view their complete donation history. The dashboard only shows a preview of the 5 most recent donations. Users need a dedicated page to:
- View all donations they've made
- See which campaigns they supported
- Review donation amounts and messages
- Track their giving history over time

## Current State

**Dashboard Preview** (`packages/client/src/pages/Dashboard.jsx`):
- Shows only 5 most recent donations
- Limited information displayed
- No way to see full history
- No filtering or sorting options

**Backend API** (already exists):
- Endpoint: `GET /api/donations/mine` (protected)
- Returns: Array of donation objects with campaign details
- Data includes: `id`, `amount`, `message`, `created_at`, `campaign_title`, `campaign_image`, `campaign_id`

## Desired Outcome

A dedicated "My Donations" page that:
1. **Displays complete donation history** - All donations, not just 5
2. **Shows campaign context** - Campaign title, image, link to campaign
3. **Provides donation details** - Amount, date, message (if any)
4. **Calculates totals** - Total amount donated, number of donations
5. **Accessible from navigation** - Link in header/dashboard
6. **Protected route** - Requires authentication

## Acceptance Criteria

### AC-1: New Page Created
- [ ] New page component: `packages/client/src/pages/MyDonations.jsx`
- [ ] Page displays all user donations (not limited to 5)
- [ ] Shows loading state while fetching data
- [ ] Shows empty state if no donations exist
- [ ] Shows error state if API call fails

### AC-2: Routing Configured
- [ ] New route added to `App.jsx`: `/donations`
- [ ] Route is protected (requires authentication)
- [ ] Route imported and configured correctly

### AC-3: Navigation Updated
- [ ] Link to "My Donations" added to navigation
- [ ] Link visible when user is authenticated
- [ ] Link highlights when on donations page
- [ ] Dashboard "My Donations" section links to full page

### AC-4: Donation Display
- [ ] Each donation shows: campaign title, amount, date, message
- [ ] Campaign title is clickable (links to campaign detail)
- [ ] Donations sorted by date (newest first)
- [ ] Proper formatting for amounts ($X,XXX.XX)
- [ ] Relative time display (e.g., "2 days ago")

### AC-5: Summary Statistics
- [ ] Total amount donated displayed
- [ ] Total number of donations displayed
- [ ] Statistics prominently shown at top of page

### AC-6: Responsive Design
- [ ] Page works on mobile devices
- [ ] Donation cards stack properly on small screens
- [ ] Navigation accessible on mobile

## Technical Approach

### Files to Create
1. `packages/client/src/pages/MyDonations.jsx` - New page component

### Files to Modify
1. `packages/client/src/App.jsx` - Add route
2. `packages/client/src/components/layout/Header.jsx` - Add navigation link
3. `packages/client/src/pages/Dashboard.jsx` - Add link to full donations page

### Components to Reuse
- `DonationList` component (may need enhancement)
- `DonationItem` component (displays individual donations)
- API client (`api.get('/donations/mine')`)

### API Integration
- Endpoint: `GET /api/donations/mine`
- Already implemented in backend
- Returns donation array with campaign details
- No backend changes needed

## Out of Scope

- Filtering donations by date range
- Sorting options (newest/oldest/amount)
- Exporting donation history
- Donation receipts/PDFs
- Editing or deleting donations

(These can be added in future iterations if needed)

## Constitution Alignment

- **user-first**: Provides users with complete visibility into their giving history
- **simplicity**: Reuses existing components and API, minimal new code
- **api-first**: Backend API already exists, no changes needed

## Risk Assessment

- **Risk Level**: Low-Medium
- **Complexity**: Medium (new page, routing, navigation)
- **Breaking Changes**: None
- **Dependencies**: Existing API endpoint, existing components
- **Testing**: Manual testing + visual verification

## Success Metrics

- Users can view all their donations (not limited to 5)
- Page loads quickly (<1 second)
- Navigation is intuitive and accessible
- Mobile experience is smooth
- No console errors or warnings

