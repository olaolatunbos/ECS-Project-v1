# ECS-Project-v1

A Flask task-management (Todo) app deployed to **AWS ECS Fargate** behind an Application Load Balancer, provisioned end-to-end with **Terraform** and shipped through **GitHub Actions** CI/CD. Staging and production run as isolated Terraform workspaces in a single AWS account and region (`eu-west-2`).

## Architecture


- **Application** — [app/](app/): a Flask REST API with a small server-rendered UI. Task state is held **in memory** (a module-level dict), so it resets on restart; there is no database.
- **Infrastructure** — [terraform/](terraform/): composed of `vpc`, `alb`, `ecs`, `ecr`, `certificate`, and `dns` modules under [terraform/modules/](terraform/modules/).
- **Environments** — `staging` and `production` are **Terraform workspaces**. Per-environment settings (CIDRs, task sizing, image URL, hostname) live in the `workspace_config` map in [terraform/locals.tf](terraform/locals.tf).

## Application

### API

| Method | Path              | Description                          |
|--------|-------------------|--------------------------------------|
| GET    | `/`               | Serves the Todo web UI               |
| GET    | `/health`         | Health check → `{"status": "ok"}`    |
| GET    | `/tasks`          | List all tasks                       |
| POST   | `/tasks`          | Create a task (`title` required)     |
| GET    | `/tasks/<id>`     | Get a task by id                     |
| PUT    | `/tasks/<id>`     | Update a task (partial updates ok)   |
| DELETE | `/tasks/<id>`     | Delete a task                        |

A task looks like:

```json
{ "id": "<uuid>", "title": "Buy milk", "description": "2%", "completed": false }
```

### Run locally

```bash
cd app
pip install -r requirements-dev.txt
python app.py            # serves on http://localhost:3000
```

Then open http://localhost:3000, or exercise the API:

```bash
curl -s localhost:3000/health
curl -s -X POST localhost:3000/tasks \
  -H 'Content-Type: application/json' \
  -d '{"title":"Buy milk","description":"2%"}'
curl -s localhost:3000/tasks
```

### Test, lint, format

```bash
cd app
pytest                                       # run the suite
pytest --cov=app --cov-report=term           # with coverage
pytest tests/test_app.py::test_create_task   # a single test
ruff check --fix .                           # lint + autofix
ruff format .                                # format
```

### Container

[app/Dockerfile](app/Dockerfile) is a multi-stage build producing a hardened **distroless** image running as a non-root user, exposing port `3000`.

```bash
docker build -t task-management ./app
docker run -p 3000:3000 task-management
```

## Infrastructure (Terraform)

Run everything from [terraform/](terraform/). **Select a workspace before any plan/apply** — an unrecognized workspace fails on the missing config key.

```bash
cd terraform
terraform init
terraform workspace select staging     # or: production
terraform plan
terraform apply
```

State is stored in an S3 backend with native lockfile locking ([terraform/backend.tf](terraform/backend.tf)). To change sizing, CIDRs, or hostnames for an environment, edit the `workspace_config` map in [terraform/locals.tf](terraform/locals.tf) rather than adding tfvars files.

### Key outputs

`app_url`, `alb_dns_name`, `vpc_id`, `ecs_cluster_id`, `ecs_service_name`.

## CI/CD

All workflows ([.github/workflows/](.github/workflows/)) authenticate to AWS via **OIDC** (no long-lived credentials).

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| [ci.yaml](.github/workflows/ci.yaml) | PR / push on `app/**` | Ruff, pytest + coverage, pip-audit, gitleaks, Docker build + Trivy scan; pushes the image to ECR on push to `main` |
| [cd.yaml](.github/workflows/cd.yaml) | After CI succeeds on `main` | Deploy to staging → smoke-test `/health` → deploy to production |
| [terraform-plan.yaml](.github/workflows/terraform-plan.yaml) | PR on `terraform/**` | Plans staging + production, posts plans as PR comments, runs Checkov |
| [terraform-apply.yaml](.github/workflows/terraform-apply.yaml) | Push on `terraform/**` | Applies staging, then production |
| [terraform-destroy.yaml](.github/workflows/terraform-destroy.yaml) | Manual dispatch | Destroys a chosen environment |

Production deploys and applies are gated by **GitHub Environment** protection rules — add required reviewers on the `production` environment to enforce manual approval.

## Repository layout

```
app/                     Flask application, tests, Dockerfile
  templates/, static/    Server-rendered UI
  tests/                 pytest suite
terraform/               Root module + backend/providers/locals
  modules/               vpc, alb, ecs, ecr, certificate, dns
.github/workflows/       CI, CD, and Terraform plan/apply/destroy pipelines
```

## Contributing

Pre-commit hooks ([.pre-commit-config.yaml](.pre-commit-config.yaml)) run gitleaks and Terraform `fmt` / `tflint` / `trivy` (tflint and trivy must be installed locally):

```bash
pre-commit install
pre-commit run --all-files
```
