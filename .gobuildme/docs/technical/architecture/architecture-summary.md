# Architecture Summary
**Project**: YesFundMe | **Repo**: yesfundme | **Updated**: 2026-01-29

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
| Frontend | React | 19.x | SPA with React Router |
| Build | Vite | 7.x | Fast HMR |
| Styling | Tailwind | 4.x | Utility CSS |
| Backend | Express | 4.x | REST API |
| Database | SQLite | 3.x | better-sqlite3 driver |
| Auth | JWT | - | 7-day expiry |
| Runtime | Node.js | 22.x | ES Modules |

## Critical Paths
- `packages/server/middleware/auth.js` → JWT verification, security-sensitive
- `packages/server/models/` → All database operations
- `packages/client/src/context/AuthContext.jsx` → Auth state management
- `packages/database/schema.sql` → Database schema definition

## Integration Points
- Client → Server: REST API via fetch, JSON bodies
- Server → DB: better-sqlite3 synchronous queries
- Auth: JWT Bearer tokens in Authorization header

## Rules of Thumb
- All API routes prefixed with `/api/`
- Protected routes use `authenticateToken` middleware
- Models handle all database queries (no raw SQL in routes)
- Components in `components/`, pages in `pages/`
- Use `api/client.js` for all API calls from frontend

## Testing Runbook
- Run dev: `npm run dev`
- Seed DB: `npm run seed`
- Reset DB: `npm run reset-db`
- Lint: `npm run lint --workspace=@yesfundme/client`
