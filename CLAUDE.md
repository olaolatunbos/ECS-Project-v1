# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A Flask task-management API ([app/](app/)) deployed to AWS ECS Fargate behind an ALB, provisioned with Terraform ([terraform/](terraform/)). The app is an in-memory CRUD API (no database) — task state lives in a module-level `tasks` dict in [app/app.py](app/app.py) and is lost on restart. Two environments, `staging` and `production`, are modelled as **Terraform workspaces**, not separate root modules or directories.

## Common commands

Application (run from [app/](app/)):

```bash
pip install -r requirements-dev.txt   # installs runtime + dev deps
python app.py                         # run locally on :3000 (debug mode)
pytest                                # run the test suite
pytest --cov=app --cov-report=term    # tests with coverage (matches CI)
pytest tests/test_app.py::test_create_task   # run a single test
ruff format .                         # format
ruff check --fix .                    # lint + autofix
```

Terraform (run from [terraform/](terraform/)):

```bash
terraform init
terraform workspace select staging    # or production — REQUIRED before plan/apply
terraform plan
terraform apply
```

Pre-commit hooks ([.pre-commit-config.yaml](.pre-commit-config.yaml)) run gitleaks and `terraform_fmt` / `terraform_tflint` / `terraform_trivy` (tflint and trivy must be installed locally).

## Terraform architecture

The root module ([terraform/main.tf](terraform/main.tf)) wires together modules under [terraform/modules/](terraform/modules/): `ecr`, `vpc`, `certificate`, `alb`, `dns`, `ecs`. Key structural points:

- **Workspace-driven config.** [terraform/locals.tf](terraform/locals.tf) holds a `workspace_config` map keyed by workspace name (`staging`/`production`). `local.env = workspace_config[terraform.workspace]` selects the active settings (CIDRs, task sizing, image URL, hostname). **Selecting an unknown workspace fails on the missing map key** — this is intentional. There is no `terraform.tfvars` with per-env values; environment differences live entirely in this map.
- **Name prefixing.** `local.name = "${var.name}-${terraform.workspace}"` (e.g. `prj1-staging`) keeps resource names unique since both environments deploy into the *same* AWS account/region (`eu-west-2`).
- **State.** Single S3 backend ([terraform/backend.tf](terraform/backend.tf)) with `use_lockfile` (S3-native locking, no DynamoDB). Workspaces partition state within that one backend.
- **Networking / traffic path.** `vpc` (public + private subnets) → `alb` (public, HTTPS via ACM cert) → `ecs` Fargate service in **private** subnets, target-group registered on the ALB. `certificate` provisions the ACM cert with DNS validation; `dns` points the workspace hostname at the ALB. Note `module.ecs` has an explicit `depends_on = [module.alb]` so the target group is fully wired before the service registers.
- **Health check.** ALB health check path is `/health`, matching the Flask `/health` route. Container port is `3000` throughout (`var.container_port`).

## CI/CD architecture

Four GitHub Actions workflows in [.github/workflows/](.github/workflows/), all authenticating to AWS via **OIDC** (role `github-actions`, no long-lived keys):

- **[ci.yaml](.github/workflows/ci.yaml)** — triggered on `app/**` changes. Jobs: static analysis (ruff), test+coverage (pytest), security (pip-audit, gitleaks), docker build + Trivy scan. The `docker-push` job runs **only on push to main**, builds one image and tags/pushes it to *both* the staging and production ECR repos (same registry) as `<sha>` and `latest`.
- **[cd.yaml](.github/workflows/cd.yaml)** — chained via `workflow_run` after CI completes on main. Progression: **deploy-staging → smoke-test (curls `/health` via the ALB) → deploy-production**. It resolves the `latest` image digest from ECR and pulls the *live* task definition from ECS at deploy time (no `task-definition.json` is committed). Production has no smoke test gate beyond staging's.
- **[terraform-plan.yaml](.github/workflows/terraform-plan.yaml)** — on PRs touching `terraform/**`; runs a matrix over `[staging, production]`, posts each plan as a PR comment, includes a Checkov scan.
- **[terraform-apply.yaml](.github/workflows/terraform-apply.yaml)** — on push to main touching `terraform/**`. Applies staging first, then production (`needs: apply-staging`). Environment gates are enforced via **GitHub Environments** — add required reviewers on the `production` environment for a manual approval gate.
- **[terraform-destroy.yaml](.github/workflows/terraform-destroy.yaml)** — manual `workflow_dispatch` only, with an environment-choice input.

Deploy jobs read config from GitHub Actions **variables** (`vars.ECR_REPOSITORY`, `vars.ECS_CLUSTER`, `vars.ECS_SERVICE`, `vars.TASK_DEFINITION_FAMILY`, `vars.CONTAINER_NAME`) and secrets (`secrets.AWS_ACCOUNT_ID`), scoped per GitHub Environment.

## Container

[app/Dockerfile](app/Dockerfile) is a multi-stage build: deps installed to `/app/deps` on `python:3.12-slim`, final image is `gcr.io/distroless/python3-debian12` running as non-root UID `65532`, `PYTHONPATH=/app/deps`, `CMD ["app.py"]`. When adding runtime imports, remember the distroless base has no shell and only what's in `requirements.txt`.

## Conventions worth knowing

- CI runs Python 3.11; the Docker image is built on Python 3.12. Keep code compatible with both.
- Tests clear `app_module.tasks` in the `client` fixture — the in-memory store is shared global state, so any new stateful behaviour must be resettable the same way.
- To add an environment or change sizing/CIDRs/hostnames, edit the `workspace_config` map in [terraform/locals.tf](terraform/locals.tf) and add a matching workspace — not new tfvars files.
