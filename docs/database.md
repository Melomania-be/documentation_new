# Database Structure

## Overview

The database is a **PostgreSQL** relational database. It stores all data related to musical projects, repertoire, participants, instruments, contacts, mailing, accounting, and recruitment managed through the application.
<iframe width="800" height="500" src='https://dbdiagram.io/e/6a0c1da89f1f8ec47b4d081c/6a0c1dae697f99c167ad3e22'> </iframe>
To edit this schema, go to https://dbdiagram.io/d and sign in using the dummy email account melomaniadevmail@gmail.com. The sign-in requires to give an OTP sent to the email adress, so you need to log into the dummy account on gmail (pw: melomania_devMail1) to retrieve it. 
To this day, the contents of this schema is based on the following dump from 19/5/2026:
<a href="/files/dump_19-5-2026.sql" download="dump_19-5-2026.sql" style={{
  display: 'inline-block',
  backgroundColor: '#2563eb',
  color: 'white',
  padding: '10px 20px',
  borderRadius: '6px',
  fontWeight: 'bold',
  textDecoration: 'none',
  marginTop: '5px'
}}>
  Download dump (.sql)
</a>

Le lien vers le schéma interactif est : https://dbdiagram.io/d/Schema-diagram-6a0c7d94697f99c167b3a5f3 

## Schema diagram

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   TypeOfPiece   │       │    Composer     │       │   Instrument    │
│─────────────────│       │─────────────────│       │─────────────────│
│ id (PK)         │       │ id (PK)         │       │ id (PK)         │
│ name            │       │ first_name      │       │ name            │
└────────┬────────┘       │ last_name       │       └────────┬────────┘
         │                └────────┬────────┘                │
         │                         │                         │
         ▼                         ▼                         ▼
┌─────────────────────────────────────────┐       ┌─────────────────┐
│              Repertoire                 │       │     Plays       │
│─────────────────────────────────────────│       │─────────────────│
│ id (PK)                                 │       │ id (PK)         │
│ title                                   │       │ participant_id  │
│ type_id (FK) → TypeOfPiece              │       │ instrument_id   │
│ composer_id (FK) → Composer             │       │ program_id (FK) │
└────────────────────┬────────────────────┘       └────────┬────────┘
                     │                                     │
                     │         ┌─────────────────┐         │
                     │         │    Concert      │         │
                     └────────►│─────────────────│◄────────┘
                               │ id_concert(PK)  │
                               │ name            │    ┌─────────────────┐
                               │ description     │◄── │    Progam       │
                               │ date            │    │─────────────────│
                               └────────┬────────┘    │ id (PK)         │
                                        │             │ name            │
                                        ▼             | place           |
                               ┌─────────────────┐    |id_concert (FK)  |
                               │   Participant   │    └─────────────────┘
                               │─────────────────│
                               │ id (PK)         │──────────────┐
                               │ first_name      │              │
                               │ last_name       │              ▼                     
                               │ contact_id (FK) │─────► ┌─────────────────┐                  ┌─────────────────────┐
                               │ project_id (FK) │       │    Contacts     │                  │       Mailing       │
                               └────────┬────────┘       │─────────────────│                  │─────────────────────│
                                        │                │ id (PK)         │ ◄────────        │ id (PK)             │
                               ┌────────┴────────┐       │ email           │                  │ subject             │
                               ▼                 ▼       │ phone           │                  │ body                │
                     ┌──────────────┐  ┌──────────────┐  └─────────────────┘                  │ sent_at             │
                     │  Accounting  │  │ Recruitment  │                                       │ recipient_count     │
                     │──────────────│  │──────────────│                                       └─────────────────────┘
                     │ id (PK)      │  │ id (PK)      │
                     │ part_id (FK) │  │ part_id (FK) │
                     │ amount       │  │ status       │
                     │ type         │  │ applied_at   │
                     │ date         │  └──────────────┘
                     │ description  │
                     └──────────────┘

```

## Tables

# Database Tables
*Edited by Michelle*

---

### `folders`
Stores the folder structure used to organize files within the application. Folders can be nested and linked to a project or a specific piece.

| Column              | Type      | Description                                       |
|---------------------|-----------|---------------------------------------------------|
| id                  | int PK    | Unique identifier                                 |
| name                | string    | Name of the folder                                |
| parent_id           | int FK    | References `folders.id` (parent folder, if any)  |
| project_id          | int FK    | References `projects.id`                         |
| piece_id            | int FK    | References `pieces.id`                           |
| is_system_generated | boolean   | Whether the folder was auto-created by the system |
| created_at          | timestamp | Creation date                                     |
| updated_at          | timestamp | Last update date                                  |

**Relations:**
- belongs to one `projects`
- belongs to one `pieces`
- can be nested inside another `folders` via `parent_id` (self-referencing)

---

### `forms`
Stores the individual form fields or responses linked to a registration.

| Column          | Type      | Description                        |
|-----------------|-----------|------------------------------------|
| id              | int PK    | Unique identifier                  |
| text            | text      | Content or answer of the field     |
| type            | string    | Type of form field                 |
| registration_id | int FK    | References `registrations.id`      |
| created_at      | timestamp | Creation date                      |
| updated_at      | timestamp | Last update date                   |

**Relations:**
- belongs to one `registrations`

---

### `instruments`
Stores all the musical instruments used by contacts and participants.

| Column     | Type      | Description                              |
|------------|-----------|------------------------------------------|
| id         | int PK    | Unique identifier                        |
| name       | string    | Name of the instrument                   |
| family     | string    | Instrument family (e.g. Strings, Brass)  |
| created_at | timestamp | Creation date                            |
| updated_at | timestamp | Last update date                         |

**Relations:**
- linked to `contacts` via `plays`
- linked to `sections` via `played_in_sections`
- linked to `recommendeds` via `recommendeds_instruments`

---

### `lists`
Stores named lists used in the application for various organizational purposes.

| Column     | Type      | Description       |
|------------|-----------|-------------------|
| id         | int PK    | Unique identifier |
| name       | string    | Name of the list  |
| created_at | timestamp | Creation date     |
| updated_at | timestamp | Last update date  |

---

### `mail_templates`
Stores reusable email templates used throughout the application (recruitment, registration, etc.).

| Column     | Type      | Description                           |
|------------|-----------|---------------------------------------|
| id         | int PK    | Unique identifier                     |
| name       | string    | Name of the template                  |
| content    | text      | HTML or text content of the template  |
| is_default | boolean   | Whether this is the default template  |
| created_at | timestamp | Creation date                         |
| updated_at | timestamp | Last update date                      |

**Relations:**
- referenced by `outgoing_mails` via `mail_template_id`

---

### `materials`
Stores the different editions or versions of a musical piece (sheet music, parts, etc.).

| Column         | Type      | Description                                    |
|----------------|-----------|------------------------------------------------|
| id             | int PK    | Unique identifier                              |
| piece_id       | int FK    | References `pieces.id`                        |
| name           | string    | Name of the material/edition                   |
| description    | text      | Optional description                           |
| edition        | string    | Edition name or number                         |
| editor         | string    | Name of the editor/publisher                   |
| notes          | text      | Additional notes                               |
| is_default     | boolean   | Whether this is the default material           |
| is_active      | boolean   | Whether this material is currently active      |
| files_count    | int       | Number of files attached to this material      |
| projects_count | int       | Number of projects using this material         |
| created_at     | timestamp | Creation date                                  |
| updated_at     | timestamp | Last update date                               |

**Relations:**
- belongs to one `pieces`
- referenced by `performed_ins` via `material_id`

---

### `outgoing_mails`
Logs all outgoing emails sent by the application (recruitment messages, registration emails, etc.).

| Column           | Type      | Description                              |
|------------------|-----------|------------------------------------------|
| id               | int PK    | Unique identifier                        |
| type             | string    | Type/category of the email               |
| receiver_id      | int FK    | References `contacts.id` (recipient)    |
| project_id       | int FK    | References `projects.id`                |
| mail_template_id | int FK    | References `mail_templates.id`          |
| sent             | boolean   | Whether the email was successfully sent  |
| created_at       | timestamp | Creation date                            |
| updated_at       | timestamp | Last update date                         |

**Relations:**
- belongs to one `mail_templates`
- belongs to one `projects`
- targets one `contacts` as receiver

---

### `participants`
Stores the musicians participating in a specific project. Each participant is linked to a contact (their identity) and a section.

| Column                | Type      | Description                                             |
|-----------------------|-----------|---------------------------------------------------------|
| id                    | int PK    | Unique identifier                                       |
| project_id            | int FK    | References `projects.id`                               |
| contact_id            | int FK    | References `contacts.id`                               |
| section_id            | int FK    | References `sections.id`                               |
| accepted              | boolean   | Whether the participant has been accepted               |
| last_activity         | timestamp | Date of their last activity in the app                 |
| is_section_leader     | boolean   | Whether this participant is the section leader         |
| audition_status       | text      | Status: none, pending, completed, expired              |
| audition_requested_at | timestamp | When the audition was requested                        |
| audition_deadline     | timestamp | Deadline for the audition                              |
| created_at            | timestamp | Creation date                                           |
| updated_at            | timestamp | Last update date                                        |

**Relations:**
- belongs to one `projects`
- belongs to one `contacts`
- belongs to one `sections`
- linked to `rehearsals` via `participates_ins`
- linked to concerts via `participates_in_concerts`

---

### `participates_in_concerts`
Junction table recording which participants take part in which concerts.

| Column         | Type      | Description                          |
|----------------|-----------|--------------------------------------|
| participant_id | int PK FK | References `participants.id`         |
| concert_id     | int PK FK | References the concert/callsheet     |
| comment        | text      | Optional comment                     |
| created_at     | timestamp | Creation date                        |
| updated_at     | timestamp | Last update date                     |

**Relations:**
- belongs to one `participants`
- belongs to one concert/callsheet

---

### `participates_ins`
Junction table recording which participants attend which rehearsals.

| Column         | Type      | Description                      |
|----------------|-----------|----------------------------------|
| rehearsal_id   | int PK FK | References `rehearsals.id`       |
| participant_id | int PK FK | References `participants.id`     |
| comment        | text      | Optional attendance comment      |
| created_at     | timestamp | Creation date                    |
| updated_at     | timestamp | Last update date                 |

**Relations:**
- belongs to one `rehearsals`
- belongs to one `participants`

---

### `performed_ins`
Junction table linking pieces to the projects they are performed in, with ordering and material selection.

| Column             | Type      | Description                               |
|--------------------|-----------|-------------------------------------------|
| project_id         | int PK FK | References `projects.id`                 |
| piece_id           | int PK FK | References `pieces.id`                   |
| order              | int       | Performance order within the project      |
| material_id        | int FK    | References `materials.id`                |
| material_specified | boolean   | Whether a specific material was chosen    |
| created_at         | timestamp | Creation date                             |
| updated_at         | timestamp | Last update date                          |

**Relations:**
- belongs to one `projects`
- belongs to one `pieces`
- belongs to one `materials`

---

### `pieces`
Stores all the musical pieces in the application's repertoire.

| Column               | Type      | Description                                    |
|----------------------|-----------|------------------------------------------------|
| id                   | int PK    | Unique identifier                              |
| name                 | string    | Title of the piece                             |
| opus                 | string    | Opus number                                    |
| year_of_composition  | string    | Year the piece was composed                    |
| composer_id          | int FK    | References `contacts.id` (the composer)       |
| type_of_piece_id     | int FK    | References `type_of_pieces.id`                |
| folder_id            | int FK    | References `folders.id`                       |
| arranger             | string    | Name of the arranger if applicable             |
| selected_material_id | int FK    | References `materials.id` (default material)  |
| created_at           | timestamp | Creation date                                  |
| updated_at           | timestamp | Last update date                               |

**Relations:**
- belongs to one `type_of_pieces`
- belongs to one composer via `contacts`
- belongs to one `folders`
- has many `materials`
- linked to `projects` via `performed_ins`

---

### `played_in_sections`
Junction table linking instruments to the sections they are played in.

| Column        | Type      | Description                  |
|---------------|-----------|------------------------------|
| section_id    | int PK FK | References `sections.id`     |
| instrument_id | int PK FK | References `instruments.id`  |
| created_at    | timestamp | Creation date                |
| updated_at    | timestamp | Last update date             |

**Relations:**
- belongs to one `sections`
- belongs to one `instruments`

---

### `plays`
Links a contact to the instrument(s) they play, with a proficiency level.

| Column            | Type      | Description                              |
|-------------------|-----------|------------------------------------------|
| contact_id        | int PK FK | References `contacts.id`                |
| instrument_id     | int PK FK | References `instruments.id`             |
| proficiency_level | string    | Level of proficiency (default: unknown)  |
| created_at        | timestamp | Creation date                            |
| updated_at        | timestamp | Last update date                         |

**Relations:**
- belongs to one `contacts`
- belongs to one `instruments`

---

### `projects`
Stores the musical projects managed in the application (concerts, seasons, etc.).

| Column           | Type      | Description                      |
|------------------|-----------|----------------------------------|
| id               | int PK    | Unique identifier                |
| name             | string    | Name of the project              |
| section_group_id | int FK    | References `section_groups.id`   |
| folder_id        | int FK    | References `folders.id`         |
| created_at       | timestamp | Creation date                    |
| updated_at       | timestamp | Last update date                 |

**Relations:**
- belongs to one `section_groups`
- belongs to one `folders`
- has many `participants`
- has many `rehearsals`
- linked to `pieces` via `performed_ins`
- linked to `contacts` via `responsibles`
- has one `registrations`
- has one `recruitment_settings`

---

### `recommendeds`
Stores people recommended by existing members as potential recruits for a project, before a full recruitment record is created.

| Column     | Type      | Description                              |
|------------|-----------|------------------------------------------|
| id         | int PK    | Unique identifier                        |
| first_name | string    | First name of the recommended person    |
| last_name  | string    | Last name of the recommended person     |
| email      | string    | Email address                            |
| phone      | string    | Phone number                             |
| messenger  | string    | Messenger contact                        |
| comment    | text      | Optional comment from the recommender   |
| project_id | int FK    | References `projects.id`                |
| created_at | timestamp | Creation date                            |
| updated_at | timestamp | Last update date                         |

**Relations:**
- belongs to one `projects`
- linked to `instruments` via `recommendeds_instruments`

---

### `recommendeds_instruments`
Junction table linking recommended people to the instruments they play.

| Column         | Type      | Description                      |
|----------------|-----------|----------------------------------|
| recommended_id | int PK FK | References `recommendeds.id`     |
| instrument_id  | int PK FK | References `instruments.id`      |
| created_at     | timestamp | Creation date                    |
| updated_at     | timestamp | Last update date                 |

**Relations:**
- belongs to one `recommendeds`
- belongs to one `instruments`

---

### `recruitment_contacts`
Stores the full recruitment pipeline for a project. Each record represents a person being actively recruited, with status and follow-up tracking.

| Column                 | Type      | Description                                                                                                        |
|------------------------|-----------|--------------------------------------------------------------------------------------------------------------------|
| id                     | int PK    | Unique identifier                                                                                                  |
| project_id             | int FK    | References `projects.id`                                                                                          |
| contact_id             | int FK    | References `contacts.id` (if the person is already in the system)                                                |
| first_name             | string    | First name                                                                                                         |
| last_name              | string    | Last name                                                                                                          |
| email                  | string    | Email address                                                                                                      |
| phone                  | string    | Phone number                                                                                                       |
| messenger              | string    | Messenger contact                                                                                                  |
| section_id             | int FK    | References `sections.id` (target section)                                                                        |
| status                 | text      | Recruitment status: not_yet_contacted, awaiting_response, to_follow_up, not_available, pending_validation, cancelled, recruited |
| contact_method         | text      | How they were contacted: manual, email, messenger, phone                                                          |
| contact_date           | timestamp | Date of first contact                                                                                              |
| last_follow_up         | timestamp | Date of last follow-up                                                                                             |
| notes                  | text      | Internal notes                                                                                                     |
| recommended_by         | string    | Name of the person who recommended them                                                                           |
| recommender_contact_id | int FK    | References `contacts.id` (the recommender)                                                                       |
| is_duplicate           | boolean   | Whether this record is flagged as a duplicate                                                                     |
| source                 | string    | How this person entered the pipeline                                                                               |
| contacted_by           | string    | Who made the contact                                                                                               |
| created_at             | timestamp | Creation date                                                                                                      |
| updated_at             | timestamp | Last update date                                                                                                   |

**Relations:**
- belongs to one `projects`
- belongs to one `contacts`
- belongs to one `sections`

---

### `recruitment_recommendations`
Stores external recommendations submitted via a form, before they are processed into a `recruitment_contacts` record.

| Column                 | Type      | Description                                                          |
|------------------------|-----------|----------------------------------------------------------------------|
| id                     | int PK    | Unique identifier                                                    |
| project_id             | int FK    | References `projects.id`                                            |
| recommender_name       | string    | Name of the person making the recommendation                        |
| recommender_email      | string    | Email of the recommender                                             |
| recommended_first_name | string    | First name of the recommended person                                |
| recommended_last_name  | string    | Last name of the recommended person                                 |
| recommended_email      | string    | Email of the recommended person                                     |
| recommended_phone      | string    | Phone of the recommended person                                     |
| recommended_messenger  | string    | Messenger contact                                                    |
| recommended_instrument | string    | Instrument they play                                                 |
| recommendation_message | text      | Message from the recommender                                         |
| status                 | text      | Processing status: pending, ignored, contacted_email, contacted_manual |
| recruitment_contact_id | int FK    | References `recruitment_contacts.id` once processed                |
| created_at             | timestamp | Creation date                                                        |
| updated_at             | timestamp | Last update date                                                     |

**Relations:**
- belongs to one `projects`
- resolved into one `recruitment_contacts`

---

### `recruitment_settings`
Stores per-project configuration for the recruitment module.

| Column                 | Type      | Description                                       |
|------------------------|-----------|---------------------------------------------------|
| id                     | int PK    | Unique identifier                                 |
| project_id             | int FK    | References `projects.id` (unique per project)    |
| follow_up_days         | int       | Number of days before a follow-up is triggered   |
| auto_follow_up_enabled | boolean   | Whether automatic follow-ups are enabled         |
| auto_import_enabled    | boolean   | Whether automatic import of recommendations is on |
| last_auto_import       | timestamp | Date of the last automatic import                 |
| created_at             | timestamp | Creation date                                     |
| updated_at             | timestamp | Last update date                                  |

**Relations:**
- belongs to one `projects` (one-to-one)

---

### `registrations`
Stores the registration form associated with a project, used to onboard new participants.

| Column         | Type      | Description                           |
|----------------|-----------|---------------------------------------|
| id             | int PK    | Unique identifier                     |
| project_id     | int FK    | References `projects.id`             |
| last_send_date | timestamp | Date the registration was last sent   |
| created_at     | timestamp | Creation date                         |
| updated_at     | timestamp | Last update date                      |

**Relations:**
- belongs to one `projects`
- has many `forms`

---

### `rehearsals`
Stores the rehearsal sessions associated with a project.

| Column     | Type      | Description                           |
|------------|-----------|---------------------------------------|
| id         | int PK    | Unique identifier                     |
| project_id | int FK    | References `projects.id`             |
| start_date | timestamp | Start date and time of the rehearsal  |
| end_date   | timestamp | End date and time of the rehearsal    |
| place      | string    | Location of the rehearsal             |
| comment    | text      | Optional comment                      |
| created_at | timestamp | Creation date                         |
| updated_at | timestamp | Last update date                      |

**Relations:**
- belongs to one `projects`
- linked to `participants` via `participates_ins`

---

### `responsibles`
Links contacts to the projects they are responsible for (project managers, conductors, etc.).

| Column     | Type      | Description                  |
|------------|-----------|------------------------------|
| project_id | int PK FK | References `projects.id`     |
| contact_id | int PK FK | References `contacts.id`     |
| created_at | timestamp | Creation date                |
| updated_at | timestamp | Last update date             |

**Relations:**
- belongs to one `projects`
- belongs to one `contacts`

---

### `saves`
Stores miscellaneous application-level key-value settings and configuration variables.

| Column     | Type      | Description                   |
|------------|-----------|-------------------------------|
| id         | int PK    | Unique identifier             |
| variable   | string    | Name of the setting/variable  |
| value      | string    | Value of the setting          |
| created_at | timestamp | Creation date                 |
| updated_at | timestamp | Last update date              |

---

### `section_groups`
Groups multiple sections together under a named group (e.g. "Orchestra", "Choir").

| Column     | Type      | Description              |
|------------|-----------|--------------------------|
| id         | int PK    | Unique identifier        |
| name       | string    | Name of the group        |
| created_at | timestamp | Creation date            |
| updated_at | timestamp | Last update date         |

**Relations:**
- referenced by `projects` via `section_group_id`
- linked to `sections` via `section_section_groups`

---

### `section_pdfs`
Stores PDF files assigned to a section within a project (e.g. sheet music parts for auditions).

| Column          | Type      | Description                                   |
|-----------------|-----------|-----------------------------------------------|
| id              | int PK    | Unique identifier                             |
| project_id      | int FK    | References `projects.id`                     |
| section_id      | int FK    | References `sections.id`                     |
| file_id         | int FK    | References the file                           |
| title           | string    | Title of the PDF                              |
| description     | text      | Optional description                          |
| order           | int       | Display order                                 |
| is_required     | boolean   | Whether this PDF is required for the section  |
| is_active       | boolean   | Whether this PDF is currently active          |
| auditions_count | int       | Number of auditions linked to this PDF        |
| created_at      | timestamp | Creation date                                 |
| updated_at      | timestamp | Last update date                              |

**Relations:**
- belongs to one `projects`
- belongs to one `sections`

---

### `section_section_groups`
Junction table linking sections to section groups, with an ordering field.

| Column           | Type      | Description                      |
|------------------|-----------|----------------------------------|
| section_id       | int PK FK | References `sections.id`         |
| section_group_id | int PK FK | References `section_groups.id`   |
| order            | int       | Display order within the group   |
| created_at       | timestamp | Creation date                    |
| updated_at       | timestamp | Last update date                 |

**Relations:**
- belongs to one `sections`
- belongs to one `section_groups`

---

### `sections`
Stores the orchestra or ensemble sections (e.g. Strings, Brass, Woodwinds, Percussion).

| Column     | Type      | Description                               |
|------------|-----------|-------------------------------------------|
| id         | int PK    | Unique identifier                         |
| name       | string    | Name of the section                       |
| size       | int       | Expected number of musicians in the section |
| created_at | timestamp | Creation date                             |
| updated_at | timestamp | Last update date                          |

**Relations:**
- linked to `section_groups` via `section_section_groups`
- linked to `instruments` via `played_in_sections`
- referenced by `participants` via `section_id`
- referenced by `recruitment_contacts` via `section_id`
- referenced by `section_pdfs` via `section_id`

---

### `seens`
Tracks which participants have seen a given callsheet.

| Column         | Type      | Description                      |
|----------------|-----------|----------------------------------|
| callsheet_id   | int PK FK | References the callsheet         |
| participant_id | int PK FK | References `participants.id`     |
| created_at     | timestamp | Creation date                    |
| updated_at     | timestamp | Last update date                 |

**Relations:**
- belongs to one `participants`
- belongs to one callsheet

---

### `shared_folders`
Stores public sharing links for folders, allowing external access via a unique token.

| Column     | Type      | Description                              |
|------------|-----------|------------------------------------------|
| id         | int PK    | Unique identifier                        |
| folder_id  | int FK    | References `folders.id`                 |
| token      | string    | Unique public access token               |
| view_count | int       | Number of times the link was accessed    |
| is_active  | boolean   | Whether the share link is still active   |
| expires_at | timestamp | Expiry date of the share link            |
| created_at | timestamp | Creation date                            |
| updated_at | timestamp | Last update date                         |

**Relations:**
- belongs to one `folders`

---

### `type_of_pieces`
Stores the different categories of musical pieces (e.g. Symphony, Concerto, Sonata).

| Column     | Type      | Description              |
|------------|-----------|--------------------------|
| id         | int PK    | Unique identifier        |
| name       | string    | Unique name of the type  |
| created_at | timestamp | Creation date            |
| updated_at | timestamp | Last update date         |

**Relations:**
- referenced by `pieces` via `type_of_piece_id`

---

### `users`
Stores the application's authenticated users (administrators).

| Column     | Type      | Description              |
|------------|-----------|--------------------------|
| id         | int PK    | Unique identifier        |
| full_name  | string    | Full name of the user    |
| email      | string    | Unique email address     |
| password   | string    | Hashed password          |
| created_at | timestamp | Creation date            |
| updated_at | timestamp | Last update date         |


## Notes

> ⚠️ The database schema is managed via **AdonisJS Lucid** migrations located in the `back` repository under `database/migrations/`. Always run migrations after pulling new changes:
> ```bash
> node ace migration:run
> ```

> ℹ️ A legacy migration script written in Python is available in the `database` repository under `migrationScript/`. It was used to migrate data from the old Melomania database and is kept for historical reference only.
