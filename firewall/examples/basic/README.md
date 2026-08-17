# Basic example

Calls `firewall` to create one ingress rule allowing SSH/RDP from Google's
Identity-Aware Proxy range, on an existing VPC network.

## Usage

```bash
terraform init
terraform plan \
  -var="project_id=<your-project-id>" \
  -var="network_self_link=<self link of an existing VPC, e.g. from the vpc module>"
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| project_id | Project ID where the example firewall rules are created. | `string` | yes |
| network_self_link | Self link of an existing VPC network. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| firewall_rule_self_links | Map of firewall rule name to self link. |
