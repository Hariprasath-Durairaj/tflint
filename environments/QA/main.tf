###############################################################################
# QA Environment – Root Terraform Config (clean, reusable, AGIC pattern)
###############################################################################

############################
# Providers & Versions are locked in versions.tf
############################
provider "azurerm" {
  features {}
}

############################
# 1. Networking
############################
module "vnet" {
  source              = "../../terraform-modules/terraform-azure-vnet"
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  subnets             = var.subnets   # expects "aks", "appgw", "bastion" keys
  tags                = var.tags
}

# NAT Gateway for deterministic, high‑scale egress
module "nat_gateway" {
  source              = "../../terraform-modules/terraform-azure-nat-gateway"
  name                = var.nat_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  public_ip_count     = 2                     # 128k SNAT ports
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_subnet_nat_gateway_association" "aks" {
  subnet_id      = module.vnet.subnet_ids["aks"]
  nat_gateway_id = module.nat_gateway.id
}

############################
# 2. Public IP for Application Gateway (inbound)
############################
module "public_ip_appgw" {
  source              = "../../terraform-modules/terraform-azure-public-ip"
  name                = var.public_ip_appgw_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.tags
}

############################
# 3. Shared platform services
############################
module "log_analytics" {
  source              = "../../terraform-modules/terraform-azure-log-analytics"
  name                = var.log_analytics_name
  location            = var.location
  resource_group_name = var.resource_group_name
  retention_in_days   = var.log_retention
  tags                = var.tags
}

module "key_vault" {
  source              = "../../terraform-modules/terraform-azure-key-vault"
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  tags                = var.tags
}

module "acr" {
  source              = "../../terraform-modules/terraform-azure-acr"
  name                = var.acr_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

module "disk_encryption_set" {
  source              = "../../terraform-modules/terraform-azure-disk-encryption-set"
  name                = var.des_name
  location            = var.location
  resource_group_name = var.resource_group_name
  key_vault_key_id    = var.key_vault_key_id
  tags                = var.tags
}

module "backup" {
  source              = "../../terraform-modules/terraform-azure-backup"
  name                = var.backup_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

############################
# 4. Security – NSG for AKS subnet
############################
module "nsg" {
  source              = "../../terraform-modules/terraform-azure-nsg"
  nsg_name            = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.vnet.subnet_ids["aks"]
  nsg_security_rules  = var.nsg_security_rules
  tags                = var.tags
}

############################
# 5. Ingress: WAF + App Gateway
############################
module "waf_policy" {
  source                      = "../../terraform-modules/terraform-azure-waf"
  name                        = "${var.prefix}-waf-policy"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  mode                        = "Prevention"
  owasp_version               = "3.2"
  file_upload_limit_in_mb     = 100
  max_request_body_size_in_kb = 128
  tags                        = var.tags
}

module "app_gateway" {
  source               = "../../terraform-modules/terraform-azure-app-gateway"
  name                 = var.app_gateway_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  subnet_id            = module.vnet.subnet_ids["appgw"]
  public_ip_id         = module.public_ip_appgw.public_ip_id
  frontend_port        = var.app_gateway_frontend_port
  backend_port         = var.app_gateway_backend_port
  sku_name             = var.app_gateway_sku_name
  sku_tier             = var.app_gateway_sku_tier
  capacity             = var.app_gateway_capacity
  firewall_policy_id   = module.waf_policy.waf_policy_id
  zones                = ["1","2","3"]
  tags                 = var.tags
}

############################
# 6. AKS Cluster with AGIC
############################
module "aks" {
  source                          = "../../terraform-modules/terraform-azure-aks"
  name                            = var.aks_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  dns_prefix                      = var.dns_prefix
  kubernetes_version              = var.kubernetes_version
  node_resource_group             = var.node_resource_group
  acr_id                          = module.acr.acr_id
  log_analytics_workspace_id      = module.log_analytics.workspace_id
  private_cluster_enabled         = true
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges

  default_node_pool = merge(var.default_node_pool, {
    vnet_subnet_id      = module.vnet.subnet_ids["aks"]
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 6
    zones               = ["1","2","3"]
  })

  user_node_pools = {
    for k, v in var.user_node_pools : k => merge(v, {
      vnet_subnet_id      = module.vnet.subnet_ids["aks"]
      enable_auto_scaling = true
    })
  }

  network_plugin = var.network_plugin
  dns_service_ip = var.dns_service_ip
  service_cidr   = var.service_cidr

  # Managed App Gateway Ingress Controller addon
  ingress_application_gateway = {
    enabled    = true
    gateway_id = module.app_gateway.app_gateway_id
  }

  tags = var.tags
}

# Allow AKS kubelet identity to pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity_object_id
}

############################
# 7. Private DNS
############################
module "private_dns" {
  source               = "../../terraform-modules/terraform-azure-private-dns"
  name                 = var.private_dns_name
  resource_group_name  = var.resource_group_name
  link_name            = var.private_dns_link_name
  virtual_network_id   = module.vnet.vnet_id
  registration_enabled = false
  tags                 = var.tags
}

############################
# 8. Kubernetes Namespaces (for workloads)
############################
resource "kubernetes_namespace" "workspaces" {
  for_each = toset(["bitnobi", "candig", "keycloak", "integrateai", "webapp"])
  metadata { name = each.key }
}
