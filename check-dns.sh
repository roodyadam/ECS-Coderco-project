#!/bin/bash
# Quick DNS diagnostic script

echo "=== DNS Diagnostic for tm.roodyadamsapp.com ==="
echo ""

echo "1. Current Nameservers (from registrar):"
whois roodyadamsapp.com 2>/dev/null | grep -i "name server" | head -4
echo ""

echo "2. Route53 Zone Nameservers (CORRECT):"
aws route53 get-hosted-zone --id Z06988621L4AI5LXY4AF3 --query 'DelegationSet.NameServers' --output text 2>/dev/null | tr '\t' '\n'
echo ""

echo "3. DNS Record in Route53:"
aws route53 list-resource-record-sets --hosted-zone-id Z06988621L4AI5LXY4AF3 --query "ResourceRecordSets[?Name=='tm.roodyadamsapp.com.']" --output json 2>/dev/null | jq '.[0] | {Name, Type, AliasTarget}'
echo ""

echo "4. DNS Resolution Test:"
echo "   Local DNS:"
dig tm.roodyadamsapp.com +short | head -2
echo ""
echo "   Google DNS (8.8.8.8):"
dig @8.8.8.8 tm.roodyadamsapp.com +short | head -2 || echo "   ❌ FAILED - nameservers don't match!"
echo ""
echo "   Cloudflare DNS (1.1.1.1):"
dig @1.1.1.1 tm.roodyadamsapp.com +short | head -2 || echo "   ❌ FAILED - nameservers don't match!"
echo ""

echo "=== SUMMARY ==="
echo "If external DNS (8.8.8.8, 1.1.1.1) fails but local works:"
echo "  → Your domain registrar nameservers don't match Route53 zone"
echo "  → Update your registrar to use Route53 nameservers (see DNS_NAMESERVER_FIX.md)"
