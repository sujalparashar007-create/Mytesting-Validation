# Basic example: two top-level folders, one project in each, with APIs enabled.

module "hierarchy" {
  source = "../.."

  folders = {
    "production" = {
      display_name = "Production"
      parent       = var.org_id
    }

    "non-production" = {
      display_name = "Non-Production"
      parent       = var.org_id
    }
  }

  projects = {
    "app-prod" = {
      project_id      = "app-prod-0001"
      billing_account = var.billing_account
      folder_key      = "production"
      labels          = {
        env  = "prod"
        team = "app"
      }
      services = [
        "compute.googleapis.com",
        "storage.googleapis.com"
      ]
    }

    "app-dev" = {
      project_id      = "app-dev-0002"
      billing_account = var.billing_account
      folder_key      = "non-production"
      labels          = {
        env  = "dev"
        team = "app"
      }
      services = [
        "compute.googleapis.com"
      ]
    }
  }
}