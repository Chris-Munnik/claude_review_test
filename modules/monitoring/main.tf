# Monitoring Module
# Creates Log Analytics Workspace with free tier for centralized logging

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "log-${var.environment}-${var.location}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags

  # Note: The free tier provides 5GB/month of data ingestion
  # After 5GB, pay-as-you-go pricing applies
}
