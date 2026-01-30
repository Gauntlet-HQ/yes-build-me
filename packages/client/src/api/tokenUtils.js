/**
 * Check if a JWT token is expired.
 * @param {string|null} token - The JWT token to check
 * @returns {boolean} - true if expired/invalid, false if valid
 */
export function isTokenExpired(token) {
  if (!token || typeof token !== 'string') {
    return true
  }

  try {
    // JWT format: header.payload.signature
    const parts = token.split('.')
    if (parts.length !== 3) {
      return true
    }

    // Decode payload (Base64)
    const payload = JSON.parse(atob(parts[1]))

    // Check exp claim exists and is a number
    if (typeof payload.exp !== 'number') {
      return true
    }

    // Compare with current time (exp is in seconds, Date.now() is in ms)
    const now = Math.floor(Date.now() / 1000)
    return payload.exp <= now
  } catch {
    // Any decode error = treat as expired
    return true
  }
}

