output "host_project_id" {
  description = "Project ID of the Shared VPC host project."
  value       = google_compute_shared_vpc_host_project.landing_zone_host_project.project
}

output "service_project_ids" {
  description = "Set of project IDs attached as Shared VPC service projects."
  value = [
    for sp in google_compute_shared_vpc_service_project.landing_zone_service_project :
    sp.service_project
  ]
}
