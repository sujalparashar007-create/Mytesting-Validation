# Example: finops-function basic usage
# Deploys a Cloud Function (2nd gen) triggered by Pub/Sub budget alerts.
# Secrets (e.g. Teams webhook) stored in Secret Manager.
# Run: terraform init && terraform validate

module "finops_function" {
  source = "../../"

  project_id      = var.project_id
  region          = var.region
  pubsub_topic_id = var.pubsub_topic_id
  function_name   = "finops-budget-alert-processor"
  bucket_name     = var.bucket_name

  # function_source_dir left unset -- uses the module's own bundled
  # function-source/ (logs alerts, forwards to Teams if configured).

  existing_service_account_email = var.service_account_email

  environment_variables = {}

  secret_environment = var.secret_environment
}
