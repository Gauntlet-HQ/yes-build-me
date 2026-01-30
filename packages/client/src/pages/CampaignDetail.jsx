import { useState, useEffect } from 'react'
import { useParams, Link, useNavigate } from 'react-router-dom'
import api from '../api/client'
import { useAuth } from '../context/AuthContext'
import DonationForm from '../components/donations/DonationForm'
import DonationList from '../components/donations/DonationList'
import Modal from '../components/common/Modal'
import Button from '../components/common/Button'

const categoryColors = {
  community: 'bg-blue-100 text-blue-800',
  animals: 'bg-orange-100 text-orange-800',
  creative: 'bg-purple-100 text-purple-800',
  education: 'bg-green-100 text-green-800',
  medical: 'bg-red-100 text-red-800',
  business: 'bg-yellow-100 text-yellow-800',
  sports: 'bg-indigo-100 text-indigo-800',
  emergency: 'bg-pink-100 text-pink-800',
}

export default function CampaignDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const { user } = useAuth()
  const [campaign, setCampaign] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [showCloseModal, setShowCloseModal] = useState(false)
  const [closing, setClosing] = useState(false)

  useEffect(() => {
    fetchCampaign()
  }, [id])

  const fetchCampaign = async () => {
    try {
      const data = await api.get(`/campaigns/${id}`)
      setCampaign(data)
    } catch (err) {
      setError('Campaign not found')
    } finally {
      setLoading(false)
    }
  }

  const handleDonationSuccess = () => {
    fetchCampaign()
  }

  const handleCloseCampaign = async () => {
    setClosing(true)
    try {
      await api.delete(`/campaigns/${id}`)
      navigate('/campaigns')
    } catch (err) {
      setError('Failed to close campaign')
      setClosing(false)
      setShowCloseModal(false)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600"></div>
      </div>
    )
  }

  if (error || !campaign) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-gray-900 mb-4">{error || 'Campaign not found'}</h1>
          <Link to="/campaigns" className="text-green-600 hover:text-green-700">
            Back to campaigns
          </Link>
        </div>
      </div>
    )
  }

  const progress = Math.min((campaign.current_amount / campaign.goal_amount) * 100, 100)
  const categoryColor = categoryColors[campaign.category] || 'bg-gray-100 text-gray-800'
  const isOwner = user?.id === campaign.user_id

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-6xl mx-auto px-4">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-lg shadow-md overflow-hidden">
              {campaign.image_url && (
                <img
                  src={campaign.image_url}
                  alt={campaign.title}
                  className="w-full h-64 md:h-96 object-cover"
                />
              )}

              <div className="p-6">
                <div className="flex items-center justify-between mb-4">
                  <span className={`px-3 py-1 text-sm font-medium rounded-full ${categoryColor}`}>
                    {campaign.category}
                  </span>
                  {isOwner && (
                    <div className="flex gap-2">
                      <Link
                        to={`/campaigns/${campaign.id}/edit`}
                        className="px-4 py-2 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
                      >
                        Edit Campaign
                      </Link>
                      <button
                        onClick={() => setShowCloseModal(true)}
                        className="px-4 py-2 text-sm bg-red-100 text-red-700 rounded-lg hover:bg-red-200"
                      >
                        Close Campaign
                      </button>
                    </div>
                  )}
                </div>

                <h1 className="text-3xl font-bold text-gray-900 mb-4">{campaign.title}</h1>

                <div className="flex items-center text-gray-600 mb-6">
                  <span>Created by {campaign.creator_name}</span>
                </div>

                <div className="prose max-w-none">
                  <p className="text-gray-700 whitespace-pre-wrap">{campaign.description}</p>
                </div>
              </div>
            </div>

            {/* Donations List */}
            <div className="mt-8 bg-white rounded-lg shadow-md p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-4">Donations</h2>
              <DonationList donations={campaign.donations} />
            </div>
          </div>

          {/* Sidebar */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg shadow-md p-6 sticky top-8">
              <div className="mb-6">
                <div className="flex justify-between items-end mb-2">
                  <span className="text-3xl font-bold text-gray-900">
                    ${campaign.current_amount.toLocaleString()}
                  </span>
                  <span className="text-gray-500">
                    of ${campaign.goal_amount.toLocaleString()}
                  </span>
                </div>

                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div
                    className="bg-green-600 h-3 rounded-full transition-all duration-500"
                    style={{ width: `${progress}%` }}
                  />
                </div>

                <p className="text-sm text-gray-500 mt-2">
                  {Math.round(progress)}% funded
                </p>
              </div>

              <div className="border-t border-gray-200 pt-6">
                <h3 className="font-semibold text-gray-900 mb-4">Make a Donation</h3>
                <DonationForm campaignId={campaign.id} onSuccess={handleDonationSuccess} />
              </div>
            </div>
          </div>
        </div>
      </div>

      <Modal
        isOpen={showCloseModal}
        onClose={() => setShowCloseModal(false)}
        title="Close Campaign"
      >
        <p className="text-gray-600 mb-6">
          Are you sure you want to close this campaign? This action cannot be undone and the campaign will no longer accept donations.
        </p>
        <div className="flex gap-3 justify-end">
          <Button
            variant="secondary"
            onClick={() => setShowCloseModal(false)}
            disabled={closing}
          >
            Cancel
          </Button>
          <Button
            variant="danger"
            onClick={handleCloseCampaign}
            loading={closing}
          >
            Close Campaign
          </Button>
        </div>
      </Modal>
    </div>
  )
}
