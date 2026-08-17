# vpc

Creates a custom-mode VPC network and its subnets. Does not manage firewall
rules (see `../firewall`) or Shared VPC host/service attachment (see
`../shared-vpc`) - this module's only responsibility is the network and its
subnets.

## Usage

See `examples/basic/` for a complete, runnable example. Minimal shape:

```hcl
module "vpc" {
  source = "../vpc"

  project_id   = "my-landing-zone-prod"
  network_name = "landing-zone-vpc"

  subnets = {
    "landing-zone-subnet-usc1" = {
      region            = "us-central1"
      ip_cidr_range     = "10.0.0.0/22"
      flow_logs_enabled = true
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| project_id | Project ID where the VPC network and subnets are created. | `string` | n/a | yes |
| network_name | Name of the VPC network. | `string` | n/a | yes |
| routing_mode | Network-wide routing mode, `REGIONAL` or `GLOBAL`. | `string` | `"REGIONAL"` | no |
| delete_default_routes_on_create | If true, the default internet gateway route is not created. | `bool` | `false` | no |
| subnets | Map of subnets to create, keyed by a descriptive subnet name. | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| network_id | ID of the created VPC network. |
| network_name | Name of the created VPC network. |
| network_self_link | Self link of the created VPC network. |
| subnet_self_links | Map of subnet name to self link. |
| subnet_ids | Map of subnet name to subnet ID. |
