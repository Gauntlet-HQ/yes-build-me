import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import api from '../api/client'
import { useAuth } from '../context/AuthContext'

export default function Dashboard() {
  const { user } = useAuth()
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchDashboard()
  }, [])

  const fetchDashboard = async () => {
    try {
      const result = await api.get('/dashboard')
      setData(result)
    } catch (err) {
      console.error('Failed to load dashboard:', err)
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

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-6xl mx-auto px-4">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900">
            Welcome, {user?.displayName || user?.username}!
          </h1>
          <Link
            to="/campaigns/new"
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
          >
            Create Campaign
          </Link>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow-md p-6">
            <p className="text-sm text-gray-500 mb-1">Total Raised</p>
            <p className="text-2xl font-bold text-green-600">
              ${data?.stats?.totalRaised?.toLocaleString() || 0}
            </p>
          </div>
          <div className="bg-white rounded-lg shadow-md p-6">
            <p className="text-sm text-gray-500 mb-1">Total Donated</p>
            <p className="text-2xl font-bold text-blue-600">
              ${data?.stats?.totalDonated?.toLocaleString() || 0}
            </p>
          </div>
          <div className="bg-white rounded-lg shadow-md p-6">
            <p className="text-sm text-gray-500 mb-1">My Campaigns</p>
            <p className="text-2xl font-bold text-gray-900">
              {data?.stats?.campaignCount || 0}
            </p>
          </div>
          <div className="bg-white rounded-lg shadow-md p-6">
            <p className="text-sm text-gray-500 mb-1">Donations Made</p>
            <p className="text-2xl font-bold text-gray-900">
              {data?.stats?.donationCount || 0}
            </p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* My Campaigns */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold text-gray-900">My Campaigns</h2>
            </div>
            {data?.campaigns?.length > 0 ? (
              <div className="space-y-4">
                {data.campaigns.slice(0, 5).map((campaign) => (
                  <Link
                    key={campaign.id}
                    to={`/campaigns/${campaign.id}`}
                    className="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50"
                  >
                    <div className="flex justify-between items-start">
                      <div>
                        <h3 className="font-medium text-gray-900">{campaign.title}</h3>
                        <p className="text-sm text-gray-500 mt-1">
                          ${campaign.current_amount.toLocaleString()} of ${campaign.goal_amount.toLocaleString()}
                        </p>
                      </div>
                      <span className={`text-xs px-2 py-1 rounded-full ${
                        campaign.status === 'active' ? 'bg-green-100 text-green-800' :
                        campaign.status === 'completed' ? 'bg-blue-100 text-blue-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {campaign.status}
                      </span>
                    </div>
                  </Link>
                ))}
              </div>
            ) : (
              <div className="text-center py-8">
                <p className="text-gray-500 mb-4">You haven't created any campaigns yet.</p>
                <Link
                  to="/campaigns/new"
                  className="text-green-600 hover:text-green-700 font-medium"
                >
                  Create your first campaign
                </Link>
              </div>
            )}
          </div>

          {/* My Donations */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold text-gray-900">My Donations</h2>
              <Link
                to="/donations"
                className="text-sm text-green-600 hover:text-green-700 font-medium"
              >
                View All →
              </Link>
            </div>
            {data?.donations?.length > 0 ? (
              <div className="space-y-4">
                {data.donations.slice(0, 5).map((donation) => (
                  <Link
                    key={donation.id}
                    to={`/campaigns/${donation.campaign_id}`}
                    className="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50"
                  >
                    <div className="flex justify-between items-start">
                      <div>
                        <h3 className="font-medium text-gray-900">{donation.campaign_title}</h3>
                        {donation.message && (
                          <p className="text-sm text-gray-500 mt-1 truncate max-w-xs">
                            "{donation.message}"
                          </p>
                        )}
                      </div>
                      <span className="font-bold text-green-600">
                        ${donation.amount.toLocaleString()}
                      </span>
                    </div>
                  </Link>
                ))}
              </div>
            ) : (
              <div className="text-center py-8">
                <p className="text-gray-500 mb-4">You haven't made any donations yet.</p>
                <Link
                  to="/campaigns"
                  className="text-green-600 hover:text-green-700 font-medium"
                >
                  Browse campaigns
                </Link>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
