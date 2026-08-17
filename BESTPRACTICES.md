# Terraform Module Best Practices

Guidelines for writing Terraform modules in this repository. This is a GCP
landing zone starter pack - modules here get reused across customer
engagements, so consistency and readability matter more than cleverness.

## Simplicity over cleverness

- Prefer simple, explicit code over compact, clever code. A module that's a
  bit repetitive but easy to read beats one that's short but hard to follow.
- Duplicate or redundant blocks are fine. Don't introduce an abstraction just
  to avoid repeating a few lines.
- Avoid complex loops. `for_each`/`count` over a flat list or map is fine.
  Nested loops (a `for_each` producing another `for_each`, or deeply nested
  `for` expressions) are not - if you need one, restructure the input data
  instead of nesting the logic.
- Avoid deep conditional nesting (`try()` wrapped in `try()`, multi-level
  `? :`). One level of conditional logic is usually enough; if you need more,
  the variable design is probably wrong.
- Don't build a feature "because it might be needed later." Add flexibility
  when a real use case needs it, not speculatively.

## Naming

- Resource and module block names must be descriptive and state what the
  resource *is*, not restate its type.
  - Good: `resource "google_compute_network" "landing_zone_vpc"`
  - Avoid: `resource "google_compute_network" "this"` /
    `resource "google_compute_network" "vpc1"`
- Variable and output names should read naturally in context:
  `var.network_name`, not `var.name` inside a networking module where "name"
  is ambiguous.
- Be consistent within a module - don't mix `snake_case` and abbreviations
  arbitrarily (`svc_acct` in one place, `service_account` in another).
- Prefix booleans clearly: `enable_*`, `create_*`, `is_*`.

## Module structure

- Standard file layout: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`,
  `README.md`. Split `main.tf` into topic files (`iam.tf`, `network.tf`) once
  it gets long - don't force everything into one file.
- One module = one clear responsibility. If a module is doing IAM, networking,
  and logging all at once, split it.
- No hardcoded values that vary by environment or customer - those belong in
  variables with sensible defaults, not baked into resource blocks.

## Flexibility without over-engineering

- A module should be flexible enough to be reused across customers/projects
  without editing its code - that's the whole point of a module. Flexibility
  means exposing the right variables, not exposing every possible attribute
  as a variable "just in case."
- Use `optional()` attributes with defaults in object-type variables so
  callers only need to set what they care about.
- Every variable needs a `description`. Every variable that can reasonably
  have a safe default should have one - don't force callers to specify
  values that rarely change.

## Variables and outputs

- Use `type` on every variable - no untyped variables.
- Validate inputs with `validation` blocks where a bad value would fail late
  or unclearly otherwise (e.g. a region string, a CIDR range).
- Output the values downstream modules or stages will actually need
  (IDs, self-links, emails) - not the entire resource object.
- Mark sensitive outputs (`sensitive = true`) - service account keys, secrets,
  connection strings.

## IAM and security

- Follow least privilege: grant the narrowest role that accomplishes the
  task, scoped to the narrowest resource level (prefer project/resource-level
  bindings over org-level where possible).
- Prefer `google_*_iam_member` for additive, single-principal grants used
  alongside other automation. Use `google_*_iam_binding` only when this
  module is meant to fully own the role's membership list. Avoid
  `google_*_iam_policy` (authoritative, replaces the whole policy) unless the
  module is explicitly designed to own the entire IAM policy for that
  resource.
- Never hardcode credentials, keys, or secrets in code or `.tfvars` committed
  to the repo.

## Versioning and providers

- Pin provider version constraints in `versions.tf` (`required_providers`,
  `required_version`) - don't leave them unconstrained.
- Pin module sources to a tag or commit SHA when referencing external
  modules (including this repo's own modules from other repos). Don't
  reference `main`/`master` directly.

## Documentation

- Every module needs a `README.md`: what it does, inputs, outputs, and a
  minimal usage example.
- Comments explain *why*, not *what* - the code already says what a resource
  does; a comment should only exist for a non-obvious constraint or reason
  (e.g. "must be created before X due to eventual consistency").

## Testing before merge

- Run `terraform fmt` and `terraform validate` before opening a PR.
- Run `terraform plan` against a real or sandbox project and review the
  diff - don't merge on `validate` passing alone.
