# System Analysis - YesFundMe

## Architectural Style

**Pattern**: Monorepo with Client-Server Architecture

YesFundMe follows a classic three-tier architecture implemented as an npm workspaces monorepo:

1. **Presentation Tier** (`packages/client`): React SPA with Vite
2. **Application Tier** (`packages/server`): Express.js REST API
3. **Data Tier** (`packages/database` + SQLite file): Persistent storage

## Design Decisions

### 1. Monorepo Structure (npm Workspaces)
- **Decision**: Single repo with `packages/*` structure
- **Rationale**: Simplified dependency management, atomic commits across client/server, shared tooling
- **Trade-offs**: Larger repo size, all packages versioned together

### 2. SQLite for Development
- **Decision**: Use better-sqlite3 instead of PostgreSQL
- **Rationale**: Zero configuration, file-based, perfect for rapid development and learning
- **Trade-offs**: Not suitable for production scale, no concurrent writes
- **Migration Path**: Schema designed to be PostgreSQL-compatible

### 3. JWT Authentication
- **Decision**: Stateless JWT tokens stored client-side
- **Rationale**: Simple, scalable, no session storage needed
- **Trade-offs**: Token revocation requires additional infrastructure

### 4. React 19 + Vite
- **Decision**: Latest React with Vite bundler
- **Rationale**: Fast HMR, modern tooling, React Server Components ready
- **Trade-offs**: Cutting-edge versions may have fewer community resources

## Component Interactions

```
┌─────────────────────────────────────────────────────────────┐
│                     packages/client                          │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────────────┐ │
│  │  Pages  │──│Components│──│ Context │──│   API Client    │ │
│  └─────────┘  └─────────┘  └─────────┘  └────────┬────────┘ │
└──────────────────────────────────────────────────┼──────────┘
                                                   │ HTTP/JSON
                                                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     packages/server                          │
│  ┌─────────┐  ┌──────────┐  ┌─────────┐  ┌───────────────┐  │
│  │ Routes  │──│Middleware│──│ Models  │──│   Database    │  │
│  └─────────┘  └──────────┘  └─────────┘  └───────────────┘  │
└─────────────────────────────────────────────────────────────┘
                                                   │
                                                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    packages/database                         │
│  ┌──────────┐  ┌──────────┐                                 │
│  │schema.sql│  │ seed.js  │  → yesfundme.db (SQLite file)   │
│  └──────────┘  └──────────┘                                 │
└─────────────────────────────────────────────────────────────┘
```

## Key Patterns

### Frontend Patterns
- **Context API** for global state (AuthContext)
- **Protected Routes** for authenticated pages
- **Component Composition** with layout wrappers
- **Tailwind CSS** for utility-first styling

### Backend Patterns
- **RESTful Routes** organized by resource (`/api/auth`, `/api/campaigns`, etc.)
- **Middleware Chain** for auth validation
- **Model Layer** encapsulating database queries
- **Synchronous SQLite** via better-sqlite3 (no callbacks)

## Scalability Considerations

| Concern | Current | Production Path |
|---------|---------|-----------------|
| Database | SQLite (single file) | PostgreSQL + connection pooling |
| Sessions | JWT (stateless) | Add Redis for token blacklist |
| Static Assets | Vite dev server | CDN (CloudFront, etc.) |
| API Server | Single process | PM2 cluster or container replicas |
