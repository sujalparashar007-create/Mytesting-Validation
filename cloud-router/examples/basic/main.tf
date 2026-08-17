module "cloud_router" {
  source = "../.."

  project_id = var.project_id
  region     = var.region
  network    = var.network_self_link
  name       = "landing-zone-router"
  asn        = 64514
}
