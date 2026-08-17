variable "project_id" {
  description = "Project ID where the example router is created."
  type        = string
}

variable "region" {
  description = "Region for the example router."
  type        = string
  default     = "us-central1"
}

variable "network_self_link" {
  description = "Self link of an existing VPC network (e.g. from the vpc module)."
  type        = string
}
