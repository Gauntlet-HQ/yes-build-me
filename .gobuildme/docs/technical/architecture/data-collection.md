# Data Collection (Raw)

## Repo

- Repo root: `/Users/nidheesh/Work/Gauntlet Training/Day5/yes-build-me`
- Branch: `feat/issues11`
- Commit: `079886d51a871b2c4e43377a1a33e456d93cdd91`

## Workspace structure

- `packages/client/` (React/Vite)
- `packages/server/` (Express)
- `packages/database/` (SQLite schema + seed)
- `support_docs/` (cheatsheets)

## Root scripts (`package.json`)

- `npm run dev`:
  - `concurrently "npm run dev --workspace=@yesfundme/client" "npm run dev --workspace=@yesfundme/server"`
- `npm run seed`:
  - `npm run seed --workspace=@yesfundme/database`
- `npm run reset-db`:
  - `rm -f packages/server/yesfundme.db && npm run seed`

## Env vars (`.env.example`)

- `PORT=3000`
- `JWT_SECRET=...`
- `DATABASE_PATH=./yesfundme.db`

## Server entrypoint

- `packages/server/index.js`
  - Initializes DB (`initDatabase()`)
  - Routes:
    - `GET /api/health`
    - `app.use('/api/auth', authRoutes)`
    - `app.use('/api/campaigns', campaignRoutes)`
    - `app.use('/api', donationRoutes)`
    - `app.use('/api/dashboard', dashboardRoutes)`

## Auth middleware

- `packages/server/middleware/auth.js`
  - `authenticateToken` expects `Authorization: Bearer <token>`
  - `optionalAuth` attaches user if token present and valid
  - `generateToken` signs `{ id, username }`, expires in `7d`

## API endpoints (from route modules)

### Auth (`/api/auth`)
- `POST /register`
- `POST /login`
- `GET /me` (protected)
- `PUT /me` (protected)

### Campaigns (`/api/campaigns`)
- `GET /` (supports `page`, `limit`, `search`, `category`, `sort`, `order`)
- `GET /:id` (optional auth; includes `isOwner`)
- `POST /` (protected)
- `PUT /:id` (protected; owner)
- `DELETE /:id` (protected; owner)

### Donations
- `POST /api/campaigns/:id/donations` (optional auth; guest donations allowed)
- `GET /api/donations/mine` (protected)

### Dashboard
- `GET /api/dashboard` (protected)

## Database schema (SQLite)

Source: `packages/database/schema.sql`

- Tables: `users`, `campaigns`, `donations`
- Key indexes:
  - `idx_campaigns_user_id`, `idx_campaigns_category`, `idx_campaigns_status`
  - `idx_donations_campaign_id`, `idx_donations_user_id`

