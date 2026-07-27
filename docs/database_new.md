# Database Structure

## Overview

The database is a **PostgreSQL** relational database. It stores all data related to musical projects, repertoire, participants, instruments, contacts, mailing, accounting, auditions, and recruitment managed through the Melomania application.

### Schema Access

- **Interactive schema:** 
<iframe width="560" height="315" src='https://dbdiagram.io/e/6a0c1da89f1f8ec47b4d081c/6a0c1dae697f99c167ad3e22'> </iframe>
- **Edit access:** Sign in to https://dbdiagram.io/d using `melomaniadevmail@gmail.com` (OTP sent to email, password: `melomania_devMail1`)
- **Based on:** Database dump from May 19, 2026 (`dump_19-5-2026.sql`)

### Schema Management

The database schema is managed via **AdonisJS Lucid** migrations located in `back/database/migrations/`. Always run migrations after pulling new changes:

```bash
node ace migration:run
```

---

## Tables

### `accounting_categories`

Stores accounting categories for project expenses and income (e.g. "Venue rental", "Musician fees", "Ticket sales").

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | varchar(255) | Category name (required) |
| `description` | text | Optional description |
| `is_default` | boolean | Whether this is a pre-created default category (default: false) |
| `color` | varchar(50) | Color code for UI display |
| `icon` | varchar(50) | Icon identifier for UI display |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Relations:**
- Referenced by `accounting_entries.category_id`

**Notes:**
- Categories are **global** to the application (no `project_id`) — a category created is visible in all projects
- This is the **new** accounting system; see also `expense_categories` (legacy)

---

### `accounting_entries`

Stores individual accounting transactions: invoices, payments, reimbursements, and income for projects.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `project_id` | integer (FK) | References `projects.id` (nullable) |
| `contact_id` | integer (FK) | References `contacts.id` (nullable) |
| `category_id` | integer (FK) | References `accounting_categories.id` (nullable) |
| `name` | varchar(255) | Transaction name (required) |
| `description` | text | Detailed description |
| `amount` | numeric(12,2) | Transaction amount (required, always positive) |
| `entry_type` | text | Type: `expense` or `income` (default: `expense`) |
| `payment_status` | text | Status: `pending`, `paid`, `overdue`, or `cancelled` (default: `pending`) |
| `bill_date` | date | Invoice/bill date |
| `payment_date` | date | Actual payment date |
| `due_date` | date | Payment deadline |
| `attachment` | varchar(255) | File path for attached document |
| `is_individual_payment` | boolean | Whether this is a payment to an individual (default: false) |
| `is_musician_fee` | boolean | Whether this is a musician payment (default: false) |
| `invoice_number` | varchar(255) | External invoice reference |
| `notes` | text | Internal notes |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Relations:**
- Belongs to `projects` (optional)
- Belongs to `contacts` (optional, for individual payments)
- Belongs to `accounting_categories` (optional)

**Notes:**
- Amount is stored unsigned; `entry_type` determines expense vs. income
- `is_musician_fee` and `is_individual_payment` are used for UI filtering

---

### `accounting_settings`

Stores project-specific accounting configuration (currency, payment terms, tax settings).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `project_id` | integer (FK) | References `projects.id` (unique constraint) |
| `currency` | varchar(10) | Currency code (default: `EUR`) |
| `auto_overdue_enabled` | boolean | Automatically mark overdue entries (default: true) |
| `default_payment_terms` | integer | Default payment delay in days (default: 30) |
| `tax_rate` | numeric(5,2) | Tax percentage (default: 20.00) |
| `enable_tax` | boolean | Whether tax is enabled (default: false) |
| `fiscal_year_start` | timestamp | Start of fiscal year |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Relations:**
- Belongs to `projects` (one settings block per project)

**Notes:**
- `project_id` has a unique constraint (one settings record per project)
- Not fully exposed in UI yet, but backend routes exist

---

### `adonis_schema`

**Internal AdonisJS table** — tracks migration history.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | varchar(255) | Migration file name |
| `batch` | integer | Batch number for rollback grouping |
| `migration_time` | timestamp | When migration was executed (default: now) |

**Notes:**
- **Do not modify manually** — managed by `node ace migration:run`
- Not part of Melomania business logic

---

### `adonis_schema_versions`

**Internal AdonisJS table** — tracks migration system version.

| Column | Type | Description |
|--------|------|-------------|
| `version` | integer (PK) | Schema version number |

**Notes:**
- **Do not modify manually** — managed by AdonisJS Lucid
- Not part of Melomania business logic

---

### `answers`

Stores participant responses to registration form questions.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `text` | text | The answer text (default: empty string) |
| `form_id` | integer (FK) | References `forms.id` (the question) |
| `participant_id` | integer (FK) | References `participants.id` (who answered) |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Relations:**
- Belongs to `forms` (the question being answered)
- Belongs to `participants` (who provided the answer)

**Notes:**
- Used in registration workflow when participants fill out custom forms

---

### `attached_to_callsheets`

**Pivot table** linking files to callsheets (file attachments).

| Column | Type | Description |
|--------|------|-------------|
| `file_id` | integer (FK, part of PK) | References `callsheets.id` ⚠️ |
| `callsheet_id` | integer (FK, part of PK) | References `files.id` ⚠️ |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Primary Key:** Composite (`file_id`, `callsheet_id`)

**Relations:**
- ⚠️ **Foreign keys are inverted** (known bug in migration):
  - `file_id` → `callsheets.id` (should be → `files.id`)
  - `callsheet_id` → `files.id` (should be → `callsheets.id`)

**Notes:**
- **Currently unused** in the UI
- The FK inversion is a known historical bug in the migration

---

### `attached_to_mail_templates`

**Pivot table** linking files to mail templates (email attachments).

| Column | Type | Description |
|--------|------|-------------|
| `file_id` | integer (FK, part of PK) | References `files.id` |
| `mail_template_id` | integer (FK, part of PK) | References `mail_templates.id` |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Primary Key:** Composite (`file_id`, `mail_template_id`)

**Relations:**
- Links `files` to `mail_templates`

---

### `audition_files`

Stores audio/video files uploaded by candidates for auditions.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `audition_id` | integer (FK) | References `auditions.id` (required) |
| `file_id` | integer (FK) | References `files.id` (required) |
| `file_type` | text | File type: `audio` or `video` (required) |
| `description` | varchar(500) | Optional description from candidate |
| `file_size` | bigint | File size in bytes |
| `duration_seconds` | integer | Media duration in seconds |
| `uploaded_at` | timestamp | When the file was uploaded (required) |
| `created_at` | timestamp | Record creation timestamp (required) |
| `updated_at` | timestamp | Last update timestamp (required) |

**Constraints:**
- `file_type` CHECK: must be `video` or `audio`

**Relations:**
- Belongs to `auditions`
- References `files` for actual file storage

**Notes:**
- Separate from generic `files` table to track audition-specific metadata (duration, upload time)

---

### `audition_pdf_files`

Stores PDF materials provided to audition candidates (scores, excerpts to perform), organized by section.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `audition_id` | integer (FK) | References `auditions.id` (required) |
| `file_id` | integer (FK) | References `files.id` (required) |
| `section_id` | integer (FK) | References `sections.id` (required) |
| `title` | varchar(255) | PDF title (required) |
| `description` | text | Optional description |
| `order` | integer | Display order (required, default: 0) |
| `downloaded_by_candidate` | boolean | Whether candidate downloaded it (default: false) |
| `first_downloaded_at` | timestamp | When candidate first downloaded |
| `download_count` | integer | Number of downloads (default: 0) |
| `created_at` | timestamp | Record creation timestamp (required) |
| `updated_at` | timestamp | Last update timestamp (required) |

**Relations:**
- Belongs to `auditions`
- References `files` for PDF storage
- Belongs to `sections` (instrument section)

**Notes:**
- Direction: **admin → candidate** (materials to prepare)
- Different from `audition_files` which are **candidate → admin** (submitted recordings)

---

### `auditions`

Stores audition requests sent to candidates for a specific project.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `participant_id` | integer (FK) | References `participants.id` (required) |
| `project_id` | integer (FK) | References `projects.id` (required) |
| `secure_token` | varchar(512) | Unique secure URL token (required, unique) |
| `instructions` | text | Instructions for the candidate |
| `required_files` | json | JSON structure defining required file types |
| `deadline` | timestamp | Submission deadline |
| `is_submitted` | boolean | Whether candidate submitted (required, default: false) |
| `submitted_at` | timestamp | Actual submission timestamp |
| `candidate_notes` | text | Notes from the candidate |
| `created_at` | timestamp | Record creation timestamp (required) |
| `updated_at` | timestamp | Last update timestamp (required) |

**Unique Constraint:** (`participant_id`, `project_id`) — one audition per candidate per project

**Relations:**
- Belongs to `participants` (the candidate)
- Belongs to `projects`
- Has many `audition_files` (submitted recordings)
- Has many `audition_pdf_files` (provided materials)

**Notes:**
- `secure_token` enables public access without login
- Workflow: created → candidate uploads files → marks as submitted

---

### `auth_access_tokens`

**Technical table** storing API authentication tokens for admin users.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `tokenable_id` | integer (FK) | References `users.id` (required) |
| `type` | varchar(255) | Token type (required) |
| `name` | varchar(255) | Token name/label |
| `hash` | varchar(255) | Hashed token value (required) |
| `abilities` | text | JSON permissions/abilities (required) |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |
| `last_used_at` | timestamp | Last time token was used |
| `expires_at` | timestamp | Token expiration date |

**Relations:**
- Belongs to `users`

**Notes:**
- **AdonisJS Auth** system table
- Tokens are stored hashed, never in plain text

---

### `callsheets`

Stores information sheets (call sheets) for projects, shared with all participants.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `version` | varchar(255) | Version label (e.g., "v1", "v2.1") |
| `project_id` | integer (FK) | References `projects.id` |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Relations:**
- Belongs to `projects`
- Has many `content_callsheets` (content blocks)
- Tracked by `seens` (which participants viewed it)

**Notes:**
- Callsheets are publicly accessible via unique URL
- `version` helps identify the latest version

---

### `composers`

Stores composers in the global repertoire database.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `short_name` | varchar(255) | Short name (e.g., "Bach") |
| `long_name` | varchar(255) | Full name (e.g., "Johann Sebastian Bach") |
| `birth_date` | date | Birth date |
| `death_date` | date | Death date (nullable for living composers) |
| `country` | varchar(255) | Country of origin |
| `main_style` | varchar(255) | Primary musical style/period |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Relations:**
- Referenced by `pieces.composer_id`

**Notes:**
- Uses `short_name`/`long_name` instead of `first_name`/`last_name` (design choice)

---

### `concerts`

Stores concerts (performance events) associated with projects.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `start_date` | timestamp | Concert start date/time |
| `comment` | text | Comments/notes (default: empty) |
| `project_id` | integer (FK) | References `projects.id` |
| `place` | varchar(255) | Venue/location |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |
| `end_date` | timestamp | Concert end date/time |

**Relations:**
- Belongs to `projects`
- Linked to participants via `participates_in_concerts` (attendance tracking)

**Notes:**
- A project can have multiple concerts
- Concert name comes from the parent project
- Time span: `start_date` → `end_date`

---

### `contacts`

**Global contact directory** storing all people: musicians, professionals, administrative contacts.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `first_name` | varchar(255) | First name (required) |
| `last_name` | varchar(255) | Last name (required) |
| `email` | varchar(255) | Email address (default: empty) |
| `phone` | varchar(255) | Phone number (default: empty) |
| `messenger` | varchar(255) | Messenger handle (default: empty) |
| `comments` | text | Internal notes (default: empty) |
| `validated` | boolean | Whether contact is validated (required, default: false) |
| `subscribed` | boolean | Whether subscribed to emails (required, default: true) |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Relations:**
- Referenced by `participants.contact_id` (contact becomes participant when joining a project)
- Linked to instruments via `plays` (instruments this contact plays)
- Can belong to multiple `lists` via `contacts_lists`

**Notes:**
- **Central directory** — single source of truth for contact info
- A contact becomes a `participant` when joining a project, avoiding data duplication

---

### `contacts_lists`

**Pivot table** linking contacts to mailing lists.

| Column | Type | Description |
|--------|------|-------------|
| `contact_id` | integer (FK, part of PK) | References `contacts.id` |
| `list_id` | integer (FK, part of PK) | References `lists.id` |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Primary Key:** Composite (`contact_id`, `list_id`)

**Relations:**
- Links `contacts` to `lists`

**Notes:**
- Used for targeted mailing and contact filtering (e.g., "Professional violinists", "Alumni 2024")

---

### `contains`

**Pivot table** linking files to folders (file system structure).

| Column | Type | Description |
|--------|------|-------------|
| `folder_id` | integer (FK, part of PK) | References `folders.id` |
| `file_id` | integer (FK, part of PK) | References `files.id` |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Primary Key:** Composite (`folder_id`, `file_id`)

**Relations:**
- Links `folders` to `files`

**Notes:**
- Enables many-to-many relationship (a file could theoretically appear in multiple folders)
- Coexists with `files.folder_id` FK (dual mechanism for historical reasons)

---

### `content_callsheets`

Stores content blocks (sections) for callsheets — modular title+text components.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `title` | varchar(255) | Block title/heading |
| `text` | text | Rich HTML content (default: empty) |
| `callsheet_id` | integer (FK) | References `callsheets.id` |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Relations:**
- Belongs to `callsheets`

**Notes:**
- A callsheet is composed of multiple content blocks
- Allows flexible page building (title+text repeated sections)

---

### `content_registrations`

Stores content blocks (sections) for registration pages — modular title+text components.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `title` | varchar(255) | Block title/heading |
| `text` | text | Rich HTML content (default: empty) |
| `registration_id` | integer (FK) | References `registrations.id` |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Relations:**
- Belongs to `registrations`

**Notes:**
- Same pattern as `content_callsheets` but for registration pages
- Enables modular registration form building

---

### `expense_categories`

**Legacy accounting categories** — predecessor to `accounting_categories`.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | varchar(255) | Category name (required, unique) |
| `description` | text | Optional description |
| `is_default` | boolean | Whether default category (required, default: false) |
| `color` | text | Color code for UI |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

**Notes:**
- **Legacy system** — being replaced by `accounting_categories`
- Still referenced by some older code and the deprecated `accounting.ts` model
- Migration to new system is incomplete
- 10 default categories in English exist in production

---

### `files`

**Central file storage table** — stores all files used across the application (scores, PDFs, uploads, documents).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | varchar(255) | File name (required) |
| `type` | varchar(255) | MIME type or file extension |
| `content` | text | Inline file content for small files (default: empty) |
| `path` | varchar(255) | File path on disk/storage |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |
| `size` | bigint | File size in bytes |
| `folder_id` | integer (FK) | References `folders.id` (nullable) |
| `project_id` | integer (FK) | References `projects.id` (nullable) |
| `piece_id` | integer (FK) | References `pieces.id` (nullable) |
| `material_id` | integer (FK) | References `materials.id` (nullable) |
| `instrument_part` | varchar(255) | Instrument part label (e.g., "Violin I") |
| `part_order` | integer | Order of parts (default: 0) |

**Relations:**
- Belongs to `folders` (file system hierarchy)
- Can belong to `projects` (project-specific files)
- Can belong to `pieces` (score/repertoire files)
- Can belong to `materials` (specific edition/material files)
- Referenced by many pivot tables: `contains`, `attached_to_callsheets`, `attached_to_mail_templates`, `audition_files`, `audition_pdf_files`, `section_pdfs`

**Notes:**
- **Highly polymorphic** — can be linked to multiple contexts
- Storage options: inline (`content`) or filesystem (`path`)
- `instrument_part` + `part_order` organize parts within scores

---

## Relationships Summary

This section documents all the tables covered above (`accounting_categories` through `files`).

### Accounting Domain

| From | Relation | To | Notes |
|------|----------|-----|-------|
| `accounting_entries` | belongs to | `projects` | Optional FK |
| `accounting_entries` | belongs to | `contacts` | Optional FK |
| `accounting_entries` | belongs to | `accounting_categories` | Optional FK |
| `accounting_settings` | belongs to | `projects` | One settings per project (unique constraint) |

### Registration & Forms

| From | Relation | To | Notes |
|------|----------|-----|-------|
| `answers` | belongs to | `forms` | The question |
| `answers` | belongs to | `participants` | Who answered |
| `content_registrations` | belongs to | `registrations` | Content blocks |

### Callsheets

| From | Relation | To | Notes |
|------|----------|-----|-------|
| `callsheets` | belongs to | `projects` | |
| `content_callsheets` | belongs to | `callsheets` | Content blocks |
| `attached_to_callsheets` | pivot | `files` ↔ `callsheets` | ⚠️ FK inverted (bug) |

### Mailing

| From | Relation | To | Notes |
|------|----------|-----|-------|
| `attached_to_mail_templates` | pivot | `files` ↔ `mail_templates` | |

### Auditions

| From | Relation | To | Notes |
|------|----------|-----|-------|
| `auditions` | belongs to | `participants` | |
| `auditions` | belongs to | `projects` | Unique per participant+project |
| `audition_files` | belongs to | `auditions` | |
| `audition_files` | references | `files` | |
| `audition_pdf_files` | belongs to | `auditions` | |
| `audition_pdf_files` | references | `files` | |
| `audition_pdf_files` | belongs to | `sections` | |

### Authentication

| From | Relation | To | Notes |
|------|----------|-----|-------|
| `auth_access_tokens` | belongs to | `users` | |

### Repertoire

| From | Relation | To | Notes |
|------|----------|-----|-------|
| `pieces` (not in this section) | references | `composers` | |

### Projects & Events

| From | Relation | To | Notes |
|------|----------|-----|-------|
| `concerts` | belongs to | `projects` | |

### Contacts

| From | Relation | To | Notes |
|------|----------|-----|-------|
| `participants` (not in this section) | references | `contacts` | Contact becomes participant |
| `plays` (not in this section) | links | `contacts` ↔ `instruments` | Pivot table |
| `contacts_lists` | pivot | `contacts` ↔ `lists` | |

### Files & Folders

| From | Relation | To | Notes |
|------|----------|-----|-------|
| `files` | belongs to | `folders` | Optional FK |
| `files` | belongs to | `projects` | Optional FK |
| `files` | belongs to | `pieces` | Optional FK |
| `files` | belongs to | `materials` | Optional FK |
| `contains` | pivot | `folders` ↔ `files` | |

---

## Notes

### Legacy & Migration

- **`expense_categories`** is the old accounting system, gradually being replaced by `accounting_categories`
- Migration is incomplete; some code still references `expense_categories`

### Known Issues

- **`attached_to_callsheets`** has inverted foreign keys (migration bug) — currently unused in UI

### Technical Tables

- **`adonis_schema`** and **`adonis_schema_versions`** are AdonisJS internal tables for migration tracking
- **`auth_access_tokens`** is the AdonisJS Auth token storage system

### Data Model Architecture

Melomania's core structure:

```
contacts (global directory)
    ↓
participants (when contact joins a project)
    ↓
projects → concerts, rehearsals, callsheets, accounting, auditions
    ↓
pieces (repertoire) ← composers
    ↓
files (scores, documents) ← folders
```

---

*This documentation covers tables from `accounting_categories` through `files`. Tables from `folders` onward are documented in the next section.*


---

## Multi-Tenant Architecture (Added July 2026)

A multi-tenant architecture has been implemented using the shared schema approach. All organizations share the same database tables, but tenant-specific tables now have an `organization_id` column.

### New Table: `organizations`

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | varchar(255) | Organization name (unique, required) |
| `created_at` | timestamp | Record creation timestamp |
| `updated_at` | timestamp | Last update timestamp |

### Tables with `organization_id` added

The following tables now have an `organization_id` foreign key referencing `organizations.id` (nullable, SET NULL on delete):

- `users`
- `contacts`
- `projects`
- `lists`
- `mail_templates`
- `files`
- `folders`
- `section_groups`
- `pieces`
- `forms`
- `outgoing_mails`
- `accounting_categories`
- `accounting_settings`
- `accounting_entries`
- `recruitment_settings`

### Shared Global Tables (no `organization_id`)

- `composers`, `instruments`, `type_of_pieces` — shared reference data
- `callsheets`, `participants`, `concerts`, `rehearsals`, `recruitment_contacts` — inherit tenant isolation through their parent `project`

For full details see the [Multi-Tenant Architecture technical documentation](../Technical%20documentation/multi_tenant_architecture.md).

---