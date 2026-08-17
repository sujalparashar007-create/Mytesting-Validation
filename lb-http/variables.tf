variable "project_id" {
  description = "Project ID where the load balancer resources are created."
  type        = string
}

variable "name" {
  description = "Base name used for all created resources (health check, backend service, URL map, proxy, forwarding rule)."
  type        = string
}

variable "protocol" {
  description = "Protocol the backend service uses to talk to backends."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS", "HTTP2"], var.protocol)
    error_message = "protocol must be one of \"HTTP\", \"HTTPS\", or \"HTTP2\"."
  }
}

variable "port_name" {
  description = "Named port on the backend instance groups that traffic is sent to."
  type        = string
  default     = "http"
}

variable "enable_cdn" {
  description = "Enable Cloud CDN on the backend service."
  type        = bool
  default     = false
}

variable "session_affinity" {
  description = "Session affinity mode for the backend service."
  type        = string
  default     = "NONE"
}

variable "health_check" {
  description = "Health check configuration for the backend service."
  type = object({
    protocol            = optional(string, "HTTP")
    port                = optional(number, 80)
    request_path        = optional(string, "/")
    check_interval_sec  = optional(number, 5)
    timeout_sec         = optional(number, 5)
    healthy_threshold   = optional(number, 2)
    unhealthy_threshold = optional(number, 2)
  })
  default = {}

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.health_check.protocol)
    error_message = "health_check.protocol must be either \"HTTP\" or \"HTTPS\"."
  }
}

variable "backends" {
  description = "Backends (instance groups or NEGs) for the default backend service."
  type = list(object({
    group           = string
    balancing_mode  = optional(string, "UTILIZATION")
    capacity_scaler = optional(number, 1.0)
    max_utilization = optional(number, 0.8)
  }))
  default = []
}

variable "host_rules" {
  description = "Additional host/path-based routing rules, each pointing at a backend service created outside this module (by self link or ID). Leave empty to route all traffic to the default backend service created here."
  type = list(object({
    hosts             = list(string)
    path_matcher_name = string
    default_service   = string
    path_rules = optional(list(object({
      paths   = list(string)
      service = string
    })), [])
  }))
  default = []
}

variable "ssl_domains" {
  description = "Domains for a Google-managed SSL certificate. Non-empty creates an HTTPS proxy on port 443; empty creates an HTTP proxy on port 80."
  type        = list(string)
  default     = []
}

variable "ip_address" {
  description = "Self link of a reserved global static IP to use for the forwarding rule. Null uses an ephemeral IP."
  type        = string
  default     = null
}
