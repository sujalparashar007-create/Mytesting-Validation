variable "project_id" {
  description = "Project ID where the example load balancer is created."
  type        = string
}

variable "backend_instance_group" {
  description = "Self link of an existing managed instance group to use as the backend."
  type        = string
}
