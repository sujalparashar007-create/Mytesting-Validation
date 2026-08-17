# Basic example

Calls `shared-vpc` to enable a host project, attach one service project, and
grant `roles/compute.networkUser` to one group on that service project.

## Usage

```bash
terraform init
terraform plan \
  -var="host_project_id=<your-host-project-id>" \
  -var="service_project_id=<your-service-project-id>"
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| host_project_id | Project ID to enable as the Shared VPC host project. | `string` | yes |
| service_project_id | Project ID to attach as a Shared VPC service project. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| host_project_id | Project ID of the Shared VPC host project. |
| service_project_ids | Set of project IDs attached as Shared VPC service projects. |
