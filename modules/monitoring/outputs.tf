output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.workspace.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.workspace.name
}

output "workspace_id" {
  description = "Workspace ID (customer ID) of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.workspace.workspace_id
}
