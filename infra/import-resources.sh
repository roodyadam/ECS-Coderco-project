#!/bin/bash
# One-time import script for existing AWS resources
# Run this once to import existing resources into Terraform state
# After import, Terraform will manage these resources normally

set -e

cd "$(dirname "$0")"

echo "Starting resource import..."

# Import ECR repository
echo "Importing ECR repository..."
terraform import module.ecr.aws_ecr_repository.this aimapp-repo || echo "ECR repository already imported or doesn't exist"

# Import IAM roles
echo "Importing IAM execution role..."
terraform import module.iam.aws_iam_role.ecs_execution aimapp-ecs-execution-role || echo "ECS execution role already imported or doesn't exist"

echo "Importing IAM task role..."
terraform import module.iam.aws_iam_role.ecs_task aimapp-ecs-task-role || echo "ECS task role already imported or doesn't exist"

# Import OIDC provider
echo "Getting OIDC provider ARN..."
OIDC_ARN=$(aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[?contains(Arn, `token.actions.githubusercontent.com`)].Arn' --output text 2>/dev/null || echo "")

if [ -n "$OIDC_ARN" ]; then
  echo "Importing OIDC provider: $OIDC_ARN"
  terraform import module.iam.aws_iam_openid_connect_provider.github "$OIDC_ARN" || echo "OIDC provider already imported or doesn't exist"
else
  echo "OIDC provider not found - it will be created on next terraform apply"
fi

echo ""
echo "Import complete!"
echo "Run 'terraform plan' to verify everything is in sync."
echo "Terraform will now manage these resources normally."

