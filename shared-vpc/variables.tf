variable "host_project_id" {
  description = "Project ID to enable as the Shared VPC host project."
  type        = string
}

variable "service_project_ids" {
  description = "Set of project IDs to attach as Shared VPC service projects."
  type        = set(string)
  default     = []
}

variable "service_project_network_users" {
  description = "Map of service project ID to the list of IAM principals that should get roles/compute.networkUser on that project, so they can use the shared network's subnets."
  type        = map(list(string))
  default     = {}
}
