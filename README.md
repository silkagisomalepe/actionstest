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

Pull request → Vulnerability scan → TF Linting → TF fmt → plan + PR comment. Merge to main → manual approval → apply.

## Running locally

### Prerequisites

- Terraform >= 1.10
- Ansible + `ansible-lint` (`pip install ansible ansible-lint yamllint`)
- AWS CLI, authenticated to the target account
- `gh` CLI (for `scripts/create-github-secrets.sh`)
- `jq`

### Terraform

```bash
cd environments/dev
terraform init
terraform validate
terraform plan -var-file=dev.auto.tfvars -var-file=../common.tfvars
```

Repeat from `stacks/aws-rewards` or `stacks/aws-baseline` directly if you only need to validate/plan a single stack — each has its own `versions.tf` and can be initialized independently with `-backend=false`.

### Ansible

```bash
cd ansible
yamllint playbooks/ roles/
ansible-lint playbooks/ roles/
ansible-playbook playbooks/site.yml --syntax-check
```

Role resolution is handled by `ansible/ansible.cfg` (`roles_path = ./roles`), so these commands must be run with `ansible/` as the working directory. `.ansible-lint` at the repo root excludes non-Ansible YAML (GitHub Actions workflows, AWS Config conformance packs) from lint scanning.

### Testing an Ansible deploy directly (bypassing CI)

```bash
cd ansible
zip -r ansible-deploy.zip playbooks/ roles/ requirements.yml ansible.cfg
aws s3 cp ansible-deploy.zip s3://<artifact-bucket>/<env>/ansible-deploy-test.zip

aws ssm send-command \
  --document-name "AWS-ApplyAnsiblePlaybooks" \
  --targets "Key=tag:Environment,Values=<env>" "Key=tag:Service,Values=rewards" \
  --parameters '{
    "SourceType": ["S3"],
    "SourceInfo": ["{\"path\":\"https://s3.<region>.amazonaws.com/<artifact-bucket>/<env>/ansible-deploy-test.zip\"}"],
    "InstallDependencies": ["True"],
    "PlaybookFile": ["playbooks/site.yml"],
    "ExtraVariables": ["env=<env>"],
    "Check": ["True"]
  }' \
  --query "Command.CommandId" --output text
```

### GitHub secrets bootstrap

```bash
./scripts/create-github-secrets.sh github.com <owner>/<repo>
```

Prompts interactively for the `DEV_`/`PROD_` `AWS_OIDC_*` secrets that `ansible-cac-pipeline.yaml` and `tf-iac-pipeline.yaml` expect, creating the `dev`/`prod` GitHub environments if they don't already exist.

## Troubleshooting

Connect to an instance via SSM Session Manager (no SSH/bastion needed):

```bash
aws ssm start-session --target <instance-id>
```

### `myapp` not responding

```bash
sudo systemctl status myapp --no-pager
sudo journalctl -u myapp -n 50 --no-pager
```

`myapp` fetches `APP_SECRET` from Secrets Manager at import time (`ansible/roles/myapp/files/src/myapp/config.py`) and exits on failure — if the app never responds, this is almost always the cause. Check for a `Boot Error: ...` line in the journal output: it means either the secret has no value yet (set one in the console) or the instance role lacks `secretsmanager:GetSecretValue`/`kms:Decrypt` on it.

### nginx not reloading

```bash
sudo systemctl status nginx --no-pager
sudo nginx -t
```

`nginx -t` will point at the exact config line if `sites-available/myapp.conf` (or anything else in `sites-enabled/`) has a syntax error or a `default_server` conflict.
