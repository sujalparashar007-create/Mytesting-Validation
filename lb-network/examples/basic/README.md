# Basic example

Creates an internal passthrough TCP load balancer fronting one existing
managed instance group, forwarding all ports.

## Usage

```bash
terraform init
terraform plan \
  -var="project_id=<your-project-id>" \
  -var="network_self_link=<self link of an existing VPC>" \
  -var="subnetwork_self_link=<self link of an existing subnetwork>" \
  -var="backend_instance_group=<self link of an existing MIG>"
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| project_id | Project ID where the example load balancer is created. | `string` | yes |
| region | Region for the example load balancer. | `string` | no (default `us-central1`) |
| network_self_link | Self link of an existing VPC network. | `string` | yes |
| subnetwork_self_link | Self link of an existing subnetwork. | `string` | yes |
| backend_instance_group | Self link of an existing managed instance group. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| forwarding_rule_ip_address | IP address the load balancer is reachable on. |
