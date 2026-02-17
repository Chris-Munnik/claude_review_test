# Azure Landing Zone - Hub and Spoke Architecture

This Terraform configuration deploys an Azure Landing Zone following the Azure Well-Architected Framework with a hub-spoke network topology in a single subscription.

## Architecture Overview

This landing zone implements:

- **Hub-Spoke Network Topology**: Central hub VNet connected to multiple spoke VNets
- **Azure Well-Architected Framework**: Following best practices for reliability, security, cost optimization, operational excellence, and performance efficiency
- **Cost-Free Resources**: All resources deployed are free or use free tiers (within limits)
- **CAF Naming Convention**: Industry-standard Cloud Adoption Framework naming convention
- **Modular Design**: Reusable modules for networking, NSG, routing, and monitoring

## Network Architecture

### Address Space

- **Hub VNet**: 10.0.0.0/16
  - GatewaySubnet: 10.0.0.0/24 (reserved for future VPN Gateway)
  - AzureFirewallSubnet: 10.0.1.0/24 (reserved for future Azure Firewall)
  - ManagementSubnet: 10.0.2.0/24 (for management resources)

- **Spoke Workload VNet**: 10.1.0.0/16
  - WorkloadSubnet: 10.1.0.0/24 (for application workloads)

- **Spoke Services VNet**: 10.2.0.0/16
  - ServicesSubnet: 10.2.0.0/24 (for shared services)

### VNet Peering

- Hub to Spoke Workload (bidirectional)
- Hub to Spoke Services (bidirectional)
- Spokes do NOT peer directly with each other (traffic routes through hub)

## Resources Deployed

### Resource Groups

- `rg-hub-test-germanywestcentral-001`: Hub networking resources
- `rg-spoke-workload-test-germanywestcentral-001`: Workload spoke resources
- `rg-spoke-services-test-germanywestcentral-001`: Services spoke resources
- `rg-monitoring-test-germanywestcentral-001`: Monitoring and logging resources

### Networking

- 3 Virtual Networks (hub and 2 spokes)
- 5 Subnets across all VNets
- 4 VNet Peerings (hub-spoke topology)
- Network Security Groups with custom rules
- Route Tables for traffic management

### Monitoring

- Log Analytics Workspace (PerGB2018 SKU with 30-day retention)
- Diagnostic settings for VNets and NSGs

## Prerequisites

1. Azure subscription (Subscription ID: efb80fd1-010b-4344-86f0-55a423d10a1e)
2. Azure CLI or Azure PowerShell installed
3. Terraform 1.5.0 or later installed
4. Appropriate Azure permissions (Contributor or Owner role on the subscription)

## Deployment Instructions

### 1. Authenticate to Azure

Using Azure CLI:

```bash
az login --tenant ac9ff574-a96d-4b6d-8811-15c5d145b220
az account set --subscription efb80fd1-010b-4344-86f0-55a423d10a1e
```

### 2. Initialize Terraform

```bash
cd "C:\Users\chrismunnik\Documents\TF-LZ-Test"
terraform init
```

### 3. Review the Plan

```bash
terraform plan
```

### 4. Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 5. View Outputs

After successful deployment, view the outputs:

```bash
terraform output
```

## Cost Considerations

All resources deployed are designed to be cost-free or use free tiers:

- **Virtual Networks**: Free
- **Subnets**: Free
- **VNet Peering**: Free for data transfer within the same region
- **Network Security Groups**: Free
- **Route Tables**: Free
- **Log Analytics Workspace**: First 5GB/month free

**Important Notes**:
- If you add VMs, storage accounts, or other compute resources, costs will apply
- Log Analytics has a 5GB/month free tier; exceeding this will incur charges
- Keep the retention period at 30 days to stay within free limits

## Modules

### Networking Module

Creates Virtual Networks and subnets with diagnostic logging.

Location: `modules/networking/`

### NSG Module

Creates Network Security Groups with custom rules and associates them with subnets.

Location: `modules/nsg/`

### Route Table Module

Creates route tables with custom routes for traffic management.

Location: `modules/route-table/`

### Monitoring Module

Creates Log Analytics Workspace for centralized logging and monitoring.

Location: `modules/monitoring/`

## Customization

### Modify Address Spaces

Edit [variables.tf](variables.tf) to change VNet address spaces:

```hcl
variable "hub_vnet_address_space" {
  default = ["10.0.0.0/16"]
}
```

### Add Security Rules

Edit [main.tf](main.tf) in the NSG module sections to add or modify security rules:

```hcl
security_rules = [
  {
    name                       = "AllowHTTPSInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
]
```

### Change Region

Edit the `location` variable in [variables.tf](variables.tf):

```hcl
variable "location" {
  default = "germanywestcentral"
}
```

## Azure Well-Architected Framework Alignment

This landing zone follows the five pillars of the Azure Well-Architected Framework:

1. **Reliability**: Hub-spoke topology provides network redundancy and isolation
2. **Security**: NSGs with default-deny rules, network segmentation, diagnostic logging
3. **Cost Optimization**: Using free-tier resources, modular design for granular control
4. **Operational Excellence**: Infrastructure as Code, modular design, comprehensive logging
5. **Performance Efficiency**: Regional deployment, service endpoints for Azure PaaS services

## Cleanup

To remove all deployed resources:

```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

## Troubleshooting

### Issue: Authentication Failed

**Solution**: Ensure you're logged in with Azure CLI and have set the correct subscription:

```bash
az login
az account set --subscription efb80fd1-010b-4344-86f0-55a423d10a1e
```

### Issue: Resource Already Exists

**Solution**: Check if resources with the same names exist in your subscription. You can modify the naming in [variables.tf](variables.tf).

### Issue: Insufficient Permissions

**Solution**: Ensure your account has Contributor or Owner role on the subscription.

## Next Steps

After deploying the landing zone, consider:

1. Adding Azure Bastion for secure VM access (note: costs apply)
2. Deploying application workloads in the spoke VNets
3. Implementing Azure Policy for governance
4. Setting up Azure Monitor alerts
5. Configuring backup and disaster recovery

## Support

For issues or questions:
- Review Terraform documentation: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- Review Azure Well-Architected Framework: https://learn.microsoft.com/azure/architecture/framework/

## License

This configuration is provided as-is for testing and educational purposes.
