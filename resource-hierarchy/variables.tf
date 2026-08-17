variable "folders" {
  description = <<-EOT
    Map of folders to create, keyed by a descriptive folder name.
    `parent` is a literal ID ("organizations/1234" or "folders/5678").
    Nest a folder under another folder created in this same call by setting
    that folder's `parent` to the parent folder's output ID.
  EOT
  type = map(object({
    display_name = string
    parent       = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for f in var.folders :
      startswith(f.parent, "organizations/") || startswith(f.parent, "folders/")
    ])
    error_message = "Every folder's parent must start with \"organizations/\" or \"folders/\"."
  }
}

variable "projects" {
  description = <<-EOT
    Map of projects to create, keyed by a descriptive project name.
    Set `folder_key` to nest under a folder created in this same module call,
    or set `folder_id`/`org_id` for an existing parent.
    `services` is an optional list of APIs to enable on the project.
  EOT
  type = map(object({
    project_id          = string
    billing_account     = string
    folder_key          = optional(string)
    folder_id           = optional(string)
    org_id              = optional(string)
    labels              = optional(map(string), {})
    auto_create_network = optional(bool, false)
    services            = optional(list(string), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for p in var.projects :
      (p.folder_key != null) || (p.folder_id != null) || (p.org_id != null)
    ])
    error_message = "Every project must set exactly one parent: folder_key, folder_id, or org_id."
  }
}
