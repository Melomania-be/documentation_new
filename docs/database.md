# Database Structure

## Overview

PostgreSQL relational database storing all Melomania data: projects, repertoire, participants, instruments, contacts, mailing, accounting, auditions, recruitment.

### Schema Access

- **Interactive schema:** 
<iframe width="560" height="315" src='https://dbdiagram.io/e/6a0c1da89f1f8ec47b4d081c/6a0c1dae697f99c167ad3e22'> </iframe>
- **Edit access:** [https://dbdiagram.io/d] (sign in with `melomaniadevmail@gmail.com`, OTP sent to email, password: `melomania_devMail1`)

Based on database dump from May 19, 2026 (`dump_19-5-2026.sql`). This file can be found in the static/files folder of the documentation repository.

### Schema Management

Schema managed via AdonisJS Lucid migrations in `back/database/migrations/`.

Run migrations after pulling:
```bash
node ace migration:run
```

---

## Tables

### `accounting_categories`

Stores accounting categories for expenses and income (e.g. "Venue rental", "Musician fees", "Ticket sales").

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | varchar(255) | Category name (required) |
| `description` | text | Optional description |
| `is_default` | boolean | Pre-created default category (default: false) |
| `color` | varchar(50) | Color code for UI |
| `icon` | varchar(50) | Icon identifier for UI |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Referenced by `accounting_entries.category_id`

**Notes:**
- Global to application (no `project_id`)
- New accounting system; see `expense_categories` (legacy)

---

### `accounting_entries`

Individual accounting transactions: invoices, payments, reimbursements, income.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `project_id` | integer (FK) | References `projects.id` (nullable) |
| `contact_id` | integer (FK) | References `contacts.id` (nullable) |
| `category_id` | integer (FK) | References `accounting_categories.id` (nullable) |
| `name` | varchar(255) | Transaction name (required) |
| `description` | text | Detailed description |
| `amount` | numeric(12,2) | Transaction amount (required, always positive) |
| `entry_type` | text | `expense` or `income` (default: `expense`) |
| `payment_status` | text | `pending`, `paid`, `overdue`, `cancelled` (default: `pending`) |
| `bill_date` | date | Invoice/bill date |
| `payment_date` | date | Actual payment date |
| `due_date` | date | Payment deadline |
| `attachment` | varchar(255) | File path for attached document |
| `is_individual_payment` | boolean | Payment to individual (default: false) |
| `is_musician_fee` | boolean | Musician payment (default: false) |
| `invoice_number` | varchar(255) | External invoice reference |
| `notes` | text | Internal notes |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects` (optional)
- Belongs to `contacts` (optional, for individual payments)
- Belongs to `accounting_categories` (optional)

**Notes:**
- Amount stored unsigned; `entry_type` determines expense vs income
- `is_musician_fee` and `is_individual_payment` used for UI filtering

---

### `accounting_settings`

Project-specific accounting configuration (currency, payment terms, tax).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `project_id` | integer (FK) | References `projects.id` (unique constraint) |
| `currency` | varchar(10) | Currency code (default: `EUR`) |
| `auto_overdue_enabled` | boolean | Auto-mark overdue entries (default: true) |
| `default_payment_terms` | integer | Default payment delay in days (default: 30) |
| `tax_rate` | numeric(5,2) | Tax percentage (default: 20.00) |
| `enable_tax` | boolean | Tax enabled (default: false) |
| `fiscal_year_start` | timestamp | Start of fiscal year |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects` (one per project)

**Notes:**
- `project_id` unique constraint (one settings record per project)
- Not fully exposed in UI yet, backend routes exist

---

### `adonis_schema`

Internal AdonisJS table tracking migration history.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | varchar(255) | Migration file name |
| `batch` | integer | Batch number for rollback |
| `migration_time` | timestamp | When migration executed (default: now) |

**Notes:**
- Do not modify manually (managed by `node ace migration:run`)
- Not part of Melomania business logic

---

### `adonis_schema_versions`

Internal AdonisJS table tracking migration system version.

| Column | Type | Description |
|--------|------|-------------|
| `version` | integer (PK) | Schema version number |

**Notes:**
- Do not modify manually (managed by AdonisJS Lucid)
- Not part of Melomania business logic

---

### `answers`

Participant responses to registration form questions.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `text` | text | Answer text (default: empty) |
| `form_id` | integer (FK) | References `forms.id` (question) |
| `participant_id` | integer (FK) | References `participants.id` (who answered) |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `forms` (question)
- Belongs to `participants` (who answered)

**Notes:**
- Used in registration workflow when participants fill custom forms

---

### `attached_to_callsheets`

Pivot table linking files to callsheets.

| Column | Type | Description |
|--------|------|-------------|
| `file_id` | integer (FK, part of PK) | References `callsheets.id` (bug) |
| `callsheet_id` | integer (FK, part of PK) | References `files.id` (bug) |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Primary Key:** Composite (`file_id`, `callsheet_id`)

**Relations:**
- Foreign keys inverted (known migration bug):
  - `file_id` should reference `files.id`
  - `callsheet_id` should reference `callsheets.id`

**Notes:**
- Currently unused in UI
- FK inversion is historical bug

---

### `attached_to_mail_templates`

Pivot table linking files to mail templates.

| Column | Type | Description |
|--------|------|-------------|
| `file_id` | integer (FK, part of PK) | References `files.id` |
| `mail_template_id` | integer (FK, part of PK) | References `mail_templates.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Primary Key:** Composite (`file_id`, `mail_template_id`)

**Relations:**
- Links `files` to `mail_templates`

---

### `audition_files`

Audio/video files uploaded by audition candidates.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `audition_id` | integer (FK) | References `auditions.id` (required) |
| `file_id` | integer (FK) | References `files.id` (required) |
| `file_type` | text | `audio` or `video` (required) |
| `description` | varchar(500) | Optional description |
| `file_size` | bigint | File size in bytes |
| `duration_seconds` | integer | Media duration |
| `uploaded_at` | timestamp | Upload timestamp (required) |
| `created_at` | timestamp | Record creation (required) |
| `updated_at` | timestamp | Last update (required) |

**Constraints:**
- `file_type` CHECK: must be `video` or `audio`

**Relations:**
- Belongs to `auditions`
- References `files` for storage

**Notes:**
- Separate from generic `files` for audition-specific metadata (duration, upload time)

---

### `audition_pdf_files`

PDF materials provided to audition candidates (scores, excerpts), organized by section.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `audition_id` | integer (FK) | References `auditions.id` (required) |
| `file_id` | integer (FK) | References `files.id` (required) |
| `section_id` | integer (FK) | References `sections.id` (required) |
| `title` | varchar(255) | PDF title (required) |
| `description` | text | Optional description |
| `order` | integer | Display order (required, default: 0) |
| `downloaded_by_candidate` | boolean | Candidate downloaded (default: false) |
| `first_downloaded_at` | timestamp | First download timestamp |
| `download_count` | integer | Download count (default: 0) |
| `created_at` | timestamp | Record creation (required) |
| `updated_at` | timestamp | Last update (required) |

**Relations:**
- Belongs to `auditions`
- References `files` for PDF storage
- Belongs to `sections`

**Notes:**
- Direction: admin to candidate (materials to prepare)
- Different from `audition_files` (candidate to admin, submitted recordings)

---

### `auditions`

Audition requests sent to candidates for projects.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `participant_id` | integer (FK) | References `participants.id` (required) |
| `project_id` | integer (FK) | References `projects.id` (required) |
| `secure_token` | varchar(512) | Unique secure URL token (required, unique) |
| `instructions` | text | Instructions for candidate |
| `required_files` | json | JSON defining required file types |
| `deadline` | timestamp | Submission deadline |
| `is_submitted` | boolean | Candidate submitted (required, default: false) |
| `submitted_at` | timestamp | Submission timestamp |
| `candidate_notes` | text | Notes from candidate |
| `created_at` | timestamp | Record creation (required) |
| `updated_at` | timestamp | Last update (required) |

**Unique Constraint:** (`participant_id`, `project_id`) - one audition per candidate per project

**Relations:**
- Belongs to `participants` (candidate)
- Belongs to `projects`
- Has many `audition_files` (submitted recordings)
- Has many `audition_pdf_files` (provided materials)

**Notes:**
- `secure_token` enables public access without login
- Workflow: created, candidate uploads, marks submitted

---

### `auth_access_tokens`

API authentication tokens for admin users.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `tokenable_id` | integer (FK) | References `users.id` (required) |
| `type` | varchar(255) | Token type (required) |
| `name` | varchar(255) | Token name/label |
| `hash` | varchar(255) | Hashed token (required) |
| `abilities` | text | JSON permissions (required) |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |
| `last_used_at` | timestamp | Last use timestamp |
| `expires_at` | timestamp | Token expiration |

**Relations:**
- Belongs to `users`

**Notes:**
- AdonisJS Auth system table
- Tokens stored hashed, never plain text

---

### `callsheets`

Information sheets (call sheets) for projects, shared with participants.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `version` | varchar(255) | Version label (e.g. "v1", "v2.1") |
| `project_id` | integer (FK) | References `projects.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects`
- Has many `content_callsheets` (content blocks)
- Tracked by `seens` (participant views)

**Notes:**
- Publicly accessible via unique URL
- `version` identifies latest version

---

### `composers`

Composers in the global repertoire database.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `short_name` | varchar(255) | Short name (e.g. "Bach") |
| `long_name` | varchar(255) | Full name (e.g. "Johann Sebastian Bach") |
| `birth_date` | date | Birth date |
| `death_date` | date | Death date (nullable) |
| `country` | varchar(255) | Country of origin |
| `main_style` | varchar(255) | Primary musical style/period |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Referenced by `pieces.composer_id`

**Notes:**
- Uses `short_name`/`long_name` (not `first_name`/`last_name`)

---

### `concerts`

Concerts (performance events) associated with projects.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `start_date` | timestamp | Concert start date/time |
| `comment` | text | Comments/notes (default: empty) |
| `project_id` | integer (FK) | References `projects.id` |
| `place` | varchar(255) | Venue/location |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |
| `end_date` | timestamp | Concert end date/time |

**Relations:**
- Belongs to `projects`
- Linked to participants via `participates_in_concerts` (attendance)

**Notes:**
- Project can have multiple concerts
- Concert name from parent project
- Time span: `start_date` to `end_date`

---

### `contacts`

Global contact directory: musicians, professionals, admin contacts.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `first_name` | varchar(255) | First name (required) |
| `last_name` | varchar(255) | Last name (required) |
| `email` | varchar(255) | Email (default: empty) |
| `phone` | varchar(255) | Phone (default: empty) |
| `messenger` | varchar(255) | Messenger handle (default: empty) |
| `comments` | text | Internal notes (default: empty) |
| `validated` | boolean | Contact validated (required, default: false) |
| `subscribed` | boolean | Subscribed to emails (required, default: true) |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Referenced by `participants.contact_id` (contact becomes participant when joining project)
- Linked to instruments via `plays`
- Can belong to multiple `lists` via `contacts_lists`

**Notes:**
- Central directory, single source of truth for contact info
- Contact becomes `participant` when joining project (avoids duplication)

---

### `contacts_lists`

Pivot table linking contacts to mailing lists.

| Column | Type | Description |
|--------|------|-------------|
| `contact_id` | integer (FK, part of PK) | References `contacts.id` |
| `list_id` | integer (FK, part of PK) | References `lists.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Primary Key:** Composite (`contact_id`, `list_id`)

**Relations:**
- Links `contacts` to `lists`

**Notes:**
- Used for targeted mailing and contact filtering (e.g. "Professional violinists", "Alumni 2024")

---

### `contains`

Pivot table linking files to folders (file system structure).

| Column | Type | Description |
|--------|------|-------------|
| `folder_id` | integer (FK, part of PK) | References `folders.id` |
| `file_id` | integer (FK, part of PK) | References `files.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Primary Key:** Composite (`folder_id`, `file_id`)

**Relations:**
- Links `folders` to `files`

**Notes:**
- Enables many-to-many (file could appear in multiple folders)
- Coexists with `files.folder_id` FK (dual mechanism, historical)

---

### `content_callsheets`

Content blocks (sections) for callsheets - modular title+text components.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `title` | varchar(255) | Block title/heading |
| `text` | text | Rich HTML content (default: empty) |
| `callsheet_id` | integer (FK) | References `callsheets.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `callsheets`

**Notes:**
- Callsheet composed of multiple content blocks
- Flexible page building (repeating title+text sections)

---

### `content_registrations`

Content blocks (sections) for registration pages - modular title+text components.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `title` | varchar(255) | Block title/heading |
| `text` | text | Rich HTML content (default: empty) |
| `registration_id` | integer (FK) | References `registrations.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `registrations`

**Notes:**
- Same pattern as `content_callsheets` for registration pages
- Enables modular registration form building

---

### `expense_categories`

Legacy accounting categories (predecessor to `accounting_categories`).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | varchar(255) | Category name (required, unique) |
| `description` | text | Optional description |
| `is_default` | boolean | Default category (required, default: false) |
| `color` | text | Color code for UI |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Notes:**
- Legacy system being replaced by `accounting_categories`
- Still referenced by older code and deprecated `accounting.ts` model
- Migration to new system incomplete
- 10 default categories in English exist in production

---

### `files`

Central file storage - all files used in application (scores, PDFs, uploads, documents).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | varchar(255) | File name (required) |
| `type` | varchar(255) | MIME type or file extension |
| `content` | text | Inline file content for small files (default: empty) |
| `path` | varchar(255) | File path on disk/storage |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |
| `size` | bigint | File size in bytes |
| `folder_id` | integer (FK) | References `folders.id` (nullable) |
| `project_id` | integer (FK) | References `projects.id` (nullable) |
| `piece_id` | integer (FK) | References `pieces.id` (nullable) |
| `material_id` | integer (FK) | References `materials.id` (nullable) |
| `instrument_part` | varchar(255) | Instrument part label (e.g. "Violin I") |
| `part_order` | integer | Order of parts (default: 0) |

**Relations:**
- Belongs to `folders` (file system hierarchy)
- Can belong to `projects` (project-specific files)
- Can belong to `pieces` (score/repertoire files)
- Can belong to `materials` (specific edition/material files)
- Referenced by many pivot tables: `contains`, `attached_to_callsheets`, `attached_to_mail_templates`, `audition_files`, `audition_pdf_files`, `section_pdfs`

**Notes:**
- Highly polymorphic (linked to multiple contexts)
- Storage: inline (`content`) or filesystem (`path`)
- `instrument_part` + `part_order` organize parts within scores

---

### `folders`

Folder structure for organizing files. Folders can be nested and linked to project or piece.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | string | Folder name |
| `parent_id` | integer (FK) | References `folders.id` (parent folder, if any) |
| `project_id` | integer (FK) | References `projects.id` |
| `piece_id` | integer (FK) | References `pieces.id` |
| `is_system_generated` | boolean | Auto-created by system |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects`
- Belongs to `pieces`
- Can be nested inside another `folders` via `parent_id` (self-referencing)

---

### `forms`

Individual form fields or responses linked to registration.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `text` | text | Content or answer of field |
| `type` | string | Type of form field |
| `registration_id` | integer (FK) | References `registrations.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `registrations`

---

### `instruments`

Musical instruments used by contacts and participants.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | string | Instrument name |
| `family` | string | Instrument family (e.g. Strings, Brass) |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Linked to `contacts` via `plays`
- Linked to `sections` via `played_in_sections`
- Linked to `recommendeds` via `recommendeds_instruments`

---

### `lists`

Named lists for organizational purposes.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | string | List name |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

---

### `mail_templates`

Reusable email templates (recruitment, registration, etc.).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | string | Template name |
| `content` | text | HTML or text content |
| `is_default` | boolean | Default template |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Referenced by `outgoing_mails` via `mail_template_id`

---

### `materials`

Different editions or versions of musical piece (sheet music, parts, etc.).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `piece_id` | integer (FK) | References `pieces.id` |
| `name` | string | Material/edition name |
| `description` | text | Optional description |
| `edition` | string | Edition name or number |
| `editor` | string | Editor/publisher name |
| `notes` | text | Additional notes |
| `is_default` | boolean | Default material |
| `is_active` | boolean | Currently active |
| `files_count` | integer | Files attached to material |
| `projects_count` | integer | Projects using material |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `pieces`
- Referenced by `performed_ins` via `material_id`

---

### `outgoing_mails`

Logs all outgoing emails (recruitment, registration, etc.).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `type` | string | Email type/category |
| `receiver_id` | integer (FK) | References `contacts.id` (recipient) |
| `project_id` | integer (FK) | References `projects.id` |
| `mail_template_id` | integer (FK) | References `mail_templates.id` |
| `sent` | boolean | Email sent successfully |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `mail_templates`
- Belongs to `projects`
- Targets one `contacts` as receiver

---

### `participants`

Musicians participating in specific project. Each linked to contact (identity) and section.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `project_id` | integer (FK) | References `projects.id` |
| `contact_id` | integer (FK) | References `contacts.id` |
| `section_id` | integer (FK) | References `sections.id` |
| `accepted` | boolean | Participant accepted |
| `last_activity` | timestamp | Last activity date |
| `is_section_leader` | boolean | Section leader |
| `audition_status` | text | Status: none, pending, completed, expired |
| `audition_requested_at` | timestamp | Audition request timestamp |
| `audition_deadline` | timestamp | Audition deadline |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects`
- Belongs to `contacts`
- Belongs to `sections`
- Linked to `rehearsals` via `participates_ins`
- Linked to concerts via `participates_in_concerts`

---

### `participates_in_concerts`

Junction table: which participants take part in which concerts.

| Column | Type | Description |
|--------|------|-------------|
| `participant_id` | integer (PK, FK) | References `participants.id` |
| `concert_id` | integer (PK, FK) | References concert/callsheet |
| `comment` | text | Optional comment |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `participants`
- Belongs to concert/callsheet

---

### `participates_ins`

Junction table: which participants attend which rehearsals.

| Column | Type | Description |
|--------|------|-------------|
| `rehearsal_id` | integer (PK, FK) | References `rehearsals.id` |
| `participant_id` | integer (PK, FK) | References `participants.id` |
| `comment` | text | Optional attendance comment |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `rehearsals`
- Belongs to `participants`

---

### `performed_ins`

Junction table linking pieces to projects, with ordering and material selection.

| Column | Type | Description |
|--------|------|-------------|
| `project_id` | integer (PK, FK) | References `projects.id` |
| `piece_id` | integer (PK, FK) | References `pieces.id` |
| `order` | integer | Performance order within project |
| `material_id` | integer (FK) | References `materials.id` |
| `material_specified` | boolean | Specific material chosen |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects`
- Belongs to `pieces`
- Belongs to `materials`

---

### `pieces`

Musical pieces in application's repertoire.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | string | Piece title |
| `opus` | string | Opus number |
| `year_of_composition` | string | Year composed |
| `composer_id` | integer (FK) | References `composers.id` |
| `type_of_piece_id` | integer (FK) | References `type_of_pieces.id` |
| `folder_id` | integer (FK) | References `folders.id` |
| `arranger` | string | Arranger name if applicable |
| `selected_material_id` | integer (FK) | References `materials.id` (default material) |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `type_of_pieces`
- Belongs to composer via `composers`
- Belongs to `folders`
- Has many `materials`
- Linked to `projects` via `performed_ins`

---

### `played_in_sections`

Junction table linking instruments to sections.

| Column | Type | Description |
|--------|------|-------------|
| `section_id` | integer (PK, FK) | References `sections.id` |
| `instrument_id` | integer (PK, FK) | References `instruments.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `sections`
- Belongs to `instruments`

---

### `plays`

Links contact to instrument(s) they play, with proficiency level.

| Column | Type | Description |
|--------|------|-------------|
| `contact_id` | integer (PK, FK) | References `contacts.id` |
| `instrument_id` | integer (PK, FK) | References `instruments.id` |
| `proficiency_level` | string | Proficiency level (default: unknown) |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `contacts`
- Belongs to `instruments`

---

### `projects`

Musical projects managed in application (concerts, seasons, etc.).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | string | Project name |
| `section_group_id` | integer (FK) | References `section_groups.id` |
| `folder_id` | integer (FK) | References `folders.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `section_groups`
- Belongs to `folders`
- Has many `participants`
- Has many `rehearsals`
- Linked to `pieces` via `performed_ins`
- Linked to `contacts` via `responsibles`
- Has one `registrations`
- Has one `recruitment_settings`

---

### `recommendeds`

People recommended by existing members as potential recruits, before full recruitment record created.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `first_name` | string | Recommended person first name |
| `last_name` | string | Recommended person last name |
| `email` | string | Email address |
| `phone` | string | Phone number |
| `messenger` | string | Messenger contact |
| `comment` | text | Optional comment from recommender |
| `project_id` | integer (FK) | References `projects.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects`
- Linked to `instruments` via `recommendeds_instruments`

---

### `recommendeds_instruments`

Junction table linking recommended people to instruments they play.

| Column | Type | Description |
|--------|------|-------------|
| `recommended_id` | integer (PK, FK) | References `recommendeds.id` |
| `instrument_id` | integer (PK, FK) | References `instruments.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `recommendeds`
- Belongs to `instruments`

---

### `recruitment_contacts`

Full recruitment pipeline for project. Each record is person being actively recruited, with status and follow-up tracking.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `project_id` | integer (FK) | References `projects.id` |
| `contact_id` | integer (FK) | References `contacts.id` (if in system) |
| `first_name` | string | First name |
| `last_name` | string | Last name |
| `email` | string | Email address |
| `phone` | string | Phone number |
| `messenger` | string | Messenger contact |
| `section_id` | integer (FK) | References `sections.id` (target section) |
| `status` | text | not_yet_contacted, awaiting_response, to_follow_up, not_available, pending_validation, cancelled, recruited |
| `contact_method` | text | How contacted: manual, email, messenger, phone |
| `contact_date` | timestamp | First contact date |
| `last_follow_up` | timestamp | Last follow-up date |
| `notes` | text | Internal notes |
| `recommended_by` | string | Recommender name |
| `recommender_contact_id` | integer (FK) | References `contacts.id` (recommender) |
| `is_duplicate` | boolean | Flagged as duplicate |
| `source` | string | How entered pipeline |
| `contacted_by` | string | Who made contact |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects`
- Belongs to `contacts`
- Belongs to `sections`

---

### `recruitment_recommendations`

External recommendations submitted via form, before processed into `recruitment_contacts`.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `project_id` | integer (FK) | References `projects.id` |
| `recommender_name` | string | Recommender name |
| `recommender_email` | string | Recommender email |
| `recommended_first_name` | string | Recommended person first name |
| `recommended_last_name` | string | Recommended person last name |
| `recommended_email` | string | Recommended person email |
| `recommended_phone` | string | Recommended person phone |
| `recommended_messenger` | string | Messenger contact |
| `recommended_instrument` | string | Instrument played |
| `recommendation_message` | text | Recommender message |
| `status` | text | pending, ignored, contacted_email, contacted_manual |
| `recruitment_contact_id` | integer (FK) | References `recruitment_contacts.id` once processed |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects`
- Resolved into `recruitment_contacts`

---

### `recruitment_settings`

Per-project configuration for recruitment module.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `project_id` | integer (FK) | References `projects.id` (unique per project) |
| `follow_up_days` | integer | Days before follow-up triggered |
| `auto_follow_up_enabled` | boolean | Auto follow-ups enabled |
| `auto_import_enabled` | boolean | Auto import recommendations enabled |
| `last_auto_import` | timestamp | Last auto import date |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects` (one-to-one)

---

### `registrations`

Registration form associated with project, for onboarding new participants.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `project_id` | integer (FK) | References `projects.id` |
| `last_send_date` | timestamp | Registration last sent date |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects`
- Has many `forms`

---

### `rehearsals`

Rehearsal sessions associated with project.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `project_id` | integer (FK) | References `projects.id` |
| `start_date` | timestamp | Rehearsal start date/time |
| `end_date` | timestamp | Rehearsal end date/time |
| `place` | string | Rehearsal location |
| `comment` | text | Optional comment |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects`
- Linked to `participants` via `participates_ins`

---

### `responsibles`

Links contacts to projects they are responsible for (project managers, conductors, etc.).

| Column | Type | Description |
|--------|------|-------------|
| `project_id` | integer (PK, FK) | References `projects.id` |
| `contact_id` | integer (PK, FK) | References `contacts.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects`
- Belongs to `contacts`

---

### `saves`

Application-level key-value settings and configuration variables.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `variable` | string | Setting/variable name |
| `value` | string | Setting value |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

---

### `section_groups`

Groups multiple sections together (e.g. "Orchestra", "Choir").

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | string | Group name |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Referenced by `projects` via `section_group_id`
- Linked to `sections` via `section_section_groups`

---

### `section_pdfs`

PDF files assigned to section within project (e.g. sheet music parts for auditions).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `project_id` | integer (FK) | References `projects.id` |
| `section_id` | integer (FK) | References `sections.id` |
| `file_id` | integer (FK) | References file |
| `title` | string | PDF title |
| `description` | text | Optional description |
| `order` | integer | Display order |
| `is_required` | boolean | PDF required for section |
| `is_active` | boolean | PDF currently active |
| `auditions_count` | integer | Auditions linked to PDF |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `projects`
- Belongs to `sections`

---

### `section_section_groups`

Junction table linking sections to section groups, with ordering.

| Column | Type | Description |
|--------|------|-------------|
| `section_id` | integer (PK, FK) | References `sections.id` |
| `section_group_id` | integer (PK, FK) | References `section_groups.id` |
| `order` | integer | Display order within group |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `sections`
- Belongs to `section_groups`

---

### `sections`

Orchestra or ensemble sections (e.g. Strings, Brass, Woodwinds, Percussion).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | string | Section name |
| `size` | integer | Expected number of musicians |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Linked to `section_groups` via `section_section_groups`
- Linked to `instruments` via `played_in_sections`
- Referenced by `participants` via `section_id`
- Referenced by `recruitment_contacts` via `section_id`
- Referenced by `section_pdfs` via `section_id`

---

### `seens`

Tracks which participants have seen given callsheet.

| Column | Type | Description |
|--------|------|-------------|
| `callsheet_id` | integer (PK, FK) | References callsheet |
| `participant_id` | integer (PK, FK) | References `participants.id` |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `participants`
- Belongs to callsheet

---

### `shared_folders`

Public sharing links for folders, allowing external access via unique token.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `folder_id` | integer (FK) | References `folders.id` |
| `token` | string | Unique public access token |
| `view_count` | integer | Link access count |
| `is_active` | boolean | Share link active |
| `expires_at` | timestamp | Share link expiry date |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Belongs to `folders`

---

### `type_of_pieces`

Categories of musical pieces (e.g. Symphony, Concerto, Sonata).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `name` | string | Type name (unique) |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

**Relations:**
- Referenced by `pieces` via `type_of_piece_id`

---

### `users`

Application's authenticated users (administrators).

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Unique identifier |
| `full_name` | string | User full name |
| `email` | string | Unique email address |
| `password` | string | Hashed password |
| `created_at` | timestamp | Record creation |
| `updated_at` | timestamp | Last update |

---

## Notes

Schema managed via AdonisJS Lucid migrations in `back/database/migrations/`. Run `node ace migration:run` after pulling.

Legacy Python migration script in `database/migrationScript/` (historical reference only).

**Legacy:**
- `expense_categories` is old accounting system, being replaced by `accounting_categories`
- Migration incomplete, some code still references `expense_categories`

**Known Issues:**
- `attached_to_callsheets` has inverted foreign keys (migration bug), currently unused in UI

**Technical Tables:**
- `adonis_schema` and `adonis_schema_versions` are AdonisJS internal migration tracking
- `auth_access_tokens` is AdonisJS Auth token storage

**Architecture:**
```
contacts (global directory)
  ↓
participants (when contact joins project)
  ↓
projects -> concerts, rehearsals, callsheets, accounting, auditions
  ↓
pieces (repertoire) <- composers
  ↓
files (scores, documents) <- folders
```
