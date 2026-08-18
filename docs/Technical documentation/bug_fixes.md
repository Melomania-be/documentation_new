# Edited by  # Umair

# Bug Fixes

This page documents the bug fixes applied to the Melomania application.

---

## Bug #160 — Fix rehearsal and concert time display

**Status:** Fixed
**Affected component:** `src/lib/components/DateShow.svelte`

### Description

Rehearsals cannot span multiple days, so the end date input was removed from their creation form. However, the callsheet, registration form, and project dashboard were still displaying an incorrect end date for rehearsals (and in some cases for same-day concerts).

For example, a rehearsal on **Tuesday 2 June 2026** was incorrectly displayed as:

```
Tuesday 2 June 2026 to Monday 1 June 2026
```

### Root Cause

The `DateShow.svelte` component was always showing the end date when an `endTime` prop was provided, without checking whether the event was a rehearsal or whether the end date was on the same day as the start date.

### Fix

The `DateShow.svelte` component was completely rewritten to:

- Use local date/time parsing functions (`getDate` and `getTime`) that correctly handle timezone-safe date formatting
- Only display the end time (not the end date) when `withDate` is true
- Never display a "to [end date]" range — the component now only shows the start date in date mode

### Files Changed

| File | Change |
|------|--------|
| `src/lib/components/DateShow.svelte` | Complete rewrite of date/time display logic |

### Before and After

**Before:**
```
Tuesday 2 June 2026 to Monday 1 June 2026   13:00 - 16:00
```

**After:**
```
Tuesday 2 June 2026   13:00 - 16:00
```

### Affected Pages

- Project dashboard (Events section)
- Callsheet public view
- Registration form (Events tab)
- Attendance picker

---

## Feature #83 — Add order and position to callsheet content blocks

**Status:** Implemented
**Branch:** `feature/callsheet-block-ordering-Umair`

### Description

Previously, when creating an information block in a callsheet, it would always appear at the top of the callsheet. There was no way to choose where to place it relative to the default Program and Events sections.

### Fix

Added the ability to:

- **Move blocks up or down** using ▲ ▼ buttons
- **Choose the position** of each block — either **above** or **below** the Program and Events sections

### Files Changed

**Backend:**

| File | Change |
|------|--------|
| `database/migrations/[timestamp]_add_order_position_to_content_callsheets.ts` | Added `order` and `position` columns to `content_callsheets` table |
| `app/models/content_callsheet.ts` | Added `order` and `position` model properties |
| `app/validators/callsheet.ts` | Added `order` and `position` validation |
| `app/controllers/callsheets_controller.ts` | Updated to save `order` and `position` |

**Frontend:**

| File | Change |
|------|--------|
| `src/lib/types/ContentCallsheet.ts` | Added `order` and `position` fields to the type |
| `src/lib/components/callsheet/CallsheetModifier.svelte` | Added ▲ ▼ buttons and position dropdown |
| `src/lib/components/callsheet/CallsheetShow.svelte` | Updated to display blocks in correct order and position |
| `src/lib/components/callsheet/ContentSection.svelte` | Added `positionFilter` prop to filter blocks by position |

---

## Feature #83 — Add order and position to registration content blocks

**Status:** Implemented
**Branch:** `feature/registration-block-ordering-Umair`

### Description

Same as the callsheet feature above, but applied to the registration form. Information blocks in the registration editor could not be reordered or positioned relative to the Events and Program sections.

### Fix

Added the same ordering and positioning system to the registration form:

- **Move blocks up or down** using ▲ ▼ buttons
- **Choose the position** of each block — either **above** or **below** the default content

### Files Changed

**Backend:**

| File | Change |
|------|--------|
| `database/migrations/[timestamp]_add_order_position_to_content_registrations.ts` | Added `order` and `position` columns to `content_registrations` table |
| `app/models/content_registration.ts` | Added `order` and `position` model properties |
| `app/validators/registration.ts` | Added `order` and `position` validation |
| `app/controllers/registrations_controller.ts` | Updated to save `order` and `position` |

**Frontend:**

| File | Change |
|------|--------|
| `src/lib/types/ContentRegistration.ts` | Added `order` and `position` fields to the type |
| `src/lib/components/registration/RegistrationModifier.svelte` | Added ▲ ▼ buttons and position dropdown |
| `src/lib/components/registration/RegistrationShow.svelte` | Updated to display blocks in correct order and position |