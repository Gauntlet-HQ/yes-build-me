# Technology Stack

## Runtime & Tooling

| Category | Tech | Version / Constraint | Source |
|----------|------|----------------------|--------|
| Runtime | Node.js | >= 22.0.0 | root `package.json` engines |
| Package management | npm workspaces | npm (workspace root) | root `package.json` workspaces |
| Dev orchestration | concurrently | 9.2.1 | root `package.json` devDependencies |

## Frontend (Client)

| Layer | Tech | Version | Notes |
|------|------|---------|-------|
| UI | React | 19.2.x | `packages/client/package.json` |
| DOM | react-dom | 19.2.x |  |
| Routing | react-router-dom | 7.13.x | client-side routes |
| Build/dev server | Vite | 7.2.x | `vite` |
| Styling | Tailwind CSS | 4.1.x | PostCSS pipeline |
| Linting | ESLint | 9.39.x | `eslint` + plugins |

## Backend (Server)

| Layer | Tech | Version | Notes |
|------|------|---------|-------|
| HTTP server | Express | 4.21.x | REST JSON API |
| Auth | jsonwebtoken | 9.0.x | JWT signing/verify |
| Password hashing | bcrypt | 6.0.x | password hashes stored in DB |
| Dev tooling | nodemon | 3.1.x | dev server reloading |

## Data Layer

| Layer | Tech | Version | Notes |
|------|------|---------|-------|
| Database | SQLite | file-based | primary datastore |
| Driver | better-sqlite3 | 12.6.x | synchronous DB access; WAL enabled |

