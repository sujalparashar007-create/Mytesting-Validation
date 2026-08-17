# lb-network

Creates a regional passthrough Network Load Balancer (`load_balancing_scheme
= "EXTERNAL"`) or Internal Load Balancer (`"INTERNAL"`): regional health
check, regional backend service, and forwarding rule.

Separate from `../lb-http` (HTTP(S) load balancing), since ALB and NLB use
entirely different GCP resource sets (target proxy + URL map vs. a bare
backend service + forwarding rule). Health checks live inside this module
rather than as a standalone one, since a health check has no independent
purpose outside a backend service.

## Usage

See `examples/basic/` for a complete, runnable example. Minimal shape
(internal passthrough LB):

```hcl
module "lb_network" {
  source = "../lb-network"

  project_id             = "my-project"
  region                 = "us-central1"
  name                    = "internal-lb"
  load_balancing_scheme  = "INTERNAL"
  network                 = module.vpc.network_self_link
  subnetwork              = module.vpc.subnet_self_links["app-subnet"]

  backends = [{
    group = google_compute_instance_group_manager.app.instance_group
  }]
}
```

External passthrough NLB: set `load_balancing_scheme = "EXTERNAL"` and omit
`network`/`subnetwork`.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| project_id | Project ID where resources are created. | `string` | n/a | yes |
| region | Region for the load balancer resources. | `string` | n/a | yes |
| name | Base name used for all created resources. | `string` | n/a | yes |
| load_balancing_scheme | `EXTERNAL` or `INTERNAL`. | `string` | n/a | yes |
| network | VPC network; required when `load_balancing_scheme = "INTERNAL"`. | `string` | `null` | no |
| subnetwork | Subnetwork; required when `load_balancing_scheme = "INTERNAL"`. | `string` | `null` | no |
| protocol | `TCP` or `UDP`. | `string` | `"TCP"` | no |
| ports | Ports to forward; `null` forwards all ports (INTERNAL only). | `list(string)` | `null` | no |
| ip_address | Self link of a reserved static IP; `null` uses an ephemeral IP. | `string` | `null` | no |
| health_check | Health check configuration. | `object` | TCP on port 80 | no |
| backends | Backends (instance groups/NEGs) for the backend service. | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|---|---|
| backend_service_id | ID of the backend service. |
| forwarding_rule_ip_address | IP address the load balancer is reachable on. |
| health_check_id | ID of the health check. |
