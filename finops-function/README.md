# finops-function

Deploys a Cloud Function (2nd gen) triggered by Pub/Sub budget alerts (see
`../finops-alerts` for the topic). Sensitive values (e.g. a Teams webhook
URL) are stored in Secret Manager, not plaintext env vars.

## What the default function does

`function-source/` ships a minimal, working implementation
(`process_budget_alert`):

- Always logs the decoded budget alert payload to Cloud Logging.
- If `TEAMS_WEBHOOK_URL` is set (wire it via `secret_environment`), also
  POSTs a basic Markdown summary card to that Microsoft Teams Incoming
  Webhook.

This is a minimal reference implementation, not hardened production code -
review error handling and message formatting before relying on it for real
alerting. Pass your own `function_source_dir` to use different function code
entirely; the module doesn't require you to use the bundled one.

## Usage

```hcl
module "finops_function" {
  source = "../finops-function"

  project_id      = "my-project-id"
  region          = "us-east1"
  pubsub_topic_id = module.finops_alerts.pubsub_topic_id

  existing_service_account_email = "tf-executor@my-project.iam.gserviceaccount.com"

  secret_environment = {
    TEAMS_WEBHOOK_URL = var.teams_webhook_url
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | (required) | GCP project ID |
| `pubsub_topic_id` | `string` | (required) | Full Pub/Sub topic ID to trigger the function |
| `region` | `string` | `"us-east1"` | GCP region |
| `function_name` | `string` | `"finops-budget-alert-processor"` | Cloud Function name |
| `function_source_dir` | `string` | `null` | Path to source code directory; `null` uses this module's own `function-source/` |
| `bucket_name` | `string` | `"finops-function-source"` | GCS bucket for source zip |
| `runtime` | `string` | `"python311"` | Cloud Function runtime |
| `existing_service_account_email` | `string` | `null` | Runtime SA; null = module creates dedicated SA |
| `runtime_sa_roles` | `list(string)` | `["roles/logging.logWriter"]` | IAM roles for the dedicated runtime SA |
| `max_instance_count` | `number` | `1` | Maximum number of Cloud Function instances |
| `available_memory` | `string` | `"256M"` | Memory allocated to the Cloud Function |
| `timeout_seconds` | `number` | `60` | Cloud Function execution timeout in seconds |
| `environment_variables` | `map(string)` | `{}` | Env vars passed to the runtime (sensitive in Terraform) |
| `secret_environment` | `map(string)` | `{}` | Secrets stored in Secret Manager and exposed to the function |
| `existing_secret_ids` | `map(string)` | `{}` | Key to existing secret ID; keys present here skip secret creation |
| `secret_accessors` | `list(object({secret_key, member}))` | `[]` | Additional members granted secretAccessor on specific secrets |
| `enable_function` | `bool` | `true` | Set to false to skip Cloud Function creation |

## Outputs

| Name | Description |
|------|-------------|
| `function_name` | Cloud Function name |
| `function_uri` | Cloud Function trigger URI |
| `bucket_name` | GCS bucket storing function source code |

