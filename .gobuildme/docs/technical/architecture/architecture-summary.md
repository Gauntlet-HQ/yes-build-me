# Architecture Summary
**Project**: YesFundMe | **Repo**: yes-build-me | **Updated**: 2026-01-30 (079886d)

## Structure
| Area | Path | Purpose | Owner |
|------|------|---------|-------|
| Client | `packages/client/` | React SPA frontend | Frontend |
| Server | `packages/server/` | Express REST API | Backend |
| Database | `packages/database/` | Schema + seed scripts | Backend |
| Components | `packages/client/src/components/` | Reusable UI components | Frontend |
| Pages | `packages/client/src/pages/` | Route-level components | Frontend |
| Routes | `packages/server/routes/` | API endpoint handlers | Backend |
| Models | `packages/server/models/` | Database operations | Backend |
| Middleware | `packages/server/middleware/` | Auth + request processing | Backend |

## Stack
| Layer | Tech | Version | Notes |
|-------|------|---------|-------|
| Runtime | Node.js | 22+ | ES Modules |
| Frontend | React | 19.2 | With React Router 7 |
| Bundler | Vite | 7.2 | SWC transform |
| Styling | TailwindCSS | 4.1 | PostCSS integration |
| Backend | Express | 4.21 | REST API |
| Database | SQLite | via better-sqlite3 | File-based |
| Auth | JWT + bcrypt | 9.0/6.0 | Stateless tokens |

## Critical Paths
- `packages/server/middleware/auth.js` → JWT validation, security-critical
- `packages/server/models/user.js` → Password handling, bcrypt operations
- `packages/server/db/init.js` → Database initialization
- `packages/client/src/context/AuthContext.jsx` → Global auth state
- `packages/database/schema.sql` → Database schema definition

## Integration Points
- Client → Server: REST API at `http://localhost:3000/api`
- Server → Database: better-sqlite3 synchronous queries
- Auth: JWT in `Authorization: Bearer` header

## Rules of Thumb
- All database access through models, never direct SQL in routes
- Protected routes use `authenticateToken` middleware
- Passwords never returned in API responses
- React pages fetch data in `useEffect`, handle loading/error states
- Form components use controlled inputs with validation

## Testing Runbook
- Install deps: `npm install`
- Seed database: `npm run seed`
- Start dev: `npm run dev` (runs client + server concurrently)
- Reset database: `npm run reset-db`
- Lint client: `npm run lint --workspace=@yesfundme/client`
