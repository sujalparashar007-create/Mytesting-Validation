output "org_policy_ids" {
  description = "Map of constraint name to the applied org-level policy resource ID."
  value       = module.org_policies.org_policy_ids
}

output "kms_key_id" {
  description = "The ID of the KMS crypto key used for disk encryption."
  value       = google_kms_crypto_key.disk_key.id
}

output "disk_self_link" {
  description = "The self_link of the CMEK-encrypted disk."
  value       = google_compute_disk.cmek_disk.self_link
}

output "cross_project_sa_email" {
  description = "The email of the cross-project service account."
  value       = google_service_account.cross_project_sa.email
}

output "main_project_id" {
  description = "The main project ID (Project-A)."
  value       = var.main_project_id
}

output "service_project_id" {
  description = "The service project ID (Project-B)."
  value       = var.service_project_id
}

output "cmek_vm_name" {
  description = "The name of the CMEK-encrypted VM."
  value       = google_compute_instance.cmek_vm.name
}

output "cmek_vm_self_link" {
  description = "The self_link of the CMEK-encrypted VM."
  value       = google_compute_instance.cmek_vm.self_link
}
