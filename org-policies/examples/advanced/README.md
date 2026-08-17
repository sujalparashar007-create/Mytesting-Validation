# Advanced example

One constraint per pattern, so each can be read in isolation:

| Pattern | Constraint used | How |
|---|---|---|
| Project exception | `compute.disableSerialPortAccess` | `excluded_project_ids = [var.exception_project_id]` - enforced org-wide, `enforce = "FALSE"` on that one project. |
| Folder exception | `compute.requireOsLogin` | `excluded_folder_ids = [var.exception_folder_id]` - same idea, every project under that folder inherits the exception. |
| Disabling a policy | `compute.skipDefaultNetworkCreation` | `enforce = "FALSE"` set directly, org-wide - an explicit "don't enforce this" decision recorded in code, not just an omitted constraint. |
| Passing an allow-list of values | `compute.trustedImageProjects` | `list_constraints = [{ allowed_values = [...] }]`. |
| Passing a deny-list of values | `storage.restrictAuthTypes` | `list_constraints = [{ denied_values = [...] }]`. |

See `../../README.md` for the full explanation of the `enforce` tri-state
(`"TRUE"` / `"FALSE"` / unset) and why exceptions are modeled this way.

## Usage

```bash
export USER_PROJECT_OVERRIDE=true
export GOOGLE_BILLING_PROJECT=<your-quota-project-id>

terraform init
terraform plan \
  -var="org_id=<your-org-id>" \
  -var="exception_project_id=<a-real-project-id>" \
  -var="exception_folder_id=<a-real-folder-id>"
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| org_id | The numeric ID of the GCP organization. | `string` | yes |
| exception_project_id | Project ID exempted from `compute.disableSerialPortAccess`. | `string` | yes |
| exception_folder_id | Folder ID exempted from `compute.requireOsLogin`. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| org_policy_ids | Map of constraint name to the applied org-level policy resource ID. |
