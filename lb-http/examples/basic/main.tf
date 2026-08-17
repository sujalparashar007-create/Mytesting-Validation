module "lb_http" {
  source = "../.."

  project_id = var.project_id
  name       = "app-lb"

  backends = [{
    group = var.backend_instance_group
  }]
}
