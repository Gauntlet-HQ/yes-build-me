import { createContext, useContext, useState, useEffect } from 'react'
import api from '../api/client'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = api.getToken()
    if (token) {
      api.get('/auth/me')
        .then(userData => {
          setUser(userData)
        })
        .catch(() => {
          api.setToken(null)
        })
        .finally(() => {
          setLoading(false)
        })
    } else {
      setLoading(false)
    }
  }, [])

  const login = async (username, password) => {
    const data = await api.post('/auth/login', { username, password })
    api.setToken(data.token)
    setUser(data.user)
    return data.user
  }

  const register = async (username, email, password, displayName) => {
    const data = await api.post('/auth/register', { username, email, password, displayName })
    api.setToken(data.token)
    setUser(data.user)
    return data.user
  }

  const logout = () => {
    api.setToken(null)
    setUser(null)
  }

  const updateProfile = async (updates) => {
    const updatedUser = await api.put('/auth/me', updates)
    setUser(updatedUser)
    return updatedUser
  }

  const value = {
    user,
    loading,
    login,
    register,
    logout,
    updateProfile,
    isAuthenticated: !!user
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
