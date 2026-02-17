# Azure Landing Zone - Hub and Spoke Architecture
# Following Azure Well-Architected Framework principles

# Resource Groups
resource "azurerm_resource_group" "rg_hub" {
  name     = "rg-hub-${var.environment}-${var.location}-001"
  location = var.location
  tags     = merge(var.tags, { Purpose = "HubNetwork" })
}

resource "azurerm_resource_group" "rg_spoke_workload" {
  name     = "rg-spoke-workload-${var.environment}-${var.location}-001"
  location = var.location
  tags     = merge(var.tags, { Purpose = "SpokeWorkload" })
}

resource "azurerm_resource_group" "rg_spoke_services" {
  name     = "rg-spoke-services-${var.environment}-${var.location}-001"
  location = var.location
  tags     = merge(var.tags, { Purpose = "SpokeServices" })
}

resource "azurerm_resource_group" "rg_monitoring" {
  name     = "rg-monitoring-${var.environment}-${var.location}-001"
  location = var.location
  tags     = merge(var.tags, { Purpose = "Monitoring" })
}

# Monitoring Module - Deploy first for logging
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = azurerm_resource_group.rg_monitoring.name
  location            = var.location
  environment         = var.environment
  tags                = var.tags
}

# Hub Network Module
module "hub_network" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.rg_hub.name
  location            = var.location
  environment         = var.environment
  vnet_name           = "vnet-hub-${var.environment}-${var.location}-001"
  address_space       = var.hub_vnet_address_space
  subnets             = var.hub_subnets
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                = merge(var.tags, { NetworkRole = "Hub" })
}

# Spoke Workload Network Module
module "spoke_workload_network" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.rg_spoke_workload.name
  location            = var.location
  environment         = var.environment
  vnet_name           = "vnet-spoke-workload-${var.environment}-${var.location}-001"
  address_space       = var.spoke_workload_vnet_address_space
  subnets             = var.spoke_workload_subnets
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                = merge(var.tags, { NetworkRole = "SpokeWorkload" })
}

# Spoke Services Network Module
module "spoke_services_network" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.rg_spoke_services.name
  location            = var.location
  environment         = var.environment
  vnet_name           = "vnet-spoke-services-${var.environment}-${var.location}-001"
  address_space       = var.spoke_services_vnet_address_space
  subnets             = var.spoke_services_subnets
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                = merge(var.tags, { NetworkRole = "SpokeServices" })
}

# VNet Peering: Hub to Spoke Workload
resource "azurerm_virtual_network_peering" "hub_to_spoke_workload" {
  name                         = "peer-hub-to-spoke-workload"
  resource_group_name          = azurerm_resource_group.rg_hub.name
  virtual_network_name         = module.hub_network.vnet_name
  remote_virtual_network_id    = module.spoke_workload_network.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

# VNet Peering: Spoke Workload to Hub
resource "azurerm_virtual_network_peering" "spoke_workload_to_hub" {
  name                         = "peer-spoke-workload-to-hub"
  resource_group_name          = azurerm_resource_group.rg_spoke_workload.name
  virtual_network_name         = module.spoke_workload_network.vnet_name
  remote_virtual_network_id    = module.hub_network.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
}

# VNet Peering: Hub to Spoke Services
resource "azurerm_virtual_network_peering" "hub_to_spoke_services" {
  name                         = "peer-hub-to-spoke-services"
  resource_group_name          = azurerm_resource_group.rg_hub.name
  virtual_network_name         = module.hub_network.vnet_name
  remote_virtual_network_id    = module.spoke_services_network.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

# VNet Peering: Spoke Services to Hub
resource "azurerm_virtual_network_peering" "spoke_services_to_hub" {
  name                         = "peer-spoke-services-to-hub"
  resource_group_name          = azurerm_resource_group.rg_spoke_services.name
  virtual_network_name         = module.spoke_services_network.vnet_name
  remote_virtual_network_id    = module.hub_network.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
}

# Network Security Groups Module for Hub
module "nsg_hub" {
  source = "./modules/nsg"

  resource_group_name = azurerm_resource_group.rg_hub.name
  location            = var.location
  environment         = var.environment
  nsg_name            = "nsg-hub-management-${var.environment}-${var.location}-001"
  subnet_id           = module.hub_network.subnet_ids["ManagementSubnet"]
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
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
    },
    {
      name                       = "AllowSSHInbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAllInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
  tags = merge(var.tags, { Purpose = "HubManagement" })
}

# Network Security Groups Module for Spoke Workload
module "nsg_spoke_workload" {
  source = "./modules/nsg"

  resource_group_name = azurerm_resource_group.rg_spoke_workload.name
  location            = var.location
  environment         = var.environment
  nsg_name            = "nsg-spoke-workload-${var.environment}-${var.location}-001"
  subnet_id           = module.spoke_workload_network.subnet_ids["WorkloadSubnet"]
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  security_rules = [
    {
      name                       = "AllowHTTPInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTPSInbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAllInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
  tags = merge(var.tags, { Purpose = "SpokeWorkload" })
}

# Network Security Groups Module for Spoke Services
module "nsg_spoke_services" {
  source = "./modules/nsg"

  resource_group_name = azurerm_resource_group.rg_spoke_services.name
  location            = var.location
  environment         = var.environment
  nsg_name            = "nsg-spoke-services-${var.environment}-${var.location}-001"
  subnet_id           = module.spoke_services_network.subnet_ids["ServicesSubnet"]
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  security_rules = [
    {
      name                       = "AllowServicesInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAllInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
  tags = merge(var.tags, { Purpose = "SpokeServices" })
}

# Route Table Module for Spoke Workload
module "route_table_spoke_workload" {
  source = "./modules/route-table"

  resource_group_name = azurerm_resource_group.rg_spoke_workload.name
  location            = var.location
  environment         = var.environment
  route_table_name    = "rt-spoke-workload-${var.environment}-${var.location}-001"
  subnet_id           = module.spoke_workload_network.subnet_ids["WorkloadSubnet"]
  routes = [
    {
      name                   = "route-to-hub"
      address_prefix         = "10.0.0.0/16"
      next_hop_type          = "VnetLocal"
      next_hop_in_ip_address = null
    },
    {
      name                   = "route-to-services"
      address_prefix         = "10.2.0.0/16"
      next_hop_type          = "VirtualNetworkGateway"
      next_hop_in_ip_address = null
    }
  ]
  tags = merge(var.tags, { Purpose = "SpokeWorkloadRouting" })
}

# Route Table Module for Spoke Services
module "route_table_spoke_services" {
  source = "./modules/route-table"

  resource_group_name = azurerm_resource_group.rg_spoke_services.name
  location            = var.location
  environment         = var.environment
  route_table_name    = "rt-spoke-services-${var.environment}-${var.location}-001"
  subnet_id           = module.spoke_services_network.subnet_ids["ServicesSubnet"]
  routes = [
    {
      name                   = "route-to-hub"
      address_prefix         = "10.0.0.0/16"
      next_hop_type          = "VnetLocal"
      next_hop_in_ip_address = null
    },
    {
      name                   = "route-to-workload"
      address_prefix         = "10.1.0.0/16"
      next_hop_type          = "VirtualNetworkGateway"
      next_hop_in_ip_address = null
    }
  ]
  tags = merge(var.tags, { Purpose = "SpokeServicesRouting" })
}
