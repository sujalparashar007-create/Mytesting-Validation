# org-policies

Applies organization policy constraints (built-in and custom) at the
organization level, with optional per-project/per-folder exceptions. Does not
create folders or projects (see `../vpc`, `../shared-vpc`, and the rest of
your landing zone stages for that) - this module's only responsibility is
policy enforcement.

## Required environment variables

`google_org_policy_policy` calls require a quota project. Without these set,
`terraform plan` succeeds but `apply` fails after confirmation:

```bash
export USER_PROJECT_OVERRIDE=true
export GOOGLE_BILLING_PROJECT=<your-quota-project-id>
```

See the [provider reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#quota-management-configuration).

## Usage

See `examples/basic/` for a complete, runnable example seeded with a curated
set of hardening constraints (pulled from Google's own [Cloud Foundation
Fabric FAST](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric)
reference org-policy set). Minimal shape:

```hcl
module "org_policies" {
  source = "../org-policies"

  org_id = "123456789012"
  folder_target_ids  = ["1234567890"]
  project_target_ids = ["my-project-id"]

  org_constraints = {
    "compute.disableSerialPortAccess" = {
      enforce = "TRUE"
    }
    "compute.trustedImageProjects" = {
      list_constraints = [{
        allowed_values = ["is:projects/debian-cloud", "is:projects/ubuntu-os-cloud"]
      }]
    }
  }

  custom_constraint_policies = {
    "restrict_public_ip" = {
      display_name   = "Restrict Public IP Addresses"
      description    = "Prevents instances from being created with public IP addresses"
      action_type    = "ALLOW"
      condition      = "resource.accessConfigs.exists(ac, ac.natIP == \"\")"
      method_types   = ["CREATE", "UPDATE"]
      resource_types = ["compute.googleapis.com/Instance"]
      enforce        = "TRUE"
    }
  }
}
```

### The `enforce` tri-state

`enforce` on a constraint is a **string**, not a bool: `"TRUE"`, `"FALSE"`, or
left unset. This lets a constraint carry only `list_constraints` (allow/deny
value lists) without also emitting a boolean rule - unset means "no boolean
rule for this constraint," not "false."

### Exceptions

`excluded_project_ids` / `excluded_folder_ids` on a constraint create an
explicit `enforce = "FALSE"` policy at that project/folder, overriding the
org-wide setting for that resource only.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| org_id | The numeric ID of the GCP organization. | `string` | n/a | yes |
| org_constraints | Map of built-in constraints to enforce, keyed by constraint name. | `map(object)` | `{}` | no |
| custom_constraint_policies | Map of custom constraints to create and enforce, keyed by a descriptive name. | `map(object)` | `{}` | no |
| folder_target_ids | Folder IDs where org_constraints should also be applied directly. | `list(string)` | `[]` | no |
| project_target_ids | Project IDs where org_constraints should also be applied directly. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|---|---|
| org_policy_ids | Map of constraint name to the applied org-level policy resource ID. |
| custom_constraint_names | Map of custom constraint key to its full constraint name. |
