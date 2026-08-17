output "forwarding_rule_ip_address" {
  description = "IP address the load balancer is reachable on."
  value       = module.lb_http.forwarding_rule_ip_address
}
