locals {
  # Flattened once here so the exception resources below only need a single
  # for_each each, per this repo's no-nested-loops rule.
  folder_exceptions = flatten([
    for constraint, cfg in var.org_constraints : [
      for fid in coalesce(cfg.excluded_folder_ids, []) : {
        constraint                = constraint
        id                        = fid
        default_exception_enforce = "FALSE"
      }
    ]
  ])

  project_exceptions = flatten([
    for constraint, cfg in var.org_constraints : [
      for pid in coalesce(cfg.excluded_project_ids, []) : {
        constraint                = constraint
        id                        = pid
        default_exception_enforce = "FALSE"
      }
    ]
  ])

  # Optional direct policy application targets. These use the same rule
  # definitions as org_constraints, but are applied at folder/project scope.
  folder_policy_targets = flatten([
    for constraint, cfg in var.org_constraints : [
      for fid in var.folder_target_ids : {
        constraint       = constraint
        id               = fid
        enforce          = try(cfg.enforce, null)
        conditions       = try(cfg.conditions, [])
        list_constraints = try(cfg.list_constraints, [])
      }
    ]
  ])

  project_policy_targets = flatten([
    for constraint, cfg in var.org_constraints : [
      for pid in var.project_target_ids : {
        constraint       = constraint
        id               = pid
        enforce          = try(cfg.enforce, null)
        conditions       = try(cfg.conditions, [])
        list_constraints = try(cfg.list_constraints, [])
      }
    ]
  ])

  # Folder targets for custom constraints. GCP requires custom constraint
  # DEFINITIONS to be org-scoped, but their ENFORCEMENT policies can target
  # folders; fan each custom constraint out to the folder target IDs.
  folder_custom_policy_targets = flatten([
    for name, cfg in var.custom_constraint_policies : [
      for fid in var.folder_target_ids : {
        name       = name
        id         = fid
        enforce    = cfg.enforce
        conditions = try(cfg.conditions, [])
      }
    ]
  ])

}
