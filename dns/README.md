# dns

Creates private Cloud DNS zones (standard, forwarding, or peering) and their
record sets. Does not create the VPC network (see `../vpc`) - pass network
self links in.

## Zone modes

A zone is typically only one of these at a time:

| Mode | Set | Use case |
|---|---|---|
| Standard private zone | `networks` | Authoritative zone resolved by the listed VPCs. |
| Forwarding zone | `forwarding_target_name_servers` | Forward queries for this zone to external/on-prem DNS servers. |
| Peering zone | `peering_network` | Resolve this zone using another VPC's private zones. |

## Usage

See `examples/basic/` for a complete, runnable example. Minimal shape:

```hcl
module "dns" {
  source = "../dns"

  project_id = "my-project"

  zones = {
    "internal-example-com" = {
      dns_name = "internal.example.com."
      networks = [module.vpc.network_self_link]
    }
  }

  record_sets = {
    "app-a-record" = {
      zone_key = "internal-example-com"
      name     = "app.internal.example.com."
      type     = "A"
      rrdatas  = ["10.0.0.10"]
    }
  }
}
```

### Forwarding zone (to on-prem DNS)

```hcl
zones = {
  "corp-example-com" = {
    dns_name = "corp.example.com."
    networks = [module.vpc.network_self_link]
    forwarding_target_name_servers = [
      { ipv4_address = "10.10.0.53" },
    ]
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| project_id | Project ID where the DNS zones are created. | `string` | n/a | yes |
| zones | Map of private DNS zones to create, keyed by zone name. | `map(object)` | `{}` | no |
| record_sets | Map of DNS record sets to create, keyed by a descriptive name. | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| zone_ids | Map of zone name to resource ID. |
| zone_name_servers | Map of zone name to assigned name servers. |
| record_set_ids | Map of record set name to resource ID. |
