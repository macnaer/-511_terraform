---
name: terraform-module-authoring
description: Conventions for writing or modifying Terraform modules and variables in this repo — HCL style, typed and described variables, secrets handling, root volume, IMDSv2, tagging, for_each patterns. Use when creating new .tf resources, modules, or editing existing ones.
---

# Terraform Module Authoring

## Project layout

```
main.tf            # terraform block + provider + module calls
variables.tf       # root inputs (secrets: sensitive, NO defaults)
outputs.tf         # root outputs, re-exported from modules
modules/<name>/    # one cohesive module per concern
  main.tf
  variables.tf
  outputs.tf
```

## Non-negotiables

- Every resource, variable, output, module: `description`.
- Typed variables only: `type = string/number/bool/map/list/object`.
- Secrets: `sensitive = true`, never a `default`, never logged.
- Pin providers with `~>`: `version = "~> 6.0"`.
- All resources tagged via shared `var.tags` (`ManagedBy = "Terraform"`).
- Root volume: `root_block_device` (NOT `ebs_block_device`).
- IMDSv2 enforced:
  ```hcl
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  ```

## Style

- Two-space indent, aligned `=` inside argument blocks.
- No comments unless asked.
- Prefer `merge()` + `for_each` over duplicated blocks:

```hcl
resource "aws_security_group_rule" "ingress" {
  for_each = var.ingress_rules
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
  security_group_id = aws_security_group.this.id
}
```

- Optional object attrs: `optional(type, default)` in `map(object({...}))`.

## Module inputs/outputs

- Inputs validated with `default` only for non-secret, stable values.
- Outputs: anything another module or the user needs (`id`, `ip`, `arn`).
- Root `outputs.tf` re-exports: `value = module.<name>.<output>`.

## Checklist before finishing

1. `terraform fmt -recursive`
2. `terraform validate`
3. No secrets introduced, no existing functionality weakened
4. Ask user to confirm before `apply`
