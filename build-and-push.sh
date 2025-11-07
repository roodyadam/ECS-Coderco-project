#!/bin/bash
# Script to build and push Docker image to ECR

cd "$(dirname "$0")"

# Get ECR repository URL from Terraform
ECR_REPO=$(cd infra && terraform output -raw ecr_repository_url 2>/dev/null)

if [ -z "$ECR_REPO" ]; then
    echo "Error: Could not get ECR repository URL. Make sure terraform apply has completed."
    exit 1
fi

echo "ECR Repository: $ECR_REPO"

# Get AWS account and region
AWS_ACCOUNT=$(echo $ECR_REPO | cut -d'.' -f1)
AWS_REGION=$(echo $ECR_REPO | cut -d'.' -f4)

echo "AWS Account: $AWS_ACCOUNT"
echo "AWS Region: $AWS_REGION"

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO

# Build the image
echo "Building Docker image..."
cd aim
docker build -f docker/Dockerfile -t aimapp:latest .

# Tag the image
echo "Tagging image..."
docker tag aimapp:latest $ECR_REPO:latest

# Push the image
echo "Pushing image to ECR..."
docker push $ECR_REPO:latest

echo "Done! Image pushed to $ECR_REPO:latest"
echo "ECS service should now be able to pull and run the container."
