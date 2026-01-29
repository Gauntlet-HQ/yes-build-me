import DonationItem from './DonationItem'

export default function DonationList({ donations }) {
  if (!donations || donations.length === 0) {
    return (
      <div className="text-center py-6">
        <p className="text-gray-500">No donations yet. Be the first to donate!</p>
      </div>
    )
  }

  return (
    <div>
      <p className="text-sm text-gray-500 mb-4">
        {donations.length} donation{donations.length !== 1 ? 's' : ''}
      </p>
      <div className="space-y-4">
        {donations.map((donation) => (
          <DonationItem key={donation.id} donation={donation} />
        ))}
      </div>
    </div>
  )
}
