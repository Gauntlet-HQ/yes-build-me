import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import api from '../api/client'

function getRelativeTime(dateString) {
  const date = new Date(dateString)
  const now = new Date()
  const diffMs = now - date
  const diffSecs = Math.floor(diffMs / 1000)
  const diffMins = Math.floor(diffSecs / 60)
  const diffHours = Math.floor(diffMins / 60)
  const diffDays = Math.floor(diffHours / 24)

  if (diffSecs < 60) return 'just now'
  if (diffMins < 60) return `${diffMins} minute${diffMins > 1 ? 's' : ''} ago`
  if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`
  if (diffDays < 30) return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`
  return date.toLocaleDateString()
}

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

  // Loading state
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600"></div>
      </div>
    )
  }

  // Error state
  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <p className="text-red-600 mb-4">Failed to load donations: {error}</p>
          <button
            onClick={fetchDonations}
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
          >
            Retry
          </button>
        </div>
      </div>
    )
  }

  // Empty state
  if (donations.length === 0) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <p className="text-gray-500 mb-4">You haven't made any donations yet.</p>
          <Link
            to="/campaigns"
            className="inline-block px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 font-medium"
          >
            Browse Campaigns
          </Link>
        </div>
      </div>
    )
  }

  // Success state - donations list
  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      {/* Page Title */}
      <h1 className="text-3xl font-bold text-gray-900 mb-6">My Donations</h1>

      {/* Summary Statistics Card */}
      <div className="bg-white rounded-lg shadow-md p-6 mb-6">
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-sm text-gray-500 mb-1">Total Donated</p>
            <p className="text-2xl font-bold text-green-600">
              ${totalDonated.toLocaleString()}
            </p>
          </div>
          <div>
            <p className="text-sm text-gray-500 mb-1">Total Donations</p>
            <p className="text-2xl font-bold text-gray-900">
              {donationCount}
            </p>
          </div>
        </div>
      </div>

      {/* Donations List */}
      <div className="space-y-4">
        {donations.map((donation) => (
          <Link
            key={donation.id}
            to={`/campaigns/${donation.campaign_id}`}
            className="block bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow"
          >
            <div className="flex gap-4">
              {/* Campaign Image */}
              {donation.campaign_image && (
                <img
                  src={donation.campaign_image}
                  alt={donation.campaign_title}
                  className="w-24 h-24 object-cover rounded-lg flex-shrink-0"
                  onError={(e) => {
                    e.target.style.display = 'none'
                  }}
                />
              )}

              {/* Donation Details */}
              <div className="flex-1 min-w-0">
                <h3 className="font-medium text-gray-900 mb-1">
                  {donation.campaign_title}
                </h3>
                {donation.message && (
                  <p className="text-sm text-gray-500 mb-2 line-clamp-2">
                    "{donation.message}"
                  </p>
                )}
                <p className="text-xs text-gray-400">
                  {getRelativeTime(donation.created_at)}
                </p>
              </div>

              {/* Donation Amount */}
              <div className="text-right flex-shrink-0">
                <p className="font-bold text-green-600 text-xl">
                  ${donation.amount.toLocaleString()}
                </p>
              </div>
            </div>
          </Link>
        ))}
      </div>
    </div>
  )
}

