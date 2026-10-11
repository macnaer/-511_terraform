---
name: terraform-aws-debugging
description: Diagnose Terraform AWS failures — invalid credentials (InvalidClientTokenId), missing AMI ("empty result" errors), key pair issues, orphaned resources not in state, and partial applies after -target failures. Use when terraform plan/apply fails or infrastructure state looks wrong.
---

# Terraform AWS Debugging

> The agent never executes Terraform — `terraform ...` commands below are
> prepared for the engineer. AWS CLI (read-only) may be used by the agent.

## Triage order

1. Read the exact Terraform error (last 20–30 lines).
2. Check what actually exists in AWS with AWS CLI (see below).
3. Compare with `terraform state list`.

Credentials for CLI come from `secrets.auto.tfvars` — see
`terraform-workflow` skill for the PowerShell snippet.

## Common errors

### `InvalidClientTokenId` (403 from STS)
Access key invalid or revoked. Check `secrets.auto.tfvars` still contains
placeholder values (`YOUR_ACCESS_KEY`) or the key was rotated/deleted in IAM.
Fix: paste a valid key pair. Never debug deeper before verifying this.

### `Error: collecting instance settings: empty result`
Usually means the AMI does not exist in the target region — AWS returns an
empty image list instead of a clear error. Verify:

```powershell
aws ec2 describe-images --image-ids ami-XXXX --region eu-north-1
# -> {"Images": []}  => AMI missing
```

Find a current AMI (Canonical owner for Ubuntu):

```powershell
aws ec2 describe-images --owners 099720109477 `
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" `
            "Name=state,Values=available" `
  --query "sort_by(Images,&CreationDate)[-1].[ImageId,Name]" --output text
```

### `InvalidKeyPair.NotFound`
`aws ec2 describe-key-pairs --query "KeyPairs[].KeyName"` — fix `aws_key_name`.

### Resource failed but is not in state
Creation may have died before the state save. Check for orphans:

```powershell
aws ec2 describe-instances `
  --filters "Name=instance-state-name,Values=pending,running,stopping,stopped" `
  --query "Reservations[].Instances[].[InstanceId,State.Name]" --output text
```

- Orphan found + not in state → either `terraform import` it or terminate it
  manually before retrying (avoid double billing).
- Nothing found → state is clean; safe to re-run `apply`.

### `Error: Invalid target "module..."`
PowerShell split the flag. Quote it: `terraform plan "-target=module.demo_server"`

### "Applied changes may be incomplete" (after `-target`)
Expected. Run a full `terraform plan` afterwards to verify nothing else pending.

## Useful inspection commands

```powershell
terraform state list
terraform state show module.demo_server.aws_instance.this
terraform plan -detailed-exitcode   # 0 = no changes, 2 = changes pending
terraform validate
```
