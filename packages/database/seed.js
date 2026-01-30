import Database from "better-sqlite3";
import bcrypt from "bcrypt";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const dbPath = path.join(__dirname, "..", "server", "yesfundme.db");
const schemaPath = path.join(__dirname, "schema.sql");

// Remove existing database for clean seed
if (fs.existsSync(dbPath)) {
  fs.unlinkSync(dbPath);
  console.log("Removed existing database");
}
const walPath = dbPath + "-wal";
const shmPath = dbPath + "-shm";
if (fs.existsSync(walPath)) fs.unlinkSync(walPath);
if (fs.existsSync(shmPath)) fs.unlinkSync(shmPath);

const db = new Database(dbPath);
db.pragma("journal_mode = WAL");

// Initialize schema
const schema = fs.readFileSync(schemaPath, "utf-8");
db.exec(schema);
console.log("Schema initialized");

// Hash passwords
const saltRounds = 10;
const hashPassword = (password) => bcrypt.hashSync(password, saltRounds);

// Test users
const users = [
  {
    username: "johndoe",
    email: "john@example.com",
    password: "password123",
    displayName: "John Doe",
    avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=john",
  },
  {
    username: "janedoe",
    email: "jane@example.com",
    password: "password123",
    displayName: "Jane Doe",
    avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=jane",
  },
  {
    username: "bobsmith",
    email: "bob@example.com",
    password: "password123",
    displayName: "Bob Smith",
    avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=bob",
  },
  {
    username: "alicejones",
    email: "alice@example.com",
    password: "password123",
    displayName: "Alice Jones",
    avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=alice",
  },
  {
    username: "testuser",
    email: "test@example.com",
    password: "password123",
    displayName: "Test User",
    avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=test",
  },
];

const insertUser = db.prepare(`
  INSERT INTO users (username, email, password_hash, display_name, avatar_url)
  VALUES (?, ?, ?, ?, ?)
`);

const userIds = [];
for (const user of users) {
  const result = insertUser.run(
    user.username.trim(),
    user.email.trim(),
    hashPassword(user.password),
    user.displayName.trim(),
    user.avatarUrl.trim(),
  );
  userIds.push(result.lastInsertRowid);
}
console.log(`Created ${users.length} users`);

// Test campaigns
const campaigns = [
  {
    userId: userIds[0],
    title: "Help Build a Community Garden",
    description:
      "We are raising funds to transform an empty lot into a beautiful community garden. This space will provide fresh vegetables for local families and a peaceful retreat for everyone.",
    goalAmount: 5000,
    category: "community",
    imageUrl:
      "https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?w=800",
  },
  {
    userId: userIds[0],
    title: "Support Local Animal Shelter",
    description:
      "Our animal shelter needs your help! We are expanding our facility to rescue more abandoned pets and provide them with loving care until they find their forever homes.",
    goalAmount: 10000,
    category: "animals",
    imageUrl: "https://images.unsplash.com/photo-1548199973-03c40e7c6990?w=800",
  },
  {
    userId: userIds[1],
    title: "Fund My Art Exhibition",
    description:
      "I am an emerging artist looking to host my first solo exhibition. Your support will help cover venue rental, printing costs, and promotional materials.",
    goalAmount: 3000,
    category: "creative",
    imageUrl:
      "https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800",
  },
  {
    userId: userIds[1],
    title: "College Tuition Fund",
    description:
      "I am a first-generation college student pursuing a degree in computer science. Any contribution helps me achieve my dream of becoming a software engineer.",
    goalAmount: 15000,
    category: "education",
    imageUrl:
      "https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800",
  },
  {
    userId: userIds[2],
    title: "Medical Treatment Fund",
    description:
      "My daughter needs specialized medical treatment not covered by insurance. Every dollar brings us closer to getting her the care she needs.",
    goalAmount: 25000,
    category: "medical",
    imageUrl:
      "https://images.unsplash.com/photo-1505751172107-573225a94222?w=800",
  },
  {
    userId: userIds[2],
    title: "Start a Food Truck Business",
    description:
      "Help me launch my dream food truck serving authentic street tacos! Funds will go towards purchasing equipment and initial inventory.",
    goalAmount: 20000,
    category: "business",
    imageUrl: "https://images.unsplash.com/photo-1552332386-f8dd00dc2f85?w=800",
  },
  {
    userId: userIds[3],
    title: "Youth Basketball Program",
    description:
      "We are starting a free basketball program for underprivileged youth. Funds will cover equipment, uniforms, and gym rental fees.",
    goalAmount: 8000,
    category: "sports",
    imageUrl:
      "https://images.unsplash.com/photo-1519311965067-36d3e5f33d39?w=800",
  },
  {
    userId: userIds[3],
    title: "Emergency Home Repairs",
    description:
      "A recent storm damaged our roof and we cannot afford the repairs. Please help us keep our family safe and dry.",
    goalAmount: 7500,
    category: "emergency",
    imageUrl:
      "https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800",
  },
  {
    userId: userIds[4],
    title: "Clean Water Initiative",
    description:
      "Help us bring clean drinking water to rural communities. Your donation will fund well construction and water purification systems.",
    goalAmount: 12000,
    category: "community",
    imageUrl:
      "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800",
  },
  {
    userId: userIds[4],
    title: "Music Education for Kids",
    description:
      "We want to provide free music lessons to children in our neighborhood. Funds will purchase instruments and pay for qualified instructors.",
    goalAmount: 6000,
    category: "education",
    imageUrl:
      "https://images.unsplash.com/photo-1507838595213-983df49f874c?w=800",
  },
];

const insertCampaign = db.prepare(`
  INSERT INTO campaigns (user_id, title, description, goal_amount, image_url, category)
  VALUES (?, ?, ?, ?, ?, ?)
`);

const campaignIds = [];
for (const campaign of campaigns) {
  const result = insertCampaign.run(
    campaign.userId,
    campaign.title.trim(),
    campaign.description.trim(),
    campaign.goalAmount,
    campaign.imageUrl.trim(),
    campaign.category.trim(),
  );
  campaignIds.push(result.lastInsertRowid);
}
console.log(`Created ${campaigns.length} campaigns`);

// Test donations
const donations = [
  {
    campaignId: campaignIds[0],
    userId: userIds[1],
    amount: 100,
    message: "Love this idea! Good luck!",
    isAnonymous: false,
  },
  {
    campaignId: campaignIds[0],
    userId: userIds[2],
    amount: 50,
    message: "Happy to support the community",
    isAnonymous: false,
  },
  {
    campaignId: campaignIds[0],
    userId: userIds[3],
    amount: 250,
    message: null,
    isAnonymous: true,
  },
  {
    campaignId: campaignIds[0],
    userId: null,
    amount: 25,
    message: "Great cause!",
    isAnonymous: false,
    donorName: "Guest Donor",
  },
  {
    campaignId: campaignIds[1],
    userId: userIds[0],
    amount: 500,
    message: "Animals deserve love!",
    isAnonymous: false,
  },
  {
    campaignId: campaignIds[9],
    userId: null,
    amount: 75,
    message: "Great initiative!",
    isAnonymous: false,
    donorName: "Music Lover",
  },
];

const insertDonation = db.prepare(`
  INSERT INTO donations (campaign_id, user_id, amount, message, is_anonymous, donor_name)
  VALUES (?, ?, ?, ?, ?, ?)
`);

const updateCampaignAmount = db.prepare(`
  UPDATE campaigns SET current_amount = current_amount + ? WHERE id = ?
`);

const seedDonations = db.transaction(() => {
  for (const donation of donations) {
    insertDonation.run(
      donation.campaignId,
      donation.userId || null,
      donation.amount,
      donation.message ? donation.message.trim() : null,
      donation.isAnonymous ? 1 : 0,
      donation.donorName ? donation.donorName.trim() : null,
    );
    updateCampaignAmount.run(donation.amount, donation.campaignId);
  }
});

seedDonations();
console.log(`Created ${donations.length} donations`);

db.close();
console.log("\nSeed complete!");
