# JWT Authentication

## How JWT Works

1. User logs in with credentials
2. Server verifies credentials
3. Server generates JWT token
4. Client stores token (localStorage)
5. Client sends token with each request
6. Server verifies token on protected routes

## Token Structure

```
header.payload.signature

Header: { "alg": "HS256", "typ": "JWT" }
Payload: { "id": 1, "username": "user", "exp": 1234567890 }
Signature: HMACSHA256(base64(header) + "." + base64(payload), secret)
```

## Server-Side (Express)

### Generate Token
```javascript
import jwt from 'jsonwebtoken'

const token = jwt.sign(
  { id: user.id, username: user.username },
  JWT_SECRET,
  { expiresIn: '7d' }
)
```

### Verify Token (Middleware)
```javascript
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization']
  const token = authHeader && authHeader.split(' ')[1]

  if (!token) return res.status(401).json({ error: 'Token required' })

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' })
    req.user = user
    next()
  })
}
```

## Client-Side (React)

### Store Token
```javascript
localStorage.setItem('token', token)
```

### Send Token with Requests
```javascript
headers: {
  'Authorization': `Bearer ${token}`
}
```

## Resources

- [JWT.io](https://jwt.io)
- [jsonwebtoken npm](https://www.npmjs.com/package/jsonwebtoken)
