variable "org_id" {
  description = "The numeric ID of the GCP organization the policies are applied to."
  type        = string
}

variable "org_constraints" {
  description = "Map of built-in organization policy constraints to enforce, keyed by constraint name (e.g. \"compute.disableSerialPortAccess\"). enforce is a tri-state string (\"TRUE\", \"FALSE\", or unset) so a constraint can carry only list_constraints without a boolean rule."
  type = map(object({
    enforce = optional(string)
    # project/folder IDs where this constraint's boolean rule is explicitly
    # set to FALSE, overriding the org-wide setting for that resource
    excluded_project_ids = optional(list(string), [])
    excluded_folder_ids  = optional(list(string), [])
    conditions = optional(list(object({
      enforce     = optional(string)
      expression  = string
      title       = string
      description = optional(string)
    })), [])
    list_constraints = optional(list(object({
      allowed_values = optional(list(string))
      denied_values  = optional(list(string))
    })), [])
  }))
  default = {}
}

variable "custom_constraint_policies" {
  description = "Map of custom organization policy constraints to create and enforce, keyed by a descriptive constraint name (the resulting constraint is named \"custom.<key>\")."
  type = map(object({
    description    = string
    display_name   = string
    action_type    = string
    condition      = string
    method_types   = list(string)
    resource_types = list(string)
    enforce        = string
    conditions = optional(list(object({
      enforce     = string
      expression  = string
      title       = string
      description = optional(string)
    })), [])
  }))
  default = {}
}
