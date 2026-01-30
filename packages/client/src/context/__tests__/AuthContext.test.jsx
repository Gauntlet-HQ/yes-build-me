import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { AuthProvider, useAuth } from '../AuthContext'
import api from '../../api/client'

// Helper to create a JWT token with a specific exp value
function createToken(payload) {
  const header = btoa(JSON.stringify({ alg: 'HS256', typ: 'JWT' }))
  const body = btoa(JSON.stringify(payload))
  const signature = 'fake-signature'
  return `${header}.${body}.${signature}`
}

// Test component that displays auth state
function TestConsumer() {
  const { user, loading, isAuthenticated } = useAuth()
  return (
    <div>
      <span data-testid="loading">{loading ? 'true' : 'false'}</span>
      <span data-testid="user">{user ? user.username : 'null'}</span>
      <span data-testid="authenticated">{isAuthenticated ? 'true' : 'false'}</span>
    </div>
  )
}

// Fixed timestamp for consistent token testing (2026-01-30T12:00:00Z)
const FIXED_NOW = 1738238400000

describe('AuthContext token validation', () => {
  let originalDateNow

  beforeEach(() => {
    // Mock Date.now() without fake timers to avoid timeout issues
    originalDateNow = Date.now
    Date.now = vi.fn(() => FIXED_NOW)
    vi.spyOn(api, 'getToken')
    vi.spyOn(api, 'setToken')
    vi.spyOn(api, 'get')
  })

  afterEach(() => {
    Date.now = originalDateNow
    vi.restoreAllMocks()
  })

  // Test: validates token on mount
  it('validates token on mount', async () => {
    const futureExp = Math.floor(Date.now() / 1000) + 3600
    const validToken = createToken({ exp: futureExp })
    api.getToken.mockReturnValue(validToken)
    api.get.mockResolvedValue({ id: 1, username: 'testuser' })

    render(
      <AuthProvider>
        <TestConsumer />
      </AuthProvider>
    )

    await waitFor(() => {
      expect(screen.getByTestId('loading').textContent).toBe('false')
    })

    expect(api.getToken).toHaveBeenCalled()
  })

  // AC-001: Valid token triggers /auth/me call
  it('proceeds with valid token, calls /auth/me', async () => {
    const futureExp = Math.floor(Date.now() / 1000) + 3600
    const validToken = createToken({ exp: futureExp })
    api.getToken.mockReturnValue(validToken)
    api.get.mockResolvedValue({ id: 1, username: 'testuser' })

    render(
      <AuthProvider>
        <TestConsumer />
      </AuthProvider>
    )

    await waitFor(() => {
      expect(screen.getByTestId('loading').textContent).toBe('false')
    })

    expect(api.get).toHaveBeenCalledWith('/auth/me')
    expect(screen.getByTestId('user').textContent).toBe('testuser')
  })

  // AC-002: Expired token clears and no API call
  it('clears expired token, no API call', async () => {
    const pastExp = Math.floor(Date.now() / 1000) - 3600
    const expiredToken = createToken({ exp: pastExp })
    api.getToken.mockReturnValue(expiredToken)

    render(
      <AuthProvider>
        <TestConsumer />
      </AuthProvider>
    )

    await waitFor(() => {
      expect(screen.getByTestId('loading').textContent).toBe('false')
    })

    expect(api.setToken).toHaveBeenCalledWith(null)
    expect(api.get).not.toHaveBeenCalled()
    expect(screen.getByTestId('user').textContent).toBe('null')
  })

  // AC-003: No token sets loading false
  it('handles no token, sets loading false', async () => {
    api.getToken.mockReturnValue(null)

    render(
      <AuthProvider>
        <TestConsumer />
      </AuthProvider>
    )

    await waitFor(() => {
      expect(screen.getByTestId('loading').textContent).toBe('false')
    })

    expect(api.get).not.toHaveBeenCalled()
    expect(screen.getByTestId('user').textContent).toBe('null')
  })

  // AC-E01: Malformed token triggers logout
  it('clears malformed token', async () => {
    api.getToken.mockReturnValue('not-a-valid-jwt')

    render(
      <AuthProvider>
        <TestConsumer />
      </AuthProvider>
    )

    await waitFor(() => {
      expect(screen.getByTestId('loading').textContent).toBe('false')
    })

    expect(api.setToken).toHaveBeenCalledWith(null)
    expect(api.get).not.toHaveBeenCalled()
  })
})

