variable "org_id" {
  description = "Organization ID that department folders are created under, in the form \"organizations/1234567890\"."
  type        = string
}

variable "billing_account" {
  description = "Billing account ID to link the example projects to."
  type        = string
}
