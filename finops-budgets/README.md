# finops-budgets

Creates GCP billing budgets with Pub/Sub alert wiring, scoped budget filters,
and IAM viewer grants. Meant to pair with `../finops-alerts` (for the
Pub/Sub topic and notification channels) and `../finops-dataset` (for
storing billing export data to report against).

## Usage

```hcl
module "finops_budgets" {
  source = "../finops-budgets"

  billing_account          = "000000-000000-000000"
  pubsub_topic_id          = module.finops_alerts.pubsub_topic_id
  notification_channel_ids = module.finops_alerts.notification_channel_ids

  budgets = {
    monthly_overall = {
      display_name                    = "Monthly Overall Budget"
      currency_code                   = "USD"
      units                           = "1000"
      credit_types_treatment          = "EXCLUDE_ALL_CREDITS"
      enable_project_level_recipients = true
      budget_month                    = "2026-08"
      budget_project                  = "projects/my-project"
      threshold_rules = [
        { threshold_percent = 0.5 },
        { threshold_percent = 0.8 },
        { threshold_percent = 1.0 },
      ]
    }
  }

  iam_viewers = ["group:finops-team@example.com"]
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `billing_account` | `string` | (required) | GCP billing account ID. |
| `pubsub_topic_id` | `string` | `""` | Full Pub/Sub topic ID for alert publishing. |
| `notification_channel_ids` | `map(string)` | `{}` | Map of email to notification channel ID. |
| `budgets` | `map(object({...}))` | `{}` | Budget definitions. Each budget accepts: `budget_filter` (nested object with optional `projects`, `resource_ancestors`, `labels`, `services`), `credit_types_treatment` (`INCLUDE_ALL_CREDITS` / `EXCLUDE_ALL_CREDITS` / `INCLUDE_SPECIFIED_CREDITS`), `calendar_period` (`MONTH` / `QUARTER` / `YEAR`), `threshold_rules` (each with `threshold_percent` and optional `spend_basis`: `CURRENT_SPEND` or `FORECASTED_SPEND`). |
| `iam_viewers` | `list(string)` | `[]` | Members granted `roles/billing.viewer`. |

## Outputs

| Name | Description |
|---|---|
| `budget_ids` | Map of budget key to resource name. |
| `budget_names` | Map of budget key to display name. |
| `budget_amounts` | Budget amount structs (`month`, `project_id`, `currency`, `budget_amount`), one per budget-filter project with `budget_month` set - useful as an input to a downstream BigQuery reporting view, if you build one. |
