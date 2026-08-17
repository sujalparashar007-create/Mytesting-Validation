output "nat_ids" {
  description = "Map of NAT name to resource ID."
  value       = module.cloud_nat.nat_ids
}
