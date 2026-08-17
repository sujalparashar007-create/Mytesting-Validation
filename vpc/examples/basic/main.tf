module "vpc" {
  source = "../.."

  project_id   = var.project_id
  network_name = "landing-zone-vpc"

  subnets = {
    "landing-zone-subnet-usc1" = {
      region            = "us-central1"
      ip_cidr_range     = "10.0.0.0/22"
      flow_logs_enabled = true
    }
  }
}
