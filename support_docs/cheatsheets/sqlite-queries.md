# SQLite Queries

## Basic Queries

### SELECT
```sql
SELECT * FROM users WHERE id = ?
SELECT id, name FROM users ORDER BY created_at DESC
SELECT * FROM items LIMIT 10 OFFSET 20
```

### INSERT
```sql
INSERT INTO users (username, email) VALUES (?, ?)
```

### UPDATE
```sql
UPDATE users SET name = ? WHERE id = ?
```

### DELETE
```sql
DELETE FROM users WHERE id = ?
```

## better-sqlite3 Usage

### Prepared Statements
```javascript
const stmt = db.prepare('SELECT * FROM users WHERE id = ?')
const user = stmt.get(userId)
```

### Get One Row
```javascript
const user = stmt.get(param)
```

### Get All Rows
```javascript
const users = stmt.all(param)
```

### Run Statement (INSERT/UPDATE/DELETE)
```javascript
const result = stmt.run(param1, param2)
// result.lastInsertRowid - ID of inserted row
// result.changes - Number of affected rows
```

## Transactions

```javascript
const transaction = db.transaction(() => {
  stmt1.run(params)
  stmt2.run(params)
})
transaction()
```

## Resources

- [better-sqlite3 Documentation](https://github.com/WiseLibs/better-sqlite3)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
