**# Advanced example**

Calls `resource-hierarchy` to create a two-level folder hierarchy (departments -> environment folders), create projects inside the environment folders, and enable selected APIs for those projects.

**## Usage**

```bash
terraform init

terraform plan \
  -var="org_id=<your-organization-id>" \
  -var="billing_account=<your-billing-account-id>"

terraform apply \
  -var="org_id=<your-organization-id>" \
  -var="billing_account=<your-billing-account-id>"
```

**## Inputs**

| Name | Description | Type | Required |
|---|---|---|---|
| org_id | Organization ID under which the top-level department folders are created, e.g. `organizations/1234567890`. | `string` | yes |
| billing_account | Billing account ID used to link the example projects. | `string` | yes |

**## Outputs**

| Name | Description |
|---|---|
| level1_folder_ids | Map of department folder key to created folder ID. |
| env_folder_ids | Map of environment folder key to created folder ID. |
| project_ids | Map of project key to created project ID. |