# Terraform IAC — Neal Street Tech Demo

## Structure

```
environments/
  common.tfvars          # shared values across all environments
  dev/                   # mvp environment (calls stacks/nst-aws)

stacks/
  nst-aws/        # reusable stack: wiring of all modules

modules/
  aws-nst-*/              # internal reusable modules
```

## Adding an environment

1. Copy `environments/dev/` to `environments/<env>/`
2. Update `backend.tf` with the new workspace name
3. Update `<env>.auto.tfvars` with environment-specific values

## Terraform CI

Pull request → Vulnerability scan → TF Linting → TF fmt → plan + PR comment. Merge to main → apply.
