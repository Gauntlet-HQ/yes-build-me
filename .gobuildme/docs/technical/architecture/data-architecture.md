# Data Architecture

## Storage

- **Primary datastore**: SQLite file DB (local/dev)
- **Access**: Server-only via `better-sqlite3`
- **Performance setting**: WAL enabled (`journal_mode = WAL`)

## Schema Overview

Source of truth: `packages/database/schema.sql`

### Tables

#### `users`
| Column | Type | Notes |
|--------|------|------|
| `id` | INTEGER PK | autoincrement |
| `username` | TEXT | unique, required |
| `email` | TEXT | unique, required |
| `password_hash` | TEXT | bcrypt hash |
| `display_name` | TEXT | optional |
| `avatar_url` | TEXT | optional |
| `created_at` | DATETIME | default now |

#### `campaigns`
| Column | Type | Notes |
|--------|------|------|
| `id` | INTEGER PK | autoincrement |
| `user_id` | INTEGER FK | owner → `users.id` |
| `title` | TEXT | required |
| `description` | TEXT | required |
| `goal_amount` | REAL | required |
| `current_amount` | REAL | default 0 |
| `image_url` | TEXT | optional |
| `category` | TEXT | required |
| `status` | TEXT | default `active` |
| `created_at` | DATETIME | default now |
| `updated_at` | DATETIME | default now |

#### `donations`
| Column | Type | Notes |
|--------|------|------|
| `id` | INTEGER PK | autoincrement |
| `campaign_id` | INTEGER FK | target campaign |
| `user_id` | INTEGER FK | optional (guest donations allowed) |
| `amount` | REAL | required |
| `message` | TEXT | optional |
| `is_anonymous` | INTEGER | boolean-ish (0/1) |
| `donor_name` | TEXT | required for guest donations (by route policy) |
| `created_at` | DATETIME | default now |

## Indexes (for common queries)

Defined in `schema.sql`:
- `campaigns(user_id)`
- `campaigns(category)`
- `campaigns(status)`
- `donations(campaign_id)`
- `donations(user_id)`

## Data Flow (typical)

- Register/login:
  - create user → bcrypt hash stored in `users.password_hash` → JWT returned
- Browse campaigns:
  - query `campaigns` (pagination + search/filter in model layer)
- Donate:
  - insert into `donations` → update `campaigns.current_amount` (model responsibility)
- Dashboard:
  - query campaigns by user + donations by user → compute aggregate stats in route

