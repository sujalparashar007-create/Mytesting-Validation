output "firewall_rule_ids" {
  description = "Map of firewall rule name to resource ID."
  value = {
    for name, rule in google_compute_firewall.landing_zone_firewall_rule :
    name => rule.id
  }
}

output "firewall_rule_self_links" {
  description = "Map of firewall rule name to self link."
  value = {
    for name, rule in google_compute_firewall.landing_zone_firewall_rule :
    name => rule.self_link
  }
}
