# Requires USER_PROJECT_OVERRIDE=true and GOOGLE_BILLING_PROJECT=<quota-project>
# environment variables set at apply time -- without them, apply will plan
# successfully but fail with a billing/quota project error on the real
# "yes" confirmation. See:
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#quota-management-configuration

resource "google_org_policy_policy" "project_exceptions" {
  for_each = {
    for e in local.project_exceptions : "${e.constraint}::project::${e.id}" => e
  }

  name   = "projects/${each.value.id}/policies/${each.value.constraint}"
  parent = "projects/${each.value.id}"

  spec {
    rules {
      enforce = each.value.default_exception_enforce
    }
  }
}

resource "google_org_policy_policy" "folder_exceptions" {
  for_each = {
    for e in local.folder_exceptions : "${e.constraint}::folder::${e.id}" => e
  }

  name   = "folders/${each.value.id}/policies/${each.value.constraint}"
  parent = "folders/${each.value.id}"

  spec {
    rules {
      enforce = each.value.default_exception_enforce
    }
  }
}

resource "google_org_policy_policy" "folder_targets" {
  for_each = {
    for t in local.folder_policy_targets : "${t.constraint}::folder::${t.id}" => t
  }

  name   = "folders/${each.value.id}/policies/${each.value.constraint}"
  parent = "folders/${each.value.id}"

  spec {
    dynamic "rules" {
      for_each = each.value.conditions
      content {
        enforce = try(rules.value.enforce, null)
        condition {
          expression  = rules.value.expression
          title       = rules.value.title
          description = try(rules.value.description, null)
        }
      }
    }

    dynamic "rules" {
      for_each = each.value.enforce == "TRUE" || each.value.enforce == "FALSE" ? [1] : []
      content {
        enforce = each.value.enforce
      }
    }

    dynamic "rules" {
      for_each = each.value.list_constraints
      content {
        values {
          allowed_values = rules.value.allowed_values
          denied_values  = rules.value.denied_values
        }
      }
    }
  }
}

resource "google_org_policy_policy" "project_targets" {
  for_each = {
    for t in local.project_policy_targets : "${t.constraint}::project::${t.id}" => t
  }

  name   = "projects/${each.value.id}/policies/${each.value.constraint}"
  parent = "projects/${each.value.id}"

  spec {
    dynamic "rules" {
      for_each = each.value.conditions
      content {
        enforce = try(rules.value.enforce, null)
        condition {
          expression  = rules.value.expression
          title       = rules.value.title
          description = try(rules.value.description, null)
        }
      }
    }

    dynamic "rules" {
      for_each = each.value.enforce == "TRUE" || each.value.enforce == "FALSE" ? [1] : []
      content {
        enforce = each.value.enforce
      }
    }

    dynamic "rules" {
      for_each = each.value.list_constraints
      content {
        values {
          allowed_values = rules.value.allowed_values
          denied_values  = rules.value.denied_values
        }
      }
    }
  }
}

resource "google_org_policy_policy" "org_enforced_policies" {
  for_each = var.create_org_policies ? var.org_constraints : {}

  name   = "organizations/${var.org_id}/policies/${each.key}"
  parent = "organizations/${var.org_id}"

  spec {
    dynamic "rules" {
      for_each = each.value.conditions
      content {
        enforce = try(rules.value.enforce, null)
        condition {
          expression  = rules.value.expression
          title       = rules.value.title
          description = try(rules.value.description, null)
        }
      }
    }

    dynamic "rules" {
      for_each = each.value.enforce == "TRUE" || each.value.enforce == "FALSE" ? [1] : []
      content {
        enforce = each.value.enforce
      }
    }

    dynamic "rules" {
      for_each = each.value.list_constraints
      content {
        values {
          allowed_values = rules.value.allowed_values
          denied_values  = rules.value.denied_values
        }
      }
    }
  }
}

resource "google_org_policy_custom_constraint" "custom_constraints" {
  for_each = var.custom_constraint_policies

  name           = "custom.${each.key}"
  parent         = "organizations/${var.org_id}"
  display_name   = each.value.display_name
  description    = each.value.description
  action_type    = each.value.action_type
  condition      = each.value.condition
  method_types   = each.value.method_types
  resource_types = each.value.resource_types
}

resource "google_org_policy_policy" "org_custom_constraints_policies" {
  for_each = var.custom_constraint_policies

  name   = "organizations/${var.org_id}/policies/${google_org_policy_custom_constraint.custom_constraints[each.key].name}"
  parent = "organizations/${var.org_id}"

  spec {
    dynamic "rules" {
      for_each = each.value.conditions
      content {
        enforce = rules.value.enforce
        condition {
          expression  = try(rules.value.expression, null)
          title       = try(rules.value.title, null)
          description = try(rules.value.description, null)
        }
      }
    }

    rules {
      enforce = each.value.enforce
    }
  }
}
