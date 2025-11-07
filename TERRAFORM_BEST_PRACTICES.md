# Terraform Destroy and Apply - Best Practices

## ⚠️ Can You Run `terraform destroy` and `terraform apply` Whenever?

**Short answer**: Yes, but understand what happens first!

## 🔴 What `terraform destroy` Does

**DESTROYS ALL RESOURCES** managed by Terraform:

- ❌ **ECS Service** - Your running application stops
- ❌ **ECS Tasks** - All containers are terminated
- ❌ **Application Load Balancer (ALB)** - Load balancer deleted
- ❌ **Target Groups** - Health check targets removed
- ❌ **Security Groups** - Firewall rules deleted
- ❌ **VPC & Subnets** - Network infrastructure removed
- ❌ **Route Tables** - Network routing deleted
- ❌ **Route53 DNS Records** - Your domain stops resolving
- ❌ **ECR Repository** - Repository deleted (but images may persist)
- ❌ **CloudWatch Log Groups** - Logs deleted
- ❌ **IAM Roles** - Execution and task roles removed

### ✅ What WON'T Be Deleted

- ✅ **ECR Docker Images** - Images stored separately (may need to check)
- ✅ **ACM Certificate** - If using existing certificate
- ✅ **Route53 Hosted Zone** - The zone itself (only records deleted)
- ✅ **Your Code** - Local files are safe
- ✅ **Terraform State File** - State file remains (but empty)

## ✅ What `terraform apply` Does

**Creates or Updates** resources to match your configuration:

- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Updates** existing resources if config changed
- ✅ **Creates** new resources if they don't exist
- ✅ **No data loss** - Updates are non-destructive (usually)

## 🎯 When to Use Each

### Use `terraform apply` for:
- ✅ Making configuration changes
- ✅ Adding new resources
- ✅ Updating existing resources
- ✅ Regular deployments
- ✅ **This is your go-to command for updates!**

### Use `terraform destroy` only when:
- ⚠️ You want to completely remove infrastructure
- ⚠️ You're testing/developing and want a clean slate
- ⚠️ You're cleaning up old/unused resources
- ⚠️ You're moving to a different region/account
- ⚠️ **NOT for regular operations!**

## 🔄 What Happens When You Destroy and Reapply

### Step 1: `terraform destroy`
```
Your Infrastructure:
├── ECS Service → STOPPED
├── ALB → DELETED
├── VPC → DELETED
├── DNS Records → DELETED
└── Your Site → DOWN ❌
```

### Step 2: `terraform apply` (after destroy)
```
New Infrastructure Created:
├── NEW VPC (different IPs)
├── NEW ALB (different DNS name)
├── NEW ECS Cluster
├── NEW Security Groups
└── NEW DNS Records

You'll need to:
1. Rebuild and push Docker image
2. Update Route53 if ALB DNS changed
3. Wait for DNS propagation
4. Your application data is LOST
```

## 💡 Best Practices

### 1. **Use `terraform apply` for Updates**
```bash
# Make changes to .tf files
vim infra/main.tf

# Apply changes (safe, updates resources)
terraform apply
```

### 2. **Use `terraform plan` First**
```bash
# See what will change BEFORE applying
terraform plan

# Review the changes, then apply
terraform apply
```

### 3. **Backup Important Data**
Before destroying:
- ✅ Export any data from your application
- ✅ Save configuration files
- ✅ Note down important IPs/ARNs if needed

### 4. **Use Workspaces for Testing**
```bash
# Create a test workspace
terraform workspace new test

# Test changes here first
terraform apply

# Switch back to production
terraform workspace select default
```

### 5. **State File Management**
- ✅ Keep `terraform.tfstate` in version control (or use remote state)
- ✅ Don't manually edit state file
- ✅ Use `terraform import` if needed

## ⚠️ Important Warnings

### Data Loss
- **ECS containers are stateless** - All data in running containers is lost
- **CloudWatch logs** - Deleted when log groups are removed
- **Application state** - Any in-memory data is lost

### DNS Changes
- **ALB DNS name changes** - New ALB gets new DNS name
- **Route53 records** - Need to be updated if ALB changes
- **DNS propagation** - Takes time to propagate globally

### Cost Implications
- **Destroying stops costs** - No charges for deleted resources
- **Recreating costs** - New resources start billing again
- **Data transfer** - May incur costs when recreating

## 🛡️ Safe Workflow

### For Regular Updates:
```bash
# 1. Review what will change
terraform plan

# 2. Apply changes (safe)
terraform apply

# 3. Verify everything works
curl https://tm.roodyadamsapp.com
```

### For Complete Rebuild:
```bash
# 1. Backup important data
# 2. Export application data if needed

# 3. Destroy (careful!)
terraform destroy

# 4. Rebuild
terraform apply

# 5. Rebuild and push Docker image
./build-and-push-amd64.sh

# 6. Force ECS deployment
aws ecs update-service \
  --cluster aimapp-cluster \
  --service aimapp-service \
  --force-new-deployment \
  --region eu-west-2
```

## 📋 Quick Reference

| Command | When to Use | Data Loss? | Downtime? |
|---------|------------|------------|-----------|
| `terraform apply` | Updates, changes | No | Minimal (rolling updates) |
| `terraform destroy` | Complete removal | **Yes** | **Yes** |
| `terraform plan` | Preview changes | No | No |
| `terraform refresh` | Sync state | No | No |

## 🎓 Key Takeaways

1. ✅ **`terraform apply` is safe** - Use it for updates
2. ⚠️ **`terraform destroy` is destructive** - Use carefully
3. 💡 **Always run `terraform plan` first** - See what will change
4. 🔄 **Destroy + Apply = Complete rebuild** - Everything is new
5. 📦 **Backup data before destroying** - Containers are stateless

## 🔍 Check What Will Be Destroyed

Before running `terraform destroy`, see what will be deleted:

```bash
terraform plan -destroy
```

This shows you exactly what will be removed without actually destroying anything.



