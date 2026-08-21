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
  folder_target_ids = contains(var.deployment_levels, "folder") ? var.folder_level_policy_target_ids : []
  project_target_ids = contains(var.deployment_levels, "project") ? var.project_level_policy_target_ids : []

  org_constraints = local.policy_set
}
