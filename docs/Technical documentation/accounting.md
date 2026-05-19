# TD - Accounting Feature

*Edited by Michel, 17/05/2026*

## Overview

The Accounting feature lets the project manager track all the expenses and incomes of a project. Each entry has a name, an amount, a category, and dates. It is accessible from inside a project, in the **Accounting** tab.

URL:/projects/:projectId/management/accounting

Each project has its own accounting. Entries are not shared between projects.

## How it works

1. The project manager adds entries one by one (each entry is a single expense or income).
2. Each entry has a category (10 default categories are available, custom ones can be added).
3. Entries have a `bill_date` (date of the invoice) and a `bank_date` (expected date of the payment on the bank account). Both are used to compute the different balances of the project.
4. Files (invoices, receipts) can be attached to each entry.
5. The page automatically computes 9 indicators: total / current / future expenses, incomes and balance.

Entries can be linked to a specific person (a musician for example) by checking 

**Payment to individual**.

## The Accounting page

The page is divided into three areas:

- A **header** with an `Add New` button on the right.
- 9 **indicators** in three groups: expenses, incomes, balance.
- A **list of entries**, an **attachments section**, and two charts (expenses + incomes), followed by the list of categories.

### The 9 indicators

| Group | Indicator | What it shows |
|---|---|---|
| Expenses | Total Expenses | Sum of all expense entries |
| | Current Expenses | Expenses already settled on the bank account |
| | Expenses To Come | Expenses with a future bank date |
| Incomes | Total Incomes | Sum of all income entries |
| | Current Incomes | Incomes already received |
| | Incomes To Come | Incomes with a future bank date |
| Balance | Total Balance | Total Incomes − Total Expenses |
| | Current Balance | Current Incomes − Current Expenses |
| | Future Balance | Incomes To Come − Expenses To Come |

The split between "current" and "to come" is based on the `bank_date` of each entry.

### The entry list

The list has 7 columns:

| Column | Content |
|---|---|
| NAME | Name of the entry |
| BILL DATE | Date of the invoice |
| BANK DATE | Date of the payment on the bank account |
| AMOUNT | Amount in euros |
| CATEGORY | Category of the entry (with its color) |
| ATTACHMENTS | Files attached to the entry |
| ACTION | Action icons (edit, delete) |

The list can be sorted by `id`, `created_at` or `contact_date`. A search bar allows filtering the entries.

### Attachments section and charts

Below the list, an **Attachments** section gathers all the files attached to the entries of the project. Two charts also display the distribution of expenses and incomes by category (currently empty when no entries exist).

## Adding an entry

The `Add New` button in the header opens the **New** popup. The fields are:

| Field | Type | Notes |
|---|---|---|
| Payment to individual | Checkbox | Optional. Changes the form (see below). |
| Name | Text | Required |
| Bill Date | Date | Date of the invoice |
| Bank Date | Date | Date of the payment on the bank account |
| Amount | Number (€) | Required |
| Expense Category | Dropdown | Required. List of available categories. |
| Upload Files | Drag & drop | Optional. One or several files can be attached. |

The popup has two buttons: **Cancel** and **Add**. A **Submit** button next to the upload area uploads the selected files.

### "Payment to individual" checkbox

When checked, the form changes:

- The **Expense Category** dropdown is restricted to two categories: `Musician payments` and `Musician reimbursements`.
- A new field **Person Name** appears (free text, no autocomplete).
- A large grey area appears next to it. Its purpose is unclear and could not be determined during this exploration.

When unchecked, the dropdown shows all 10 categories (including `Musician payments` and `Musician reimbursements`).

> **Important**: this filter is done on the frontend only. The two "musician" categories are not flagged as "for individuals" in the database. The list of restricted categories is hardcoded on the frontend.

### About the sign of the amount

The page displays the message:

> "Add entries with negative amounts to see expenses"  
> "Add entries with positive amounts to see incomes"

In the database, the type of an entry is stored in a separate column (`entry_type`, with the values `expense` or `income`), not by the sign of the amount. The exact link between the UI message and the actual storage should be confirmed.

## Categories

Each entry must have a category. By default the app provides 10 categories, all in English, each with its own color:

| Category | Color | Type |
|---|---|---|
| Musician payments | Blue (#3B82F6) | Expense |
| Musician reimbursements | Orange (#F59E0B) | Expense |
| Sheet music printing | Green (#10B981) | Expense |
| Advertising costs | Red (#EF4444) | Expense |
| Day-to-day management | Purple (#8B5CF6) | Expense |
| Venue rental | Dark orange (#F97316) | Expense |
| Equipment rental | Dark green (#059669) | Expense |
| Ticket sales | Dark red (#DC2626) | Income |
| Donations | Dark purple (#7C3AED) | Income |
| Miscellaneous | Grey (#6B7280) | Mixed |

> Note: the dropdown is called `Expense Category` in the form, but two of the 10 default categories are actually incomes (Ticket sales, Donations). The label is probably an old one that was not updated.

### Custom categories

Below the entry list, the **CATEGORIES** section displays all the categories with their colors. An `Add New` button opens the **New Category** popup with three fields:

- **Name** (required)
- **Description** (optional)
- **Color** (color picker)

The popup does not let the user choose an icon, but the database has an `icon` column on the categories table. Only the default categories use it (and not all of them).

> Important: categories are global. They do not belong to a project. A custom category created in one project will be visible in every other project of the app.

## The hidden settings

The Accounting feature has a settings system (`accounting_settings` table) that is **not exposed in the UI explored**. There is no Settings button on the Accounting page, but the table exists in the database and the backend has full CRUD routes for it (`getSettings`, `updateSettings` in the controller).

Each project has one row of settings, created automatically the first time it is needed (`getOrCreateForProject` static method on the model).

The settings table contains 7 columns:

| Setting | Type | Default | Purpose |
|---|---|---|---|
| currency | string | `EUR` | Currency of the project |
| auto_overdue_enabled | boolean | `true` | Auto-mark unpaid entries as overdue |
| default_payment_terms | integer | `30` | Default delay (days) between bill and bank date |
| tax_rate | decimal(5,2) | `20.00` | Tax rate in % |
| enable_tax | boolean | `false` | Apply taxes on entries |
| fiscal_year_start | timestamp | null | Start of the fiscal year |

So the backend already supports things like a custom currency, VAT, and a fiscal year, but none of it is currently visible in the Accounting UI. There is probably a UI planned, or it was removed at some point. To be confirmed with Aurian.

The `auto_overdue_enabled` setting works like the automatic follow-up of the Recruitment feature: it triggers a recalculation of the entries' `payment_status`, moving `pending` entries with a past `due_date` to `overdue`. The recalculation is only triggered when the settings are saved (same pattern as Recruitment).


## Backend

### AccountingEntry model

**Backend file:** `back/app/models/accounting_entry.ts`

The `AccountingEntry` model represents a single accounting entry (an expense or an income).

| Field | Type | Notes |
|---|---|---|
| id | number | Primary key |
| project_id | number | FK to Project |
| contact_id | number or null | FK to Contact. Not visible in the UI form. |
| category_id | number or null | FK to AccountingCategory |
| name | string | Required |
| description | text or null | Long description. Not visible in the UI form. |
| amount | decimal(12,2) | Required. Unsigned in the database. |
| entry_type | enum | `expense` or `income`. Default: `expense`. |
| payment_status | enum | `pending`, `paid`, `overdue`, `cancelled`. Default: `pending`. |
| bill_date | date or null | Date of the invoice |
| payment_date | date or null | Date the entry was actually paid. Updated by `markAsPaid`. |
| due_date | date or null | Expected payment date. Used by `updateOverdueStatuses`. |
| attachment | string or null | One single file path |
| is_individual_payment | boolean | Default: false. Linked to the "Payment to individual" checkbox. |
| is_musician_fee | boolean | Default: false. Not visible in the UI. |
| invoice_number | string or null | Invoice number. Not visible in the UI form. |
| notes | text or null | Free notes |
| createdAt / updatedAt | DateTime | Automatic |

### Methods of the model

- `markAsPaid()` — sets `payment_status` to `paid` and updates `payment_date`.
- `markAsPending()` — sets `payment_status` to `pending`.
- `markAsCancelled()` — sets `payment_status` to `cancelled`.
- `isOverdue()` — true if not paid and `due_date` has passed.
- `canBeMarkedAsPaid()` — true if `pending` or `overdue`.
- `getStatusBadge()` — returns label, color and icon for the current status.
- `getProjectStats(projectId)` — returns stats of the whole project (total entries, total expenses, total incomes, totals by payment status).
- `updateOverdueStatuses(projectId)` — moves all `pending` entries with a past `due_date` to `overdue`. Triggered by `updateSettings` in the controller.

> Note: the controller does **not** use the `markAs*` methods. It updates the status directly via the `updateStatus` route.

### AccountingCategory model

**Backend file:** `back/app/models/accounting_category.ts`

Represents a category of entry. Has 6 fields: `id`, `name`, `description`, `is_default`, `color`, `icon`.

There is **no `project_id`** on this model: categories are global to the whole app, not specific to a project.

> The model has a static method `getOrCreateDefaults()` that would create 8 default categories in French (with icons). But this method seems unused: the 10 default categories visible in the UI are in English and come from a different seeder (see below).

### AccountingSettings model

**Backend file:** `back/app/models/accounting_settings.ts`

Represents the settings of the Accounting feature for one project. See section "The hidden settings" above for the columns.

### Two coexisting systems for categories

The project contains **two systems** for accounting categories:

| System | Table | Status |
|---|---|---|
| Old | `expense_categories` | Currently used by the UI |
| New | `accounting_categories` | Defined in code, not used yet (?) |

The deprecated model `back/app/models/accounting.ts` (marked `@deprecated` in the code) points to the `accounting_entries` table but uses `ExpenseCategory` instead of `AccountingCategory`. The transition between the two systems doesn't seem to be finished.

### Other backend files

| File | Purpose |
|---|---|
| `back/app/controllers/accounting_controller.ts` | Main controller (538 lines, CRUD entries, stats, attachments, contact links) |
| `back/app/controllers/accounting_categories_controller.ts` | Controller dedicated to categories |
| `back/app/models/expense_category.ts` | Old category model (used by the UI) |
| `back/app/validators/accounting_entry.ts` | Validator for entries |
| `back/app/validators/expense_categories.ts` | Validator for the old categories |
| `back/database/seeders/expense_categories_seeder.ts` | Seeder that creates the 10 default categories visible in the UI |

## Database structure

The Accounting feature uses 3 main tables (the new system), plus 1 older table still used by the UI.

### accounting_entries

**Migration:** `back/database/migrations/1760000000003_create_accounting_entries_table.ts`

The main table. Stores every entry (expense or income) of a project.

| Column | SQL type | Notes |
|---|---|---|
| id | increments | Primary key |
| project_id | integer | FK to `projects.id`, ON DELETE CASCADE |
| contact_id | integer (nullable) | FK to `contacts.id`, ON DELETE CASCADE |
| category_id | integer (nullable) | FK to `accounting_categories.id`, ON DELETE SET NULL |
| name | string(255) | NOT NULL |
| description | text (nullable) | |
| amount | decimal(12,2) | NOT NULL. Unsigned. |
| entry_type | enum | Default: `expense`. Values: `expense`, `income`. |
| payment_status | enum | Default: `pending`. Values: `pending`, `paid`, `overdue`, `cancelled`. |
| bill_date | date (nullable) | |
| payment_date | date (nullable) | |
| due_date | date (nullable) | |
| attachment | string (nullable) | One single file path |
| is_individual_payment | boolean | Default: false |
| is_musician_fee | boolean | Default: false |
| invoice_number | string (nullable) | |
| notes | text (nullable) | |
| created_at | timestamp | |
| updated_at | timestamp | |

Indexes:
- `(project_id, payment_status)` for fast filtering
- `(entry_type)` to quickly split expenses and incomes
- `(payment_date)`
- `(due_date)` used by `updateOverdueStatuses`

### accounting_categories

**Migration:** `back/database/migrations/1760000000001_create_accounting_categories_table.ts`

Stores the new system of categories.

| Column | SQL type | Notes |
|---|---|---|
| id | increments | Primary key |
| name | string(255) | NOT NULL |
| description | text (nullable) | |
| is_default | boolean | Default: false |
| color | string(50) (nullable) | Hex code |
| icon | string(50) (nullable) | Icon name (probably Lucide) |
| created_at | timestamp | |
| updated_at | timestamp | |

Index: `(name)`.

There is **no `project_id`** column → categories are global to the app.

### accounting_settings

**Migration:** `back/database/migrations/1760000000002_create_accounting_settings_table.ts`

Stores the settings of the Accounting feature for one project.

| Column | SQL type | Notes |
|---|---|---|
| id | increments | Primary key |
| project_id | integer | FK to `projects.id`, ON DELETE CASCADE |
| currency | string(10) | Default: `EUR` |
| auto_overdue_enabled | boolean | Default: true |
| default_payment_terms | integer | Default: 30 |
| tax_rate | decimal(5,2) | Default: 20.00 |
| enable_tax | boolean | Default: false |
| fiscal_year_start | timestamp (nullable) | |
| created_at | timestamp | |
| updated_at | timestamp | |

Constraint: `UNIQUE(project_id)` (one settings row per project).

### expense_categories (old system, still in use)

**Migration:** `back/database/migrations/1751980239258_create_expense_categories.ts`

This is the **old** category table, but it is the one actually used by the UI. The 10 default categories visible on the Accounting page come from the seeder `expense_categories_seeder.ts`.

### Main relations

- `accounting_entries.project_id` → `projects.id` (CASCADE)
- `accounting_entries.contact_id` → `contacts.id` (CASCADE, optional)
- `accounting_entries.category_id` → `accounting_categories.id` (SET NULL, optional)
- `accounting_settings.project_id` → `projects.id` (CASCADE, unique)

## Main workflows (developer perspective)

### Adding an entry

1. The user fills the `New` popup.
2. The frontend calls the `createOrUpdate` controller method (lines 169–273 of `accounting_controller.ts`).
3. The backend validates the data (`Name`, `Amount`, `Expense Category` required).
4. A new `AccountingEntry` row is created with `entry_type = expense` and `payment_status = pending` by default.
5. If files have been uploaded, they are saved (one file per entry) and the path is stored in the `attachment` column.

The same controller method `createOrUpdate` is also used when the user **edits** an existing entry.

### Changing the payment status

The model has helpers (`markAsPaid`, `markAsPending`, `markAsCancelled`) but the controller does **not** call them. The status is updated directly via the `updateStatus` route (line 295 of the controller).

The 4 statuses (`pending`, `paid`, `overdue`, `cancelled`) are not exposed in the UI explored — they probably appear somewhere I missed (an edit screen ?), or are only used by the backend / hidden settings.

### Automatic overdue update

The `updateOverdueStatuses(projectId)` static method on the model moves all `pending` entries with a past `due_date` to `overdue`. It is called only inside `updateSettings` (line 93 of the controller), so:

- It is **not** triggered on every page load.
- It is **not** triggered by a cron job.
- It runs **only when the user saves the Accounting settings**.

If no one ever opens / saves the settings, the entries will never be moved to `overdue` automatically. Same pattern as the Recruitment follow-up.

### Categories management

Categories are global to the app. They can be created, edited and deleted through `getCategories`, `createOrUpdateCategory`, `deleteCategory` methods of the controller. There is also a dedicated controller `accounting_categories_controller.ts` (probably for the new system). The exact split between the two controllers should be confirmed.

### Attachments

A single file can be uploaded per entry. The upload is done through `uploadAttachment` (line 433), and files can be downloaded back via `downloadAttachment` (line 468). The UI section "Attachments" at the bottom of the page gathers all the files from all the entries of the project.

## Known issues and attention points

- **Two coexisting systems for categories.** The old `expense_categories` table (used by the UI, 10 categories in English) and the new `accounting_categories` table (not used yet, 8 categories in French defined in code). The deprecated model `accounting.ts` still points to `expense_categories`. The migration between the two systems doesn't seem to be complete.

- **Hidden settings.** The `accounting_settings` table supports 7 columns (currency, tax rate, fiscal year start, auto overdue, etc.) but no UI exposes them. The settings are created automatically with default values.

- **Status `payment_status` mostly invisible in the UI.** The 4 values (`pending`, `paid`, `overdue`, `cancelled`) are defined in the database and can be updated via the API, but the form to create or edit an entry does not show them. To be confirmed if an edit screen exists somewhere.

- **`entry_type` field invisible too.** The UI message says "negative amounts to see expenses, positive amounts to see incomes", but in the database there is an explicit `entry_type` column. The exact mapping between the sign and this column is not clear and should be checked.

- **Misleading label "Expense Category".** The dropdown is called `Expense Category` in the form, but two of the default categories (`Ticket sales`, `Donations`) are actually incomes.

- **"Payment to individual" filter is frontend-only.** When the checkbox is checked, the category dropdown is restricted to `Musician payments` and `Musician reimbursements`. There is no flag in the database to mark a category as "for individual": the list is hardcoded on the frontend.

- **Custom categories are global.** A category created in one project will be visible in every other project of the app. There is no `project_id` column on the `accounting_categories` table.

- **One attachment per entry.** The UI suggests "Click or drag files here to upload" (plural), but the `attachment` column is a single string. Only one file is actually stored per entry. The plural in the UI is misleading.

- **The mysterious grey area.** When "Payment to individual" is checked, a large grey area appears to the right of the Person Name field. I couldn't figure out what it is supposed to display.

- **Typo in the controller.** The method `getContactAccountingsproject` (line 517) is missing an underscore — should probably be `getContactAccountingsProject` or `getContactAccountingsForProject`.

- **No automatic trigger for `updateOverdueStatuses`.** The recalculation runs only when the settings are saved. As long as nobody opens the (hidden) settings, no entry will ever move to `overdue` automatically.

- **`is_musician_fee` boolean invisible in the UI.** The column exists on the model but is never shown nor set through the form. It might be filled automatically based on the category, but this should be confirmed.

## How to modify this feature

To modify or extend the Accounting feature, the main entry points are:

1. **Main model** — `back/app/models/accounting_entry.ts` for the data structure and helpers on an entry.
2. **Main controller** — `back/app/controllers/accounting_controller.ts` for the API routes (CRUD entries, stats, attachments, status changes).
3. **Settings model** — `back/app/models/accounting_settings.ts` for the (hidden) settings.
4. **Category model** — there are currently two: `back/app/models/expense_category.ts` (used by the UI) and `back/app/models/accounting_category.ts` (new system, not yet used). Be careful which one to use when modifying.
5. **Seeder** — `back/database/seeders/expense_categories_seeder.ts` for the 10 default categories actually visible in the UI.
6. **Migrations** — `back/database/migrations/*_accounting_*.ts` and `1751980239258_create_expense_categories.ts`. New columns must be added via a new migration, not by modifying existing ones.
7. **Frontend pages** — Svelte pages and components related to accounting, probably under `front/src/routes/projects/[id]/management/accounting/` (to be confirmed).

A few things to keep in mind when working on this feature:

- The new system (`AccountingEntry` + `AccountingCategory`) is in place in the code but is not fully used by the UI yet. Before adding new code, check which system is really active.
- Any change on the way categories work should consider both tables (`expense_categories` and `accounting_categories`).
- The settings are not exposed in the UI. Adding a Settings popup would be a good first step to make the existing backend features usable.