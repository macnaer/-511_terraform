# HMP621 — Terraform AWS Demo

Terraform configuration that provisions a single Ubuntu EC2 instance with a
security group in AWS (`eu-north-1`), using the default VPC.

## Structure

```
.
├── main.tf                 # terraform block, provider, module call
├── variables.tf            # input variables (secrets are sensitive)
├── outputs.tf              # instance_id, public_ip, private_ip, sg_id
├── terraform.tfvars          # non-secret values (gitignored, auto-loaded)
├── secrets.auto.tfvars       # AWS credentials (gitignored, auto-loaded, NEVER commit)
├── secrets.tfvars.example    # template for secrets
├── modules/
│   └── demo-server/        # single module: EC2 + security group + rules
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── AGENTS.md               # system prompt for the AI agent
└── README.md
```

## Module `modules/demo-server`

| Resource | Description |
|---|---|
| `aws_instance.this` | Ubuntu EC2, gp3 root volume (20 GB), IMDSv2 required |
| `aws_security_group.this` | `SG_Terraform` |
| `aws_security_group_rule.ingress` | `for_each` rules: SSH 22, HTTP 80, ICMP — all `0.0.0.0/0` |
| `aws_security_group_rule.egress` | all outbound `0.0.0.0/0` |

## Prerequisites

- Terraform >= 1.5.0
- AWS account + access key (create a dedicated IAM user, prefer rotating keys)

## Setup

```powershell
# 1. Create secrets file from template (once)
Copy-Item secrets.tfvars.example secrets.auto.tfvars
# edit secrets.auto.tfvars and put real AWS credentials
# (`.auto.tfvars` is loaded by Terraform automatically - no -var-file needed)

# 2. Adjust non-secret settings if needed
notepad terraform.tfvars

# 3. Init & validate
terraform init
terraform validate
```

## Usage

```powershell
# Full infrastructure
terraform plan
terraform apply

# Only the demo-server module (quotes required in PowerShell)
terraform plan  "-target=module.demo_server"
terraform apply "-target=module.demo_server"
```

## Outputs

After apply you get:

- `instance_id`
- `public_ip`
- `private_ip`
- `security_group_id`

```powershell
terraform output public_ip
```

## Cleanup

```powershell
terraform destroy
```

## Security notes

- **`secrets.auto.tfvars` and `terraform.tfvars` are gitignored.** Never commit
  credentials. Copy `secrets.tfvars.example` to `secrets.auto.tfvars` instead.
- **Rotate the previously exposed access key** — credentials were once
  hardcoded in `vars.tf` and must be considered compromised.
- SSH/HTTP ingress is open to the whole internet (`0.0.0.0/0`) by explicit
  decision. Restrict `ingress_rules` (module input) if tighter access needed.
- IMDSv2 is enforced (`http_tokens = "required"`).

## Customization

| Variable | Default | Purpose |
|---|---|---|
| `aws_region` | `eu-north-1` | AWS region |
| `aws_image_id` | `ami-0d6d8576c5ce37b8a` | AMI |
| `aws_instance_type` | `t3.small` | Instance type |
| `aws_key_name` | `Stockholm_3` | EC2 key pair |
| `root_volume_size` | `20` | Root volume GB |
| `sg_name` | `SG_Terraform` | Security group name |
| `tags` | project tags | Common tags |
