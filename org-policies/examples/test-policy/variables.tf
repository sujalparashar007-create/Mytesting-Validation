variable "org_id" {
  description = "The numeric ID of the GCP organization."
  type        = string
}

variable "deployment_levels" {
  description = "Where to apply policies. Allowed values: org, folder, project."
  type        = list(string)
  default     = ["folder"]
  validation {
    condition     = length(setsubtract(toset(var.deployment_levels), toset(["org", "folder", "project"]))) == 0
    error_message = "deployment_levels can only contain: org, folder, project."
  }
}

variable "project_level_policy_target_ids" {
  description = "Project IDs where project-level policy resources should be created."
  type        = list(string)
  default     = []
}

variable "folder_level_policy_target_ids" {
  description = "Folder IDs (numeric, no \"folders/\" prefix) where folder-level policy resources should be created."
  type        = list(string)
  default     = []
}
