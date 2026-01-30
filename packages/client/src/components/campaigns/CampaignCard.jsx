import { Link } from 'react-router-dom'

const categoryColors = {
  community: 'bg-blue-100 text-blue-800',
  animals: 'bg-orange-100 text-orange-800',
  creative: 'bg-purple-100 text-purple-800',
  education: 'bg-green-100 text-green-800',
  medical: 'bg-red-100 text-red-800',
  business: 'bg-yellow-100 text-yellow-800',
  sports: 'bg-indigo-100 text-indigo-800',
  emergency: 'bg-pink-100 text-pink-800',
}

export default function CampaignCard({ campaign }) {
  const progress = Math.min((campaign.current_amount / campaign.goal_amount) * 100, 100)
  const categoryColor = categoryColors[campaign.category] || 'bg-gray-100 text-gray-800'

  return (
    <Link to={`/campaigns/${campaign.id}`} className="block">
      <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
        <div className="aspect-video bg-gray-200">
          {campaign.image_url ? (
            <img
              src={campaign.image_url}
              alt={campaign.title}
              className="w-full h-full object-cover"
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center text-gray-400">
              No image
            </div>
          )}
        </div>

        <div className="p-4">
          <span className={`inline-block px-2 py-1 text-xs font-medium rounded-full ${categoryColor}`}>
            {campaign.category}
          </span>

          <h3 className="mt-2 text-lg font-semibold text-gray-900 line-clamp-2">
            {campaign.title}
          </h3>

          <p className="mt-1 text-sm text-gray-600 line-clamp-3">
            {campaign.description}
          </p>

          <div className="mt-4">
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-green-600 h-2 rounded-full"
                style={{ width: `${progress}%` }}
              />
            </div>
            <div className="mt-2 flex justify-between text-sm">
              <span className="font-medium text-gray-900">
                ${campaign.current_amount.toLocaleString()}
              </span>
              <span className="text-gray-500">
                of ${campaign.goal_amount.toLocaleString()}
              </span>
            </div>
          </div>
        </div>
      </div>
    </Link>
  )
}
