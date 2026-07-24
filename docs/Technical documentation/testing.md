# Automated Test Suite

*Written by Naomi and Borshon*

This page explains how the automated test suite works, where to find the tests, how to run them, and how to add new tests for your feature.

---

## Overview

The test suite is split into two parts:

- **Backend tests (Japa)**: tests the API endpoints directly, runs in the back repository
- **Frontend tests (Playwright)**: tests the app in a real browser, runs in the front repository

Both are configured to run automatically on every pull request to `dev` via **GitHub Actions**.

---

## How Automatic Testing on Every PR Works

When you open a pull request targeting `dev`, GitHub Actions automatically:

1. Spins up a fresh environment (Ubuntu, Node.js, PostgreSQL)
2. Installs all dependencies
3. Runs migrations and seeds the database
4. Runs all the tests
5. Reports the results directly on the PR

If any test fails, the PR is marked as failing. This prevents broken code from being merged into `dev`.

You can see the test results in the **Checks** tab of any pull request on GitHub.

---

## Backend Tests (Japa)

### Where to find them

```
back/
└── tests/
    ├── bootstrap.ts          ← Japa configuration (do not modify)
    └── functional/
        └── callsheet.spec.ts ← Example: callsheet API tests
```

Each feature has its own test file in `tests/functional/`.

### How to run them

Make sure the database is running (Docker), then:

```bash
cd back
node ace test functional
```

To run a specific test file:

```bash
node ace test functional --files callsheet
```

### How to add tests for your feature

1. Create a new file in `tests/functional/`:

```bash
touch tests/functional/[feature].spec.ts
```

2. Use this template:

```typescript
import { test } from '@japa/runner'

// Helper to get an auth token
async function getToken(client: any) {
  const response = await client.post('/sign_in').json({
    email: 'admin@admin.admin',
    password: 'admin'
  })
  return response.body().token
}

test.group('[Feature] API', () => {

  // Test unauthenticated access
  test('should return 401 for unauthenticated access', async ({ client }) => {
    const response = await client.get('/[your-route]')
    response.assertStatus(401)
  })

  // Test authenticated access
  test('should return 200 for authenticated user', async ({ client }) => {
    const token = await getToken(client)
    const response = await client
      .get('/[your-route]')
      .bearerToken(token)
    response.assertStatus(200)
  })

  // Test invalid ID
  test('should return 404 for invalid ID', async ({ client }) => {
    const response = await client.get('/[your-route]/99999')
    response.assertStatus(404)
  })

  // Test validation
  test('should return 422 when required field is missing', async ({ client }) => {
    const token = await getToken(client)
    const response = await client
      .post('/[your-route]')
      .bearerToken(token)
      .json({ /* missing required fields */ })
    response.assertStatus(422)
  })

})
```

3. Run your tests to make sure they pass:

```bash
node ace test functional
```

### Tips for writing Japa tests

- Use `99999` as a fake ID to test 404 responses: it is unlikely to exist in the database
- Always test both authenticated and unauthenticated access for protected routes
- Public routes (like the public callsheet page) do not need a token
- The `admin@admin.admin` user is created by the seed: make sure to run `node ace db:seed` before running tests

---

## Frontend Tests (Playwright)

### Where to find them

```
front/
└── tests/
    ├── auth.setup.ts         ← Saves login session (run once before tests)
    ├── callsheet.spec.ts     ← Example: callsheet frontend tests
    └── .auth/
        └── user.json         ← Saved login session (gitignored)
```

Each feature has its own test file in `tests/`.

### How to run them

Make sure both the back and front servers are running, then:

**Step 1: Generate the login session (only needed once, or when the session expires):**

```bash
cd front
npx playwright test --project=setup --headed
```

**Step 2: Run the tests:**

```bash
npx playwright test --project=chromium --no-deps
```

To run in headed mode (see the browser):

```bash
npx playwright test --project=chromium --headed --no-deps
```

To run in Playwright's interactive UI mode (highly recommended for debugging):

```bash
npx playwright test --ui
```

To run a specific file:

```bash
npx playwright test callsheet --project=chromium --no-deps
```

### How to add tests for your feature

1. Create a new file in `tests/`:

```bash
touch tests/[feature].spec.ts
```

2. Use this template:

```typescript
import { test, expect } from '@playwright/test'

const BASE_URL = 'http://localhost:5173'

test.describe('[Feature] Feature', () => {

  // Test that requires login (uses saved session from auth.setup.ts)
  test('should display [feature] page', async ({ page }) => {
    await page.goto(`${BASE_URL}/[your-route]`)
    await expect(page).toHaveURL(/.*[your-route].*/)
    await expect(page.locator('body')).toBeVisible()
  })

  // Test that does not require login (fresh browser context)
  test('should redirect unauthenticated user to login', async ({ browser }) => {
    const context = await browser.newContext({ storageState: undefined })
    const page = await context.newPage()
    await page.goto(`${BASE_URL}/[your-route]`)
    await expect(page).toHaveURL(/.*login.*/)
    await context.close()
  })

})
```

3. Run your tests:

```bash
npx playwright test [feature] --project=chromium --no-deps
```

### Tips for writing Playwright tests

- The login session is saved in `tests/.auth/user.json`: this file is gitignored and must be generated locally
- Use `{ storageState: undefined }` for tests that should not be authenticated
- Run tests with `--headed` or `--ui` to see the browser and debug issues
- Keep tests independent: each test should work on its own without relying on another test

#### Testing browser dialogs (Alerts/Confirmations)

If your feature displays a browser dialog (like the warning when adding a contact already in the list), you must set up a listener in Playwright before triggering the action:

```typescript
test('should display alert when contact is already in list', async ({ page }) => {
  // Set up the listener first
  page.on('dialog', async (dialog) => {
    expect(dialog.message()).toContain('already in the list');
    await dialog.accept(); // Clicks 'OK'
  });

  // Trigger the action
  await page.click('button:has-text("Add to List")');
});
```

---

## GitHub Actions Configuration

### Backend CI

File: `back/.github/workflows/test.yml`

Runs on every pull request to `dev`. It:
- Starts a PostgreSQL database
- Installs dependencies
- Runs migrations and seeds
- Runs all Japa functional tests

### Frontend CI

File: `front/.github/workflows/playwright.yml`

Runs on every pull request to `dev` and `master`. It:
- Installs dependencies
- Installs Playwright browsers
- Runs all Playwright tests
- Uploads the test report as an artifact if tests fail

---

## Naming Conventions

- Backend test files: `tests/functional/[feature].spec.ts`
- Frontend test files: `tests/[feature].spec.ts`
- Test group names: `'[Feature] API'` for backend, `'[Feature] Feature'` for frontend
- Test names should clearly describe what is being tested (e.g. `'should return 404 for invalid ID'`)

---

## Updating Tests

When you modify a feature, you must also update the corresponding test file. If you add a new endpoint, add a test for it. If you change validation rules, update the validation test. This ensures the test suite stays in sync with the codebase.

---

## Troubleshooting

### "ECONNREFUSED" or database connection issues during Japa tests

* Ensure your local PostgreSQL database is running.
* Ensure you have run migrations and seeded the database using `node ace migration:run` and `node ace db:seed` in the `back/` folder.
* Verify your backend environment settings in the `back/.env` file.
