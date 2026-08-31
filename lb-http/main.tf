resource "google_compute_health_check" "default" {
  project = var.project_id
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
}

resource "google_compute_backend_service" "default" {
  project = var.project_id
  name    = "${var.name}-backend"

  protocol         = var.protocol
  port_name        = var.port_name
  enable_cdn       = var.enable_cdn
  session_affinity = var.session_affinity
  health_checks    = [google_compute_health_check.default.id]

  dynamic "backend" {
    for_each = var.backends
    content {
      group           = backend.value.group
      balancing_mode  = backend.value.balancing_mode
      capacity_scaler = backend.value.capacity_scaler
      max_utilization = backend.value.max_utilization
    }
  }
}

resource "google_compute_url_map" "default" {
  project         = var.project_id
  name            = "${var.name}-url-map"
  default_service = google_compute_backend_service.default.id

  dynamic "host_rule" {
    for_each = var.host_rules
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher_name
    }
  }

  dynamic "path_matcher" {
    for_each = var.host_rules
    content {
      name            = path_matcher.value.path_matcher_name
      default_service = path_matcher.value.default_service

      dynamic "path_rule" {
        for_each = path_matcher.value.path_rules
        content {
          paths   = path_rule.value.paths
          service = path_rule.value.service
        }
      }
    }
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  count   = length(var.ssl_domains) > 0 ? 1 : 0
  project = var.project_id
  name    = "${var.name}-cert"

  managed {
    domains = var.ssl_domains
  }
}

resource "google_compute_target_http_proxy" "default" {
  count   = length(var.ssl_domains) == 0 ? 1 : 0
  project = var.project_id
  name    = "${var.name}-http-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_target_https_proxy" "default" {
  count            = length(var.ssl_domains) > 0 ? 1 : 0
  project          = var.project_id
  name             = "${var.name}-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default[0].id]
}

resource "google_compute_global_forwarding_rule" "default" {
  project    = var.project_id
  name       = "${var.name}-fr"
  target     = length(var.ssl_domains) > 0 ? google_compute_target_https_proxy.default[0].id : google_compute_target_http_proxy.default[0].id
  port_range = length(var.ssl_domains) > 0 ? "443" : "80"
  ip_address = var.ip_address

  load_balancing_scheme = "EXTERNAL"
}
