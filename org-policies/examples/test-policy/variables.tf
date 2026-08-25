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

variable "billing_project" {
  description = "Project ID used for billing and quota when the Google provider calls org/folder-level APIs (Org Policy API requires a quota project). Must have orgpolicy.googleapis.com enabled and the authenticated user must have access to it."
  type        = string
  default     = "test-project-506110"
}

# -----------------------------------------------------------------------------
# CMEK Variables
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "The GCP project ID where KMS and disk resources will be created."
  type        = string
  default     = "test-project-506110"
}

variable "kms_keyring_name" {
  description = "Name of the KMS key ring."
  type        = string
  default     = "my-keyring"
}

variable "kms_key_name" {
  description = "Name of the KMS crypto key."
  type        = string
  default     = "my-disk-key"
}

variable "kms_location" {
  description = "Location for the KMS key ring."
  type        = string
  default     = "us-central1"
}

variable "disk_name" {
  description = "Name of the CMEK-encrypted disk."
  type        = string
  default     = "test-ok-cmek"
}

variable "disk_zone" {
  description = "Zone for the CMEK-encrypted disk."
  type        = string
  default     = "us-central1-a"
}

variable "disk_size_gb" {
  description = "Size of the disk in GB."
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "Type of the disk (e.g., pd-balanced, pd-ssd)."
  type        = string
  default     = "pd-balanced"
}

# -----------------------------------------------------------------------------
# Cross-Project SA Validation Variables
# -----------------------------------------------------------------------------

variable "main_project_id" {
  description = "The main GCP project ID (Project-A)."
  type        = string
  default     = "test-project-506110"
}

variable "service_project_id" {
  description = "The service GCP project ID (Project-B) for cross-project SA testing."
  type        = string
  default     = "test-service-project-00"
}

variable "enable_service_project_resources" {
  description = "Whether to enable Compute API in the service project. Set to false if billing is not enabled on the service project."
  type        = bool
  default     = false
}
