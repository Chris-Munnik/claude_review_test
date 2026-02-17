# Outputs for Azure Landing Zone

output "resource_group_ids" {
  description = "IDs of all resource groups"
  value = {
    hub        = azurerm_resource_group.rg_hub.id
    spoke_workload = azurerm_resource_group.rg_spoke_workload.id
    spoke_services = azurerm_resource_group.rg_spoke_services.id
    monitoring = azurerm_resource_group.rg_monitoring.id
  }
}

output "hub_network" {
  description = "Hub network details"
  value = {
    vnet_id   = module.hub_network.vnet_id
    vnet_name = module.hub_network.vnet_name
    subnets   = module.hub_network.subnet_ids
  }
}

output "spoke_workload_network" {
  description = "Spoke workload network details"
  value = {
    vnet_id   = module.spoke_workload_network.vnet_id
    vnet_name = module.spoke_workload_network.vnet_name
    subnets   = module.spoke_workload_network.subnet_ids
  }
}

output "spoke_services_network" {
  description = "Spoke services network details"
  value = {
    vnet_id   = module.spoke_services_network.vnet_id
    vnet_name = module.spoke_services_network.vnet_name
    subnets   = module.spoke_services_network.subnet_ids
  }
}

output "log_analytics_workspace" {
  description = "Log Analytics Workspace details"
  value = {
    id   = module.monitoring.log_analytics_workspace_id
    name = module.monitoring.log_analytics_workspace_name
  }
}

output "network_security_groups" {
  description = "Network Security Group IDs"
  value = {
    hub_management    = module.nsg_hub.nsg_id
    spoke_workload    = module.nsg_spoke_workload.nsg_id
    spoke_services    = module.nsg_spoke_services.nsg_id
  }
}

output "route_tables" {
  description = "Route Table IDs"
  value = {
    spoke_workload = module.route_table_spoke_workload.route_table_id
    spoke_services = module.route_table_spoke_services.route_table_id
  }
}
