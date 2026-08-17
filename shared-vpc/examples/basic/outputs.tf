output "host_project_id" {
  description = "Project ID of the Shared VPC host project."
  value       = module.shared_vpc.host_project_id
}

output "service_project_ids" {
  description = "Set of project IDs attached as Shared VPC service projects."
  value       = module.shared_vpc.service_project_ids
}
