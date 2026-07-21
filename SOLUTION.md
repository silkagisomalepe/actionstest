# Solution

## Goal

Add Ansible Configuration-as-Code on top of the existing Terraform-provisioned AWS infrastructure, with a CI/CD pipeline that lints, scans, and deploys playbooks to the fleet — without SSH access to instances.

## Architecture

```
ansible/
  playbooks/site.yml     # entrypoint: applies common + nginx + myapp roles to all hosts
  roles/common, nginx    # baseline packages, nginx install/start
  roles/myapp            # dedicated service account, venv + gunicorn app, nginx reverse-proxy vhost
  requirements.yml       # external role/collection dependencies
  ansible.cfg            # roles_path, so ansible-lint/ansible-playbook resolve roles/ from any invocation context

.github/workflows/ansible-cac-pipeline.yaml
  lint            → yamllint + ansible-lint + syntax-check
  scan            → Trivy config scan
  manual-approval → trstringer/manual-approval, workflow_dispatch deploy runs only
  deploy          → package as .zip, upload to S3, dispatch via AWS SSM (single environment, chosen via workflow_dispatch input)
```

Deployment is push-based from CI but pull-executed on the instance: GitHub Actions authenticates via OIDC, uploads the playbook bundle to S3, and issues an `aws ssm send-command` against `AWS-ApplyAnsiblePlaybooks`. The SSM agent on each tagged instance downloads and runs the bundle locally using its own IAM instance profile — no SSH keys, bastion, or inbound network path to the fleet are required.

A second, independent bootstrap path exists for ASG scale-out: `modules/aws-nst-ec2`'s `user_data` installs the CloudWatch agent, and — when `ansible_artifact_bucket` is set — also installs `ansible-core`, pulls the latest bundle from a stable S3 key, and runs the playbook locally at boot. This means a new instance the ASG launches on its own (scaling policy, replacement after termination) gets fully configured without waiting for the next CI deploy to happen to catch it via SSM.

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

**Manual approval gate on both pipelines.** Added a `manual-approval` job (via `trstringer/manual-approval`) between plan/lint and apply/deploy in both `tf-iac-pipeline.yaml` and `ansible-cac-pipeline.yaml`. Infra and config changes now require a human sign-off before touching real resources, at the cost of pipeline latency on every deploy.

**Ansible deploy restricted to `workflow_dispatch` only.** The deploy job's environment matrix used to fall back to `["dev","prod"]` for *any* trigger that wasn't `workflow_dispatch` — meaning every push to `main` silently deployed to prod as well as dev, with no approval gate. Deploy now only runs on an explicit `workflow_dispatch` with `action: deploy`, targeting the single environment chosen in the input; `push`/`pull_request` still run lint and scan, but never deploy.

**EC2 self-bootstrap via pull-based `user_data`, not a golden AMI.** New ASG-launched instances previously got nothing beyond the SSM agent — the actual tooling only landed when the CI pipeline happened to run an SSM push against tag-matched instances, so a scale-out event between deploys left new nodes unconfigured. Fixed by having `user_data` install `ansible-core`, pull the same bundle CI uploads to a stable S3 key (`rewards-ansible-artifacts/dev/ansible-deploy.zip`), and run the playbook locally at every boot. Considered baking a Packer/EC2-Image-Builder AMI instead (the "properly stateless/immutable" answer), but that's a whole extra build pipeline and AMI-rotation story that isn't worth it for a demo; the trade-off is a slower, less deterministic boot (live package installs, depends on apt/S3 being reachable) versus a pre-baked image.

**AWS CLI v2 over apt's `awscli`.** The pull-based bootstrap originally installed `awscli` via apt (AWS CLI v1) alongside `ansible-core`. That crashed at runtime with `KeyError: 'opsworkscm'` — apt's v1 CLI and a newer `botocore` pulled in by something else on the same system Python is a well-known version-skew failure. Switched to the official AWS CLI v2 installer (self-contained, bundles its own Python, no shared-dependency conflicts).

**Dedicated `myapp` service account, not `ec2-user`/`ubuntu`/root.** The `myapp` role originally defaulted its file/service owner to `ec2-user` — the default login user on Amazon Linux, not the Ubuntu AMI actually in use, so ownership tasks failed outright (`failed to look up user ec2-user`). Beyond just picking a name that exists, running a network-facing process as any login-capable account (`ubuntu`, `ec2-user`, or root) means a compromised app inherits that account's `sudo` — effectively root either way. Added explicit `group`/`user` tasks that create a dedicated system account (no login shell, no home dir) before anything chowns to it.

**Stale nginx config caused a duplicate `default_server`.** The site vhost moved from `/etc/nginx/conf.d/myapp.conf` to `sites-available/` + a `sites-enabled/` symlink at some point, but nothing removed the old file from already-provisioned instances — both got included, so nginx failed `nginx -t` with "duplicate default server for 0.0.0.0:80", and `reload` (which no-ops on a failed config test) kept serving stale config until someone ran a manual `systemctl restart`. Added an explicit cleanup task for the old `conf.d` path.

**`for_each` over apply-time-unknown values.** Hit "Invalid for_each argument" twice in `modules/aws-nst-ec2`: `additional_policy_arns` (and later the consolidated `managed` policy-attachment resource) used `toset(...)` directly over a list that included a brand-new IAM policy's `.arn` — not knowable until after that policy is created, so Terraform can't compute set membership from it. Fixed both by keying `for_each` off the list index (`{ for idx, arn in list : tostring(idx) => arn }`) instead of the value itself — the index is always known even when the value isn't.

**Tags now flow end-to-end from `environments/dev`.** `stacks/aws-baseline` had no `tags` variable at all, and several modules it calls into (`aws-nst-config`, and `aws-nst-kms` as used by `aws-nst-waf`/`aws-nst-cloudtrail`, plus `aws-nst-s3`, `aws-nst-flow-logs`) either lacked a `service_tags` variable or had specific resources (the EC2 ASG's `tag` blocks, a couple of KMS keys) that never actually applied it. Wired `var.tags` through every module call in both stacks, down to resource level.

**Removed GuardDuty from the baseline stack.** `aws_guardduty_detector` creation failed with `SubscriptionRequiredException` — this AWS account isn't subscribed to GuardDuty, and every other resource in that module (feature toggles, publishing destination) depends on the detector's ID, so nothing in it can work regardless of permissions. Removed the `module "guardduty"` call entirely rather than leave a permanently-broken module in the plan; the module files are untouched if a subscribed account needs it later.

**Removed the SNS topic policy — it mixed KMS actions into an SNS-scoped resource policy.** `aws_sns_topic_policy` failed apply with `InvalidParameter: ... action out of service scope` because its policy document granted `kms:GenerateDataKey`/`kms:Decrypt`/`kms:*`, which aren't valid actions on an SNS topic's own resource policy. Removed the resource and its policy document rather than try to salvage it — those KMS grants belonged on the SNS topic's KMS key policy, not here, and nothing else depended on them.

**ALB access-logs bucket: SSE-S3, not a customer-managed KMS key.** The bucket started SSE-KMS, which — combined with ALB *connection logs* also being enabled — requires bucket and key policy grants for the `logdelivery.elasticloadbalancing.amazonaws.com` service principal (the legacy per-region ELB service-account method doesn't support SSE-KMS destinations at all, and never supported connection logs). Rather than carry that extra KMS key + policy surface, switched the bucket to SSE-S3 (`AES256`) and removed the now-unused CMK/alias/key-policy resources entirely — simpler, and access logs don't need a customer-managed key.

**Cloudtrail bucket name has no `-logs` suffix.** Tried renaming it to `<name>-logs` for consistency with the other log buckets; the apply failed with `BucketAlreadyExists` — S3 bucket names are globally unique across every AWS account, and someone else already owns that name. Reverted to the original name.

**No TLS on the public listener.** The ALB (`stacks/aws-rewards/load_balancers.tf`) only has an HTTP:80 listener wired up; the HTTPS:443 listener and ACM certificate are present but commented out, and there's no CDN (e.g. CloudFront) in front of it. This is an accepted trade-off for this stage of the project, not an oversight: it means all traffic between clients and the ALB — including anything in the request/response bodies — travels unencrypted, and there's no CDN layer to absorb traffic, cache static assets, or provide a WAF/DDoS buffer before requests reach the ALB. Enabling the HTTPS listener (`acm-alb` module output is already wired to `certificate_arn`, just commented out) should happen before this is exposed to real users or handles anything sensitive.

**Monorepo.** Terraform IaC (`modules/`, `stacks/`, `environments/`) and Ansible CaC (`ansible/`) live in one repository rather than being split out. This keeps cross-referencing simple — the Ansible pipeline, the S3 artifact bucket it deploys through, and the EC2 IAM role it deploys onto are all defined and versioned together, so a single PR can change infra and configuration in lockstep. The trade-off: CI triggers, ownership, and blast radius are less isolated than separate repos would give you — a change anywhere in the repo shares the same PR/approval flow, and path-filtered workflows (`paths: ansible/**` etc.) are doing the job that repo boundaries would otherwise do.

## What's out of scope / left for follow-up

- The `AWS-ApplyAnsiblePlaybooks` deploy path has not yet been exercised end-to-end in `prod` — only `dev`, manually and via the pipeline.
- The post-deploy smoke test only checks a single HTTP health-check URL, with no rollback on failure.
- The pull-based `user_data` bootstrap (CloudWatch agent + self-configuring Ansible at boot) hasn't been exercised against a real ASG scale-out event yet — only against manually-triggered SSM deploys and initial instance boot.
- `rewards-sns` was asked about during this work but does not exist anywhere in this repository's Terraform — if it's a real resource, it's unmanaged here or lives in a different repo/stack.
