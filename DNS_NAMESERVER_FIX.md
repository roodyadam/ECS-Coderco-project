# DNS Nameserver Fix Guide

## 🔴 The Problem

Your website works for you but not for your friend because:

1. **Your domain registrar** is pointing to **WRONG nameservers**
2. **Your Route53 zone** has the correct DNS records, but uses **DIFFERENT nameservers**
3. External DNS servers query the wrong nameservers → can't find your DNS record → site doesn't work

## ✅ The Solution

Update your domain registrar to use the **correct nameservers** from your Route53 zone.

### Step 1: Get the Correct Nameservers

Your Route53 zone nameservers are:
```
ns-896.awsdns-48.net
ns-107.awsdns-13.com
ns-1459.awsdns-54.org
ns-1909.awsdns-46.co.uk
```

### Step 2: Update Your Domain Registrar

1. Log into your domain registrar (where you bought `roodyadamsapp.com`)
2. Find the **DNS settings** or **Nameservers** section
3. Replace the current nameservers with:
   - `ns-896.awsdns-48.net`
   - `ns-107.awsdns-13.com`
   - `ns-1459.awsdns-54.org`
   - `ns-1909.awsdns-46.co.uk`
4. Save the changes

### Step 3: Wait for Propagation

- DNS changes can take **24-48 hours** to propagate globally
- Some locations may see the change in minutes, others may take hours
- Use online DNS checkers to verify: https://dnschecker.org

### Step 4: Verify the Fix

After updating nameservers, verify with:

```bash
# Check nameservers
dig NS roodyadamsapp.com +short

# Should return:
# ns-896.awsdns-48.net.
# ns-107.awsdns-13.com.
# ns-1459.awsdns-54.org.
# ns-1909.awsdns-46.co.uk.

# Test DNS resolution from external servers
dig @8.8.8.8 tm.roodyadamsapp.com +short
# Should return IP addresses

# Test from Cloudflare DNS
dig @1.1.1.1 tm.roodyadamsapp.com +short
# Should return IP addresses
```

## 🔍 How to Find Your Domain Registrar

If you're not sure where you registered the domain:

1. Check your email for registration confirmation
2. Check `whois roodyadamsapp.com` - look for "Registrar"
3. Common registrars: GoDaddy, Namecheap, Route53, AWS, Google Domains

## 📋 Quick Reference

**Current (WRONG) Nameservers:**
- NS-1509.AWSDNS-60.ORG
- NS-1622.AWSDNS-10.CO.UK
- NS-460.AWSDNS-57.COM
- NS-716.AWSDNS-25.NET

**Correct Nameservers (UPDATE YOUR REGISTRAR):**
- ns-896.awsdns-48.net
- ns-107.awsdns-13.com
- ns-1459.awsdns-54.org
- ns-1909.awsdns-46.co.uk

## ⚠️ Important Notes

1. **Don't delete the Route53 zone** - it has your DNS records
2. **Update the registrar**, not Route53
3. **Wait 24-48 hours** for global propagation
4. **Clear DNS cache** on your friend's device after 24 hours:
   - Windows: `ipconfig /flushdns`
   - Mac: `sudo dscacheutil -flushcache`
   - Linux: `sudo systemd-resolve --flush-caches`

## 🎯 Expected Result

After updating nameservers and waiting for propagation:
- ✅ Your friend can access https://tm.roodyadamsapp.com
- ✅ External DNS servers can resolve the domain
- ✅ Site works from any location globally

