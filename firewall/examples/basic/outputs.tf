output "firewall_rule_self_links" {
  description = "Map of firewall rule name to self link."
  value       = module.firewall.firewall_rule_self_links
}
