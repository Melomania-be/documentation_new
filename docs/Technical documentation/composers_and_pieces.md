# TD - Composers & Pieces Feature

*Edited by Stéphane*

## Overview

The Composers & Pieces feature is Melomania's comprehensive music library management system that enables administrators and project managers to catalog and organize classical music compositions. It provides a structured repository of composers with their biographical information, musical works, and associated materials. The system supports the organization of pieces by composer, piece type, and arrangement, while tracking material versions and their usage across projects. This feature serves as the foundation for repertoire planning and score management in project production workflows.

---

## How the feature works

The Composers & Pieces feature provides several working paths for administrators and librarians:

### Managing Composers

1. Open the composers library interface.
2. Browse the list of existing composers with filtering and pagination options.
3. To add or edit a composer:
   - Enter or update the composer's biographical information:
     - Short name (e.g., "J.S. Bach")
     - Long name (e.g., "Johann Sebastian Bach")
     - Birth date and death date
     - Country of origin
     - Main musical style (e.g., "Baroque", "Classical", "Romantic")
   - Save the composer record to the database.
4. Filter and search composers by any biographical field.
5. View all pieces associated with a specific composer.

### Managing Pieces

1. Open the pieces library interface.
2. Browse the list of existing pieces with advanced filtering options.
3. To add or edit a piece:
   - Enter the piece's core information:
     - Name (title of the work)
     - Opus number (if applicable)
     - Year of composition
     - Composer (linked from composers database)
     - Type of piece (e.g., "Symphony", "Sonata", "Concerto")
     - Arranger information (if this is an arrangement)
   - Link the piece to one or more projects where it will be performed.
   - Select material versions and organize scores.
   - Save the piece record to the database.
4. Filter and search pieces by name, opus, year, or composer.
5. Associate material files and performance documentation with pieces.

### Using Pieces in Projects

1. When planning a project repertoire:
   - Add pieces to the project performance list.
   - Define the performance order for each piece.
   - Specify the material version to be used for each piece.
   - Mark if a specific material was requested or if the default material should be used.
2. Access piece scores and materials directly from the project context.
3. Organize pieces into sections for performance structure.

> Note: Pieces must be created in the library before they can be added to projects. Materials (scores and performance documents) should be organized within the piece structure for easy access during rehearsals and performances.

---

## User perspective

From the librarian and project manager perspective, the Composers & Pieces feature enables:

- **Efficient repertoire discovery**: Browse and filter the music library quickly to find pieces matching specific criteria (composer, period, style, piece type).
- **Piece selection for projects**: Build project repertoires by selecting pieces from the library and organizing them into a performance sequence.
- **Material management**: Organize different versions of scores (original, arrangements, transpositions) and track which version is used for each performance.
- **Composer documentation**: Maintain comprehensive biographical records of composers for historical context and reference.
- **Performance preparation**: Access all necessary materials (scores, parts, annotations) from the project's piece list, ensuring musicians have what they need.

From the performer perspective:

- **Quick access to scores**: Musicians receive callsheets with links to piece information and materials.
- **Clear material versions**: Know which specific version of a piece will be performed (original vs. arrangement, etc.).
- **Performance context**: Understand the composer's historical period, style, and the piece's role in the project's program.

---

## Architecture

### Frontend

| Route | File | Description |
|-------|------|-------------|
| `/library/composers` | `src/routes/library/composers/+page.svelte` | Composers library interface with browsing, filtering, and management capabilities |
| `/library/pieces` | `src/routes/library/pieces/+page.svelte` | Pieces library interface with advanced filtering, search, and piece details display |
| `/library/type_of_pieces` | `src/routes/library/type_of_pieces/+page.svelte` | Piece type management for categorizing different compositions |

### Backend

| File | Description |
|------|-------------|
| `app/controllers/composers_controller.ts` | Main controller handling composer CRUD operations, filtering, and piece retrieval |
| `app/controllers/pieces_controller.ts` | Main controller handling piece CRUD operations, filtering, and material management |
| `app/controllers/type_of_pieces_controller.ts` | Controller for managing piece type categories and classifications |
| `app/models/composer.ts` | Database model representing composer records with relationships to pieces |
| `app/models/piece.ts` | Database model representing piece records with relationships to composers, projects, and materials |
| `app/models/type_of_piece.ts` | Database model for piece type classification |
| `app/models/material.ts` | Database model for managing material versions and score files |
| `app/validators/composer.ts` | Input validation for composer data |
| `app/validators/piece.ts` | Input validation for piece data |

### API Endpoints

#### Composers Endpoints (authenticated)

| Method | Endpoint | Controller Method | Description |
|--------|----------|-------------------|-------------|
| `GET` | `/api/composers` | `getAll` | Retrieve all composers with filtering, pagination, and ordering |
| `GET` | `/api/composers/:id/pieces` | `getPieces` | Retrieve all pieces composed by a specific composer |
| `PUT` | `/api/composers` | `createOrUpdate` | Create a new composer or update an existing composer record |
| `DELETE` | `/api/composers/:id` | `delete` | Remove a composer from the database |

#### Pieces Endpoints (authenticated)

| Method | Endpoint | Controller Method | Description |
|--------|----------|-------------------|-------------|
| `GET` | `/api/pieces` | `getAll` | Retrieve all pieces with filtering, pagination, and related data (composer, type, projects, folder) |
| `PUT` | `/api/pieces` | `createOrUpdate` | Create a new piece or update an existing piece record |
| `DELETE` | `/api/pieces/:id` | `delete` | Remove a piece from the database |

#### Piece Type Endpoints (authenticated)

| Method | Endpoint | Controller Method | Description |
|--------|----------|-------------------|-------------|
| `GET` | `/api/type_of_pieces` | `getAll` | Retrieve all piece type categories |
| `PUT` | `/api/type_of_pieces` | `createOrUpdate` | Create or update a piece type |
| `DELETE` | `/api/type_of_pieces/:id` | `delete` | Remove a piece type |

### Query Features

#### Composer Query Filtering

The composers endpoint supports filtering by:
- `short_name`: Short name identifier
- `long_name`: Full composer name
- `birth_date`: Birth year/date
- `death_date`: Death year/date
- `country`: Country of origin
- `main_style`: Musical style period

#### Piece Query Filtering

The pieces endpoint supports filtering by:
- `name`: Piece title
- `opus`: Opus number
- `year_of_composition`: Composition year
- `composer_id`: Composer identifier
- `arranger`: Arranger name
- Related data by composer name through relationship query

---

## Database Structure

### `composers` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | `number` (Primary Key) | Unique identifier for the composer |
| `short_name` | `string` | Abbreviated composer name (e.g., "J.S. Bach") |
| `long_name` | `string` | Full composer name |
| `birth_date` | `Date` | Birth date of the composer |
| `death_date` | `Date` | Death date of the composer |
| `country` | `string` | Country of origin |
| `main_style` | `string` | Primary musical style/period |
| `createdAt` | `DateTime` | Creation timestamp |
| `updatedAt` | `DateTime` | Last update timestamp |

**Relationships:**
- `pieces` (HasMany): All pieces composed by this composer

### `pieces` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | `number` (Primary Key) | Unique identifier for the piece |
| `name` | `string` | Title of the piece |
| `opus` | `string` | Opus number (if applicable) |
| `year_of_composition` | `string` | Year the piece was composed |
| `type_of_piece_id` | `number` (Foreign Key) | Reference to piece type |
| `composer_id` | `number` (Foreign Key) | Reference to composer |
| `folder_id` | `number` (Foreign Key, nullable) | Reference to file folder containing materials |
| `selected_material_id` | `number` (Foreign Key, nullable) | Reference to the default/selected material version |
| `arranger` | `string` (nullable) | Name of arranger if this is an arrangement |
| `createdAt` | `DateTime` | Creation timestamp |
| `updatedAt` | `DateTime` | Last update timestamp |

**Relationships:**
- `composer` (BelongsTo): The composer of this piece
- `typeOfPiece` (BelongsTo): The category/type of this piece
- `folder` (BelongsTo): File folder storing scores and materials
- `projects` (ManyToMany): All projects where this piece is performed (pivot table: `performed_ins`)
- `materials` (HasMany): All material versions associated with this piece
- `files` (HasMany): All files related to this piece
- `selectedMaterial` (BelongsTo): The currently selected material version

**Pivot Table: `performed_ins`**

| Column | Type | Description |
|--------|------|-------------|
| `id` | `number` (Primary Key) | Unique identifier |
| `piece_id` | `number` (Foreign Key) | Reference to piece |
| `project_id` | `number` (Foreign Key) | Reference to project |
| `order` | `number` | Performance order in the project program |
| `material_id` | `number` (nullable) | Specific material version used in this project |
| `material_specified` | `boolean` | Flag indicating if material was explicitly specified |
| `createdAt` | `DateTime` | Creation timestamp |
| `updatedAt` | `DateTime` | Last update timestamp |

### `type_of_pieces` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | `number` (Primary Key) | Unique identifier for the piece type |
| `name` | `string` | Name of the piece type (e.g., "Symphony") |
| `createdAt` | `DateTime` | Creation timestamp |
| `updatedAt` | `DateTime` | Last update timestamp |

**Relationships:**
- `pieces` (HasMany): All pieces of this type

### `materials` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | `number` (Primary Key) | Unique identifier for the material version |
| `piece_id` | `number` (Foreign Key) | Reference to the piece |
| `name` | `string` | Name/description of this material version |
| `description` | `string` (nullable) | Detailed description of the material |
| `is_default` | `boolean` | Whether this is the default material version |
| `is_active` | `boolean` | Whether this material version is active and available for use |
| `createdAt` | `DateTime` | Creation timestamp |
| `updatedAt` | `DateTime` | Last update timestamp |

**Relationships:**
- `piece` (BelongsTo): The piece this material belongs to
- `files` (HasMany): All files (scores, parts, annotations) in this material version

---

## Key Features

### Composer Management

- **Biographical records**: Store comprehensive information about composers including birth/death dates, nationality, and musical style
- **Chronological organization**: Filter and sort by historical periods to understand compositional context
- **Piece linking**: View all works by a composer instantly
- **Advanced filtering**: Search by name, country, style, or historical period

### Piece Organization

- **Comprehensive cataloging**: Record title, opus number, composition year, and arrangement details
- **Type classification**: Categorize pieces by type (symphony, sonata, concerto, etc.)
- **Material version tracking**: Maintain multiple versions of scores (original, arrangements, transpositions)
- **Default material selection**: Set a primary material version for each piece
- **Folder integration**: Organize score files and materials in structured folders

### Project Integration

- **Repertoire building**: Add pieces to projects and arrange them in performance order
- **Material specification**: Choose specific material versions for each performance
- **Pivot tracking**: Store performance-specific data including order and material selections
- **Related data preloading**: Efficiently load composer, type, and material information

### Advanced Querying

- **Multi-field filtering**: Filter by multiple composer and piece attributes simultaneously
- **Relationship filtering**: Search pieces by composer name or other related data
- **Pagination support**: Handle large music libraries with efficient pagination
- **Custom ordering**: Sort results by any field in ascending or descending order

### Material Management

- **Default material methods**: Automatically create and retrieve default materials for pieces
- **Selected material serialization**: Include material metadata in piece queries
- **Active material filtering**: Only show active material versions to end users
- **File association**: Link scores and parts to material versions for organized access

### Data Integrity

- **Relationship management**: Maintain referential integrity between composers, pieces, and projects
- **Cascade operations**: Handle piece and composer deletion with proper relationship cleanup
- **Timestamp tracking**: Automatic creation and update timestamps for audit trails
- **Input validation**: Validate all composer and piece data before database operations
