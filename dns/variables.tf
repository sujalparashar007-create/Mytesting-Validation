variable "project_id" {
  description = "Project ID where the DNS zones are created."
  type        = string
}

variable "zones" {
  description = "Private Cloud DNS zones to create, keyed by zone name. Set networks for a standard private zone, forwarding_target_name_servers for a forwarding zone, or peering_network for a peering zone -- a zone is typically only one of these at a time."
  type = map(object({
    dns_name    = string
    description = optional(string)
    networks    = optional(list(string), [])
    forwarding_target_name_servers = optional(list(object({
      ipv4_address    = string
      forwarding_path = optional(string)
    })), [])
    peering_network = optional(string)
    labels          = optional(map(string), {})
  }))
  default = {}
}

variable "record_sets" {
  description = "DNS record sets to create, keyed by a descriptive name."
  type = map(object({
    zone_key = string
    name     = string
    type     = string
    ttl      = optional(number, 300)
    rrdatas  = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for rs in var.record_sets : contains(keys(var.zones), rs.zone_key)
    ])
    error_message = "Every record_sets entry's zone_key must reference a key present in var.zones."
  }
}
