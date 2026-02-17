output "route_table_id" {
  description = "ID of the route table"
  value       = azurerm_route_table.route_table.id
}

output "route_table_name" {
  description = "Name of the route table"
  value       = azurerm_route_table.route_table.name
}
