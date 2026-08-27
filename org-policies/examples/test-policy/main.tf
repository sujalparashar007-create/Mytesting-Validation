# Test policy example:
# - Reuses advanced example structure
# - Replaces policies with the requested baseline set
# - Can target org/folder/project hierarchy in one run
locals {
  policy_set = {
    # Identity & Access
    "iam.disableServiceAccountKeyCreation" = {
      enforce = "TRUE"
    }

    # Networking
    "compute.skipDefaultNetworkCreation" = {
      enforce = "TRUE"
    }

    "compute.vmExternalIpAccess" = {
      # List constraint: deny all external IPv4 access for VMs.
      deny_all = true
    }

    # APIs
    "gcp.restrictServiceUsage" = {
      list_constraints = [{
        denied_values = [
          "is:translate.googleapis.com",
          "is:vision.googleapis.com",
          "is:genomics.googleapis.com",
        ]
      }]
    }

    # Data Protection
    "storage.uniformBucketLevelAccess" = {
      enforce = "TRUE"
    }

    # Encryption
    "gcp.restrictNonCmekServices" = {
      list_constraints = [{
        denied_values = [
          "compute.googleapis.com",
          "storage.googleapis.com",
        ]
      }]
    }

    # Cloud Functions
    "cloudfunctions.allowedVpcConnectorEgressSettings" = {
      list_constraints = [{
        allowed_values = ["PRIVATE_RANGES_ONLY"]
      }]
    }
  }

  # CEL condition for the custom VM machine-type constraint.
  # DENY when the machine type is NOT in the approved list.
  vm_machine_type_condition = "([\"${join("\", \"", var.allowed_vm_machine_types)}\"].exists(type, resource.machineType.contains(type))) == false"

  # CEL condition for the custom disk-type constraint.
  # DENY when the disk type does NOT contain "pd-balanced".
  disk_type_condition = "([\"pd-balanced\"].exists(disktype, resource.type.contains(disktype))) == false"
}

module "org_policies" {
  source = "../.."

  org_id = var.org_id

  create_org_policies = contains(var.deployment_levels, "org")
  folder_target_ids   = contains(var.deployment_levels, "folder") ? var.folder_level_policy_target_ids : []
  project_target_ids  = contains(var.deployment_levels, "project") ? var.project_level_policy_target_ids : []

  org_constraints = local.policy_set

  # 10th instructor requirement: "Restrict disk types" (allow only pd-balanced).
  # No built-in GCP org policy constraint exists for disk types (verified),
  # so this is implemented as a CUSTOM constraint using CEL.
  #
  # GCP rule: the constraint DEFINITION (custom.restrictDiskTypes) must live
  # at ORGANIZATION scope; the ENFORCEMENT policy is FOLDER-level only
  # (folder_target_ids), because org-level policies are disabled here
  # (create_org_policies = false).
  custom_constraint_policies = {
    restrictVmMachineType = {
      display_name = "Restrict VM machine types"
      description  = "Only approved VM machine types are allowed. Any non-approved machine type is denied."
      action_type  = "DENY"
      # resource.machineType carries the full machine type path, e.g.:
      #   projects/<project>/zones/<zone>/machineTypes/n1-standard-1
      # DENY when the machine type is NOT in the approved allow-list.
      condition      = local.vm_machine_type_condition
      method_types   = ["CREATE"]
      resource_types = ["compute.googleapis.com/Instance"]
      enforce        = "TRUE"
    }

    restrictDiskTypes = {
      display_name = "Restrict disk types to pd-balanced"
      description  = "Only pd-balanced disks are allowed. Any other disk type (pd-ssd, pd-standard, pd-extreme, Hyperdisk, ...) is denied."
      action_type  = "DENY"
      # resource.type carries the full disk type path, e.g.:
      #   projects/<project>/zones/<zone>/diskTypes/pd-balanced
      condition      = local.disk_type_condition
      method_types   = ["CREATE"]
      resource_types = ["compute.googleapis.com/Disk"]
      enforce        = "TRUE"
    }
  }
}

# -----------------------------------------------------------------------------
# Enable Required APIs
# -----------------------------------------------------------------------------

# Enable IAM API in Main Project (required for service account creation)
resource "google_project_service" "main_project_iam" {
  project            = var.main_project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

# Enable Compute API in Main Project (required for IAM binding)
resource "google_project_service" "main_project_compute" {
  project            = var.main_project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# -----------------------------------------------------------------------------
# Custom VPC/Subnet for Positive VM Test
# -----------------------------------------------------------------------------

# Custom VPC. Required because compute.skipDefaultNetworkCreation prevents
# the default VPC from being created, and the positive-test VM needs a network.
resource "google_compute_network" "test_vpc" {
  name                    = var.network_name
  project                 = var.main_project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  depends_on = [google_project_service.main_project_compute]
}

# Custom subnet for the positive-test VM.
resource "google_compute_subnetwork" "test_subnet" {
  name          = var.subnetwork_name
  project       = var.main_project_id
  region        = var.subnetwork_region
  network       = google_compute_network.test_vpc.id
  ip_cidr_range = var.subnetwork_cidr

  depends_on = [google_compute_network.test_vpc]
}

# -----------------------------------------------------------------------------
# CMEK Resources for Disk Encryption
# -----------------------------------------------------------------------------

# Get project number for Compute Engine service agent
data "google_project" "project" {
  project_id = var.project_id
}

# KMS Key Ring
resource "google_kms_key_ring" "disk_keyring" {
  name     = var.kms_keyring_name
  location = var.kms_location
  project  = var.project_id

  depends_on = [google_project_service.kms_api]
}

# KMS Crypto Key
resource "google_kms_crypto_key" "disk_key" {
  name            = var.kms_key_name
  key_ring        = google_kms_key_ring.disk_keyring.id
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = "7776000s" # 90 days
}

# Grant Compute Engine service agent access to the KMS key
resource "google_kms_crypto_key_iam_binding" "compute_sa_key_access" {
  crypto_key_id = google_kms_crypto_key.disk_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
  ]
}

# CMEK-encrypted disk
resource "google_compute_disk" "cmek_disk" {
  name    = var.disk_name
  project = var.project_id
  zone    = var.disk_zone
  size    = var.disk_size_gb
  type    = var.disk_type

  disk_encryption_key {
    kms_key_self_link = google_kms_crypto_key.disk_key.id
  }

  depends_on = [google_kms_crypto_key_iam_binding.compute_sa_key_access]
}

# -----------------------------------------------------------------------------
# Cross-Project Service Account Validation Resources
# -----------------------------------------------------------------------------

# Service Account in Main Project (Project-A)
resource "google_service_account" "cross_project_sa" {
  account_id   = var.sa_account_id
  display_name = "Test Cross-Project Service Account"
  project      = var.main_project_id

  depends_on = [google_project_service.main_project_iam]
}

# Grant Compute Instance Admin role to the SA in Main Project
resource "google_project_iam_member" "sa_compute_access" {
  project = var.main_project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.cross_project_sa.email}"
}

# Enable Compute API in Service Project
# NOTE: Set enable_service_project_resources = true in terraform.tfvars
# only if billing is enabled on the service project.
resource "google_project_service" "service_project_compute" {
  count              = var.enable_service_project_resources ? 1 : 0
  project            = var.service_project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# -----------------------------------------------------------------------------
# CMEK-Encrypted Positive-Test VM
# -----------------------------------------------------------------------------

# Compliant VM in Main Project.
# Validates:
#   1. custom.restrictVmMachineType (approved machine type)
#   2. gcp.restrictNonCmekServices (boot disk is CMEK-encrypted)
#   3. custom.restrictDiskTypes (boot disk is pd-balanced)
#   4. compute.vmExternalIpAccess (no external IP)
#   5. compute.skipDefaultNetworkCreation (uses custom VPC, not default)
resource "google_compute_instance" "cmek_vm" {
  name                      = var.vm_name
  project                   = var.main_project_id
  zone                      = var.disk_zone
  machine_type              = var.vm_machine_type
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = 10
      type  = "pd-balanced"
    }

    kms_key_self_link = google_kms_crypto_key.disk_key.id
  }

  network_interface {
    network    = google_compute_network.test_vpc.id
    subnetwork = google_compute_subnetwork.test_subnet.id
  }

  service_account {
    email  = google_service_account.cross_project_sa.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_project_iam_member.sa_compute_access,
    google_kms_crypto_key_iam_binding.compute_sa_key_access,
    google_compute_subnetwork.test_subnet
  ]
}

# -----------------------------------------------------------------------------
# Commented Negative-Test Resources
# -----------------------------------------------------------------------------

# NEGATIVE TEST: Non-approved machine type.
# This resource will FAIL if uncommented because custom.restrictVmMachineType
# denies machine types that are not in var.allowed_vm_machine_types.
# To test, uncomment and run terraform apply.
# Expected error: "Policy constraints/custom.restrictVmMachineType violated"

# resource "google_compute_instance" "negative_machine_type_vm" {
#   name         = "test-non-approved-machine-type-vm"
#   project      = var.main_project_id
#   zone         = var.disk_zone
#   machine_type = "e2-micro"
#
#   boot_disk {
#     initialize_params {
#       image = var.vm_image
#       size  = 10
#       type  = "pd-balanced"
#     }
#
#     kms_key_self_link = google_kms_crypto_key.disk_key.id
#   }
#
#   network_interface {
#     network    = google_compute_network.test_vpc.id
#     subnetwork = google_compute_subnetwork.test_subnet.id
#   }
#
#   service_account {
#     email  = google_service_account.cross_project_sa.email
#     scopes = ["cloud-platform"]
#   }
#
#   depends_on = [
#     google_project_iam_member.sa_compute_access,
#     google_kms_crypto_key_iam_binding.compute_sa_key_access,
#     google_compute_subnetwork.test_subnet
#   ]
# }

# NEGATIVE TEST: Cross-project service account usage.
# This resource will FAIL if uncommented because iam.disableCrossProjectServiceAccountUsage
# is a Google-managed legacy constraint that blocks using a service account from one project
# on a resource in another project.
# To test, uncomment and run terraform apply.
# Expected error: "Cross-project service account usage is disabled"

# resource "google_compute_instance" "cross_project_vm" {
#   name         = "test-cross-project-vm"
#   project      = var.service_project_id
#   zone         = var.disk_zone
#   machine_type = var.vm_machine_type
#
#   boot_disk {
#     initialize_params {
#       image = var.vm_image
#       size  = 10
#       type  = "pd-balanced"
#     }
#
#     kms_key_self_link = google_kms_crypto_key.disk_key.id
#   }
#
#   network_interface {
#     network    = google_compute_network.test_vpc.id
#     subnetwork = google_compute_subnetwork.test_subnet.id
#   }
#
#   service_account {
#     email  = google_service_account.cross_project_sa.email
#     scopes = ["cloud-platform"]
#   }
#
#   depends_on = [
#     google_project_service.service_project_compute,
#     google_kms_crypto_key_iam_binding.compute_sa_key_access,
#     google_compute_subnetwork.test_subnet
#   ]
# }
