output "vnet_peering_id" {
  description = "ID of the VNet peering"
  value       = azurerm_virtual_network_peering.this.id
}