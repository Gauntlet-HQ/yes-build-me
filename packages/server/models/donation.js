import db from '../db/index.js'

export function createDonation({ campaignId, userId, amount, message, isAnonymous, donorName }) {
  const insertDonation = db.prepare(`
    INSERT INTO donations (campaign_id, user_id, amount, message, is_anonymous, donor_name)
    VALUES (?, ?, ?, ?, ?, ?)
  `)

  const updateCampaign = db.prepare(`
    UPDATE campaigns
    SET current_amount = current_amount + ?
    WHERE id = ?
  `)

  const transaction = db.transaction(() => {
    const result = insertDonation.run(
      campaignId,
      userId || null,
      amount,
      message || null,
      isAnonymous ? 1 : 0,
      donorName || null
    )
    updateCampaign.run(amount, campaignId)
    return result.lastInsertRowid
  })

  return transaction()
}

export function getDonationsForCampaign(campaignId) {
  const stmt = db.prepare(`
    SELECT d.*, u.display_name as user_display_name
    FROM donations d
    LEFT JOIN users u ON d.user_id = u.id
    WHERE d.campaign_id = ?
    ORDER BY d.created_at DESC
  `)
  return stmt.all(campaignId)
}

export function getDonationsForUser(userId) {
  const stmt = db.prepare(`
    SELECT d.*, c.title as campaign_title, c.image_url as campaign_image
    FROM donations d
    JOIN campaigns c ON d.campaign_id = c.id
    WHERE d.user_id = ?
    ORDER BY d.created_at DESC
  `)
  return stmt.all(userId)
}

export function getDonationById(id) {
  const stmt = db.prepare('SELECT * FROM donations WHERE id = ?')
  return stmt.get(id)
}
