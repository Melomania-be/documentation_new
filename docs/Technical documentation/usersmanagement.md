# TD - User Management 

*Edited by Ramy*

## Overview

This module implements the complete user management and authentication workflow between:

- Frontend: SvelteKit admin interface + API proxy routes
- Backend: AdonisJS REST API
- Authentication: Bearer access tokens stored in cookies

The system allows:

- User authentication
- Session management
- User creation
- User edition
- User deletion
- Current user retrieval
- Admin-only access control
- Authentication cookie cleanup

---

# Architecture

## Frontend Architecture (SvelteKit)

Frontend API routes act as a proxy layer between the browser and AdonisJS.

Advantages:

- Hides backend URL
- Centralizes authentication logic
- Manages bearer tokens through cookies
- Simplifies frontend/backend communication
- Provides centralized error handling

Base pattern:

```ts
const res = await fetch(`${API_URL}/users`, {
  method: 'GET',
  headers: {
    authorization: `${await getToken(cookies)}`
  }
})
```

Environment variable:

```env
API_URL=http://backend-url
```

---

# Frontend API Routes

| Route | Method | Purpose |
|---|---|---|
| `/api/users` | GET | Retrieve all users |
| `/api/users` | PUT | Create new user |
| `/api/users` | PATCH | Update existing user |
| `/api/users` | DELETE | Delete user |
| `/api/users/current` | GET | Retrieve authenticated user |
| `/api/sign_in` | POST | Authenticate user |
| `/auth/cleanup` | GET | Clear corrupted authentication cookies |

---

# Authentication System

## Token Storage

Authentication relies on bearer access tokens stored inside cookies.

Cookie name:

```txt
Authorization
```

Example:

```txt
Bearer oat_xxxxxxxxx
```

Authentication flow:

```txt
Login
→ Backend generates access token
→ Frontend stores token in cookie
→ SvelteKit proxy forwards Authorization header
→ AdonisJS authenticates request
```

---

## Authentication Utility Layer

File:

```txt
src/lib/server/authentification.ts
```

Main responsibilities:

- Store authentication tokens
- Retrieve authentication tokens
- Remove invalid tokens
- Validate token format
- Cleanup corrupted cookies

Core functions:

```ts
setToken()
getToken()
removeToken()
isTokenValid()
cleanupCorruptedCookies()
```

---

# Frontend User Management Page

Main page:

```txt
src/routes/users/+page.svelte
```

Main features:

- User listing
- User creation form
- Inline user edition
- User deletion
- User activity display
- Session information display

---

# User Interface Features

## Add User

Allows administrators to create new users.

Fields:

```txt
fullName
email
password
password_confirmation
```

Request:

```txt
PUT /api/users
```

---

## Edit User

Allows administrators to modify:

- full name
- email

Request:

```txt
PATCH /api/users
```

---

## Delete User

Allows administrators to delete existing users.

Request:

```txt
DELETE /api/users
```

Security restriction:

```txt
Super admin cannot be deleted
```

---

## Current User Retrieval

Route:

```txt
GET /api/users/current
```

Used for:

- session persistence
- displaying connected user information
- frontend authentication checks

---

# Backend Architecture (AdonisJS)

Main controller:

```txt
UsersController
```

Responsibilities:

- Authentication
- User CRUD operations
- Access token management
- Authorization checks
- Session management

---

# Backend Routes

## User routes

Prefix:

```txt
/users
```

Routes:

```txt
GET    /
GET    /current
PUT    /
PATCH  /:id
DELETE /:id
```

---

# Authentication Routes

Routes:

```txt
POST /sign_in
POST /sign_out
```

---

# UsersController

File:

```txt
app/controllers/users_controller.ts
```

Main methods:

| Method | Purpose |
|---|---|
| `getAll()` | Retrieve all users |
| `signIn()` | Authenticate user |
| `signOut()` | Revoke access token |
| `create()` | Create user |
| `update()` | Update user |
| `delete()` | Delete user |
| `getCurrentUser()` | Retrieve authenticated user |

---

# Authorization System

Authorization relies on AdonisJS Bouncer abilities.

Ability:

```txt
adminRights
```

Definition:

```ts
export const adminRights = Bouncer.ability(async (user: User) => {
  return user.email === env.get('ADMIN_EMAIL')
})
```

Important:

- No role system exists
- No permission hierarchy exists
- Admin access depends entirely on the configured admin email

Protected actions:

- create user
- update user
- delete user

---

# User Model

File:

```txt
app/models/user.ts
```

Main fields:

```ts
id
fullName
email
password
createdAt
updatedAt
```

---

## Access Token Provider

Authentication uses:

```ts
DbAccessTokensProvider
```

Configuration:

```ts
expiresIn: '30 days'
prefix: 'oat_'
table: 'auth_access_tokens'
```

Purpose:

- Persistent authentication
- API token management
- Session persistence

---

# Validation System

File:

```txt
app/validators/user.ts
```

Validators:

| Validator | Purpose |
|---|---|
| `userLoginValidator` | Login validation |
| `userCreationValidator` | User creation validation |
| `userUpdateValidator` | User update validation |

---

## User Creation Validation

Fields:

```txt
email
password
password_confirmation
fullName
```

---

## User Update Validation

Fields:

```txt
email
fullName
```

---

# Session Management

## Login Workflow

Flow:

| Step | Action |
|---|---|
| 1 | Frontend sends credentials |
| 2 | Backend validates credentials |
| 3 | Access token is generated |
| 4 | Token stored inside cookie |
| 5 | Future requests forward bearer token |

---

## Logout Workflow

Flow:

| Step | Action |
|---|---|
| 1 | Current token identified |
| 2 | Token revoked |
| 3 | Authentication cookie removed |

---

## Cleanup Route

Route:

```txt
/auth/cleanup
```

Purpose:

- Remove corrupted cookies
- Force authentication reset
- Clear invalid sessions

Deleted cookies:

```txt
Authorization
auth
session
```

---

# Security Notes

Security relies on:

- Bearer token authentication
- HTTP-only cookies in production
- Admin authorization checks
- Token validation
- Cookie cleanup mechanisms

Important limitation:

```txt
Admin access depends on a single configured email address
```

---

# Improvement Notes

- No role-based access control system (RBAC)

- Admin permissions rely on a single `adminRights` ability

- User listing performs sequential token queries

- Limited session management features

- Token cleanup logic handled manually