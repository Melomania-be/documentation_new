# Mobile Notifications Plan

## Recommended architecture

The best fit for this project is:

- Store every notification in the backend database
- Register mobile device tokens per musician
- Send push notifications only for important events
- Keep an in-app notification center fed by the same backend records

This gives:

- history
- unread state
- resilience when push is unavailable
- a clean base for iOS and Android

## Implemented in this repo

Backend support has been added for:

- persistent `notifications`
- mobile `device_tokens`
- optional `users.contact_id` link
- authenticated notification API
- automatic notifications for:
  - new piece added to a project
  - new concert created in a project
  - participant added to a project
  - participant validated
  - participant assigned to a concert
  - participant assigned to a rehearsal
  - participant removed from a project

## New backend routes

- `GET /notifications`
- `POST /notifications/register-device`
- `POST /notifications/read-all`
- `POST /notifications/:id/read`

## Suggested notification scenarios

### High priority push

- invitation received
- participation confirmed
- concert created
- concert assignment
- rehearsal assignment
- concert cancelled
- major schedule change

### In-app first

- new piece added
- material updated
- callsheet updated
- document added

## Mobile work still required

The current mobile app is a Capacitor wrapper. To receive native push notifications, add:

1. `@capacitor/push-notifications`
2. Firebase Cloud Messaging configuration for Android
3. Apple Push Notifications configuration for iOS

Optional but recommended later:

4. a provider service in the backend to actually send push payloads
5. user notification preferences
6. grouped notifications to reduce spam

## Minimal next steps

1. Run backend migrations
2. Link each mobile musician account to a `contact_id`
3. Add Capacitor Push Notifications in `mobile-main`
4. On login or app start, register the device token with `POST /notifications/register-device`
5. Build a mobile notifications screen backed by `GET /notifications`
6. Mark items as read with the new endpoints

## Capacitor integration outline

On mobile app startup:

1. Request push permission
2. Register with APNs/FCM
3. Send the returned token to the backend
4. Listen for foreground notifications
5. Open the right screen from notification payload data

Example payload fields to use in navigation:

- `project_id`
- `piece_id`
- `concert_id`
- `rehearsal_id`
- `participant_id`

## Best next backend improvement

Firebase push sending is now prepared in the backend with the Firebase Admin SDK.

To activate real outside-app push notifications, set these backend environment variables:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`

The private key must be copied as a single-line env value with `\n` escapes.

Example:

```env
FIREBASE_PROJECT_ID=my-firebase-project
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@my-firebase-project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nABC...\n-----END PRIVATE KEY-----\n"
```

Once those are present, important notifications are sent outside the app through FCM and still stored in the database.
