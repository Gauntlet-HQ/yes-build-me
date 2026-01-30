import { Link } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'

export default function NavBar() {
  const { user, logout } = useAuth()

  return (
    <nav className="bg-white shadow-sm">
      <div className="max-w-6xl mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center gap-8">
            <Link to="/" className="text-xl font-bold text-green-600">
              YesFundMe
            </Link>
            <div className="hidden md:flex items-center gap-6">
              <Link to="/campaigns" className="text-gray-600 hover:text-gray-900">
                Browse
              </Link>
              {user && (
                <Link to="/campaigns/new" className="text-gray-600 hover:text-gray-900">
                  Create Campaign
                </Link>
              )}
            </div>
          </div>

          <div className="flex items-center gap-4">
            {user ? (
              <>
                <Link to="/dashboard" className="text-gray-600 hover:text-gray-900">
                  Dashboard
                </Link>
                <Link to="/profile" className="text-gray-600 hover:text-gray-900">
                  Profile
                </Link>
                <button
                  onClick={logout}
                  className="text-gray-600 hover:text-gray-900"
                >
                  Logout
                </button>
              </>
            ) : (
              <>
                <Link to="/login" className="text-gray-600 hover:text-gray-900">
                  Login
                </Link>
                <Link
                  to="/register"
                  className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                >
                  Sign Up
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  )
}
