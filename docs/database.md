# Database Structure

## Overview

The database is a **PostgreSQL** relational database. It stores all data related to musical projects, repertoire, participants, instruments, contacts, mailing, accounting, and recruitment managed through the application.

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

### `TypeOfPiece`
Stores the different categories of musical pieces (e.g. Symphony, Concerto, Sonata, etc.).

| Column | Type   | Description              |
|--------|--------|--------------------------|
| id     | int PK | Unique identifier        |
| name   | string | Name of the type/category |

---

### `Composer`
Stores information about the composers of musical pieces.

| Column     | Type   | Description         |
|------------|--------|---------------------|
| id         | int PK | Unique identifier   |
| first_name | string | Composer first name |
| last_name  | string | Composer last name  |

---

### `Repertoire`
Stores all the musical pieces in the application's repertoire. Each piece is linked to a composer and a type.

| Column      | Type   | Description                            |
|-------------|--------|----------------------------------------|
| id          | int PK | Unique identifier                      |
| title       | string | Title of the piece                     |
| type_id     | int FK | References `TypeOfPiece.id`            |
| composer_id | int FK | References `Composer.id`               |

**Relations:**
- belongs to one `TypeOfPiece`
- belongs to one `Composer`
- can be linked to many `Projects`

---

### `Concerts`
Stores the musical projects managed in the application (concerts, rehearsals, events, etc.).

| Column      | Type   | Description                       |
|-------------|--------|-----------------------------------|
| id          | int PK | Unique identifier                 |
| name        | string | Name of the project               |
| description | text   | Description of the project        |
| date        | date   | Date of the project               |

**Relations:**
- has many `Participants`
- has many pieces from `Repertoire`

---

### `Sections`
Stores the orchestra or ensemble sections (e.g. Strings, Brass, Woodwinds, Percussion).

| Column | Type   | Description        |
|--------|--------|--------------------|
| id     | int PK | Unique identifier  |
| name   | string | Name of the section |

---

### `Instrument`
Stores all the musical instruments used by participants.

| Column | Type   | Description           |
|--------|--------|-----------------------|
| id     | int PK | Unique identifier     |
| name   | string | Name of the instrument |

---

### `Participant`
Stores the people (musicians) participating in a project.

| Column     | Type   | Description                    |
|------------|--------|--------------------------------|
| id         | int PK | Unique identifier              |
| first_name | string | Participant first name         |
| last_name  | string | Participant last name          |
| contact_id | int FK | References `Contacts.id`       |
| project_id | int FK | References `Projects.id`       |

> ⚠️ **Design note:** `Participant` references `Contacts` via a `contact_id` foreign key rather than storing contact details directly. This avoids data duplication and ensures that if a contact's email or phone changes, it only needs to be updated in one place. Storing the data in hard in `Participant` would create redundancy and a risk of inconsistency between tables.

**Relations:**
- belongs to one `Project`
- belongs to one `Contacts` entry
- can play many instruments via `Plays`

---

### `Plays`
Junction table that links a participant to the instrument(s) they play and the section they belong to.

| Column         | Type   | Description                    |
|----------------|--------|--------------------------------|
| id             | int PK | Unique identifier              |
| participant_id | int FK | References `Participant.id`    |
| instrument_id  | int FK | References `Instrument.id`     |
| section_id     | int FK | References `Sections.id`       |

**Relations:**
- belongs to one `Participant`
- belongs to one `Instrument`
- belongs to one `Section`

---

### `Contacts`
Stores the contact information (email, phone) independently from participants. A participant references a contact via `contact_id`, which avoids storing contact details in hard in multiple places.

| Column | Type   | Description       |
|--------|--------|-------------------|
| id     | int PK | Unique identifier |
| email  | string | Email address     |
| phone  | string | Phone number      |

**Relations:**
- referenced by `Participant` via `contact_id`

---

### `Mailing`
Stores the mailing campaigns sent to participants or groups of participants.

| Column           | Type     | Description                        |
|------------------|----------|------------------------------------|
| id               | int PK   | Unique identifier                  |
| subject          | string   | Subject of the email               |
| body             | text     | Content of the email               |
| sent_at          | datetime | Date and time the email was sent   |
| recipient_count  | int      | Number of recipients               |

**Relations:**
- can target many `Participants`

---

### `Accounting`
Stores financial transactions related to participants or projects (membership fees, payments, reimbursements, etc.).

| Column         | Type   | Description                          |
|----------------|--------|--------------------------------------|
| id             | int PK | Unique identifier                    |
| participant_id | int FK | References `Participant.id`          |
| amount         | float  | Amount of the transaction            |
| type           | string | Type of transaction (income/expense) |
| date           | date   | Date of the transaction              |
| description    | text   | Description of the transaction       |

**Relations:**
- belongs to one `Participant`

---

### `Recruitment`
Stores recruitment requests or applications from people wishing to join a project or the orchestra.

| Column         | Type     | Description                            |
|----------------|----------|----------------------------------------|
| id             | int PK   | Unique identifier                      |
| participant_id | int FK   | References `Participant.id`            |
| status         | string   | Status of the application (pending, accepted, rejected) |
| applied_at     | datetime | Date of the application                |

**Relations:**
- belongs to one `Participant`

---

## Relationships Summary

| Table        | Relation       | Table          | Type         |
|--------------|----------------|----------------|--------------|
| Repertoire   | belongs to     | TypeOfPiece    | Many-to-One  |
| Repertoire   | belongs to     | Composer       | Many-to-One  |
| Repertoire   | linked to      | Conert         | Many-to-Many |
| Participant  | belongs to     | Concert        | Many-to-One  |
| Participant  | references     | Contacts       | Many-to-One  |
| Plays        | links          | Participant    | Many-to-One  |
| Plays        | links          | Instrument     | Many-to-One  |
| Plays        | links          | Sections       | Many-to-One  |
| Accounting   | belongs to     | Participant    | Many-to-One  |
| Recruitment  | belongs to     | Participant    | Many-to-One  |
| Mailing      | targets        | Participant    | Many-to-Many |



## Notes

> ⚠️ The database schema is managed via **AdonisJS Lucid** migrations located in the `back` repository under `database/migrations/`. Always run migrations after pulling new changes:
> ```bash
> node ace migration:run
> ```

> ℹ️ A legacy migration script written in Python is available in the `database` repository under `migrationScript/`. It was used to migrate data from the old Melomania database and is kept for historical reference only.
