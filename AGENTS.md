# AGENTS.md

Instructions for AI coding agents working in this repository.

## What this repo is

A Terraform starter pack for building a GCP landing zone for a customer:
resource hierarchy, governance, IAM, networking, logging, monitoring, and
cost management modules. Modules here are meant to be reused across customer
engagements - write for the next engineer/agent who picks this up cold, not
just for the current task.

## Before creating or editing a module

1. Read `BESTPRACTICES.md` in this repo root - it's the actual style guide
   (naming, structure, IAM patterns, flexibility vs. over-engineering). Every
   module you create or touch must follow it.
2. Look at `sample-ref-module/` - it's a working reference module that
   applies every rule in `BESTPRACTICES.md` in practice, including an
   `examples/basic/` directory. When in doubt about how something should
   look, match its shape rather than re-deriving it from the prose rules.
3. Check the repo root for an existing module directory covering the same
   or adjacent resource before creating a new one (each module is its own
   top-level directory, e.g. `network/`, `iam/`, `logging/` - not nested
   under a `modules/` folder). Extend an existing module if the resource
   fits its stated responsibility; create a new one if it doesn't.
4. Identify the module's single responsibility before writing any code
   (e.g. "creates a Shared VPC host project and subnets" - not "networking
   and IAM and logging").

## Creating a new module - checklist

- [ ] One clear responsibility, named accordingly, as its own top-level
      directory at the repo root (e.g. `network/`, `iam/`, `logging/`).
- [ ] Standard files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`,
      `README.md`. Split `main.tf` into topic files if it grows large.
- [ ] Every variable has a `type` and a `description`. Add `validation`
      blocks for values that would otherwise fail late or unclearly.
- [ ] Every resource/module block name is descriptive of what it represents,
      not a restatement of its resource type or a placeholder like `this`.
- [ ] No nested loops or multi-level conditional nesting - if the logic
      needs that, restructure the input variable shape instead.
- [ ] IAM bindings scoped to least privilege, at the narrowest resource
      level that makes sense; additive (`_iam_member`) unless the module is
      explicitly meant to own the whole binding list.
- [ ] Provider/module version constraints pinned in `versions.tf`.
- [ ] An `examples/basic/` directory with a small, runnable root module that
      calls this module - not just a code block in the README.
- [ ] `README.md` written: purpose, inputs, outputs, minimal usage example.
- [ ] `terraform fmt` and `terraform validate` run clean.
- [ ] `terraform plan` reviewed against a real or sandbox project - don't
      stop at `validate` passing.

## What "good" looks like here

Simple and a little repetitive beats clever and compact. Duplicate blocks
are acceptable; deeply nested loops or conditionals are not. Flexibility
should come from well-designed variables (with sensible defaults), not from
exposing every possible resource attribute "just in case." See
`BESTPRACTICES.md` for the full reasoning behind each of these.

## Commit and PR expectations

- Don't commit `.tfvars` files containing real customer values, credentials,
  or secrets.
- Keep commits scoped to one module or one logical change.
- Don't reference `main`/`master` for any module source - pin to a tag or
  commit SHA.
