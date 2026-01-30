# Clarifications: My Donations Page

**Feature**: My Donations Page
**Date**: 2026-01-30

## Questions & Answers

### Q1: Should we add filtering/sorting options?
**Answer**: No, out of scope for initial implementation. Display all donations sorted by date (newest first) only. Future enhancements can add:
- Filter by date range
- Sort by amount/date
- Search by campaign name

**Rationale**: Keep initial implementation simple. Backend API already returns sorted data.

### Q2: Should we paginate the donations list?
**Answer**: No, not for initial implementation. Display all donations on a single page. Most users won't have hundreds of donations.

**Future consideration**: Add pagination if users report performance issues with large donation lists.

### Q3: Should we show campaign images?
**Answer**: Yes, display campaign images alongside donation details for better visual context. Use the `campaign_image` field from API response.

**Fallback**: If image fails to load, show placeholder or just campaign title.

### Q4: Should anonymous donations be shown?
**Answer**: Yes, show all donations made by the authenticated user, regardless of whether they were marked anonymous. The "anonymous" flag only affects how the donation appears to others viewing the campaign.

### Q5: Where should the navigation link be placed?
**Answer**: Add "My Donations" link in the header navigation, between "Dashboard" and "Profile" links. This makes it easily accessible from any page.

**Mobile**: Include in mobile menu as well, in the same position.

### Q6: Should we reuse existing DonationList component?
**Answer**: No, the existing `DonationList` component is designed for campaign detail pages (showing who donated to a campaign). The MyDonations page needs a different layout showing which campaigns the user donated to.

**Approach**: Create custom donation card layout within MyDonations.jsx component.

### Q7: What should the empty state look like?
**Answer**: Show friendly message "You haven't made any donations yet" with a call-to-action button linking to `/campaigns` to browse campaigns.

**Design**: Center-aligned, with icon (optional), message, and prominent CTA button.

### Q8: Should we show donation messages?
**Answer**: Yes, if the user included a message with their donation, display it below the campaign title. Truncate long messages with ellipsis.

### Q9: What statistics should we display?
**Answer**: Show two key metrics at the top:
1. **Total Donated**: Sum of all donation amounts (formatted as currency)
2. **Total Donations**: Count of donations made

**Layout**: Display side-by-side in a summary card above the donations list.

### Q10: Should the page be accessible to non-authenticated users?
**Answer**: No, this is a protected route. Only authenticated users can view their donation history. Non-authenticated users should be redirected to `/login`.

## Design Decisions

### Decision 1: Route Path
**Chosen**: `/donations`
**Alternatives considered**: `/my-donations`, `/dashboard/donations`
**Rationale**: Short, clean URL. Consistent with other top-level routes.

### Decision 2: Component Location
**Chosen**: `packages/client/src/pages/MyDonations.jsx`
**Rationale**: Follows existing pattern for page components. Consistent with Dashboard.jsx, Profile.jsx, etc.

### Decision 3: Data Fetching
**Chosen**: Fetch on component mount using `useEffect`
**Alternatives considered**: Global state, React Query
**Rationale**: Consistent with existing patterns in Dashboard.jsx. No need for caching or global state for this feature.

### Decision 4: Loading State
**Chosen**: Full-page spinner (same as Dashboard.jsx)
**Rationale**: Consistent UX with other pages. Simple implementation.

### Decision 5: Error Handling
**Chosen**: Show error message with retry button
**Rationale**: Gives user control to retry if network fails. Better UX than just showing error.

## Assumptions

1. **Backend API is stable**: The `/api/donations/mine` endpoint works correctly and returns expected data structure
2. **No pagination needed**: Users won't have so many donations that performance becomes an issue
3. **Images are optional**: Campaign images may be null/missing, need fallback handling
4. **Sorting is server-side**: Backend returns donations sorted by `created_at DESC`
5. **No real-time updates**: Page doesn't need to auto-refresh when new donations are made

## Out of Scope (Confirmed)

- Filtering by date range, campaign, or amount
- Sorting options (newest/oldest/highest/lowest)
- Exporting donation history (CSV, PDF)
- Donation receipts or tax documents
- Editing or canceling donations
- Donation analytics or charts
- Sharing donation history
- Donation reminders or recurring donations

## Dependencies

**Existing Code**:
- `api.get()` - API client (packages/client/src/api/client.js)
- `useAuth()` - Auth context hook
- `ProtectedRoute` - Route wrapper component
- Tailwind CSS classes - Styling

**Backend**:
- `GET /api/donations/mine` endpoint (already implemented)

**No new dependencies required**.

## Acceptance Criteria Refinement

Based on clarifications, the acceptance criteria remain as defined in request.md with these clarifications:
- AC-4: Campaign images should be displayed (with fallback for missing images)
- AC-5: Statistics = Total donated + donation count only
- Navigation link goes between Dashboard and Profile in header

