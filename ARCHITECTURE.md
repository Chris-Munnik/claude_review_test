# Azure Landing Zone Architecture

## Overview

This document describes the architecture of the Azure Landing Zone with a hub-spoke network topology deployed in Germany West Central region.

## Network Topology

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Subscription                        │
│              efb80fd1-010b-4344-86f0-55a423d10a1e           │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Hub VNet (10.0.0.0/16)                     │    │
│  │    rg-hub-test-germanywestcentral-001              │    │
│  │                                                     │    │
│  │  ┌─────────────────────────────────────┐          │    │
│  │  │ GatewaySubnet (10.0.0.0/24)        │          │    │
│  │  │ (Reserved for VPN Gateway)          │          │    │
│  │  └─────────────────────────────────────┘          │    │
│  │                                                     │    │
│  │  ┌─────────────────────────────────────┐          │    │
│  │  │ AzureFirewallSubnet (10.0.1.0/24)  │          │    │
│  │  │ (Reserved for Azure Firewall)       │          │    │
│  │  └─────────────────────────────────────┘          │    │
│  │                                                     │    │
│  │  ┌─────────────────────────────────────┐          │    │
│  │  │ ManagementSubnet (10.0.2.0/24)     │          │    │
│  │  │ + NSG (Hub Management)              │          │    │
│  │  └─────────────────────────────────────┘          │    │
│  │                                                     │    │
│  └──────────────┬──────────────────┬──────────────────┘    │
│                 │                  │                        │
│         VNet    │                  │    VNet                │
│        Peering  │                  │   Peering              │
│                 │                  │                        │
│  ┌──────────────▼────────────┐  ┌─▼──────────────────┐   │
│  │  Spoke Workload VNet      │  │ Spoke Services VNet │   │
│  │     (10.1.0.0/16)         │  │    (10.2.0.0/16)    │   │
│  │  rg-spoke-workload-...    │  │  rg-spoke-services-...│  │
│  │                            │  │                     │   │
│  │  ┌──────────────────────┐ │  │ ┌─────────────────┐│   │
│  │  │ WorkloadSubnet       │ │  │ │ ServicesSubnet  ││   │
│  │  │   (10.1.0.0/24)      │ │  │ │  (10.2.0.0/24)  ││   │
│  │  │ + NSG (Workload)     │ │  │ │ + NSG (Services)││   │
│  │  │ + Route Table        │ │  │ │ + Route Table   ││   │
│  │  └──────────────────────┘ │  │ └─────────────────┘│   │
│  │                            │  │                     │   │
│  └────────────────────────────┘  └─────────────────────┘   │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │           Monitoring Resources                      │    │
│  │    rg-monitoring-test-germanywestcentral-001       │    │
│  │                                                     │    │
│  │  ┌─────────────────────────────────────┐          │    │
│  │  │ Log Analytics Workspace              │          │    │
│  │  │ (PerGB2018 SKU, 30-day retention)   │          │    │
│  │  │ - VNet Diagnostics                   │          │    │
│  │  │ - NSG Diagnostics                    │          │    │
│  │  └─────────────────────────────────────┘          │    │
│  │                                                     │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Resource Hierarchy

```
Subscription: efb80fd1-010b-4344-86f0-55a423d10a1e
├── Resource Group: rg-hub-test-germanywestcentral-001
│   ├── Virtual Network: vnet-hub-test-germanywestcentral-001
│   │   ├── Subnet: GatewaySubnet (10.0.0.0/24)
│   │   ├── Subnet: AzureFirewallSubnet (10.0.1.0/24)
│   │   └── Subnet: ManagementSubnet (10.0.2.0/24)
│   ├── Network Security Group: nsg-hub-management-test-germanywestcentral-001
│   ├── VNet Peering: peer-hub-to-spoke-workload
│   └── VNet Peering: peer-hub-to-spoke-services
│
├── Resource Group: rg-spoke-workload-test-germanywestcentral-001
│   ├── Virtual Network: vnet-spoke-workload-test-germanywestcentral-001
│   │   └── Subnet: WorkloadSubnet (10.1.0.0/24)
│   ├── Network Security Group: nsg-spoke-workload-test-germanywestcentral-001
│   ├── Route Table: rt-spoke-workload-test-germanywestcentral-001
│   └── VNet Peering: peer-spoke-workload-to-hub
│
├── Resource Group: rg-spoke-services-test-germanywestcentral-001
│   ├── Virtual Network: vnet-spoke-services-test-germanywestcentral-001
│   │   └── Subnet: ServicesSubnet (10.2.0.0/24)
│   ├── Network Security Group: nsg-spoke-services-test-germanywestcentral-001
│   ├── Route Table: rt-spoke-services-test-germanywestcentral-001
│   └── VNet Peering: peer-spoke-services-to-hub
│
└── Resource Group: rg-monitoring-test-germanywestcentral-001
    └── Log Analytics Workspace: log-test-germanywestcentral-001
```

## Naming Convention

This landing zone follows the Azure Cloud Adoption Framework (CAF) naming convention:

| Resource Type | Pattern | Example |
|--------------|---------|---------|
| Resource Group | `rg-{purpose}-{environment}-{region}-{instance}` | `rg-hub-test-germanywestcentral-001` |
| Virtual Network | `vnet-{purpose}-{environment}-{region}-{instance}` | `vnet-hub-test-germanywestcentral-001` |
| Subnet | `{purpose}Subnet` | `ManagementSubnet` |
| Network Security Group | `nsg-{purpose}-{environment}-{region}-{instance}` | `nsg-hub-management-test-germanywestcentral-001` |
| Route Table | `rt-{purpose}-{environment}-{region}-{instance}` | `rt-spoke-workload-test-germanywestcentral-001` |
| Log Analytics | `log-{environment}-{region}-{instance}` | `log-test-germanywestcentral-001` |

## Network Security

### Hub Management Subnet NSG Rules

| Priority | Name | Direction | Action | Protocol | Port | Source | Destination |
|----------|------|-----------|--------|----------|------|--------|-------------|
| 100 | AllowHTTPSInbound | Inbound | Allow | TCP | 443 | VirtualNetwork | * |
| 110 | AllowSSHInbound | Inbound | Allow | TCP | 22 | VirtualNetwork | * |
| 4096 | DenyAllInbound | Inbound | Deny | * | * | * | * |

### Spoke Workload Subnet NSG Rules

| Priority | Name | Direction | Action | Protocol | Port | Source | Destination |
|----------|------|-----------|--------|----------|------|--------|-------------|
| 100 | AllowHTTPInbound | Inbound | Allow | TCP | 80 | VirtualNetwork | * |
| 110 | AllowHTTPSInbound | Inbound | Allow | TCP | 443 | VirtualNetwork | * |
| 4096 | DenyAllInbound | Inbound | Deny | * | * | * | * |

### Spoke Services Subnet NSG Rules

| Priority | Name | Direction | Action | Protocol | Port | Source | Destination |
|----------|------|-----------|--------|----------|------|--------|-------------|
| 100 | AllowServicesInbound | Inbound | Allow | TCP | 443 | VirtualNetwork | * |
| 4096 | DenyAllInbound | Inbound | Deny | * | * | * | * |

## Routing

### Spoke Workload Route Table

| Route Name | Address Prefix | Next Hop Type |
|------------|---------------|---------------|
| route-to-hub | 10.0.0.0/16 | VnetLocal |
| route-to-services | 10.2.0.0/16 | VirtualNetworkGateway |

### Spoke Services Route Table

| Route Name | Address Prefix | Next Hop Type |
|------------|---------------|---------------|
| route-to-hub | 10.0.0.0/16 | VnetLocal |
| route-to-workload | 10.1.0.0/16 | VirtualNetworkGateway |

## Traffic Flow

1. **Inter-Spoke Communication**: Traffic between spokes flows through the hub VNet (no direct spoke-to-spoke peering)
2. **Hub Management**: Hub management subnet can communicate with all spokes
3. **Internet Access**: All subnets have default internet access via Azure's default routing
4. **Isolation**: NSGs provide network-level isolation and security between subnets

## Well-Architected Framework Alignment

### Reliability
- Hub-spoke topology provides network redundancy
- Multiple spokes can be added independently
- VNet peering provides high bandwidth, low latency connectivity

### Security
- Network segmentation through hub-spoke topology
- NSGs with default-deny rules
- Centralized logging to Log Analytics
- Service endpoints for Azure PaaS services

### Cost Optimization
- Using free-tier resources where possible
- Log Analytics with 5GB free tier
- No expensive network appliances (Firewall, VPN Gateway) deployed by default
- Modular design allows adding resources as needed

### Operational Excellence
- Infrastructure as Code with Terraform
- Modular design for reusability
- Comprehensive diagnostic logging
- Clear naming conventions

### Performance Efficiency
- Regional deployment in Germany West Central
- VNet peering for high-performance connectivity
- Service endpoints for Azure PaaS services

## Monitoring and Diagnostics

All network resources send diagnostic logs to the centralized Log Analytics Workspace:

- **VNet Diagnostics**: VMProtectionAlerts and AllMetrics
- **NSG Diagnostics**: NetworkSecurityGroupEvent and NetworkSecurityGroupRuleCounter

## Future Enhancements

1. **Azure Bastion**: Secure RDP/SSH access to VMs without public IPs
2. **Azure Firewall**: Centralized network security and traffic inspection
3. **VPN Gateway**: Hybrid connectivity to on-premises networks
4. **Azure Policy**: Governance and compliance enforcement
5. **Azure Monitor Alerts**: Proactive monitoring and alerting
6. **Additional Spokes**: Additional spoke VNets for different workloads

## Compliance

This architecture follows:
- Azure Well-Architected Framework
- Azure Landing Zone design principles
- Cloud Adoption Framework (CAF) best practices
- Defense-in-depth security model
