variable "project_id" {
  description = "Project ID where the firewall rules are created."
  type        = string
}

variable "network_self_link" {
  description = "Self link of the VPC network the firewall rules apply to (e.g. module.vpc.network_self_link)."
  type        = string
}

variable "firewall_rules" {
  description = "Map of firewall rules to create, keyed by a descriptive rule name."
  type = map(object({
    direction               = optional(string, "INGRESS")
    priority                = optional(number, 1000)
    source_ranges           = optional(list(string), [])
    destination_ranges      = optional(list(string), [])
    source_tags             = optional(list(string), [])
    target_tags             = optional(list(string), [])
    target_service_accounts = optional(list(string), [])
    disabled                = optional(bool, false)
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in var.firewall_rules : contains(["INGRESS", "EGRESS"], rule.direction)
    ])
    error_message = "Every firewall rule's direction must be either \"INGRESS\" or \"EGRESS\"."
  }
}
