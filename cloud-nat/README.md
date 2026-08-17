# cloud-nat

Creates Cloud NAT gateways, keyed by name, each attached to an existing
Cloud Router in a given region (see `../cloud-router`). Supports one or more
NAT gateways per call, so a single instance of this module can cover
multiple regions/projects if you don't need per-region state isolation.

## Usage

See `examples/basic/` for a complete, runnable example. Minimal shape:

```hcl
module "cloud_nat" {
  source = "../cloud-nat"

  project_id = "my-project"

  nats = {
    "us-central1-nat" = {
      router = module.cloud_router.router_name
      region = "us-central1"
    }
  }
}
```

### Static IPs and per-subnet scoping

```hcl
nats = {
  "restricted-nat" = {
    router                             = module.cloud_router.router_name
    region                             = "us-central1"
    nat_ip_allocate_option              = "MANUAL_ONLY"
    nat_ips                             = [google_compute_address.nat_ip.self_link]
    source_subnetwork_ip_ranges_to_nat  = "LIST_OF_SUBNETWORKS"
    subnetworks = [{
      name = "projects/my-project/regions/us-central1/subnetworks/restricted-subnet"
    }]
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| project_id | Project ID where the NAT gateways are created. | `string` | n/a | yes |
| nats | Map of NAT gateways to create, keyed by a descriptive NAT name. | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| nat_ids | Map of NAT name to resource ID. |
