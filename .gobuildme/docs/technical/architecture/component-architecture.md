# Component Architecture - YesFundMe

## Component Hierarchy

```mermaid
graph TB
    subgraph "App Shell"
        App[App.jsx]
        AP[AuthProvider]
        RR[RouterProvider]
    end

    subgraph "Layout Components"
        L[Layout]
        H[Header]
        F[Footer]
    end

    subgraph "Page Components"
        HP[HomePage]
        BC[BrowseCampaigns]
        CD[CampaignDetail]
        CC[CreateCampaign]
        EC[EditCampaign]
        DB[Dashboard]
        LP[LoginPage]
        RP[RegisterPage]
        PP[ProfilePage]
    end

    subgraph "Feature Components"
        CF[CampaignForm]
        CL[CampaignList]
        CCard[CampaignCard]
        CFil[CampaignFilters]
        DF[DonationForm]
        DL[DonationList]
    end

    subgraph "Common Components"
        Btn[Button]
        Inp[Input]
        Crd[Card]
        Mdl[Modal]
        PR[ProtectedRoute]
    end

    App --> AP
    AP --> RR
    RR --> L
    L --> H
    L --> F
    L --> HP
    L --> BC
    L --> CD
    L --> CC
    L --> EC
    L --> DB
    L --> LP
    L --> RP
    L --> PP

    BC --> CL
    BC --> CFil
    CL --> CCard
    CD --> DF
    CD --> DL
    CD --> Mdl
    CC --> CF
    EC --> CF

    CF --> Inp
    CF --> Btn
    DF --> Inp
    DF --> Btn
    CCard --> Crd
    CCard --> Btn
```

## Component Catalog

### Layout Components

| Component | File | Props | Responsibility |
|-----------|------|-------|----------------|
| **Layout** | `layout/Layout.jsx` | children | Page wrapper with header/footer |
| **Header** | `layout/Header.jsx` | - | Navigation, auth state display |
| **Footer** | `layout/Footer.jsx` | - | Site footer with links |

### Page Components

| Component | File | Route | Auth Required |
|-----------|------|-------|---------------|
| **HomePage** | `pages/Home.jsx` | `/` | No |
| **BrowseCampaigns** | `pages/BrowseCampaigns.jsx` | `/campaigns` | No |
| **CampaignDetail** | `pages/CampaignDetail.jsx` | `/campaigns/:id` | No |
| **CreateCampaign** | `pages/CreateCampaign.jsx` | `/campaigns/new` | Yes |
| **EditCampaign** | `pages/EditCampaign.jsx` | `/campaigns/:id/edit` | Yes (owner) |
| **Dashboard** | `pages/Dashboard.jsx` | `/dashboard` | Yes |
| **LoginPage** | `pages/Login.jsx` | `/login` | No |
| **RegisterPage** | `pages/Register.jsx` | `/register` | No |
| **ProfilePage** | `pages/Profile.jsx` | `/profile` | Yes |

### Feature Components

| Component | File | Props | Used By |
|-----------|------|-------|---------|
| **CampaignForm** | `campaigns/CampaignForm.jsx` | campaign?, onSubmit | CreateCampaign, EditCampaign |
| **CampaignList** | `campaigns/CampaignList.jsx` | campaigns | BrowseCampaigns, Dashboard |
| **CampaignCard** | `campaigns/CampaignCard.jsx` | campaign | CampaignList |
| **CampaignFilters** | `campaigns/CampaignFilters.jsx` | filters, onChange | BrowseCampaigns |
| **DonationForm** | `donations/DonationForm.jsx` | campaignId, onSuccess | CampaignDetail |
| **DonationList** | `donations/DonationList.jsx` | donations | CampaignDetail |

### Common Components

| Component | File | Props | Description |
|-----------|------|-------|-------------|
| **Button** | `common/Button.jsx` | variant, size, disabled, onClick, children | Styled button with variants |
| **Input** | `common/Input.jsx` | label, type, error, ...inputProps | Form input with label/error |
| **Card** | `common/Card.jsx` | children, className | Container card component |
| **Modal** | `common/Modal.jsx` | isOpen, onClose, title, children | Overlay modal dialog |
| **ProtectedRoute** | `auth/ProtectedRoute.jsx` | children | Auth guard wrapper |

## State Management

```mermaid
flowchart TB
    subgraph "Global State (Context)"
        AC[AuthContext]
        AC --> |user| U[Current User]
        AC --> |token| T[JWT Token]
        AC --> |login/logout| A[Auth Actions]
    end

    subgraph "Local State (useState)"
        FS[Form State]
        LS[Loading State]
        ES[Error State]
        MS[Modal State]
    end

    subgraph "Server State (fetch)"
        CD[Campaign Data]
        DD[Donation Data]
        DS[Dashboard Stats]
    end

    AC --> Header
    AC --> ProtectedRoute
    AC --> DonationForm

    FS --> CampaignForm
    FS --> DonationForm
    LS --> Pages
    ES --> Pages
    MS --> CampaignDetail
```

## Data Flow Patterns

### Authentication Flow

```mermaid
sequenceDiagram
    participant U as User
    participant LP as LoginPage
    participant AC as AuthContext
    participant API as api/client.js
    participant LS as localStorage

    U->>LP: Submit credentials
    LP->>API: api.post('/auth/login')
    API-->>LP: {user, token}
    LP->>AC: login(user, token)
    AC->>LS: setItem('token', token)
    AC->>AC: setUser(user)
    LP->>LP: navigate('/dashboard')
```

### Campaign Creation Flow

```mermaid
sequenceDiagram
    participant U as User
    participant CC as CreateCampaign
    participant CF as CampaignForm
    participant API as api/client.js

    U->>CF: Fill form fields
    CF->>CF: Validate inputs
    U->>CF: Submit
    CF->>CC: onSubmit(formData)
    CC->>API: api.post('/campaigns', data)
    API-->>CC: {campaign}
    CC->>CC: navigate(`/campaigns/${id}`)
```

## Component Conventions

### File Structure
```
components/
├── auth/
│   └── ProtectedRoute.jsx
├── campaigns/
│   ├── CampaignCard.jsx
│   ├── CampaignFilters.jsx
│   ├── CampaignForm.jsx
│   └── CampaignList.jsx
├── common/
│   ├── Button.jsx
│   ├── Card.jsx
│   ├── Input.jsx
│   └── Modal.jsx
├── donations/
│   ├── DonationForm.jsx
│   └── DonationList.jsx
└── layout/
    ├── Footer.jsx
    ├── Header.jsx
    └── Layout.jsx
```

### Naming Conventions
- Components: PascalCase (`CampaignCard.jsx`)
- Props: camelCase (`onSubmit`, `isLoading`)
- Event handlers: `handle*` or `on*` (`handleSubmit`, `onClick`)
- State setters: `set*` (`setLoading`, `setError`)

### Prop Patterns
- **Render props**: Not used
- **Children**: Layout components, Card, Modal
- **Callbacks**: `onSubmit`, `onChange`, `onClose`, `onSuccess`
- **Boolean flags**: `isLoading`, `isOpen`, `disabled`
