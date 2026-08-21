# Test Policy Apply Guide

## Outcome

Folder-level apply is successful for folder `278994416390` using `org-policies\examples\test-policy`.

## Files Changed

| File | What changed | Why |
|---|---|---|
| `C:\Users\user\Downloads\mytesting\mytesting\org-policies\main.tf` | Added `folder_targets` and `project_targets` resources with full boolean/list rule support | Existing module only created boolean `enforce = FALSE` exceptions at folder/project level, which broke list constraints |
| `C:\Users\user\Downloads\mytesting\mytesting\org-policies\locals.tf` | Added `folder_policy_targets` and `project_policy_targets` locals | To fan out org constraints to folder/project target IDs |
| `C:\Users\user\Downloads\mytesting\mytesting\org-policies\variables.tf` | Added `folder_target_ids` and `project_target_ids` | To pass explicit hierarchy targets without changing existing behavior |
| `C:\Users\user\Downloads\mytesting\mytesting\org-policies\README.md` | Added new input documentation + usage mention | Keep module docs aligned with new hierarchy support |
| `C:\Users\user\Downloads\mytesting\mytesting\org-policies\examples\test-policy\main.tf` | Switched to `folder_target_ids/project_target_ids`; replaced failing constraints with valid supported ones | To make folder-level apply work end-to-end |
| `C:\Users\user\Downloads\mytesting\mytesting\org-policies\examples\test-policy\terraform.tfvars` | Set folder ID `278994416390`, left project targets empty | Apply specifically at folder level |
| `C:\Users\user\Downloads\mytesting\mytesting\org-policies\examples\test-policy\imports.auto.tf` | Added import blocks for pre-existing org policies | Avoid `POLICY_ALREADY_EXISTS` errors during apply |

## Files Created

| File | Where created | Why created |
|---|---|---|
| `imports.auto.tf` | `C:\Users\user\Downloads\mytesting\mytesting\org-policies\examples\test-policy` | Import existing org policy resources into Terraform state |
| `terraform.tfvars` | `C:\Users\user\Downloads\mytesting\mytesting\org-policies\examples\test-policy` | Provide variables non-interactively for Terraform |
| `guide.md` | `C:\Users\user\Downloads\mytesting\mytesting\org-policies\examples\test-policy` | Document execution output and validation steps |

## Applied Policy Set

- `iam.disableServiceAccountKeyCreation`
- `iam.restrictCrossProjectServiceAccountLienRemoval`
- `compute.skipDefaultNetworkCreation`
- `compute.managed.vmExternalIpAccess`
- `gcp.restrictServiceUsage`
- `storage.uniformBucketLevelAccess`
- `gcp.restrictNonCmekServices`
- `compute.disableNonFIPSMachineTypes`
- `cloudfunctions.allowedVpcConnectorEgressSettings`

## Manual Validation in GCP Console

1. Open **Google Cloud Console** and ensure organization is `563019909339`.
2. Go to **IAM & Admin → Organization Policies**.
3. Search and open each policy listed in **Applied Policy Set**.
4. Verify for each:
   - Organization-level policy exists on `organizations/563019909339`.
   - Folder-level policy exists on `folders/278994416390`.
5. Go to **Resource Manager → Folders → `test-folder` (`278994416390`) → Organization Policies** and confirm the same constraints at folder scope.
6. Validate rule data:
   - Boolean constraints show expected enforce state.
   - List constraints show expected allowed/denied values from `main.tf`.
