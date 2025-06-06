# General Variables
variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID"
  type        = string
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
}

# Virtual Network (VNet)
variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
}

variable "subnets" {
  description = "Subnets to be created in the VNet"
  type        = map(list(string))
}

# Public IPs
variable "public_ip_nginx_name" {
  description = "Name of the public IP for NGINX Ingress"
  type        = string
}

variable "public_ip_bastion_name" {
  description = "The name of the public IP for Bastion"
  type        = string
}

# Network Security Group (NSG)
variable "nsg_name" {
  description = "Name of the Network Security Group"
  type        = string
}

variable "nsg_security_rules" {
  description = "List of NSG security rules"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}

# NAT Gateway
variable "nat_gateway_name" {
  description = "Name of the NAT Gateway"
  type        = string
}

# Bastion
variable "bastion_name" {
  description = "Name of the Bastion host"
  type        = string
}

# Private DNS
variable "private_dns_name" {
  description = "Name of the private DNS zone"
  type        = string
}

variable "private_dns_link_name" {
  description = "Name of the private DNS link"
  type        = string
}

# VNet Peering
variable "vnet_peering_name" {
  description = "Name of the VNet peering"
  type        = string
}

variable "remote_virtual_network_id" {
  description = "ID of the remote virtual network"
  type        = string
}

# Key Vault and Encryption
variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
}

variable "des_name" {
  description = "Name of the Disk Encryption Set"
  type        = string
}

variable "key_vault_key_id" {
  description = "Key Vault Key ID"
  type        = string
}

# Azure Container Registry (ACR)
variable "acr_name" {
  description = "Name of the Azure Container Registry (ACR)"
  type        = string
}

# AKS Cluster Configuration
variable "aks_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS"
  type        = string
}

variable "node_resource_group" {
  description = "Resource group for AKS nodes"
  type        = string
}

variable "default_node_pool" {
  description = "The default node pool configuration for AKS"
  type = object({
    name                        = string
    vm_size                     = string
    enable_auto_scaling         = bool
    node_count                  = number
    min_count                   = number
    max_count                   = number
    max_pods                    = number
    os_disk_size_gb             = number
    type                        = string
    node_labels                 = map(string)
    tags                        = map(string)
    vnet_subnet_id              = string
    temporary_name_for_rotation = optional(string)
    availability_zones          = optional(list(string))
  })
}

variable "user_node_pools" {
  description = "User node pools for AKS"
  type        = map(any)
}

# AKS Network
variable "network_plugin" {
  description = "Network plugin for AKS"
  type        = string
}

variable "dns_service_ip" {
  description = "DNS service IP for AKS"
  type        = string
}

variable "service_cidr" {
  description = "Service CIDR for AKS"
  type        = string
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR"
  type        = string
}

# Log Analytics
variable "log_analytics_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "log_retention" {
  description = "Log retention in days"
  type        = number
}

# Backup Vault
variable "backup_vault_name" {
  description = "Name of the Recovery Services Backup Vault"
  type        = string
}

variable "api_server_authorized_ip_ranges" {
  description = "List of IPs allowed to access the AKS API server"
  type        = list(string)
  default     = []
}

variable "private_cluster_enabled" {
  description = "Whether the AKS cluster is private"
  type        = bool
  default     = false
}


variable "enable_monitoring" {
  description = "Enable monitoring (OMS agent) for AKS"
  type        = bool
  default     = true
}


variable "app_gateway_name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "app_gateway_subnet_name" {
  description = "Name of the subnet for the Application Gateway"
  type        = string
}

variable "app_gateway_frontend_port" {
  description = "Frontend port for the Application Gateway"
  type        = number
}

variable "app_gateway_backend_ip_addresses" {
  description = "List of backend IP addresses for the Application Gateway"
  type        = list(string)
}

variable "app_gateway_backend_port" {
  description = "Backend port number for App Gateway"
  type        = number
}

variable "app_gateway_sku_name" {
  description = "SKU name for Application Gateway"
  type        = string
}

variable "app_gateway_sku_tier" {
  description = "SKU tier for Application Gateway"
  type        = string
}

variable "app_gateway_capacity" {
  description = "Capacity for Application Gateway"
  type        = number
}

variable "app_gateway_tags" {
  description = "Tags for Application Gateway"
  type        = map(string)
  default     = {}
}
variable "app_gateway_public_ip_name" {
  description = "Public IP resource name for Application Gateway"
  type        = string
  default     = null
}

variable "custom_rules" {
  description = "Custom WAF rules for Application Gateway"
  type        = list(any)
  default     = []
}
