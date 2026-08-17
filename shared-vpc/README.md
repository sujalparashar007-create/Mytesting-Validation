# shared-vpc

Enables a host project for Shared VPC, attaches service projects to it, and
grants `roles/compute.networkUser` to the principals that need to use the
shared network's subnets from each service project. Does not create the VPC
network or subnets themselves (see `../vpc`) - a customer that doesn't use
Shared VPC shouldn't need this module at all.

## Usage

See `examples/basic/` for a complete, runnable example. Minimal shape:

```hcl
module "shared_vpc" {
  source = "../shared-vpc"

  host_project_id     = "my-landing-zone-host"
  service_project_ids = ["my-app-a-prod", "my-app-b-prod"]

  service_project_network_users = {
    "my-app-a-prod" = ["group:app-a-admins@example.com"]
    "my-app-b-prod" = ["group:app-b-admins@example.com"]
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| host_project_id | Project ID to enable as the Shared VPC host project. | `string` | n/a | yes |
| service_project_ids | Set of project IDs to attach as Shared VPC service projects. | `set(string)` | `[]` | no |
| service_project_network_users | Map of service project ID to the list of IAM principals that get `roles/compute.networkUser` on that project. | `map(list(string))` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| host_project_id | Project ID of the Shared VPC host project. |
| service_project_ids | Set of project IDs attached as Shared VPC service projects. |
