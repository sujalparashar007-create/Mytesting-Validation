# Demonstrates, one constraint per pattern:
#   1. a project-level exception to an org-wide boolean constraint
#   2. a folder-level exception to an org-wide boolean constraint
#   3. explicitly disabling a constraint org-wide (enforce = "FALSE")
#   4. passing an allow-list of values to a constraint
#   5. passing a deny-list of values to a constraint
module "org_policies" {
  source = "../.."

  org_id = var.org_id

  org_constraints = {
    # 1. Project exception: enforced everywhere in the org, except this one
    # project, where it's explicitly turned off.
    "compute.disableSerialPortAccess" = {
      enforce              = "TRUE"
      excluded_project_ids = [var.exception_project_id]
    }

    # 2. Folder exception: same idea, scoped to a folder instead of a
    # project -- every project under this folder inherits enforce = FALSE.
    "compute.requireOsLogin" = {
      enforce             = "TRUE"
      excluded_folder_ids = [var.exception_folder_id]
    }

    # 3. Disabling a policy: set enforce = "FALSE" org-wide. This is
    # different from just omitting the constraint -- it's an explicit
    # decision, recorded in code, to not enforce it (e.g. because a parent
    # org already enforces it and you don't want conflicting policies).
    "compute.skipDefaultNetworkCreation" = {
      enforce = "FALSE"
    }

    # 4. Passing values: an allow-list constraint. Only images from these
    # projects can be used to create VM instances.
    "compute.trustedImageProjects" = {
      list_constraints = [{
        allowed_values = [
          "is:projects/debian-cloud",
          "is:projects/ubuntu-os-cloud",
        ]
      }]
    }

    # 5. Passing values: a deny-list constraint. HMAC-signed requests are
    # blocked as an authentication method for Cloud Storage.
    "storage.restrictAuthTypes" = {
      list_constraints = [{
        denied_values = ["in:ALL_HMAC_SIGNED_REQUESTS"]
      }]
    }
  }
}
