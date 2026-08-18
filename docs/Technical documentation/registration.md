# Edited by  # Umair


# Registration

This page describes the Registration feature in Melomania. The registration form allows project managers to create a public form that musicians can fill in to apply for a project.

---

## Overview

The Registration feature allows project managers to:

- Create a registration form for a project
- Add custom information blocks (with rich text content)
- Add custom form questions for applicants
- Share a public link with musicians so they can apply
- View and manage applications from the Participants page

Musicians (applicants) can:

- View project details (events, program, information)
- Fill in their personal information
- Select their musical section
- Choose which rehearsals and concerts they can attend
- Answer custom form questions
- Submit their application

---

## Accessing the Registration Editor

1. Click on **Projects** in the sidebar
2. Select a project
3. Click on the **Registration** tab — if no registration form exists yet, you will be prompted to create one

---

## Registration Editor

The editor is split into two panels:

- **Left panel** — the editing interface
- **Right panel** — a live preview of the public registration form

### Information Blocks

Information blocks are custom content sections displayed to applicants on the registration form under the **Information** tab.

To manage information blocks:

1. Click the **INFORMATION** section to expand it
2. Click **Add content** to add a new block
3. Fill in the **title** and **content** (supports rich HTML via the text editor)
4. Use the **▲ ▼ buttons** to reorder blocks
5. Use the **position dropdown** to choose whether the block appears **above** or **below** the default program and events sections
6. Click the **trash icon** to delete a block

### Form Questions

Custom questions can be added to the registration form under the **FORM** section:

1. Click the **FORM** section to expand it
2. Add, edit or remove questions
3. Each question has a **type** (text, checkbox, etc.)

### Saving

Click **Save** to save all changes. A confirmation popup will appear when saved successfully.

### Deleting

Click **Delete** to remove the entire registration form for the project.

---

## Public Registration Form

The public registration form is accessible at:

```
/registration/{projectId}
```

It is divided into **3 steps**:

### Step 1 — Project Details

Shows three tabs:

- **Events** — list of all concerts and rehearsals with date, time, place and type
- **Program** — list of musical pieces with composer names
- **Information** — custom information blocks added by the project manager

### Step 2 — Contact

The applicant fills in their personal information:

- First name (required)
- Last name (required)
- Email address (required)
- Phone number (optional)
- Messenger (optional)
- Section (required — shows FULL if the section has reached its capacity)

### Step 3 — Attendances

The applicant selects which rehearsals and concerts they can attend. They can also add a comment for each event and answer any custom form questions.

---

## Submitting an Application

When the applicant clicks **Submit**:

- Their contact information is saved (or matched to an existing contact)
- A participant record is created for the project with `accepted = false`
- Their attendance selections are saved
- Their form answers are saved
- A success popup is displayed

The application then appears in the **Participants** tab of the project for the project manager to review and validate.

---

## Ordering and Positioning Information Blocks

Each information block has two fields:

- **order** — the display order among other blocks
- **position** — whether the block appears `above` or `below` the default Events and Program sections

These can be configured in the Registration Editor using the ▲ ▼ buttons and the position dropdown.

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/registrations/:id` | Get the registration form for a project |
| `POST` | `/api/projects/:id/management/registration` | Create or update the registration form |
| `DELETE` | `/api/projects/:id/management/registration` | Delete the registration form |
| `PUT` | `/api/registrations/:id` | Submit a registration (public) |
| `GET` | `/api/projects/:id/public/participants-count` | Get participant count by section (public) |

---

## Database Structure

### `registrations` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Auto-incremented primary key |
| `project_id` | integer (FK) | References `projects.id` |
| `created_at` | timestamp | Auto-set on creation |
| `updated_at` | timestamp | Auto-updated on every save |

### `content_registrations` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Auto-incremented primary key |
| `registration_id` | integer (FK) | References `registrations.id` |
| `title` | string | Title of the information block |
| `text` | text | Rich HTML content |
| `order` | integer | Display order of the block |
| `position` | string | `above` or `below` the default sections |
| `created_at` | timestamp | Auto-set on creation |
| `updated_at` | timestamp | Auto-updated on every save |

### `forms` table

Stores custom form questions for a registration:

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Auto-incremented primary key |
| `registration_id` | integer (FK) | References `registrations.id` |
| `text` | string | The question text |
| `type` | string | The question type (text, checkbox, etc.) |

---

## Frontend Files

| File | Description |
|------|-------------|
| `src/lib/components/registration/RegistrationModifier.svelte` | Registration editor with information blocks and form questions |
| `src/lib/components/registration/RegistrationShow.svelte` | Public registration form shown to applicants |
| `src/lib/components/registration/RegistrationForm.svelte` | Individual form question component |
| `src/lib/components/registration/RegistrationFormModifier.svelte` | Form question editor |
| `src/lib/types/ContentRegistration.ts` | TypeScript type for a registration content block |
| `src/lib/types/Registration.ts` | TypeScript type for a registration |