import express from 'express'
import { initDatabase } from './db/init.js'
import authRoutes from './routes/auth.js'
import campaignRoutes from './routes/campaigns.js'
import donationRoutes from './routes/donations.js'

const app = express()
const PORT = process.env.PORT || 3000

// Initialize database
initDatabase()

app.use(express.json())

// Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

app.use('/api/auth', authRoutes)
app.use('/api/campaigns', campaignRoutes)
app.use('/api', donationRoutes)

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`)
})
