output "org_policy_ids" {
  description = "Map of constraint name to the applied org-level policy resource ID."
  value = {
    for name, policy in google_org_policy_policy.org_enforced_policies :
    name => policy.id
  }
}

output "custom_constraint_names" {
  description = "Map of custom constraint key to its full constraint name (custom.<key>)."
  value = {
    for name, constraint in google_org_policy_custom_constraint.custom_constraints :
    name => constraint.name
  }
}

output "folder_custom_constraint_policy_ids" {
  description = "Map of \"<constraint-key>::folder::<folder-id>\" to the folder-level custom constraint policy resource ID."
  value = {
    for key, policy in google_org_policy_policy.folder_custom_constraint_policies :
    key => policy.id
  }
}

