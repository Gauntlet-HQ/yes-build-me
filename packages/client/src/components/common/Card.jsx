export default function Card({ children, className = '', padding = true }) {
  return (
    <div className={`bg-white rounded-lg shadow-md ${padding ? 'p-6' : ''} ${className}`}>
      {children}
    </div>
  )
}
