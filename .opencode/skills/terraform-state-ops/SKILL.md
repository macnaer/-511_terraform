---
name: terraform-state-ops
description: Terraform state operations — inspect state, reconcile resources missing from state, targeted recovery with -target, manual state rm, importing existing AWS resources, and handling drift. Use when state and reality diverge or a resource must be re-linked.
---

# Terraform State Operations

Always inspect before mutating. Never edit `terraform.tfstate` by hand.

## Inspect

```powershell
terraform state list
terraform state show <ADDRESS>
terraform plan -detailed-exitcode    # 0 = clean, 2 = drift/changes, 1 = error
```

Resource addresses look like:
`module.demo_server.aws_security_group_rule.ingress["ssh"]`
(for_each keys are in brackets; count would be `[0]`)

## Resource exists in AWS but not in state

```powershell
terraform import "module.demo_server.aws_instance.this" "i-0abc1234"
```

Then run `terraform plan` — any diff means config/actual mismatch; resolve
before apply.

## Resource in state but deleted outside Terraform

```powershell
terraform state rm "module.demo_server.aws_instance.this"
```

Plan will then show it as "will be created".

## Partial failures with `-target`

A failed `-target` apply may leave some resources created and some missing.

1. `terraform state list` — see what was saved.
2. AWS CLI — see what actually exists (see `terraform-aws-debugging`).
3. Reconcile: `import` orphans, `state rm` stale entries.
4. Finish with a **full** `terraform plan` (no `-target`) to confirm clean state.

Remember: PowerShell requires quotes — `terraform plan "-target=module.demo_server"`.

## Drift (config ≠ reality)

- `terraform plan` shows it as delete/recreate or in-place update.
- Prefer letting Terraform converge: show the user the plan, get approval.
- For unwanted manual changes: decide whether config or reality is source of
  truth — never silently force `-replace`.

## Hard rules

- No `apply`/`destroy`/`state rm`/`import` without user confirmation.
- Backups exist as `terraform.tfstate.backup` (gitignored) — don't delete.
- Don't run `terraform apply -refresh-only` or `-auto-approve` unprompted.
