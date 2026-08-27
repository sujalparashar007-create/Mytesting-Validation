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

# -----------------------------------------------------------------------------
# VM / Network Variables
# -----------------------------------------------------------------------------

variable "vm_name" {
  description = "Name of the compliant positive-test VM."
  type        = string
  default     = "test-cmek-vm"
}

variable "vm_machine_type" {
  description = "Machine type for the compliant positive-test VM. Must be in allowed_vm_machine_types."
  type        = string
  default     = "n1-standard-1"
}

variable "vm_image" {
  description = "Boot disk image for the positive-test VM."
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "allowed_vm_machine_types" {
  description = "List of approved VM machine types enforced by the custom.restrictVmMachineType constraint."
  type        = list(string)
  default     = ["n1-standard-1"]
}

variable "network_name" {
  description = "Name of the custom VPC created for the positive-test VM."
  type        = string
  default     = "test-policy-vpc"
}

variable "subnetwork_name" {
  description = "Name of the custom subnet created for the positive-test VM."
  type        = string
  default     = "test-policy-subnet"
}

variable "subnetwork_cidr" {
  description = "CIDR range for the custom subnet."
  type        = string
  default     = "10.0.0.0/24"
}

variable "subnetwork_region" {
  description = "Region for the custom subnet. Must match the region of disk_zone."
  type        = string
  default     = "us-central1"
}

variable "sa_account_id" {
  description = "Account ID for the cross-project test service account."
  type        = string
  default     = "test-cross-project-sa"
}
