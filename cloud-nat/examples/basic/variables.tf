variable "project_id" {
  description = "Project ID where the example NAT gateway is created."
  type        = string
}

variable "router_name" {
  description = "Name of an existing Cloud Router (e.g. from the cloud-router module)."
  type        = string
}
