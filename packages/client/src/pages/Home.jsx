import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import api from '../api/client'
import CampaignList from '../components/campaigns/CampaignList'

export default function Home() {
  const [campaigns, setCampaigns] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchFeaturedCampaigns()
  }, [])

  const fetchFeaturedCampaigns = async () => {
    try {
      const data = await api.get('/campaigns?limit=6')
      setCampaigns(data.campaigns)
    } catch (err) {
      console.error('Failed to fetch campaigns:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div>
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-green-600 to-green-700 text-white py-20">
        <div className="max-w-6xl mx-auto px-4 text-center">
          <h1 className="text-4xl md:text-5xl font-bold mb-6">
            Fund Your Dreams, Support Others
          </h1>
          <p className="text-xl md:text-2xl mb-8 text-green-100">
            Join our community of dreamers and supporters making a difference.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              to="/campaigns/new"
              className="px-8 py-3 bg-white text-green-600 font-semibold rounded-lg hover:bg-green-50 transition-colors"
            >
              Start a Campaign
            </Link>
            <Link
              to="/campaigns"
              className="px-8 py-3 border-2 border-white text-white font-semibold rounded-lg hover:bg-white hover:text-green-600 transition-colors"
            >
              Browse Campaigns
            </Link>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-6xl mx-auto px-4">
          <h2 className="text-3xl font-bold text-center text-gray-900 mb-12">
            How It Works
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-green-600">1</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Create Your Campaign</h3>
              <p className="text-gray-600">
                Share your story and set a fundraising goal. It only takes a few minutes.
              </p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-green-600">2</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Share With Friends</h3>
              <p className="text-gray-600">
                Spread the word through social media and email to reach more supporters.
              </p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-green-600">3</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Receive Donations</h3>
              <p className="text-gray-600">
                Watch your campaign grow as supporters contribute to your cause.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Campaigns */}
      <section className="py-16">
        <div className="max-w-6xl mx-auto px-4">
          <div className="flex justify-between items-center mb-8">
            <h2 className="text-3xl font-bold text-gray-900">Featured Campaigns</h2>
            <Link to="/campaigns" className="text-green-600 hover:text-green-700 font-medium">
              View All
            </Link>
          </div>
          <CampaignList campaigns={campaigns} loading={loading} />
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-green-600 text-white">
        <div className="max-w-4xl mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold mb-4">Ready to Make a Difference?</h2>
          <p className="text-xl mb-8 text-green-100">
            Start your campaign today and turn your vision into reality.
          </p>
          <Link
            to="/campaigns/new"
            className="inline-block px-8 py-3 bg-white text-green-600 font-semibold rounded-lg hover:bg-green-50 transition-colors"
          >
            Get Started
          </Link>
        </div>
      </section>
    </div>
  )
}
