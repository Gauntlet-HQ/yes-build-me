# Data Architecture - YesFundMe

## Database Schema

### Entity Relationship Diagram

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│      users      │       │    campaigns    │       │    donations    │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ id (PK)         │──┐    │ id (PK)         │──┐    │ id (PK)         │
│ username        │  │    │ user_id (FK)────│──┘    │ campaign_id (FK)│───┐
│ email           │  │    │ title           │       │ user_id (FK)────│───┼──┐
│ password_hash   │  │    │ description     │       │ amount          │   │  │
│ display_name    │  └────│ goal_amount     │       │ message         │   │  │
│ avatar_url      │       │ current_amount  │◀──────│ is_anonymous    │   │  │
│ created_at      │       │ image_url       │       │ donor_name      │   │  │
└─────────────────┘       │ category        │       │ created_at      │   │  │
                          │ status          │       └─────────────────┘   │  │
                          │ created_at      │                             │  │
                          │ updated_at      │                             │  │
                          └─────────────────┘                             │  │
                                   ▲                                      │  │
                                   └──────────────────────────────────────┘  │
                                   ▲                                         │
                                   └─────────────────────────────────────────┘
```

### Table Definitions

#### users
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PK, AUTO | Unique identifier |
| username | TEXT | UNIQUE, NOT NULL | Login username |
| email | TEXT | UNIQUE, NOT NULL | User email |
| password_hash | TEXT | NOT NULL | bcrypt hash |
| display_name | TEXT | | Public display name |
| avatar_url | TEXT | | Profile image URL |
| created_at | DATETIME | DEFAULT NOW | Registration timestamp |

#### campaigns
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PK, AUTO | Unique identifier |
| user_id | INTEGER | FK → users, NOT NULL | Campaign creator |
| title | TEXT | NOT NULL | Campaign title |
| description | TEXT | NOT NULL | Full description |
| goal_amount | REAL | NOT NULL | Target amount ($) |
| current_amount | REAL | DEFAULT 0 | Raised amount ($) |
| image_url | TEXT | | Campaign image |
| category | TEXT | NOT NULL | Campaign category |
| status | TEXT | DEFAULT 'active' | active/paused/completed |
| created_at | DATETIME | DEFAULT NOW | Creation timestamp |
| updated_at | DATETIME | DEFAULT NOW | Last update |

#### donations
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PK, AUTO | Unique identifier |
| campaign_id | INTEGER | FK → campaigns, NOT NULL | Target campaign |
| user_id | INTEGER | FK → users | Donor (null if anonymous) |
| amount | REAL | NOT NULL | Donation amount ($) |
| message | TEXT | | Donor message |
| is_anonymous | INTEGER | DEFAULT 0 | Hide donor identity |
| donor_name | TEXT | | Name for anonymous donors |
| created_at | DATETIME | DEFAULT NOW | Donation timestamp |

## Indexes

```sql
-- Performance indexes for common queries
CREATE INDEX idx_campaigns_user_id ON campaigns(user_id);     -- User's campaigns
CREATE INDEX idx_campaigns_category ON campaigns(category);    -- Browse by category
CREATE INDEX idx_campaigns_status ON campaigns(status);        -- Active campaigns
CREATE INDEX idx_donations_campaign_id ON donations(campaign_id); -- Campaign donations
CREATE INDEX idx_donations_user_id ON donations(user_id);      -- User's donations
```

## Data Flow

### Campaign Creation
```
Client                    Server                   Database
  │                         │                         │
  │  POST /api/campaigns    │                         │
  │  {title, description,   │                         │
  │   goal_amount, ...}     │                         │
  │────────────────────────▶│                         │
  │                         │  INSERT INTO campaigns  │
  │                         │─────────────────────────▶
  │                         │                         │
  │                         │◀─────────────────────────
  │                         │  {id, ...}              │
  │◀────────────────────────│                         │
  │  {campaign}             │                         │
```

### Donation Flow
```
Client                    Server                   Database
  │                         │                         │
  │  POST /api/donations    │                         │
  │  {campaign_id, amount}  │                         │
  │────────────────────────▶│                         │
  │                         │  BEGIN TRANSACTION      │
  │                         │─────────────────────────▶
  │                         │  INSERT INTO donations  │
  │                         │─────────────────────────▶
  │                         │  UPDATE campaigns       │
  │                         │  SET current_amount +=  │
  │                         │─────────────────────────▶
  │                         │  COMMIT                 │
  │                         │─────────────────────────▶
  │◀────────────────────────│                         │
  │  {donation, campaign}   │                         │
```

## Data Access Patterns

### Read Patterns
| Query | Frequency | Optimization |
|-------|-----------|--------------|
| Browse active campaigns | High | idx_campaigns_status |
| Filter by category | Medium | idx_campaigns_category |
| View campaign details | High | Primary key lookup |
| User's campaigns | Medium | idx_campaigns_user_id |
| Campaign donations | Medium | idx_donations_campaign_id |

### Write Patterns
| Operation | Frequency | Considerations |
|-----------|-----------|----------------|
| New user registration | Low | Email/username uniqueness |
| Create campaign | Low | User validation |
| Make donation | Medium | Transaction for amount update |
| Update campaign | Low | Owner authorization |

## Migration Considerations

### SQLite → PostgreSQL
| SQLite | PostgreSQL | Notes |
|--------|------------|-------|
| INTEGER | SERIAL | Auto-increment syntax |
| TEXT | VARCHAR/TEXT | Size limits optional |
| REAL | DECIMAL | Precision for money |
| DATETIME | TIMESTAMP | Timezone handling |
| INTEGER (boolean) | BOOLEAN | Native boolean type |

### Schema Migration Script (Future)
```sql
-- PostgreSQL version would add:
-- 1. DECIMAL(10,2) for money columns
-- 2. UUID for primary keys (optional)
-- 3. JSONB for flexible metadata
-- 4. Full-text search indexes
```
