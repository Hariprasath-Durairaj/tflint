###############################################################################
# outputs.tf – QA Environment                                                #
###############################################################################

# ────────────────────────────────────────────────────────────────────────────
# Core platform IDs
# ────────────────────────────────────────────────────────────────────────────
output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.name
}

output "aks_cluster_id" {
  description = "Resource ID of the AKS cluster"
  value       = module.aks.id
}

output "app_gateway_id" {
  description = "Resource ID of the Application Gateway"
  value       = module.app_gateway.app_gateway_id
}

output "public_ip_app_gateway" {
  description = "Public IP address of the Application Gateway front‑end"
  value       = module.public_ip_appgw.public_ip_address
}

# ────────────────────────────────────────────────────────────────────────────
# Shared services
# ────────────────────────────────────────────────────────────────────────────
output "key_vault_id" {
  description = "ID of the Azure Key Vault"
  value       = module.key_vault.key_vault_id
}

output "acr_id" {
  description = "ID of the Azure Container Registry"
  value       = module.acr.acr_id
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = module.log_analytics.workspace_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway providing outbound egress"
  value       = module.nat_gateway.id
}

output "private_dns_zone_id" {
  description = "ID of the Private DNS zone linked to the VNet"
  value       = module.private_dns.zone_id
}# Outputs
output "public_ip_nginx" {
  value = module.public_ip_nginx.public_ip_address
}

output "key_vault_id" {
  value = module.key_vault.key_vault_id
}

output "acr_id" {
  value = module.acr.acr_id
}

output "log_analytics_workspace_id" {
  value = module.log_analytics.workspace_id
}

output "nginx_ingress_controller_id" {
  value = helm_release.nginx_ingress.id
}
