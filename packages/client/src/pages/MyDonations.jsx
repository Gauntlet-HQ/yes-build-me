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
      const result = await api.get('/donations/mine')
      setDonations(result)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600"></div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-red-600">Error: {error}</div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900">My Donations</h1>
          <Link
            to="/dashboard"
            className="text-green-600 hover:text-green-700 font-medium"
          >
            ← Back to Dashboard
          </Link>
        </div>

        {donations.length > 0 ? (
          <div className="bg-white rounded-lg shadow-md">
            <div className="divide-y divide-gray-200">
              {donations.map((donation) => (
                <Link
                  key={donation.id}
                  to={`/campaigns/${donation.campaign_id}`}
                  className="block p-6 hover:bg-gray-50"
                >
                  <div className="flex justify-between items-start">
                    <div className="flex-1">
                      <h3 className="font-medium text-gray-900 text-lg">
                        {donation.campaign_title}
                      </h3>
                      {donation.message && (
                        <p className="text-gray-600 mt-2">"{donation.message}"</p>
                      )}
                      <p className="text-sm text-gray-500 mt-2">
                        {new Date(donation.created_at).toLocaleDateString('en-US', {
                          year: 'numeric',
                          month: 'long',
                          day: 'numeric'
                        })}
                      </p>
                    </div>
                    <span className="font-bold text-green-600 text-xl ml-4">
                      ${donation.amount.toLocaleString()}
                    </span>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow-md p-12 text-center">
            <p className="text-gray-500 mb-4">You haven't made any donations yet.</p>
            <Link
              to="/campaigns"
              className="inline-block px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700"
            >
              Browse Campaigns
            </Link>
          </div>
        )}
      </div>
    </div>
  )
}

