---
name: terraform-workflow
description: Standard Terraform change workflow for this AWS repo — how to prepare changes, hand commands to the engineer, secrets handling via secrets.auto.tfvars, and PowerShell command quirks. Use when making any change to .tf files or advising on plan/apply.
---

# Terraform Workflow

## Golden rule

**The agent NEVER executes Terraform.** Every `terraform` command (`init`,
`fmt`, `validate`, `plan`, `apply`, `destroy`, `state`, ...) is run manually
by the engineer. The agent writes/analyzes code and provides the exact
commands, ready to copy-paste.

AWS CLI diagnostics (`aws ec2 describe-...`) do not modify infrastructure
and may be used by the agent to inspect reality.

## Standard cycle (executed by the engineer)

```powershell
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply     # only after explicit approval of the plan
```

Never advise `apply` or `destroy` without the user first approving the plan.

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

## After making changes

1. Hand the engineer these commands and ask them to run:

```powershell
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

2. Ask the engineer to report the plan output; analyze it for unexpected
   replacements/drift before advising `apply`.
3. Report what changed and remaining risks in 3–5 lines.
