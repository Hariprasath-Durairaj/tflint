provider "azurerm" {
  features {}
}
# Virtual Network
module "vnet" {
  source              = "../../terraform_modules/terraform-azure-network"
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  subnets             = var.subnets
  tags                = var.tags
}

# Public IP for NGINX Ingress
module "public_ip_nginx" {
  source              = "../../terraform_modules/terraform-azure-public-ip"
  name                = var.public_ip_nginx_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# AKS Cluster
module "aks" {
  source                          = "../../terraform_modules/terraform-azure-aks"
  name                            = var.aks_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  dns_prefix                      = var.dns_prefix
  kubernetes_version              = var.kubernetes_version
  node_resource_group             = var.node_resource_group
  acr_id                          = module.acr.acr_id
  log_analytics_workspace_id      = module.log_analytics.workspace_id
  enable_monitoring               = true
  private_cluster_enabled         = false
  api_server_authorized_ip_ranges = []

  default_node_pool = merge(var.default_node_pool, {
    vnet_subnet_id              = module.vnet.subnet_ids["aks-subnet"]
    temporary_name_for_rotation = "sysrotate01"
  })

  user_node_pools = {
    for k, v in var.user_node_pools : k => merge(v, {
      vnet_subnet_id = module.vnet.subnet_ids["aks-subnet"]
    })
  }

  network_plugin = var.network_plugin
  dns_service_ip = var.dns_service_ip
  service_cidr   = var.service_cidr
  tags           = var.tags
}

# Kubernetes provider
provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}

# Helm provider
provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = base64decode(module.aks.client_certificate)
    client_key             = base64decode(module.aks.client_key)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}

resource "kubernetes_namespace" "bitnobi" {
  metadata {
    name = "bitnobi"
  }
}

resource "kubernetes_namespace" "candig" {
  metadata {
    name = "candig"
  }
}

resource "kubernetes_namespace" "keycloak" {
  metadata {
    name = "keycloak"
  }
}

resource "kubernetes_namespace" "integrateai" {
  metadata {
    name = "integrateai"
  }
}

resource "kubernetes_namespace" "webapp" {
  metadata {
    name = "webapp"
  }
}

# NGINX Ingress Controller via Helm
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.6"

  set {
    name  = "controller.enableWAF"
    value = "true"
  }

  set {
    name  = "controller.waf.enable"
    value = "true"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = module.public_ip_nginx.public_ip_id
  }

  depends_on = [module.aks]
}

# Private DNS Zone
module "private_dns" {
  source                = "../../terraform_modules/terraform-azure-private-dns"
  name                  = var.private_dns_name
  resource_group_name   = var.resource_group_name
  link_name             = var.private_dns_link_name
  virtual_network_id    = module.vnet.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

# Azure Key Vault
module "key_vault" {
  source              = "../../terraform_modules/terraform-azure-key-vault"
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  tags                = var.tags
}

# Azure Container Registry
module "acr" {
  source              = "../../terraform_modules/terraform-azure-acr"
  name                = var.acr_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# ACR Pull Permission for AKS
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id = module.aks.kubelet_identity_object_id
}

# Log Analytics Workspace
module "log_analytics" {
  source              = "../../terraform_modules/terraform-azure-log-analytics"
  name                = var.log_analytics_name
  location            = var.location
  resource_group_name = var.resource_group_name
  retention_in_days   = var.log_retention
  tags                = var.tags
}

# Disk Encryption Set
module "disk_encryption_set" {
  source              = "../../terraform_modules/terraform-azure-disk-encryption-set"
  name                = var.des_name
  location            = var.location
  resource_group_name = var.resource_group_name
  key_vault_key_id    = var.key_vault_key_id
  tags                = var.tags
}

# NSG
module "nsg" {
  source              = "../../terraform_modules/terraform-azure-nsg"
  nsg_name            = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.vnet.subnet_ids["aks-subnet"]
  nsg_security_rules  = var.nsg_security_rules 
  tags                = var.tags
}

# Backup Vault
module "backup" {
  source              = "../../terraform_modules/terraform-azure-backup"
  name                = var.backup_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

module "waf_policy" {
  source                  = "../../terraform_modules/terraform-azure-waf"
  name                    = "dhdp-waf-policy"
  location                = var.location
  resource_group_name     = var.resource_group_name
  mode                    = "Prevention"
  file_upload_limit_in_mb = 100
  max_request_body_size_in_kb = 128
  custom_rules            = [] # Or provide rules as needed
  owasp_version           = "3.2"
  tags                    = var.tags
}


module "app_gateway" {
  source              = "../../terraform_modules/terraform-azure-app-gateway"
  name                = var.app_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.vnet.subnet_ids[var.app_gateway_subnet_name]
  public_ip_id        = module.public_ip_nginx.public_ip_id # Or your dedicated AppGW IP
  frontend_port       = var.app_gateway_frontend_port
  backend_ip_addresses = var.app_gateway_backend_ip_addresses
  backend_port        = var.app_gateway_backend_port
  sku_name            = var.app_gateway_sku_name
  sku_tier            = var.app_gateway_sku_tier
  capacity            = var.app_gateway_capacity
  firewall_policy_id  = module.waf_policy.waf_policy_id
  tags                = var.app_gateway_tags
}

