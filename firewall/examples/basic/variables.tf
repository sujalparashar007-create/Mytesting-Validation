variable "project_id" {
  description = "Project ID where the example firewall rules are created."
  type        = string
}

variable "network_self_link" {
  description = "Self link of an existing VPC network (e.g. from the vpc module)."
  type        = string
}
