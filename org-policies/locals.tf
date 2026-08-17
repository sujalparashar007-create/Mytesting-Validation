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
}
