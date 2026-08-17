variable "host_project_id" {
  description = "Project ID to enable as the Shared VPC host project."
  type        = string
}

variable "service_project_id" {
  description = "Project ID to attach as a Shared VPC service project."
  type        = string
}
