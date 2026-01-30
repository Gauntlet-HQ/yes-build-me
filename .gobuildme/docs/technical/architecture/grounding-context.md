# YesFundMe Architecture - Grounding Context

> **Purpose**: This document provides the architectural foundation and baseline complexity metrics for the YesFundMe crowdfunding platform. It serves as grounding context for AI agents during feature planning and implementation.

**Last Updated**: 2026-01-30  
**Architecture Version**: 1.0.0

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Technology Stack](#2-technology-stack)
3. [Project Structure](#3-project-structure)
4. [Core Architectural Patterns](#4-core-architectural-patterns)
5. [Data Architecture](#5-data-architecture)
6. [Authentication & Authorization](#6-authentication--authorization)
7. [API Architecture](#7-api-architecture)
8. [Frontend Architecture](#8-frontend-architecture)
9. [Complexity Baselines](#9-complexity-baselines)
10. [Architectural Decisions](#10-architectural-decisions)
11. [Common Implementation Patterns](#11-common-implementation-patterns)

---

## 1. System Overview

**YesFundMe** is a full-stack crowdfunding platform built as an educational project. It demonstrates modern web development patterns with a monorepo structure containing separate client and server packages.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Client (React)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │   Pages      │  │  Components  │  │  Context  │ │
│  │  (Routes)    │  │   (UI)       │  │  (State)  │ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
│           │                │                │        │
│           └────────────────┴────────────────┘        │
│                      │                                │
│                 API Client                           │
└─────────────────────┼───────────────────────────────┘
                      │ HTTP/JSON
                      │ JWT Auth
┌─────────────────────┼───────────────────────────────┐
│                 Express Server                       │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────┐│
│  │  Routes  │→ │Middleware│→ │      Models        ││
│  │  (API)   │  │ (Auth)   │  │ (Data Access)      ││
│  └──────────┘  └──────────┘  └────────────────────┘│
│                                    │                 │
└────────────────────────────────────┼─────────────────┘
                                     │
                      ┌──────────────┴─────────────┐
                      │     SQLite Database         │
                      │  (users, campaigns,         │
                      │   donations)                │
                      └────────────────────────────┘
```

### Design Philosophy

- **Educational First**: Code clarity and learning value over optimization
- **Monolithic Simplicity**: Single SQLite database, no microservices complexity
- **Separation of Concerns**: Clear client/server boundaries, no direct DB access from frontend
- **RESTful APIs**: Standard HTTP methods, JSON payloads, JWT authentication

---

## 2. Technology Stack

### Frontend Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| React | 19.2.0 | UI framework with hooks and context |
| Vite | 7.2.4 | Build tool with HMR for fast development |
| React Router | 7.13.0 | Client-side routing |
| Tailwind CSS | 4.1.18 | Utility-first styling |
| ESLint | 9.39.1 | Code linting |

### Backend Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Node.js | 22.x | JavaScript runtime |
| Express.js | 4.21.0 | Web framework |
| better-sqlite3 | 12.6.2 | SQLite database driver (synchronous) |
| bcrypt | 6.0.0 | Password hashing |
| jsonwebtoken | 9.0.3 | JWT token generation/validation |

### Development Tools

- **npm workspaces**: Monorepo management
- **concurrently**: Run client and server simultaneously
- **nodemon**: Backend hot reload

---

## 3. Project Structure

```
yesfundme/
├── packages/
│   ├── client/                    # React frontend application
│   │   ├── public/                # Static assets
│   │   ├── src/
│   │   │   ├── api/               # API client utilities
│   │   │   │   └── client.js      # HTTP client with token management
│   │   │   ├── components/        # Reusable UI components
│   │   │   │   ├── auth/          # Auth-related components (ProtectedRoute)
│   │   │   │   ├── campaigns/     # Campaign components (Card, List, Form)
│   │   │   │   ├── common/        # Shared UI (Button, Input, Modal)
│   │   │   │   ├── donations/     # Donation components (Form, List)
│   │   │   │   └── layout/        # Layout components (Header, Footer)
│   │   │   ├── context/           # React Context providers
│   │   │   │   └── AuthContext.jsx # Authentication state
│   │   │   ├── pages/             # Page-level components (Routes)
│   │   │   │   ├── Home.jsx
│   │   │   │   ├── Login.jsx
│   │   │   │   ├── Register.jsx
│   │   │   │   ├── Dashboard.jsx
│   │   │   │   ├── BrowseCampaigns.jsx
│   │   │   │   ├── CampaignDetail.jsx
│   │   │   │   ├── CreateCampaign.jsx
│   │   │   │   └── EditCampaign.jsx
│   │   │   ├── App.jsx            # Root component with routes
│   │   │   └── main.jsx           # Entry point
│   │   ├── index.html
│   │   ├── vite.config.js
│   │   └── package.json
│   │
│   ├── server/                    # Express backend application
│   │   ├── db/
│   │   │   ├── index.js           # Database connection singleton
│   │   │   └── init.js            # Database initialization
│   │   ├── middleware/
│   │   │   └── auth.js            # JWT authentication middleware
│   │   ├── models/                # Data access layer
│   │   │   ├── user.js            # User CRUD operations
│   │   │   ├── campaign.js        # Campaign CRUD operations
│   │   │   └── donation.js        # Donation CRUD operations
│   │   ├── routes/                # API route handlers
│   │   │   ├── auth.js            # /api/auth endpoints
│   │   │   ├── campaigns.js       # /api/campaigns endpoints
│   │   │   ├── donations.js       # /api/donations endpoints
│   │   │   └── dashboard.js       # /api/dashboard endpoints
│   │   ├── index.js               # Server entry point
│   │   └── package.json
│   │
│   └── database/                  # Database schema and seeding
│       ├── schema.sql             # Table definitions and indexes
│       ├── seed.js                # Test data seeding script
│       └── package.json
│
├── support_docs/                  # Learning materials and cheatsheets
├── .gobuildme/                    # GoBuildMe framework files
├── package.json                   # Root workspace configuration
└── README.md
```

---

## 4. Core Architectural Patterns

### 4.1 Monorepo with npm Workspaces

**Pattern**: Single repository with multiple packages managed by npm workspaces.

**Implementation**:
- Root `package.json` defines workspaces: `["packages/*"]`
- Shared dependencies can be installed at root or package level
- Scripts can target specific workspaces: `npm run dev --workspace=@yesfundme/client`

**Benefits**:
- Single repository for related code
- Shared tooling and configurations
- Simplified dependency management

### 4.2 Client-Server Separation

**Pattern**: Clear separation between frontend (client) and backend (server) with API communication.

**Rules**:
- ✅ Client communicates via REST APIs only
- ✅ Server exposes RESTful endpoints
- ❌ No direct database access from client
- ❌ No server-side rendering (SPA architecture)

### 4.3 Three-Layer Backend Architecture

**Pattern**: Routes → Models → Database

```
Routes (API endpoints)
  ↓
Middleware (authentication, validation)
  ↓
Models (data access layer)
  ↓
Database (SQLite)
```

**Responsibilities**:
- **Routes**: HTTP handling, request/response, error handling
- **Middleware**: Authentication, authorization, validation
- **Models**: Database queries, business logic, data transformations

### 4.4 Component-Based Frontend

**Pattern**: Reusable React components with clear hierarchy.

```
Pages (route-level, orchestration)
  ↓
Feature Components (campaigns, donations, auth)
  ↓
Common Components (buttons, inputs, modals)
```

**Rules**:
- Pages handle routing and data fetching
- Components are presentational or container-based
- Context for global state (authentication)
- Props for local state and component communication

---

## 5. Data Architecture

### 5.1 Database Schema

**Technology**: SQLite 3 with better-sqlite3 (synchronous driver)

**Tables**:

#### Users Table
```sql
users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
```

#### Campaigns Table
```sql
campaigns (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,           -- FK to users
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  goal_amount REAL NOT NULL,
  current_amount REAL DEFAULT 0,
  image_url TEXT,
  category TEXT NOT NULL,             -- 'medical', 'education', 'emergency', etc.
  status TEXT DEFAULT 'active',       -- 'active', 'cancelled', 'completed'
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
)
```

#### Donations Table
```sql
donations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL,       -- FK to campaigns
  user_id INTEGER,                    -- FK to users (nullable for anonymous)
  amount REAL NOT NULL,
  message TEXT,
  is_anonymous INTEGER DEFAULT 0,     -- SQLite boolean (0/1)
  donor_name TEXT,                    -- For anonymous donations
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (campaign_id) REFERENCES campaigns(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
)
```

### 5.2 Indexes

Performance optimization for common queries:

```sql
-- Campaign queries
idx_campaigns_user_id ON campaigns(user_id)
idx_campaigns_category ON campaigns(category)
idx_campaigns_status ON campaigns(status)

-- Donation queries
idx_donations_campaign_id ON donations(campaign_id)
idx_donations_user_id ON donations(user_id)
```

### 5.3 Data Access Pattern

**Synchronous SQLite Operations**: better-sqlite3 uses synchronous APIs (not async/await).

**Example Model Pattern** (`models/user.js`):
```javascript
import { getDb } from '../db/index.js'

export function findById(id) {
  const db = getDb()
  const stmt = db.prepare('SELECT * FROM users WHERE id = ?')
  return stmt.get(id)
}

export function createUser({ username, email, passwordHash, displayName }) {
  const db = getDb()
  const stmt = db.prepare(
    'INSERT INTO users (username, email, password_hash, display_name) VALUES (?, ?, ?, ?)'
  )
  const result = stmt.run(username, email, passwordHash, displayName)
  return result.lastInsertRowid
}
```

**Key Characteristics**:
- No `async/await` in model functions
- Prepared statements for performance and SQL injection prevention
- Direct return values (not promises)

---

## 6. Authentication & Authorization

### 6.1 JWT-Based Authentication

**Flow**:

```
1. User registers/logs in
   ↓
2. Server validates credentials
   ↓
3. Server generates JWT token (7-day expiry)
   ↓
4. Client stores token in localStorage
   ↓
5. Client includes token in Authorization header
   ↓
6. Server validates token on protected routes
```

### 6.2 Backend Implementation

**Token Generation** (`middleware/auth.js`):
```javascript
export function generateToken(user) {
  return jwt.sign(
    { id: user.id, username: user.username },
    JWT_SECRET,
    { expiresIn: '7d' }
  )
}
```

**Middleware**:
- `authenticateToken`: Require valid JWT (401 if missing, 403 if invalid)
- `optionalAuth`: Attempt to decode JWT but continue if missing/invalid

**Protected Routes**:
```javascript
router.put('/campaigns/:id', authenticateToken, async (req, res) => {
  // req.user is populated by middleware
})
```

### 6.3 Frontend Implementation

**AuthContext** (`context/AuthContext.jsx`):
- Provides `user`, `login`, `register`, `logout`, `updateProfile`
- Manages token storage via API client
- Auto-loads user on app initialization

**API Client** (`api/client.js`):
```javascript
const token = localStorage.getItem('token')
if (token) {
  headers['Authorization'] = `Bearer ${token}`
}
```

**Protected Routes**:
```jsx
<Route
  path="/dashboard"
  element={
    <ProtectedRoute>
      <Dashboard />
    </ProtectedRoute>
  }
/>
```

### 6.4 Authorization Rules

- **Campaigns**: Only owner can update/delete
- **Profile**: Only authenticated user can update their own profile
- **Donations**: Any user (authenticated or anonymous) can donate
- **Dashboard**: Authenticated users only

---

## 7. API Architecture

### 7.1 RESTful Endpoints

**Base URL**: `http://localhost:3000/api`

#### Authentication Routes (`/api/auth`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/register` | Public | Register new user |
| POST | `/auth/login` | Public | Login user |
| GET | `/auth/me` | Protected | Get current user |
| PUT | `/auth/me` | Protected | Update profile |

#### Campaign Routes (`/api/campaigns`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/campaigns` | Public | List campaigns (pagination, search, filter) |
| GET | `/campaigns/:id` | Public | Get campaign details |
| POST | `/campaigns` | Protected | Create campaign |
| PUT | `/campaigns/:id` | Protected (owner) | Update campaign |
| DELETE | `/campaigns/:id` | Protected (owner) | Cancel campaign |

#### Donation Routes
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/campaigns/:id/donations` | Optional | Make donation |
| GET | `/donations/mine` | Protected | Get user's donations |

#### Dashboard Routes
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/dashboard` | Protected | Get user dashboard data |

### 7.2 Request/Response Patterns

**Standard Error Response**:
```json
{
  "error": "Error message string"
}
```

**Success Responses**:
- **Single Resource**: `{ user: {...}, token: "..." }`
- **Collection**: `{ campaigns: [...], total: 42 }`
- **Confirmation**: `{ message: "Success" }`

### 7.3 Pagination & Filtering

**Query Parameters** (campaigns list):
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 12)
- `search`: Search term (title/description)
- `category`: Filter by category
- `status`: Filter by status

**Example**: `GET /api/campaigns?category=medical&page=2&limit=10`

---

## 8. Frontend Architecture

### 8.1 React Patterns

**Hooks Used**:
- `useState`: Local component state
- `useEffect`: Side effects (data fetching, subscriptions)
- `useContext`: Global state access (AuthContext)
- `useNavigate`: Programmatic navigation

**State Management**:
- **Global State**: React Context (AuthContext for user session)
- **Local State**: Component useState (forms, UI toggles)
- **Server State**: Fetch on mount, store in local state (no global cache)

### 8.2 Routing Structure

**Routes** (`App.jsx`):
```
/ → Home (public)
/login → Login (public)
/register → Register (public)
/campaigns → BrowseCampaigns (public)
/campaigns/:id → CampaignDetail (public)
/campaigns/new → CreateCampaign (protected)
/campaigns/:id/edit → EditCampaign (protected, owner only)
/dashboard → Dashboard (protected)
/profile → Profile (protected)
```

**Route Protection**:
- `ProtectedRoute` wrapper checks `isAuthenticated`
- Redirects to `/login` if not authenticated

### 8.3 Component Patterns

**Page Components**:
- Handle routing parameters (`useParams`)
- Fetch data on mount (`useEffect`)
- Pass data to child components via props
- Example: `CampaignDetail.jsx` fetches campaign and passes to `DonationForm`

**Feature Components**:
- Domain-specific (campaigns, donations, auth)
- Receive data via props
- Emit events via callbacks
- Example: `CampaignCard.jsx` receives campaign prop, emits onClick

**Common Components**:
- Reusable UI primitives (Button, Input, Modal)
- Configurable via props
- No business logic

### 8.4 API Client Pattern

**Centralized API Client** (`api/client.js`):
```javascript
const api = {
  get(endpoint) { ... },
  post(endpoint, data) { ... },
  put(endpoint, data) { ... },
  delete(endpoint) { ... },
  setToken(token) { ... },
  getToken() { ... }
}
```

**Usage in Components**:
```javascript
import api from '../api/client'

// In component
useEffect(() => {
  api.get('/campaigns')
    .then(data => setCampaigns(data.campaigns))
    .catch(err => setError(err.message))
}, [])
```

---

## 9. Complexity Baselines

### 9.1 Typical Feature Complexity

| Feature Type | LoC Range | Files | Duration | Example |
|--------------|-----------|-------|----------|---------|
| **Simple UI Component** | 30-80 | 1 | 1-2h | Button, Input, Card |
| **Page Component** | 80-150 | 1 | 2-4h | BrowseCampaigns, Dashboard |
| **API Endpoint** | 40-100 | 2 (route + model) | 2-3h | GET /campaigns |
| **Feature Slice** | 200-400 | 4-8 | 1-2 days | Donation flow (form + API + model) |
| **Complex Feature** | 400-800 | 8-15 | 2-4 days | Full CRUD with auth (campaign management) |

### 9.2 Component Complexity

**Simple Component** (30-80 LoC):
- Single responsibility
- Few props (1-5)
- Minimal state
- Example: `Button.jsx`, `Card.jsx`

**Medium Component** (80-150 LoC):
- Multiple responsibilities
- More props (5-10)
- Local state with effects
- Example: `CampaignCard.jsx`, `DonationForm.jsx`

**Complex Component** (150-300 LoC):
- Orchestration logic
- Data fetching
- Error handling
- Example: `CampaignDetail.jsx`, `Dashboard.jsx`

### 9.3 API Endpoint Complexity

**Simple Endpoint** (40-60 LoC):
- Single model query
- Basic validation
- Standard response
- Example: `GET /campaigns/:id`

**Medium Endpoint** (60-100 LoC):
- Multiple queries
- Validation + authorization
- Transformations
- Example: `POST /campaigns`

**Complex Endpoint** (100-150 LoC):
- Joins/aggregations
- Transaction handling
- Business logic
- Example: `POST /campaigns/:id/donations` (update campaign amount)

---

## 10. Architectural Decisions

### ADR-001: SQLite for Simplicity

**Decision**: Use SQLite instead of PostgreSQL/MySQL.

**Context**: Educational project prioritizing local development simplicity.

**Rationale**:
- No external database server required
- File-based database (`yesfundme.db`)
- Sufficient for learning and low-traffic use
- Easy to reset/seed for development

**Tradeoffs**:
- Not production-ready for concurrent writes
- Limited to single-server deployment
- No replication/clustering

**Status**: Accepted

---

### ADR-002: Monorepo Structure

**Decision**: Use npm workspaces monorepo with separate client/server packages.

**Context**: Need clear separation between frontend and backend while keeping code in one repository.

**Rationale**:
- Single repository for related code
- Clear boundaries between client and server
- Shared tooling and scripts
- Simplified setup for learners

**Tradeoffs**:
- Slightly more complex than single package
- Need to manage workspace dependencies

**Status**: Accepted

---

### ADR-003: JWT for Authentication

**Decision**: Use JWT tokens stored in localStorage for authentication.

**Context**: Need stateless authentication for SPA.

**Rationale**:
- No server-side session storage needed
- Works well with SQLite (no Redis required)
- Simple token-based auth flow
- Educational standard pattern

**Tradeoffs**:
- Tokens vulnerable to XSS (mitigated by proper sanitization)
- Cannot revoke tokens before expiry
- localStorage accessible to JavaScript

**Status**: Accepted

---

### ADR-004: Synchronous SQLite Operations

**Decision**: Use better-sqlite3 (synchronous) instead of async SQLite drivers.

**Context**: Need simple database operations for educational project.

**Rationale**:
- Simpler code without async/await in models
- better-sqlite3 is faster for synchronous operations
- SQLite is fast enough that async isn't needed
- Reduces complexity for learners

**Tradeoffs**:
- Cannot scale to high-concurrency workloads
- Blocks event loop during queries
- Less idiomatic for Node.js

**Status**: Accepted

---

### ADR-005: No State Management Library

**Decision**: Use React Context for global state instead of Redux/Zustand.

**Context**: Application has minimal global state (just user authentication).

**Rationale**:
- Built-in React feature (no dependencies)
- Sufficient for single global state domain
- Simpler for learners
- Less boilerplate

**Tradeoffs**:
- Not suitable if state grows complex
- No dev tools for debugging
- Performance concerns at scale (re-renders)

**Status**: Accepted

---

## 11. Common Implementation Patterns

### 11.1 Protected Route Pattern

**Backend** (owner authorization):
```javascript
router.put('/campaigns/:id', authenticateToken, async (req, res) => {
  const campaign = findCampaignById(req.params.id)
  
  if (!campaign) {
    return res.status(404).json({ error: 'Campaign not found' })
  }
  
  if (campaign.user_id !== req.user.id) {
    return res.status(403).json({ error: 'Not authorized' })
  }
  
  // Proceed with update...
})
```

**Frontend**:
```jsx
<Route
  path="/campaigns/:id/edit"
  element={
    <ProtectedRoute>
      <EditCampaign />
    </ProtectedRoute>
  }
/>
```

### 11.2 Data Fetching Pattern

**Page Component**:
```javascript
function CampaignDetail() {
  const { id } = useParams()
  const [campaign, setCampaign] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  
  useEffect(() => {
    api.get(`/campaigns/${id}`)
      .then(data => {
        setCampaign(data)
        setLoading(false)
      })
      .catch(err => {
        setError(err.message)
        setLoading(false)
      })
  }, [id])
  
  if (loading) return <Loading />
  if (error) return <div>Error: {error}</div>
  
  return <div>{campaign.title}</div>
}
```

### 11.3 Form Submission Pattern

**Component**:
```javascript
function CampaignForm({ onSubmit }) {
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    goalAmount: '',
    category: 'medical'
  })
  const [error, setError] = useState(null)
  
  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      await onSubmit(formData)
    } catch (err) {
      setError(err.message)
    }
  }
  
  return (
    <form onSubmit={handleSubmit}>
      {/* form fields */}
    </form>
  )
}
```

**Page Usage**:
```javascript
function CreateCampaign() {
  const navigate = useNavigate()
  
  const handleCreate = async (data) => {
    const campaign = await api.post('/campaigns', data)
    navigate(`/campaigns/${campaign.id}`)
  }
  
  return <CampaignForm onSubmit={handleCreate} />
}
```

### 11.4 Model CRUD Pattern

**Standard Model Functions**:
```javascript
// Read
export function findById(id) {
  const db = getDb()
  const stmt = db.prepare('SELECT * FROM table WHERE id = ?')
  return stmt.get(id)
}

// Create
export function create(data) {
  const db = getDb()
  const stmt = db.prepare('INSERT INTO table (...) VALUES (...)')
  const result = stmt.run(...values)
  return result.lastInsertRowid
}

// Update
export function update(id, updates) {
  const db = getDb()
  const stmt = db.prepare('UPDATE table SET ... WHERE id = ?')
  return stmt.run(...values, id)
}

// Delete
export function deleteById(id) {
  const db = getDb()
  const stmt = db.prepare('DELETE FROM table WHERE id = ?')
  return stmt.run(id)
}
```

### 11.5 Error Handling Pattern

**API Routes**:
```javascript
router.post('/campaigns', authenticateToken, async (req, res) => {
  try {
    // Validation
    if (!req.body.title) {
      return res.status(400).json({ error: 'Title is required' })
    }
    
    // Business logic
    const campaignId = createCampaign({...})
    const campaign = findCampaignById(campaignId)
    
    res.status(201).json(campaign)
  } catch (err) {
    console.error('Error creating campaign:', err)
    res.status(500).json({ error: 'Internal server error' })
  }
})
```

---

## Appendix A: Environment Setup

### Required Environment Variables

**Server** (`.env` in `packages/server/`):
```env
PORT=3000
JWT_SECRET=your-secret-key-change-in-production
DATABASE_PATH=./yesfundme.db
```

### Development Commands

```bash
# Install all dependencies
npm install

# Seed database
npm run seed

# Reset database (delete and reseed)
npm run reset-db

# Start development (client + server)
npm run dev

# Start only client
npm run dev --workspace=@yesfundme/client

# Start only server
npm run dev --workspace=@yesfundme/server
```

### Ports

- **Frontend**: `http://localhost:5173` (Vite dev server)
- **Backend**: `http://localhost:3000` (Express API)

---

## Appendix B: Key Files Reference

### Critical Configuration Files

- `package.json` (root): Workspace configuration
- `packages/client/vite.config.js`: Vite configuration with proxy to backend
- `packages/server/index.js`: Express server entry point
- `packages/database/schema.sql`: Database schema definition

### Entry Points

- **Frontend**: `packages/client/src/main.jsx` → `App.jsx`
- **Backend**: `packages/server/index.js`
- **Database**: `packages/database/seed.js`

---

**End of Grounding Context**
