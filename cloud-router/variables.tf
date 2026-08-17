variable "project_id" {
  description = "Project ID where the Cloud Router is created."
  type        = string
}

variable "region" {
  description = "Region for the Cloud Router."
  type        = string
}

variable "name" {
  description = "Name of the Cloud Router."
  type        = string
}

variable "network" {
  description = "Self link or name of the VPC network the router attaches to."
  type        = string
}

variable "description" {
  description = "Description of the Cloud Router."
  type        = string
  default     = null
}

variable "asn" {
  description = "Local BGP Autonomous System Number for the router (private ASN range: 64512-65534 or 4200000000-4294967294)."
  type        = number
}

variable "advertise_mode" {
  description = "BGP advertise mode: DEFAULT advertises all subnets in the VPC; CUSTOM advertises only advertised_groups/advertised_ip_ranges."
  type        = string
  default     = "DEFAULT"

  validation {
    condition     = contains(["DEFAULT", "CUSTOM"], var.advertise_mode)
    error_message = "advertise_mode must be either \"DEFAULT\" or \"CUSTOM\"."
  }
}

variable "advertised_groups" {
  description = "Groups of IP ranges to advertise, when advertise_mode is CUSTOM (e.g. [\"ALL_SUBNETS\"])."
  type        = list(string)
  default     = []
}

variable "advertised_ip_ranges" {
  description = "Explicit IP ranges to advertise, when advertise_mode is CUSTOM."
  type = list(object({
    range       = string
    description = optional(string)
  }))
  default = []
}

variable "keepalive_interval" {
  description = "BGP session keepalive interval in seconds (20-60). Null uses the GCP default."
  type        = number
  default     = null
}

variable "interfaces" {
  description = "Router interfaces to create, keyed by a descriptive interface name. Used to attach the router to a VPN tunnel or (for router-appliance setups) a subnetwork."
  type = map(object({
    ip_range            = optional(string)
    vpn_tunnel          = optional(string)
    subnetwork          = optional(string)
    private_ip_address  = optional(string)
    redundant_interface = optional(string)
  }))
  default = {}
}

variable "peers" {
  description = "BGP peers to create, keyed by a descriptive peer name."
  type = map(object({
    interface         = string
    peer_ip_address   = optional(string)
    peer_asn          = number
    advertise_mode    = optional(string, "DEFAULT")
    advertised_groups = optional(list(string), [])
    advertised_ip_ranges = optional(list(object({
      range       = string
      description = optional(string)
    })), [])
    enable = optional(bool, true)
  }))
  default = {}

  validation {
    condition = alltrue([
      for peer in var.peers : contains(["DEFAULT", "CUSTOM"], peer.advertise_mode)
    ])
    error_message = "Every peer's advertise_mode must be either \"DEFAULT\" or \"CUSTOM\"."
  }
}
