#!/bin/bash
# Script to build and push Docker image to ECR for linux/amd64 platform

cd "$(dirname "$0")"

# Get ECR repository URL from Terraform
ECR_REPO=$(cd infra && terraform output -raw ecr_repository_url 2>/dev/null)

if [ -z "$ECR_REPO" ]; then
    echo "Error: Could not get ECR repository URL. Make sure terraform apply has completed."
    exit 1
fi

echo "ECR Repository: $ECR_REPO"

# Get AWS region
AWS_REGION=$(echo $ECR_REPO | cut -d'.' -f4)

echo "AWS Region: $AWS_REGION"
echo "Building for linux/amd64 platform (this will take longer on ARM Macs)..."

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO

# Build and push for linux/amd64 platform using buildx
echo "Building Docker image for linux/amd64..."
cd aim
docker buildx build --platform linux/amd64 -f docker/Dockerfile -t $ECR_REPO:latest --push .

echo "Done! Image pushed to $ECR_REPO:latest"
echo "ECS service should now be able to pull and run the container."
