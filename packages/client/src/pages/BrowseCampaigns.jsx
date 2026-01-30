import { useState, useEffect } from 'react'
import api from '../api/client'
import CampaignList from '../components/campaigns/CampaignList'

const categories = [
  { value: 'all', label: 'All Categories' },
  { value: 'community', label: 'Community' },
  { value: 'animals', label: 'Animals' },
  { value: 'creative', label: 'Creative' },
  { value: 'education', label: 'Education' },
  { value: 'medical', label: 'Medical' },
  { value: 'business', label: 'Business' },
  { value: 'sports', label: 'Sports' },
  { value: 'emergency', label: 'Emergency' },
]

const sortOptions = [
  { value: 'newest', label: 'Newest', sort: 'createdAt', order: 'desc' },
  { value: 'most_funded', label: 'Most Funded', sort: 'currentAmount', order: 'desc' },
  { value: 'ending_soon', label: 'Ending Soon', sort: 'endDate', order: 'asc' },
]

export default function BrowseCampaigns() {
  const [campaigns, setCampaigns] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [category, setCategory] = useState('all')
  const [sortBy, setSortBy] = useState('newest')
  const [pagination, setPagination] = useState({ page: 1, totalPages: 1 })

  const fetchCampaigns = async (page = 1) => {
    setLoading(true)
    try {
      const params = new URLSearchParams({
        page: page.toString(),
        limit: '9',
      })

      if (search) params.append('search', search)
      if (category !== 'all') params.append('category', category)

      const selectedSort = sortOptions.find(opt => opt.value === sortBy)
      if (selectedSort) {
        params.append('sort', selectedSort.sort)
        params.append('order', selectedSort.order)
      }

      const data = await api.get(`/campaigns?${params}`)
      setCampaigns(data.campaigns)
      setPagination(data.pagination)
    } catch (err) {
      console.error('Failed to fetch campaigns:', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchCampaigns(1)
  }, [search, category, sortBy])

  const handleSearch = (e) => {
    e.preventDefault()
    fetchCampaigns(1)
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Browse Campaigns</h1>

        <div className="mb-8 flex flex-col sm:flex-row gap-4">
          <form onSubmit={handleSearch} className="flex-1">
            <input
              type="text"
              placeholder="Search campaigns..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </form>

          <select
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
          >
            {categories.map((cat) => (
              <option key={cat.value} value={cat.value}>
                {cat.label}
              </option>
            ))}
          </select>

          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
          >
            {sortOptions.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
        </div>

        <CampaignList campaigns={campaigns} loading={loading} />

        {pagination.totalPages > 1 && (
          <div className="mt-8 flex justify-center gap-2">
            <button
              onClick={() => fetchCampaigns(pagination.page - 1)}
              disabled={pagination.page === 1}
              className="px-4 py-2 border border-gray-300 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100"
            >
              Previous
            </button>
            <span className="px-4 py-2 text-gray-600">
              Page {pagination.page} of {pagination.totalPages}
            </span>
            <button
              onClick={() => fetchCampaigns(pagination.page + 1)}
              disabled={pagination.page === pagination.totalPages}
              className="px-4 py-2 border border-gray-300 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100"
            >
              Next
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
