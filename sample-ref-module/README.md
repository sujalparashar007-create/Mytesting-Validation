# sample-ref-module

Creates a custom-mode VPC network with a set of subnets and ingress firewall
rules. Reference module - its structure and conventions are what every module
in this repo should follow. See `../BESTPRACTICES.md` and `../AGENTS.md` for
the reasoning behind these choices.

## What this module does

- One VPC network (`google_compute_network`).
- Zero or more subnets, each keyed by a descriptive name (`google_compute_subnetwork`).
- Zero or more firewall rules, each keyed by a descriptive name (`google_compute_firewall`).

Nothing nested beyond one `for_each` per resource - no loops inside loops.

## Usage

See `examples/basic/` for a complete, runnable example. Minimal shape:

```hcl
module "network" {
  source = "../sample-ref-module"

  project_id   = "my-landing-zone-prod"
  network_name = "landing-zone-vpc"

  subnets = {
    "landing-zone-subnet-usc1" = {
      region        = "us-central1"
      ip_cidr_range = "10.0.0.0/22"
      flow_logs_enabled = true
    }
  }

  firewall_rules = {
    "allow-iap-ingress" = {
      source_ranges = ["35.235.240.0/20"]
      allow = [{
        protocol = "tcp"
        ports    = ["22", "3389"]
      }]
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
| subnets | Map of subnets to create, keyed by a descriptive subnet name. | `map(object)` | `{}` | no |
| firewall_rules | Map of ingress firewall rules to create, keyed by a descriptive rule name. | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| network_id | ID of the created VPC network. |
| network_self_link | Self link of the created VPC network. |
| subnet_self_links | Map of subnet name to self link. |
| subnet_ids | Map of subnet name to subnet ID. |
