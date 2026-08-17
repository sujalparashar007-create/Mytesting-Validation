output "zone_ids" {
  description = "Map of zone name to resource ID."
  value       = module.dns.zone_ids
}
