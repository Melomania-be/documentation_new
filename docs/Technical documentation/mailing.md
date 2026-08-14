# TD - Mailing Feature

*Edited by Stéphane on 14/05/2026*

## Overview

The Mailing feature is Melomania's comprehensive email communication system that enables project managers and administrators to send personalized emails to participants, contacts, and mailing lists. The system supports both automated notifications (like registration confirmations and callsheet updates) and manual communications using customizable HTML templates with dynamic content replacement. It includes two main interfaces: global mailing for app-wide communications and project-specific mailing for targeted participant notifications.

---

## How the feature works

The mailing feature provides several working paths for administrators and project managers:

1. Open the global mailing interface or the project mailing page.
2. Choose the type of email to send:
   - Use an existing custom template.
   - Use a default system template.
   - Create a completely new template from scratch.
   - Send a one-off custom message without a saved template.
3. If creating a new template:
   - Enter the template name, subject, and HTML content.
   - Insert dynamic placeholders for contact and project data.
   - Save the template for reuse in future mailings.
4. If using a saved template, select it from the template list and optionally edit its content before sending.
5. Define the recipient scope:
   - All contacts in a mailing list.
   - All accepted participants of a project.
   - A specific participant or contact for individual notifications.

> Warning: the email recipient must already exist in the system before sending. Contacts or participants should be created and saved first so the mailing feature can resolve the recipient data correctly.

6. The system loads the template content and resolves placeholders using the selected recipient data and project context.
7. The processed email content is sent through the AdonisJS mail service.
8. Each send is recorded in the `outgoing_mails` table, including the template used, recipient, project reference, and send status.

---

## Receiver perspective

From the recipient side, the mailing feature is entirely passive: the recipient receives messages and interacts only with the content of those emails.


- The recipient can receive different types of email depending on their status:
  - project participants can receive callsheet notifications, recruitment updates, audition invitations, and participation status emails;
  - mailing list contacts can receive newsletters, announcements, and custom campaign messages.
- For participation workflows, the recipient may specifically receive:
  - **acceptance emails** confirming that their participation is validated and providing next steps such as callsheet access or event information;
  - **refusal emails** notifying them that their request was declined and possibly giving explanations or next steps.
- The email content is personalized automatically, so the recipient sees their own name, the relevant project details, and any action links.
- The recipient does not need to open the app to receive these messages, but they may follow links in the email to view callsheets, registration pages, or project details.


---

## Architecture

### Frontend

| Route | File | Description |
|-------|------|-------------|
| `/mailing` | `src/routes/mailing/+page.svelte` | Global mailing interface with three tabs: sending emails, managing custom templates, and configuring system templates |
| `/projects/[id]/management/mailing` | `src/routes/projects/[id]/management/mailing/+page.svelte` | Project-specific mailing interface for sending notifications to project participants |

### Backend

| File | Description |
|------|-------------|
| `app/controllers/mailings_controller.ts` | Main controller handling all mailing operations including sending emails, managing templates, and tracking outgoing mail |
| `app/controllers/default_templates_controller.ts` | Handles system default email templates management |
| `app/models/mail_template.ts` | Database model for email templates |
| `app/models/outgoing_mail.ts` | Database model for tracking sent emails |
| `app/mails/` | Directory containing email template classes for different notification types |

### Email Template Classes

| File | Description |
|------|-------------|
| `app/mails/callsheet_notification.ts` | Template for callsheet update notifications |
| `app/mails/participation_validation_notification.ts` | Template for participation confirmation emails |
| `app/mails/recruitment_notification.ts` | Template for recruitment campaign emails |
| `app/mails/recommended_notification.ts` | Template for recommendation emails |
| `app/mails/refusal_notification.ts` | Template for participation refusal emails |
| `app/mails/audition_request.ts` | Template for audition request emails |
| `app/mails/template_preparation.ts` | Generic template processor with dynamic content replacement |
| `app/mails/unique_preparation.ts` | Template for one-off emails without templates |

### API Endpoints

#### Project Mailing Endpoints (authenticated)

| Method | Endpoint | Controller Method | Description |
|--------|----------|-------------------|-------------|
| `GET` | `/api/projects/:id/management/mailing` | `getOutgoing` | Get last sent notification timestamps for recruitment and callsheet emails |

#### Global Mailing Endpoints (authenticated)

| Method | Endpoint | Controller Method | Description |
|--------|----------|-------------------|-------------|
| `POST` | `/api/mailing/sendUnique` | `sendUnique` | Send a custom email to all contacts in a mailing list |
| `POST` | `/api/mailing/sendMailToParticipants` | `sendMailToParticipants` | Send email to all accepted participants of a project (template or custom) |
| `POST` | `/api/mailing/sendTemplateToList` | `sendTemplateToList` | Send a template email to all contacts in a mailing list |
| `POST` | `/api/mailing/sendCallsheetNotification` | `sendCallsheetNotification` | Send callsheet update notification to all project participants |
| `POST` | `/api/mailing/sendRecruitmentNotification` | `sendRecruitmentNotification` | Send recruitment campaign email to all subscribed contacts |
| `POST` | `/api/mailing/sendParticipationValidationNotification` | `sendParticipationValidationNotification` | Send participation confirmation email to individual participant |
| `POST` | `/api/mailing/sendRecommendedNotification` | `sendRecommendedNotification` | Send recommendation email to potential participant |
| `POST` | `/api/mailing/sendRefusalEmailToParticipant` | `sendRefusalEmailToParticipant` | Send participation refusal email to participant |
| `POST` | `/api/mailing/sendAuditionRequest` | `sendAuditionRequest` | Send audition request email to participant |
| `POST` | `/api/mailing/sendMailToIndividualContacts` | `sendMailToIndividualContacts` | Send a custom email or template to a selected list of individual contacts |

#### Default Templates Endpoints (authenticated)

| Method | Endpoint | Controller Method | Description |
|--------|----------|-------------------|-------------|
| `GET` | `/api/mailing/templates/default` | `getDefaultTemplates` | Get all system default email templates |
| `PUT` | `/api/mailing/templates/default/edit` | `editDefaultTemplate` | Update a system default email template |

### Sending to Individual Contacts

The `sendMailToIndividualContacts` method (added in #201) sends an email to a
hand-picked list of contacts, rather than to a whole list or all participants.

It expects the following body:
- `contactIds` (number[]): the IDs of the contacts to send to. If empty or missing, the endpoint returns a 400.
- `type` (`'unique'` | `'template'`): whether to send a one-off custom message or a saved template.
- `subject`, `content`: used when `type` is `'unique'`.
- `templateId`: used when `type` is `'template'`.

For each contact, the email is only sent if **all three** conditions are met:
the contact has an email, `subscribed === true`, and `validated === true`.
Contacts that don't match are silently skipped.

Each successful send is recorded in the `outgoing_mails` table (with `receiver_id`,
`type`, and `sent` status), like the other mailing methods.

---

## Database Structure

### `mail_templates` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | `number` (Primary Key) | Unique identifier for the template |
| `name` | `string` | Template name |
| `content` | `string` | HTML content of the template |
| `is_default` | `boolean` | Whether this is a system default template |
| `createdAt` | `DateTime` | Creation timestamp |
| `updatedAt` | `DateTime` | Last update timestamp |

### `outgoing_mails` table

| Column | Type | Description |
|--------|------|-------------|
| `id` | `number` (Primary Key) | Unique identifier for the sent email |
| `type` | `string` | Type of email sent (unique, template, callsheet_notification, etc.) |
| `receiver_id` | `number` | ID of the contact who received the email |
| `project_id` | `number` | ID of the related project (null for global emails) |
| `mail_template_id` | `number` | ID of the template used (null for non-template emails) |
| `sent` | `boolean` | Whether the email was successfully sent |
| `createdAt` | `DateTime` | Creation timestamp |
| `updatedAt` | `DateTime` | Last update timestamp |

---

## Email Template System

### Dynamic Content Replacement

Email templates support dynamic content replacement using placeholders:

| Placeholder | Description | Source |
|-------------|-------------|--------|
| `${CONTACT_FIRST_NAME}` | Recipient's first name | Contact record |
| `${CONTACT_LAST_NAME}` | Recipient's last name | Contact record |
| `${PROJECT_NAME}` | Project name | Project record |
| `${PROJECT_DATE}` | Project date | Project record |
| `${TO_CONTACT_FIRST_NAME}` | Responsible person's first name | Project responsibles |
| `${TO_CONTACT_LAST_NAME}` | Responsible person's last name | Project responsibles |
| `${TO_CONTACT_EMAIL}` | Responsible person's email | Project responsibles |
| `${CALLSHEET_LINK}` | Public link to callsheet | Generated URL |
| `${REGISTRATION_LINK}` | Public link to registration form | Generated URL |

### Template Processing Flow

1. **Template Selection**: User selects or creates an email template
2. **Content Preparation**: Template content is loaded and placeholders are identified
3. **Data Gathering**: Required data (contact, project, responsibles, etc.) is fetched
4. **Content Replacement**: Placeholders are replaced with actual values
5. **Email Sending**: Processed HTML content is sent via AdonisJS mail service
6. **Tracking**: Email send is recorded in `outgoing_mails` table

---

## Key Features

### Automated Notifications

The system automatically sends emails for certain events:
- **Registration Confirmation**: Sent when participant registration is validated
- **Participation Validation**: Confirmation email with callsheet link
- **Audition Requests**: Individual emails for audition scheduling
- **Refusal Notifications**: Polite rejection emails for declined participants

### Template Management

- **Custom Templates**: User-created templates for specific communications
- **System Templates**: Pre-defined templates for standard notifications
- **HTML Editor**: Rich text editor for template creation and editing
- **Template Variables**: Dynamic content insertion for personalization

### Mailing Lists Integration

- Integration with contact lists for bulk communications
- Filtering by subscription status and email validation
- Support for both project participants and general contact lists

### Tracking and Analytics

- Complete logging of all sent emails
- Tracking of notification types and timestamps
- Status monitoring for recruitment and callsheet notifications

