# resource-hierarchy

Creates the GCP resource hierarchy - folders, projects, and per-project API
enablement. This module builds structure only; it does **not** manage IAM
(access is owned by the separate IAM module) and it does **not** create the
organization (the organization comes from Cloud Identity on the domain and is
passed in as the parent).

## What it creates

- Folders (`google_folder`), keyed by a descriptive name.
- Projects (`google_project`), keyed by a descriptive name, each attached to a
  billing account and placed under a folder or the organization.
- Per-project API enablement (`google_project_service`), declared inline.

Services are declared *inside* each project object and flattened in `locals.tf`
so every resource uses one `for_each` with no nested loops.

## Design notes

- **One `for_each` per resource**, no loops inside loops. Nested inputs are
  flattened once in `locals.tf`.
- **`optional()` with sensible defaults** - callers set only what they need.
  `auto_create_network` defaults to `false` (no default network).
- **Descriptive resource names**, never `this`.
- **Validation** catches bad parents and missing project parents at plan time.
- **IAM is out of scope** - organization-wide access mapping is owned by the
  IAM module, which consumes this module's folder/project ID outputs.

## Multi-level folders

A folder nests under another by setting its `parent` to the parent folder's
output ID. Because a resource cannot reference itself, build deeper trees by
chaining module calls or passing the parent folder's `id` output as the child's
`parent`.

## Usage

```hcl
module "hierarchy" {
  source = "../.."

  folders = {
    "production" = {
      display_name = "Production"
      parent       = "organizations/123456789012"
    }
  }

  projects = {
    "app-prod" = {
      project_id      = "app-prod-001"
      billing_account = "XXXXXX-XXXXXX-XXXXXX"
      folder_key      = "production"
      labels          = { env = "prod", team = "app" }
      services        = ["compute.googleapis.com", "storage.googleapis.com"]
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| folders | Map of folders to create, keyed by name. | `map(object)` | `{}` | no |
| projects | Map of projects to create, keyed by name; each may carry inline `services`. | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| folder_ids | Map of folder name to resource name ("folders/1234"). |
| folder_numeric_ids | Map of folder name to numeric folder ID. |
| project_ids | Map of project name to project ID. |
| project_numbers | Map of project name to project number. |
