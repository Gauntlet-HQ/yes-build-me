import { useEffect } from 'react'

export default function ConfirmationModal({
  isOpen,
  onConfirm,
  onCancel,
  campaignName,
  amount,
  donorName,
  message,
  isAnonymous
}) {
  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === 'Escape' && isOpen) {
        onCancel()
      }
    }
    document.addEventListener('keydown', handleEscape)
    return () => document.removeEventListener('keydown', handleEscape)
  }, [isOpen, onCancel])

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="fixed inset-0 bg-black bg-opacity-50" />

      <div className="relative bg-white rounded-lg shadow-xl max-w-md w-full mx-4 p-6">
        <h2 className="text-xl font-bold text-gray-900 mb-4 text-center">
          Confirm Your Donation
        </h2>

        <div className="space-y-3 mb-6">
          <div className="flex justify-between">
            <span className="text-gray-600">Campaign:</span>
            <span className="font-medium text-gray-900">{campaignName}</span>
          </div>

          <div className="flex justify-between">
            <span className="text-gray-600">Amount:</span>
            <span className="font-bold text-green-600 text-lg">
              ${parseFloat(amount).toLocaleString(undefined, { minimumFractionDigits: 2 })}
            </span>
          </div>

          <div className="flex justify-between">
            <span className="text-gray-600">From:</span>
            <span className="font-medium text-gray-900">
              {isAnonymous ? 'Anonymous' : donorName}
            </span>
          </div>

          {message && (
            <div className="pt-2 border-t border-gray-200">
              <span className="text-gray-600 text-sm">Message:</span>
              <p className="text-gray-900 mt-1 text-sm">{message}</p>
            </div>
          )}
        </div>

        <div className="flex gap-3">
          <button
            type="button"
            onClick={onCancel}
            className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 font-medium"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={onConfirm}
            className="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 font-medium"
          >
            Confirm
          </button>
        </div>
      </div>
    </div>
  )
}
