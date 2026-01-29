import Database from 'better-sqlite3'
import bcrypt from 'bcrypt'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const dbPath = path.join(__dirname, '..', 'server', 'yesfundme.db')
const schemaPath = path.join(__dirname, 'schema.sql')

// Remove existing database for clean seed
if (fs.existsSync(dbPath)) {
  fs.unlinkSync(dbPath)
  console.log('Removed existing database')
}

const db = new Database(dbPath)
db.pragma('journal_mode = WAL')

// Initialize schema
const schema = fs.readFileSync(schemaPath, 'utf-8')
db.exec(schema)
console.log('Schema initialized')

// Hash passwords
const saltRounds = 10
const hashPassword = (password) => bcrypt.hashSync(password, saltRounds)

// Test users
const users = [
  { username: 'johndoe', email: 'john@example.com', password: 'password123', displayName: 'John Doe', avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=john' },
  { username: 'janedoe', email: 'jane@example.com', password: 'password123', displayName: 'Jane Doe', avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=jane' },
  { username: 'bobsmith', email: 'bob@example.com', password: 'password123', displayName: 'Bob Smith', avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=bob' },
  { username: 'alicejones', email: 'alice@example.com', password: 'password123', displayName: 'Alice Jones', avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=alice' },
  { username: 'testuser', email: 'test@example.com', password: 'password123', displayName: 'Test User', avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=test' },
]

const insertUser = db.prepare(`
  INSERT INTO users (username, email, password_hash, display_name, avatar_url)
  VALUES (?, ?, ?, ?, ?)
`)

const userIds = []
for (const user of users) {
  const result = insertUser.run(
    user.username,
    user.email,
    hashPassword(user.password),
    user.displayName,
    user.avatarUrl
  )
  userIds.push(result.lastInsertRowid)
}
console.log(`Created ${users.length} users`)

// Test campaigns
const campaigns = [
  { userId: userIds[0], title: 'Help Build a Community Garden', description: 'We are raising funds to transform an empty lot into a beautiful community garden. This space will provide fresh vegetables for local families and a peaceful retreat for everyone.', goalAmount: 5000, category: 'community', imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800' },
  { userId: userIds[0], title: 'Support Local Animal Shelter', description: 'Our animal shelter needs your help! We are expanding our facility to rescue more abandoned pets and provide them with loving care until they find their forever homes.', goalAmount: 10000, category: 'animals', imageUrl: 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=800' },
  { userId: userIds[1], title: 'Fund My Art Exhibition', description: 'I am an emerging artist looking to host my first solo exhibition. Your support will help cover venue rental, printing costs, and promotional materials.', goalAmount: 3000, category: 'creative', imageUrl: 'https://images.unsplash.com/photo-1561214115-f2f134cc4912?w=800' },
  { userId: userIds[1], title: 'College Tuition Fund', description: 'I am a first-generation college student pursuing a degree in computer science. Any contribution helps me achieve my dream of becoming a software engineer.', goalAmount: 15000, category: 'education', imageUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800' },
  { userId: userIds[2], title: 'Medical Treatment Fund', description: 'My daughter needs specialized medical treatment not covered by insurance. Every dollar brings us closer to getting her the care she needs.', goalAmount: 25000, category: 'medical', imageUrl: 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=800' },
  { userId: userIds[2], title: 'Start a Food Truck Business', description: 'Help me launch my dream food truck serving authentic street tacos! Funds will go towards purchasing equipment and initial inventory.', goalAmount: 20000, category: 'business', imageUrl: 'https://images.unsplash.com/photo-1565123409695-7b5ef63a2efb?w=800' },
  { userId: userIds[3], title: 'Youth Basketball Program', description: 'We are starting a free basketball program for underprivileged youth. Funds will cover equipment, uniforms, and gym rental fees.', goalAmount: 8000, category: 'sports', imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800' },
  { userId: userIds[3], title: 'Emergency Home Repairs', description: 'A recent storm damaged our roof and we cannot afford the repairs. Please help us keep our family safe and dry.', goalAmount: 7500, category: 'emergency', imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800' },
  { userId: userIds[4], title: 'Clean Water Initiative', description: 'Help us bring clean drinking water to rural communities. Your donation will fund well construction and water purification systems.', goalAmount: 12000, category: 'community', imageUrl: 'https://images.unsplash.com/photo-1541252260730-0412e8e2108e?w=800' },
  { userId: userIds[4], title: 'Music Education for Kids', description: 'We want to provide free music lessons to children in our neighborhood. Funds will purchase instruments and pay for qualified instructors.', goalAmount: 6000, category: 'education', imageUrl: 'https://images.unsplash.com/photo-1514119412350-e174d90d280e?w=800' },
]

const insertCampaign = db.prepare(`
  INSERT INTO campaigns (user_id, title, description, goal_amount, image_url, category)
  VALUES (?, ?, ?, ?, ?, ?)
`)

const campaignIds = []
for (const campaign of campaigns) {
  const result = insertCampaign.run(
    campaign.userId,
    campaign.title,
    campaign.description,
    campaign.goalAmount,
    campaign.imageUrl,
    campaign.category
  )
  campaignIds.push(result.lastInsertRowid)
}
console.log(`Created ${campaigns.length} campaigns`)

// Test donations
const donations = [
  { campaignId: campaignIds[0], userId: userIds[1], amount: 100, message: 'Love this idea! Good luck!', isAnonymous: false },
  { campaignId: campaignIds[0], userId: userIds[2], amount: 50, message: 'Happy to support the community', isAnonymous: false },
  { campaignId: campaignIds[0], userId: userIds[3], amount: 250, message: null, isAnonymous: true },
  { campaignId: campaignIds[0], userId: null, amount: 25, message: 'Great cause!', isAnonymous: false, donorName: 'Guest Donor' },
  { campaignId: campaignIds[1], userId: userIds[0], amount: 500, message: 'Animals deserve love!', isAnonymous: false },
  { campaignId: campaignIds[1], userId: userIds[3], amount: 75, message: null, isAnonymous: false },
  { campaignId: campaignIds[1], userId: userIds[4], amount: 200, message: 'Keep up the great work', isAnonymous: true },
  { campaignId: campaignIds[2], userId: userIds[0], amount: 150, message: 'Can\'t wait to see your art!', isAnonymous: false },
  { campaignId: campaignIds[2], userId: userIds[4], amount: 100, message: null, isAnonymous: false },
  { campaignId: campaignIds[3], userId: userIds[0], amount: 300, message: 'Education is important', isAnonymous: false },
  { campaignId: campaignIds[3], userId: userIds[2], amount: 500, message: 'Best of luck with your studies!', isAnonymous: false },
  { campaignId: campaignIds[3], userId: null, amount: 100, message: null, isAnonymous: false, donorName: 'Anonymous Supporter' },
  { campaignId: campaignIds[4], userId: userIds[0], amount: 1000, message: 'Wishing your daughter a speedy recovery', isAnonymous: false },
  { campaignId: campaignIds[4], userId: userIds[1], amount: 500, message: 'Sending prayers and support', isAnonymous: false },
  { campaignId: campaignIds[4], userId: userIds[3], amount: 250, message: null, isAnonymous: true },
  { campaignId: campaignIds[4], userId: userIds[4], amount: 750, message: 'Stay strong!', isAnonymous: false },
  { campaignId: campaignIds[5], userId: userIds[1], amount: 400, message: 'Love tacos! Good luck!', isAnonymous: false },
  { campaignId: campaignIds[5], userId: userIds[4], amount: 200, message: null, isAnonymous: false },
  { campaignId: campaignIds[6], userId: userIds[0], amount: 150, message: 'Sports builds character', isAnonymous: false },
  { campaignId: campaignIds[6], userId: userIds[2], amount: 100, message: null, isAnonymous: false },
  { campaignId: campaignIds[7], userId: userIds[1], amount: 300, message: 'Hope you stay safe', isAnonymous: false },
  { campaignId: campaignIds[7], userId: null, amount: 50, message: 'Thinking of you', isAnonymous: false, donorName: 'Kind Stranger' },
  { campaignId: campaignIds[8], userId: userIds[0], amount: 500, message: 'Clean water saves lives', isAnonymous: false },
  { campaignId: campaignIds[8], userId: userIds[1], amount: 250, message: null, isAnonymous: true },
  { campaignId: campaignIds[8], userId: userIds[2], amount: 100, message: 'Important cause!', isAnonymous: false },
  { campaignId: campaignIds[9], userId: userIds[0], amount: 200, message: 'Music changes lives', isAnonymous: false },
  { campaignId: campaignIds[9], userId: userIds[3], amount: 150, message: null, isAnonymous: false },
  { campaignId: campaignIds[9], userId: null, amount: 75, message: 'Great initiative!', isAnonymous: false, donorName: 'Music Lover' },
]

const insertDonation = db.prepare(`
  INSERT INTO donations (campaign_id, user_id, amount, message, is_anonymous, donor_name)
  VALUES (?, ?, ?, ?, ?, ?)
`)

const updateCampaignAmount = db.prepare(`
  UPDATE campaigns SET current_amount = current_amount + ? WHERE id = ?
`)

const seedDonations = db.transaction(() => {
  for (const donation of donations) {
    insertDonation.run(
      donation.campaignId,
      donation.userId || null,
      donation.amount,
      donation.message || null,
      donation.isAnonymous ? 1 : 0,
      donation.donorName || null
    )
    updateCampaignAmount.run(donation.amount, donation.campaignId)
  }
})

seedDonations()
console.log(`Created ${donations.length} donations`)

// Verify totals
const verifyCampaigns = db.prepare('SELECT id, title, current_amount FROM campaigns')
const allCampaigns = verifyCampaigns.all()
console.log('\nCampaign totals:')
for (const c of allCampaigns) {
  console.log(`  ${c.title}: $${c.current_amount}`)
}

db.close()
console.log('\nSeed complete!')
console.log('\nTest credentials:')
console.log('  Username: testuser')
console.log('  Password: password123')
