# Implementation Plan: My Donations Page

**Feature**: My Donations Page
**Issue**: #11
**Date**: 2026-01-30
**Estimated Effort**: 2-3 hours
**Risk Level**: Low-Medium

## Implementation Order

### Phase 1: Create MyDonations Page Component
**Priority**: High (foundation)
**Estimated Time**: 60-90 minutes

**File**: `packages/client/src/pages/MyDonations.jsx`

**Steps**:
1. Create new file with basic React component structure
2. Import required dependencies (useState, useEffect, Link, api, useAuth)
3. Set up component state (donations, loading, error)
4. Implement data fetching in useEffect
5. Create loading state UI (spinner)
6. Create error state UI (error message + retry button)
7. Create empty state UI (no donations message + CTA)
8. Create summary statistics card (total donated, donation count)
9. Create donations list layout
10. Create individual donation card layout
11. Add responsive styling (mobile + desktop)
12. Test component in isolation

**Dependencies**: None (can start immediately)

**Validation**:
- Component renders without errors
- All UI states work (loading, error, empty, success)
- Statistics calculate correctly
- Donations display with correct data
- Links to campaigns work
- Responsive on mobile and desktop

### Phase 2: Register Route in App.jsx
**Priority**: High (required for navigation)
**Estimated Time**: 10 minutes

**File**: `packages/client/src/App.jsx`

**Steps**:
1. Import MyDonations component
2. Add new Route element with path="/donations"
3. Wrap in ProtectedRoute component
4. Place after Dashboard route (line ~50)
5. Verify route works by navigating to /donations

**Dependencies**: Phase 1 complete (MyDonations component exists)

**Validation**:
- Route accessible at /donations
- Protected route redirects to /login if not authenticated
- Page renders correctly when authenticated

### Phase 3: Add Navigation Links in Header
**Priority**: High (user discovery)
**Estimated Time**: 15 minutes

**File**: `packages/client/src/components/layout/Header.jsx`

**Steps**:
1. Add "My Donations" link in desktop navigation (after Dashboard, line ~36)
2. Add "My Donations" link in mobile navigation (after Dashboard, line ~100)
3. Ensure link only shows when user is authenticated
4. Test navigation from header
5. Verify mobile menu closes after clicking link (existing issue #3)

**Dependencies**: Phase 2 complete (route registered)

**Validation**:
- Link visible in desktop navigation when authenticated
- Link visible in mobile navigation when authenticated
- Link not visible when logged out
- Clicking link navigates to /donations
- Active state highlights correctly (if implemented)

### Phase 4: Add "View All" Link in Dashboard
**Priority**: Medium (discoverability)
**Estimated Time**: 10 minutes

**File**: `packages/client/src/pages/Dashboard.jsx`

**Steps**:
1. Locate "My Donations" section header (line ~125)
2. Add "View All →" link next to section title
3. Link to /donations route
4. Style as secondary link (green-600, small text)
5. Test link from dashboard

**Dependencies**: Phase 2 complete (route registered)

**Validation**:
- "View All" link visible in dashboard donations section
- Link navigates to /donations
- Link styled consistently with design system

## Technical Implementation Details

### MyDonations Component Structure

```jsx
import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import api from '../api/client'

export default function MyDonations() {
  const [donations, setDonations] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchDonations()
  }, [])

  const fetchDonations = async () => {
    try {
      setLoading(true)
      setError(null)
      const data = await api.get('/donations/mine')
      setDonations(data)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  // Calculate statistics
  const totalDonated = donations.reduce((sum, d) => sum + d.amount, 0)
  const donationCount = donations.length

  // Render loading state
  if (loading) return <LoadingSpinner />

  // Render error state
  if (error) return <ErrorState error={error} onRetry={fetchDonations} />

  // Render empty state
  if (donations.length === 0) return <EmptyState />

  // Render donations list
  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <h1>My Donations</h1>
      <StatisticsCard total={totalDonated} count={donationCount} />
      <DonationsList donations={donations} />
    </div>
  )
}
```

### Statistics Calculation

```javascript
const totalDonated = donations.reduce((sum, d) => sum + d.amount, 0)
const donationCount = donations.length
```

### Donation Card Layout

```jsx
<Link
  to={`/campaigns/${donation.campaign_id}`}
  className="block bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow"
>
  <div className="flex gap-4">
    {donation.campaign_image && (
      <img
        src={donation.campaign_image}
        alt={donation.campaign_title}
        className="w-24 h-24 object-cover rounded-lg"
      />
    )}
    <div className="flex-1">
      <h3 className="font-medium text-gray-900">{donation.campaign_title}</h3>
      {donation.message && (
        <p className="text-sm text-gray-500 mt-1">{donation.message}</p>
      )}
      <p className="text-xs text-gray-400 mt-2">
        {formatRelativeTime(donation.created_at)}
      </p>
    </div>
    <div className="text-right">
      <p className="font-bold text-green-600 text-xl">
        ${donation.amount.toLocaleString()}
      </p>
    </div>
  </div>
</Link>
```

## Testing Strategy

### Manual Testing Checklist
- [ ] Navigate to /donations when logged in
- [ ] Verify loading spinner shows while fetching
- [ ] Verify donations display correctly
- [ ] Verify statistics are accurate
- [ ] Click campaign link, verify navigation works
- [ ] Test with 0 donations (empty state)
- [ ] Test with network error (error state)
- [ ] Test retry button in error state
- [ ] Verify responsive layout on mobile
- [ ] Test navigation links in header (desktop + mobile)
- [ ] Test "View All" link from dashboard
- [ ] Verify protected route (logout and try to access)

### Edge Cases to Test
- User with 0 donations
- User with 1 donation
- User with 100+ donations
- Donations with no message
- Donations with very long messages
- Campaigns with missing images
- Network timeout/failure
- Invalid token (401 error)

## Rollback Plan

If issues arise:
1. Remove route from App.jsx
2. Remove navigation links from Header.jsx
3. Remove "View All" link from Dashboard.jsx
4. Delete MyDonations.jsx file
5. Commit rollback with message "Revert: My Donations page"

No database changes, so rollback is safe and simple.

## Post-Implementation

### Verification Steps
1. Run `npm run dev` and test all functionality
2. Check browser console for errors
3. Test on mobile device or responsive mode
4. Verify no TypeScript/ESLint errors
5. Test with different user accounts

### Future Enhancements (Out of Scope)
- Add filtering by date range
- Add sorting options (date, amount)
- Add pagination for large lists
- Add donation analytics/charts
- Add export to CSV functionality
- Add search by campaign name

