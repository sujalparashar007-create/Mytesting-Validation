module "dns" {
  source = "../.."

  project_id = var.project_id

  zones = {
    "internal-example-com" = {
      dns_name = "internal.example.com."
      networks = [var.network_self_link]
    }
  }

  record_sets = {
    "app-a-record" = {
      zone_key = "internal-example-com"
      name     = "app.internal.example.com."
      type     = "A"
      rrdatas  = ["10.0.0.10"]
    }
  }
}
