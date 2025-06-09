###############################################################################
# terraform.tfvars — **DHDP QA** (clean, AGIC-only pattern)
###############################################################################

########################
# 1. Global settings
########################
prefix               = "dhdp-qa"
location             = "canadacentral"
resource_group_name  = "dhdp-qa-rg"
tenant_id            = "2135e496-4990-4b82-9b82-d8c62774306a"   # replace with real GUID

tags = {
  environment  = "QA"
  businessUnit = "Corp-IT"
  application  = "DHDP"
  owner        = "hp@corp.com"
  managedBy    = "Terraform"
  createdBy    = "AzureDevOps"
  criticality  = "Standard"
}

########################
# 2. Networking
########################
vnet_name     = "${prefix}-vnet"
address_space = ["10.31.0.0/16"]

subnets = {
  aks    = ["10.31.4.0/22"]
  appgw  = ["10.31.64.0/24"]
  AzureBastionSubnet = ["10.31.80.0/27"]
}

nat_gateway_name           = "${prefix}-natgw"
nat_gateway_public_ip_count = 2        # gives 128k SNAT ports

########################
# 3. Network Security Group
########################
nsg_name = "${prefix}-nsg"

nsg_security_rules = [
  {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]

########################
# 4. Private DNS
########################
private_dns_name      = "privatelink.azurecr.io"
private_dns_link_name = "acr-dns-link"

########################
# 5. Key Vault & Encryption
########################
key_vault_name   = "${prefix}-kv"
des_name         = "${prefix}-des"
key_vault_key_id = "https://dhdp-qa-kv.vault.azure.net/keys/dhdp-qa-cmk/0123456789abcdef0123456789abcdef"

########################
# 6. Backup
########################
backup_vault_name = "${prefix}-backup-vault"

########################
# 7. Azure Container Registry
########################
acr_name = "${prefix}acr"

########################
# 8. AKS cluster
########################
aks_name            = "${prefix}-aks"
dns_prefix          = "dhdpqa"
kubernetes_version  = "1.32.3"
node_resource_group = "MC_${resource_group_name}_${aks_name}_${location}"

default_node_pool = {
  name                = "system"
  vm_size             = "Standard_D2s_v5"
  os_disk_size_gb     = 50
  enable_auto_scaling = true
  min_count           = 1
  max_count           = 3
  max_pods            = 30
  availability_zones  = ["1","2","3"]
  node_labels         = { type = "system" }
  vnet_subnet_id      = ""   # auto-set in main.tf
}

user_node_pools = {
  bitnobi = {
    name                = "bitnobi"
    vm_size             = "Standard_D2s_v5"
    os_disk_size_gb     = 100
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 5
    max_pods            = 60
    node_labels         = { app = "bitnobi" }
    taints              = ["app=bitnobi:NoSchedule"]
    availability_zones  = ["1","2","3"]
    vnet_subnet_id      = ""
  }
  candig = {
    name                = "candig"
    vm_size             = "Standard_D2s_v5"
    os_disk_size_gb     = 50
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 5
    max_pods            = 30
    node_labels         = { app = "candig" }
    taints              = ["app=candig:NoSchedule"]
    availability_zones  = ["1","2","3"]
    vnet_subnet_id      = ""
  }
  keycloak = {
    name                = "keycloak"
    vm_size             = "Standard_D2s_v5"
    os_disk_size_gb     = 50
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 5
    max_pods            = 30
    node_labels         = { app = "keycloak" }
    taints              = ["app=keycloak:NoSchedule"]
    availability_zones  = ["1","2","3"]
    vnet_subnet_id      = ""
  }
  integrateai = {
    name                = "integrateai"
    vm_size             = "Standard_D2s_v5"
    os_disk_size_gb     = 50
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 5
    max_pods            = 30
    node_labels         = { app = "integrateai" }
    taints              = ["app=integrateai:NoSchedule"]
    availability_zones  = ["1","2","3"]
    vnet_subnet_id      = ""
  }
  webapp = {
    name                = "webapp"
    vm_size             = "Standard_D2s_v5"
    os_disk_size_gb     = 50
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 5
    max_pods            = 30
    node_labels         = { app = "webapp" }
    taints              = ["app=webapp:NoSchedule"]
    availability_zones  = ["1","2","3"]
    vnet_subnet_id      = ""
  }
}

network_plugin     = "azure"
dns_service_ip     = "10.2.0.10"
service_cidr       = "10.2.0.0/24"

api_server_authorized_ip_ranges = ["203.0.113.10/32"]   # bastion / VPN CIDR

########################
# 9. Log Analytics
########################
log_analytics_name = "${prefix}-log"
log_retention      = 30

########################
# 10. Application Gateway & WAF
########################
app_gateway_name            = "${prefix}-appgw"
app_gateway_subnet_name     = "appgw"          # must match subnets key
app_gateway_public_ip_name  = "${prefix}-appgw-pip"
app_gateway_frontend_port   = 80
app_gateway_backend_port    = 80
app_gateway_backend_ip_addresses = ["10.31.4.4", "10.31.4.5"]  # <- AGIC replaces these
app_gateway_sku_name        = "WAF_v2"
app_gateway_sku_tier        = "WAF_v2"
app_gateway_capacity        = 2
app_gateway_tags            = tags
