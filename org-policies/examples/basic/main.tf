# Curated hardening constraints, adapted from Google Cloud Foundation
# Fabric's FAST reference org-policy set (compute, storage, IAM, SQL, GKE).
# Edit to fit your requirements -- this is a starting point, not a mandate.
module "org_policies" {
  source = "../.."

  org_id = var.org_id

  org_constraints = {
    # -- compute --
    "compute.disableSerialPortAccess" = {
      enforce = "TRUE"
    }
    "compute.disableNestedVirtualization" = {
      enforce = "TRUE"
    }
    "compute.requireOsLogin" = {
      enforce = "TRUE"
    }
    "compute.skipDefaultNetworkCreation" = {
      enforce = "TRUE"
    }
    "compute.vmExternalIpAccess" = {
      list_constraints = [{
        denied_values = ["*"]
      }]
    }
    "compute.trustedImageProjects" = {
      list_constraints = [{
        allowed_values = [
          "is:projects/debian-cloud",
          "is:projects/ubuntu-os-cloud",
          "is:projects/cos-cloud",
        ]
      }]
    }

    # -- storage --
    "storage.uniformBucketLevelAccess" = {
      enforce = "TRUE"
    }
    "storage.publicAccessPrevention" = {
      enforce = "TRUE"
    }

    # -- iam --
    "iam.disableAuditLoggingExemption" = {
      enforce = "TRUE"
    }

    # -- sql --
    "sql.restrictPublicIp" = {
      enforce = "TRUE"
    }

    # -- gke --
    "container.managed.enablePrivateNodes" = {
      enforce = "TRUE"
    }
  }
}
