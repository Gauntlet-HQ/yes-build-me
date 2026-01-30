import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { isTokenExpired } from '../tokenUtils'

// Helper to create a JWT token with a specific exp value
function createToken(payload) {
  const header = btoa(JSON.stringify({ alg: 'HS256', typ: 'JWT' }))
  const body = btoa(JSON.stringify(payload))
  const signature = 'fake-signature'
  return `${header}.${body}.${signature}`
}

describe('isTokenExpired', () => {
  beforeEach(() => {
    vi.useFakeTimers()
    vi.setSystemTime(new Date('2026-01-30T12:00:00Z'))
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  // AC-001: Valid token with future exp returns false
  it('returns false for valid token with future exp', () => {
    const futureExp = Math.floor(Date.now() / 1000) + 3600 // 1 hour from now
    const token = createToken({ exp: futureExp, sub: 'user123' })
    expect(isTokenExpired(token)).toBe(false)
  })

  // AC-002: Expired token with past exp returns true
  it('returns true for expired token with past exp', () => {
    const pastExp = Math.floor(Date.now() / 1000) - 3600 // 1 hour ago
    const token = createToken({ exp: pastExp, sub: 'user123' })
    expect(isTokenExpired(token)).toBe(true)
  })

  // AC-E01: Malformed token returns true
  it('returns true for malformed token', () => {
    expect(isTokenExpired('not-a-valid-jwt')).toBe(true)
    expect(isTokenExpired('only.two.parts.but.invalid')).toBe(true)
    expect(isTokenExpired('a.b')).toBe(true)
  })

  // AC-E02: Token without exp claim returns true
  it('returns true for token without exp claim', () => {
    const token = createToken({ sub: 'user123', iat: 123456 })
    expect(isTokenExpired(token)).toBe(true)
  })

  // AC-B01: Boundary expiration at current second
  it('handles boundary expiration at current second', () => {
    const now = Math.floor(Date.now() / 1000)
    const tokenAtNow = createToken({ exp: now })
    // exp <= now should be expired
    expect(isTokenExpired(tokenAtNow)).toBe(true)
  })

  // AC-B02: exp=0 treated as expired
  it('treats exp=0 as expired', () => {
    const token = createToken({ exp: 0 })
    expect(isTokenExpired(token)).toBe(true)
  })

  // Null token returns true
  it('returns true for null token', () => {
    expect(isTokenExpired(null)).toBe(true)
  })

  // Empty string token returns true
  it('returns true for empty string token', () => {
    expect(isTokenExpired('')).toBe(true)
  })
})

