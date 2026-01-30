# Technology Stack - YesFundMe

## Overview

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| **Runtime** | Node.js | 22+ | JavaScript runtime |
| **Package Manager** | npm | 9+ | Dependency management (workspaces) |

## Frontend Stack

| Technology | Version | Purpose | Notes |
|------------|---------|---------|-------|
| React | 19.2.0 | UI library | Latest with concurrent features |
| React DOM | 19.2.0 | DOM rendering | Paired with React |
| React Router | 7.13.0 | Client-side routing | v7 with data APIs |
| Vite | 7.2.4 | Build tool & dev server | Fast HMR, ESM-native |
| TailwindCSS | 4.1.18 | Utility CSS framework | JIT compilation |
| PostCSS | 8.5.6 | CSS processing | Tailwind integration |
| ESLint | 9.39.1 | Linting | Flat config format |

## Backend Stack

| Technology | Version | Purpose | Notes |
|------------|---------|---------|-------|
| Express.js | 4.21.0 | Web framework | Minimal, flexible |
| better-sqlite3 | 12.6.2 | SQLite driver | Synchronous API |
| jsonwebtoken | 9.0.3 | JWT handling | Auth tokens |
| bcrypt | 6.0.0 | Password hashing | Argon2 alternative |
| nodemon | 3.1.0 | Dev server | Auto-restart on changes |

## Database

| Technology | Version | Purpose | Notes |
|------------|---------|---------|-------|
| SQLite | 3.x (via better-sqlite3) | Relational database | File-based, zero config |

## Development Tools

| Tool | Version | Purpose |
|------|---------|---------|
| concurrently | 9.2.1 | Run multiple scripts | Client + server together |
| @vitejs/plugin-react-swc | 4.2.2 | React transform | Faster than Babel |
| autoprefixer | 10.4.23 | CSS vendor prefixes | PostCSS plugin |

## Dependency Graph

```
yesfundme (root)
├── @yesfundme/client
│   ├── react, react-dom (UI)
│   ├── react-router-dom (routing)
│   ├── vite + plugins (build)
│   └── tailwindcss + postcss (styling)
├── @yesfundme/server
│   ├── express (HTTP)
│   ├── better-sqlite3 (database)
│   ├── jsonwebtoken (auth)
│   └── bcrypt (security)
└── @yesfundme/database
    └── better-sqlite3 (schema/seed)
```

## Version Constraints

```json
{
  "engines": {
    "node": ">=22.0.0"
  }
}
```

## Security Considerations

| Package | Security Role |
|---------|---------------|
| bcrypt | Password hashing with salt (cost factor 10) |
| jsonwebtoken | Signed tokens, expiration enforcement |
| better-sqlite3 | Parameterized queries prevent SQL injection |

## Future Considerations

| Current | Upgrade Path | When |
|---------|--------------|------|
| SQLite | PostgreSQL | Production deployment |
| bcrypt | Argon2 | If bcrypt vulnerabilities found |
| Express 4 | Express 5 | When stable |
