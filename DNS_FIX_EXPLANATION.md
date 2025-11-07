# DNS Fix Explanation - What Changed and Why

## 🔴 The Problem

Your domain `tm.roodyadamsapp.com` worked for you but not for others because:

1. **You had TWO Route53 hosted zones** for the same domain
2. **Your domain registrar** was pointing to **Zone 2's nameservers**
3. **But the DNS record** was only in **Zone 1**
4. **Result**: 
   - Your local DNS (cached/using Zone 1) → Found record → ✅ Worked
   - External DNS servers (Google, Cloudflare) → Queried Zone 2 → Found nothing → ❌ Failed

## 📝 What Changed

### 1. File: `infra/main.tf`
**Line 64** - Changed the `hosted_zone_id`:

```terraform
# BEFORE:
hosted_zone_id = "Z06988621L4AI5LXY4AF3"  # Zone 1 (wrong zone)

# AFTER:
hosted_zone_id = "Z03471512MMNKQA60WMUH"  # Zone 2 (correct zone - registrar points here)
```

**What this does**: Tells Terraform which Route53 hosted zone to manage DNS records in.

### 2. Created DNS Record in Zone 2

I used AWS CLI to create the DNS record in Zone 2 (the zone your registrar actually uses):

```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id Z03471512MMNKQA60WMUH \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "tm.roodyadamsapp.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "ZHURV8PSTC4K8",
          "DNSName": "aimapp-alb-962039018.eu-west-2.elb.amazonaws.com",
          "EvaluateTargetHealth": true
        }
      }
    }]
  }'
```

### 3. Updated Terraform State

```bash
# Removed old record from state
terraform state rm 'module.route53.aws_route53_record.alb'

# Imported new record into state
terraform import 'module.route53.aws_route53_record.alb' \
  Z03471512MMNKQA60WMUH_tm.roodyadamsapp.com_A
```

## 🎓 Key Concepts to Learn

### Route53 Hosted Zones

- A **hosted zone** is a container for DNS records for a domain
- Each zone has its own set of **nameservers** (like `ns-1509.awsdns-60.org`)
- Your **domain registrar** (where you bought the domain) must point to ONE zone's nameservers
- DNS queries go: `User → DNS Server → Nameservers (from registrar) → Hosted Zone → Record`

### How DNS Resolution Works

```
1. User types: https://tm.roodyadamsapp.com
2. Browser asks DNS server: "What's the IP for tm.roodyadamsapp.com?"
3. DNS server checks: "Who are the nameservers for roodyadamsapp.com?"
4. Gets nameservers from domain registrar (Zone 2 nameservers)
5. Queries Zone 2 nameservers: "What's the IP for tm.roodyadamsapp.com?"
6. Zone 2 returns: "It's an alias to aimapp-alb-962039018.eu-west-2.elb.amazonaws.com"
7. Browser connects to that ALB
```

### The Problem in Detail

```
Your Setup:
├── Domain Registrar
│   └── Points to Zone 2 nameservers (ns-1509, ns-1622, etc.)
│
├── Route53 Zone 1 (Z06988621L4AI5LXY4AF3)
│   └── Has DNS record ✅
│   └── But registrar doesn't point here ❌
│
└── Route53 Zone 2 (Z03471512MMNKQA60WMUH)
    └── No DNS record ❌
    └── But registrar points here ✅
```

**Result**: External DNS servers query Zone 2 (as instructed by registrar) → find nothing → can't resolve

## 🔍 How to Diagnose This Issue

### 1. Check which nameservers your registrar uses:
```bash
whois roodyadamsapp.com | grep -i "name server"
```

### 2. List all Route53 hosted zones:
```bash
aws route53 list-hosted-zones --query "HostedZones[?Name=='roodyadamsapp.com.']"
```

### 3. Check which zone has those nameservers:
```bash
# Check Zone 1
aws route53 get-hosted-zone --id Z06988621L4AI5LXY4AF3 \
  --query 'DelegationSet.NameServers'

# Check Zone 2
aws route53 get-hosted-zone --id Z03471512MMNKQA60WMUH \
  --query 'DelegationSet.NameServers'
```

### 4. Test DNS resolution from external servers:
```bash
# Test from Google DNS
dig @8.8.8.8 tm.roodyadamsapp.com +short

# Test from Cloudflare DNS
dig @1.1.1.1 tm.roodyadamsapp.com +short
```

If external DNS servers can't resolve it, but your local DNS can, it's likely a zone mismatch issue.

## ✅ The Fix

1. **Identified** which zone the registrar points to (Zone 2)
2. **Created** DNS record in that zone (Zone 2)
3. **Updated** Terraform to manage the correct zone
4. **Synced** Terraform state with the new record

## 📚 Files Modified

1. **`infra/main.tf`** (Line 64)
   - Changed `hosted_zone_id` from Zone 1 to Zone 2

2. **Route53 Zone 2** (via AWS CLI)
   - Created A record pointing to ALB

3. **Terraform State**
   - Removed old Zone 1 record
   - Imported new Zone 2 record

## 🎯 Takeaway

**Always ensure your DNS records are in the same Route53 hosted zone that your domain registrar points to!**

To find out which zone to use:
1. Check nameservers from `whois` command
2. Find which Route53 zone has those nameservers
3. Use that zone ID in your Terraform configuration


