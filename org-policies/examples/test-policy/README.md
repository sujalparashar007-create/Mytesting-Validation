# Test-policy example

Reusable GCP Organization Policy validation module. Applies a focused set of
security/FinOps/data-protection policies at org, folder, or project scope and
creates a small set of positive-test GCP resources to demonstrate that the
policies can be satisfied.

The `deployment_levels` variable (default `["folder"]`) controls where policies
are applied:

- Organization-level policies — when `"org"` is in `deployment_levels` (sets `create_org_policies = true`)
- Folder-level policies — when `"folder"` is in `deployment_levels` (populates `folder_target_ids`)
- Project-level policies — when `"project"` is in `deployment_levels` (populates `project_target_ids`)

## Policies validated

| # | Policy / Constraint | Type | Hierarchy | Terraform-managed |
|---|---------------------|------|-----------|-------------------|
| 1 | `iam.disableServiceAccountKeyCreation` | Built-in | Folder | Yes |
| 2 | `gcp.restrictServiceUsage` | Built-in | Folder | Yes |
| 3 | `compute.skipDefaultNetworkCreation` | Built-in | Folder | Yes |
| 4 | `compute.vmExternalIpAccess` | Built-in | Folder | Yes |
| 5 | `storage.uniformBucketLevelAccess` | Built-in | Folder | Yes |
| 6 | `gcp.restrictNonCmekServices` | Built-in | Folder | Yes |
| 7 | `custom.restrictVmMachineType` | Custom | Org definition, folder enforcement | Yes |
| 8 | `custom.restrictDiskTypes` | Custom | Org definition, folder enforcement | Yes |
| 9 | `cloudfunctions.allowedVpcConnectorEgressSettings` | Built-in | Folder | Yes |
| 10 | `iam.disableCrossProjectServiceAccountUsage` | Google-managed legacy | Project (default) | No — manual validation |

### Note on policy #10

`iam.disableCrossProjectServiceAccountUsage` is a **Google-managed (legacy)**
constraint. It is enforced at the project level by Google's default behavior and
is **not present in the settable constraint list at org or folder scope**
(attempting to create a policy for it returns `404: Requested entity was not
found`). This module documents and validates it manually using the cross-project
service-account test, rather than creating a Terraform-managed folder policy.

## Usage

```bash
export USER_PROJECT_OVERRIDE=true
export GOOGLE_BILLING_PROJECT=<your-quota-project-id>

terraform init
terraform plan
terraform apply
```

Do not use `terraform apply -auto-approve` unless explicitly requested.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `org_id` | The numeric ID of the GCP organization. | `string` | — | yes |
| `deployment_levels` | Where to apply policies. Allowed values: `org`, `folder`, `project`. | `list(string)` | `["folder"]` | no |
| `project_level_policy_target_ids` | Project IDs where project-level policy resources should be created. | `list(string)` | `[]` | no |
| `folder_level_policy_target_ids` | Folder IDs where folder-level policy resources should be created. | `list(string)` | `[]` | no |
| `billing_project` | Project ID used for billing/quota when the Google provider calls org/folder-level APIs. | `string` | `test-project-506110` | no |
| `project_id` | The GCP project ID where KMS and disk resources will be created. | `string` | `test-project-506110` | no |
| `kms_keyring_name` | Name of the KMS key ring. | `string` | `my-keyring` | no |
| `kms_key_name` | Name of the KMS crypto key. | `string` | `my-disk-key` | no |
| `kms_location` | Location for the KMS key ring. | `string` | `us-central1` | no |
| `disk_name` | Name of the CMEK-encrypted disk. | `string` | `test-ok-cmek` | no |
| `disk_zone` | Zone for the CMEK-encrypted disk and positive-test VM. | `string` | `us-central1-a` | no |
| `disk_size_gb` | Size of the disk in GB. | `number` | `10` | no |
| `disk_type` | Type of the disk. Must be `pd-balanced`. | `string` | `pd-balanced` | no |
| `main_project_id` | The main GCP project ID (Project-A). | `string` | `test-project-506110` | no |
| `service_project_id` | The service GCP project ID (Project-B) for cross-project SA testing. | `string` | `test-service-project-00` | no |
| `enable_service_project_resources` | Whether to enable Compute API in the service project. | `bool` | `false` | no |
| `vm_name` | Name of the compliant positive-test VM. | `string` | `test-cmek-vm` | no |
| `vm_machine_type` | Machine type for the positive-test VM. Must be in `allowed_vm_machine_types`. | `string` | `n1-standard-1` | no |
| `vm_image` | Boot disk image for the positive-test VM. | `string` | `debian-cloud/debian-11` | no |
| `allowed_vm_machine_types` | Approved VM machine types enforced by `custom.restrictVmMachineType`. | `list(string)` | `["n1-standard-1"]` | no |
| `network_name` | Name of the custom VPC. | `string` | `test-policy-vpc` | no |
| `subnetwork_name` | Name of the custom subnet. | `string` | `test-policy-subnet` | no |
| `subnetwork_cidr` | CIDR range for the custom subnet. | `string` | `10.0.0.0/24` | no |
| `subnetwork_region` | Region for the custom subnet. | `string` | `us-central1` | no |
| `sa_account_id` | Account ID for the cross-project test service account. | `string` | `test-cross-project-sa` | no |

## Outputs

| Name | Description |
|---|---|
| `org_policy_ids` | Map of constraint name to applied org-level policy resource ID. |
| `custom_constraint_names` | Map of custom constraint key to full constraint name (`custom.<key>`). |
| `folder_custom_constraint_policy_ids` | Map of custom constraint policy IDs at folder level. |
| `kms_key_id` | The ID of the KMS crypto key used for disk encryption. |
| `disk_self_link` | The self-link of the CMEK-encrypted disk. |
| `cross_project_sa_email` | The email of the cross-project test service account. |
| `main_project_id` | The main project ID (Project-A). |
| `service_project_id` | The service project ID (Project-B). |
| `test_vpc_id` | The ID of the custom VPC. |
| `test_subnet_id` | The ID of the custom subnet. |
| `cmek_vm_name` | The name of the CMEK-encrypted positive-test VM. |
| `cmek_vm_self_link` | The self-link of the CMEK-encrypted positive-test VM. |
| `cmek_vm_machine_type` | The machine type of the CMEK-encrypted positive-test VM. |

## Resources created

### Policy Resources (via parent module)

| Resource | Description |
|---|---|
| `google_org_policy_policy` | 9 Terraform-managed folder-level built-in policies. |
| `google_org_policy_custom_constraint` | `custom.restrictVmMachineType`, `custom.restrictDiskTypes` definitions at org scope. |
| `google_org_policy_policy` | Folder-level enforcement policies for the two custom constraints. |

### Positive-Test Infrastructure

| Resource | Name | Description |
|---|---|---|
| `google_project_service` | `main_project_iam` | Enable IAM API in main project. |
| `google_project_service` | `main_project_compute` | Enable Compute API in main project. |
| `google_project_service` | `kms_api` | Enable Cloud KMS API. |
| `google_compute_network` | `test_vpc` | Custom VPC for positive-test VM. |
| `google_compute_subnetwork` | `test_subnet` | Custom subnet for positive-test VM. |
| `google_kms_key_ring` | `disk_keyring` | KMS key ring. |
| `google_kms_crypto_key` | `disk_key` | KMS crypto key for CMEK. |
| `google_kms_crypto_key_iam_binding` | `compute_sa_key_access` | Allow Compute SA to use KMS key. |
| `google_compute_disk` | `cmek_disk` | Standalone CMEK `pd-balanced` disk. |
| `google_service_account` | `cross_project_sa` | Test service account in main project. |
| `google_project_iam_member` | `sa_compute_access` | Grant Compute Instance Admin to SA. |
| `google_compute_instance` | `cmek_vm` | Compliant positive-test VM. |

### Commented Negative-Test Resources

These resources are intentionally commented out in `main.tf`. Uncomment them to
demonstrate policy rejection.

| Resource | Name | Demonstrates |
|---|---|---|
| `google_compute_instance` | `negative_machine_type_vm` | `custom.restrictVmMachineType` rejects non-approved machine types. |
| `google_compute_instance` | `cross_project_vm` | `iam.disableCrossProjectServiceAccountUsage` rejects cross-project SA usage. |

## Manual Policy Validation

### 1. `iam.disableServiceAccountKeyCreation`

```bash
gcloud iam service-accounts keys create /tmp/test-key.json \
  --iam-account=$(terraform output -raw cross_project_sa_email) \
  --project=$(terraform output -raw main_project_id)
```

**Expected:** `Key creation is disabled by organization policy.`

### 2. `gcp.restrictServiceUsage`

```bash
gcloud services enable translate.googleapis.com \
  --project=$(terraform output -raw main_project_id)
```

**Expected:** Policy violation for `constraints/gcp.restrictServiceUsage`.

### 3. `compute.skipDefaultNetworkCreation`

Create a new project under the target folder and enable Compute API; verify no
default VPC is created.

**Positive:** Verify the custom VPC exists.

```bash
gcloud compute networks describe test-policy-vpc \
  --project=$(terraform output -raw main_project_id)
```

### 4. `compute.vmExternalIpAccess`

```bash
gcloud compute instances create test-external-ip-vm \
  --zone=us-central1-a --machine-type=n1-standard-1 \
  --subnet=test-policy-subnet --external-ip \
  --project=$(terraform output -raw main_project_id)
```

**Expected:** Policy violation for `constraints/compute.vmExternalIpAccess`.

**Positive:** Verify `cmek_vm` has no external IP.

```bash
gcloud compute instances describe test-cmek-vm \
  --zone=us-central1-a \
  --project=$(terraform output -raw main_project_id) \
  --format="value(networkInterfaces[0].accessConfigs)"
```

### 5. `storage.uniformBucketLevelAccess`

```bash
gcloud storage buckets create gs://test-ubla-bucket-$(date +%s) \
  --project=$(terraform output -raw main_project_id) \
  --no-uniform-bucket-level-access
```

**Expected:** Policy violation.

### 6. `gcp.restrictNonCmekServices`

```bash
gcloud compute disks create test-non-cmek-disk \
  --zone=us-central1-a --type=pd-balanced \
  --project=$(terraform output -raw main_project_id)
```

**Expected:** Policy violation for `constraints/gcp.restrictNonCmekServices`.

**Positive:** Verify `cmek_disk` encryption.

```bash
gcloud compute disks describe test-ok-cmek \
  --zone=us-central1-a \
  --project=$(terraform output -raw main_project_id) \
  --format="value(diskEncryptionKey.kmsKeyName)"
```

### 7. `custom.restrictVmMachineType`

**Negative:** Uncomment `negative_machine_type_vm` in `main.tf` and run
`terraform apply`.

**Expected:** `Constraint constraints/custom.restrictVmMachineType violated`.

**Positive:** Verify `cmek_vm` machine type.

```bash
gcloud compute instances describe test-cmek-vm \
  --zone=us-central1-a \
  --project=$(terraform output -raw main_project_id) \
  --format="value(machineType)"
```

### 8. `custom.restrictDiskTypes`

```bash
gcloud compute disks create test-pd-ssd-disk \
  --zone=us-central1-a --type=pd-ssd \
  --disk-encryption-key=$(terraform output -raw kms_key_id) \
  --project=$(terraform output -raw main_project_id)
```

**Expected:** `Constraint constraints/custom.restrictDiskTypes violated`.

**Positive:** Verify `cmek_disk` type.

```bash
gcloud compute disks describe test-ok-cmek \
  --zone=us-central1-a \
  --project=$(terraform output -raw main_project_id) \
  --format="value(type)"
```

### 9. `cloudfunctions.allowedVpcConnectorEgressSettings`

Deploy the sample function in `cf-source/` with a VPC connector. Set egress to
`PRIVATE_RANGES_ONLY` (positive) or `ALL_TRAFFIC` (negative).

**Expected negative:** Policy violation for
`constraints/cloudfunctions.allowedVpcConnectorEgressSettings`.

### 10. `iam.disableCrossProjectServiceAccountUsage`

```bash
gcloud compute instances create test-cross-project-vm \
  --zone=us-central1-a --machine-type=n1-standard-1 \
  --subnet=test-policy-subnet \
  --service-account=$(terraform output -raw cross_project_sa_email) \
  --project=$(terraform output -raw service_project_id)
```

**Expected:** `Cross-project service account usage is disabled` or
`Constraint constraints/iam.disableCrossProjectServiceAccountUsage violated`.

## Cleanup

```bash
terraform destroy
```
