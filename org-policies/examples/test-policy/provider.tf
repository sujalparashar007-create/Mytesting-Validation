# Configure Google provider with explicit billing/quota project for org/folder-level API calls.
#
# ROOT CAUSE: The Org Policy API (orgpolicy.googleapis.com) operates at
# organizations/ and folders/ scope, which don't have their own billing accounts.
# API calls must be billed to a project. The Google provider requires
# user_project_override + billing_project to route that billing correctly.
#
# Without these, the provider falls through to ADC without a proper quota project
# for API billing and fails with:
#   403 SERVICE_DISABLED: "The orgpolicy.googleapis.com API requires a quota
#   project, which is not set by default."
#
# FIX: Explicitly set user_project_override + billing_project in the provider.
# This works equivalently for terraform plan, apply, AND destroy, and handles
# resource creation, update, and deletion. It is NOT an apply-only workaround
# because the provider persists this config for all lifecycle operations.
#
# Equivalent environment variables (not required when provider config is set):
#   USER_PROJECT_OVERRIDE=true
#   GOOGLE_BILLING_PROJECT=<billing_project>

provider "google" {
  user_project_override = true
  billing_project       = var.billing_project
}

# Enable Cloud KMS API (required for KMS key ring and crypto key resources)
resource "google_project_service" "kms_api" {
  project            = var.project_id
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}