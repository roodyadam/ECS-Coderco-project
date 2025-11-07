# CI/CD Setup Guide

This document explains the CI/CD pipeline setup using GitHub Actions with OIDC authentication.

## Overview

The CI/CD pipeline consists of three main jobs:
1. **Build & Push**: Builds Docker image and pushes to ECR with SHA tag
2. **Terraform Deploy**: Runs Terraform validation, formatting, linting, and applies changes
3. **Health Check**: Verifies the deployment is healthy

## Prerequisites

1. **GitHub Repository**: Your code must be in a GitHub repository
2. **Terraform Applied**: Infrastructure must be initially deployed with Terraform
3. **GitHub Secret**: You need to add the GitHub Actions role ARN as a secret

## Setup Steps

### 1. Configure GitHub Repository in Terraform

Add your GitHub repository to `infra/terraform.tfvars`:

```hcl
github_repo = "your-username/your-repo-name"
```

### 2. Apply Terraform Changes

Run Terraform to create the OIDC provider and GitHub Actions IAM role:

```bash
cd infra
terraform init
terraform plan
terraform apply
```

### 3. Get GitHub Actions Role ARN

After applying Terraform, get the role ARN:

```bash
cd infra
terraform output github_actions_role_arn
```

### 4. Add GitHub Secret

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `AWS_GITHUB_ACTIONS_ROLE_ARN`
5. Value: The ARN from step 3 (e.g., `arn:aws:iam::147923156682:role/aimapp-github-actions-role`)
6. Click **Add secret**

### 5. Test the Pipeline

1. Push to a feature branch to test the build job
2. Merge to `main` to trigger the full deployment pipeline
3. Or use **Actions** → **Deploy** → **Run workflow** for manual trigger

## Pipeline Details

### Build & Push Job

- **Triggers**: Push to any branch, manual dispatch
- **Actions**:
  - Authenticates to AWS using OIDC
  - Gets ECR repository URL from Terraform
  - Builds Docker image for `linux/amd64` platform
  - Tags image with commit SHA and `latest` (on main branch)
  - Pushes to ECR

### Terraform Deploy Job

- **Triggers**: Push to any branch, manual dispatch
- **Actions**:
  - Runs `terraform fmt -check` (formats if needed)
  - Runs `terraform validate`
  - Runs `tflint` for best practices
  - Runs `terraform plan` with SHA as image tag
  - Runs `terraform apply` (only on main branch)
  - Forces ECS service update to pull new image

### Health Check Job

- **Triggers**: Only after successful deploy on main branch
- **Actions**:
  - Waits 30 seconds for ECS to stabilize
  - Checks `https://tm.<your-domain>/status` endpoint
  - Retries up to 10 times with 15-second intervals
  - Fails pipeline if health check doesn't return 200

## Workflow Features

✅ **OIDC Authentication**: No static AWS keys required  
✅ **Separate Pipelines**: Build runs on all branches, deploy only on main  
✅ **Manual Trigger**: Use `workflow_dispatch` to run manually  
✅ **Terraform Best Practices**: Includes fmt, validate, and tflint  
✅ **Job Summaries**: Shows deployment status in GitHub Actions UI  
✅ **SHA-based Tagging**: Immutable image tags for traceability  

## Troubleshooting

### Pipeline fails at "Configure AWS credentials"

- Verify the `AWS_GITHUB_ACTIONS_ROLE_ARN` secret is set correctly
- Check that Terraform has been applied and the role exists
- Verify the GitHub repository name matches in `terraform.tfvars`

### Health check fails

- Check ECS service logs in CloudWatch
- Verify the ALB target group health checks are passing
- Ensure the `/status` endpoint is accessible

### Terraform plan fails

- Check that all required variables are set in `terraform.tfvars`
- Verify Terraform state is accessible
- Check for any syntax errors in Terraform files

## Manual Deployment

To manually trigger a deployment:

1. Go to **Actions** tab in GitHub
2. Select **Deploy** workflow
3. Click **Run workflow**
4. Select branch and click **Run workflow**

## Image Tagging Strategy

- **Commit SHA**: Every build gets tagged with the full commit SHA (e.g., `abc123def456...`)
- **Latest**: Main branch builds also get the `latest` tag
- **ECS Update**: The pipeline updates the ECS task definition with the SHA tag and forces a new deployment

## Security Notes

- OIDC provider is scoped to your specific GitHub repository
- IAM role has least-privilege permissions (ECR, ECS, Terraform state access)
- No static credentials stored in GitHub
- All AWS API calls are authenticated via OIDC tokens


