output "network_id" {
  description = "ID of the created VPC network."
  value       = google_compute_network.landing_zone_vpc.id
}

output "network_self_link" {
  description = "Self link of the created VPC network."
  value       = google_compute_network.landing_zone_vpc.self_link
}

output "subnet_self_links" {
  description = "Map of subnet name to self link."
  value = {
    for name, subnet in google_compute_subnetwork.landing_zone_subnet :
    name => subnet.self_link
  }
}

output "subnet_ids" {
  description = "Map of subnet name to subnet ID."
  value = {
    for name, subnet in google_compute_subnetwork.landing_zone_subnet :
    name => subnet.id
  }
}
