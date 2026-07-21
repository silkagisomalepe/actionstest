# Solution

## Goal

Add Ansible Configuration-as-Code on top of the existing Terraform-provisioned AWS infrastructure, with a CI/CD pipeline that lints, scans, and deploys playbooks to the fleet — without SSH access to instances.

## Architecture

```
ansible/
  playbooks/site.yml     # entrypoint: applies common + nginx roles to all hosts
  roles/common, nginx    # baseline packages, nginx install/start
  requirements.yml        # external role/collection dependencies
  ansible.cfg             # roles_path, so ansible-lint/ansible-playbook resolve roles/ from any invocation context

.github/workflows/ansible-cac-pipeline.yaml
  lint  → yamllint + ansible-lint + syntax-check
  scan  → Trivy config scan
  deploy → package as .zip, upload to S3, dispatch via AWS SSM (per environment, dev then prod, max-parallel 1)
```

Deployment is push-based from CI but pull-executed on the instance: GitHub Actions authenticates via OIDC, uploads the playbook bundle to S3, and issues an `aws ssm send-command` against `AWS-ApplyAnsiblePlaybooks`. The SSM agent on each tagged instance downloads and runs the bundle locally using its own IAM instance profile — no SSH keys, bastion, or inbound network path to the fleet are required.

## Key decisions and trade-offs

**SSM over SSH.** Rejected pushing playbooks over SSH from CI runners: it would need a bastion or public SSH exposure, plus key management in GitHub secrets. SSM reuses the IAM/OIDC trust already in place and keeps instances on private subnets with no inbound access at all. Trade-off: the instance's IAM role now needs S3 `GetObject`/`ListBucket` and `kms:Decrypt` on the artifact bucket — a new attack surface (albeit a much narrower one than open SSH), and Ansible's own dependency-install step now runs with the instance role's privileges rather than a scoped-down CI credential.

**`AWS-ApplyAnsiblePlaybooks`, not `AWS-RunAnsiblePlaybook`.** The latter is AWS's deprecated document with a different (and, we found the hard way, non-obvious) parameter schema — sending it `playbookurl`/`playbookfile`/`extraparams` fails with `InvalidParameters`, and it's a dead end since it's no longer being enhanced. Moved to the documented replacement (`SourceType`/`SourceInfo`/`PlaybookFile`/`ExtraVariables`/`Check`), which also gains bundled/complex-playbook support and verbose logging.

**Artifact format is `.zip`, not `.tar.gz`.** `AWS-ApplyAnsiblePlaybooks` only auto-decompresses `.zip` archives after download; a gzip tarball would land on the instance still compressed and the playbook run would fail to find `site.yml`. Packaging now includes `ansible.cfg` in the bundle itself, so role resolution works identically whether you're running from a checkout or from the extracted SSM download directory.

**Roles path fixed at three layers, not one.** `ansible-lint`'s syntax-check and `ansible-playbook` both resolve roles relative to the *playbook's* directory (`ansible/playbooks/roles`) by default, not the actual sibling `ansible/roles/`. Rather than restructure the repo (which would also require re-pathing the SSM deploy bundle), we fixed resolution at each invocation site: `ansible/ansible.cfg` (`roles_path = ./roles`) for anything run with `ansible/` as cwd — local dev and the CI "Syntax check" step — and `ANSIBLE_ROLES_PATH` (absolute, via `${{ github.workspace }}`) for the `ansible-lint` GitHub Action step, which runs from the repo root. Belt-and-suspenders, but each config only works for the cwd it's scoped to.

**S3 region-qualified endpoints.** `SourceInfo`'s `path` must be a real HTTPS URL the SSM agent fetches directly — the AWS docs' own example (`https://s3.amazonaws.com/bucket/key`) is the *global* endpoint, which 301-redirects for any bucket outside `us-east-1`; the agent doesn't follow redirects. Switched to `https://s3.<region>.amazonaws.com/...`.

**Module boundary for the extra IAM policy.** `modules/aws-nst-ec2` gained a generic `additional_policy_arns` list variable rather than bucket- or KMS-specific variables — the module has no reason to know about "ansible artifacts." The actual `s3:GetObject`/`s3:ListBucket`/`kms:Decrypt` policy document lives in `stacks/aws-rewards/storage.tf`, next to the bucket it grants access to, and gets passed in by ARN. Keeps the module reusable for any future policy the stack needs to attach, at the cost of one extra resource + wiring step per stack that needs it.

**Consolidated policy attachments with `for_each`.** Replaced four separate `aws_iam_role_policy_attachment` resources (SSM core, CloudWatch agent, the module's own logging policy, plus the new "additional" list) with one `for_each` over `concat([...static arns...], var.additional_policy_arns)`. `create_before_destroy` is set because this change moves existing attachments to new resource addresses (`managed["<arn>"]` instead of named resources) — Terraform will plan a destroy+create rather than an in-place update on first apply against already-provisioned infra, even though the resulting IAM state is identical.

**Secrets Manager: container managed, value is not.** `aws_secretsmanager_secret_version` is now `count`-gated on `secret_string != null`, with `ignore_changes = [secret_string]` on the version resource as a second guard. This lets Terraform own the secret + its dedicated CMK (via the existing `aws-nst-kms` module) while a human sets and rotates the actual value through the console — `terraform apply` will never create an empty/placeholder version or clobber a manually-set one on drift.

**KMS default-policy bug.** The Secrets Manager module's key policy granted the account root only `kms:Describe*`/`Get*`/`List*`/`RevokeGrant` — missing `kms:PutKeyPolicy`. AWS rejects `CreateKey` outright if no principal in the initial policy can ever update the policy again (`MalformedPolicyDocumentException`). Fixed by granting `kms:*` to the account root, matching AWS's own default key-policy convention (this is the standard "root has full admin, specific grants layered on top for services/roles" shape, not a broadening beyond what KMS keys normally ship with).

**Manual approval gate on `terraform apply`.** Added a `manual-approval` job between `plan` and `apply` in `tf-iac-pipeline.yaml` (via `trstringer/manual-approval`), gating on the same push-to-main / workflow-dispatch conditions as apply itself. Infra changes now require a human sign-off before touching real resources, at the cost of pipeline latency on every merge to main.

**No TLS on the public listener.** The ALB (`stacks/aws-rewards/load_balancers.tf`) only has an HTTP:80 listener wired up; the HTTPS:443 listener and ACM certificate are present but commented out, and there's no CDN (e.g. CloudFront) in front of it. This is an accepted trade-off for this stage of the project, not an oversight: it means all traffic between clients and the ALB — including anything in the request/response bodies — travels unencrypted, and there's no CDN layer to absorb traffic, cache static assets, or provide a WAF/DDoS buffer before requests reach the ALB. Enabling the HTTPS listener (`acm-alb` module output is already wired to `certificate_arn`, just commented out) should happen before this is exposed to real users or handles anything sensitive.

**Monorepo.** Terraform IaC (`modules/`, `stacks/`, `environments/`) and Ansible CaC (`ansible/`) live in one repository rather than being split out. This keeps cross-referencing simple — the Ansible pipeline, the S3 artifact bucket it deploys through, and the EC2 IAM role it deploys onto are all defined and versioned together, so a single PR can change infra and configuration in lockstep. The trade-off: CI triggers, ownership, and blast radius are less isolated than separate repos would give you — a change anywhere in the repo shares the same PR/approval flow, and path-filtered workflows (`paths: ansible/**` etc.) are doing the job that repo boundaries would otherwise do.

## What's out of scope / left for follow-up

- The `AWS-ApplyAnsiblePlaybooks` deploy path has not yet been exercised end-to-end in `prod` — only `dev`, manually and via the pipeline.
- No automated smoke test post-deploy (the workflow has a commented-out placeholder); health-check validation is manual today.
- `rewards-sns` was asked about during this work but does not exist anywhere in this repository's Terraform — if it's a real resource, it's unmanaged here or lives in a different repo/stack.
