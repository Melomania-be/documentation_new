# TD - Recruitment Feature

*Edited by Michel, 16/05/2026*

## Overview

The Recruitment feature lets the project manager handle the list of musicians he wants to recruit for a project. It is accessible from inside a project, in the **Recruitment** tab.

URL:/projects/:projectId/management/recruitment
Each project has its own recruitment list. Contacts are not shared between projects, but they can be copied from one project to another.

## How it works

1. The project manager adds candidates to the list (manually, from the global Contacts database, or by copying from another project).
2. Each contact has a status. By default it is `Not yet contacted`.
3. When the project manager contacts the candidate, the status changes to `Awaiting response` and the contact date is saved.
4. If the candidate does not reply after a delay (7 days by default), the status changes automatically to `Follow up`.
5. After the candidate replies, the status moves to `Pending validation`, then to `Recruited`, `Not available`, or `Cancelled`.
Recommendations sent through the public recommendation link of the project appear in a separate tab.

## The Recruitment Management page

The page is divided into three parts:

- A **header** with 4 action buttons (Settings, Import Contacts, Add Manual, Import Project).
- 4 **counters** that show the state of the project recruitment.
- A list of contacts with 3 tabs: Contacts, Recommendations and Statistics.

### Counters

| Counter | What it shows |
|---|---|
| Total Contacts | Total number of recruitment contacts in the project |
| In Progress | Contacts with status `Awaiting response` or `Follow up` |
| Recruited | Contacts with status `Recruited` |
| Recommendations | Recommendations received via the public link |

### Action buttons

- **Settings**: opens the automatic follow-up settings.
- **Import Contacts**: opens a popup to import contacts from the global Contacts database.
- **Add Manual**: opens a form to add a new contact directly.
- **Import Project**: copies the recruitment contacts of another project into the current one.

## Adding contacts

There are three ways to add a contact to the recruitment list.

### Add Manual

Opens a form to create a contact directly. The fields are:

- **First Name** and **Last Name** (required)
- **Email**, **Phone**, **Messenger** (at least one of the three is required)
- **Musical Section** (optional, from the section groups of the project)
- **Contacted by** (auto-filled with the connected user, can be modified)
- **Notes** (free text)

When saved, the contact is created with the status `Not yet contacted` and the source `Manual`.

### Import Contacts

Opens a popup to search and filter the global Contacts database, then import selected contacts into the project. The source of the imported contacts is `Database`.

### Import Project

Copies the recruitment contacts from another project into the current one. The current project is excluded from the list. The source of the copied contacts is `Project`.

If the source project has no other contacts, the popup shows "No Projects Available".

## Statuses and workflow

A recruitment contact has a `status` that reflects its position in the recruitment pipeline. There are 7 default statuses.

| Status | Meaning |
|---|---|
| Not yet contacted | Default status when the contact is created |
| Awaiting response | The contact has been reached out to |
| Follow up | The contact has not replied after the delay |
| Pending validation | The contact has replied, waiting for the manager's decision |
| Not available | The contact is not available for this project |
| Recruited | The contact has been recruited |
| Cancelled | The recruitment has been cancelled |

In the code, the statuses are defined as a TypeScript union type in `recruitment_contact.ts` (model). They are hardcoded and cannot be changed without modifying the source code.

### Custom statuses

In addition to the 7 default statuses, the project manager can create custom statuses by clicking the **+ Statuses** button on the Recruitment page. A popup opens with a field to enter the name of a new custom status.

The list of default statuses is shown for reference inside the popup to avoid duplicates.

### Automatic Follow-up

The **Settings** button opens the Recruitment Settings popup. It contains the configuration of the automatic follow-up.

- **Enable automatic follow-up**: toggle (enabled by default).
- **Follow-up delay (in days)**: number of days before a contact in `Awaiting response` is automatically moved to `Follow up`. Default: 7 days.

Modifying the delay automatically recalculates the status of all contacts currently in `Awaiting response`, based on their contact date.


## Contact list

The Contacts tab displays the list of all recruitment contacts of the project, with the following columns:

| Column | Content |
|---|---|
| Contact | First name, last name, avatar with initials, and email |
| Section | Musical section of the contact (link to the section page) |
| Status | Current status (editable dropdown) |
| Contact Date | Date of the last action on the contact |
| Contacted By | User who is in charge of this contact |
| Source | How the contact was added: Manual, Database or Project |
| Actions | Quick action icons (see below) |

The list can be sorted by `id`, `created_at` or `contact_date`, and a search bar allows filtering by these fields. A **Filters** button gives access to more filtering options.

### Quick actions on a contact

On each row, a set of icons in the Actions column allows quick interactions. The icons change automatically depending on the current status of the contact.

| Status | Available icons |
|---|---|
| Not yet contacted | ✉️ Email, 🕐 Mark as contacted, ⋮ Menu |
| Awaiting response / Follow up | ✉️ Email, ✅ Mark as recruited, ❌ Mark as not available, ⋮ Menu |
| Recruited / Not available / Cancelled | ✉️ Email, ⋮ Menu |

- The **✉️ Email** icon opens the user's default mail client through a `mailto:` link. It does **not** use the application's mailing system.
- The **🕐** icon marks the contact as contacted: it sets the contact date to the current time and changes the status to `Awaiting response`.
- The **✅** icon directly marks the contact as `Recruited`.
- The **❌** icon directly marks the contact as `Not available`.
- The **⋮** menu opens a list with two parts: a quick way to change status to any of the 7 statuses, and 3 actions: Edit notes, Edit "Contacted by", and Delete.

Each quick action also updates the `contact_date` to the current time.

## Bulk Actions

When one or more contacts are selected (via the checkbox of each row, or with **Select all**), a panel called **BULK ACTIONS** appears at the top of the list.

It contains:

- A **Send emails** button: sends an email to all selected contacts through the application's mailing system (different from the `mailto:` icon).
- 7 buttons (one for each status) to change the status of all selected contacts at once.

## Recommendations tab

The Recommendations tab lists all recommendations submitted for the current project.

Recommendations are submitted by external people (typically already-recruited musicians or contacts) through the public recommendation link of the project. This link is unique per project and does not require authentication.

When a recommendation is submitted, it appears in this tab. The project manager can then process it and turn it into a recruitment contact if needed.

If no recommendation has been received yet, the tab shows:

> "No recommendations - Recommendations will appear here when people are recommended via the project's recommendation link."

## Statistics tab

The Statistics tab gives an overview of the recruitment performance for the project.

It contains 3 indicators:

| Indicator | Description |
|---|---|
| Total Contacts | Total number of recruitment contacts in the project |
| Recruitment Rate | Percentage of contacts with status `Recruited` |
| Recommendations | Number of pending recommendations |

It also contains a **Status Breakdown** graph showing the distribution of contacts by status.

If the project has no contact yet, the tab shows the message "No recruitment contacts - Start by adding contacts to see statistics".


## Backend

### RecruitmentContact model

**Backend file:** `back/app/models/recruitment_contact.ts`

The `RecruitmentContact` model represents a single recruitment contact for a project. Its fields are:

| Field | Type | Notes |
|---|---|---|
| id | number | Primary key |
| project_id | number | Foreign key to Project |
| contact_id | number or null | Foreign key to global Contact (when imported from the database) |
| first_name | string | Required |
| last_name | string | Required |
| email | string or null | One of email / phone / messenger is required |
| phone | string or null | |
| messenger | string or null | |
| section_id | number or null | Foreign key to Section |
| status | RecruitmentStatus | One of the 7 default statuses |
| contact_method | ContactMethod | manual / email / messenger / phone |
| contact_date | DateTime or null | Date of the last action on the contact |
| last_follow_up | DateTime or null | Date of the last automatic follow-up |
| notes | string or null | Free text |
| recommended_by | string or null | Name of the person who recommended this contact |
| recommender_contact_id | number or null | Foreign key to the contact who recommended |
| is_duplicate | boolean | True if the contact is detected as a duplicate |
| source | string or null | Manual / Database / Project |
| contacted_by | string or null | User in charge of the contact |
| createdAt / updatedAt | DateTime | Automatic |

### Relations

A recruitment contact belongs to:

- A **Project** (`project_id`)
- A **Section** (`section_id`)
- A global **Contact** (`contact_id`, optional)
- Another **Contact** as recommender (`recommender_contact_id`, optional)

### Methods of the model

The model includes several methods used by the controller:

- `markAsContacted()` — Sets the status to `Awaiting response` and updates the contact date. Used by the 🕐 quick action.
- `markAsRecruited()` — Sets the status to `Recruited`. Used by the ✅ quick action.
- `markAsNotAvailable()` — Sets the status to `Not available`. Used by the ❌ quick action.
- `markForFollowUp()` — Sets the status to `Follow up` and updates the last follow-up date.
- `markAsCancelled()` — Sets the status to `Cancelled`.
- `shouldFollowUp(days)` — Returns true if the contact should be moved to `Follow up` (based on the contact date and the delay).
- `isInProgress()` — Returns true if the status is `Awaiting response` or `Follow up`.
- `isCompleted()` — Returns true if the status is `Recruited`, `Not available` or `Cancelled`.
- `getStatusBadge()` — Returns the label, color and icon associated with the current status.

### Other backend files

| File | Purpose |
|---|---|
| `back/app/controllers/recruitment_controller.ts` | Main controller for recruitment contacts (routes API) |
| `back/app/controllers/recruitment_recommendation_controller.ts` | Controller for the public recommendation system |
| `back/app/models/recruitment_settings.ts` | Settings of the recruitment (follow-up delay, etc.), one per project |
| `back/app/models/recruitment_recommendation.ts` | Model for the recommendations received |
| `back/app/mails/recruitment_email.ts` | Email sent to candidates |
| `back/app/mails/recruitment_notification.ts` | Internal notification email |



## Database structure

The Recruitment feature uses 3 main tables.

### recruitment_contacts

**Migration file:** `back/database/migrations/1754614941141_create_recruitment_contacts_table.ts`

Stores the recruitment contacts of each project.

| Column | SQL type | Notes |
|---|---|---|
| id | increments | Primary key |
| project_id | integer | FK to `projects.id`, ON DELETE CASCADE |
| contact_id | integer (nullable) | FK to `contacts.id`, ON DELETE CASCADE |
| first_name | string(255) | NOT NULL |
| last_name | string(255) | NOT NULL |
| email | string(255) (nullable) | |
| phone | string(255) (nullable) | |
| messenger | string(255) (nullable) | |
| section_id | integer (nullable) | FK to `sections.id`, ON DELETE SET NULL |
| status | enum | Default: `not_yet_contacted`. 7 values: not_yet_contacted, awaiting_response, to_follow_up, not_available, pending_validation, cancelled, recruited |
| contact_method | enum | Default: `manual`. 4 values: manual, email, messenger, phone |
| contact_date | timestamp (nullable) | |
| last_follow_up | timestamp (nullable) | |
| notes | text (nullable) | |
| recommended_by | string (nullable) | |
| recommender_contact_id | integer (nullable) | FK to `contacts.id`, ON DELETE SET NULL |
| is_duplicate | boolean | Default: false |
| source | string (nullable) | One of: database, manual, recommendation, project |
| created_at | timestamp | |
| updated_at | timestamp | |

Indexes:
- `(project_id, status)` for fast filtering
- `(contact_date)` for the automatic follow-up query
- `UNIQUE(project_id, contact_id)` to prevent the same global contact from being imported twice into the same project

A later migration adds the `contacted_by` column (string, nullable):
- `1755128640568_create_contacted_by_to_recruitment_contacts_table.ts`

### recruitment_settings

**Migration file:** `back/database/migrations/1754617007020_create_recruitment_settings_table.ts`

Stores the automatic follow-up settings of each project (one row per project).

| Column | SQL type | Notes |
|---|---|---|
| id | increments | Primary key |
| project_id | integer | FK to `projects.id`, ON DELETE CASCADE |
| follow_up_days | integer | Default: 7. Number of days before a contact is automatically moved to `to_follow_up`. |
| auto_follow_up_enabled | boolean | Default: true. Toggle of the automatic follow-up. |
| created_at | timestamp | |
| updated_at | timestamp | |

Constraint: `UNIQUE(project_id)` ensures one settings row per project.

A later migration added the `auto_import` column:
- `1755462588293_create_auto_import_to_recruitment_settings_table.ts`

### recruitment_recommendations

**Migration file:** `back/database/migrations/1754617158633_create_recruitment_recommendations_table.ts`

Stores the recommendations received via the public recommendation link of the project.

| Column | SQL type | Notes |
|---|---|---|
| id | increments | Primary key |
| project_id | integer | FK to `projects.id`, ON DELETE CASCADE |
| recommender_name | string(255) | NOT NULL. Name of the person making the recommendation |
| recommender_email | string(255) (nullable) | |
| recommended_first_name | string(255) | NOT NULL. Name of the recommended person |
| recommended_last_name | string(255) | NOT NULL |
| recommended_email | string(255) (nullable) | |
| recommended_phone | string(255) (nullable) | |
| recommended_messenger | string(255) (nullable) | |
| recommended_instrument | string(255) (nullable) | |
| recommendation_message | text (nullable) | Free message from the recommender |
| status | enum | Default: `pending`. 4 values: pending, ignored, contacted_email, contacted_manual |
| recruitment_contact_id | integer (nullable) | FK to `recruitment_contacts.id`, ON DELETE SET NULL. Links to the recruitment contact created from this recommendation (if any) |
| created_at | timestamp | |
| updated_at | timestamp | |

Index: `(project_id, status)` for fast filtering of pending recommendations.

A later migration applied a fix to this table:
- `1756095460790_create_fix_recruitment_recommendations_table.ts`

### Main relations

- `recruitment_contacts.project_id` → `projects.id` (CASCADE)
- `recruitment_contacts.contact_id` → `contacts.id` (CASCADE, optional)
- `recruitment_contacts.section_id` → `sections.id` (SET NULL, optional)
- `recruitment_contacts.recommender_contact_id` → `contacts.id` (SET NULL, optional)
- `recruitment_settings.project_id` → `projects.id` (CASCADE, unique)
- `recruitment_recommendations.project_id` → `projects.id` (CASCADE)
- `recruitment_recommendations.recruitment_contact_id` → `recruitment_contacts.id` (SET NULL, optional). Links a recommendation to the recruitment contact it produced.


## Main workflows (developer perspective)

### Adding a contact manually

1. The user fills the Add Manual form.
2. The frontend sends a request to the `createManualContact` controller method.
3. The backend validates the form (first_name, last_name required, at least one contact method).
4. The controller checks for duplicates using a name similarity algorithm (edit distance).
5. A new `RecruitmentContact` row is inserted with `status = not_yet_contacted` and `source = manual`.
6. The frontend refreshes the contact list.

### Changing a status

When the user clicks a quick action icon (🕐, ✅, ❌) or a status in the ⋮ menu or in Bulk Actions, the frontend calls the `updateContactStatus` controller method with the new status. The controller updates the contact directly (it does not go through the `markAs*` helper methods of the model).

### Automatic Follow-up

The automatic follow-up update happens **only when the user saves the recruitment settings**. It is not triggered on every page load nor by a scheduled task.

The mechanism is:

1. The user opens Settings, modifies the delay or the toggle, and clicks Save.
2. The frontend calls the `updateSettings` controller method.
3. The controller updates the settings and then calls a private method `updateFollowUpStatuses(projectId, followUpDays)`.
4. The method selects all contacts of the project with status `awaiting_response` and a non-null `contact_date`.
5. For each contact older than `followUpDays`, the status is changed to `to_follow_up`.

> Note: this implementation matches the UI message displayed in the Settings popup ("Impact of changes: Modifying the follow-up delay will automatically recalculate the status...").

### Recommendation submission

A recommendation is submitted through the public recommendation link of the project (no authentication required). The submitted data is inserted in `recruitment_recommendations` with `status = pending`. The project manager can later process the recommendation via the `handleRecommendation` controller method: ignore it (`status = ignored`) or convert it into a recruitment contact, in which case the `recruitment_contact_id` of the recommendation is set to the new contact's id.

### Synchronization with Participants

When a participant is removed from a project, the `updateRecruitmentOnParticipantDeletion` controller method is triggered. It synchronizes the state of the related recruitment contact (the exact behavior should be confirmed by reading this method in the controller).

## Known issues and attention points

- **Mismatch between UI labels and code values for statuses.** The UI shows "Follow up" but the database value is `to_follow_up`. UI labels are human-friendly, code values use snake_case.
- **`contact_date` is updated at every quick action.** It does not represent the date of the first contact but the date of the last action on the contact. This affects the automatic follow-up logic.
- **The automatic follow-up runs only when settings are saved.** If the user never opens or modifies the Settings popup, contacts in `awaiting_response` will not be automatically moved to `to_follow_up`. There is no cron job or page-load trigger.
- **Two different ways to send emails.** The ✉️ icon on a contact row uses a `mailto:` link (opens the user's mail client). The "Send emails" bulk button uses the application's mailing system through the `sendRecruitmentEmails` controller method.
- **The 7 default statuses are hardcoded in TypeScript** (`RecruitmentStatus` union type in `recruitment_contact.ts`) and in the database enum. Adding a new default status requires modifying both the source code and the database (new migration).
- **Custom statuses behavior on delete.** When a custom status is deleted while still used by contacts, the effect on those contacts is not documented yet and should be tested.
- **No token on the public recommendation link.** The `recruitment_recommendations` table has no security token column. The link uses the project id directly. Anyone with the link can submit a recommendation.
- **`autoImportAllContacts` method exists in the controller** and matches the `auto_import` column added to `recruitment_settings`. The UI activation point for this feature was not identified during this exploration.

## How to modify this feature

To modify or extend the Recruitment feature, the main entry points are:

1. **Model** — `back/app/models/recruitment_contact.ts` for the data structure and helper methods on a contact.
2. **Controller** — `back/app/controllers/recruitment_controller.ts` (around 1300 lines) for the API routes, validation, duplicate detection, and the follow-up update logic.
3. **Settings model** — `back/app/models/recruitment_settings.ts` for the follow-up configuration.
4. **Recommendation controller** — `back/app/controllers/recruitment_recommendation_controller.ts` for the public recommendation flow.
5. **Migrations** — `back/database/migrations/*_recruitment_*.ts` for any database schema change. New columns must be added via a new migration, not by modifying the existing ones.
6. **Frontend pages** — Svelte pages and components related to recruitment (typically under `front/src/routes/projects/[id]/management/recruitment/`, to be confirmed by exploring the front project).

When adding a new feature, keep the same conventions: status values as snake_case in the database and TypeScript union types in the model, validation in the controller, and a dedicated migration for any schema change.