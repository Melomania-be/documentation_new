# Workflows

*Edited by Umair*

This page provides detailed explanations about the workflows used in the development process of the app.

---

## Setting up the app locally

To run the app on your local machine you need three repositories: **front**, **back** and **database**. Make sure **Docker** is installed and running on your machine before starting.

### Step 1 — Clone the three repositories

```bash
git clone https://github.com/Melomania-be/front.git
git clone https://github.com/Melomania-be/back.git
git clone https://github.com/Melomania-be/database.git
```

### Step 2 — Start the database

Go into the database folder and run:

```bash
cd database
docker compose up -d
```

This starts a PostgreSQL database and an Adminer interface (a database viewer available at `http://localhost:8888`).

The default database credentials from `docker-compose.yml` are:
```
POSTGRES_USER=admin123
POSTGRES_PASSWORD=admin123
POSTGRES_DB=melomania
```

### Step 3 — Set up the backend

Go into the back folder and create a `.env` file:

```bash
cd back
cp .env.example .env
```

Fill in the `.env` file with the following values:

```
DB_HOST=localhost
DB_PORT=5432
DB_USER=admin123
DB_PASSWORD=admin123
DB_DATABASE=melomania
```

> ⚠️ If port 5432 is already in use on your machine, use `DB_PORT=5433` instead and update the `docker-compose.yml` ports accordingly.

You also need to set the admin user credentials (used to create the first user via `db:seed`):

```
ADMIN_EMAIL=admin@admin.admin
ADMIN_PASSWORD=admin
```

And the SMTP variables (required for the backend to start, even locally):

```
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USERNAME=local
SMTP_PASSWORD=local
```

> ℹ️ Emails don't actually send locally but these values must exist or AdonisJS will block startup.

Then install dependencies, run migrations and seed the database:

```bash
npm install
node ace migration:run
node ace db:seed
npm run dev
```

> ℹ️ `node ace db:seed` creates the admin user using the `ADMIN_EMAIL` and `ADMIN_PASSWORD` values from your `.env`. If you skip this step, the admin account will not exist yet.

The backend will be available at `http://localhost:3333`.

### Step 4 — Set up the frontend

Go into the front folder and create a `.env` file:

```bash
cd front
```

Create a `.env` file with:

```
API_URL=http://localhost:3333
```

Then install dependencies and start the dev server:

```bash
npm install
npm run dev
```

The app will be available at `http://localhost:5173`.

You can log in with:
- **Email:** `admin@admin.admin`
- **Password:** `admin`

---

## Deploy front to development server

```bash
cd front
npm run build
```

Then push the build output to the development server using your deployment method (SSH, CI/CD, etc.).

---

## Deploy back to development server

The backend uses Docker for deployment. Build the Docker image:

```bash
cd back
docker build -t melomania-back .
```

Then deploy the image to the development server.

---

## Promote dev to prod

Once changes have been tested on the development server, promote them to production by:
1. Merging the dev branch into the main/master branch
2. Triggering the production deployment pipeline

---

## Bump version

To bump the version of the app update the `version` field in `package.json` in both the `front` and `back` repositories, then commit with a message like:

```bash
git commit -m "Bump version to x.x.x"
```

---

## Copy database from prod to dev

To copy the production database to the development server:
1. Create a dump of the production database using `pg_dump`
2. Transfer the dump to the development server
3. Restore it using `pg_restore` or `psql`

```bash
# On production server
pg_dump -U admin123 melomania > melomania_backup.sql

# On development server
psql -U admin123 melomania < melomania_backup.sql
```
