output "router_id" {
  description = "ID of the created Cloud Router."
  value       = google_compute_router.router.id
}

output "router_name" {
  description = "Name of the created Cloud Router."
  value       = google_compute_router.router.name
}

output "router_self_link" {
  description = "Self link of the created Cloud Router."
  value       = google_compute_router.router.self_link
}

output "interface_names" {
  description = "Set of created interface names, for use as a peer's interface value."
  value       = keys(google_compute_router_interface.interfaces)
}
