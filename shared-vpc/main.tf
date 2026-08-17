resource "google_compute_shared_vpc_host_project" "landing_zone_host_project" {
  project = var.host_project_id
}

resource "google_compute_shared_vpc_service_project" "landing_zone_service_project" {
  for_each = var.service_project_ids

  host_project    = google_compute_shared_vpc_host_project.landing_zone_host_project.project
  service_project = each.value
}

locals {
  # Flattened once here so the resource below only needs a single for_each,
  # per this repo's no-nested-loops rule.
  network_user_bindings = merge([
    for project_id, principals in var.service_project_network_users : {
      for principal in principals :
      "${project_id}/${principal}" => {
        project_id = project_id
        principal  = principal
      }
    }
  ]...)
}

resource "google_project_iam_member" "shared_vpc_network_user" {
  for_each = local.network_user_bindings

  project = each.value.project_id
  role    = "roles/compute.networkUser"
  member  = each.value.principal

  depends_on = [google_compute_shared_vpc_service_project.landing_zone_service_project]
}
