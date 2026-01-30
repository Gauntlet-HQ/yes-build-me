export default function ProgressBar({ currentAmount, goalAmount, showText = true, size = 'md' }) {
  const percentage = Math.min((currentAmount / goalAmount) * 100, 100)
  const isOverFunded = currentAmount > goalAmount

  const heightClasses = {
    sm: 'h-2',
    md: 'h-3',
    lg: 'h-4',
  }

  return (
    <div>
      <div className={`w-full bg-gray-200 rounded-full ${heightClasses[size] || heightClasses.md}`}>
        <div
          className={`bg-green-500 ${heightClasses[size] || heightClasses.md} rounded-full transition-all duration-500`}
          style={{ width: `${percentage}%` }}
        />
      </div>

      {showText && (
        <div className="mt-2 flex justify-between text-sm">
          <span className="font-medium text-gray-900">
            ${currentAmount.toLocaleString()} raised
          </span>
          <span className="text-gray-500">
            of ${goalAmount.toLocaleString()} goal
          </span>
        </div>
      )}

      {isOverFunded && showText && (
        <p className="text-sm text-green-600 mt-1">
          Goal exceeded by ${(currentAmount - goalAmount).toLocaleString()}!
        </p>
      )}
    </div>
  )
}
