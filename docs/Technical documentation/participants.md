
# TD - Participants

*Edited by Umair*

This page explains how participants are managed within a project in Melomania. A participant is a contact who has been added to a specific project, with information about their section, attendance, and registration form answers.

---

## Overview

A participant links a **contact** to a **project**. Each participant can be:

- Assigned to a **section** (e.g. violin, cello, trumpet)
- Marked as a **section leader**
- Registered for specific **concerts** and **rehearsals**
- Associated with **form answers** from the project's registration form
- Either **accepted** or **pending** (application not yet validated)

---

## Accessing Participants

Participants are managed from within a project. Navigate to:

```
Projects → [Select a project] → Management → Participants
```

---

## Adding a Participant

Before adding a participant, make sure the project has:
- A **registration form** created
- A **section group with sections** defined

If either is missing, the app will redirect you to create them first.

### Steps

1. Go to the project's participant management page
2. Click **Create a new participant**
3. Select a **contact** from the list
4. Fill in the **registration form answers**
5. Set **concert and rehearsal attendance**
6. Assign a **section** and optionally mark as **section leader**
7. Click **Save**

When a new participant is saved for the first time, a **validation notification email** is automatically sent to the contact.

---

## Editing a Participant

1. Open an existing participant from the list
2. Click the **edit icon** (pencil) in the top-right corner of the form
3. Modify the relevant fields
4. Click **Save**

---

## Deleting a Participant

1. Open the participant's page
2. Click the **Delete** button
3. The participant is removed from the project, and their attendance records (concerts and rehearsals) are detached

> When a participant is deleted, their recruitment status is automatically updated to **cancelled** in the recruitment module.

---

## Attendance

The **AttendancePicker** component displays a table of checkboxes, one per concert or rehearsal. Each column shows the venue and date of the event.

- **Check** a box to mark the participant as attending
- **Uncheck** a box to remove their attendance
- Each attendance entry can also include a **comment** (visible in the table next to the checkbox)

Attendance is managed separately for:
- **Concerts**
- **Rehearsals**

---

## Section Assignment

The **SectionPicker** component allows you to:

- Select a **section** from a dropdown (e.g. Violins, Brass, Woodwinds)
- Check the **Section leader** checkbox if the participant leads their section

---

## Validating an Application

Participants who applied through the registration form start with `accepted = false`. To validate them:

1. Go to **Applications** under the project's participant management
2. Review the participant's answers and audition files
3. Click **Validate**

Once validated:
- The participant's `accepted` field is set to `true`
- They are automatically added to the **Recruitment** module with status `recruited`
- If they were already in recruitment, their status is updated to `recruited`

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/projects/:id/management/participants` | Get all accepted participants for a project |
| `GET` | `/api/projects/:id/management/participants/:participantId` | Get a single participant |
| `POST` | `/api/projects/:id/management/participants` | Create or update a participant |
| `DELETE` | `/api/projects/:id/management/participants/:participantId` | Delete a participant |
| `GET` | `/api/projects/:id/management/applications` | Get all pending applications |
| `GET` | `/api/projects/:id/management/participants/:participantId/auditions` | Get participant with audition files |
| `POST` | `/api/projects/:id/management/participants/validate` | Validate a participant application |
| `GET` | `/api/projects/:id/management/participants/count-by-section` | Get participant count grouped by section |
| `GET` | `/api/projects/:id/management/participants/answers` | Get all participant form answers |

---

## Database

### `participants` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer | Primary key |
| `project_id` | integer | Foreign key to the project |
| `contact_id` | integer | Foreign key to the contact |
| `section_id` | integer | Foreign key to the assigned section |
| `is_section_leader` | boolean | Whether the participant leads their section |
| `accepted` | boolean | Whether the application has been validated |
| `created_at` | timestamp | Creation date |
| `updated_at` | timestamp | Last update date |

### `participates_ins` table (pivot)

This table links participants to rehearsals.

| Column | Type | Description |
|--------|------|-------------|
| `rehearsal_id` | integer | Foreign key to the rehearsal |
| `participant_id` | integer | Foreign key to the participant |
| `created_at` | timestamp | Creation date |
| `updated_at` | timestamp | Last update date |

> A similar pivot table exists for concerts, linking participants to concert attendance.

---

## Filtering & Search

The participant list supports filtering by:

- Contact first name, last name, email, phone, messenger
- Section name

Results are paginated and orderable.