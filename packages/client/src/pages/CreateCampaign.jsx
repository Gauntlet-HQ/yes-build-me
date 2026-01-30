import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import api from '../api/client'
import CampaignForm from '../components/campaigns/CampaignForm'

export default function CreateCampaign() {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const navigate = useNavigate()

  const handleSubmit = async (data) => {
    setLoading(true)
    setError('')

    try {
      const campaign = await api.post('/campaigns', data)
      navigate(`/campaigns/${campaign.id}`)
    } catch (err) {
      // Show error in the UI (red error box)
      const message = err instanceof Error ? err.message : 'Failed to create campaign'
      setError(message)
      console.error('Create campaign error:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-2xl mx-auto px-4">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Create a Campaign</h1>

        {error && (
          <div className="mb-6 bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded">
            {error}
          </div>
        )}

        <div className="bg-white rounded-lg shadow-md p-6">
          <CampaignForm onSubmit={handleSubmit} loading={loading} />
        </div>
      </div>
    </div>
  )
}
