locals {
  project_name = "mecha-buda"

  tags = {
    project = local.project_name
    env     = var.environment
    owner   = "gustavo.scheffer"
    billing = "000000"
  } 
}

resource "azurerm_resource_group" "rg" {
  name     = "mecha-buda-rg-${var.environment}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_container_registry" "acr" {
  name                = "mechabudaacr${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.project_name}-aks-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_tier = "Free"

  dns_prefix = "${local.project_name}-aks-${var.environment}"

  network_profile {
    network_plugin = "azure"
    network_plugin_mode = "overlay"
  }

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_D2_v2"

  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "example" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}