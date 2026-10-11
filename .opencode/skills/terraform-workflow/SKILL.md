---
name: terraform-workflow
description: Standard Terraform change workflow for this AWS repo — fmt, init, validate, plan, apply, secrets handling via secrets.auto.tfvars, and PowerShell command quirks. Use when making any change to .tf files, reviewing a plan, or deploying infrastructure.
---

# Terraform Workflow

## Standard cycle (always in this order)

```powershell
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply     # only after explicit user confirmation of the plan
```

Never run `apply` or `destroy` without showing the user the plan and getting
explicit approval first.

## Secrets

- Credentials live in `secrets.auto.tfvars` (gitignored, auto-loaded).
- Never print, echo, or commit this file. Never add defaults to sensitive
  variables in `variables.tf`.
- `secrets.tfvars.example` is the committed template.

## PowerShell quirks (Windows, PS 5.1)

- Flags with `=` MUST be quoted, otherwise PS splits them:

```powershell
terraform plan  "-target=module.demo_server"    # correct
terraform plan  -target=module.demo_server      # WRONG: 'Invalid target "module"'
```

- To read a credential from `secrets.auto.tfvars` for one AWS CLI call:

```powershell
$t = Get-Content secrets.auto.tfvars -Raw
$env:AWS_ACCESS_KEY_ID     = ([regex]::Match($t,'aws_access_key\s*=\s*"([^"]+)"')).Groups[1].Value
$env:AWS_SECRET_ACCESS_KEY = ([regex]::Match($t,'aws_secret_key\s*=\s*"([^"]+)"')).Groups[1].Value
$env:AWS_DEFAULT_REGION    = "eu-north-1"
aws ec2 describe-instances
```

Never persist these env vars across commands; set them per invocation.

## Git rules

- `*.tfvars` is gitignored (incl. `terraform.tfvars`). Only `*.tfvars.example`
  is committed.
- Commit and push only when the user explicitly asks.
- Before committing: `git status` + `git diff` — verify no secrets staged.

## After changes

1. `terraform fmt -check -recursive` must pass silently.
2. `terraform validate` must succeed.
3. `terraform plan` when credentials are available — report drift if any.
4. Report what changed and remaining risks in 3–5 lines.
