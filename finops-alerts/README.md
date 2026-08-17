# finops-alerts

Creates a Pub/Sub topic and email notification channels for GCP billing
budget alerts. Supports bring-your-own-topic and additive IAM grants. Meant
to be wired into `../finops-budgets`' `google_billing_budget` so threshold
breaches publish events to this topic.

## Usage

```hcl
module "finops_alerts" {
  source = "../finops-alerts"

  project_id   = "my-project-id"
  topic_name   = "finops-budget-alerts"
  alert_emails = ["alerts@example.com"]

  iam = [
    { role = "roles/pubsub.publisher", member = "serviceAccount:budget-sa@my-project.iam.gserviceaccount.com" },
  ]
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `project_id` | `string` | (required) | GCP project ID. |
| `topic_name` | `string` | `"finops-budget-alerts"` | Pub/Sub topic name. |
| `alert_emails` | `list(string)` | `[]` | Email addresses for notifications. |
| `labels` | `map(string)` | `{environment="finops", managed_by="terraform"}` | Topic labels. |
| `iam` | `list(object({role, member}))` | `[]` | Additional IAM grants on the Pub/Sub topic (additive). |
| `existing_topic_id` | `string` | `null` | Existing Pub/Sub topic ID; `null` creates a new topic. |
| `existing_notification_channel_ids` | `map(string)` | `{}` | Map of email to existing channel ID (emails present here skip creation). |

## Outputs

| Name | Description |
|---|---|
| `pubsub_topic_id` | Full Pub/Sub topic ID for wiring into budgets. |
| `pubsub_topic_name` | Short topic name. |
| `notification_channel_ids` | Map of email to channel ID. |
