# TD - File Manager

*Edited by Naomi*

## Overview

The Files feature is Melomania's built-in file storage system. It allows users to upload, organize, preview, download, and share files either linked to a specific project or stored independently as general files. Each project has a default folder structure (Scores, Photos, Videos, Documents) that is automatically created when the file manager is first opened.

---

## Architecture

### Frontend

| Route | File | Description |
|-------|------|-------------|
| `/files` | `src/routes/files/+page.svelte` | Main file management page (Projects and General Files tabs) |

### Backend

| File | Description |
|------|-------------|
| `app/controllers/files_controller.ts` | Handles file upload, download, streaming, update and delete |
| `app/controllers/filesystem_controller.ts` | Handles folder structure, project file management, and general files |
| `app/controllers/folders_controller.ts` | Handles folder CRUD operations |
| `app/controllers/shared_folder_controller.ts` | Handles folder sharing via public tokens |
| `app/models/file.ts` | File database model |
| `app/models/folder.ts` | Folder database model |

### API Endpoints

#### File endpoints (authenticated)

| Method | Endpoint | Controller Method | Description |
|--------|----------|-------------------|-------------|
| `POST` | `/api/files` | `upload` | Upload one or multiple files |
| `GET` | `/api/files` | `getAll` | Get all files |
| `PUT` | `/api/files/:id` | `update` | Update file metadata |
| `DELETE` | `/api/files/:id` | `delete` | Delete a file |
| `GET` | `/api/files/download/:id` | `download` | Download a file |
| `GET` | `/api/files/stream/:id` | `stream` | Stream a file (for audio/video preview) |
| `GET` | `/api/files/info/:id` | `info` | Get file info and check if it exists on disk |

#### Filesystem endpoints (authenticated)

| Method | Endpoint | Controller Method | Description |
|--------|----------|-------------------|-------------|
| `GET` | `/api/filesystem/projects/:id` | `getProjectStructure` | Get a project's full folder structure |
| `POST` | `/api/filesystem/projects/:id/init` | `initProjectStructure` | Initialize default folders for a project |
| `POST` | `/api/filesystem/projects/:id/sync-pieces` | `syncPieceFolders` | Sync piece folders with the project's pieces |
| `GET` | `/api/filesystem/folders/:id/contents` | `getFolderContents` | Get contents of a folder |
| `POST` | `/api/filesystem/folders` | `createFolder` | Create a new folder |
| `DELETE` | `/api/filesystem/folders/:id` | `deleteFolder` | Delete a folder |
| `PATCH` | `/api/filesystem/folders/:id` | `renameFolder` | Rename a folder |
| `POST` | `/api/filesystem/upload` | `uploadFiles` | Upload files to a folder |
| `DELETE` | `/api/filesystem/files/:id` | `deleteFile` | Delete a file from the filesystem |
| `PATCH` | `/api/filesystem/files/:id` | `renameFile` | Rename a file |
| `GET` | `/api/filesystem/general` | `getGeneralFiles` | Get all general files (not linked to a project) |

#### Shared folder endpoints (public)

| Method | Endpoint | Controller Method | Description |
|--------|----------|-------------------|-------------|
| `GET` | `/shared/folders/:token` | `getSharedFolder` | Get a shared folder by token (public) |
| `GET` | `/shared/folders/:token/folder/:folderId` | `getSharedSubfolder` | Get a subfolder of a shared folder (public) |
| `GET` | `/shared/folders/:token/download/:fileId` | `downloadSharedFile` | Download a file from a shared folder (public) |

---

## Database Structure

### `files` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Auto-incremented primary key |
| `name` | string | Original filename |
| `type` | string | MIME type of the file (e.g. `application/pdf`, `image/jpeg`) |
| `content` | string | Legacy field, currently empty string |
| `path` | string | Physical path to the file on the server disk |
| `size` | integer | File size in bytes (nullable) |
| `folder_id` | integer (FK) | References `folders.id` (nullable) |
| `project_id` | integer (FK) | References `projects.id` (nullable) |
| `piece_id` | integer (FK) | References `pieces.id` (nullable) |
| `material_id` | integer (FK) | References `materials.id` (nullable) |
| `instrument_part` | string | Instrument part label (nullable) |
| `part_order` | integer | Order of the part within a material |
| `created_at` | timestamp | Auto-set on creation |
| `updated_at` | timestamp | Auto-updated on every save |

### `folders` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer (PK) | Auto-incremented primary key |
| `name` | string | Name of the folder |
| `parent_id` | integer (FK) | References `folders.id` — allows nested folders (nullable) |
| `project_id` | integer (FK) | References `projects.id` (nullable) |
| `piece_id` | integer (FK) | References `pieces.id` (nullable) |
| `is_system_generated` | boolean | True if the folder was auto-created by the app |
| `created_at` | timestamp | Auto-set on creation |
| `updated_at` | timestamp | Auto-updated on every save |

### `contains` pivot table

Links files to folders:

| Column | Type | Description |
|--------|------|-------------|
| `folder_id` | integer (FK) | References `folders.id` — deleted cascade |
| `file_id` | integer (FK) | References `files.id` — deleted cascade |
| `created_at` | timestamp | Auto-set on creation |
| `updated_at` | timestamp | Auto-updated on every save |

---

## Model Relationships

### `File` model (`app/models/file.ts`)

```
File
  ├── belongsTo → Folder (via folder_id)
  ├── belongsTo → Project (via project_id)
  ├── belongsTo → Piece (via piece_id)
  ├── belongsTo → Material (via material_id)
  └── manyToMany → Folder (via contains pivot table)
```

### `Folder` model (`app/models/folder.ts`)

```
Folder
  ├── belongsTo → Folder (parent, via parent_id) — self-referencing
  ├── hasMany → Folder (children, via parent_id) — self-referencing
  ├── belongsTo → Project (via project_id)
  ├── belongsTo → Piece (via piece_id)
  └── manyToMany → File (via contains pivot table)
```

---

## How the Feature Works

### 1. Project Folder Structure Initialization

When a user first opens the file manager for a project, the frontend calls `POST /api/filesystem/projects/:id/init`. The backend `initProjectStructure` method:
1. Checks if a root folder already exists for the project
2. If not, creates a **root folder** named after the project
3. Creates 4 default subfolders: **Scores**, **Photos**, **Videos**, **Documents**
4. For each piece in the project, creates a piece subfolder inside **Scores**
5. Copies any existing score files into the corresponding piece folders

If the root folder already exists, it returns the existing structure instead.

### 2. Uploading Files

Files are uploaded via `POST /api/filesystem/upload`. The backend:
1. Validates the uploaded file using `filesystemUploadValidator`
2. Moves the file to the `uploads` directory on the server with a unique `cuid()` filename
3. Creates a `File` record in the database with the original name, type, path and size
4. Links the file to the specified folder

### 3. Downloading and Streaming Files

- **Download** (`GET /api/files/download/:id`) — forces a file download in the browser using `Content-Disposition: attachment`
- **Stream** (`GET /api/files/stream/:id`) — streams the file for in-browser preview. Supports **range requests** for audio and video files, allowing seeking without downloading the entire file. The content type is determined by the file extension using a built-in MIME type map.

### 4. Sharing Folders

A folder can be shared publicly via `POST /api/filesystem/folders/:id/share`. This creates a **shared folder** record with a unique public token. The shared folder is then accessible at `/shared/folders/:token` without authentication — this is how folders appear on the callsheet for participants to access.

To revoke sharing, call `DELETE /api/filesystem/folders/:id/share`.

### 5. General Files

General files (not linked to any project) are managed separately. `GET /api/filesystem/general` returns all files and folders that have no `project_id`. These are displayed in the **General Files** tab of the file manager.

---

## Tips for Developers

- Files are stored physically on the server disk under the `uploads/` directory with a unique `cuid()` name — the original filename is only stored in the database
- The `path` field in the `files` table is the **absolute path** on the server disk — if the server moves, all file paths need to be updated
- The `is_system_generated` flag on folders prevents users from accidentally deleting default folders like Scores, Photos, Videos and Documents
- When adding a new default folder to the project structure, update the `initProjectStructure` method in `filesystem_controller.ts`
- The streaming endpoint supports **partial content (HTTP 206)** for range requests — this is essential for video and audio preview to work correctly in the browser
- Shared folders use a **public token** for access — no authentication is needed to access a shared folder, so be careful what is shared