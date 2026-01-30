# Lite Plan: sort-dropdown-campaign-list

## Change Summary
Add a sort dropdown to the Browse Campaigns page allowing users to sort by newest, most funded, and ending soon. Backend API already supports `sort` and `order` query parameters.

## Files to Modify
- `packages/client/src/pages/BrowseCampaigns.jsx` - Add sort state, dropdown UI, and pass params to API

## Approach
- Add `sortOptions` array with values: newest, most_funded, ending_soon
- Add `sort` state variable (default: 'newest')
- Add sort dropdown next to category dropdown
- Update `fetchCampaigns` to include sort/order params
- Add sort to useEffect dependencies

## Risks/Notes
- None - straightforward UI addition using existing API support
