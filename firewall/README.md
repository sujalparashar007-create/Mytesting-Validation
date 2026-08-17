# firewall

Creates firewall rules on an existing VPC network. Does not create the
network itself (see `../vpc`) - kept separate because firewall rules change
far more often than the network, and are often reviewed/owned by a security
team independently of networking changes.

## Usage

See `examples/basic/` for a complete, runnable example. Minimal shape:

```hcl
module "firewall" {
  source = "../firewall"

  project_id        = "my-landing-zone-prod"
  network_self_link = module.vpc.network_self_link

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
| project_id | Project ID where the firewall rules are created. | `string` | n/a | yes |
| network_self_link | Self link of the VPC network the rules apply to. | `string` | n/a | yes |
| firewall_rules | Map of firewall rules to create, keyed by a descriptive rule name. | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| firewall_rule_ids | Map of firewall rule name to resource ID. |
| firewall_rule_self_links | Map of firewall rule name to self link. |
