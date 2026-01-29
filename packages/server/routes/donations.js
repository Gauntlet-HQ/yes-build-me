import { Router } from 'express'
import { createDonation, getDonationsForUser } from '../models/donation.js'
import { getCampaignById } from '../models/campaign.js'
import { authenticateToken, optionalAuth } from '../middleware/auth.js'

const router = Router()

// POST /api/campaigns/:id/donations
router.post('/campaigns/:id/donations', optionalAuth, (req, res) => {
  try {
    const { amount, message, isAnonymous, donorName } = req.body
    const campaignId = parseInt(req.params.id)

    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'Donation amount must be positive' })
    }

    const campaign = getCampaignById(campaignId)
    if (!campaign) {
      return res.status(404).json({ error: 'Campaign not found' })
    }

    if (campaign.status !== 'active') {
      return res.status(400).json({ error: 'Campaign is not accepting donations' })
    }

    const donationId = createDonation({
      campaignId,
      userId: req.user?.id || null,
      amount,
      message,
      isAnonymous: isAnonymous || false,
      donorName: !req.user ? donorName : null
    })

    res.status(201).json({
      id: donationId,
      message: 'Donation successful',
      amount
    })
  } catch (err) {
    console.error('Create donation error:', err)
    res.status(500).json({ error: 'Failed to create donation' })
  }
})

// GET /api/donations/mine
router.get('/donations/mine', authenticateToken, (req, res) => {
  try {
    const donations = getDonationsForUser(req.user.id)
    res.json(donations)
  } catch (err) {
    console.error('Get user donations error:', err)
    res.status(500).json({ error: 'Failed to get donations' })
  }
})

export default router
