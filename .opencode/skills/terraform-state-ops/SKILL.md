---
name: terraform-state-ops
description: Terraform state operations — reconcile resources missing from state, targeted recovery with -target, manual state rm, importing existing AWS resources, and handling drift. Use when state and reality diverge or a resource must be re-linked.
---

# Terraform State Operations

> The agent never executes Terraform — every command below is prepared for
> the engineer to run. The agent may use read-only AWS CLI calls to inspect
> what actually exists.

Always inspect before mutating. Never edit `terraform.tfstate` by hand.

## Resource addresses with `count`

With `count = var.instance_count`, addresses carry an index:

```
module.demo_server.aws_instance.this[0]
module.demo_server.aws_instance.this[1]
```

for_each keys are in brackets too: `aws_security_group_rule.ingress["ssh"]`.

## Inspect (engineer runs)

```powershell
terraform state list
terraform state show "module.demo_server.aws_instance.this[0]"
terraform plan -detailed-exitcode    # 0 = clean, 2 = drift/changes, 1 = error
```

## Resource exists in AWS but not in state

```powershell
terraform import "module.demo_server.aws_instance.this[0]" "i-0abc1234"
```

Then `terraform plan` — any diff means config/actual mismatch; resolve
before apply.

## Resource in state but deleted outside Terraform

```powershell
terraform state rm "module.demo_server.aws_instance.this[0]"
```

Plan will then show it as "will be created".

## Migrating a single instance into a count slot

Adding `count` turns `aws_instance.this` into `aws_instance.this[0]`.
To keep an existing instance (avoid recreate):

```powershell
terraform state mv 'module.demo_server.aws_instance.this' 'module.demo_server.aws_instance.this[0]'
```

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

- The agent runs NO terraform commands; the engineer executes every command.
- No `apply`/`destroy`/`state rm`/`import` without user confirmation.
- Backups exist as `terraform.tfstate.backup` (gitignored) — don't delete.
- Don't advise `terraform apply -refresh-only` or `-auto-approve` unprompted.
