# TD: Mobile Notifications

*Edited by Stephane*

This page explains the mobile notification system used by Melomania, with a focus on Android.

The reading order is intentional:

1. first, the simple functional view
2. then, the technical details
3. finally, how to test it end to end

---

## Simple overview

Melomania mobile is a Capacitor-based native wrapper around the web application.

For Android notifications, the flow is simple:

1. The user opens the mobile app and logs in.
2. The frontend asks Android for notification permission.
3. Capacitor registers the device for push notifications.
4. Firebase returns a device token.
5. The frontend sends that token to the backend.
6. The backend stores the token in the `device_tokens` table.
7. When a supported business event happens, the backend creates a notification.
8. The backend sends a push through Firebase Cloud Messaging.
9. Android displays the notification.
10. If the user taps it, the app opens the related Melomania page.

At the moment, push sending is enabled only for these notification types:

- `project_application_submitted`
- `recruitment_status_changed`

This filtering is done in `back/app/services/notification_service.ts`.

---

## Code locations

### Mobile wrapper

- `mobile/package.json`
- `mobile/capacitor.config.ts`
- `mobile/android/app/src/main/AndroidManifest.xml`
- `mobile/android/app/src/main/java/be/melomania/app/MainActivity.java`

### Frontend notification registration

- `front/src/lib/client/mobilePush.ts`
- `front/src/routes/+layout.svelte`

### Backend notification handling

- `back/app/controllers/notifications_controller.ts`
- `back/app/services/notification_service.ts`
- `back/app/services/firebase_push_service.ts`
- `back/app/models/device_token.ts`
- `back/app/models/notification.ts`
- `back/app/validators/notification.ts`

---

## How it works

## 1. Android native layer

The Android-specific notification setup lives in the native Capacitor project.

In `mobile/android/app/src/main/AndroidManifest.xml`:

- the app declares `android.permission.INTERNET`
- the app declares `android.permission.POST_NOTIFICATIONS`
- the default Firebase notification channel id is declared in app metadata

In `mobile/android/app/src/main/java/be/melomania/app/MainActivity.java`:

- the app creates a default Android notification channel on startup
- channel id: `melomania_general`
- channel name: `General notifications`
- importance: `IMPORTANCE_HIGH`

This is important because Android 8+ requires notification channels for visible notifications.

## 2. Capacitor SDK layer

The mobile wrapper depends on these packages:

- `@capacitor/core` `^8.1.0`
- `@capacitor/android` `^8.1.0`
- `@capacitor/push-notifications` `^8.0.0`
- `@capacitor/local-notifications` `^8.0.0`

These packages are declared in `mobile/package.json`.

Their roles are:

- `PushNotifications`: receive remote notifications from Firebase
- `LocalNotifications`: display a local notification when a push arrives while the app is already open

That second part matters because foreground push notifications are not always shown visually by default. The project compensates for that by showing a local notification.

## 3. Frontend initialization

When the frontend layout mounts, `front/src/routes/+layout.svelte` calls:

```ts
initMobilePushNotifications()
```

The logic lives in `front/src/lib/client/mobilePush.ts`.

This function:

1. checks that the app is running inside a native Capacitor platform
2. requests push permission
3. calls `PushNotifications.register()`
4. waits for the native registration callback
5. extracts the Firebase token
6. sends the token to the backend

It also subscribes to these events:

- `registration`
- `registrationError`
- `pushNotificationReceived`
- `pushNotificationActionPerformed`
- `localNotificationActionPerformed`

## 4. Device token registration

Once the token is received, the frontend sends it to:

```text
/api/notifications/register-device
```

The payload contains:

- `token`
- `platform`
- `provider`
- `device_label`
- optionally `app_version`

Validation is handled by `back/app/validators/notification.ts`.

Then `back/app/controllers/notifications_controller.ts` calls:

```ts
NotificationService.registerDeviceToken(...)
```

That service stores or updates the token in the `device_tokens` table.

Important behavior:

- if the token already exists, it is updated
- `user_id` is attached
- `contact_id` is attached when the user can be linked to a contact
- `last_seen_at` is refreshed

## 5. Notification creation in the backend

Business logic creates notifications through `NotificationService`.

Each notification is first stored in the `notifications` table with fields such as:

- `type`
- `title`
- `body`
- `data`
- `project_id`
- `actor_user_id`

After that, `sendPushIfNeeded(...)` decides whether a mobile push should be sent too.

Not every in-app notification becomes a mobile push. The allowed types are controlled by the `pushEnabledTypes` set in `back/app/services/notification_service.ts`.

## 6. Database structure

Two database tables are central to the mobile notification flow:

- `notifications`
- `device_tokens`

### `notifications` table

This table stores the in-app notification itself, whether or not a push was later sent successfully.

Main fields:

- `id`: notification identifier
- `user_id`: linked user when the notification targets a user
- `contact_id`: linked contact when the notification targets a contact
- `project_id`: related project when applicable
- `actor_user_id`: user who triggered the action, when available
- `organization_id`: tenant / organization scope
- `type`: functional notification type
- `title`: notification title
- `body`: notification body
- `data`: JSON payload used for contextual navigation
- `read_at`: timestamp set when the notification is marked as read
- `sent_push_at`: timestamp set only if a push was successfully sent
- `created_at`
- `updated_at`

Important point:

- a notification can exist in database even if no push was sent
- `sent_push_at` tells whether the push delivery step succeeded at backend level

### `device_tokens` table

This table stores the mobile tokens used to send Firebase push notifications.

Main fields:

- `id`
- `user_id`
- `contact_id`
- `organization_id`
- `platform`
- `provider`
- `token`
- `device_label`
- `app_version`
- `last_seen_at`
- `created_at`
- `updated_at`

Important constraints and behavior:

- uniqueness is enforced on `(token, organization_id)`
- the same token is scoped per organization in the multi-tenant setup
- `provider` defaults to `fcm`
- `platform` is sent by the mobile client, typically Android

### Token attribution

A token is attributed in this order:

1. the mobile app registers with Firebase through Capacitor
2. Firebase returns a registration token
3. the frontend sends that token to `/api/notifications/register-device`
4. the backend authenticates the current user
5. the backend stores the token with `user_id`
6. the backend also tries to attach `contact_id` by linking the user to a contact
7. in multi-tenant mode, `organization_id` is also part of the stored record

This is why a push can later be targeted either through `user_id` or `contact_id`.

### Token lifecycle

The current implementation does not store a dedicated token expiration date such as `expires_at`.

Today, token lifecycle is handled like this:

- when a token is first received, it is inserted into `device_tokens`
- when the same token is received again, the existing row is updated
- each registration refreshes `last_seen_at`
- if Firebase reports `registration-token-not-registered` or `invalid-registration-token`, the backend deletes that token

So in practice:

- there is no proactive expiration timestamp stored in database
- token validity is maintained reactively, based on Firebase feedback
- `last_seen_at` is the best field to estimate whether a token is still actively used

### Read status and push status

The notification lifecycle is split into two separate concerns:

- `read_at`: whether the user has read the in-app notification
- `sent_push_at`: whether the backend successfully sent the push

These two values are independent:

- a notification may be pushed but never read
- a notification may exist in database without being pushed

## 7. Firebase Admin SDK sending

The actual push sending is handled by `back/app/services/firebase_push_service.ts`.

This service:

1. checks whether Firebase credentials are configured
2. initializes the Firebase Admin SDK once
3. loads all matching device tokens for the recipient
4. converts notification data values to strings for FCM
5. sends a multicast push using `sendEachForMulticast(...)`
6. removes invalid tokens if Firebase reports them as invalid

The Firebase Admin SDK depends on these environment variables:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`

If these values are missing, pushes are not sent, but the backend keeps working and simply reports that Firebase is not configured.

## 8. Foreground vs background behavior

### App in background or closed

Android displays the Firebase push notification directly.

If the user taps it, the `pushNotificationActionPerformed` listener runs and redirects the app according to the payload.

### App open in foreground

The frontend receives `pushNotificationReceived`.

Then `showForegroundNotification(...)` uses Capacitor Local Notifications to display a visible local notification.

This avoids the situation where the app receives the push but the user sees nothing.

## 9. Navigation after tap

The current navigation logic is intentionally simple.

If the notification payload contains:

- `project_id`: redirect to `/projects/{project_id}/management`
- `piece_id`: redirect to `/library/pieces`

This logic is implemented in `handleNotificationNavigation(...)` in `front/src/lib/client/mobilePush.ts`.

---

## Android SDK and environment details

The Android toolchain involved in notifications is:

- Android Studio
- Android SDK
- Gradle
- Capacitor Android
- Firebase Cloud Messaging

The wrapper URL is configured in `mobile/capacitor.config.ts`.

Current behavior:

- if `MOBILE_APP_URL` is defined, Capacitor uses it
- otherwise it defaults to `http://10.0.2.2:5173`

`10.0.2.2` is the Android emulator alias for the host machine's localhost.

So in practice:

- local emulator testing can point to a local frontend server
- production builds should use the production frontend URL

The example environment file is:

- `mobile/.env.example`

Useful commands from `mobile/`:

```bash
npm run sync
npm run android
```

What they do:

- `npm run sync` propagates Capacitor config and plugins into the native Android project
- `npm run android` opens the Android project in Android Studio

---

## How to test

## Test scenarios

There are currently two business scenarios that should generate mobile push notifications:

1. a new project application is submitted
2. a recruitment status changes

These correspond to the two push-enabled notification types:

- `project_application_submitted`
- `recruitment_status_changed`

### Scenario 1: new project application submitted

Goal:

- verify that project responsibles receive a push when someone submits an application to a project

Preconditions:

1. Install and launch the Android app on a device or emulator for a user who is responsible for a project.
2. Log in with that responsible user's account.
3. Accept notification permission.
4. Confirm that a row exists in `device_tokens` for the connected user.
5. Make sure the target project has at least one registration form or submission path enabled.

Test steps:

1. From another account, or from the public registration flow, submit an application to the target project.
2. Confirm that the backend creates a notification of type `project_application_submitted`.
3. Confirm that the responsible user's Android device receives the push.
4. Tap the notification.

Expected result:

- the responsible user receives a push notification
- the push title/body mention the new application and the project name
- tapping the notification redirects to `/projects/{project_id}/management`

Technical origin:

- backend flow starts in `back/app/controllers/registrations_controller.ts`
- push is sent to project responsibles

### Scenario 2: recruitment status changed

Goal:

- verify that a contact receives a push when their recruitment status changes

Preconditions:

1. Install and launch the Android app on a device or emulator for a user linked to a contact in the project.
2. Log in with that user's account.
3. Accept notification permission.
4. Confirm that a row exists in `device_tokens` for the connected user.
5. Make sure that contact exists in the recruitment flow and can have its status changed.

Test steps:

1. Change the recruitment status of that contact in the project.
2. Confirm that the backend creates a notification of type `recruitment_status_changed`.
3. Confirm that the Android device receives the push.
4. Tap the notification.

Expected result:

- the contact receives a push notification
- the push body mentions the previous status and the new status
- tapping the notification redirects to `/projects/{project_id}/management`

Technical origin:

- backend flow is triggered from recruitment status updates
- main implementations are in `back/app/controllers/recruitment_controller.ts` and `back/app/controllers/participants_controller.ts`

## Detailed testing checklist

### A. Test token registration

Expected result:

- the frontend registers a token
- the backend stores it

How to verify:

1. Open the mobile app.
2. Log in.
3. Accept notification permission.
4. Inspect app logs.
5. Check the `device_tokens` table.

Things to verify in logs:

- initialization started
- registration payload received
- backend registration succeeded

Things to verify in `device_tokens`:

- `user_id`
- `contact_id`
- `platform`
- `provider`
- `token`
- `device_label`
- `last_seen_at`

### B. Test backend notification creation

Expected result:

- a row is created in `notifications`

How to verify:

1. Trigger a supported business action.
2. Inspect the created notification row.
3. Check whether `sent_push_at` is filled.

Useful fields:

- `type`
- `title`
- `body`
- `data`
- `project_id`
- `sent_push_at`

### C. Test Firebase delivery

Expected result:

- Firebase sends at least one message successfully

How to verify:

1. Check backend logs.
2. Make sure Firebase credentials are configured.
3. Confirm that the target user has at least one valid device token.

Failure patterns to watch:

- `firebase_not_configured`
- `no_device_tokens`
- invalid registration token errors

### D. Test foreground display

Expected result:

- the user sees a visible notification even when the app is already open

How to verify:

1. Keep the app open in foreground.
2. Trigger a push-enabled notification.
3. Confirm that `pushNotificationReceived` is hit.
4. Confirm that `LocalNotifications.schedule(...)` runs.
5. Confirm that the notification is visually displayed on Android.

### E. Test tap navigation

Expected result:

- tapping the notification opens the expected page

How to verify:

1. Send a notification with `project_id`.
2. Tap it and confirm redirect to the matching project management page.
3. Send a notification with `piece_id`.
4. Tap it and confirm redirect to the pieces library.

---

## Common issues

### Permission not granted

Symptoms:

- no push token registration
- no visible notifications

Check:

- Android app notification permission

### Firebase not configured

Symptoms:

- notifications are stored in database
- no push is sent

Check:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`

### No stored device token

Symptoms:

- backend creates notifications
- push sending reports `no_device_tokens`

Check:

- user really logged in from the mobile app
- register-device endpoint succeeded

### Invalid or stale token

Symptoms:

- Firebase send fails for one device

Check:

- reinstall or device reset may have invalidated the token
- the backend should remove invalid tokens automatically

### Wrong mobile URL

Symptoms:

- the app points to the wrong environment
- local tests hit production, or production APK points to local

Check:

- `mobile/capacitor.config.ts`
- `MOBILE_APP_URL`

---

## Current limitations

- Push is enabled only for a limited set of notification types.
- Navigation after tap supports only a few payload patterns.
- There is no dedicated automated test suite yet for the full mobile push flow in this repository.
- The implementation is mainly focused on Android behavior at this stage.
