# TD - Multi-Tenant Architecture

*Edited by Naomi*

This page explains how the multi-tenant architecture works in Melomania, and what every developer needs to know to adapt their current and future work.

---

## What is Multi-Tenancy?

Multi-tenancy means that multiple independent organizations can use the same Melomania application without seeing each other's data. Each organization has its own isolated space - contacts, projects, callsheets, files and all other data belong to one organization only.

Melomania uses the **shared schema with organization_id** approach: all organizations share the same database tables, but every tenant-specific table has an `organization_id` column that links each row to its organization.

---

## The Organizations Table

A new `organizations` table has been added with the following structure:

| Column | Type | Description |
|--------|------|-------------|
| id | integer | Primary key |
| name | string (unique) | Organization name |
| created_at | timestamp | Creation date |
| updated_at | timestamp | Last update date |

---

## Tables with organization_id

The following tables now have an `organization_id` foreign key column:

- `users`
- `contacts`
- `projects`
- `lists`
- `mail_templates`
- `files`
- `folders`
- `section_groups`
- `pieces`
- `forms`
- `outgoing_mails`
- `accounting_categories`
- `accounting_settings`
- `accounting_entries`
- `recruitment_settings`

**Tables that do NOT have organization_id (shared globally):**
- `composers` - shared reference data across all organizations
- `instruments` - shared reference data
- `type_of_pieces` - shared reference data
- `callsheets`, `participants`, `concerts`, `rehearsals`, `recruitment_contacts` - these inherit tenant isolation through their parent `project`, which already has `organization_id`

---

## How Organization Scoping Works

All controllers that touch tenant-specific tables now filter queries by `organization_id`. Here is the pattern used throughout the codebase:

```typescript
async getAll(ctx: HttpContext) {
  const organizationId = ctx.auth.user?.organizationId

  const results = await MyModel.query()
    .if(organizationId, (query) => query.where('organization_id', organizationId!))
    // ... rest of query
}
```

The `.if()` method only applies the `.where()` clause if `organizationId` is not null. This ensures that users without an organization (during migration) can still access data.

### Creating Records

When creating a new record, always pass `organizationId`:

```typescript
async create(ctx: HttpContext) {
  const organizationId = ctx.auth.user?.organizationId

  const record = await MyModel.create({
    ...data,
    organizationId,
  })
}
```

### Updating and Deleting Records

Always scope find queries by organization to prevent IDOR vulnerabilities:

```typescript
async delete({ params, auth }: HttpContext) {
  const organizationId = auth.user?.organizationId

  const record = await MyModel.query()
    .where('id', params.id)
    .if(organizationId, (query) => query.where('organization_id', organizationId!))
    .firstOrFail()

  await record.delete()
}
```

**Never do this:**
```typescript
// WRONG - Anyone can delete any record!
const record = await MyModel.findOrFail(params.id)
await record.delete()
```

---

## Important Security Note - Bulk Operations

Model hooks (`beforeFind`, `beforeFetch`) do NOT apply to bulk update and delete operations such as:

```typescript
// These bypass any automatic organization filtering!
await MyModel.query().where('status', 'active').update({ status: 'inactive' })
await MyModel.query().where('project_id', id).delete()
```

For any bulk operation, you MUST manually add the organization scope:

```typescript
// Correct
await MyModel.query()
  .where('status', 'active')
  .if(organizationId, (query) => query.where('organization_id', organizationId!))
  .update({ status: 'inactive' })
```

---

## The Organization Middleware

An `OrganizationMiddleware` has been added and applied to all authenticated routes. It verifies that the authenticated user exists before allowing the request through. It is registered as a named middleware called `organization` in `start/kernel.ts`.

---

## Models

All tenant-specific models now have the following additions:

```typescript
@column()
declare organizationId: number | null

@belongsTo(() => Organization)
declare organization: BelongsTo<typeof Organization>
```

The `Organization` model has a `hasMany` relationship to `User`.

---

## Creating a New Organization

Only a super admin can create a new organization. The endpoint is:

```
POST /organization/create
```

Request body:
```json
{
  "name": "My Orchestra",
  "admin_email": "admin@myorchestra.com",
  "admin_password": "securepassword",
  "admin_full_name": "John Doe"
}
```

This creates the organization and its first admin user in one request.

---

## Existing Data Migration

All existing data has been assigned to a default organization called **Melomania** via the organization seeder. To run the seeder on a new environment:

```bash
node ace db:seed --files database/seeders/organization_seeder.ts
```

This will:
1. Create the Melomania organization if it doesn't exist
2. Assign all existing users to it
3. Assign all existing data in tenant-specific tables to it

---

## What You Need to Do

If you are working on a feature that touches any of the tenant-specific tables listed above, make sure to:

1. **Scope all queries** with `.if(organizationId, (query) => query.where('organization_id', organizationId!))` in your controller
2. **Pass `organizationId`** when creating new records
3. **Scope find queries** before updating or deleting to prevent IDOR vulnerabilities
4. **Manually scope bulk operations** since they bypass automatic filtering
5. **Do not add `organization_id`** to tables that inherit tenant isolation through a parent (e.g. `callsheets` through `projects`)

If you are unsure whether your table needs `organization_id`, check the list above or ask.

---

## References

- Security audit: coordinated with Brice Sandjong and Line Tchependa
- GitHub issue: #103
- Related PR: naomi/multi-tenant-architecture