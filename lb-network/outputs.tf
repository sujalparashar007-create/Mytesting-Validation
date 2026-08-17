output "backend_service_id" {
  description = "ID of the backend service."
  value       = google_compute_region_backend_service.default.id
}

output "forwarding_rule_ip_address" {
  description = "IP address the load balancer is reachable on."
  value       = google_compute_forwarding_rule.default.ip_address
}

output "health_check_id" {
  description = "ID of the health check."
  value       = google_compute_region_health_check.default.id
}
