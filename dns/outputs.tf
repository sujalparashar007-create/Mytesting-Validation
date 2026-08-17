output "zone_ids" {
  description = "Map of zone name to resource ID."
  value = {
    for name, zone in google_dns_managed_zone.zones :
    name => zone.id
  }
}

output "zone_name_servers" {
  description = "Map of zone name to its assigned name servers (populated for forwarding/peering verification)."
  value = {
    for name, zone in google_dns_managed_zone.zones :
    name => zone.name_servers
  }
}

output "record_set_ids" {
  description = "Map of record set name to resource ID."
  value = {
    for name, rs in google_dns_record_set.records :
    name => rs.id
  }
}
