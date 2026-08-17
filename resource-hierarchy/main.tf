resource "google_folder" "folder" {
  for_each = var.folders

  display_name = each.value.display_name
  parent       = each.value.parent
}

resource "google_project" "project" {
  for_each = var.projects

  name            = each.key
  project_id      = each.value.project_id
  billing_account = each.value.billing_account

  folder_id = each.value.folder_key != null ? trimprefix(google_folder.folder[each.value.folder_key].name, "folders/") : each.value.folder_id
  org_id    = (each.value.folder_key != null || each.value.folder_id != null) ? null : each.value.org_id

  labels              = each.value.labels
  auto_create_network = each.value.auto_create_network
}

resource "google_project_service" "service" {
  for_each = local.project_services

  project = google_project.project[each.value.project_key].project_id
  service = each.value.service

  disable_on_destroy = false
}
