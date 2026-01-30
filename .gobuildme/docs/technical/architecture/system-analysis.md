# System Analysis

## Overview

YesFundMe is a small full-stack learning app built as an npm workspaces monorepo:

- **Client**: React SPA (Vite) served by a dev server in development.
- **Server**: Express REST API that exposes JSON endpoints under `/api/*`.
- **Database**: SQLite file accessed by the server via `better-sqlite3`.

## High-Level Architecture

### Modules
- `packages/client/`: UI + routing + auth context + feature pages.
- `packages/server/`: Express app (`index.js`) + middleware + routes + model layer.
- `packages/database/`: schema + seeding scripts (for local/dev).

### Runtime Topology (local dev)

1. `npm run dev` starts:
   - Vite dev server for the SPA (default Vite port)
   - Express API server on `PORT` (default `3000`)
2. Browser loads the SPA from Vite and calls the API server for data/auth.

## Key Architectural Patterns

### API Routing and Layering
- `packages/server/index.js` wires route modules:
  - `/api/auth` → `routes/auth.js`
  - `/api/campaigns` → `routes/campaigns.js`
  - `/api/campaigns/:id/donations`, `/api/donations/mine` → `routes/donations.js`
  - `/api/dashboard` → `routes/dashboard.js`
- Each route module performs input validation and delegates persistence to the model layer (`models/*.js`).

### Authentication
- JWT bearer token auth:
  - `authenticateToken` blocks unauthenticated access and sets `req.user`.
  - `optionalAuth` attaches user context if provided; otherwise continues.
- Tokens are created with `generateToken` and include `{ id, username }`.

### Authorization
- Route-level checks enforce ownership:
  - Campaign update/delete requires authenticated user and `campaign.user_id === req.user.id`.

### Data Access
- SQLite file DB opened once via `better-sqlite3` (synchronous driver).
- WAL mode is enabled for better concurrent read/write behavior in local dev.

## Error Handling Conventions
- Errors are typically returned as JSON `{ error: "..." }` with appropriate HTTP status codes:
  - 400 for validation errors
  - 401 for missing token / invalid credentials
  - 403 for invalid/expired token or forbidden resource access
  - 404 for missing records
  - 500 for unhandled server errors

## Cross-Cutting Concerns

### Configuration
- `.env` controls:
  - `PORT`
  - `JWT_SECRET`
  - `DATABASE_PATH`

### Logging
- Server logs to console; avoid logging secrets or JWTs.

## Known Constraints / Intentional Simplifications
- Single-process server and a single SQLite file are appropriate for this learning app.
- No explicit migrations framework (schema is in `packages/database/schema.sql`).
- No formal test harness configured at the root yet (recommended for new work).

