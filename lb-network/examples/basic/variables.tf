variable "project_id" {
  description = "Project ID where the example load balancer is created."
  type        = string
}

variable "region" {
  description = "Region for the example load balancer."
  type        = string
  default     = "us-central1"
}

variable "network_self_link" {
  description = "Self link of an existing VPC network (e.g. from the vpc module)."
  type        = string
}

variable "subnetwork_self_link" {
  description = "Self link of an existing subnetwork (e.g. from the vpc module)."
  type        = string
}

variable "backend_instance_group" {
  description = "Self link of an existing managed instance group to use as the backend."
  type        = string
}
