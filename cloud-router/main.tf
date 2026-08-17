resource "google_compute_router" "router" {
  project     = var.project_id
  region      = var.region
  name        = var.name
  network     = var.network
  description = var.description

  bgp {
    asn                = var.asn
    advertise_mode     = var.advertise_mode
    advertised_groups  = var.advertise_mode == "CUSTOM" ? var.advertised_groups : null
    keepalive_interval = var.keepalive_interval

    dynamic "advertised_ip_ranges" {
      for_each = var.advertise_mode == "CUSTOM" ? var.advertised_ip_ranges : []
      content {
        range       = advertised_ip_ranges.value.range
        description = advertised_ip_ranges.value.description
      }
    }
  }
}

resource "google_compute_router_interface" "interfaces" {
  for_each = var.interfaces

  project             = var.project_id
  region              = var.region
  router              = google_compute_router.router.name
  name                = each.key
  ip_range            = each.value.ip_range
  vpn_tunnel          = each.value.vpn_tunnel
  subnetwork          = each.value.subnetwork
  private_ip_address  = each.value.private_ip_address
  redundant_interface = each.value.redundant_interface
}

resource "google_compute_router_peer" "peers" {
  for_each = var.peers

  project           = var.project_id
  region            = var.region
  router            = google_compute_router.router.name
  name              = each.key
  interface         = each.value.interface
  peer_ip_address   = each.value.peer_ip_address
  peer_asn          = each.value.peer_asn
  advertise_mode    = each.value.advertise_mode
  advertised_groups = each.value.advertise_mode == "CUSTOM" ? each.value.advertised_groups : null
  enable            = each.value.enable

  dynamic "advertised_ip_ranges" {
    for_each = each.value.advertise_mode == "CUSTOM" ? each.value.advertised_ip_ranges : []
    content {
      range       = advertised_ip_ranges.value.range
      description = advertised_ip_ranges.value.description
    }
  }

  depends_on = [google_compute_router_interface.interfaces]
}
