resource "google_compute_region_health_check" "default" {
  project = var.project_id
  region  = var.region
  name    = "${var.name}-hc"

  check_interval_sec  = var.health_check.check_interval_sec
  timeout_sec         = var.health_check.timeout_sec
  healthy_threshold   = var.health_check.healthy_threshold
  unhealthy_threshold = var.health_check.unhealthy_threshold

  dynamic "http_health_check" {
    for_each = var.health_check.protocol == "HTTP" ? [1] : []
    content {
      port         = var.health_check.port
      request_path = var.health_check.request_path
    }
  }

  dynamic "https_health_check" {
    for_each = var.health_check.protocol == "HTTPS" ? [1] : []
    content {
      port         = var.health_check.port
      request_path = var.health_check.request_path
    }
  }

  dynamic "tcp_health_check" {
    for_each = var.health_check.protocol == "TCP" ? [1] : []
    content {
      port = var.health_check.port
    }
  }
}

resource "google_compute_region_backend_service" "default" {
  project = var.project_id
  region  = var.region
  name    = "${var.name}-backend"

  protocol              = var.protocol
  load_balancing_scheme = var.load_balancing_scheme
  network               = var.load_balancing_scheme == "INTERNAL" ? var.network : null
  health_checks         = [google_compute_region_health_check.default.id]

  dynamic "backend" {
    for_each = var.backends
    content {
      group          = backend.value.group
      balancing_mode = backend.value.balancing_mode
      failover       = backend.value.failover
    }
  }
}

resource "google_compute_forwarding_rule" "default" {
  project = var.project_id
  region  = var.region
  name    = "${var.name}-fr"

  load_balancing_scheme = var.load_balancing_scheme
  backend_service       = google_compute_region_backend_service.default.id
  ip_protocol           = var.protocol
  ip_address            = var.ip_address
  ports                 = var.ports
  all_ports             = var.ports == null ? true : null
  network               = var.load_balancing_scheme == "INTERNAL" ? var.network : null
  subnetwork            = var.load_balancing_scheme == "INTERNAL" ? var.subnetwork : null
}
