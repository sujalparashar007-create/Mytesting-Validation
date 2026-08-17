resource "google_dns_managed_zone" "zones" {
  for_each = var.zones

  project     = var.project_id
  name        = each.key
  dns_name    = each.value.dns_name
  description = each.value.description
  visibility  = "private"
  labels      = each.value.labels

  dynamic "private_visibility_config" {
    for_each = length(each.value.networks) > 0 ? [1] : []
    content {
      dynamic "networks" {
        for_each = each.value.networks
        content {
          network_url = networks.value
        }
      }
    }
  }

  dynamic "forwarding_config" {
    for_each = length(each.value.forwarding_target_name_servers) > 0 ? [1] : []
    content {
      dynamic "target_name_servers" {
        for_each = each.value.forwarding_target_name_servers
        content {
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = target_name_servers.value.forwarding_path
        }
      }
    }
  }

  dynamic "peering_config" {
    for_each = each.value.peering_network == null ? [] : [each.value.peering_network]
    content {
      target_network {
        network_url = peering_config.value
      }
    }
  }
}

resource "google_dns_record_set" "records" {
  for_each = var.record_sets

  project      = var.project_id
  managed_zone = google_dns_managed_zone.zones[each.value.zone_key].name
  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
}
