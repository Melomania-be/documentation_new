# Database structure
This page provides a detailed explanation of the database structure, their roles, and the relationships between them.

---

## Overview

This is a relational database. It stores all data related to musical projects, repertoire, participants, instruments, and contacts managed through the application.

---

## Schema Diagram

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
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   Repertoire    │◄──────│   Repertoire    │       │     Plays       │
│─────────────────│       │  (composer_id)  │       │─────────────────│
│ id (PK)         │       └─────────────────┘       │ id (PK)         │
│ title           │                                  │ participant_id  │
│ type_id (FK)    │                                  │ instrument_id   │
│ composer_id (FK)│                                  │ section_id (FK) │
└────────┬────────┘                                  └────────┬────────┘
         │                                                    │
         │              ┌─────────────────┐                  │
         │              │    Projects     │                  │
         │              │─────────────────│                  │
         └─────────────►│ id (PK)         │◄─────────────────┘
                        │ name            │
                        │ description     │         ┌─────────────────┐
                        │ date            │         │    Sections     │
                        └────────┬────────┘         │─────────────────│
                                 │                  │ id (PK)         │
                                 │                  │ name            │
                                 ▼                  └─────────────────┘
                        ┌─────────────────┐
                        │   Participant   │◄──────┐
                        │─────────────────│       │
                        │ id (PK)         │       │  ┌─────────────────┐
                        │ first_name      │       │  │    Contacts     │
                        │ last_name       │       │  │─────────────────│
                        │ project_id (FK) │       └──│ participant_id  │
                        └─────────────────┘          │ email           │
                                                     │ phone           │
                                                     └─────────────────┘
```

---

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

### `Projects`
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
| project_id | int FK | References `Projects.id`       |

**Relations:**
- belongs to one `Project`
- has one `Contacts` entry
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
Stores the contact information for each participant.

| Column         | Type   | Description                    |
|----------------|--------|--------------------------------|
| id             | int PK | Unique identifier              |
| participant_id | int FK | References `Participant.id`    |
| email          | string | Email address                  |
| phone          | string | Phone number                   |

**Relations:**
- belongs to one `Participant`

---

## Relationships Summary

| Table        | Relation       | Table          | Type         |
|--------------|----------------|----------------|--------------|
| Repertoire   | belongs to     | TypeOfPiece    | Many-to-One  |
| Repertoire   | belongs to     | Composer       | Many-to-One  |
| Repertoire   | linked to      | Projects       | Many-to-Many |
| Participant  | belongs to     | Projects       | Many-to-One  |
| Participant  | has one        | Contacts       | One-to-One   |
| Plays        | links          | Participant    | Many-to-One  |
| Plays        | links          | Instrument     | Many-to-One  |
| Plays        | links          | Sections       | Many-to-One  |
