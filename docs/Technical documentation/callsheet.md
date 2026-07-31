# TD - Callsheet Feature

*Edited by Naomi*

## Overview

The Callsheet feature allows project managers to create and share information pages with all participants of a project. Each callsheet has a version label, a set of custom content blocks, and is publicly accessible via a unique link sent to participants. The app also tracks which participants have opened the latest callsheet.

---

## Architecture

The feature is split across the frontend (Svelte) and backend (AdonisJS):

### Frontend Routes

| Route | File | Description |
|-------|------|-------------|
| `/projects/[id]/management/callsheets` | `src/routes/projects/[id]/management/callsheets/+page.svelte` | List of all callsheets for a project |
| `/projects/[id]/management/callsheets/creation` | `src/routes/projects/[id]/management/callsheets/creation/+page.svelte` | Create a new callsheet |
| `/projects/[id]/management/callsheets/[callsheetId]/creation` | `src/routes/projects/[id]/management/callsheets/[callsheetId]/creation/+page.svelte` | Edit an existing callsheet (also used to copy from last one) |
| `/call_sheets/[id]/[visitorId]` | `src/routes/call_sheets/[id]/[visitorId]/+page.svelte` | Public callsheet page seen by participants |

### Backend

| File | Description |
|------|-------------|
| `app/controllers/callsheets_controller.ts` | Handles all API requests for callsheets |
| `app/models/callsheet.ts` | Callsheet database model |
| `app/models/content_callsheet.ts` | Content block database model |
| `app/validators/callsheet.ts` | Input validation for creating/updating callsheets |

### API Endpoints

All callsheet endpoints are prefixed with `/api` and require authentication except the public callsheet page:

| Method | Endpoint | Controller Method | Description |
|--------|----------|-------------------|-------------|
| `GET` | `/api/projects/:id/management/call_sheets` | `getAll` | Get all callsheets for a project |
| `GET` | `/api/call_sheets/:id/:visitorId` | `getOne` | Get a single callsheet (public, tracks visitor) |
| `POST` | `/api/projects/:id/management/call_sheets` | `createOrUpdate` | Create or update a callsheet |
| `DELETE` | `/api/projects/:id/management/call_sheets/:callsheetId` | `delete` | Delete a callsheet |

---

## Database Structure

### `callsheets` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Auto-incremented primary key |
| `version` | string | Version label (e.g. "1", "v2.1") |
| `project_id` | integer (FK) | References `projects.id` — deleted cascade |
| `created_at` | timestamp | Auto-set on creation |
| `updated_at` | timestamp | Auto-updated on every save |

### `content_callsheets` table

Each callsheet has multiple content blocks stored in this table:

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Auto-incremented primary key |
| `callsheet_id` | integer (FK) | References `callsheets.id` — deleted cascade |
| `title` | string | Title/heading of the content block |
| `text` | text | Rich HTML content of the block (was `string(255)` before migration `1723559101418`) |
| `created_at` | timestamp | Auto-set on creation |
| `updated_at` | timestamp | Auto-updated on every save |

### `seens` pivot table

Tracks which participants have seen a callsheet:

| Column | Type | Description |
|--------|------|-------------|
| `callsheet_id` | integer (FK) | References `callsheets.id` |
| `participant_id` | integer (FK) | References `participants.id` |
| `created_at` | timestamp | When the participant first saw it |
| `updated_at` | timestamp | When they last saw it |

### `attached_to_callsheets` table

Links files to callsheets (currently unused in the UI):

| Column | Type | Description |
|--------|------|-------------|
| `file_id` | integer (FK) | References `callsheets.id` |
| `callsheet_id` | integer (FK) | References `files.id` |

---

## Model Relationships

### `Callsheet` model (`app/models/callsheet.ts`)

```
Callsheet
  ├── belongsTo → Project (via project_id)
  ├── hasMany → ContentCallsheet (via callsheet_id)
  └── manyToMany → Participant (via seens pivot table)
```

### `ContentCallsheet` model (`app/models/content_callsheet.ts`)

```
ContentCallsheet
  └── belongsTo → Callsheet (via callsheet_id)
```

---

## How the Feature Works

### 1. Listing Callsheets
The frontend fetches all callsheets for a project via `GET /api/projects/:id/management/call_sheets`. Results are sorted by `updatedAt` descending by default. The `maxUpdateDate()` function in the frontend finds the most recently updated callsheet to use for the "New callsheet from the last one" button.

### 2. Creating a New Callsheet
When clicking "New callsheet", the user is redirected to `/projects/[id]/management/callsheets/creation`. A `POST` request is sent to the API with:
- `version` — required string
- `project_id` — the current project ID
- `contents` — array of `{ title, text }` objects

The validator (`createCallsheetValidator`) enforces that all fields are present.

### 3. Editing / Copying from Last One
When clicking "New callsheet from the last one", the user is redirected to `/projects/[id]/management/callsheets/[callsheetId]/creation` where `callsheetId` is the ID of the most recently updated callsheet. The same creation form is loaded but pre-filled with the existing content.

When saving an existing callsheet (with an `id` in the request body), the controller:
1. Finds the existing callsheet by ID
2. Updates the `version` field
3. **Deletes all existing content blocks** (`await callsheet.related('contents').query().delete()`)
4. Creates new content blocks from the request data

> **Note:** Content blocks are fully deleted and recreated on every save — there is no partial update. Each block keeps its order and position, which are re-sent on every save (see section 6).

### 4. The Public Callsheet Page
The public callsheet is accessible at `/call_sheets/[callsheetId]/[visitorId]`. It is one of the only public pages in the app — no authentication required.

When a participant opens the callsheet:
1. The frontend fetches `GET /api/call_sheets/:id/:visitorId`
2. The backend finds the most recently updated callsheet for the project
3. If a valid `visitorId` (contact ID) is provided, the backend:
   - Finds the corresponding participant in the project
   - Updates their `last_activity` timestamp
   - Records them in the `seens` pivot table (detaches first, then re-attaches to update the timestamp)
4. The callsheet is returned with all its relationships preloaded: contents, project, responsibles, rehearsals, concerts, pieces (with composers and files), and section groups

### 5. Deleting a Callsheet
A `DELETE` request to `/api/projects/:id/management/call_sheets/:callsheetId` deletes the callsheet and all its content blocks (cascade delete).

### 6. Ordering and Positioning Content Blocks

Since #208, each content block has two extra fields (see the `ContentCallsheet` type):
- `order` (number): the display order of the block among the others.
- `position` (`'above'` | `'below'`): whether the block is shown above or below the program & events section.

In the callsheet editor (`CallsheetModifier.svelte`), the user can:
- Reorder blocks with the ▲ / ▼ buttons (`moveUp` / `moveDown`). After each move, `order` is recomputed for every block.
- Choose `above` / `below` for each block through a dropdown ("Above program & events" / "Below program & events").

Both fields are sent with each block when saving. Note that this replaces the old behaviour described in issue #83, where blocks could not be reordered.

---

## Known Issues & Open Tasks

| Issue | Repo | Description |
|-------|------|-------------|
| #83 | front | Blocks cannot be moved after creation in the callsheet editor |
| #99 | back | Callsheet links and attached features need thorough testing |
| #167 | front | Scores not available on callsheet |

---

## Tips for Developers

- When adding a new field to a callsheet content block, remember to update both the `createCallsheetValidator` and the `ContentCallsheet` model, as well as a new database migration.
- The `text` field of content blocks was originally a `string(255)` — it was changed to `text` (unlimited) in migration `1723559101418_alter_content_callsheets_table.ts` to support rich HTML content.
- The public callsheet page (`/call_sheets/[id]/[visitorId]`) always returns the **most recently updated** callsheet for a project, not a specific version. The version label is purely informational.
- The `seens` pivot table is used to track how many participants have opened the latest callsheet — this count is displayed on the project dashboard.