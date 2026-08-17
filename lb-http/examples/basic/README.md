# Basic example

Creates an HTTP (port 80) global load balancer fronting one existing managed
instance group, with default health check settings.

## Usage

```bash
terraform init
terraform plan \
  -var="project_id=<your-project-id>" \
  -var="backend_instance_group=<self link of an existing MIG>"
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| project_id | Project ID where the example load balancer is created. | `string` | yes |
| backend_instance_group | Self link of an existing managed instance group. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| forwarding_rule_ip_address | IP address the load balancer is reachable on. |
