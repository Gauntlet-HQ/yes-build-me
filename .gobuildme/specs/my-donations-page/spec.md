# Technical Specification: My Donations Page

**Feature**: My Donations Page
**Issue**: #11
**Date**: 2026-01-30
**Status**: Draft

## Overview

Create a dedicated page (`/donations`) that displays a user's complete donation history with summary statistics, replacing the limited 5-donation preview currently shown on the dashboard.

## Architecture

### Component Structure

```
MyDonations (new page)
├── Page Header (title + stats)
├── Summary Statistics Card
│   ├── Total Donated
│   └── Total Donations Count
└── Donations List
    └── Donation Cards (reuse existing pattern)
        ├── Campaign Title (clickable)
        ├── Campaign Image
        ├── Donation Amount
        ├── Donation Date
        └── Donation Message (if exists)
```

### Data Flow

```
MyDonations.jsx
    ↓ (useEffect on mount)
api.get('/donations/mine')
    ↓ (authenticated request)
Backend: GET /api/donations/mine
    ↓ (returns array)
[{
  id, amount, message, created_at,
  campaign_id, campaign_title, campaign_image
}]
    ↓ (setState)
Render donations list + statistics
```

## API Contract

### Endpoint (Existing)
**GET** `/api/donations/mine`

**Authentication**: Required (JWT token)

**Response**:
```json
[
  {
    "id": 1,
    "campaign_id": 5,
    "user_id": 2,
    "amount": 50,
    "message": "Great cause!",
    "is_anonymous": 0,
    "donor_name": null,
    "created_at": "2026-01-25T10:30:00Z",
    "campaign_title": "Help Build Community Center",
    "campaign_image": "https://..."
  }
]
```

**Error Responses**:
- `401 Unauthorized` - No token or invalid token
- `500 Internal Server Error` - Database error

## Component Specifications

### 1. MyDonations Page Component

**File**: `packages/client/src/pages/MyDonations.jsx`

**State**:
- `donations` (array) - List of user donations
- `loading` (boolean) - Loading state
- `error` (string|null) - Error message

**Lifecycle**:
1. Mount: Fetch donations via `api.get('/donations/mine')`
2. Loading: Show spinner
3. Success: Display donations + statistics
4. Error: Show error message
5. Empty: Show empty state with link to browse campaigns

**UI States**:
- **Loading**: Centered spinner
- **Error**: Error message with retry option
- **Empty**: "No donations yet" + link to `/campaigns`
- **Success**: Statistics card + donations list

**Statistics Calculation**:
```javascript
const totalDonated = donations.reduce((sum, d) => sum + d.amount, 0)
const donationCount = donations.length
```

### 2. App.jsx Route Addition

**File**: `packages/client/src/App.jsx`

**Change**: Add new protected route

**Location**: After `/dashboard` route (line ~50)

**Code**:
```jsx
<Route
  path="/donations"
  element={
    <ProtectedRoute>
      <MyDonations />
    </ProtectedRoute>
  }
/>
```

**Import**: Add `import MyDonations from './pages/MyDonations'`

### 3. Header Navigation Update

**File**: `packages/client/src/components/layout/Header.jsx`

**Desktop Navigation** (line ~34):
Add link after "Dashboard" link:
```jsx
<Link to="/donations" className="text-gray-600 hover:text-gray-900">
  My Donations
</Link>
```

**Mobile Navigation** (line ~96):
Add link after "Dashboard" link:
```jsx
<Link
  to="/donations"
  className="text-gray-600 hover:text-gray-900"
>
  My Donations
</Link>
```

### 4. Dashboard Link Update

**File**: `packages/client/src/pages/Dashboard.jsx`

**Change**: Add "View All" link to donations section header

**Location**: Line 125 (inside donations section header)

**Code**:
```jsx
<div className="flex justify-between items-center mb-4">
  <h2 className="text-xl font-bold text-gray-900">My Donations</h2>
  <Link
    to="/donations"
    className="text-sm text-green-600 hover:text-green-700 font-medium"
  >
    View All →
  </Link>
</div>
```

## UI/UX Design

### Page Layout

```
┌─────────────────────────────────────────┐
│ My Donations                            │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Summary Statistics                  │ │
│ │ Total Donated: $XXX | X Donations   │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ [Campaign Image] Campaign Title     │ │
│ │ "Message text..."                   │ │
│ │ 2 days ago              $50         │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ [Campaign Image] Another Campaign   │ │
│ │ 1 week ago              $25         │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Styling Guidelines

**Colors**:
- Primary: `green-600` (links, amounts)
- Text: `gray-900` (headings), `gray-600` (body), `gray-500` (meta)
- Background: `white` (cards), `gray-50` (page background)

**Spacing**:
- Page padding: `px-4 py-8`
- Card spacing: `space-y-4`
- Card padding: `p-6`

**Typography**:
- Page title: `text-3xl font-bold`
- Section title: `text-xl font-bold`
- Campaign title: `font-medium text-gray-900`
- Amount: `font-bold text-green-600`

## Responsive Design

**Mobile** (<768px):
- Single column layout
- Stack campaign image above text
- Full-width cards
- Reduce padding

**Desktop** (≥768px):
- Max width container: `max-w-4xl mx-auto`
- Campaign image inline with text
- Comfortable spacing

## Error Handling

**Network Error**:
```jsx
<div className="text-center py-12">
  <p className="text-red-600 mb-4">Failed to load donations</p>
  <button onClick={fetchDonations}>Retry</button>
</div>
```

**401 Unauthorized**:
- Handled by API client (redirects to `/login`)

**Empty State**:
```jsx
<div className="text-center py-12">
  <p className="text-gray-500 mb-4">You haven't made any donations yet.</p>
  <Link to="/campaigns">Browse campaigns</Link>
</div>
```

## Testing Checklist

- [ ] Page loads without errors
- [ ] Loading spinner shows while fetching
- [ ] Donations display correctly
- [ ] Statistics calculate correctly
- [ ] Campaign links work
- [ ] Empty state shows when no donations
- [ ] Error state shows on API failure
- [ ] Navigation link highlights when active
- [ ] Mobile responsive layout works
- [ ] Protected route redirects if not authenticated

