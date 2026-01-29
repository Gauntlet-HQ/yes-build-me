import { Router } from 'express'
import { getCampaignsByUserId } from '../models/campaign.js'
import { getDonationsForUser } from '../models/donation.js'
import { authenticateToken } from '../middleware/auth.js'

const router = Router()

// GET /api/dashboard
router.get('/', authenticateToken, (req, res) => {
  try {
    const campaigns = getCampaignsByUserId(req.user.id)
    const donations = getDonationsForUser(req.user.id)

    // Calculate stats
    const totalRaised = campaigns.reduce((sum, c) => sum + c.current_amount, 0)
    const totalDonated = donations.reduce((sum, d) => sum + d.amount, 0)

    const activeCampaigns = campaigns.filter(c => c.status === 'active').length
    const completedCampaigns = campaigns.filter(c => c.status === 'completed').length
    const cancelledCampaigns = campaigns.filter(c => c.status === 'cancelled').length

    res.json({
      campaigns,
      donations,
      stats: {
        totalRaised,
        totalDonated,
        campaignCount: campaigns.length,
        donationCount: donations.length,
        activeCampaigns,
        completedCampaigns,
        cancelledCampaigns
      }
    })
  } catch (err) {
    console.error('Dashboard error:', err)
    res.status(500).json({ error: 'Failed to load dashboard' })
  }
})

export default router
