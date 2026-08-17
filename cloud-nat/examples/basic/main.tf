module "cloud_nat" {
  source = "../.."

  project_id = var.project_id

  nats = {
    "us-central1-nat" = {
      router = var.router_name
      region = "us-central1"
    }
  }
}
