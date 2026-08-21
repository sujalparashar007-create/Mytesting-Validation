# Test-policy example

Reuses the advanced example structure, but applies the requested policy set.
It supports policy resources at all three hierarchy levels:

- Organization-level policies from `org_constraints`
- Folder-level policies via `excluded_folder_ids`
- Project-level policies via `excluded_project_ids`

## Policies included

- `iam.disableServiceAccountKeyCreation`
- `iam.disableCrossProjectServiceAccountUsage`
- `compute.skipDefaultNetworkCreation`
- `compute.managed.vmExternalIpAccess`
- `serviceuser.services`
- `storage.uniformBucketLevelAccess`
- `gcp.restrictNonCmekServices`
- `compute.trustedMachineTypes`
- `compute.trustedDiskTypes`
- `cloudfunctions.allowedVpcConnectorEgressSettings`

## Usage

All required values are provided in `terraform.tfvars`.

```bash
export USER_PROJECT_OVERRIDE=true
export GOOGLE_BILLING_PROJECT=<your-quota-project-id>

terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| org_id | The numeric ID of the GCP organization. | `string` | yes |
| project_level_policy_target_ids | Project IDs where project-level policy resources should be created. | `list(string)` | yes |
| folder_level_policy_target_ids | Folder IDs where folder-level policy resources should be created. | `list(string)` | yes |

## Outputs

| Name | Description |
|---|---|
| org_policy_ids | Map of constraint name to the applied org-level policy resource ID. |
