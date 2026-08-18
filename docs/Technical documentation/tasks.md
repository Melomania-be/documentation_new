# Edited by  # Umair

# Task Manager

This page describes the Task Manager feature in Melomania. Tasks allow project teams to track and manage work items within a project.

---

## Overview

The Task Manager is accessible from within a project and allows team members to:

- View all tasks for a project
- Create new tasks
- Update the status of existing tasks
- Delete tasks they created
- Assign tasks to specific users

---

## Accessing the Task Manager

To access the Task Manager:

1. Click on **Projects** in the sidebar
2. Select a project from the list
3. Click on the **Tasks** tab in the project navigation bar

---

## Task List

The task list displays all tasks for the current project. Each task shows:

- **Title** — the name of the task
- **Description** — optional additional details
- **Status badge** — the current status of the task, color coded:
  - Grey — **To Do**
  - Blue — **In Progress**
  - Green — **Done**
- **Assigned user** — the team member assigned to the task (if any)
- **Status dropdown** — to quickly update the task status
- **Delete button** — to remove the task

---

## Creating a Task

1. Click the **+ Add Task** button at the top right
2. Fill in the form:
   - **Title** (required)
   - **Description** (optional)
   - **Status** (defaults to "To Do")
   - **Assign to** (optional, select a user from the list)
3. Click **Create Task**

The new task will appear immediately in the task list.

---

## Updating a Task Status

Each task has a **status dropdown** on the right side. Simply select a new status to update it:

- **To Do** — task has not been started
- **In Progress** — task is currently being worked on
- **Done** — task has been completed

The status is saved automatically when you change it.

---

## Deleting a Task

Click the **Delete** button next to a task to remove it.

> **Note:** Only the **creator** of a task can delete it. If you try to delete a task you did not create, you will see a permission error.

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/tasks?project_id={id}` | Get all tasks for a project |
| `POST` | `/api/tasks` | Create a new task |
| `PUT` | `/api/tasks/:id` | Update a task (e.g. change status) |
| `DELETE` | `/api/tasks/:id` | Delete a task (creator only) |

All routes require an active session. Attempting to delete a task you did not create will return a **403 Forbidden** error.

---

## POST /api/tasks — Required payload

```json
{
  "title": "Task title",
  "projectId": 1,
  "description": "Optional description",
  "status": "todo",
  "assignedTo": 2
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Title of the task |
| `projectId` | Yes | ID of the project |
| `description` | No | Additional details |
| `status` | No | Defaults to `todo`. Can be `todo`, `in_progress`, or `done` |
| `assignedTo` | No | ID of the user to assign the task to |

---

## PUT /api/tasks/:id — Update payload

You can send only the field that changes:

```json
{
  "status": "in_progress"
}
```

---

## Security

- All task routes are protected and require an active session
- **Bouncer policies** prevent unauthorized access (anti-IDOR)
- Only the **creator** of a task can delete it — attempting to delete another user's task returns a **403 Forbidden** response
- **VineJS validation** is applied on all incoming data

---

## Frontend Files

| File | Description |
|------|-------------|
| `src/routes/projects/[id]/management/tasks/+page.svelte` | Main task list and creation form |
| `src/routes/projects/[id]/management/tasks/+page.server.ts` | Server load function |
| `src/routes/api/tasks/+server.ts` | API proxy for GET and POST requests |
| `src/routes/api/tasks/[id]/+server.ts` | API proxy for PUT and DELETE requests |
| `src/lib/types/Task.ts` | TypeScript type definition for a Task |