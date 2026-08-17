variable "project_id" {
  description = "Project ID where the VPC network and subnets are created."
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network."
  type        = string
}

variable "routing_mode" {
  description = "Network-wide routing mode, either REGIONAL or GLOBAL."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "routing_mode must be either \"REGIONAL\" or \"GLOBAL\"."
  }
}

variable "delete_default_routes_on_create" {
  description = "If true, the default internet gateway route is not created with the network."
  type        = bool
  default     = false
}

variable "subnets" {
  description = "Map of subnets to create, keyed by a descriptive subnet name."
  type = map(object({
    region                   = string
    ip_cidr_range            = string
    private_ip_google_access = optional(bool, true)
    flow_logs_enabled        = optional(bool, false)
    secondary_ip_ranges      = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for subnet in var.subnets : can(cidrhost(subnet.ip_cidr_range, 0))
    ])
    error_message = "Every subnet's ip_cidr_range must be a valid CIDR block."
  }
}
