# System Analysis - YesFundMe

## Architectural Style

**Pattern**: Monorepo with Client-Server Architecture

YesFundMe follows a classic three-tier architecture:
1. **Presentation Layer**: React SPA (Single Page Application)
2. **Application Layer**: Express.js REST API
3. **Data Layer**: SQLite database

## Design Decisions

### Why Monorepo?
- Shared configuration and tooling
- Atomic commits across frontend/backend
- Simplified dependency management for learning projects

### Why SQLite?
- Zero configuration database
- File-based, easy to reset/seed
- Sufficient for learning and demo purposes

### Why JWT Authentication?
- Stateless authentication
- Easy to implement and understand
- Standard industry practice

## Component Boundaries

```
┌─────────────────────────────────────────────────────────────┐
│                     packages/client                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Pages     │  │ Components  │  │   Context/State     │  │
│  │             │  │             │  │                     │  │
│  │ - Home      │  │ - Campaign  │  │ - AuthContext       │  │
│  │ - Campaigns │  │ - Donation  │  │ - API Client        │  │
│  │ - Dashboard │  │ - Layout    │  │                     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ REST API (JSON)
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     packages/server                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Routes    │  │   Models    │  │    Middleware       │  │
│  │             │  │             │  │                     │  │
│  │ - auth      │  │ - user      │  │ - authenticateToken │  │
│  │ - campaigns │  │ - campaign  │  │ - optionalAuth      │  │
│  │ - donations │  │ - donation  │  │                     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ better-sqlite3
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    packages/database                         │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  SQLite: yesfundme.db                                   ││
│  │  - users, campaigns, donations tables                   ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

1. **User Action** → React Component
2. **API Call** → api/client.js (with JWT if authenticated)
3. **Route Handler** → packages/server/routes/
4. **Business Logic** → packages/server/models/
5. **Database Query** → SQLite via better-sqlite3
6. **Response** → JSON back through the chain
