# Basic example

Creates a Cloud Router with default (DEFAULT) BGP advertisement on an
existing VPC network.

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
| project_id | Project ID where the example router is created. | `string` | yes |
| region | Region for the example router. | `string` | no (default `us-central1`) |
| network_self_link | Self link of an existing VPC network. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| router_self_link | Self link of the created Cloud Router. |
