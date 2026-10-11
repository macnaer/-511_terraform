---
name: terraform-module-authoring
description: Conventions for writing or modifying Terraform modules and variables in this repo — HCL style, typed and described variables, secrets handling, count pattern, user_data with IMDSv2, root volume, tagging, for_each. Use when creating new .tf resources, modules, or editing existing ones.
---

# Terraform Module Authoring

> The agent never executes Terraform — the engineer runs all `terraform`
> commands. Hand over the verification commands at the end.

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

## Multiple instances: `count`

```hcl
variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

resource "aws_instance" "this" {
  count = var.instance_count
  # ...
  tags = merge({ Name = "${var.instance_name}-${count.index + 1}" }, var.tags)
}
```

Outputs become lists: `aws_instance.this[*].id`.
Resource addresses gain an index: `aws_instance.this[0]`.

## `user_data` with IMDSv2

When `http_tokens = "required"`, metadata calls need a token — plain curl
returns 401:

```hcl
user_data = <<-EOT
  #!/bin/bash
  apt-get update -y
  apt-get install -y apache2
  systemctl enable --now apache2
  TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
  echo "<h1>Hello from $(hostname) - $PUBLIC_IP</h1>" > /var/www/html/index.html
EOT

user_data_replace_on_change = true
```

Without `user_data_replace_on_change = true`, user_data edits do NOT apply
to existing instances.

## Module inputs/outputs

- Inputs validated with `default` only for non-secret, stable values.
- Outputs: anything another module or the user needs (`id`, `ip`, `arn`).
- Root `outputs.tf` re-exports: `value = module.<name>.<output>`.

## Checklist before finishing

1. No secrets introduced, no existing functionality weakened
2. Ask the engineer to run:

```powershell
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

3. Ask user to confirm the plan before the engineer applies
