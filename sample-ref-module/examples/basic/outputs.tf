output "network_id" {
  description = "ID of the created VPC network."
  value       = module.network.network_id
}

output "subnet_self_links" {
  description = "Map of subnet name to self link."
  value       = module.network.subnet_self_links
}
