output "backend_service_id" {
  description = "ID of the default backend service."
  value       = google_compute_backend_service.default.id
}

output "url_map_id" {
  description = "ID of the URL map."
  value       = google_compute_url_map.default.id
}

output "forwarding_rule_ip_address" {
  description = "IP address the load balancer is reachable on."
  value       = google_compute_global_forwarding_rule.default.ip_address
}

output "health_check_id" {
  description = "ID of the health check."
  value       = google_compute_health_check.default.id
}
