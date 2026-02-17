# Cost Analysis - Azure Landing Zone

## Overview

This document provides a detailed cost analysis of the Azure Landing Zone deployment. The goal is to ensure all resources are either free or have minimal costs for testing purposes.

## Free Resources

The following resources deployed by this landing zone are **completely free**:

### Network Resources (FREE)
- ✅ **Virtual Networks (VNets)**: No charge for VNets
- ✅ **Subnets**: No charge for subnets
- ✅ **Network Security Groups (NSGs)**: No charge for NSGs or rules
- ✅ **Route Tables**: No charge for route tables or routes
- ✅ **VNet Peering (same region)**: Free for data transfer within Germany West Central

### Security Resources (FREE)
- ✅ **NSG Flow Logs Storage**: Not enabled in this deployment (would incur storage costs)
- ✅ **Diagnostic Logs**: Collection is free; storage in Log Analytics has limits (see below)

## Resources with Free Tiers

### Log Analytics Workspace

**SKU**: PerGB2018 (Pay-as-you-go)
**Free Tier**: First 5 GB per month
**Retention**: 30 days (within free tier; 31-730 days would incur costs)

**Estimated Monthly Ingestion**:
- VNet diagnostic logs: ~10-50 MB/month (very low)
- NSG diagnostic logs: ~50-200 MB/month (low, depends on traffic)
- **Total Estimated**: ~60-250 MB/month

**Cost Estimate**: **$0/month** (well within 5GB free tier)

**Cost if Exceeded**:
- After 5GB: $2.76 per GB (Germany West Central pricing as of 2024)
- For this landing zone with minimal traffic, you should stay well under 5GB

## Resources NOT Deployed (Would Incur Costs)

The following resources are commonly part of landing zones but are NOT deployed to keep costs at zero:

### Not Deployed - Azure Firewall
- ❌ **Azure Firewall**: ~$913/month
- ❌ **Azure Firewall Basic**: ~$100/month
- **Note**: AzureFirewallSubnet is created but no firewall is deployed

### Not Deployed - VPN Gateway
- ❌ **VPN Gateway Basic**: ~$27/month
- ❌ **VPN Gateway VpnGw1**: ~$143/month
- **Note**: GatewaySubnet is created but no gateway is deployed

### Not Deployed - Azure Bastion
- ❌ **Azure Bastion Basic**: ~$137/month
- ❌ **Azure Bastion Standard**: ~$179/month

### Not Deployed - Virtual Machines
- ❌ **Windows VM (B1s)**: ~$10/month
- ❌ **Linux VM (B1s)**: ~$4/month
- ❌ **Storage for VM disks**: ~$3-5/month per disk

### Not Deployed - Storage Accounts
- ❌ **Storage Account (LRS)**: ~$0.02-0.05/GB/month
- **Note**: Not needed for basic network infrastructure

## Data Transfer Costs

### Within Region (Germany West Central)
- ✅ **VNet Peering (same region)**: FREE
- ✅ **Between VNets**: FREE
- ✅ **Between Subnets**: FREE

### Cross-Region or Internet
- ❌ **Outbound to Internet**: First 100GB free, then $0.087/GB
- ❌ **Cross-region VNet peering**: $0.035/GB
- **Note**: This deployment keeps everything in one region

## Monthly Cost Summary

| Resource Category | Estimated Monthly Cost |
|------------------|----------------------|
| Virtual Networks | $0 |
| Network Security Groups | $0 |
| Route Tables | $0 |
| VNet Peering (same region) | $0 |
| Log Analytics Workspace | $0 (within free 5GB) |
| **TOTAL** | **$0/month** |

## Cost Monitoring Recommendations

### 1. Set Up Budget Alerts

Create a budget in Azure Cost Management to get alerts if costs exceed $5/month:

```bash
az consumption budget create \
  --budget-name "LandingZoneTestBudget" \
  --amount 5 \
  --time-grain Monthly \
  --start-date 2024-01-01 \
  --end-date 2025-12-31 \
  --subscription efb80fd1-010b-4344-86f0-55a423d10a1e
```

### 2. Monitor Log Analytics Ingestion

Check Log Analytics ingestion daily:

```bash
az monitor log-analytics workspace show \
  --resource-group rg-monitoring-test-germanywestcentral-001 \
  --workspace-name log-test-germanywestcentral-001 \
  --query "retentionInDays"
```

View ingestion in Azure Portal:
1. Navigate to Log Analytics Workspace
2. Go to "Usage and estimated costs"
3. Check "Data Ingestion" graph

### 3. Review Azure Advisor Recommendations

Azure Advisor provides cost optimization recommendations:

```bash
az advisor recommendation list \
  --subscription efb80fd1-010b-4344-86f0-55a423d10a1e \
  --category Cost
```

## Potential Cost Scenarios

### Scenario 1: Adding a Test VM

If you add a B1s Linux VM for testing:
- VM: ~$4/month
- Managed Disk (32GB): ~$3/month
- Public IP (if added): ~$3/month
- **Total**: ~$10/month

### Scenario 2: Exceeding Log Analytics Free Tier

If you exceed 5GB/month:
- 10GB ingestion: $0 (5GB free) + $13.80 (5GB × $2.76)
- **Total**: ~$13.80/month

### Scenario 3: Adding Azure Bastion

If you need secure VM access:
- Azure Bastion Basic: ~$137/month
- **Alternative**: Use Azure Cloud Shell (free) or VPN Gateway (cheaper)

## Cost Optimization Tips

1. **Delete When Not in Use**
   ```bash
   terraform destroy
   ```

2. **Use Auto-Shutdown for VMs** (if you add any)
   - Configure auto-shutdown schedules
   - Stop VMs during non-business hours

3. **Monitor Log Analytics Ingestion**
   - Reduce retention if needed (minimum 30 days)
   - Filter unnecessary logs

4. **Avoid Premium SKUs**
   - Use Basic/Standard SKUs for testing
   - Only use Premium for production

5. **Use Azure Dev/Test Pricing**
   - If you have Visual Studio subscription
   - Up to 55% savings on VMs

## Cleanup Instructions

To remove all resources and stop any potential costs:

```bash
cd "C:\Users\chrismunnik\Documents\TF-LZ-Test"
terraform destroy -auto-approve
```

Verify deletion in Azure Portal:
1. Check Resource Groups are deleted
2. Check "All resources" for any orphaned resources
3. Review "Cost Management + Billing" for any remaining charges

## Cost Reporting

### View Current Costs

```bash
# View costs for the subscription
az consumption usage list \
  --subscription efb80fd1-010b-4344-86f0-55a423d10a1e \
  --start-date 2024-01-01 \
  --end-date 2024-01-31

# View cost by resource group
az consumption usage list \
  --subscription efb80fd1-010b-4344-86f0-55a423d10a1e \
  --start-date 2024-01-01 \
  --end-date 2024-01-31 \
  --query "[?contains(instanceName, 'rg-hub-test')]"
```

### Export Cost Data

```bash
# Export to CSV
az consumption usage list \
  --subscription efb80fd1-010b-4344-86f0-55a423d10a1e \
  --start-date 2024-01-01 \
  --end-date 2024-01-31 \
  --output table > costs.csv
```

## Important Disclaimers

1. **Prices Change**: Azure pricing changes periodically. Check [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) for current rates.

2. **Regional Differences**: Prices vary by region. This analysis uses Germany West Central pricing.

3. **Data Transfer**: Unexpected data transfer (e.g., large file downloads) can incur costs.

4. **Hidden Costs**: Some Azure services have dependencies that may incur costs (e.g., storage for flow logs).

5. **Free Tier Limits**: Free tiers have monthly limits. Exceeding these limits will incur charges.

## Support and Questions

For detailed Azure pricing information:
- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- [Azure Virtual Network Pricing](https://azure.microsoft.com/pricing/details/virtual-network/)
- [Azure Monitor Pricing](https://azure.microsoft.com/pricing/details/monitor/)
- [Azure Cost Management](https://azure.microsoft.com/services/cost-management/)

## Conclusion

This Azure Landing Zone is designed to be **cost-free** for testing purposes by:
- Using only free network resources
- Staying within Log Analytics free tier (5GB/month)
- Not deploying costly services (Firewall, VPN, VMs)
- Keeping all resources in a single region

As long as you don't add additional resources or exceed the 5GB Log Analytics limit, your monthly cost should be **$0**.
