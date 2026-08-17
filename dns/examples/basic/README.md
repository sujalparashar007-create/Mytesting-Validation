# Basic example

Creates one private DNS zone bound to an existing VPC network, with a single
A record.

## Usage

```bash
terraform init
terraform plan \
  -var="project_id=<your-project-id>" \
  -var="network_self_link=<self link of an existing VPC>"
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| project_id | Project ID where the example DNS zone is created. | `string` | yes |
| network_self_link | Self link of an existing VPC network. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| zone_ids | Map of zone name to resource ID. |
