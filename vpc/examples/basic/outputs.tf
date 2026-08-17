output "network_id" {
  description = "ID of the created VPC network."
  value       = module.vpc.network_id
}

output "subnet_self_links" {
  description = "Map of subnet name to self link."
  value       = module.vpc.subnet_self_links
}
