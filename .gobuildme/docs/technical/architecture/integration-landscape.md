# Integration Landscape - YesFundMe

## System Integrations

### Current Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client (Browser)                          │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                 React SPA (Vite Dev Server)                 ││
│  │                    http://localhost:5173                     ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/JSON (REST API)
                              │ Authorization: Bearer <JWT>
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Server (Express.js)                         │
│                     http://localhost:3000                        │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  /api/health    - Health check                              ││
│  │  /api/auth/*    - Authentication endpoints                   ││
│  │  /api/campaigns/* - Campaign CRUD                           ││
│  │  /api/donations/* - Donation endpoints                      ││
│  │  /api/dashboard/* - User dashboard data                     ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ SQLite (better-sqlite3)
                              │ Synchronous queries
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Database (SQLite File)                       │
│                    ./yesfundme.db                                │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐         │
│  │    users      │ │   campaigns   │ │   donations   │         │
│  └───────────────┘ └───────────────┘ └───────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

## API Client Configuration

### Client-Side API Module
```javascript
// packages/client/src/api/client.js
const API_BASE = 'http://localhost:3000/api'

export const apiClient = {
  get: (path, token) => fetch(`${API_BASE}${path}`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  }),
  
  post: (path, data, token) => fetch(`${API_BASE}${path}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {})
    },
    body: JSON.stringify(data)
  })
}
```

## Communication Protocols

### REST API Standards
| Aspect | Standard |
|--------|----------|
| Protocol | HTTP/1.1 (HTTPS in production) |
| Data Format | JSON |
| Auth Header | `Authorization: Bearer <jwt>` |
| Content-Type | `application/json` |

### Response Formats

**Success Response**
```json
{
  "data": { /* resource data */ },
  "message": "Success message (optional)"
}
```

**Error Response**
```json
{
  "error": "Error message",
  "code": "ERROR_CODE (optional)"
}
```

### HTTP Status Codes
| Code | Usage |
|------|-------|
| 200 | Successful GET/PUT |
| 201 | Successful POST (created) |
| 400 | Bad request / validation error |
| 401 | Unauthorized (no/invalid token) |
| 403 | Forbidden (not owner) |
| 404 | Resource not found |
| 500 | Server error |

## External Service Placeholders

### Future Integrations (Not Yet Implemented)

| Service | Purpose | Priority |
|---------|---------|----------|
| Stripe | Payment processing | High |
| AWS S3 | Image storage | Medium |
| SendGrid | Email notifications | Medium |
| Cloudflare | CDN / DDoS protection | Low |
| Sentry | Error tracking | Medium |

### Payment Integration (Planned)
```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Client  │────▶│  Server  │────▶│  Stripe  │
│          │     │          │     │          │
│  1. Init │     │ 2. Create│     │ 3. Process│
│  payment │     │  intent  │     │  payment │
└──────────┘     └──────────┘     └──────────┘
      ▲                                 │
      └─────────────────────────────────┘
               4. Confirm success
```

## Development Environment

### Port Allocation
| Service | Port | Purpose |
|---------|------|---------|
| Vite Dev Server | 5173 | Frontend development |
| Express Server | 3000 | API backend |
| SQLite | N/A | File-based (no port) |

### Environment Variables
```bash
# packages/server/.env
PORT=3000
JWT_SECRET=your-secret-key-change-in-production
DATABASE_PATH=./yesfundme.db
```

## CORS Configuration

### Current (Development)
```javascript
// Implicit - same-origin or Vite proxy
// No explicit CORS middleware configured
```

### Production Requirements
```javascript
// Future: Add cors middleware
import cors from 'cors'
app.use(cors({
  origin: process.env.CLIENT_URL,
  credentials: true
}))
```

## Health Check Endpoint

```
GET /api/health

Response:
{
  "status": "ok",
  "timestamp": "2026-01-30T12:00:00.000Z"
}
```

Used for:
- Deployment readiness checks
- Load balancer health probes
- Monitoring uptime
