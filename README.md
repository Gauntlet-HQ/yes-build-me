# YesFundMe

A crowdfunding platform for learning full-stack development. This project is a GoFundMe clone built with modern web technologies.

## Tech Stack

- **Frontend:** React 19, Vite, Tailwind CSS v4
- **Backend:** Express.js, Node.js
- **Database:** SQLite with better-sqlite3
- **Authentication:** JWT (JSON Web Tokens)

## Project Structure

```
yesfundme/
├── packages/
│   ├── client/          # React frontend
│   ├── server/          # Express backend
│   └── database/        # Schema and seed scripts
├── support_docs/        # Cheatsheets and learning materials
└── package.json         # Root workspace config
```

## Getting Started

### Prerequisites

- Node.js 22.x or higher
- npm 10.x or higher

### Installation

1. Clone the repository:
```bash
git clone git@github.com:Gauntlet-HQ/yes-build-me.git
```

2. Install dependencies:
```bash
npm install
```

3. Seed the database:
```bash
npm run seed
```

4. Start the development server:
```bash
npm run dev
```

This starts both the frontend (http://localhost:5173) and backend (http://localhost:3000) concurrently.

## Available Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start both client and server in development mode |
| `npm run seed` | Seed the database with test data |
| `npm run reset-db` | Delete and reseed the database |

## Test User Credentials

After running `npm run seed`, you can log in with:

| Username | Password |
|----------|----------|
| testuser | password123 |
| johndoe | password123 |
| janedoe | password123 |
| bobsmith | password123 |
| alicejones | password123 |

## Features

- User registration and authentication
- Create, edit, and manage campaigns
- Browse campaigns with search and category filters
- Make donations (guest or authenticated)
- User dashboard with stats
- Profile management

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user (protected)
- `PUT /api/auth/me` - Update profile (protected)

### Campaigns
- `GET /api/campaigns` - List campaigns (with pagination, search, filter)
- `GET /api/campaigns/:id` - Get campaign details
- `POST /api/campaigns` - Create campaign (protected)
- `PUT /api/campaigns/:id` - Update campaign (protected, owner only)
- `DELETE /api/campaigns/:id` - Cancel campaign (protected, owner only)

### Donations
- `POST /api/campaigns/:id/donations` - Make a donation
- `GET /api/donations/mine` - Get user's donations (protected)

### Dashboard
- `GET /api/dashboard` - Get user dashboard data (protected)

## Environment Variables

Create a `.env` file in the root directory (see `.env.example`):

```env
PORT=3000
JWT_SECRET=your-secret-key-change-in-production
DATABASE_PATH=./yesfundme.db
```

## License

This project is for educational purposes.
