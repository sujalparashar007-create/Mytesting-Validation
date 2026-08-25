# Test-policy example

Reuses the advanced example structure, but applies the requested policy set.
The `deployment_levels` variable (default `["folder"]`) controls where policies
are applied:

- Organization-level policies — when `"org"` is in `deployment_levels` (sets `create_org_policies = true`)
- Folder-level policies — when `"folder"` is in `deployment_levels` (populates `folder_target_ids`)
- Project-level policies — when `"project"` is in `deployment_levels` (populates `project_target_ids`)

## Policies included

- `iam.disableServiceAccountKeyCreation`
- `iam.restrictCrossProjectServiceAccountLienRemoval`
- `compute.skipDefaultNetworkCreation`
- `compute.managed.vmExternalIpAccess`
- `gcp.restrictServiceUsage`
- `storage.uniformBucketLevelAccess`
- `gcp.restrictNonCmekServices`
- `compute.disableNonFIPSMachineTypes`
- `cloudfunctions.allowedVpcConnectorEgressSettings`
- `custom.restrictDiskTypes` — custom constraint (CEL): only `pd-balanced` disks allowed; any other disk type is denied at folder level (the constraint *definition* is org-scoped by GCP requirement, but no org-level enforcement policy is created)

> **Note:** `iam.disableCrossProjectServiceAccountUsage` ("disable cross-project service account access") is a Google-managed (legacy) constraint — its restriction is enforced by Google's *default* behavior and it cannot be set by users (Org Policy API returns `404: Requested entity was not found`; it is absent from the settable constraint list at both org and folder scope). This requirement is therefore covered by that managed default plus `iam.restrictCrossProjectServiceAccountLienRemoval` above. Details in `main.tf`.

## Usage

`org_id`, `project_level_policy_target_ids`, and `folder_level_policy_target_ids`
are provided in `terraform.tfvars`. `deployment_levels` defaults to `["folder"]`
(override with `-var="deployment_levels=[\"org\",\"folder\",\"project\"]` to target
all levels).

```bash
export USER_PROJECT_OVERRIDE=true
export GOOGLE_BILLING_PROJECT=<your-quota-project-id>

terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| org_id | The numeric ID of the GCP organization. | `string` | — | yes |
| deployment_levels | Where to apply policies. Allowed values: org, folder, project. | `list(string)` | `["folder"]` | no |
| project_level_policy_target_ids | Project IDs where project-level policy resources should be created. | `list(string)` | `[]` | no |
| folder_level_policy_target_ids | Folder IDs where folder-level policy resources should be created. | `list(string)` | `[]` | no |
| billing_project | Project ID used for billing and quota when the Google provider calls org/folder-level APIs. | `string` | `test-project-506110` | no |
| project_id | The GCP project ID where KMS and disk resources will be created. | `string` | `test-project-506110` | no |
| kms_keyring_name | Name of the KMS key ring. | `string` | `my-keyring` | no |
| kms_key_name | Name of the KMS crypto key. | `string` | `my-disk-key` | no |
| kms_location | Location for the KMS key ring. | `string` | `us-central1` | no |
| disk_name | Name of the CMEK-encrypted disk. | `string` | `test-ok-cmek` | no |
| disk_zone | Zone for the CMEK-encrypted disk. | `string` | `us-central1-a` | no |
| disk_size_gb | Size of the disk in GB. | `number` | `10` | no |
| disk_type | Type of the disk (e.g., pd-balanced, pd-ssd). | `string` | `pd-balanced` | no |
| main_project_id | The main GCP project ID (Project-A). | `string` | `test-project-506110` | no |
| service_project_id | The service GCP project ID (Project-B) for cross-project SA testing. | `string` | `test-service-project-00` | no |
| enable_service_project_resources | Whether to enable Compute API in the service project. | `bool` | `false` | no |

## Outputs

| Name | Description |
|---|---|
| org_policy_ids | Map of constraint name to the applied org-level policy resource ID. |
| kms_key_id | The ID of the KMS crypto key used for disk encryption. |
| disk_self_link | The self_link of the CMEK-encrypted disk. |
| cross_project_sa_email | The email of the cross-project service account. |
| main_project_id | The main project ID (Project-A). |
| service_project_id | The service project ID (Project-B). |
| cmek_vm_name | The name of the CMEK-encrypted VM. |
| cmek_vm_self_link | The self_link of the CMEK-encrypted VM. |

---

## Resources Created

### Org Policies (10 policies at folder level)
| # | Policy | Constraint | Type |
|---|--------|------------|------|
| 1 | Disable Service Account Key Creation | `iam.disableServiceAccountKeyCreation` | Built-in |
| 2 | Disable Cross-Project SA Usage | `iam.disableCrossProjectServiceAccountUsage` | Google-managed (enforced by default) |
| 3 | Disable Default Network | `compute.skipDefaultNetworkCreation` | Built-in |
| 4 | Restrict VM External IPs | `compute.managed.vmExternalIpAccess` | Built-in |
| 5 | Restrict Service Usage | `gcp.restrictServiceUsage` | Built-in |
| 6 | Uniform Bucket-Level Access | `storage.uniformBucketLevelAccess` | Built-in |
| 7 | Require CMEK | `gcp.restrictNonCmekServices` | Built-in |
| 8 | Restrict VM Machine Types | `compute.disableNonFIPSMachineTypes` | Built-in |
| 9 | Restrict Disk Types | `custom.restrictDiskTypes` | Custom Constraint |
| 10 | Restrict VPC Connector Egress | `cloudfunctions.allowedVpcConnectorEgressSettings` | Built-in |

### CMEK Resources
| Resource | Name | Description |
|----------|------|-------------|
| `google_project_service` | `kms_api` | Enable Cloud KMS API |
| `google_kms_key_ring` | `disk_keyring` | KMS key ring |
| `google_kms_crypto_key` | `disk_key` | KMS crypto key |
| `google_kms_crypto_key_iam_binding` | `compute_sa_key_access` | IAM binding for Compute SA |
| `google_compute_disk` | `cmek_disk` | CMEK-encrypted disk |

### Cross-Project SA Validation Resources
| Resource | Name | Description |
|----------|------|-------------|
| `google_project_service` | `main_project_iam` | Enable IAM API in Main Project |
| `google_project_service` | `main_project_compute` | Enable Compute API in Main Project |
| `google_service_account` | `cross_project_sa` | Service account in Main Project |
| `google_project_iam_member` | `sa_compute_access` | IAM binding for SA |
| `google_project_service` | `service_project_compute` | Enable Compute API in Service Project (conditional) |
| `google_compute_instance` | `cmek_vm` | CMEK-encrypted VM using cross-project SA |

---

## Cross-Project Service Account Validation

### Policy: `iam.disableCrossProjectServiceAccountUsage`

This policy is enforced by **Google's managed default** — it cannot be set by users. Service accounts cannot be used with resources in other GCP projects.

### Terraform Resources Added

| Resource | Name | Description |
|----------|------|-------------|
| `google_service_account` | `cross_project_sa` | Service account in Main Project (`test-project-506110`) |
| `google_project_iam_member` | `sa_compute_access` | IAM binding for SA in Main Project |
| `google_project_service` | `service_project_compute` | Enable Compute API in Service Project (`test-service-project-00`) |

### Validation Steps

**Step 1: Verify the service account was created**
```bash
gcloud iam service-accounts list --project=test-project-506110 --filter="email:test-cross-project-sa@"
```

**Step 2: Verify CMEK-encrypted VM created**
```bash
gcloud compute instances describe test-cmek-vm --zone=us-central1-a --project=test-project-506110 --format="yaml(name,serviceAccounts,diskEncryptionKey)"
```

**Step 3: Verify CMEK encryption on boot disk**
```bash
gcloud compute disks describe test-cmek-vm --zone=us-central1-a --project=test-project-506110 --format="yaml(name,diskEncryptionKey,kmsKeyName)"
```

**Step 4: Attempt cross-project SA usage (should fail)**
```bash
gcloud compute instances create test-cross-project-vm \
  --zone=us-central1-a \
  --service-account=test-cross-project-sa@test-project-506110.iam.gserviceaccount.com \
  --project=test-service-project-00
```
**Expected Result:** Error — cross-project service account usage is disabled by organization policy.

**Step 5: Test who can modify/disable this constraint**
```bash
gcloud org-policies describe iam.disableCrossProjectServiceAccountUsage --project=test-project-506110
```
**Expected Result:** NOT_FOUND — constraint is Google-managed and cannot be set by users.

**Step 6: Determine whether project administrators can bypass the control**
**Result:** ❌ Cannot bypass — constraint is Google-managed and enforced by default.

**Step 7: Identify required IAM/Org Policy governance control**
**Result:** Not applicable — no governance control needed because constraint cannot be disabled.

### Cleanup

```bash
# Delete CMEK-encrypted VM
gcloud compute instances delete test-cmek-vm --zone=us-central1-a --project=test-project-506110 --quiet

# Delete cross-project SA
gcloud iam service-accounts delete test-cross-project-sa@test-project-506110.iam.gserviceaccount.com --project=test-project-506110 --quiet

# Delete CMEK disk
gcloud compute disks delete test-ok-cmek --zone=us-central1-a --project=test-project-506110 --quiet

# Destroy all Terraform resources
terraform destroy -auto-approve
```
