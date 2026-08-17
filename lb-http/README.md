# lb-http

Creates a global external HTTP(S) Application Load Balancer: health check,
backend service, URL map, target proxy (HTTP or HTTPS, based on whether
`ssl_domains` is set), and global forwarding rule. Google-managed SSL
certificate is created automatically when `ssl_domains` is non-empty.

Separate from `../lb-network` (network/passthrough load balancing), since
the two use entirely different GCP resource sets. Health checks live inside
this module rather than as a standalone one, since a health check has no
independent purpose outside a backend service.

## Usage

See `examples/basic/` for a complete, runnable example. Minimal shape:

```hcl
module "lb_http" {
  source = "../lb-http"

  project_id = "my-project"
  name       = "app-lb"

  backends = [{
    group = google_compute_instance_group_manager.app.instance_group
  }]
}
```

### HTTPS with a managed certificate

```hcl
module "lb_http" {
  source = "../lb-http"

  project_id  = "my-project"
  name        = "app-lb"
  ssl_domains = ["app.example.com"]

  backends = [{
    group = google_compute_instance_group_manager.app.instance_group
  }]
}
```

### Path-based routing to other backend services

```hcl
host_rules = [{
  hosts             = ["app.example.com"]
  path_matcher_name = "api"
  default_service   = google_compute_backend_service.default.id
  path_rules = [{
    paths   = ["/api/*"]
    service = google_compute_backend_service.api.id
  }]
}]
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| project_id | Project ID where the load balancer resources are created. | `string` | n/a | yes |
| name | Base name used for all created resources. | `string` | n/a | yes |
| protocol | Backend service protocol: `HTTP`, `HTTPS`, or `HTTP2`. | `string` | `"HTTP"` | no |
| port_name | Named port on backend instance groups. | `string` | `"http"` | no |
| enable_cdn | Enable Cloud CDN on the backend service. | `bool` | `false` | no |
| session_affinity | Session affinity mode. | `string` | `"NONE"` | no |
| health_check | Health check configuration. | `object` | HTTP on port 80, path `/` | no |
| backends | Backends (instance groups/NEGs) for the default backend service. | `list(object)` | `[]` | no |
| host_rules | Additional host/path routing rules to other backend services. | `list(object)` | `[]` | no |
| ssl_domains | Domains for a Google-managed SSL cert; non-empty enables HTTPS. | `list(string)` | `[]` | no |
| ip_address | Self link of a reserved static IP; null uses an ephemeral IP. | `string` | `null` | no |

## Outputs

| Name | Description |
|---|---|
| backend_service_id | ID of the default backend service. |
| url_map_id | ID of the URL map. |
| forwarding_rule_ip_address | IP address the load balancer is reachable on. |
| health_check_id | ID of the health check. |
