module "shared_vpc" {
  source = "../.."

  host_project_id     = var.host_project_id
  service_project_ids = [var.service_project_id]

  service_project_network_users = {
    (var.service_project_id) = ["group:app-admins@example.com"]
  }
}
