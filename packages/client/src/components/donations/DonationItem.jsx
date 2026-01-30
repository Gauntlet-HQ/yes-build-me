function getRelativeTime(dateString) {
  const date = new Date(dateString);
  const now = new Date();
  const diffMs = now - date;
  const diffSecs = Math.floor(diffMs / 1000);
  const diffMins = Math.floor(diffSecs / 60);
  const diffHours = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHours / 24);

  if (diffSecs < 60) return "just now";
  if (diffMins < 60) return `${diffMins} minute${diffMins > 1 ? "s" : ""} ago`;
  if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? "s" : ""} ago`;
  if (diffDays < 30) return `${diffDays} day${diffDays > 1 ? "s" : ""} ago`;
  return date.toLocaleDateString();
}

export default function DonationItem({ donation }) {
  const donorName = donation.is_anonymous
    ? "Anonymous Donor"
    : donation.user_display_name || donation.donor_name || "Kind Donor";

  return (
    <div className="border-b border-gray-100 pb-4 last:border-0 last:pb-0">
      <div className="flex justify-between items-start">
        <div className="flex-1">
          <div className="flex items-center gap-2">
            <p className="font-medium text-gray-900">{donorName}</p>
            <span className="text-xs text-gray-400">
              {getRelativeTime(donation.created_at)}
            </span>
          </div>
          {donation.message && (
            <p className="text-gray-600 mt-1 text-sm">{donation.message}</p>
          )}
        </div>
        <span className="font-bold text-green-600 ml-4">
          ${donation.amount.toLocaleString()}
        </span>
      </div>
    </div>
  );
}
