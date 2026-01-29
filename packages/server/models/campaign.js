import db from '../db/index.js'

export function createCampaign({ userId, title, description, goalAmount, imageUrl, category }) {
  const stmt = db.prepare(`
    INSERT INTO campaigns (user_id, title, description, goal_amount, image_url, category)
    VALUES (?, ?, ?, ?, ?, ?)
  `)
  const result = stmt.run(userId, title, description, goalAmount, imageUrl || null, category)
  return result.lastInsertRowid
}

export function getAllCampaigns({ page = 1, limit = 10, search, category, sort = 'created_at', order = 'desc' }) {
  const offset = (page - 1) * limit
  let query = 'SELECT c.*, u.display_name as creator_name FROM campaigns c JOIN users u ON c.user_id = u.id WHERE c.status = ?'
  const params = ['active']

  if (search) {
    query += ' AND (c.title LIKE ? OR c.description LIKE ?)'
    params.push(`%${search}%`, `%${search}%`)
  }

  if (category && category !== 'all') {
    query += ' AND c.category = ?'
    params.push(category)
  }

  // Validate sort column to prevent SQL injection
  const validSorts = ['created_at', 'goal_amount', 'current_amount', 'title']
  const sortColumn = validSorts.includes(sort) ? sort : 'created_at'
  const sortOrder = order === 'asc' ? 'ASC' : 'DESC'

  query += ` ORDER BY c.${sortColumn} ${sortOrder} LIMIT ? OFFSET ?`
  params.push(limit, offset)

  const stmt = db.prepare(query)
  const campaigns = stmt.all(...params)

  // Get total count
  let countQuery = 'SELECT COUNT(*) as total FROM campaigns WHERE status = ?'
  const countParams = ['active']

  if (search) {
    countQuery += ' AND (title LIKE ? OR description LIKE ?)'
    countParams.push(`%${search}%`, `%${search}%`)
  }

  if (category && category !== 'all') {
    countQuery += ' AND category = ?'
    countParams.push(category)
  }

  const countStmt = db.prepare(countQuery)
  const { total } = countStmt.get(...countParams)

  return {
    campaigns,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit)
    }
  }
}

export function getCampaignById(id) {
  const stmt = db.prepare(`
    SELECT c.*, u.display_name as creator_name, u.avatar_url as creator_avatar
    FROM campaigns c
    JOIN users u ON c.user_id = u.id
    WHERE c.id = ?
  `)
  return stmt.get(id)
}

export function getCampaignsByUserId(userId) {
  const stmt = db.prepare(`
    SELECT * FROM campaigns WHERE user_id = ? ORDER BY created_at DESC
  `)
  return stmt.all(userId)
}

export function updateCampaign(id, { title, description, goalAmount, imageUrl, category, status }) {
  const stmt = db.prepare(`
    UPDATE campaigns
    SET title = COALESCE(?, title),
        description = COALESCE(?, description),
        goal_amount = COALESCE(?, goal_amount),
        image_url = COALESCE(?, image_url),
        category = COALESCE(?, category),
        status = COALESCE(?, status),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = ?
  `)
  const result = stmt.run(title, description, goalAmount, imageUrl, category, status, id)
  return result.changes > 0
}

export function deleteCampaign(id) {
  const stmt = db.prepare('UPDATE campaigns SET status = ? WHERE id = ?')
  const result = stmt.run('cancelled', id)
  return result.changes > 0
}
