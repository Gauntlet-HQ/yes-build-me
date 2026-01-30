import { useState } from 'react'
import { useAuth } from '../../context/AuthContext'
import api from '../../api/client'
import Modal from '../common/Modal'

export default function DonationForm({ campaignId, onSuccess }) {
  const { user } = useAuth()
  const [amount, setAmount] = useState('')
  const [message, setMessage] = useState('')
  const [isAnonymous, setIsAnonymous] = useState(false)
  const [donorName, setDonorName] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [showConfirmation, setShowConfirmation] = useState(false)

  const presetAmounts = [10, 25, 50, 100, 250]

  // Validate form and show confirmation modal
  const handleSubmit = (e) => {
    e.preventDefault()
    setError('')

    if (!amount || parseFloat(amount) <= 0) {
      setError('Please enter a valid donation amount')
      return
    }

    if (!user && !donorName.trim()) {
      setError('Please enter your name')
      return
    }

    // Show confirmation modal instead of submitting directly
    setShowConfirmation(true)
  }

  // Actually submit the donation after confirmation
  const handleConfirm = async () => {
    setLoading(true)

    try {
      await api.post(`/campaigns/${campaignId}/donations`, {
        amount: parseFloat(amount),
        message: message || null,
        isAnonymous,
        donorName: !user ? donorName : null
      })

      // Reset form on success
      setAmount('')
      setMessage('')
      setIsAnonymous(false)
      setDonorName('')
      setShowConfirmation(false)

      if (onSuccess) onSuccess()
    } catch (err) {
      setError(err.message)
      // Keep modal open on error so user can retry
    } finally {
      setLoading(false)
    }
  }

  // Close modal without submitting
  const handleCancel = () => {
    setShowConfirmation(false)
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-600 px-3 py-2 rounded text-sm">
          {error}
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Select Amount
        </label>
        <div className="flex flex-wrap gap-2 mb-2">
          {presetAmounts.map((preset) => (
            <button
              key={preset}
              type="button"
              onClick={() => setAmount(preset.toString())}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                amount === preset.toString()
                  ? 'bg-green-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              ${preset}
            </button>
          ))}
        </div>
        <div className="relative">
          <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">$</span>
          <input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="Other amount"
            className="w-full pl-8 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
          />
        </div>
      </div>

      {!user && (
        <div>
          <label htmlFor="donorName" className="block text-sm font-medium text-gray-700 mb-1">
            Your Name
          </label>
          <input
            type="text"
            id="donorName"
            value={donorName}
            onChange={(e) => setDonorName(e.target.value)}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
          />
        </div>
      )}

      <div>
        <label htmlFor="message" className="block text-sm font-medium text-gray-700 mb-1">
          Message (optional)
        </label>
        <textarea
          id="message"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          rows={3}
          placeholder="Leave a message of support..."
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
        />
      </div>

      {user && (
        <label className="flex items-center gap-2 cursor-pointer">
          <input
            type="checkbox"
            checked={isAnonymous}
            onChange={(e) => setIsAnonymous(e.target.checked)}
            className="w-4 h-4 text-green-600 rounded focus:ring-green-500"
          />
          <span className="text-sm text-gray-700">Make my donation anonymous</span>
        </label>
      )}

      <button
        type="submit"
        disabled={loading}
        className="w-full py-3 px-4 bg-green-600 text-white font-medium rounded-lg hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50"
      >
        {loading ? 'Processing...' : 'Donate Now'}
      </button>

      {/* Confirmation Modal */}
      <Modal
        isOpen={showConfirmation}
        onClose={handleCancel}
        title="Confirm Your Donation"
      >
        <div className="space-y-4">
          {/* Error message in modal */}
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-600 px-3 py-2 rounded text-sm">
              {error}
            </div>
          )}

          {/* Donation amount */}
          <div className="text-center py-4">
            <p className="text-gray-600 text-sm">You are about to donate</p>
            <p className="text-3xl font-bold text-green-600 mt-1">
              ${parseFloat(amount || 0).toLocaleString()}
            </p>
          </div>

          {/* Donation details */}
          <div className="bg-gray-50 rounded-lg p-4 space-y-2">
            {/* Guest donor name */}
            {!user && donorName && (
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Donor Name:</span>
                <span className="font-medium text-gray-900">{donorName}</span>
              </div>
            )}

            {/* Anonymous indicator */}
            {user && isAnonymous && (
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Visibility:</span>
                <span className="font-medium text-gray-900">Anonymous donation</span>
              </div>
            )}

            {/* Message preview */}
            {message && (
              <div className="text-sm">
                <span className="text-gray-600">Message:</span>
                <p className="mt-1 text-gray-900 italic">"{message}"</p>
              </div>
            )}

            {/* Fee breakdown */}
            <div className="border-t border-gray-200 pt-2 mt-2">
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Donation Amount:</span>
                <span className="font-medium text-gray-900">
                  ${parseFloat(amount || 0).toLocaleString()}
                </span>
              </div>
            </div>
          </div>

          {/* Action buttons */}
          <div className="flex gap-3 pt-2">
            <button
              type="button"
              onClick={handleCancel}
              disabled={loading}
              className="flex-1 py-2 px-4 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 disabled:opacity-50"
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={handleConfirm}
              disabled={loading}
              className="flex-1 py-2 px-4 bg-green-600 text-white font-medium rounded-lg hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50"
            >
              {loading ? 'Processing...' : 'Confirm Donation'}
            </button>
          </div>
        </div>
      </Modal>
    </form>
  )
}
