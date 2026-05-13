# Technical Documentation: Attendance Feature

*Edited by Naomi*

## Overview

The Attendance feature generates a read-only attendance report for a project, showing which participants are present or absent for each rehearsal and concert. The data comes from the registration forms filled in by participants. The report can also be downloaded as a PDF.

---

## Architecture

### Frontend

| Route | File | Description |
|-------|------|-------------|
| `/projects/[id]/management/attendance` | `src/routes/projects/[id]/management/attendance/+page.svelte` | The attendance report page |

### Backend

| File | Description |
|------|-------------|
| `app/controllers/projects_controller.ts` | Contains the `getAttendance` method |
| `app/models/rehearsal.ts` | Rehearsal model with participant pivot |
| `app/models/concert.ts` | Concert model with participant pivot |
| `src/lib/utils/simplePdfGenerator.ts` | Frontend PDF generation utility |

### API Endpoint

| Method | Endpoint | Controller Method | Description |
|--------|----------|-------------------|-------------|
| `GET` | `/api/projects/:id/management/attendance` | `getAttendance` | Get attendance data for a project |

---

## Database Structure

### `participates_ins` table (Rehearsal attendance)

Tracks which participants attend which rehearsals:

| Column | Type | Description |
|--------|------|-------------|
| `rehearsal_id` | integer (FK) | References `rehearsals.id` — deleted cascade |
| `participant_id` | integer (FK) | References `participants.id` — deleted cascade |
| `comment` | text | Optional comment from the participant about their attendance (added in migration `1727266510251`) |
| `created_at` | timestamp | Auto-set on creation |
| `updated_at` | timestamp | Auto-updated on every save |

### `participates_in_concerts` table (Concert attendance)

Tracks which participants attend which concerts:

| Column | Type | Description |
|--------|------|-------------|
| `concert_id` | integer (FK) | References `concerts.id` — deleted cascade |
| `participant_id` | integer (FK) | References `participants.id` — deleted cascade |
| `comment` | text | Optional comment from the participant about their attendance (added in migration `1727266611759`) |
| `created_at` | timestamp | Auto-set on creation |
| `updated_at` | timestamp | Auto-updated on every save |

### `rehearsals` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Auto-incremented primary key |
| `project_id` | integer (FK) | References `projects.id` |
| `start_date` | timestamp | Start date and time of the rehearsal |
| `end_date` | timestamp | End date and time (nullable) |
| `place` | string | Location of the rehearsal |
| `comment` | string | Optional comment about the rehearsal |

### `concerts` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Auto-incremented primary key |
| `project_id` | integer (FK) | References `projects.id` |
| `start_date` | timestamp | Start date and time of the concert |
| `end_date` | timestamp | End date and time (nullable) |
| `place` | string | Location of the concert |
| `comment` | string | Optional comment about the concert |

---

## Model Relationships

### `Rehearsal` model (`app/models/rehearsal.ts`)

```
Rehearsal
  ├── belongsTo → Project (via project_id)
  └── manyToMany → Participant (via participates_ins pivot table)
                   pivotColumns: ['comment']
```

### `Concert` model (`app/models/concert.ts`)

```
Concert
  ├── belongsTo → Project (via project_id)
  └── manyToMany → Participant (via participates_in_concerts pivot table)
                   pivotColumns: ['comment']
```

---

## How the Feature Works

### 1. Fetching Attendance Data

When the attendance page loads, the frontend calls `GET /api/projects/:id/management/attendance`.

The backend `getAttendance` method in `projects_controller.ts`:
1. Fetches the project with all its rehearsals and concerts, preloading their participants and the pivot column `comment`
2. Fetches all **accepted** participants with their contact and section data
3. **Sorts participants** by section order (defined in the section group), then by section leader status (leaders first), then alphabetically by name
4. Returns the project data with the sorted participants list

### 2. Displaying the Attendance Table

The frontend builds two separate tables — one for **Concerts** and one for **Rehearsals**.

Each table has:
- A **diagonal header cell** (top-left, styled with a CSS diagonal line)
- A **Section column** showing the participant's section
- One **column per event** showing the venue and date/time

For each participant row:
- A **section header row** is inserted whenever the section changes
- A **Leader badge** is shown in blue if `participant.isSectionLeader` is true
- The `laxInclude()` function checks if a participant is in an event's participant list — if yes, the cell is **green with ✓**, if no it is **red with ✗**
- A **comment column** next to each event shows the participant's `pivot_comment` if they left one

### 3. PDF Generation

When the user clicks **"Download PDF"**, the frontend calls `generateAttendancePDF()` from `src/lib/utils/simplePdfGenerator.ts`. This utility uses the **jsPDF** library to generate the PDF entirely in the browser — no server call is needed.

The PDF generator:
- Takes the project, concerts, rehearsals, participants, and the `laxInclude` function as input
- Formats dates in French locale (`fr-FR`)
- Truncates long venue names intelligently to fit in the table columns
- Adds page numbers at the bottom of each page
- If generation fails, an error alert is shown to the user

---

## Known Issues & Open Tasks

| Issue | Repo | Description |
|-------|------|-------------|
| #158 | front | Problem with the navbar between project management pages |

---

## Tips for Developers

- The attendance data is **read-only** — it comes from registration forms and cannot be edited from this page
- The `comment` column on both pivot tables was added later via migrations `1727266510251` and `1727266611759` — if you need to add more pivot columns, follow the same pattern
- Participants are sorted by their **section order** defined in the section group, not alphabetically by section name. This ensures the orchestral order is respected
- The PDF is generated **client-side** using jsPDF — no backend changes are needed to modify the PDF output, only changes to `simplePdfGenerator.ts`
- Section leaders always appear first within their section, before other musicians