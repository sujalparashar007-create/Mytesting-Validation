module "firewall" {
  source = "../.."

  project_id        = var.project_id
  network_self_link = var.network_self_link

  firewall_rules = {
    "allow-iap-ingress" = {
      source_ranges = ["35.235.240.0/20"]
      allow = [{
        protocol = "tcp"
        ports    = ["22", "3389"]
      }]
    }
  }
}
