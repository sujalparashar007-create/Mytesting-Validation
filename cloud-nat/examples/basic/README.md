# Basic example

Creates one Cloud NAT gateway (default settings: auto-allocated IPs, all
subnetworks) attached to an existing Cloud Router.

## Usage

```bash
terraform init
terraform plan \
  -var="project_id=<your-project-id>" \
  -var="router_name=<name of an existing Cloud Router>"
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| project_id | Project ID where the example NAT gateway is created. | `string` | yes |
| router_name | Name of an existing Cloud Router. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| nat_ids | Map of NAT name to resource ID. |
