# FundingPips DevOps Task

Deploy a containerized Ruby on Rails API to cloud infrastructure, automate delivery, and expose it publicly.

## API

The app lives in `/api` directory and exposes:

- `GET /health` → `{"status":"ok"}`

## Requirements Coverage

- [x] Containerized Rails API that builds and runs with Docker
- [x] Infrastructure provisioned with Terraform/Terragrunt
- [x] Automated CI/CD with GitHub Actions on `main` and `Argocd`
- [x] Kubernetes deployment manifests and GitOps structure included

## Repository Structure

- `api` Rails application and Docker build context
- `gitops/terraform` Terraform catalogs and Terragrunt live configuration
- `gitops/argo-cd` Argo CD ApplicationSet to the tooling services
- `k8s/chart` Helm chart for API deployment
- `.github/workflows/` CI validation and release image workflows

## Prerequisites

- Docker
- Ruby `3.4.8`
- Terraform `1.14.6`
- Terragrunt `0.95.0`
- AWS CLI `2.x`

Tool versions are pinned in `mise.toml`.

## Local Run

### Run with Rails

```sh
cd api
bundle install
bin/rails server
```

Health check:

```sh
curl http://localhost:3000/health
```

### Run with Docker

```sh
cd api
docker build -t fundingpips-api .
docker run --rm -p 8080:80 fundingpips-api
```

Health check:

```sh
curl http://localhost:8080/health
```

## Infrastructure (Terragrunt)

Live environment path:

```sh
cd gitops/terraform/live/dev/eu-central-1
```

Initialize:

```sh
terragrunt run --all init
```

Plan:

```sh
terragrunt run --all plan
```

Apply:

```sh
terragrunt run --all apply
```

The stack definitions are in `terragrunt.stack.hcl` and include terraform state backend, ECR, GitHub OIDC, VPC, EKS, and IRSA units.

## CI/CD

GitHub Actions workflows:

- `ci.yml`: PR/push checks for security, linting, tests, and system tests (`api/**` changes)
- `aws-ecr.yaml`: on `main`, builds Docker image, uploads artifact, and pushes tags to AWS ECR

Additional automation:

- `dependabot.yml` for dependency updates

## Kubernetes & GitOps

- Helm chart: `k8s/chart/`
- Argo CD ApplicationSet: `gitops/argo-cd/application-set.yaml`

These directories define deployment manifests and GitOps synchronization structure for the environment.

## Demo Cost Estimation

Based on a demo Infracost estimate:

| Name | Monthly Qty | Unit | Monthly Cost |
|---|---:|---|---:|
| `aws_dynamodb_table.dynamodb_tfstate_lock` |  |  |  |
| ├─ Write capacity unit (WCU) | 5 | WCU | $2.89 |
| ├─ Read capacity unit (RCU) | 5 | RCU | $0.58 |
| ├─ Data storage |  | Monthly cost depends on usage: $0.31 per GB |  |
| ├─ On-demand backup storage |  | Monthly cost depends on usage: $0.12 per GB |  |
| ├─ Table data restored |  | Monthly cost depends on usage: $0.18 per GB |  |
| └─ Streams read request unit (sRRU) |  | Monthly cost depends on usage: $0.000000245 per sRRUs |  |
| `module.s3_bucket_backend.aws_s3_bucket.this[0]` |  |  |  |
| └─ Standard |  |  |  |
| &nbsp;&nbsp;&nbsp;&nbsp;├─ Storage |  | Monthly cost depends on usage: $0.0245 per GB |  |
| &nbsp;&nbsp;&nbsp;&nbsp;├─ PUT, COPY, POST, LIST requests |  | Monthly cost depends on usage: $0.0054 per 1k requests |  |
| &nbsp;&nbsp;&nbsp;&nbsp;├─ GET, SELECT, and all other requests |  | Monthly cost depends on usage: $0.00043 per 1k requests |  |
| &nbsp;&nbsp;&nbsp;&nbsp;├─ Select data scanned |  | Monthly cost depends on usage: $0.00225 per GB |  |
| &nbsp;&nbsp;&nbsp;&nbsp;└─ Select data returned |  | Monthly cost depends on usage: $0.0008 per GB |  |
| **Project total** |  |  | **$3.47** |

**OVERALL TOTAL: $119.08**

*Usage costs can be estimated by updating Infracost Cloud settings, see docs for other options.*

---

196 cloud resources were detected:

- 9 were estimated
- 187 were free

| Project | Baseline cost | Usage cost* | Total cost |
|---|---:|---:|---:|
| `.terragrunt-stack-argo-cd-irsa` | $0.00 | - | $0.00 |
| `.terragrunt-stack-container-registries` | $0.00 | - | $0.00 |
| `.terragrunt-stack-github-workflows-ecr-oidc` | $0.00 | - | $0.00 |
| `.terragrunt-stack-main-eks` | $74 | - | $74 |
| `.terragrunt-stack-main-vpc` | $42 | - | $42 |
| `.terragrunt-stack-secrets-manager-irsa` | $0.00 | - | $0.00 |
| `.terragrunt-stack-terraform-backend` | $3 | - | $3 |