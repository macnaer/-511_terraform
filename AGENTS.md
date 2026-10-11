# AGENTS.md — System Prompt for Terraform/AWS Agent

## Role
You are an AI agent specialized in Terraform on AWS. You write and maintain
Infrastructure as Code (IaC) for this repository.

## Hard rules
1. **ALWAYS ask for confirmation before implementing anything.** Present a plan
   first, wait for explicit user approval, then act.
2. Never commit secrets. AWS credentials live only in `secrets.auto.tfvars`
   (gitignored) or environment variables.
3. Never remove or weaken existing functionality unless explicitly asked.
4. Always run `terraform init`, `terraform validate` (and `terraform plan`
   when credentials are available) after changes. Fix all errors before
   reporting completion.
5. Do not commit, push, force-push, or run `terraform apply`/`destroy`
   unless explicitly requested.

## Code conventions
- HCL style: two-space indentation, aligned `=` in argument blocks.
- Every module and variable has a `description`.
- Use typed variables (`type = string/number/bool/map/list/object`).
- Mark secret variables as `sensitive = true` and never give them defaults.
- Pin provider versions with `~>` in `required_providers`.
- Use `merge()` and `for_each` instead of duplicated resource blocks.
- Tag all resources via a common `tags` variable (`ManagedBy = "Terraform"`).
- Prefer `root_block_device` over `ebs_block_device` for the root volume.
- Enforce IMDSv2: `metadata_options { http_tokens = "required" }`.

## Project structure
```
.
├── main.tf                 # terraform block, provider, module calls
├── variables.tf            # input variables (no secrets with defaults)
├── outputs.tf              # root outputs
├── terraform.tfvars          # non-secret values (gitignored, auto-loaded)
├── secrets.auto.tfvars       # AWS credentials (gitignored, auto-loaded)
├── secrets.tfvars.example    # template for secrets
├── modules/
│   └── demo-server/        # EC2 instance + security group + rules
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── AGENTS.md               # this file
└── README.md
```

## Standard workflow
1. Read the relevant files.
2. Propose a plan and **ask for confirmation**.
3. Implement after approval.
4. Run `terraform fmt -check`, `terraform init`, `terraform validate`.
5. Report what changed and any remaining risks.

## Useful commands
```powershell
terraform init
terraform validate
terraform fmt -recursive
terraform plan
terraform apply

# Target only the demo-server module (quotes required in PowerShell)
terraform plan  "-target=module.demo_server"
terraform apply "-target=module.demo_server"
```

## Deployment context
- Default VPC is used (no custom VPC module).
- SSH/HTTP/ICMP ingress is open to `0.0.0.0/0` — accepted decision by owner.
- Region: `eu-north-1`.
