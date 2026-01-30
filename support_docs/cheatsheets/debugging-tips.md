# Debugging Tips

## Browser DevTools

### Console
```javascript
console.log(value)           // Log value
console.table(array)         // Display as table
console.error(error)         // Log error
console.group('label')       // Group logs
```

### Network Tab
- Check request/response data
- View status codes
- Inspect headers
- Check timing

### React DevTools
- Inspect component tree
- View props and state
- Track re-renders

## Backend Debugging

### Logging
```javascript
console.log('Endpoint hit:', req.path)
console.log('Request body:', req.body)
console.log('User:', req.user)
```

### Error Details
```javascript
catch (err) {
  console.error('Error name:', err.name)
  console.error('Error message:', err.message)
  console.error('Stack trace:', err.stack)
}
```

## Common Issues

### CORS Errors
- Check server CORS configuration
- Verify API URL matches

### 401 Unauthorized
- Check token is being sent
- Verify token format: `Bearer <token>`
- Check token expiration

### 404 Not Found
- Verify route path
- Check HTTP method (GET vs POST)

### 500 Server Error
- Check server logs
- Verify database connection
- Check for syntax errors

## React Debugging

### Component Not Rendering
- Check conditional logic
- Verify data is loaded
- Check for errors in console

### State Not Updating
- useState is async
- Check dependency array in useEffect
- Verify setState is called

## Resources

- [Chrome DevTools](https://developer.chrome.com/docs/devtools/)
- [React DevTools](https://react.dev/learn/react-developer-tools)
