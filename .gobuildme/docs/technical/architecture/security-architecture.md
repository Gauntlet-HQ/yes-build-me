# Security Architecture - YesFundMe

## Authentication Flow

```
┌──────────┐    POST /api/auth/register     ┌──────────┐
│  Client  │ ──────────────────────────────▶│  Server  │
│          │    { username, email, password}│          │
│          │◀────────────────────────────── │          │
│          │    { user, token }             │          │
└──────────┘                                └──────────┘

┌──────────┐    POST /api/auth/login        ┌──────────┐
│  Client  │ ──────────────────────────────▶│  Server  │
│          │    { email, password }         │          │
│          │◀────────────────────────────── │          │
│          │    { user, token }             │ bcrypt   │
└──────────┘                                │ compare  │
                                            └──────────┘
```

## Security Mechanisms

### 1. Password Security
- **Algorithm**: bcrypt with configurable cost factor
- **Storage**: Only hash stored, never plaintext
- **Validation**: Minimum length enforced at API level

```javascript
// Password hashing (registration)
const hash = await bcrypt.hash(password, 10)

// Password verification (login)
const valid = await bcrypt.compare(password, user.password_hash)
```

### 2. JWT Token Management
- **Signing**: HMAC-SHA256 with secret from environment
- **Payload**: User ID, issued-at timestamp
- **Expiration**: Configurable (recommended: 24h)
- **Storage**: Client-side (localStorage/memory)

```javascript
// Token generation
jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '24h' })

// Token verification (middleware)
jwt.verify(token, process.env.JWT_SECRET)
```

### 3. Authorization Middleware

```javascript
// packages/server/middleware/auth.js
export const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization']
  const token = authHeader && authHeader.split(' ')[1]
  
  if (!token) return res.sendStatus(401)
  
  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) return res.sendStatus(403)
    req.user = decoded
    next()
  })
}
```

## Protected Resources

| Endpoint | Auth Required | Authorization |
|----------|---------------|---------------|
| `GET /api/campaigns` | No | Public |
| `GET /api/campaigns/:id` | No | Public |
| `POST /api/campaigns` | Yes | Any authenticated user |
| `PUT /api/campaigns/:id` | Yes | Owner only |
| `DELETE /api/campaigns/:id` | Yes | Owner only |
| `POST /api/donations` | Optional | Anonymous allowed |
| `GET /api/dashboard` | Yes | Own data only |

## Data Protection

### Sensitive Data Handling
| Data Type | Storage | Exposure |
|-----------|---------|----------|
| Password | Hashed (bcrypt) | Never returned in API |
| Email | Plaintext | Only to authenticated owner |
| JWT Secret | Environment variable | Never in code/logs |
| User ID | Database | Encoded in JWT, not exposed |

### SQL Injection Prevention
- **Method**: Parameterized queries via better-sqlite3
- **Pattern**: All user input passed as parameters, never concatenated

```javascript
// Safe query pattern
db.prepare('SELECT * FROM users WHERE id = ?').get(userId)

// NEVER do this
db.exec(`SELECT * FROM users WHERE id = ${userId}`) // VULNERABLE
```

## Security Checklist

- [x] Passwords hashed with bcrypt
- [x] JWT for stateless authentication
- [x] Auth middleware on protected routes
- [x] Parameterized SQL queries
- [x] Environment-based secrets
- [ ] HTTPS enforcement (production)
- [ ] Rate limiting (production)
- [ ] CORS configuration (production)
- [ ] CSP headers (production)

## Threat Model

| Threat | Mitigation | Status |
|--------|------------|--------|
| Credential stuffing | bcrypt slow hashing | ✅ |
| SQL injection | Parameterized queries | ✅ |
| Token theft | Short expiration, HTTPS | ⚠️ HTTPS pending |
| XSS | React escaping, CSP | ⚠️ CSP pending |
| CSRF | JWT in Authorization header | ✅ |

## Environment Variables

```bash
# Required for security
JWT_SECRET=<strong-random-string>  # MUST change in production

# Optional security settings
TOKEN_EXPIRY=24h
BCRYPT_ROUNDS=10
```
