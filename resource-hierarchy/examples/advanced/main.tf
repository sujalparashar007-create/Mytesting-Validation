# Advanced example: a two-level folder hierarchy (departments -> environment
# folders) plus projects with inline API enablement.
#
# Level-1 folders hang off the organization. Level-2 (environment) folders hang
# off a level-1 folder by referencing its output ID as their parent.

module "level1" {
  source = "../.."

  folders = {
    "department-a" = {
      display_name = "Department A"
      parent       = "organizations/${var.org_id}"
    }

    "shared-services" = {
      display_name = "Shared Services"
      parent       = "organizations/${var.org_id}"
    }
  }
}

module "hierarchy" {
  source = "../.."

  folders = {
    "dept-a-prod" = {
      display_name = "Prod"
      parent       = module.level1.folder_ids["department-a"]
    }

    "dept-a-dev" = {
      display_name = "Dev"
      parent       = module.level1.folder_ids["department-a"]
    }
  }

  projects = {
    "dept-a-app-prod" = {
      project_id      = "dept-a-app-prod-001"
      billing_account = var.billing_account
      folder_key      = "dept-a-prod"
      labels = {
        env  = "prod"
        team = "app"
      }
      services = [
        "compute.googleapis.com",
        "storage.googleapis.com"
      ]
    }

    "dept-a-app-dev" = {
      project_id      = "dept-a-app-dev-001"
      billing_account = var.billing_account
      folder_key      = "dept-a-dev"
      labels = {
        env  = "dev"
        team = "app"
      }
      services = [
        "compute.googleapis.com"
      ]
    }
  }
}