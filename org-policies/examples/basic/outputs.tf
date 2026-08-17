output "org_policy_ids" {
  description = "Map of constraint name to the applied org-level policy resource ID."
  value       = module.org_policies.org_policy_ids
}
