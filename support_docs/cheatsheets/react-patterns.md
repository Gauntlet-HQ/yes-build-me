# React Patterns

## Component Structure

```jsx
function MyComponent({ prop1, prop2 }) {
  const [state, setState] = useState(initialValue)

  useEffect(() => {
    // Side effects here
  }, [dependencies])

  return (
    <div>
      {/* JSX here */}
    </div>
  )
}
```

## Common Hooks

### useState
```jsx
const [value, setValue] = useState(initialValue)
```

### useEffect
```jsx
useEffect(() => {
  // Runs on mount and when dependencies change
  return () => {
    // Cleanup function
  }
}, [dependencies])
```

### useContext
```jsx
const value = useContext(MyContext)
```

## Conditional Rendering

```jsx
{condition && <Component />}
{condition ? <ComponentA /> : <ComponentB />}
```

## List Rendering

```jsx
{items.map((item) => (
  <Component key={item.id} {...item} />
))}
```

## Event Handling

```jsx
<button onClick={() => handleClick(arg)}>Click</button>
<input onChange={(e) => setValue(e.target.value)} />
<form onSubmit={handleSubmit}>
```

## Resources

- [React Documentation](https://react.dev)
