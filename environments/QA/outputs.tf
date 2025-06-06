# Outputs
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
