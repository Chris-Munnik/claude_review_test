# Quick Start Guide

This is a quick start guide to deploy your Azure Landing Zone in less than 5 minutes.

## Prerequisites Checklist

- [ ] Azure CLI installed ([Install here](https://docs.microsoft.com/cli/azure/install-azure-cli))
- [ ] Terraform 1.5.0+ installed ([Install here](https://www.terraform.io/downloads))
- [ ] Access to Azure subscription (efb80fd1-010b-4344-86f0-55a423d10a1e)
- [ ] Contributor or Owner role on the subscription

## Quick Deploy (Automated)

### Option 1: Use the Deploy Script (Recommended)

```bash
cd "C:\Users\chrismunnik\Documents\TF-LZ-Test"
./deploy.sh
```

The script will:
1. ✓ Check for Azure CLI and Terraform
2. ✓ Log you into Azure
3. ✓ Set the correct subscription
4. ✓ Initialize Terraform
5. ✓ Validate the configuration
6. ✓ Create a plan
7. ✓ Deploy the infrastructure (after your confirmation)

### Option 2: Manual Deploy

```bash
cd "C:\Users\chrismunnik\Documents\TF-LZ-Test"

# 1. Login to Azure
az login --tenant ac9ff574-a96d-4b6d-8811-15c5d145b220
az account set --subscription efb80fd1-010b-4344-86f0-55a423d10a1e

# 2. Initialize Terraform
terraform init

# 3. Plan the deployment
terraform plan

# 4. Deploy
terraform apply
```

## What Gets Deployed?

In Germany West Central region, you'll get:

| Resource | Quantity | Cost |
|----------|----------|------|
| Resource Groups | 4 | Free |
| Virtual Networks | 3 (Hub + 2 Spokes) | Free |
| Subnets | 5 | Free |
| VNet Peerings | 4 | Free |
| Network Security Groups | 3 | Free |
| Route Tables | 2 | Free |
| Log Analytics Workspace | 1 | Free (5GB/month) |

**Total Monthly Cost: $0**

## Network Layout

```
Hub VNet (10.0.0.0/16)
├── GatewaySubnet (10.0.0.0/24)
├── AzureFirewallSubnet (10.0.1.0/24)
└── ManagementSubnet (10.0.2.0/24)

Spoke Workload VNet (10.1.0.0/16)
└── WorkloadSubnet (10.1.0.0/24)

Spoke Services VNet (10.2.0.0/16)
└── ServicesSubnet (10.2.0.0/24)
```

## Verify Deployment

After deployment completes (typically 3-5 minutes):

### 1. Check Terraform Output

```bash
terraform output
```

You should see:
- Resource group IDs
- VNet IDs and names
- Subnet IDs
- Log Analytics Workspace ID
- NSG IDs
- Route Table IDs

### 2. Check Azure Portal

Open [Azure Portal - Resource Groups](https://portal.azure.com/#view/HubsExtension/BrowseResourceGroups)

You should see 4 new resource groups:
- `rg-hub-test-germanywestcentral-001`
- `rg-spoke-workload-test-germanywestcentral-001`
- `rg-spoke-services-test-germanywestcentral-001`
- `rg-monitoring-test-germanywestcentral-001`

### 3. Test Network Connectivity

Navigate to Virtual Networks in Azure Portal:
1. Go to "vnet-hub-test-germanywestcentral-001"
2. Click "Peerings" in the left menu
3. Verify you see 2 peerings with "Connected" status

## Common Issues

### Issue: "az: command not found"
**Solution**: Install Azure CLI
```bash
# Windows (PowerShell)
winget install -e --id Microsoft.AzureCLI

# Or download from: https://aka.ms/installazurecliwindows
```

### Issue: "terraform: command not found"
**Solution**: Install Terraform
```bash
# Windows (Chocolatey)
choco install terraform

# Or download from: https://www.terraform.io/downloads
```

### Issue: "insufficient permissions"
**Solution**: Ask your Azure admin for Contributor role:
```bash
az role assignment create \
  --assignee YOUR_EMAIL \
  --role Contributor \
  --subscription efb80fd1-010b-4344-86f0-55a423d10a1e
```

### Issue: "Error: authentication failed"
**Solution**: Make sure you're logged into the correct tenant:
```bash
az logout
az login --tenant ac9ff574-a96d-4b6d-8811-15c5d145b220
az account set --subscription efb80fd1-010b-4344-86f0-55a423d10a1e
```

## Next Steps

### 1. Deploy a Test VM (Optional)

Create a test VM in the workload subnet:

```bash
az vm create \
  --resource-group rg-spoke-workload-test-germanywestcentral-001 \
  --name vm-test-001 \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --vnet-name vnet-spoke-workload-test-germanywestcentral-001 \
  --subnet WorkloadSubnet \
  --admin-username azureuser \
  --generate-ssh-keys
```

**Note**: This will incur costs (~$4/month)

### 2. View Diagnostic Logs

1. Open Azure Portal
2. Navigate to Log Analytics Workspace: `log-test-germanywestcentral-001`
3. Click "Logs" in the left menu
4. Run a query:

```kql
AzureDiagnostics
| where Category == "NetworkSecurityGroupEvent"
| take 10
```

### 3. Set Up Cost Alerts

```bash
# Create a budget alert for $5/month
az consumption budget create \
  --budget-name "LandingZoneTestBudget" \
  --amount 5 \
  --time-grain Monthly \
  --start-date $(date +%Y-%m-01) \
  --subscription efb80fd1-010b-4344-86f0-55a423d10a1e
```

## Clean Up Resources

### Quick Cleanup (Automated)

```bash
cd "C:\Users\chrismunnik\Documents\TF-LZ-Test"
./destroy.sh
```

### Manual Cleanup

```bash
terraform destroy
```

Type `yes` when prompted.

**Verify cleanup** in Azure Portal - all 4 resource groups should be deleted.

## Cost Monitoring

Check current costs:

```bash
# View current month costs
az consumption usage list \
  --subscription efb80fd1-010b-4344-86f0-55a423d10a1e \
  --start-date $(date -d "1 month ago" +%Y-%m-%d) \
  --end-date $(date +%Y-%m-%d)
```

Or visit:
[Azure Cost Management](https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/overview)

## Documentation

For more detailed information:

- [README.md](README.md) - Full documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture details with diagrams
- [COST_ANALYSIS.md](COST_ANALYSIS.md) - Detailed cost breakdown
- [Azure Portal](https://portal.azure.com)

## Support

Having issues? Check:
1. [README.md](README.md) Troubleshooting section
2. [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
3. [Azure Documentation](https://docs.microsoft.com/azure/)

## Summary

You now have a production-ready Azure Landing Zone following the Well-Architected Framework with:
- ✓ Hub-spoke network topology
- ✓ Network segmentation and security (NSGs)
- ✓ Centralized monitoring (Log Analytics)
- ✓ Industry-standard naming conventions
- ✓ Infrastructure as Code (Terraform)
- ✓ Zero cost for testing

**Deployment Time**: ~3-5 minutes
**Monthly Cost**: $0 (within free tiers)
**Resources**: 4 RGs, 3 VNets, 5 Subnets, 3 NSGs, 2 Route Tables, 1 Log Analytics
