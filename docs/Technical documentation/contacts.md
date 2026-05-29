---
id: contacts
title: TD - Contacts
---

# TD - Contacts

edited by TOUVOLI BALLO STEVE, 12/05/2026

## Purpose

The Contacts feature is one of the central parts of the Melomania application. It works as an advanced contact database for musicians and other people linked to the orchestra.

A contact can store personal information, instruments, proficiency levels, project history, mailing list membership, validation status, and accounting-related information.

The Contacts feature is used by several other modules, including:

- Projects
- Participants
- Recruitment
- Mailing
- Accounting
- Auditions
- Callsheets

## Main user pages

### Contacts dashboard

Frontend file:

```txt
front/src/routes/contacts/+page.svelte
```

This page is the main entry point for the Contacts module. It displays dashboard statistics, including:

- total number of contacts
- number of contact lists
- number of contacts waiting for validation
- number of recommended contacts

It fetches data from:

```txt
/api/contacts
/api/lists
/api/contacts/validations
/api/recommended
```

### Contacts search

Frontend file:

```txt
front/src/routes/contacts/search/+page.svelte
```

This page provides advanced search and filtering for contacts. Users can filter contacts using fields from the contact itself and related entities such as instruments, projects, participants, and lists.

The page uses the `AdvancedFilterer` component.

Important note: this page currently sends the advanced search request to:

```txt
/test/api
```

This endpoint forwards the request to the backend contact advanced search route.

### Contact creation

Frontend file:

```txt
front/src/routes/contacts/create/+page.svelte
```

This page creates a new contact by using the shared `ContactModifier` component in `create` mode.

It also fetches the list of instruments from:

```txt
/api/instruments
```

### Contact detail and edition

Frontend files:

```txt
front/src/routes/contacts/[id]/+page.server.ts
front/src/routes/contacts/[id]/+page.svelte
```

The server load fetches:

```txt
GET /contact/:id
GET /instrument
```

The page displays and allows editing of:

- first name
- last name
- email
- phone
- Messenger
- comments
- instruments and proficiency levels
- validation status
- creation date
- last update date

It also shows project participation history and accounting entries linked to the contact.

### Contact validation

Frontend file:

```txt
front/src/routes/contacts/validation/+page.svelte
```

This page is used to manage contacts that are not validated yet.

A contact can be:

- validated directly
- assigned instruments and proficiency levels before validation
- deleted
- compared with an existing contact
- merged with another contact

This is useful when a new person registers for a project and the system creates a non-validated contact that must later be confirmed by an admin.

### Contact lists

Frontend files:

```txt
front/src/routes/contacts/lists/+page.svelte
front/src/routes/contacts/lists/create/+page.svelte
front/src/routes/contacts/lists/[id]/+page.svelte
```

Contact lists are used mainly for mailing. They allow users to group contacts and send emails to a custom set of people.

These pages utilize a reusable frontend component `ListModifier.svelte` in either `create` or `modify` mode.

The page integrates with `AdvancedFilterer` to enable query-based database filtering, sending advanced filters via POST payloads to retrieve specific subsets of contacts. The user can select contacts and add them to a newly designed tabular contact list display with row-by-row visibility of added members.

## Shared frontend components

### ListModifier

Frontend file:

```txt
front/src/lib/components/list/ListModifier.svelte
```

`ListModifier` is the main reusable form component for creating and editing contact lists.

It is used in two modes:
- `create`
- `modify`

In `modify` mode, it fetches the existing list's data (including name and contact associations) and enables updating or deleting the list. The component displays added contacts in a responsive row-by-row table layout and renders the `AdvancedFilterer` below it to add new contacts to the list.

## Shared frontend component

### ContactModifier

Frontend file:

```txt
front/src/lib/components/contact/ContactModifier.svelte
```

`ContactModifier` is the main reusable form component for contacts.

It is used in two modes:

```txt
create
modify
```

In modify mode, fields are read-only at first. The user must click the edit button to enable editing.

The component handles:

- editing basic contact information
- adding/removing instruments
- selecting proficiency levels
- saving changes through `PUT /api/contacts`
- deleting a contact through `DELETE /api/contacts/:id`

## Frontend types

Main type file:

```txt
front/src/lib/types/Contact.ts
```

The frontend `Contact` type includes:

```txt
id
firstName
lastName
email
phone
messenger
comments
validated
instruments
participants
projects
recommendation_pending
createdAt
updatedAt
```

## Backend structure

### Main controller

Backend file:

```txt
back/app/controllers/contacts_controller.ts
```

The main methods are:

```txt
getAll
getOne
advancedSearch
mergeContacts
createOrUpdate
delete
getValidation
unsubscribe_from_mails
```

### Backend model

Backend file:

```txt
back/app/models/contact.ts
```

The `Contact` model defines the main contact fields and relations.

Main fields:

```txt
id
first_name
last_name
email
phone
messenger
comments
validated
subscribed
createdAt
updatedAt
```

Main relations:

```txt
instruments
lists
participants
projects
```

The model also exposes compatibility getters:

```txt
firstName
lastName
fullName
```

These are useful because the backend stores fields as `first_name` and `last_name`, while the frontend often uses `firstName` and `lastName`.

### Backend validator

Backend file:

```txt
back/app/validators/contact.ts
```

The validator checks contact creation, update, and merge payloads.

Important fields:

```txt
first_name
last_name
email
phone
messenger
comments
validated
subscribed
instruments
```

For instruments, the expected structure includes:

```txt
id
name
pivot_proficiency_level
```

## Backend API routes

Backend file:

```txt
back/start/routes.ts
```

The protected contact routes are grouped under:

```txt
/contact
```

Important routes:

| Method | Route | Purpose |
|---|---|---|
| GET | `/contact` | Get paginated contacts with simple filtering |
| GET | `/contact/validation` | Get contacts waiting for validation |
| POST | `/contact/validation/merge` | Merge two contacts |
| GET | `/contact/:id` | Get full contact details |
| PUT | `/contact` | Create or update a contact |
| DELETE | `/contact/:id` | Delete a contact |
| POST | `/contact` | Advanced contact search |

There is also a public unsubscribe route:

```txt
PUT /unsubscribe
```

This route updates the contact field:

```txt
subscribed = false
```

## Database structure

### contacts

Migration files:

```txt
back/database/migrations/1715858307609_create_contacts_table.ts
back/database/migrations/1723558562185_alter_contacts_table.ts
```

Main columns:

```txt
id
first_name
last_name
email
phone
messenger
comments
validated
subscribed
created_at
updated_at
```

The `comments` column was later changed from a string field to a text field.

### plays

Migration file:

```txt
back/database/migrations/1715858307610_create_plays_table.ts
```

This is a pivot table between contacts and instruments.

Columns:

```txt
contact_id
instrument_id
proficiency_level
created_at
updated_at
```

Primary key:

```txt
contact_id + instrument_id
```

This means a contact can play several instruments, and each instrument can have its own proficiency level.

### contacts_lists

Migration file:

```txt
back/database/migrations/1715863135043_create_contacts_lists_table.ts
```

This is a pivot table between contacts and lists.

Columns:

```txt
contact_id
list_id
created_at
updated_at
```

Primary key:

```txt
contact_id + list_id
```

### participants

The `participants` table links contacts to projects.

A participant connects:

```txt
contact_id
project_id
section_id
```

This is why the app does not directly attach contacts to projects. A contact can participate in several projects, and each participation can have project-specific information.

## Main workflows

### Creating a contact

1. The user opens `/contacts/create`.
2. The frontend loads all instruments.
3. The user fills the contact form.
4. `ContactModifier` sends a `PUT` request to `/api/contacts`.
5. The SvelteKit API route forwards the request to the backend endpoint `PUT /contact`.
6. The backend validates the payload.
7. The backend creates or updates the contact.

### Editing a contact

1. The user opens `/contacts/:id`.
2. The page server load fetches the contact from `GET /contact/:id`.
3. The user clicks the edit button.
4. The user modifies fields or instruments.
5. `ContactModifier` sends a `PUT` request to `/api/contacts`.
6. The backend updates the contact and syncs instruments.

### Deleting a contact

1. The user clicks delete in `ContactModifier`.
2. The frontend sends `DELETE /api/contacts/:id`.
3. The SvelteKit route forwards to `DELETE /contact/:id`.
4. The backend deletes related participant answers and rehearsals.
5. The backend deletes the participant records.
6. The backend deletes the contact.

### Validating a contact

1. A non-validated contact appears in `/contacts/validation`.
2. The user selects the contact.
3. The user can either validate it directly or compare it with an existing contact.
4. Direct validation sends a `PUT /api/contacts` request with `validated: true`.
5. Merge sends a `POST /api/contacts/validations` request.
6. The backend merges the selected contact data and deletes the duplicate contact.

### Advanced search

1. The user opens `/contacts/search`.
2. The frontend builds a nested filter object.
3. The frontend sends this object to `/test/api`.
4. `/test/api` forwards the request to `POST /contact`.
5. The backend uses `advancedFilter`.
6. The backend returns both matching data and filterable columns.

## Important relations

Contacts are connected to:

- `Instrument` through `plays`
- `List` through `contacts_lists`
- `Participant` through `participants`
- `Project` through `participants`
- `Accounting` through `contact_id`
- `RecruitmentContact` through `contact_id`
- Mailings through contact lists and participant lists

## Known issues and attention points

### Advanced search uses `/test/api`

The contacts search page currently calls:

```txt
/test/api
```

instead of a clearer route like:

```txt
/api/contacts/search
```

This works as a proxy but is confusing for maintainers.

### Contact creation and instruments

The backend `createOrUpdate` method only syncs instruments after `updateOrCreate`.

For new contacts, the method returns immediately after `Contact.create(...)`, so instrument synchronization may not happen during creation. This should be verified before changing the contact creation workflow.

### Validation page is complex

The validation page handles several responsibilities in one file:

- listing unvalidated contacts
- finding similar contacts
- comparing contact fields
- selecting which fields to keep
- merging contacts
- validating contacts
- deleting contacts

This file may be difficult to maintain and could be split later.

### Deleting contacts has side effects

Deleting a contact also deletes related participant data, answers, and rehearsal relations. This is important because contact deletion can affect project history.

### Field naming differs between backend and frontend

The backend uses snake_case:

```txt
first_name
last_name
created_at
updated_at
```

The frontend often uses camelCase:

```txt
firstName
lastName
createdAt
updatedAt
```

The `Contact` model provides getters for compatibility, but developers should pay attention when sending payloads back to the backend.

## How to modify this feature

When modifying the Contacts feature:

1. Start with the frontend route related to the page you want to change.
2. Check if the page uses `ContactModifier`.
3. Check the SvelteKit API proxy route under `front/src/routes/api/contacts`.
4. Check the backend method in `ContactsController`.
5. Check the validator if the request payload changes.
6. Check the `Contact` model if relations or fields change.
7. Check database migrations before changing persistent fields.
8. Test contact creation, edition, deletion, search, and validation after changes.
