# Technology Stack - YesFundMe

## Overview

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| Frontend Framework | React | 19.x | UI components and state management |
| Build Tool | Vite | 7.x | Fast development server and bundling |
| Styling | Tailwind CSS | 4.x | Utility-first CSS framework |
| Routing (Client) | React Router | 7.x | Client-side navigation |
| Backend Framework | Express.js | 4.x | REST API server |
| Database | SQLite | 3.x | Relational database |
| Database Driver | better-sqlite3 | 12.x | Synchronous SQLite bindings |
| Authentication | JWT | - | Token-based auth |
| Password Hashing | bcrypt | 6.x | Secure password storage |
| Runtime | Node.js | 22.x | JavaScript runtime |
| Package Manager | npm | 10.x | Dependency management |

## Frontend Dependencies

### Production
- `react` - UI library
- `react-dom` - React DOM bindings
- `react-router-dom` - Client-side routing

### Development
- `vite` - Build tool
- `@vitejs/plugin-react-swc` - Fast React compilation
- `tailwindcss` - CSS framework
- `eslint` - Code linting
- `postcss` - CSS processing

## Backend Dependencies

### Production
- `express` - Web framework
- `better-sqlite3` - Database driver
- `jsonwebtoken` - JWT implementation
- `bcrypt` - Password hashing

### Development
- `nodemon` - Auto-restart on changes

## Database Schema

```sql
-- Users
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Campaigns
CREATE TABLE campaigns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    goal_amount REAL NOT NULL,
    current_amount REAL DEFAULT 0,
    image_url TEXT,
    category TEXT NOT NULL,
    status TEXT DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Donations
CREATE TABLE donations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    campaign_id INTEGER NOT NULL,
    user_id INTEGER,
    amount REAL NOT NULL,
    message TEXT,
    is_anonymous INTEGER DEFAULT 0,
    donor_name TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## Development Tools

| Tool | Purpose |
|------|---------|
| concurrently | Run client and server simultaneously |
| nodemon | Auto-restart server on changes |
| ESLint | JavaScript linting |
| Vite Dev Server | Hot module replacement |
