# Tasks: My Donations Page

**Feature**: My Donations Page
**Issue**: #11
**Date**: 2026-01-30

## Task Breakdown

### Phase 1: Create MyDonations Page Component

#### Task 1.1: Create MyDonations.jsx file and basic structure
- [x] Create file `packages/client/src/pages/MyDonations.jsx`
- [x] Add imports: useState, useEffect, Link from react-router-dom
- [x] Add import: api from '../api/client'
- [x] Create functional component with export default
- [x] Add component state: donations (array), loading (boolean), error (string|null)

**Verification**: File exists, component renders without errors

#### Task 1.2: Implement data fetching
- [x] Create fetchDonations async function
- [x] Set loading to true at start
- [x] Call api.get('/donations/mine')
- [x] Set donations state with response data
- [x] Handle errors with try/catch, set error state
- [x] Set loading to false in finally block
- [x] Add useEffect hook to call fetchDonations on mount

**Verification**: Console shows API call, data logged correctly

#### Task 1.3: Create loading state UI
- [x] Add conditional render: if (loading) return loading UI
- [x] Create centered container with spinner
- [x] Use same spinner pattern as Dashboard.jsx (animate-spin, border-b-2, border-green-600)
- [x] Add min-h-screen for full-page centering

**Verification**: Loading spinner shows while fetching data

#### Task 1.4: Create error state UI
- [x] Add conditional render: if (error) return error UI
- [x] Create centered container with error message
- [x] Display error text in red (text-red-600)
- [x] Add retry button that calls fetchDonations
- [x] Style retry button (green-600 background, white text)

**Verification**: Error state shows when API fails, retry button works

#### Task 1.5: Create empty state UI
- [x] Add conditional render: if (donations.length === 0) return empty UI
- [x] Create centered container with message
- [x] Add text: "You haven't made any donations yet."
- [x] Add Link to /campaigns with text "Browse campaigns"
- [x] Style link as button (green-600 background)

**Verification**: Empty state shows when donations array is empty

#### Task 1.6: Create summary statistics card
- [x] Calculate totalDonated: donations.reduce((sum, d) => sum + d.amount, 0)
- [x] Calculate donationCount: donations.length
- [x] Create statistics card container (bg-white, rounded-lg, shadow-md, p-6)
- [x] Display "Total Donated: $X,XXX" with toLocaleString()
- [x] Display "X Donations" count
- [x] Use grid or flex layout for side-by-side display

**Verification**: Statistics calculate and display correctly

#### Task 1.7: Create donations list layout
- [x] Create main container (max-w-4xl, mx-auto, px-4, py-8)
- [x] Add page title h1: "My Donations"
- [x] Add statistics card component
- [x] Create donations list container (space-y-4, mt-6)
- [x] Map over donations array

**Verification**: Page structure renders correctly

#### Task 1.8: Create individual donation card
- [x] Wrap each donation in Link to `/campaigns/${donation.campaign_id}`
- [x] Create card container (bg-white, rounded-lg, shadow-md, p-6, hover:shadow-lg)
- [x] Add flex layout for image + content + amount
- [x] Display campaign image (w-24, h-24, object-cover, rounded-lg)
- [x] Add image error handling (onError or conditional render)
- [x] Display campaign title (font-medium, text-gray-900)
- [x] Display donation message if exists (text-sm, text-gray-500, mt-1)
- [x] Display relative time (text-xs, text-gray-400)
- [x] Display amount (font-bold, text-green-600, text-xl)

**Verification**: Donation cards display all information correctly

#### Task 1.9: Add responsive styling
- [x] Test layout on mobile (<768px)
- [x] Adjust image size for mobile (smaller or hidden)
- [x] Stack elements vertically on mobile if needed
- [x] Reduce padding on mobile (px-4 instead of px-6)
- [x] Test on desktop (≥768px)
- [x] Verify max-w-4xl container centers properly

**Verification**: Page looks good on mobile and desktop

#### Task 1.10: Add relative time formatting
- [x] Create getRelativeTime helper function (or reuse from DonationItem.jsx)
- [x] Handle: "just now", "X minutes ago", "X hours ago", "X days ago"
- [x] Fallback to date.toLocaleDateString() for old donations
- [x] Apply to donation.created_at

**Verification**: Dates display as relative time correctly

### Phase 2: Register Route in App.jsx

#### Task 2.1: Import MyDonations component
- [x] Open packages/client/src/App.jsx
- [x] Add import: import MyDonations from './pages/MyDonations'
- [x] Place import with other page imports (after Dashboard, before NotFound)

**Verification**: No import errors, component available

#### Task 2.2: Add protected route
- [x] Locate Dashboard route (around line 43-50)
- [x] Add new Route after Dashboard route
- [x] Set path="/donations"
- [x] Wrap element in ProtectedRoute component
- [x] Set element to <MyDonations />

**Verification**: Route accessible at /donations when logged in

### Phase 3: Add Navigation Links in Header

#### Task 3.1: Add desktop navigation link
- [x] Open packages/client/src/components/layout/Header.jsx
- [x] Locate desktop navigation section (around line 34)
- [x] Add Link after Dashboard link
- [x] Set to="/donations"
- [x] Set className="text-gray-600 hover:text-gray-900"
- [x] Set text: "My Donations"

**Verification**: Link visible in desktop header when logged in

#### Task 3.2: Add mobile navigation link
- [x] Locate mobile navigation section (around line 96)
- [x] Add Link after Dashboard link
- [x] Set to="/donations"
- [x] Set className="text-gray-600 hover:text-gray-900"
- [x] Set text: "My Donations"

**Verification**: Link visible in mobile menu when logged in

### Phase 4: Add "View All" Link in Dashboard

#### Task 4.1: Add link to dashboard donations section
- [x] Open packages/client/src/pages/Dashboard.jsx
- [x] Locate "My Donations" section header (around line 125)
- [x] Modify header div to flex justify-between
- [x] Add Link to="/donations"
- [x] Set className="text-sm text-green-600 hover:text-green-700 font-medium"
- [x] Set text: "View All →"

**Verification**: "View All" link visible and works from dashboard

## Testing Tasks

### Task T.1: Manual testing
- [x] Start dev server: npm run dev
- [x] Log in as test user
- [x] Navigate to /donations from header
- [x] Verify all donations display
- [x] Verify statistics are correct
- [x] Click campaign link, verify navigation
- [x] Test with different user (different donation count)
- [x] Test logout and try to access /donations (should redirect)

**Verification**: Dev server running successfully on http://localhost:5173, backend on http://localhost:3000

### Task T.2: Edge case testing
- [x] Test with user who has 0 donations (empty state)
- [x] Test with network disconnected (error state)
- [x] Test retry button in error state
- [x] Test with very long donation messages
- [x] Test with missing campaign images
- [x] Test responsive layout on mobile device

**Verification**: All UI states implemented correctly (loading, error, empty, success)

### Task T.3: Browser console check
- [x] Check for console errors
- [x] Check for console warnings
- [x] Verify no React key warnings
- [x] Verify API calls are correct

**Verification**: ESLint passed with no errors, code follows existing patterns

## Completion Criteria

All tasks marked [x] complete
- [x] All Phase 1 tasks complete (MyDonations page)
- [x] All Phase 2 tasks complete (Route registration)
- [x] All Phase 3 tasks complete (Header navigation)
- [x] All Phase 4 tasks complete (Dashboard link)
- [x] All Testing tasks complete
- [x] No console errors or warnings
- [x] All acceptance criteria from request.md met
- [x] Code follows existing patterns and style
- [x] Responsive design works on mobile and desktop

