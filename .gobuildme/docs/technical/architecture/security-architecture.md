# Security Architecture

## Authentication

- **Mechanism**: JWT bearer tokens (`Authorization: Bearer <token>`).
- **Middleware**: `packages/server/middleware/auth.js`
  - `authenticateToken` enforces auth and populates `req.user`.
  - `optionalAuth` attaches user context when a valid token is present.

## Authorization

- Ownership checks are enforced in routes where required:
  - Campaign update/delete requires the authenticated user to be the campaign owner.
- Protected endpoints use `authenticateToken`:
  - `/api/auth/me`, `/api/auth/me` (PUT)
  - `/api/campaigns` (POST), `/api/campaigns/:id` (PUT/DELETE)
  - `/api/donations/mine`
  - `/api/dashboard`

## Credential Storage

- Passwords are stored as **bcrypt hashes** (`users.password_hash`).
- Password verification uses `bcrypt.compare`.

## Secrets & Configuration

- `JWT_SECRET` must come from environment configuration (`.env` in local dev).
- Note: there is a **development fallback secret** in `middleware/auth.js`; it must not be relied on for production use.

## Data Protection

- Do not log:
  - JWTs
  - passwords
  - password hashes
- Prefer returning generic error messages for auth failures (already practiced via `{ error: "..." }`).

## Attack Surface Summary

| Surface | Examples | Primary Controls |
|--------|----------|------------------|
| Auth endpoints | `/api/auth/register`, `/api/auth/login` | validation + bcrypt + JWT |
| Protected resources | campaign CRUD, user profile | JWT middleware + ownership checks |
| Untrusted inputs | query params, request JSON bodies | route-level validation |

