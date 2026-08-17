# AHEAD-GCP-Landing-Zone-Starter-Pack
Terraform starter pack for building a secure, scalable, and maintainable Google Cloud landing zone with core modules for hierarchy, governance, IAM, networking, logging, monitoring, and cost management.

## Contributing / AI agents

See `AGENTS.md` and `BESTPRACTICES.md` before creating or editing a module.
`sample-ref-module/` is a working reference implementation of those
conventions.

## Modules

| Module | Responsibility |
|---|---|
| `sample-ref-module` | Reference implementation only - not for real use. |
| `vpc` | VPC network and subnets. |
| `firewall` | Firewall rules on an existing VPC network. |
| `shared-vpc` | Shared VPC host/service project attachment and network-user IAM. |
| `org-policies` | Organization policy constraints (built-in and custom), with per-project/folder exceptions. |
| `resource-hierarchy` | GCP folders, projects, and per-project API enablement (no IAM, no org creation). |
| `cloud-router` | Cloud Router with BGP configuration, interfaces, and peers. |
| `cloud-nat` | Cloud NAT gateways attached to an existing Cloud Router. |
| `lb-http` | Global external HTTP(S) Application Load Balancer. |
| `lb-network` | Regional passthrough Network Load Balancer (external or internal). |
| `dns` | Private Cloud DNS zones (standard, forwarding, or peering) and record sets. |
| `alerting` | Cloud Monitoring notification channels and alert policies. |
| `log-retention` | Cloud Logging sinks and log buckets with retention/CMEK, at project, folder, or org scope. |
| `logging-monitoring-samples` | Sample log-based metrics and dashboards; reference for wiring `alerting` + `log-retention` together. |
| `finops-dataset` | BigQuery dataset for FinOps reporting, plus a gated view factory. |
| `finops-budgets` | GCP billing budgets with Pub/Sub alert wiring and IAM viewer grants. |
| `finops-alerts` | Pub/Sub topic and email notification channels for budget alerts. |
| `finops-function` | Cloud Function (2nd gen) that processes budget alerts from Pub/Sub. |
