# TD - Mobile Notifications

*Edited by Chines Stéphane on 24/07/2026*

## Overview

This feature adds a shared notification system for the web application and the Android mobile app.

The goal is simple:

- store important notifications in the backend database
- send outside-app push notifications to the mobile device when the recipient has a registered device token
- keep a persistent in-app history even when push delivery fails

At the moment, 2 business scenarios are actively used for push notifications:

- `project_application_submitted`
- `recruitment_status_changed`

This means the notification system is already generic, but the current functional scope is intentionally limited to the two scenarios above.

---

## Functional behavior

### Scenario 1 - New project application

When a candidate submits a real registration form for a project, the admins of that project receive a notification.

Important detail:

- this is triggered only by the registration submission flow
- it is **not** triggered when an admin manually adds a participant
- it is **not** triggered when an admin manually creates a recruitment contact

The expected result is:

1. a notification row is created in the backend
2. the backend resolves the responsible users linked to the project
3. if one of these users has a registered mobile device token, a push is sent

### Scenario 2 - Recruitment status changed

When the status of a recruitment contact changes, a notification is sent to the user assigned to that recruitment contact.

The expected result is:

1. the recruitment contact has an `assigned_user_id`
2. the status actually changes from one value to another
3. a notification row is created for the assigned user
4. if that user has a registered mobile device token, a push is sent

Important detail:

- creating a recruitment contact alone does not send this notification
- the notification is sent only when the status changes

---

## Architecture

The implementation is split into 4 layers:

- database persistence
- backend notification orchestration
- frontend notification APIs and app startup registration
- native Android push configuration

### 1. Database persistence

The backend stores notifications in a dedicated table and stores mobile device tokens in a second table.

This gives:

- delivery history
- in-app notification center support
- read state support
- resilience when push delivery fails

### 2. Backend orchestration

The backend is responsible for:

- deciding when a business event should create a notification
- resolving the final recipient
- saving the notification row
- sending push through Firebase Cloud Messaging when the notification type is push-enabled

### 3. Frontend and mobile registration

The frontend registers the mobile push token when the app starts on a native Capacitor platform.

The web application itself does not directly send push notifications. It only:

- initializes push registration on mobile
- forwards device tokens to the backend
- exposes notification API proxy routes

### 4. Native Android layer

The Android wrapper contains:

- the Capacitor Push Notifications plugin
- Android permission declarations
- the default notification channel setup

---

## User and device token relationship

One important point of this feature is understanding how a mobile device becomes linked to a real application user.

The link is not created manually in the database. It is created automatically when a connected user opens the mobile app and the app successfully registers a push token.

### How the link is created

The sequence is:

1. a user logs in on the mobile app
2. the app initializes Capacitor push notifications
3. the native layer returns a push token
4. the frontend sends that token to the backend
5. the backend authenticates the current user
6. the backend stores the token with that `user_id`

So the real business rule is:

- the token is linked to the **currently authenticated user**
- the link is created the first time that user successfully registers push on that device

### Why `contact_id` is also stored

The backend also stores `contact_id` on the same `device_tokens` row when possible.

This is useful because some notifications are initially resolved through contacts rather than users. Storing both values makes recipient resolution more reliable.

### Can the link change later?

Yes. The link is not permanent.

Typical situations:

- the same user changes phone
- the same phone gets a new push token
- another user logs into the same mobile device
- an old token becomes invalid

### Same user, new phone

If the same user connects on a new phone, the new device registers a new token.

Result:

- a new row can be created in `device_tokens`
- both phones may temporarily receive push notifications for the same user

This is normal and useful when a user owns more than one device.

### Same phone, same user, token refreshed

Native push providers can rotate tokens.

If the token changes, the backend will store the new token the next time registration happens.

### Same phone, different user

If a device already has a token and another user logs into the app on that same phone, the token can be reassigned.

This happens because the backend updates the existing `device_tokens` row when the same token is sent again with a different authenticated user.

In practice:

- the token stays the technical key
- the `user_id` and `contact_id` attached to that token can change

### Invalid or obsolete tokens

When Firebase reports that a token is invalid or no longer registered, the backend removes it automatically.

This prevents sending push notifications forever to dead devices.

### Practical consequence for debugging

When a user says "I do not receive notifications", it is not enough to check whether the user exists.

You must also verify:

- whether the user has at least one row in `device_tokens`
- whether that row is linked to the correct `user_id`
- whether the token is still valid
- whether the app has re-registered the token recently

---

## Current notification types

The push-enabled types are currently defined in the backend notification service.

Active types:

- `project_application_submitted`
- `recruitment_status_changed`

This is intentional. Earlier experiments around concerts, pieces and other project events were removed from the active push scope.

---

## Main backend files

### NotificationService

File:

```txt
back/app/services/notification_service.ts
```

Responsibilities:

- create notification rows
- resolve recipients from `user_id`, `contact_id`, full name or email
- synchronize `users.contact_id` and `device_tokens.contact_id`
- decide whether a notification type should trigger push sending
- mark notifications as read

Main public methods:

- `createForContact()`
- `createForUserId()`
- `createForUserName()`
- `createForParticipant()`
- `listForRecipient()`
- `markAsReadForRecipient()`
- `markAllAsReadForRecipient()`
- `registerDeviceToken()`

### FirebasePushService

File:

```txt
back/app/services/firebase_push_service.ts
```

Responsibilities:

- initialize Firebase Admin
- load device tokens for a recipient
- send multicast push payloads through FCM
- remove invalid tokens when Firebase reports them as unusable

Configuration note:

The environment variables required for Firebase are intentionally not documented here. For the configuration values and secure setup procedure, contact **CHINES Stéphane**.

### NotificationsController

File:

```txt
back/app/controllers/notifications_controller.ts
```

Responsibilities:

- list the authenticated user's notifications
- register device tokens
- mark one notification as read
- mark all notifications as read

### RegistrationsController

File:

```txt
back/app/controllers/registrations_controller.ts
```

Responsibilities for notifications:

- detect when a registration submission creates a **new** application
- notify the responsible contacts of the project with `project_application_submitted`

Important detail:

- if the participant already exists for the same project and contact, the application is not considered new, so the admin notification is not sent again

### RecruitmentController

File:

```txt
back/app/controllers/recruitment_controller.ts
```

Responsibilities for notifications:

- assign recruitment contacts to a real user through `assigned_user_id`
- notify the assigned user when the recruitment status changes

### ParticipantsController

File:

```txt
back/app/controllers/participants_controller.ts
```

Responsibilities for notifications:

- keep recruitment synchronization consistent when participant-related actions update recruitment state
- send the same recruitment status notification logic when that change is triggered from the participants workflow

---

## Frontend files

### Mobile push bootstrap

File:

```txt
front/src/lib/client/mobilePush.ts
```

Responsibilities:

- detect whether the app is running on a native Capacitor platform
- request notification permission
- register with the native push provider
- send the device token to the backend
- react to notification click actions

### Layout initialization

File:

```txt
front/src/routes/+layout.svelte
```

Responsibilities:

- initialize mobile push registration when the application is loaded on mobile

### Notification API proxy routes

Files:

```txt
front/src/routes/api/notifications/+server.ts
front/src/routes/api/notifications/register-device/+server.ts
front/src/routes/api/notifications/read-all/+server.ts
front/src/routes/api/notifications/[id]/read/+server.ts
```

Responsibilities:

- forward authenticated requests from the frontend to the AdonisJS backend

---

## Android native files

Main files:

```txt
mobile-main/android/app/src/main/AndroidManifest.xml
mobile-main/android/app/src/main/java/be/melomania/app/MainActivity.java
mobile-main/android/app/src/main/res/values/strings.xml
mobile-main/android/app/capacitor.build.gradle
```

Responsibilities:

- declare the Android notification permission
- configure the default notification channel
- include the Capacitor Push Notifications plugin in the Android build

Important limitation:

Push notifications rely on Firebase Cloud Messaging and therefore require a valid Android environment compatible with Google Play Services.

---

## API routes

### Public registration route

Used by the project application scenario:

```txt
PUT /registration/submit
```

Declared in:

```txt
back/start/routes.ts
```

### Authenticated notification routes

Routes:

```txt
GET  /notifications
POST /notifications/register-device
POST /notifications/read-all
POST /notifications/:id/read
```

These routes are authenticated and operate on the currently connected user.

---

## Database structure

### notifications

Migration:

```txt
back/database/migrations/1762500000001_create_notifications_table.ts
```

Purpose:

- stores the canonical notification history

Main columns:

| Column | Type | Purpose |
|---|---|---|
| `id` | increments | Primary key |
| `user_id` | integer nullable | Target user |
| `contact_id` | integer nullable | Target contact |
| `project_id` | integer nullable | Related project |
| `actor_user_id` | integer nullable | User who triggered the action |
| `type` | string | Notification type |
| `title` | string | Short title |
| `body` | string | Human-readable message |
| `data` | json/jsonb | Navigation and business payload |
| `read_at` | timestamp nullable | Read state |
| `sent_push_at` | timestamp nullable | Set only when push sending succeeds |
| `created_at` / `updated_at` | timestamp | Timestamps |

Important detail:

- `sent_push_at = null` means the notification may still exist and be visible in-app, but no successful push delivery was recorded

### device_tokens

Migration:

```txt
back/database/migrations/1762500000002_create_device_tokens_table.ts
```

Purpose:

- stores mobile devices able to receive push notifications

Main columns:

| Column | Type | Purpose |
|---|---|---|
| `id` | increments | Primary key |
| `user_id` | integer nullable | Linked application user |
| `contact_id` | integer nullable | Linked musician/contact |
| `platform` | string | Usually `android` here |
| `provider` | string | Push provider |
| `token` | text/string | Native push token |
| `device_label` | string nullable | Device description |
| `app_version` | string nullable | App version if provided |
| `last_seen_at` | timestamp nullable | Last successful registration |
| `created_at` / `updated_at` | timestamp | Timestamps |

### users.contact_id

Migration:

```txt
back/database/migrations/1762500000000_add_contact_id_to_users_table.ts
```

Purpose:

- links an authenticated user account to a contact entry
- allows the notification system to resolve recipients more reliably

### recruitment_contacts.assigned_user_id

Migration:

```txt
back/database/migrations/1763200000000_add_assigned_user_id_to_recruitment_contacts_table.ts
```

Purpose:

- links a recruitment contact to a real user account instead of relying only on the free-text `contacted_by` field

This is especially important for mobile notifications because push delivery needs a real application user with registered device tokens.

---

## Main workflows

### Workflow 1 - Registering a mobile device

1. The mobile app starts on a native Capacitor platform.
2. The app requests notification permission.
3. The native layer returns a push token.
4. The frontend sends this token to `POST /notifications/register-device`.
5. The backend stores or updates the token in `device_tokens`.

Important detail:

- the token is registered for the user who is authenticated at that moment
- this is the moment where the `device_token -> user` relationship is established or updated

### Workflow 2 - New project application

1. A candidate submits the public registration form.
2. `RegistrationsController.submit()` creates or reuses the contact.
3. The controller checks whether the participant is new for that project.
4. If it is a real new application, the controller loads the project responsibles.
5. A `project_application_submitted` notification is created for each responsible.
6. `NotificationService` attempts push sending for each recipient.

### Workflow 3 - Recruitment status changed

1. A recruiter updates the status of a recruitment contact.
2. The backend compares the old and new statuses.
3. If the status actually changed, a `recruitment_status_changed` notification is created.
4. The recipient is the assigned user of that recruitment contact.
5. `NotificationService` attempts push sending for that user.

---

## Important behavior notes

- A notification can exist in the database without being pushed. This happens when no valid device token is found, when Firebase is not configured, or when push sending fails.
- `project_application_submitted` is linked to the **registration submission** flow, not to manual participant creation.
- `recruitment_status_changed` is linked to a **status change**, not to recruitment contact creation.
- Recruitment push delivery depends heavily on `assigned_user_id`. If a contact is assigned to the wrong user, the push will go to the wrong recipient or to nobody.
- A device token belongs to the user who was authenticated when that token was registered. If another user logs into the same phone later, the token can be reassigned.
- Old invalid tokens are automatically removed when Firebase reports them as unregistered or invalid.

---

## How to troubleshoot

When a user says "I did not receive the notification", the fastest checks are:

1. verify that a row was created in `notifications`
2. verify the `user_id` and `contact_id` of that row
3. verify that the target user has a row in `device_tokens`
4. verify whether `sent_push_at` is filled
5. verify whether the functional trigger was the correct one

Examples:

- a recruitment contact was created but its status never changed: no `recruitment_status_changed` notification should exist
- a participant was manually added by an admin: no `project_application_submitted` notification should exist
- a notification exists but `sent_push_at` is null: the history exists, but push was not confirmed

---

## Security and configuration note

This documentation intentionally does not expose the Firebase environment variables, service-account content, or any secret values.

For secure configuration, secret rotation, or Firebase setup details, contact **CHINES Stéphane**.
