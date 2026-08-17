variable "project_id" {
  description = "Project ID where the load balancer resources are created."
  type        = string
}

variable "region" {
  description = "Region for the load balancer resources."
  type        = string
}

variable "name" {
  description = "Base name used for all created resources (health check, backend service, forwarding rule)."
  type        = string
}

variable "load_balancing_scheme" {
  description = "EXTERNAL for a passthrough Network Load Balancer, INTERNAL for an internal passthrough Load Balancer."
  type        = string

  validation {
    condition     = contains(["EXTERNAL", "INTERNAL"], var.load_balancing_scheme)
    error_message = "load_balancing_scheme must be either \"EXTERNAL\" or \"INTERNAL\"."
  }
}

variable "network" {
  description = "Self link or name of the VPC network. Required when load_balancing_scheme is \"INTERNAL\"."
  type        = string
  default     = null
}

variable "subnetwork" {
  description = "Self link or name of the subnetwork. Required when load_balancing_scheme is \"INTERNAL\"."
  type        = string
  default     = null
}

variable "protocol" {
  description = "Protocol for the backend service and forwarding rule."
  type        = string
  default     = "TCP"

  validation {
    condition     = contains(["TCP", "UDP"], var.protocol)
    error_message = "protocol must be either \"TCP\" or \"UDP\"."
  }
}

variable "ports" {
  description = "Ports the forwarding rule listens on. Null forwards all ports (only valid when load_balancing_scheme is \"INTERNAL\")."
  type        = list(string)
  default     = null
}

variable "ip_address" {
  description = "Self link of a reserved static IP for the forwarding rule. Null uses an ephemeral IP."
  type        = string
  default     = null
}

variable "health_check" {
  description = "Health check configuration for the backend service."
  type = object({
    protocol            = optional(string, "TCP")
    port                = optional(number, 80)
    request_path        = optional(string, "/")
    check_interval_sec  = optional(number, 5)
    timeout_sec         = optional(number, 5)
    healthy_threshold   = optional(number, 2)
    unhealthy_threshold = optional(number, 2)
  })
  default = {}

  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP"], var.health_check.protocol)
    error_message = "health_check.protocol must be one of \"HTTP\", \"HTTPS\", or \"TCP\"."
  }
}

variable "backends" {
  description = "Backends (instance groups or NEGs) for the backend service."
  type = list(object({
    group          = string
    balancing_mode = optional(string, "CONNECTION")
    failover       = optional(bool, false)
  }))
  default = []
}
