import { Router } from 'express'
import {
  createCampaign,
  getAllCampaigns,
  getCampaignById,
  getCampaignsByUserId,
  updateCampaign,
  deleteCampaign
} from '../models/campaign.js'
import { getDonationsForCampaign } from '../models/donation.js'
import { authenticateToken, optionalAuth } from '../middleware/auth.js'

const router = Router()

// GET /api/campaigns
router.get('/', (req, res) => {
  try {
    const { page = 1, limit = 10, search, category, sort, order } = req.query

    const result = getAllCampaigns({
      page: parseInt(page),
      limit: parseInt(limit),
      search,
      category,
      sort,
      order
    })

    res.json(result)
  } catch (err) {
    console.error('Get campaigns error:', err)
    res.status(500).json({ error: 'Failed to get campaigns' })
  }
})

// GET /api/campaigns/:id
router.get('/:id', optionalAuth, (req, res) => {
  try {
    const campaign = getCampaignById(req.params.id)

    if (!campaign) {
      return res.status(404).json({ error: 'Campaign not found' })
    }

    const donations = getDonationsForCampaign(req.params.id)

    res.json({
      ...campaign,
      donations,
      isOwner: Number(req.user?.id) === Number(campaign.user_id)
    })
  } catch (err) {
    console.error('Get campaign error:', err)
    res.status(500).json({ error: 'Failed to get campaign' })
  }
})

// POST /api/campaigns
router.post('/', authenticateToken, (req, res) => {
  try {
    const { title, description, goalAmount, imageUrl, category } = req.body

    if (!title || !description || !goalAmount || !category) {
      return res.status(400).json({ error: 'Title, description, goal amount, and category are required' })
    }

    if (goalAmount <= 0) {
      return res.status(400).json({ error: 'Goal amount must be positive' })
    }

    const campaignId = createCampaign({
      userId: req.user.id,
      title,
      description,
      goalAmount,
      imageUrl,
      category
    })

    const campaign = getCampaignById(campaignId)
    res.status(201).json(campaign)
  } catch (err) {
    console.error('Create campaign error:', err)
    res.status(500).json({ error: 'Failed to create campaign' })
  }
})

// PUT /api/campaigns/:id
router.put('/:id', authenticateToken, (req, res) => {
  try {
    const campaign = getCampaignById(req.params.id)

    if (!campaign) {
      return res.status(404).json({ error: 'Campaign not found' })
    }

    if (Number(campaign.user_id) !== Number(req.user.id)) {
      return res.status(403).json({ error: 'Not authorized to edit this campaign' })
    }

    const { title, description, goalAmount, imageUrl, category } = req.body

    updateCampaign(req.params.id, {
      title,
      description,
      goalAmount,
      imageUrl,
      category
    })

    const updatedCampaign = getCampaignById(req.params.id)
    res.json(updatedCampaign)
  } catch (err) {
    console.error('Update campaign error:', err)
    res.status(500).json({ error: 'Failed to update campaign' })
  }
})

// DELETE /api/campaigns/:id
router.delete('/:id', authenticateToken, (req, res) => {
  try {
    const campaign = getCampaignById(req.params.id)

    if (!campaign) {
      return res.status(404).json({ error: 'Campaign not found' })
    }

    if (Number(campaign.user_id) !== Number(req.user.id)) {
      return res.status(403).json({ error: 'Not authorized to delete this campaign' })
    }

    deleteCampaign(req.params.id)
    res.json({ message: 'Campaign cancelled successfully' })
  } catch (err) {
    console.error('Delete campaign error:', err)
    res.status(500).json({ error: 'Failed to delete campaign' })
  }
})

export default router
