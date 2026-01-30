import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";

export default function Profile() {
  const { user, updateProfile } = useAuth();
  const [formData, setFormData] = useState({
    displayName: user?.displayName || "",
    avatarUrl: user?.avatarUrl || "",
  });
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState("");

  // Sync state when user loads
  useEffect(() => {
    if (user) {
      setFormData({
        displayName: user.displayName || user.display_name || "",
        avatarUrl: user.avatarUrl || user.avatar_url || "",
      });
    }
  }, [user]);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    setSuccess(false);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    setSuccess(false);

    try {
      // Trim inputs to prevent whitespace issues
      const updates = {
        displayName: formData.displayName.trim(),
        avatarUrl: formData.avatarUrl.trim() || null,
      };
      await updateProfile(updates);
      setSuccess(true);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-2xl mx-auto px-4">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">
          Profile Settings
        </h1>

        <div className="bg-white rounded-lg shadow-md p-6">
          {/* Current User Info */}
          <div className="flex items-center mb-8 pb-8 border-b border-gray-200">
            <div className="w-20 h-20 rounded-full bg-gray-200 overflow-hidden">
              {user?.avatarUrl || user?.avatar_url ? (
                <img
                  src={user.avatarUrl || user.avatar_url}
                  alt={user.displayName || user.display_name}
                  className="w-full h-full object-cover"
                  onError={(e) => {
                    e.target.onerror = null;
                    e.target.src =
                      "https://api.dicebear.com/7.x/initials/svg?seed=" +
                      (user.displayName || user.username);
                  }}
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-2xl font-bold text-gray-400">
                  {user?.displayName?.charAt(0) ||
                    user?.display_name?.charAt(0) ||
                    user?.username?.charAt(0) ||
                    "?"}
                </div>
              )}
            </div>
            <div className="ml-6">
              <h2 className="text-xl font-semibold text-gray-900">
                {user?.displayName || user?.username}
              </h2>
              <p className="text-gray-500">@{user?.username}</p>
              <p className="text-gray-500 text-sm">{user?.email}</p>
            </div>
          </div>

          {/* Edit Form */}
          <form onSubmit={handleSubmit} className="space-y-6">
            {error && (
              <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded">
                {error}
              </div>
            )}

            {success && (
              <div className="bg-green-50 border border-green-200 text-green-600 px-4 py-3 rounded">
                Profile updated successfully!
              </div>
            )}

            <div>
              <label
                htmlFor="displayName"
                className="block text-sm font-medium text-gray-700"
              >
                Display Name
              </label>
              <input
                type="text"
                id="displayName"
                name="displayName"
                value={formData.displayName}
                onChange={handleChange}
                className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500"
              />
            </div>

            <div>
              <label
                htmlFor="avatarUrl"
                className="block text-sm font-medium text-gray-700"
              >
                Avatar URL
              </label>
              <input
                type="url"
                id="avatarUrl"
                name="avatarUrl"
                value={formData.avatarUrl}
                onChange={handleChange}
                placeholder="https://example.com/avatar.jpg"
                className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500"
              />
              <p className="mt-1 text-sm text-gray-500">
                Enter a URL to an image for your profile picture
              </p>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50"
            >
              {loading ? "Saving..." : "Save Changes"}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
