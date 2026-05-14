# Technical Documentation: Sections & Instruments Feature

*Edited by Ramy*

## Overview

The Sections & Instruments feature allows administrators to manage orchestra organization structures inside the application.

The feature is divided into three entities:

- Instruments
- Sections
- Section Groups

Instruments represent playable musical instruments (Violin, Trumpet, Flute, etc.).

Sections represent orchestral sections and define:
- a section name
- a target participant size
- associated playable instruments

Section Groups organize multiple sections together and are used inside projects for participant assignment and section statistics.

The feature also provides:
- CRUD operations
- duplication support
- participant fill-rate statistics
- responsive mobile/desktop visualization

---

# Architecture

The feature is split between:

- Frontend (SvelteKit)
- Backend (AdonisJS)
- PostgreSQL database

---

# Frontend Structure

## Main Management Page

| Route | File | Description |
|---|---|---|
| `/sections` (or management module route) | `src/lib/components/sections/SectionGroupModifier.svelte` | Main interface for managing groups, sections, and instruments |

The page contains:
- tables for all entities
- creation/edit popups
- duplication actions
- deletion actions
- responsive layouts

---

## Statistics Display Component

| File | Description |
|---|---|
| project sections statistics component (the second Svelte file) | Displays section fill rates and participant statistics inside projects |

Features:
- fill-rate visualization
- section occupancy bars
- participant lists
- sorting by fill rate
- responsive mobile view

---

## Frontend API Routes

### Section Groups

| Method | Route | Description |
|---|---|---|
| GET | `/api/sectionGroups` | Retrieve all section groups |
| POST | `/api/sectionGroups` | Create or update a section group |
| DELETE | `/api/sectionGroups/[id]` | Delete a section group |

Files:
- `src/routes/api/sectionGroups/+server.ts`
- `src/routes/api/sectionGroups/[id]/+server.ts`

---

### Sections

| Method | Route | Description |
|---|---|---|
| GET | `/api/sections` | Retrieve all sections |
| POST | `/api/sections` | Create or update a section |
| DELETE | `/api/sections/[id]` | Delete a section |

Files:
- `src/routes/api/sections/+server.ts`
- `src/routes/api/sections/[id]/+server.ts`

---

### Instruments

The frontend also communicates with:
- `/api/instruments`
- `/api/instruments/[id]`

for CRUD operations on instruments.

(The backend structure is similar to sections and section groups.)

---

# Backend Structure

## Controllers

| File | Description |
|---|---|
| `app/controllers/section_groups_controller.ts` | Handles section group CRUD operations |
| `app/controllers/sections_controller.ts` | Handles section CRUD operations |

---

## Models

| File | Description |
|---|---|
| `app/models/section_group.ts` | Section group database model |
| `app/models/section.ts` | Section database model |
| `app/models/instrument.ts` | Instrument database model |
| `app/models/section_pdf.ts` | Stores PDFs linked to sections |

---

# Database Structure

## instruments table

| Column | Type | Description |
|---|---|---|
| id | integer (PK) | Auto-incremented primary key |
| name | string | Instrument name |
| family | string | Instrument family |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Update timestamp |

---

## sections table

| Column | Type | Description |
|---|---|---|
| id | integer (PK) | Auto-incremented primary key |
| name | string | Section name |
| size | integer | Target number of participants |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Update timestamp |

---

## section_groups table

| Column | Type | Description |
|---|---|---|
| id | integer (PK) | Auto-incremented primary key |
| name | string | Group name |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Update timestamp |

---

## played_in_sections pivot table

Defines many-to-many relationships between sections and instruments.

| Column | Type | Description |
|---|---|---|
| section_id | FK | References sections.id |
| instrument_id | FK | References instruments.id |

---

## section_section_groups pivot table

Defines relationships between sections and section groups.

| Column | Type | Description |
|---|---|---|
| section_id | FK | References sections.id |
| section_group_id | FK | References section_groups.id |
| order | integer | Section display order |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Update timestamp |

---

# Model Relationships

## SectionGroup model

SectionGroup
 ├── manyToMany → Section
 └── hasMany → Project

## Feature Workflow

## 1. Loading Data

On page mount:

all section groups are fetched
all sections are fetched
all instruments are fetched

The frontend uses:

`GET /api/sectionGroups`
`GET /api/sections`
`GET /api/instruments`

## 2. Creating and Editing

The same popup forms are used for:

creation
editing

The frontend sends POST requests containing:

entity data
related sections/instruments arrays

The backend validators ensure:

required fields exist
referenced relations are valid
## 3. Duplication

Users can duplicate:

instruments
sections
section groups

The duplicated entity:

receives a new ID
copies all relations
appends (Copy) to the name
## 4. Deletion

Deletion uses:

`DELETE /api/.../:id`

Cascade deletes automatically remove pivot relationships.

## 5. Section Statistics

Inside projects, the feature displays:

participant counts per section
target section sizes
fill-rate percentages

The fill rate is calculated using:

participantCount / sectionSize

Sections can also be:

sorted by fill rate
viewed responsively on mobile
expanded to show participant lists
Section PDFs

The section_pdfs table allows projects to attach PDF files to sections.

The feature supports:

score distribution
audition files
required documents
usage statistics

## Additional metadata includes:

active state
required state
audition count
ordering
