# Basic example

Calls `sample-ref-module` to create one VPC network, one subnet, and one
firewall rule allowing SSH/RDP from Google's Identity-Aware Proxy range.

## Usage

```bash
terraform init
terraform plan -var="project_id=<your-project-id>"
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| project_id | Project ID where the example network is created. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| network_id | ID of the created VPC network. |
| subnet_self_links | Map of subnet name to self link. |
