output "nat_ids" {
  description = "Map of NAT name to resource ID."
  value = {
    for name, nat in google_compute_router_nat.nat :
    name => nat.id
  }
}
