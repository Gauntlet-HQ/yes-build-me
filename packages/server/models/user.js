import db from "../db/index.js";

export function createUser({
  username,
  email,
  passwordHash,
  displayName,
  avatarUrl,
}) {
  const stmt = db.prepare(`
    INSERT INTO users (username, email, password_hash, display_name, avatar_url)
    VALUES (?, ?, ?, ?, ?)
  `);
  const result = stmt.run(
    username,
    email,
    passwordHash,
    displayName || username,
    avatarUrl || null,
  );
  return result.lastInsertRowid;
}

export function findByUsername(username) {
  const stmt = db.prepare("SELECT * FROM users WHERE username = ?");
  return stmt.get(username);
}

export function findByEmail(email) {
  const stmt = db.prepare("SELECT * FROM users WHERE email = ?");
  return stmt.get(email);
}

export function findById(id) {
  const stmt = db.prepare("SELECT * FROM users WHERE id = ?");
  return stmt.get(id);
}

export function updateUser(id, updates) {
  const { displayName, avatarUrl } = updates;

  const sets = [];
  const params = [];

  if (displayName !== undefined) {
    sets.push("display_name = ?");
    params.push(displayName);
  }
  if (avatarUrl !== undefined) {
    sets.push("avatar_url = ?");
    params.push(avatarUrl ? avatarUrl.trim() : null);
  }

  if (sets.length === 0) return true;

  const query = `UPDATE users SET ${sets.join(", ")} WHERE id = ?`;
  params.push(id);

  const stmt = db.prepare(query);
  const result = stmt.run(...params);
  return result.changes > 0;
}
