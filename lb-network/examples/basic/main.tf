module "lb_network" {
  source = "../.."

  project_id            = var.project_id
  region                = var.region
  name                  = "internal-lb"
  load_balancing_scheme = "INTERNAL"
  network               = var.network_self_link
  subnetwork            = var.subnetwork_self_link

  backends = [{
    group = var.backend_instance_group
  }]
}
