# TD - Audition Module 

*Edited by Ramy*

## Overview

This module implements a full audition workflow between:

* Frontend: SvelteKit API proxy routes
* Backend: AdonisJS REST API
* Storage: Database + filesystem uploads

The system allows:

* Creating audition requests
* Uploading candidate files
* Uploading and distributing PDF materials
* Saving temporary notes
* Submitting auditions
* Streaming media files
* Deleting uploaded files

---

# Architecture

## Frontend Architecture (SvelteKit)

Frontend API routes act as a proxy layer between the browser and AdonisJS.

Advantages:

* Hides backend URL
* Centralizes authentication/cookies later
* Handles file uploads safely
* Supports streaming proxying

Base pattern:

```ts
const res = await fetch(`${API_URL}/some/backend/route`, {
  method: 'POST',
  body: formData
})

return res
```

Environment variable:

```env
API_URL=http://backend-url
```

---

# Frontend API Routes

| Route | Method | Purpose |
|---|---|---|
| `/api/audition/[token]` | GET | Load audition page data |
| `/api/audition/[token]/upload` | POST | Upload candidate file |
| `/api/audition/[token]/save-notes` | POST | Save temporary candidate notes |
| `/api/audition/[token]/submit` | POST | Submit audition |
| `/api/audition/[token]/files/[fileId]` | DELETE | Delete uploaded file |
| `/api/audition/[token]/pdf/[pdfFileId]` | GET | Download assigned PDF |
| `/api/files/stream/[fileId]` | GET | Stream media files |

---

## Route Details

`/api/audition/[token]`

Loads:

- audition metadata
- uploaded files
- assigned PDFs
- participant information
- project information

`/api/audition/[token]/upload`

Uses `multipart/form-data`.

Expected fields:

```txt
file
fileType
description
```

## Upload candidate file

File:

```txt
src/routes/api/audition/[token]/upload/+server.ts
```

POST

Calls:

```txt
POST /audition/:token/upload
```

Uses:

```ts
const formData = await request.formData()
```

The frontend forwards multipart/form-data directly to AdonisJS.

Expected fields:

```txt
file
fileType
description
```

---

## Save temporary notes

File:

```txt
src/routes/api/audition/[token]/save-notes/+server.ts
```

POST

Calls:

```txt
POST /audition/:token/save-notes
```

Payload:

```json
{
  "notes": "candidate text"
}
```

Purpose:

* Autosave notes before final submission

---

## Submit audition

File:

```txt
src/routes/api/audition/[token]/submit/+server.ts
```

POST

Calls:

```txt
POST /audition/:token/submit
```

Payload:

```json
{
  "notes": "final notes"
}
```

Effects:

* Marks audition as submitted
* Sets submitted_at
* Updates participant status

---

## Delete uploaded file

File:

```txt
src/routes/api/audition/[token]/files/[fileId]/+server.ts
```

DELETE

Calls:

```txt
DELETE /audition/:token/files/:fileId
```

Effects:

* Deletes physical file
* Deletes database file record
* Deletes audition_file relation

---

## Stream media file

File:

```txt
src/routes/api/files/stream/[fileId]/+server.ts
```

Purpose:

* Streams audio/video files
* Supports range requests
* Enables browser seeking

Important logic:

```ts
const rangeHeader = request.headers.get('range')
```

Headers forwarded:

```txt
content-type
content-length
content-range
accept-ranges
```

This route is critical for:

* Video playback
* Audio playback
* Partial streaming

---

## Download assigned PDF

File:

```txt
src/routes/api/audition/[token]/pdf/[pdfFileId]/+server.ts
```

GET

Calls:

```txt
GET /audition/:token/pdf/:pdfFileId/download
```

Purpose:

* Downloads PDFs assigned to audition
* Prevents direct filesystem exposure

---

# Backend Architecture (AdonisJS)

Main controller:

```txt
AuditionsController
```

Responsibilities:

* Audition lifecycle
* File uploads
* PDF distribution
* Submission workflow
* Candidate access
* Validation

---

# Core Database Models

| Model | Purpose |
|---|---|
| `Audition` | Main audition entity |
| `AuditionFile` | Candidate uploaded files |
| `AuditionPdfFile` | PDFs attached to auditions |
| `File` | Physical file metadata |
| `SectionPdf` | PDFs assigned by section |

---

## Audition

Main entity.

Fields:

```ts
participant_id
project_id
secure_token
instructions
required_files
is_submitted
submitted_at
candidate_notes
deadline
```

Important:

```ts
required_files
```

Stored as serialized JSON.

Serialization logic:

```ts
serialize: (value) => safeParseJson(value)
prepare: (value) => safeStringify(value)
```

---

## AuditionFile

Represents uploaded candidate files.

Fields:

```ts
file_type
description
uploaded_at
```

Relations:

```txt
Audition -> hasMany -> AuditionFile
AuditionFile -> belongsTo -> File
```

---

## AuditionPdfFile

Represents PDFs attached to auditions.

Fields:

```ts
section_id
title
description
order
```

Purpose:

* Stores music sheets
* Stores instructions
* Stores audition material

---

# Backend Routes

## Public candidate routes

Prefix:

```txt
/audition
```

Routes:

```txt
GET    /:token
POST   /:token/upload
POST   /:token/save-notes
POST   /:token/submit
DELETE /:token/files/:fileId
GET    /:token/pdfs
GET    /:token/pdf/:pdfFileId/download
```

These routes are token-based.

No authentication middleware is used.

Security depends entirely on:

```txt
secure_token
```

---

# File Upload Flow

## Candidate Upload Flow

| Step | Action |
|---|---|
| 1 | Frontend receives `FormData` |
| 2 | SvelteKit forwards request to AdonisJS |
| 3 | Backend validates upload |
| 4 | File is moved to `/uploads/auditions` |
| 5 | `File` database entry is created |
| 6 | `AuditionFile` relation is created |
| 7 | Uploaded file response is returned |

---

# PDF Distribution System

## Section PDFs

PDFs can be assigned by section.

Example:

```txt
Violin section -> violin sheet PDF
Trumpet section -> trumpet PDF
```

Storage table:

```txt
section_pdfs
```

When audition is created:

```ts
associateSectionPdfsToAudition()
```

Automatically copies PDFs into:

```txt
audition_pdf_files
```

---

# Submission Workflow

## saveTemporaryNotes()

Temporary save only.

Does NOT submit.

## submitAudition()

Finalizes audition.

Effects:

```ts
is_submitted = true
submitted_at = now
participant.audition_status = 'completed'
```

After submission:

* Upload disabled
* Delete disabled
* Notes locked

---

---

# Improvement Notes

- Oversized `AuditionsController` with multiple responsibilities

- Some operations are not protected by database transactions

- Storage system is tightly coupled to local filesystem paths

- Repeated upload and validation logic across endpoints

- Debug logging still present in production routes

- File deletion lifecycle could be centralized

- Route organization could be separated into smaller modules
