# TD - Dashboard

*Edited by Umair*

This page describes the project dashboard in Melomania. The dashboard is the main overview page for a project, accessible after selecting a project from the projects list.

---

## Accessing the Dashboard

To access the dashboard of a project:

1. Click on **Projects** in the sidebar
2. Select a project from the list
3. You are automatically redirected to the project dashboard at:

```
/projects/{id}/management
```

---

## Project Header

At the top of the dashboard, the project header displays:

- **Project name** — shown as a large title (e.g. `Project : Let's dance!`)
- **Created at** — the date the project was created
- **Updated at** — the date the project was last modified
- **Edit Project** button — redirects to the project modification page at `/projects/{id}/management/modify`

---

## Navigation Tabs

Below the header, a tab bar allows navigation between the different sections of the project. Each tab has an icon and a label:

| Tab | Description |
|-----|-------------|
| **Project Details** | The main dashboard overview (current page) |
| **Participants** | Manage project participants |
| **Mailing** | Send emails to participants |
| **Callsheet** | View and manage the project callsheet |
| **Attendances** | Track attendance at rehearsals and concerts |
| **Auditions** | Manage audition submissions |
| **Accounting** | View project accounting and expenses |
| **Recruitment** | Manage recruitment contacts |

> If there are participants with pending validation, a **red notification badge** appears on the Participants tab showing the number of unvalidated participants.

---

## Dashboard Sections

### Material Assignment Alert

If any musical pieces in the project have not been assigned materials, a warning banner appears at the top of the dashboard:

> ⚠️ **Material Assignment Required** — X pieces require material assignment.

The banner includes:
- A **Show details** button to expand the list of affected pieces
- A **Manage Materials** button to navigate to the material management page

This alert disappears automatically once all pieces have been assigned materials.

---

### Notifications

A notification panel displays warnings about the project's participant status. It highlights:

- **Participants without an email address** — these participants cannot receive mailing
- **Participants not yet validated** — applications that are still pending approval

---

### Statistics Cards

Three summary cards are displayed side by side showing key project numbers at a glance:

| Card | Description |
|------|-------------|
| **PARTICIPANTS** | Total number of accepted participants in the project |
| **REHEARSALS** | Total number of rehearsals scheduled |
| **CONCERTS** | Total number of concerts scheduled |

---

### Events

The **Events** section lists all scheduled concerts and rehearsals for the project. Each event shows:

- **Date and time** — start and end time of the event
- **Location** — venue where the event takes place
- **Comment** — any additional notes (shown as "No comment" if empty)
- **Type badge** — indicates whether the event is a `concert` or a `rehearsal`

An **Edit** button allows navigating to the event management page.

---

### Project Managers

The **Project Managers** section lists the contacts responsible for managing the project. Each manager is displayed with their first and last name, and clicking on their name navigates to their contact page.

If no managers have been assigned, the message *"No project managers assigned"* is shown.

An **Edit** button redirects to the project modification page.

---

### Sections

The **Sections** section displays the distribution of participants across the different musical sections (e.g. Violins, Brass, Woodwinds). It also shows the number of participants not yet validated per section.

---

### Sheets (Callsheet)

The **Sheets** section gives an overview of which participants have viewed the project callsheet and which have not. It highlights participants who have not yet seen the callsheet.

---

### Pieces

The **Pieces** section lists the musical pieces programmed for the project.

---

## Responsive Design

The dashboard is fully responsive:

- On **desktop**, all sections are displayed side by side in a multi-column layout
- On **mobile**, sections stack vertically and a bottom navigation bar replaces the tab bar at the top

---

## API Endpoint

The dashboard data is loaded server-side from:

```
GET /projects/{id}/management
```

This returns the full project data including participants, concerts, rehearsals, responsibles, sections, and pieces. If the project is not found, the user is redirected to `/projects`.