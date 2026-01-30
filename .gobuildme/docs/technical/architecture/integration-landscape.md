# Integration Landscape

## Internal Integrations

### Client ↔ Server
- **Protocol**: HTTP
- **Format**: JSON
- **Base path**: `/api/*`
- **Auth**: Bearer token (`Authorization` header)

### Server ↔ Database
- **Database**: SQLite (file)
- **Driver**: `better-sqlite3`
- **DB path source**: `DATABASE_PATH` env var (defaults to `packages/server/yesfundme.db`)

## External Integrations

There are currently **no external third-party service integrations** (payments, email, storage, etc.) in this codebase.

## Configuration Surfaces

| Config | Purpose |
|--------|---------|
| `PORT` | Express server listen port |
| `JWT_SECRET` | JWT signing/verification secret |
| `DATABASE_PATH` | Path to SQLite database file |

