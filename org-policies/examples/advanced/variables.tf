variable "org_id" {
  description = "The numeric ID of the GCP organization."
  type        = string
}

variable "exception_project_id" {
  description = "Project ID that gets an exception from compute.disableSerialPortAccess."
  type        = string
}

variable "exception_folder_id" {
  description = "Folder ID (numeric, no \"folders/\" prefix) that gets an exception from compute.requireOsLogin."
  type        = string
}
