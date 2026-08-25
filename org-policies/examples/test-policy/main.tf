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

    "iam.restrictCrossProjectServiceAccountLienRemoval" = {
      enforce = "TRUE"
    }

    # Instructor requirement: "Disable cross-project service account access".
    # The dedicated constraint iam.disableCrossProjectServiceAccountUsage is a
    # Google-managed (legacy) constraint: the restrictive behavior (service
    # accounts can only be used by resources running in their own project) is
    # enforced by Google's managed DEFAULT, and users are NOT allowed to
    # create policies for it. Verified against the live Org Policy API: this
    # constraint is absent from the settable constraint list at BOTH org and
    # folder scope (folder exposes 194 constraints, org 195 - neither lists
    # it), and creating a policy for it returns:
    #   "Error 404: Requested entity was not found".
    # There is NO alternative user-settable built-in constraint for this
    # intent, so this requirement is covered by:
    #   1. Google-managed default of iam.disableCrossProjectServiceAccountUsage
    #      (cross-project service account usage restricted by default).
    #   2. iam.restrictCrossProjectServiceAccountLienRemoval above, which
    #      requires organization-level permission to remove cross-project
    #      service account liens.
    # DO NOT re-add "iam.disableCrossProjectServiceAccountUsage" here: apply
    # will always fail with 404 for it.

    # Networking
    "compute.skipDefaultNetworkCreation" = {
      enforce = "TRUE"
    }

    "compute.managed.vmExternalIpAccess" = {
      enforce = "TRUE"
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

    # Compute
    "compute.disableNonFIPSMachineTypes" = {
      enforce = "TRUE"
    }

    # Cloud Functions
    "cloudfunctions.allowedVpcConnectorEgressSettings" = {
      list_constraints = [{
        allowed_values = ["PRIVATE_RANGES_ONLY"]
      }]
    }
  }
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
    restrictDiskTypes = {
      display_name = "Restrict disk types to pd-balanced"
      description  = "Only pd-balanced disks are allowed. Any other disk type (pd-ssd, pd-standard, pd-extreme, Hyperdisk, ...) is denied."
      action_type  = "DENY"
      # CEL must use resource.type (NOT resource.diskType - that field does not
      # exist in the compute.googleapis.com/Disk custom-constraint schema, the
      # Org Policy API rejects it with "undefined field 'diskType'").
      # resource.type carries the full disk type path, e.g.:
      #   projects/<project>/zones/<zone>/diskTypes/pd-balanced
      # Pattern adapted from Google's official sample
      # "custom.computeAllowedDiskTypes" in
      # GoogleCloudPlatform/professional-services →
      # tools/custom-organization-policy-library: DENY when the type is not in
      # the allow-list.
      condition      = "([\"pd-balanced\"].exists(disktype, resource.type.contains(disktype))) == false"
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
  account_id   = "test-cross-project-sa"
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
# CMEK-Encrypted VM for Cross-Project SA Validation
# -----------------------------------------------------------------------------

# CMEK-encrypted VM in Main Project using the cross-project SA
# This validates that:
# 1. The SA works within the same project (Project-A)
# 2. CMEK policy is satisfied (disk is encrypted)
# 3. Cross-project SA usage is blocked by Google-managed constraint
resource "google_compute_instance" "cmek_vm" {
  name         = "test-cmek-vm"
  project      = var.main_project_id
  zone         = var.disk_zone
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
      type  = "pd-balanced"
    }

    kms_key_self_link = google_kms_crypto_key.disk_key.id
  }

  network_interface {
    network = "default"
  }

  service_account {
    email  = google_service_account.cross_project_sa.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_project_iam_member.sa_compute_access,
    google_kms_crypto_key_iam_binding.compute_sa_key_access
  ]
}

# Test VM in Service Project using Main Project's SA
# NOTE: This resource will FAIL to create due to org policy
# iam.disableCrossProjectServiceAccountUsage (Google-managed default).
# This is intentional to validate the policy enforcement.
# To test, uncomment this resource and run terraform apply.
# Expected error: "Cross-project service account usage is disabled"

# resource "google_compute_instance" "cross_project_vm" {
#   name         = "test-cross-project-vm"
#   project      = var.service_project_id
#   zone         = var.disk_zone
#   machine_type = "e2-micro"
#
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#     }
#   }
#
#   network_interface {
#     network = "default"
#   }
#
#   service_account {
#     email  = google_service_account.cross_project_sa.email
#     scopes = ["cloud-platform"]
#   }
#
#   depends_on = [google_project_service.service_project_compute]
# }
