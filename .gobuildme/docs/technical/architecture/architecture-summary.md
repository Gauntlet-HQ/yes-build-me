# Architecture Summary
**Project**: YesFundMe | **Repo**: yesfundme | **Updated**: 2026-01-29

## System Overview
3-tier monorepo: React SPA → Express REST API → SQLite database

## Structure
| Area | Path | Purpose | Owner |
|------|------|---------|-------|
| Client | packages/client/ | React SPA frontend | Frontend |
| Server | packages/server/ | Express REST API | Backend |
| Database | packages/database/ | Schema and seeds | Backend |
| Components | packages/client/src/components/ | Reusable UI components | Frontend |
| Pages | packages/client/src/pages/ | Route-level components | Frontend |
| Routes | packages/server/routes/ | API endpoints | Backend |
| Models | packages/server/models/ | Database operations | Backend |

## Stack
| Layer | Tech | Version | Notes |
|-------|------|---------|-------|
| Frontend | React | 19.x | SPA with React Router 7 |
| Build | Vite | 7.x | Fast HMR, proxy to :3000 |
| Styling | Tailwind | 4.x | Utility CSS |
| Backend | Express | 4.x | REST API on :3000 |
| Database | SQLite | 3.x | better-sqlite3 (sync) |
| Auth | JWT/bcrypt | - | 7-day expiry, 10 salt rounds |
| Runtime | Node.js | 22.x | ES Modules |

## Data Model
- **Users**: id, username, email, password_hash, display_name, avatar_url
- **Campaigns**: id, user_id(FK), title, description, goal_amount, current_amount, status
- **Donations**: id, campaign_id(FK), user_id(FK nullable), amount, donor_name, is_anonymous

## API Endpoints
| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| POST | /api/auth/register | No | User registration |
| POST | /api/auth/login | No | User login, returns JWT |
| GET | /api/auth/me | Yes | Current user profile |
| GET | /api/campaigns | No | List campaigns (paginated) |
| GET | /api/campaigns/:id | No | Campaign details |
| POST | /api/campaigns | Yes | Create campaign |
| PUT | /api/campaigns/:id | Owner | Update campaign |
| DELETE | /api/campaigns/:id | Owner | Close campaign |
| POST | /api/campaigns/:id/donations | No | Make donation |
| GET | /api/dashboard | Yes | User stats |

## Critical Paths
- `packages/server/middleware/auth.js` → JWT verification
- `packages/server/models/` → All database operations
- `packages/client/src/context/AuthContext.jsx` → Auth state
- `packages/database/schema.sql` → Schema definition

## Integration Points
- Client → Server: REST API via fetch, Vite proxies /api to :3000
- Server → DB: better-sqlite3 synchronous queries
- Auth: JWT Bearer tokens in Authorization header

## Rules of Thumb
- All API routes prefixed with `/api/`
- Protected routes use `authenticateToken` middleware
- Models handle all database queries (no raw SQL in routes)
- Components in `components/`, pages in `pages/`
- Use `api/client.js` for all API calls from frontend

## Commands
| Command | Purpose |
|---------|---------|
| `npm run dev` | Start client + server |
| `npm run seed` | Seed database |
| `npm run reset-db` | Delete and reseed |
| `npm run lint` | Lint all packages |

## Architecture Docs
- [System Analysis](system-analysis.md) - Architectural patterns
- [Technology Stack](technology-stack.md) - Dependencies and versions
- [Data Architecture](data-architecture.md) - ERD and data flow
- [Security Architecture](security-architecture.md) - Auth and authorization
- [Integration Landscape](integration-landscape.md) - API contract
- [Component Architecture](component-architecture.md) - React components
