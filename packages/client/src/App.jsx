import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import ProtectedRoute from './components/auth/ProtectedRoute'
import NavBar from './components/common/NavBar'
import Login from './pages/Login'
import Register from './pages/Register'
import Dashboard from './pages/Dashboard'
import Profile from './pages/Profile'
import BrowseCampaigns from './pages/BrowseCampaigns'
import CampaignDetail from './pages/CampaignDetail'
import CreateCampaign from './pages/CreateCampaign'
import EditCampaign from './pages/EditCampaign'

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <NavBar />
        <Routes>
          <Route path="/" element={<Navigate to="/campaigns" replace />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/campaigns" element={<BrowseCampaigns />} />
          <Route path="/campaigns/:id" element={<CampaignDetail />} />
          <Route
            path="/campaigns/new"
            element={
              <ProtectedRoute>
                <CreateCampaign />
              </ProtectedRoute>
            }
          />
          <Route
            path="/campaigns/:id/edit"
            element={
              <ProtectedRoute>
                <EditCampaign />
              </ProtectedRoute>
            }
          />
          <Route
            path="/dashboard"
            element={
              <ProtectedRoute>
                <Dashboard />
              </ProtectedRoute>
            }
          />
          <Route
            path="/profile"
            element={
              <ProtectedRoute>
                <Profile />
              </ProtectedRoute>
            }
          />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  )
}

export default App
