resource "google_compute_router_nat" "nat" {
  for_each = var.nats

  project = var.project_id
  name    = each.key
  router  = each.value.router
  region  = each.value.region

  source_subnetwork_ip_ranges_to_nat = each.value.source_subnetwork_ip_ranges_to_nat
  nat_ip_allocate_option             = each.value.nat_ip_allocate_option
  nat_ips                            = length(each.value.nat_ips) > 0 ? each.value.nat_ips : null

  min_ports_per_vm                    = each.value.min_ports_per_vm
  max_ports_per_vm                    = each.value.max_ports_per_vm
  enable_dynamic_port_allocation      = each.value.enable_dynamic_port_allocation
  enable_endpoint_independent_mapping = each.value.enable_endpoint_independent_mapping
  udp_idle_timeout_sec                = each.value.udp_idle_timeout_sec
  tcp_established_idle_timeout_sec    = each.value.tcp_established_idle_timeout_sec
  tcp_transitory_idle_timeout_sec     = each.value.tcp_transitory_idle_timeout_sec
  icmp_idle_timeout_sec               = each.value.icmp_idle_timeout_sec

  dynamic "subnetwork" {
    for_each = each.value.subnetworks
    content {
      name                     = subnetwork.value.name
      source_ip_ranges_to_nat  = subnetwork.value.source_ip_ranges_to_nat
      secondary_ip_range_names = subnetwork.value.secondary_ip_range_names
    }
  }

  dynamic "log_config" {
    for_each = each.value.log_config[*]
    content {
      enable = log_config.value.enable
      filter = log_config.value.filter
    }
  }
}
