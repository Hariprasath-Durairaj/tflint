resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  node_resource_group = var.node_resource_group

  default_node_pool {
    name                          = var.default_node_pool.name
    vm_size                       = var.default_node_pool.vm_size
    temporary_name_for_rotation   = var.default_node_pool.temporary_name_for_rotation
    enable_auto_scaling           = var.default_node_pool.enable_auto_scaling
    min_count                     = var.default_node_pool.min_count
    max_count                     = var.default_node_pool.max_count
    max_pods                      = var.default_node_pool.max_pods
    os_disk_size_gb               = var.default_node_pool.os_disk_size_gb
    node_labels                   = var.default_node_pool.node_labels
    vnet_subnet_id                = var.default_node_pool.vnet_subnet_id
    zones                         = var.default_node_pool.availability_zones
    tags                          = var.default_node_pool.tags
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  network_profile {
    network_plugin = var.network_plugin
    dns_service_ip = var.dns_service_ip
    service_cidr   = var.service_cidr
  }

  private_cluster_enabled          = var.private_cluster_enabled
  api_server_access_profile {
  authorized_ip_ranges = var.api_server_authorized_ip_ranges
}

oms_agent {
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

  tags = var.tags
}

# ✅ Move this here — after AKS cluster is declared
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each              = var.user_node_pools
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  os_disk_size_gb       = each.value.os_disk_size_gb
  node_count            = each.value.node_count
  max_pods              = each.value.max_pods
  mode                  = each.value.mode
  node_labels           = each.value.node_labels
  vnet_subnet_id        = each.value.vnet_subnet_id
  zones                 = each.value.availability_zones
  tags                  = each.value.tags
}
