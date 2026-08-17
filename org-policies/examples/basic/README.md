# Basic example

Applies a curated set of hardening constraints (compute, storage, IAM, SQL,
GKE), adapted from Google Cloud Foundation Fabric's FAST reference org-policy
set, to a real GCP organization.

## Usage

```bash
export USER_PROJECT_OVERRIDE=true
export GOOGLE_BILLING_PROJECT=<your-quota-project-id>

terraform init
terraform plan -var="org_id=<your-org-id>"
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| org_id | The numeric ID of the GCP organization. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| org_policy_ids | Map of constraint name to the applied org-level policy resource ID. |
