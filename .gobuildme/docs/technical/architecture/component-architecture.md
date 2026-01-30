# Component Architecture - YesFundMe

## Frontend Component Hierarchy

```
App
├── AuthProvider (Context)
│   └── BrowserRouter
│       └── Layout
│           ├── Header
│           │   └── Navigation links
│           ├── Routes
│           │   ├── Home
│           │   ├── Login
│           │   ├── Register
│           │   ├── BrowseCampaigns
│           │   │   ├── CategoryFilter
│           │   │   └── CampaignList
│           │   │       └── CampaignCard[]
│           │   │           └── ProgressBar
│           │   ├── CampaignDetail
│           │   │   ├── CampaignCard
│           │   │   ├── DonationForm
│           │   │   └── DonationList
│           │   │       └── DonationItem[]
│           │   ├── ProtectedRoute
│           │   │   ├── CreateCampaign
│           │   │   │   └── CampaignForm
│           │   │   ├── EditCampaign
│           │   │   │   └── CampaignForm
│           │   │   ├── Dashboard
│           │   │   └── Profile
│           │   └── NotFound
│           └── Footer
```

## Component Categories

### Layout Components
| Component | Path | Purpose |
|-----------|------|---------|
| Layout | `components/layout/Layout.jsx` | Page wrapper with header/footer |
| Header | `components/layout/Header.jsx` | Navigation and auth status |
| Footer | `components/layout/Footer.jsx` | Site footer |

### Auth Components
| Component | Path | Purpose |
|-----------|------|---------|
| AuthProvider | `context/AuthContext.jsx` | Global auth state management |
| ProtectedRoute | `components/auth/ProtectedRoute.jsx` | Route guard for auth |

### Campaign Components
| Component | Path | Purpose |
|-----------|------|---------|
| CampaignCard | `components/campaigns/CampaignCard.jsx` | Campaign preview card |
| CampaignForm | `components/campaigns/CampaignForm.jsx` | Create/edit form |
| CampaignList | `components/campaigns/CampaignList.jsx` | Grid of campaign cards |
| CategoryFilter | `components/campaigns/CategoryFilter.jsx` | Category selection |
| ProgressBar | `components/campaigns/ProgressBar.jsx` | Funding progress display |

### Donation Components
| Component | Path | Purpose |
|-----------|------|---------|
| DonationForm | `components/donations/DonationForm.jsx` | Donation input form |
| DonationItem | `components/donations/DonationItem.jsx` | Single donation display |
| DonationList | `components/donations/DonationList.jsx` | List of donations |

### Common Components
| Component | Path | Purpose |
|-----------|------|---------|
| Button | `components/common/Button.jsx` | Reusable button |
| Card | `components/common/Card.jsx` | Container card |
| Input | `components/common/Input.jsx` | Form input field |
| Loading | `components/common/Loading.jsx` | Loading spinner |
| Modal | `components/common/Modal.jsx` | Modal dialog |

### Pages
| Page | Path | Route | Auth |
|------|------|-------|------|
| Home | `pages/Home.jsx` | `/` | No |
| Login | `pages/Login.jsx` | `/login` | No |
| Register | `pages/Register.jsx` | `/register` | No |
| BrowseCampaigns | `pages/BrowseCampaigns.jsx` | `/campaigns` | No |
| CampaignDetail | `pages/CampaignDetail.jsx` | `/campaigns/:id` | No |
| CreateCampaign | `pages/CreateCampaign.jsx` | `/campaigns/new` | Yes |
| EditCampaign | `pages/EditCampaign.jsx` | `/campaigns/:id/edit` | Yes |
| Dashboard | `pages/Dashboard.jsx` | `/dashboard` | Yes |
| Profile | `pages/Profile.jsx` | `/profile` | Yes |
| NotFound | `pages/NotFound.jsx` | `*` | No |

## Backend Component Structure

```
packages/server/
├── index.js              # Express app entry point
├── db/
│   ├── index.js          # Database connection
│   └── init.js           # Database initialization
├── middleware/
│   └── auth.js           # JWT authentication middleware
├── models/
│   ├── user.js           # User CRUD operations
│   ├── campaign.js       # Campaign CRUD operations
│   └── donation.js       # Donation CRUD operations
└── routes/
    ├── auth.js           # /api/auth/* routes
    ├── campaigns.js      # /api/campaigns/* routes
    ├── donations.js      # /api/donations/* routes
    └── dashboard.js      # /api/dashboard/* routes
```

## API Endpoints

### Auth Routes (`/api/auth`)
| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/register` | authRoutes | Create new user |
| POST | `/login` | authRoutes | Authenticate user |
| GET | `/me` | authRoutes | Get current user |

### Campaign Routes (`/api/campaigns`)
| Method | Path | Handler | Auth | Description |
|--------|------|---------|------|-------------|
| GET | `/` | campaignRoutes | No | List campaigns |
| GET | `/:id` | campaignRoutes | No | Get campaign details |
| POST | `/` | campaignRoutes | Yes | Create campaign |
| PUT | `/:id` | campaignRoutes | Yes | Update campaign |
| DELETE | `/:id` | campaignRoutes | Yes | Delete campaign |

### Donation Routes (`/api/donations`)
| Method | Path | Handler | Auth | Description |
|--------|------|---------|------|-------------|
| POST | `/campaigns/:id/donations` | donationRoutes | No* | Make donation |
| GET | `/campaigns/:id/donations` | donationRoutes | No | List donations |

### Dashboard Routes (`/api/dashboard`)
| Method | Path | Handler | Auth | Description |
|--------|------|---------|------|-------------|
| GET | `/stats` | dashboardRoutes | Yes | User statistics |
| GET | `/campaigns` | dashboardRoutes | Yes | User's campaigns |
| GET | `/donations` | dashboardRoutes | Yes | User's donations |

## State Management

### AuthContext
```javascript
// Provided state
{
  user: { id, username, email, display_name } | null,
  token: string | null,
  isAuthenticated: boolean,
  isLoading: boolean
}

// Provided actions
{
  login: (email, password) => Promise,
  register: (username, email, password) => Promise,
  logout: () => void
}
```

### Data Fetching Pattern
```javascript
// Pattern used in pages
const [data, setData] = useState(null)
const [loading, setLoading] = useState(true)
const [error, setError] = useState(null)

useEffect(() => {
  fetchData()
    .then(setData)
    .catch(setError)
    .finally(() => setLoading(false))
}, [])
```
