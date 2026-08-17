# Basic example: two top-level folders, one project in each, with APIs enabled.
module "hierarchy" {
  source = "../.."

  folders = {
    "production" = {
      display_name = "Production"
      parent       = "organizations/123456789012"
    }
    "non-production" = {
      display_name = "Non-Production"
      parent       = "organizations/123456789012"
    }
  }

  projects = {
    "app-prod" = {
      project_id      = "app-prod-001"
      billing_account = "XXXXXX-XXXXXX-XXXXXX"
      folder_key      = "production"
      labels          = { env = "prod", team = "app" }
      services        = ["compute.googleapis.com", "storage.googleapis.com"]
    }
    "app-dev" = {
      project_id      = "app-dev-001"
      billing_account = "XXXXXX-XXXXXX-XXXXXX"
      folder_key      = "non-production"
      labels          = { env = "dev", team = "app" }
      services        = ["compute.googleapis.com"]
    }
  }
}
