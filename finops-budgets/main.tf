locals {
  # Per-budget channels: the budget's own list if set, else the module-wide
  # default. Computed once here rather than with coalescelist() in the
  # resource, which errors if both lists happen to be empty.
  budget_notification_channels = {
    for k, v in var.budgets : k => (
      length(v.monitoring_notification_channels) > 0
      ? v.monitoring_notification_channels
      : values(var.notification_channel_ids)
    )
  }
}

# Enforcement: real GCP billing budgets
resource "google_billing_budget" "budget" {
  for_each = var.budgets

  billing_account = var.billing_account
  display_name    = each.value.display_name

  amount {
    specified_amount {
      currency_code = each.value.currency_code
      units         = each.value.units
    }
  }

  dynamic "threshold_rules" {
    for_each = each.value.threshold_rules
    content {
      threshold_percent = threshold_rules.value.threshold_percent
      spend_basis       = threshold_rules.value.spend_basis
    }
  }

  # Only emitted when there's actually something to notify -- the provider
  # rejects an all_updates_rule block with neither pubsub_topic nor
  # monitoring_notification_channels set.
  dynamic "all_updates_rule" {
    for_each = (
      var.pubsub_topic_id != "" || length(local.budget_notification_channels[each.key]) > 0
    ) ? [1] : []
    content {
      pubsub_topic                     = var.pubsub_topic_id != "" ? var.pubsub_topic_id : null
      monitoring_notification_channels = length(local.budget_notification_channels[each.key]) > 0 ? local.budget_notification_channels[each.key] : null
      disable_default_iam_recipients   = each.value.disable_default_iam_recipients
      enable_project_level_recipients  = each.value.enable_project_level_recipients
    }
  }

  budget_filter {
    projects               = try(each.value.budget_filter.projects, null)
    resource_ancestors     = try(each.value.budget_filter.resource_ancestors, null)
    labels                 = try(each.value.budget_filter.labels, null)
    services               = try(each.value.budget_filter.services, null)
    credit_types_treatment = each.value.credit_types_treatment
    calendar_period        = each.value.calendar_period
  }
}

# billing budgets viewer for all specified members
resource "google_billing_account_iam_member" "viewer" {
  for_each = toset(var.iam_viewers)

  billing_account_id = var.billing_account
  role               = "roles/billing.viewer"
  member             = each.key
}
