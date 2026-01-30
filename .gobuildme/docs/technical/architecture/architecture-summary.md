# Architecture Summary
**Project**: YesFundMe | **Repo**: /Users/nidheesh/Work/Gauntlet Training/Day5/yes-build-me | **Updated**: 2026-01-30 (079886d5)

## Structure (≤10 rows)
| Area | Path | Purpose | Owner |
|------|------|---------|-------|
| Workspace root | `package.json` | npm workspaces + root scripts | fullstack |
| Frontend app | `packages/client/` | React SPA (Vite) | frontend |
| Backend API | `packages/server/` | Express API + auth + models | backend |
| Database assets | `packages/database/` | SQLite schema + seed scripts | backend |
| Learning docs | `support_docs/` | Cheatsheets and references | all |

## Stack (≤8 rows)
| Layer | Tech | Version | Notes |
|------|------|---------|-------|
| Runtime | Node.js | >= 22 | From root `package.json` engines |
| Frontend | React | 19.x | SPA |
| Frontend build | Vite | 7.x | Dev server + bundling |
| Styling | Tailwind CSS | 4.x | PostCSS pipeline |
| Routing | React Router | 7.x | Client-side routing |
| Backend | Express | 4.x | REST JSON API |
| Auth | JWT + bcrypt | jsonwebtoken 9 / bcrypt 6 | Bearer tokens + password hashing |
| Database | SQLite | better-sqlite3 12.x | WAL enabled |

## Critical Paths (≤10 bullets)
- `packages/server/middleware/auth.js` → Security-sensitive JWT verification and token creation
- `packages/server/routes/*.js` → API boundaries + validation + authorization checks
- `packages/server/models/*.js` → Data access + SQL correctness
- `packages/server/db/index.js` → DB file location and WAL configuration
- `packages/client/src/context/AuthContext.jsx` → Auth state + token persistence behavior
- `packages/client/src/components/auth/ProtectedRoute.jsx` → Route protection logic

## Integration Points (≤8 bullets)
- Browser (client) → API server: HTTP JSON under `/api/*` (dev: `http://localhost:3000`)
- API server → SQLite file: `DATABASE_PATH` (default `packages/server/yesfundme.db`)

## Rules of Thumb (≤10 bullets)
- Keep client/server boundaries: client calls server via HTTP only.
- Validate inputs in routes; do not trust client payloads.
- Keep SQL in models (not routes) and use indexes for common filters.
- Never hardcode secrets (especially JWT secret).
- Prefer small, reversible PRs; avoid mixed concerns.

## Testing Runbook (≤8 bullets)
- Local dev (client + server): `npm run dev`
- Seed DB: `npm run seed`
- Reset DB: `npm run reset-db`
- Client lint: `npm run lint --workspace=@yesfundme/client`
- Client build: `npm run build --workspace=@yesfundme/client`

