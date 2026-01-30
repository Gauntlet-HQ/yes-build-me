# Express Routes

## Basic Route Structure

```javascript
import { Router } from 'express'

const router = Router()

router.get('/path', (req, res) => {
  res.json({ data: 'value' })
})

export default router
```

## HTTP Methods

```javascript
router.get('/items', handler)      // Read
router.post('/items', handler)     // Create
router.put('/items/:id', handler)  // Update
router.delete('/items/:id', handler) // Delete
```

## Request Object

```javascript
req.params.id    // URL parameters (/items/:id)
req.query.search // Query string (?search=value)
req.body.field   // Request body (POST/PUT)
req.user         // Set by auth middleware
```

## Response Methods

```javascript
res.json({ data })           // Send JSON
res.status(201).json({ })    // Set status code
res.status(404).json({ error: 'Not found' })
```

## Middleware

```javascript
// Apply to all routes
router.use(middleware)

// Apply to specific route
router.get('/protected', authMiddleware, handler)
```

## Error Handling

```javascript
try {
  // Route logic
} catch (err) {
  console.error('Error:', err)
  res.status(500).json({ error: 'Server error' })
}
```

## Resources

- [Express Documentation](https://expressjs.com)
