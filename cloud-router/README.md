# cloud-router

Creates a Cloud Router with BGP configuration, plus optional interfaces
(for VPN tunnel attachment) and BGP peers. Does not create the VPC network
(see `../vpc`) or Cloud NAT (see `../cloud-nat`, which requires a router
created by this module).

## Usage

See `examples/basic/` for a complete, runnable example. Minimal shape:

```hcl
module "cloud_router" {
  source = "../cloud-router"

  project_id = "my-project"
  region     = "us-central1"
  network    = module.vpc.network_self_link
  name       = "landing-zone-router"
  asn        = 64514
}
```

### Adding a BGP peer over a VPN tunnel

```hcl
module "cloud_router" {
  source = "../cloud-router"
  # ...

  interfaces = {
    "tunnel-0-if" = {
      vpn_tunnel = google_compute_vpn_tunnel.tunnel_0.name
    }
  }

  peers = {
    "on-prem-peer" = {
      interface       = "tunnel-0-if"
      peer_ip_address = "169.254.0.1"
      peer_asn        = 65000
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| project_id | Project ID where the Cloud Router is created. | `string` | n/a | yes |
| region | Region for the Cloud Router. | `string` | n/a | yes |
| name | Name of the Cloud Router. | `string` | n/a | yes |
| network | Self link or name of the VPC network. | `string` | n/a | yes |
| description | Description of the Cloud Router. | `string` | `null` | no |
| asn | Local BGP ASN (private range: 64512-65534 or 4200000000-4294967294). | `number` | n/a | yes |
| advertise_mode | `DEFAULT` (advertise all VPC subnets) or `CUSTOM`. | `string` | `"DEFAULT"` | no |
| advertised_groups | Groups to advertise when `advertise_mode = "CUSTOM"`. | `list(string)` | `[]` | no |
| advertised_ip_ranges | Explicit ranges to advertise when `advertise_mode = "CUSTOM"`. | `list(object)` | `[]` | no |
| keepalive_interval | BGP keepalive interval in seconds (20-60). | `number` | `null` | no |
| interfaces | Router interfaces, keyed by a descriptive name. | `map(object)` | `{}` | no |
| peers | BGP peers, keyed by a descriptive name. | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| router_id | ID of the created Cloud Router. |
| router_name | Name of the created Cloud Router. |
| router_self_link | Self link of the created Cloud Router. |
| interface_names | Set of created interface names. |
