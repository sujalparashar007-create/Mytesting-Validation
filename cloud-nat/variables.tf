variable "project_id" {
  description = "Project ID where the Cloud NAT gateways are created."
  type        = string
}

variable "nats" {
  description = "Cloud NAT gateways to create, keyed by a descriptive NAT name. Each entry attaches to an existing Cloud Router (see ../cloud-router) in the given region."
  type = map(object({
    router                              = string
    region                              = string
    source_subnetwork_ip_ranges_to_nat  = optional(string, "ALL_SUBNETWORKS_ALL_IP_RANGES")
    nat_ip_allocate_option              = optional(string, "AUTO_ONLY")
    nat_ips                             = optional(list(string), [])
    min_ports_per_vm                    = optional(number)
    max_ports_per_vm                    = optional(number)
    enable_dynamic_port_allocation      = optional(bool, false)
    enable_endpoint_independent_mapping = optional(bool)
    udp_idle_timeout_sec                = optional(number)
    tcp_established_idle_timeout_sec    = optional(number)
    tcp_transitory_idle_timeout_sec     = optional(number)
    icmp_idle_timeout_sec               = optional(number)
    # Only used when source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS".
    subnetworks = optional(list(object({
      name                     = string
      source_ip_ranges_to_nat  = optional(list(string), ["ALL_IP_RANGES"])
      secondary_ip_range_names = optional(list(string), [])
    })), [])
    log_config = optional(object({
      enable = bool
      filter = string
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for nat in var.nats : contains(
        ["ALL_SUBNETWORKS_ALL_IP_RANGES", "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES", "LIST_OF_SUBNETWORKS"],
        nat.source_subnetwork_ip_ranges_to_nat
      )
    ])
    error_message = "source_subnetwork_ip_ranges_to_nat must be one of \"ALL_SUBNETWORKS_ALL_IP_RANGES\", \"ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES\", or \"LIST_OF_SUBNETWORKS\"."
  }

  validation {
    condition = alltrue([
      for nat in var.nats : contains(["AUTO_ONLY", "MANUAL_ONLY"], nat.nat_ip_allocate_option)
    ])
    error_message = "nat_ip_allocate_option must be either \"AUTO_ONLY\" or \"MANUAL_ONLY\"."
  }
}
